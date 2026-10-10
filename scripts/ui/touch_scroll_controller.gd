extends Node
## TouchScrollController
## Enables smooth mobile swipe/drag scrolling over buttons, prevents accidental button
## clicks during swiping/holding, and ensures buttons only activate on clean, intentional taps.

const SWIPE_THRESHOLD := 16.0 # Natural touch slop threshold (prevents micro-shifts from cancelling taps)
const MAX_TAP_DURATION_MS := 650 # Intentional long-press threshold for gestures
const GHOST_CLICK_BLOCK_WINDOW_MS := 400 # Blocks synthetic browser mouse events after swiping
const FRICTION := 8.5 # Kinetic scrolling friction decay

var _active_scroll: ScrollContainer = null
var _captured_button: BaseButton = null
var _captured_text_input: Control = null
var _touch_start_pos := Vector2.ZERO
var _last_touch_pos := Vector2.ZERO
var _touch_start_time := 0
var _is_swiping := false
var _has_scrolled := false
var _touch_active := false
var _last_scroll_end_time := 0
var _touch_id := -1
var _last_touch_event_time := 0
var _recent_moves: Array[Dictionary] = [] # Array of {"pos": Vector2, "time": int}

var _kinetic_scroll: ScrollContainer = null
var _kinetic_velocity := 0.0


func _ready() -> void:
	process_priority = -100 # Process before UI updates
	set_process(false)


func reset_state() -> void:
	_touch_active = false
	_is_swiping = false
	_has_scrolled = false
	_captured_button = null
	_captured_text_input = null
	_active_scroll = null
	_kinetic_scroll = null
	_kinetic_velocity = 0.0
	_last_scroll_end_time = 0
	_touch_id = -1
	_recent_moves.clear()
	set_process(false)


