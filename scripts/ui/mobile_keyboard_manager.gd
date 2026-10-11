class_name MobileKeyboardManager
extends Node

## MobileKeyboardManager
## Automatically detects mobile devices (Android, iOS) and mobile web browsers (Chrome, Safari, etc.)
## ensuring that tapping on ANY LineEdit or TextEdit reliably triggers a dedicated top-anchored
## pop-up input panel with mobile keyboard support, visible blinking caret, and zero UI lag.

static var _instance: MobileKeyboardManager = null
static var _is_mobile_cached: int = -1
static var _active_popup_layer: CanvasLayer = null
static var _active_popup_control: Control = null


func _ready() -> void:
	_instance = self
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Listen for any new LineEdit or TextEdit nodes added to the scene tree dynamically
	get_tree().node_added.connect(_on_node_added)

	# Scan existing scene tree deferred so everything is ready
	_scan_tree.call_deferred(get_tree().root)


func _on_node_added(node: Node) -> void:
	if (node is LineEdit or node is TextEdit) and not node.get_meta("is_popup_input", false):
		attach_to_input(node as Control)


func _scan_tree(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	if (node is LineEdit or node is TextEdit) and not node.get_meta("is_popup_input", false):
		attach_to_input(node as Control)
	for child in node.get_children(true):
		_scan_tree(child)


## Determines if the game is running on a mobile device (native Android/iOS or mobile web browser)
static func is_mobile() -> bool:
	if _is_mobile_cached != -1:
		return _is_mobile_cached == 1

	if OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios"):
		_is_mobile_cached = 1
		return true

	var os_name := OS.get_name().to_lower()
	if os_name == "android" or os_name == "ios":
		_is_mobile_cached = 1
		return true

	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		_is_mobile_cached = 1
		return true

	if DisplayServer.is_touchscreen_available():
		_is_mobile_cached = 1
		return true

	if is_mobile_web():
		_is_mobile_cached = 1
		return true

	return false


## Specifically detects mobile browsers (iOS Safari, Android Chrome, tablet touchscreens) via JavaScriptBridge
static func is_mobile_web() -> bool:
	if not OS.has_feature("web"):
		return false

	var win = JavaScriptBridge.get_interface("window")
	if win == null:
		return false

	var res = JavaScriptBridge.eval("""
		(function() {
			try {
				if (typeof window.isMobileBrowser === 'function') {
					return Boolean(window.isMobileBrowser());
				}
				var ua = navigator.userAgent || '';
				var isMobileUA = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|Silk/i.test(ua);
				var isTouchMac = (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
				var hasCoarse = window.matchMedia && (window.matchMedia('(pointer: coarse)').matches || window.matchMedia('(hover: none)').matches);
				var hasTouch = ('ontouchstart' in window) || (navigator.maxTouchPoints > 0);
				return Boolean(isMobileUA || isTouchMac || hasCoarse || hasTouch);
			} catch(e) {
				return true;
			}
		})()
	""")
	return bool(res)


## Calculates the top safe area inset for notched mobile screens and iOS Safari dynamic island
static func get_safe_area_top() -> float:
	var top_m: float = 0.0
	if DisplayServer.has_method("get_display_safe_area"):
		var safe: Rect2i = DisplayServer.get_display_safe_area()
		var screen_h: int = DisplayServer.screen_get_size().y
		if screen_h > 0 and safe.size.y > 0 and safe.size.y < screen_h:
			var canvas_h: float = 1920.0
			var tree = Engine.get_main_loop() as SceneTree
			if tree != null and tree.root != null:
				canvas_h = tree.root.get_visible_rect().size.y
			var canvas_scale: float = canvas_h / float(screen_h)
			top_m = float(safe.position.y) * canvas_scale

	if OS.has_feature("web"):
		var win = JavaScriptBridge.get_interface("window")
		if win != null:
			var res = JavaScriptBridge.eval("""
				(function() {
					try {
						if (typeof window.getSafeAreaInsets === 'function') {
							return window.getSafeAreaInsets();
						}
						var div = document.createElement('div');
						div.style.position = 'fixed';
						div.style.top = '0';
						div.style.paddingTop = 'env(safe-area-inset-top, 0px)';
						div.style.visibility = 'hidden';
						document.body.appendChild(div);
						var cs = window.getComputedStyle(div);
						var pt = parseFloat(cs.paddingTop) || 0;
						document.body.removeChild(div);
						return JSON.stringify({ "top": pt, "win_w": window.innerWidth || 390 });
					} catch(e) {
						return "";
					}
				})()
			""")
			if res != null and typeof(res) == TYPE_STRING and not str(res).is_empty():
				var parsed = JSON.parse_string(str(res))
				if parsed is Dictionary:
					var pt: float = float(parsed.get("top", 0.0))
					var win_w: float = float(parsed.get("win_w", 390.0))
					var canvas_w: float = 1080.0
					var scale_factor: float = canvas_w / maxf(1.0, win_w)
					var web_top: float = pt * scale_factor
					if web_top > top_m:
						top_m = web_top
	return top_m


static func _is_light_theme() -> bool:
	var tree = Engine.get_main_loop() as SceneTree
	if tree != null and tree.root != null:
		var lib = tree.root.get_node_or_null("LifeLibrary")
		if lib != null and "data" in lib and lib.data != null:
			return str(lib.data.get("theme", "")) == "light"
	return false


## Returns true if a text input popup panel is currently active
static func is_popup_open() -> bool:
	return _active_popup_control != null and is_instance_valid(_active_popup_control)


## Closes any currently active text input popup panel
static func close_active_popup() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		DisplayServer.virtual_keyboard_hide()
	if is_instance_valid(_active_popup_layer):
		_active_popup_layer.queue_free()
	_active_popup_layer = null
	_active_popup_control = null


## Attaches mobile keyboard triggering behavior and popup interceptor to any LineEdit or TextEdit control
static func attach_to_input(input_ctrl: Control, prompt_title: String = "") -> void:
	if input_ctrl == null or not is_instance_valid(input_ctrl):
		return
	if input_ctrl.get_meta("is_popup_input", false):
		return
	if not prompt_title.is_empty():
		input_ctrl.set_meta("mobile_kb_prompt_title", prompt_title)

	if input_ctrl.has_meta("mobile_kb_attached"):
		return

	input_ctrl.set_meta("mobile_kb_attached", true)

	if input_ctrl is LineEdit:
		var le := input_ctrl as LineEdit
		le.virtual_keyboard_enabled = true
		le.focus_mode = Control.FOCUS_ALL
	elif input_ctrl is TextEdit:
		var te := input_ctrl as TextEdit
		te.virtual_keyboard_enabled = true
		te.focus_mode = Control.FOCUS_ALL

	# Connect gui_input to capture direct screen touches and clicks
	var touch_down_pos := Vector2.ZERO
	var touch_down_time: int = 0

	input_ctrl.gui_input.connect(func(event: InputEvent):
		if input_ctrl.get_meta("is_popup_input", false):
			return
		if event is InputEventScreenTouch:
			var st := event as InputEventScreenTouch
			if st.pressed:
				touch_down_pos = st.position
				touch_down_time = Time.get_ticks_msec()
			else:
				var dist := (st.position - touch_down_pos).length()
				var duration := Time.get_ticks_msec() - touch_down_time
				if dist < 40.0 and duration < 800:
					open_keyboard(input_ctrl, input_ctrl.get_meta("mobile_kb_prompt_title", ""), true)
		elif event is InputEventMouseButton:
			var mb := event as InputEventMouseButton
			if mb.button_index == MOUSE_BUTTON_LEFT:
				if mb.pressed:
					touch_down_pos = mb.position
					touch_down_time = Time.get_ticks_msec()
				else:
					var dist := (mb.position - touch_down_pos).length()
					var duration := Time.get_ticks_msec() - touch_down_time
					if dist < 40.0 and duration < 800:
						open_keyboard(input_ctrl, input_ctrl.get_meta("mobile_kb_prompt_title", ""), true)
	)

	# Connect focus_entered to trigger keyboard/popup whenever the input gains focus
	input_ctrl.focus_entered.connect(func():
		if input_ctrl.get_meta("is_popup_input", false):
			return
		open_keyboard(input_ctrl, input_ctrl.get_meta("mobile_kb_prompt_title", ""))
	)


## Creates a dummy keyboard trigger button (kept for backwards-compatibility)
static func create_keyboard_trigger_button(input_ctrl: Control, button_title: String = "⌨️ Type Custom Value", prompt_title: String = "", _btn_color: Color = Color("#00f0ff")) -> Button:
	var btn := Button.new()
	btn.name = "MobileKeyboardTriggerButton"
	btn.text = button_title
	btn.visible = false
	btn.custom_minimum_size = Vector2.ZERO
	btn.pressed.connect(func():
		if input_ctrl != null and is_instance_valid(input_ctrl):
			input_ctrl.grab_focus()
			open_keyboard(input_ctrl, prompt_title, true)
	)
	return btn


## Opens the dedicated top-anchored pop-up panel for the target input control
static func open_keyboard(input_ctrl: Control, prompt_override: String = "", _force_prompt: bool = false) -> void:
	if input_ctrl == null or not is_instance_valid(input_ctrl):
		return

	if not input_ctrl.is_visible_in_tree():
		return
	if input_ctrl is LineEdit and not (input_ctrl as LineEdit).editable:
		return
	if input_ctrl is TextEdit and not (input_ctrl as TextEdit).editable:
		return

	# If this is the LineEdit inside the popup itself, directly show the virtual keyboard
	if input_ctrl.get_meta("is_popup_input", false):
		var cur_txt := ""
		var m_len := -1
		var kb_t := DisplayServer.KEYBOARD_TYPE_DEFAULT
		if input_ctrl is LineEdit:
			var le := input_ctrl as LineEdit
			cur_txt = le.text
			m_len = le.max_length
			kb_t = int(le.virtual_keyboard_type) as DisplayServer.VirtualKeyboardType
		elif input_ctrl is TextEdit:
			cur_txt = (input_ctrl as TextEdit).text
			kb_t = DisplayServer.KEYBOARD_TYPE_MULTILINE

		DisplayServer.virtual_keyboard_show(cur_txt, input_ctrl.get_global_rect(), kb_t, m_len)
		return

	# Debounce within 250ms to prevent double-firing
	var now := Time.get_ticks_msec()
	var last_open: int = int(input_ctrl.get_meta("last_kb_open_time", -500))
	if (now - last_open) < 250:
		return
	input_ctrl.set_meta("last_kb_open_time", now)

	# Ensure control has focus
	if not input_ctrl.has_focus() and input_ctrl.focus_mode != Control.FOCUS_NONE:
		input_ctrl.grab_focus()

	# Determine Title
	var title_str := prompt_override
	if title_str.is_empty():
		title_str = str(input_ctrl.get_meta("mobile_kb_prompt_title", ""))
	if title_str.is_empty() and input_ctrl is LineEdit:
		title_str = (input_ctrl as LineEdit).placeholder_text
	if title_str.is_empty():
		title_str = "ENTER VALUE"

	show_input_popup({
		"target_control": input_ctrl,
		"title": title_str
	})


## Universal pop-up panel for all text inputs across the game.
## Renders in the upper safe-zone above mobile keyboards, ensuring zero occlusion,
## properly placed blinking caret, high contrast, and zero UI lag.
static func show_input_popup(options: Dictionary) -> Control:
	close_active_popup()

	var tree = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return null

	var target_ctrl: Control = options.get("target_control", null)

	# 1. Determine Title & Text Values
	var title_str: String = options.get("title", "")
	if title_str.is_empty() and target_ctrl != null:
		title_str = str(target_ctrl.get_meta("mobile_kb_prompt_title", ""))
	if title_str.is_empty() and target_ctrl is LineEdit:
		title_str = (target_ctrl as LineEdit).placeholder_text
	if title_str.is_empty():
		title_str = "ENTER VALUE"

	var subtitle_str: String = options.get("subtitle", "")

	var initial_val: String = ""
	if options.has("initial_value"):
		initial_val = str(options.initial_value)
	elif target_ctrl is LineEdit:
		initial_val = (target_ctrl as LineEdit).text
	elif target_ctrl is TextEdit:
		initial_val = (target_ctrl as TextEdit).text

	var placeholder_str: String = ""
	if options.has("placeholder"):
		placeholder_str = str(options.placeholder)
	elif target_ctrl is LineEdit:
		placeholder_str = (target_ctrl as LineEdit).placeholder_text
	if placeholder_str.is_empty():
		placeholder_str = "Type here..."

	var kb_type: int = int(options.get("keyboard_type", -1))
	if kb_type == -1 and target_ctrl is LineEdit:
		kb_type = int((target_ctrl as LineEdit).virtual_keyboard_type)
	elif kb_type == -1:
		kb_type = int(LineEdit.KEYBOARD_TYPE_DEFAULT)

	var is_secret: bool = bool(options.get("secret", false))
	if not options.has("secret") and target_ctrl is LineEdit:
		is_secret = (target_ctrl as LineEdit).secret

	var max_len: int = int(options.get("max_length", 0))
	if max_len <= 0 and target_ctrl is LineEdit:
		max_len = (target_ctrl as LineEdit).max_length

	var is_light := _is_light_theme()

	# Styling palette
	var card_bg: Color = Color("#ffffff") if is_light else Color("#0c1527")
	var card_border: Color = Color("#0284c7") if is_light else Color("#00f0ff")
	var title_col: Color = Color("#0369a1") if is_light else Color("#00f0ff")
	var subtitle_col: Color = Color("#475569") if is_light else Color("#bae6fd")
	var input_bg: Color = Color("#f8fafc") if is_light else Color("#16233b")
	var input_border: Color = Color("#0284c7") if is_light else Color("#38bdf8")
	var input_text_col: Color = Color("#0f172a") if is_light else Color("#f8fafc")
	var placeholder_col: Color = Color("#94a3b8") if is_light else Color("#64748b")
	var caret_col: Color = Color("#0284c7") if is_light else Color("#00f0ff")

	# Dedicated top layer so it sits cleanly above modals and scene hierarchy
	var canvas_layer := CanvasLayer.new()
	canvas_layer.name = "TextInputPopupLayer"
	canvas_layer.layer = 120

	var overlay := Control.new()
	overlay.name = "TextInputPopupOverlay"
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas_layer.add_child(overlay)

	# Dimmer backdrop
	var backdrop := ColorRect.new()
	backdrop.name = "PopupBackdrop"
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0, 0, 0, 0.45) if is_light else Color(0, 0, 0, 0.65)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(backdrop)

	# Responsive width & top safe zone placement
	var vp_w: float = 1080.0
	if tree.root != null:
		vp_w = tree.root.get_visible_rect().size.x
	var card_w: float = minf(700.0, vp_w - 32.0)
	var top_margin: float = maxf(110.0, get_safe_area_top() + 40.0)

	var card := PanelContainer.new()
	card.name = "PopupCard"
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.anchor_left = 0.5
	card.anchor_right = 0.5
	card.offset_left = -card_w / 2.0
	card.offset_right = card_w / 2.0
	card.anchor_top = 0.0
	card.anchor_bottom = 0.0
	card.offset_top = top_margin
	card.custom_minimum_size = Vector2(card_w, 0)

	var card_sb := StyleBoxFlat.new()
	card_sb.bg_color = card_bg
	card_sb.border_color = card_border
	card_sb.set_border_width_all(2)
	card_sb.set_corner_radius_all(16)
	card_sb.shadow_color = Color(0, 0, 0, 0.40)
	card_sb.shadow_size = 14
	card.add_theme_stylebox_override("panel", card_sb)
	overlay.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	# Title Label
	var lbl_title := Label.new()
	lbl_title.name = "PopupTitle"
	lbl_title.text = title_str.to_upper()
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_title.add_theme_font_size_override("font_size", 28)
	lbl_title.add_theme_color_override("font_color", title_col)
	vbox.add_child(lbl_title)

	# Subtitle Label
	if not subtitle_str.is_empty():
		var lbl_sub := Label.new()
		lbl_sub.name = "PopupSubtitle"
		lbl_sub.text = subtitle_str
		lbl_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_sub.add_theme_font_size_override("font_size", 22)
		lbl_sub.add_theme_color_override("font_color", subtitle_col)
		vbox.add_child(lbl_sub)

	# Dedicated LineEdit
	var input_box := LineEdit.new()
	input_box.name = "PopupInputBox"
	input_box.text = initial_val
	input_box.placeholder_text = placeholder_str
	input_box.virtual_keyboard_enabled = true
	input_box.virtual_keyboard_type = kb_type as LineEdit.VirtualKeyboardType
	input_box.secret = is_secret
	input_box.max_length = max_len
	input_box.alignment = HORIZONTAL_ALIGNMENT_CENTER
	input_box.custom_minimum_size = Vector2(1, 64)
	input_box.add_theme_font_size_override("font_size", 28)
	input_box.add_theme_color_override("font_color", input_text_col)
	input_box.add_theme_color_override("font_placeholder_color", placeholder_col)

	# Caret properties (blinking typing indicator, properly placed with generous margins)
	input_box.caret_blink = true
	input_box.caret_blink_interval = 0.5
	input_box.caret_force_displayed = true
	input_box.add_theme_color_override("caret_color", caret_col)

	var input_sb := StyleBoxFlat.new()
	input_sb.bg_color = input_bg
	input_sb.border_color = input_border
	input_sb.set_border_width_all(2)
	input_sb.set_corner_radius_all(10)
	input_sb.content_margin_left = 20
	input_sb.content_margin_right = 20
	input_sb.content_margin_top = 12
	input_sb.content_margin_bottom = 12
	input_box.add_theme_stylebox_override("normal", input_sb)
	input_box.add_theme_stylebox_override("focus", input_sb)

	# Mark as popup input to prevent recursive popup triggering
	input_box.set_meta("is_popup_input", true)
	if target_ctrl != null:
		input_box.set_meta("target_control", target_ctrl)
	vbox.add_child(input_box)

	# Action Buttons Row
	var btn_row := HBoxContainer.new()
	btn_row.name = "PopupActionButtons"
	btn_row.add_theme_constant_override("separation", 12)
	btn_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(btn_row)

	var on_confirm_cb: Callable = options.get("on_confirm", Callable())
	var on_cancel_cb: Callable = options.get("on_cancel", Callable())
	var custom_actions: Array = options.get("custom_actions", [])

	var do_dismiss := func():
		close_active_popup()

	var do_confirm_action := func(submitted_text: String):
		var clean_val := submitted_text.strip_edges()
		if target_ctrl != null and is_instance_valid(target_ctrl):
			_apply_input_text(target_ctrl, clean_val)
		if on_confirm_cb.is_valid():
			on_confirm_cb.call(clean_val)
		do_dismiss.call()

	# Custom actions (e.g. Dual Withdraw Dividend / Inject Capital for Treasury)
	if not custom_actions.is_empty():
		for act in custom_actions:
			var act_btn := Button.new()
			act_btn.text = str(act.get("label", "Action"))
			act_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			act_btn.custom_minimum_size = Vector2(0, 54)
			act_btn.add_theme_font_size_override("font_size", 24)
			act_btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
			act_btn.set_meta("center_text", true)
			var act_col: Color = act.get("color", Color("#0284c7"))
			_style_popup_button(act_btn, act_col, is_light)
			var act_cb: Callable = act.get("callback", Callable())
			act_btn.pressed.connect(func():
				var clean_val := input_box.text.strip_edges()
				if act_cb.is_valid():
					act_cb.call(clean_val)
				do_dismiss.call()
			)
			btn_row.add_child(act_btn)

		var cancel_btn := Button.new()
		cancel_btn.text = str(options.get("cancel_text", "✕ Cancel"))
		cancel_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cancel_btn.custom_minimum_size = Vector2(0, 54)
		cancel_btn.add_theme_font_size_override("font_size", 24)
		cancel_btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
		cancel_btn.set_meta("center_text", true)
		_style_popup_button(cancel_btn, Color("#64748b"), is_light)
		cancel_btn.pressed.connect(func():
			if on_cancel_cb.is_valid():
				on_cancel_cb.call()
			do_dismiss.call()
		)
		btn_row.add_child(cancel_btn)
	else:
		var confirm_btn := Button.new()
		confirm_btn.name = "PopupConfirmButton"
		confirm_btn.text = str(options.get("confirm_text", "✓ Confirm"))
		confirm_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		confirm_btn.custom_minimum_size = Vector2(0, 54)
		confirm_btn.add_theme_font_size_override("font_size", 24)
		confirm_btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
		confirm_btn.set_meta("center_text", true)
		var conf_col: Color = options.get("confirm_color", Color("#10b981"))
		_style_popup_button(confirm_btn, conf_col, is_light)
		confirm_btn.pressed.connect(func():
			do_confirm_action.call(input_box.text)
		)
		btn_row.add_child(confirm_btn)

		var cancel_btn := Button.new()
		cancel_btn.name = "PopupCancelButton"
		cancel_btn.text = str(options.get("cancel_text", "✕ Cancel"))
		cancel_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cancel_btn.custom_minimum_size = Vector2(0, 54)
		cancel_btn.add_theme_font_size_override("font_size", 24)
		cancel_btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
		cancel_btn.set_meta("center_text", true)
		_style_popup_button(cancel_btn, Color("#64748b"), is_light)
		cancel_btn.pressed.connect(func():
			if on_cancel_cb.is_valid():
				on_cancel_cb.call()
			do_dismiss.call()
		)
		btn_row.add_child(cancel_btn)

	# Enter key submissions
	input_box.text_submitted.connect(func(text_val: String):
		if not custom_actions.is_empty():
			var first_act: Dictionary = custom_actions[0]
			var act_cb: Callable = first_act.get("callback", Callable())
			if act_cb.is_valid():
				act_cb.call(text_val.strip_edges())
			do_dismiss.call()
		else:
			do_confirm_action.call(text_val)
	)

	# PopupCard is positioned directly under a Control overlay, so it does not
	# receive a container-assigned height. Size it from the completed content
	# before showing it; otherwise only the focused LineEdit can leak outside
	# the zero-height card on mobile viewports.
	var popup_height := maxf(1.0, margin.get_combined_minimum_size().y)
	card.size = Vector2(card_w, popup_height)
	card.offset_bottom = card.offset_top + popup_height

	# Backdrop tap dismisses popup cleanly
	backdrop.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if on_cancel_cb.is_valid():
				on_cancel_cb.call()
			do_dismiss.call()
		elif event is InputEventScreenTouch and event.pressed:
			if on_cancel_cb.is_valid():
				on_cancel_cb.call()
			do_dismiss.call()
	)

	tree.root.add_child(canvas_layer)
	_active_popup_layer = canvas_layer
	_active_popup_control = overlay

	# Focus deferred and virtual keyboard trigger
	input_box.call_deferred("grab_focus")
	input_box.call_deferred("set_caret_column", input_box.text.length())
	var ds_kb_type: DisplayServer.VirtualKeyboardType = int(input_box.virtual_keyboard_type) as DisplayServer.VirtualKeyboardType
	DisplayServer.virtual_keyboard_show(input_box.text, input_box.get_global_rect(), ds_kb_type, input_box.max_length)

	return overlay


