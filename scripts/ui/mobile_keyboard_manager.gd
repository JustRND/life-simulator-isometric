class_name MobileKeyboardManager
extends Node

## MobileKeyboardManager
## Automatically detects mobile devices (Android, iOS) and mobile web browsers (Chrome, Safari, etc.)
## ensuring that tapping on ANY LineEdit or TextEdit reliably triggers virtual keyboard input.

static var _instance: MobileKeyboardManager = null
static var _active_callbacks: Dictionary = {}
static var _is_mobile_cached: int = -1


func _ready() -> void:
	_instance = self
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Listen for any new LineEdit or TextEdit nodes added to the scene tree dynamically
	get_tree().node_added.connect(_on_node_added)

	# Scan existing scene tree deferred so everything is ready
	_scan_tree.call_deferred(get_tree().root)


func _on_node_added(node: Node) -> void:
	if node is LineEdit or node is TextEdit:
		attach_to_input(node as Control)


func _scan_tree(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	if node is LineEdit or node is TextEdit:
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


## Attaches mobile keyboard triggering behavior to any LineEdit or TextEdit control
static func attach_to_input(input_ctrl: Control, prompt_title: String = "") -> void:
	if input_ctrl == null or not is_instance_valid(input_ctrl):
		return
	if not prompt_title.is_empty():
		input_ctrl.set_meta("mobile_kb_prompt_title", prompt_title)

	if input_ctrl.has_meta("mobile_kb_attached"):
		return

	input_ctrl.set_meta("mobile_kb_attached", true)

	if input_ctrl is LineEdit:
		var le := input_ctrl as LineEdit
		le.virtual_keyboard_enabled = not is_mobile_web()
		le.focus_mode = Control.FOCUS_ALL
	elif input_ctrl is TextEdit:
		input_ctrl.virtual_keyboard_enabled = not is_mobile_web()
		input_ctrl.focus_mode = Control.FOCUS_ALL

	# Connect gui_input to capture direct screen touches and clicks
	var touch_down_pos := Vector2.ZERO
	var touch_down_time: int = 0

	input_ctrl.gui_input.connect(func(event: InputEvent):
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
						if is_mobile() or is_mobile_web():
							open_keyboard(input_ctrl, input_ctrl.get_meta("mobile_kb_prompt_title", ""), true)
	)

	# Connect focus_entered to trigger keyboard whenever the input gains focus
	input_ctrl.focus_entered.connect(func():
		if is_mobile() or is_mobile_web():
			open_keyboard(input_ctrl, input_ctrl.get_meta("mobile_kb_prompt_title", ""))
	)


## Creates a styled cyber button dedicated to triggering mobile keyboard input for a specific input field
static func create_keyboard_trigger_button(input_ctrl: Control, button_title: String = "⌨️ Type Custom Value", prompt_title: String = "", btn_color: Color = Color("#00f0ff")) -> Button:
	var btn := Button.new()
	btn.name = "MobileKeyboardTriggerButton"
	btn.text = button_title
	btn.custom_minimum_size.y = 54
	btn.add_theme_font_size_override("font_size", 22)
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.set_meta("center_text", true)

	var sb_normal := StyleBoxFlat.new()
	sb_normal.bg_color = Color(btn_color.r * 0.15, btn_color.g * 0.15, btn_color.b * 0.15, 0.95)
	sb_normal.border_color = btn_color
	sb_normal.set_border_width_all(2)
	sb_normal.set_corner_radius_all(10)
	sb_normal.content_margin_left = 16
	sb_normal.content_margin_right = 16

	var sb_hover := sb_normal.duplicate() as StyleBoxFlat
	sb_hover.bg_color = Color(btn_color.r * 0.3, btn_color.g * 0.3, btn_color.b * 0.3, 0.98)
	sb_hover.border_color = Color("#ffffff")

	var sb_pressed := sb_normal.duplicate() as StyleBoxFlat
	sb_pressed.bg_color = btn_color

	btn.add_theme_stylebox_override("normal", sb_normal)
	btn.add_theme_stylebox_override("hover", sb_hover)
	btn.add_theme_stylebox_override("pressed", sb_pressed)
	btn.add_theme_color_override("font_color", Color("#ffffff"))
	btn.add_theme_color_override("font_hover_color", Color("#ffffff"))
	btn.add_theme_color_override("font_pressed_color", Color("#000000"))

	btn.pressed.connect(func():
		open_keyboard(input_ctrl, prompt_title, true)
	)
	return btn


## Opens the virtual keyboard for the target input control
static func open_keyboard(input_ctrl: Control, prompt_override: String = "", force_prompt: bool = false) -> void:
	if input_ctrl == null or not is_instance_valid(input_ctrl):
		return

	if not input_ctrl.is_visible_in_tree():
		return
	if input_ctrl is LineEdit and not input_ctrl.editable:
		return
	if input_ctrl is TextEdit and not input_ctrl.editable:
		return

	# Debounce within 200ms to prevent double-firing
	var now := Time.get_ticks_msec()
	var last_open: int = int(input_ctrl.get_meta("last_kb_open_time", -500))
	if (now - last_open) < 200:
		return
	input_ctrl.set_meta("last_kb_open_time", now)

	# Ensure control has focus
	if not input_ctrl.has_focus() and input_ctrl.focus_mode != Control.FOCUS_NONE:
		input_ctrl.grab_focus()

	var current_text := ""
	var max_len := -1
	if input_ctrl is LineEdit:
		var le := input_ctrl as LineEdit
		current_text = le.text
		max_len = le.max_length
	elif input_ctrl is TextEdit:
		var te := input_ctrl as TextEdit
		current_text = te.text

	# 1. Native Mobile (Android / iOS native app)
	if not OS.has_feature("web") and DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		var keyboard_type := DisplayServer.KEYBOARD_TYPE_DEFAULT
		if input_ctrl is LineEdit:
			keyboard_type = input_ctrl.virtual_keyboard_type
		DisplayServer.virtual_keyboard_show(current_text, input_ctrl.get_global_rect(), keyboard_type, max_len)
		return

	# 2. Web Mobile Browser Support (iOS Safari, Android Chrome, Samsung Internet)
	if force_prompt or is_mobile_web() or (OS.has_feature("web") and is_mobile()):
		_prompt_mobile_web(input_ctrl, prompt_override, current_text, max_len)


## Uses a real browser field so mobile browsers can display their OS keyboard.
static func _prompt_mobile_web(input_ctrl: Control, prompt_override: String, current_val: String, max_len: int = -1) -> void:
	if not OS.has_feature("web"):
		return

	var prompt_title := prompt_override
	if prompt_title.is_empty():
		prompt_title = str(input_ctrl.get_meta("mobile_kb_prompt_title", ""))

	if prompt_title.is_empty():
		if input_ctrl is LineEdit:
			var le := input_ctrl as LineEdit
			if not le.placeholder_text.is_empty():
				prompt_title = le.placeholder_text
			elif le.name == "NameInput":
				prompt_title = "What is your name?"
			elif le.name == "ShareQuantityInput":
				prompt_title = "Enter share quantity:"
			else:
				prompt_title = "Enter " + le.name.capitalize()
		elif input_ctrl is TextEdit:
			prompt_title = "Enter text:"

	if prompt_title.is_empty():
		prompt_title = "Enter text:"

	var input_type := "textarea" if input_ctrl is TextEdit else "text"
	if input_ctrl is LineEdit:
		var le_typed := input_ctrl as LineEdit
		if le_typed.secret:
			input_type = "password"
		elif le_typed.virtual_keyboard_type == LineEdit.KEYBOARD_TYPE_NUMBER:
			input_type = "number"
		elif le_typed.virtual_keyboard_type == LineEdit.KEYBOARD_TYPE_NUMBER_DECIMAL:
			input_type = "decimal"
		elif le_typed.virtual_keyboard_type == LineEdit.KEYBOARD_TYPE_EMAIL_ADDRESS:
			input_type = "email"

	var input_id := input_ctrl.get_instance_id()
	var input_ref: WeakRef = weakref(input_ctrl)
	var on_submit = func(args):
		_active_callbacks.erase(input_id)
		var target = input_ref.get_ref()
		if not is_instance_valid(target) or not target.is_visible_in_tree():
			return
		if args.size() > 0 and args[0] != null:
			var res_str := str(args[0])
			if res_str != "__CANCELLED__" and res_str != "null":
				_apply_input_text(target, res_str)

	var cb = JavaScriptBridge.create_callback(on_submit)
	_active_callbacks[input_id] = cb
	var win = JavaScriptBridge.get_interface("window")
	if win == null:
		_active_callbacks.erase(input_id)
		return

	if bool(JavaScriptBridge.eval("typeof window.showCyberInputOverlay === 'function'")):
		win.showCyberInputOverlay(prompt_title, current_val, max_len, input_type, cb)
	else:
		var result = win.prompt(prompt_title, current_val)
		_active_callbacks.erase(input_id)
		if result != null:
			_apply_input_text(input_ctrl, str(result))


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