func _input(event: InputEvent) -> void:
	var now := Time.get_ticks_msec()
	
	# Block browser ghost/synthetic mouse events that fire immediately following a scroll.
	# Note: Real screen touches (InputEventScreenTouch) are NEVER synthetic and must never be swallowed here.
	if _last_scroll_end_time > 0 and (now - _last_scroll_end_time) < GHOST_CLICK_BLOCK_WINDOW_MS:
		if event is InputEventMouseButton or event is InputEventMouseMotion:
			get_viewport().set_input_as_handled()
			return

	# 1. Screen Touch (Mobile/Tablet touch events)
	if event is InputEventScreenTouch:
		_last_touch_event_time = now
		var st := event as InputEventScreenTouch
		if st.pressed:
			_handle_touch_down(st.position, st.index)
		elif st.index == _touch_id or _touch_id == -1:
			_handle_touch_up(st.position)

	# 2. Screen Drag (Mobile touch drag)
	elif event is InputEventScreenDrag:
		_last_touch_event_time = now
		var sd := event as InputEventScreenDrag
		if sd.index == _touch_id or _touch_id == -1:
			_handle_touch_move(sd.position)

	# 3. Mouse Button (Web / Desktop touch emulation)
	elif event is InputEventMouseButton:
		# If a screen touch is active or recently occurred (< 500ms), ignore synthetic mouse clicks
		if (_touch_active and _touch_id >= 0) or (_last_touch_event_time > 0 and (now - _last_touch_event_time) < 500):
			return
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_handle_touch_down(mb.position, -1)
			else:
				_handle_touch_up(mb.position)

	# 4. Mouse Motion (Web / Desktop drag emulation)
	elif event is InputEventMouseMotion:
		# If a screen touch is active or recently occurred (< 500ms), ignore synthetic mouse motion
		if (_touch_active and _touch_id >= 0) or (_last_touch_event_time > 0 and (now - _last_touch_event_time) < 500):
			return
		var mm := event as InputEventMouseMotion
		if (mm.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			_handle_touch_move(mm.position)
		else:
			# If mouse moves without any button pressed, reset swipe if touch is not active
			if not _touch_active:
				_is_swiping = false


func _handle_touch_down(pos: Vector2, id: int) -> void:
	preload("res://scripts/ui/panel_pull_up.gd").finish_all_active()
	set_process(true)
	_kinetic_velocity = 0.0
	_kinetic_scroll = null
	_touch_id = id
	_touch_start_pos = pos
	_last_touch_pos = pos
	_touch_start_time = Time.get_ticks_msec()
	_is_swiping = false
	_has_scrolled = false
	_touch_active = true
	_recent_moves.clear()
	_recent_moves.append({"pos": pos, "time": _touch_start_time})
	
	_active_scroll = _find_scroll_at(get_tree().root, pos)
	_captured_button = _find_button_at(get_tree().root, pos)
	_captured_text_input = _find_text_input_at(get_tree().root, pos)


func _handle_touch_move(pos: Vector2) -> void:
	if not _touch_active:
		return

	var now := Time.get_ticks_msec()
	_recent_moves.append({"pos": pos, "time": now})
	while _recent_moves.size() > 6:
		_recent_moves.remove_at(0)

	var total_delta := pos - _touch_start_pos
	if not _is_swiping:
		if abs(total_delta.y) >= SWIPE_THRESHOLD or total_delta.length() >= SWIPE_THRESHOLD:
			_is_swiping = true
			_has_scrolled = true
			_cancel_captured_button()
			_captured_text_input = null
			_last_touch_pos = pos

	if _is_swiping:
		if _active_scroll != null and is_instance_valid(_active_scroll) and _active_scroll.is_visible_in_tree():
			var delta_y := pos.y - _last_touch_pos.y
			var vsb = _active_scroll.get_v_scroll_bar()
			if vsb != null:
				_active_scroll.scroll_vertical -= int(delta_y)
		_last_touch_pos = pos
		# Consume the drag event so child buttons do not handle it
		get_viewport().set_input_as_handled()


func _handle_touch_up(pos: Vector2) -> void:
	if not _touch_active:
		return

	var now := Time.get_ticks_msec()
	var held_duration := now - _touch_start_time
	var moved_dist := (pos - _touch_start_pos).length()

	# If the user tapped on a text input without swiping, preserve the tap and summon the virtual keyboard
	if _captured_text_input != null and is_instance_valid(_captured_text_input) and not _is_swiping and moved_dist < SWIPE_THRESHOLD:
		var target_input := _captured_text_input
		_captured_text_input = null
		_is_swiping = false
		_has_scrolled = false
		_touch_active = false
		_active_scroll = null
		_captured_button = null
		_touch_id = -1
		_recent_moves.clear()
		target_input.grab_focus()
		var MobileKeyboardManagerRef = load("res://scripts/ui/mobile_keyboard_manager.gd")
		if MobileKeyboardManagerRef != null:
			MobileKeyboardManagerRef.open_keyboard(target_input, target_input.get_meta("mobile_kb_prompt_title", ""), true)
		return

	var was_swiping_or_scrolled := _is_swiping or _has_scrolled or moved_dist >= SWIPE_THRESHOLD or held_duration > MAX_TAP_DURATION_MS

	if was_swiping_or_scrolled:
		# Consume the release event so buttons under the finger DO NOT trigger 'pressed'
		get_viewport().set_input_as_handled()
		_cancel_captured_button()
		_last_scroll_end_time = now

		# Compute kinetic velocity from recent touch movements (within last 140ms)
		if _active_scroll != null:
			var valid_moves: Array[Dictionary] = []
			for m in _recent_moves:
				if now - int(m.time) < 140:
					valid_moves.append(m)

			if valid_moves.size() >= 2:
				var oldest: Dictionary = valid_moves[0]
				var newest: Dictionary = valid_moves[valid_moves.size() - 1]
				var dt := (float(newest.time) - float(oldest.time)) / 1000.0
				if dt > 0.01:
					var dy := float(newest.pos.y) - float(oldest.pos.y)
					var v := dy / dt
					if abs(v) > 60.0:
						_kinetic_scroll = _active_scroll
						_kinetic_velocity = clampf(v, -3000.0, 3000.0)

	_is_swiping = false
	_has_scrolled = false
	_touch_active = false
	_active_scroll = null
	_captured_button = null
	_captured_text_input = null
	_touch_id = -1
	_recent_moves.clear()
	if _kinetic_scroll == null:
		set_process(false)


func _cancel_captured_button() -> void:
	if _captured_button != null and is_instance_valid(_captured_button):
		var prev_disabled := _captured_button.disabled
		var prev_focus := _captured_button.focus_mode
		_captured_button.disabled = true
		_captured_button.disabled = prev_disabled
		_captured_button.focus_mode = prev_focus
		_captured_button.button_pressed = false
		if _captured_button.has_method("release_focus"):
			_captured_button.release_focus()
		_captured_button = null
	var vp := get_viewport()
	if vp != null:
		vp.gui_release_focus()


func _process(delta: float) -> void:
	# 1. Long-press / Hold cancellation:
	if _touch_active and _captured_button != null:
		var held_time := Time.get_ticks_msec() - _touch_start_time
		if held_time > MAX_TAP_DURATION_MS:
			_has_scrolled = true
			_cancel_captured_button()

	# 2. Kinetic scrolling inertia:
	if _kinetic_scroll != null and is_instance_valid(_kinetic_scroll) and _kinetic_scroll.is_visible_in_tree():
		if abs(_kinetic_velocity) > 8.0:
			var dy := _kinetic_velocity * delta
			var vsb = _kinetic_scroll.get_v_scroll_bar()
			if vsb != null:
				var old_val := _kinetic_scroll.scroll_vertical
				_kinetic_scroll.scroll_vertical -= int(dy)
				if _kinetic_scroll.scroll_vertical == old_val:
					# Hit top or bottom bounds
					_kinetic_velocity = 0.0
					_kinetic_scroll = null
					if not _touch_active:
						set_process(false)
					return
			_kinetic_velocity = lerpf(_kinetic_velocity, 0.0, FRICTION * delta)
		else:
			_kinetic_velocity = 0.0
			_kinetic_scroll = null
			if not _touch_active:
				set_process(false)
	elif not _touch_active:
		set_process(false)


func _find_scroll_at(node: Node, pos: Vector2) -> ScrollContainer:
	if node == null:
		return null

	if node is CanvasItem:
		var ci := node as CanvasItem
		if not ci.is_visible_in_tree():
			return null
	elif node is Window:
		var win := node as Window
		if not win.visible:
			return null

	# Search children in reverse (topmost child renders on top and receives input first)
	for i in range(node.get_child_count() - 1, -1, -1):
		var child := node.get_child(i)
		var res := _find_scroll_at(child, pos)
		if res != null:
			return res

	if node is ScrollContainer:
		var sc := node as ScrollContainer
		var rect := sc.get_global_rect()
		if rect.has_point(pos):
			return sc

	return null


func _find_button_at(node: Node, pos: Vector2) -> BaseButton:
	if node == null:
		return null

	if node is CanvasItem:
		var ci := node as CanvasItem
		if not ci.is_visible_in_tree():
			return null
	elif node is Window:
		var win := node as Window
		if not win.visible:
			return null

	# Search children in reverse (topmost child renders on top and receives input first)
	for i in range(node.get_child_count() - 1, -1, -1):
		var child := node.get_child(i)
		var res := _find_button_at(child, pos)
		if res != null:
			return res

	if node is BaseButton:
		var btn := node as BaseButton
		if not btn.disabled and btn.is_visible_in_tree():
			var rect := btn.get_global_rect()
			if rect.has_point(pos):
				return btn

	return null


func _find_text_input_at(node: Node, pos: Vector2) -> Control:
	if node == null:
		return null

	if node is CanvasItem:
		var ci := node as CanvasItem
		if not ci.is_visible_in_tree():
			return null
	elif node is Window:
		var win := node as Window
		if not win.visible:
			return null

	# Search children in reverse (topmost child renders on top and receives input first)
	for i in range(node.get_child_count() - 1, -1, -1):
		var child := node.get_child(i)
		var res := _find_text_input_at(child, pos)
		if res != null:
			return res

	if node is LineEdit or node is TextEdit:
		var ctrl := node as Control
		if ctrl.is_visible_in_tree() and ctrl.focus_mode != Control.FOCUS_NONE:
			var rect := ctrl.get_global_rect()
			if rect.has_point(pos):
				return ctrl

	return null
