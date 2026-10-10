class_name MobileKeyboardManager
extends Node

## MobileKeyboardManager
## Automatically detects mobile devices (Android, iOS) and mobile web browsers (Chrome, Safari, etc.)
## ensuring that tapping on ANY LineEdit or TextEdit reliably triggers virtual keyboard input.

static var _instance: MobileKeyboardManager = null
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


## Creates a dummy keyboard trigger button (kept for backwards-compatibility; hidden by default so it does not clutter UI)
static func create_keyboard_trigger_button(input_ctrl: Control, button_title: String = "⌨️ Type Custom Value", prompt_title: String = "", btn_color: Color = Color("#00f0ff")) -> Button:
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


## Opens the virtual keyboard for the target input control
static func open_keyboard(input_ctrl: Control, prompt_override: String = "", force_prompt: bool = false) -> void:
	if input_ctrl == null or not is_instance_valid(input_ctrl):
		return

	if not input_ctrl.is_visible_in_tree():
		return
	if input_ctrl is LineEdit and not (input_ctrl as LineEdit).editable:
		return
	if input_ctrl is TextEdit and not (input_ctrl as TextEdit).editable:
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
	var keyboard_type := DisplayServer.KEYBOARD_TYPE_DEFAULT

	if input_ctrl is LineEdit:
		var le := input_ctrl as LineEdit
		current_text = le.text
		max_len = le.max_length
		keyboard_type = int(le.virtual_keyboard_type) as DisplayServer.VirtualKeyboardType
	elif input_ctrl is TextEdit:
		var te := input_ctrl as TextEdit
		current_text = te.text
		keyboard_type = DisplayServer.KEYBOARD_TYPE_MULTILINE

	# Directly invoke DisplayServer.virtual_keyboard_show
	# On mobile native (Android/iOS) and Web Mobile (GodotDisplayVK with experimentalVK),
	# this directly opens the device's native virtual keyboard without opening any secondary panels.
	DisplayServer.virtual_keyboard_show(current_text, input_ctrl.get_global_rect(), keyboard_type, max_len)


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