static func _style_popup_button(btn: Button, accent_col: Color, is_light: bool) -> void:
	var sb_normal := StyleBoxFlat.new()
	sb_normal.bg_color = accent_col.lerp(Color.WHITE, 0.15) if is_light else accent_col.lerp(Color.BLACK, 0.40)
	sb_normal.border_color = accent_col
	sb_normal.set_border_width_all(2)
	sb_normal.set_corner_radius_all(10)
	sb_normal.content_margin_top = 10
	sb_normal.content_margin_bottom = 10
	sb_normal.content_margin_left = 16
	sb_normal.content_margin_right = 16

	var sb_hover := StyleBoxFlat.new()
	sb_hover.bg_color = accent_col.lerp(Color.WHITE, 0.3) if is_light else accent_col.lerp(Color.BLACK, 0.20)
	sb_hover.border_color = accent_col.lightened(0.2)
	sb_hover.set_border_width_all(2)
	sb_hover.set_corner_radius_all(10)
	sb_hover.content_margin_top = 10
	sb_hover.content_margin_bottom = 10
	sb_hover.content_margin_left = 16
	sb_hover.content_margin_right = 16

	var sb_pressed := StyleBoxFlat.new()
	sb_pressed.bg_color = accent_col.darkened(0.2)
	sb_pressed.border_color = accent_col.lightened(0.4)
	sb_pressed.set_border_width_all(2)
	sb_pressed.set_corner_radius_all(10)
	sb_pressed.content_margin_top = 10
	sb_pressed.content_margin_bottom = 10
	sb_pressed.content_margin_left = 16
	sb_pressed.content_margin_right = 16

	btn.add_theme_stylebox_override("normal", sb_normal)
	btn.add_theme_stylebox_override("hover", sb_hover)
	btn.add_theme_stylebox_override("pressed", sb_pressed)
	btn.add_theme_stylebox_override("focus", sb_normal)

	var text_col := Color("#0f172a") if (is_light and accent_col.get_luminance() > 0.6) else Color("#ffffff")
	btn.add_theme_color_override("font_color", text_col)
	btn.add_theme_color_override("font_hover_color", text_col)
	btn.add_theme_color_override("font_pressed_color", text_col)


static func _apply_input_text(input_ctrl: Control, res_str: String) -> void:
	if input_ctrl == null or not is_instance_valid(input_ctrl):
		return
	if input_ctrl is LineEdit:
		var le := input_ctrl as LineEdit
		if le.max_length > 0 and res_str.length() > le.max_length:
			res_str = res_str.substr(0, le.max_length)
		# Normalize before notifying validation and submission handlers.
		if le.name == "NameInput" or le.get_meta("is_name_input", false):
			var CreationOptionsRef = load("res://scripts/core/creation_options.gd")
			if CreationOptionsRef != null:
				res_str = CreationOptionsRef.normalize_name(res_str)
		le.text = res_str
		le.text_changed.emit(le.text)
		if is_instance_valid(le):
			le.text_submitted.emit(le.text)
	elif input_ctrl is TextEdit:
		var te := input_ctrl as TextEdit
		te.text = res_str
		te.text_changed.emit()
