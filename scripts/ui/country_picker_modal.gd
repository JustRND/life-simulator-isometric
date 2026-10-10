class_name CountryPickerModal
extends RefCounted

## CountryPickerModal
## Provides a mobile-optimized, touch-scrollable modal dialog for selecting countries and flags.
## Replaces Godot's desktop-only PopupMenu with full kinetic touch scrolling and gesture-slop detection.

static var _active_overlay: Control = null

static func is_open() -> bool:
	return _active_overlay != null and is_instance_valid(_active_overlay) and _active_overlay.visible

static func open(parent: Node, target_option_button: OptionButton = null, on_selected: Callable = Callable(), custom_title: String = "WHERE WERE YOU BORN?") -> Control:
	if is_open():
		return _active_overlay

	if parent == null or not is_instance_valid(parent):
		return null

	var tree: SceneTree = null
	if parent.is_inside_tree():
		tree = parent.get_tree()
	elif Engine.get_main_loop() is SceneTree:
		tree = Engine.get_main_loop() as SceneTree

	var current_country := ""
	if target_option_button != null and is_instance_valid(target_option_button):
		if target_option_button.selected >= 0 and target_option_button.selected < target_option_button.item_count:
			current_country = target_option_button.get_item_text(target_option_button.selected)
	if current_country.is_empty():
		current_country = "Indonesia"

	# Full-screen dimmed overlay
	var overlay := ColorRect.new()
	overlay.name = "CountryPickerOverlay"
	overlay.set_meta("theme_exempt", true)
	overlay.color = Color(0.012, 0.035, 0.07, 0.90)
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.grow_horizontal = Control.GROW_DIRECTION_BOTH
	overlay.grow_vertical = Control.GROW_DIRECTION_BOTH
	overlay.z_index = 120
	overlay.visible = true
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_active_overlay = overlay

	# Add to root/parent
	parent.add_child(overlay)

	# Responsive outer margin
	var outer_margin := MarginContainer.new()
	outer_margin.anchors_preset = Control.PRESET_FULL_RECT
	outer_margin.anchor_right = 1.0
	outer_margin.anchor_bottom = 1.0
	outer_margin.grow_horizontal = Control.GROW_DIRECTION_BOTH
	outer_margin.grow_vertical = Control.GROW_DIRECTION_BOTH
	outer_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer_margin.add_theme_constant_override("margin_left", 20)
	outer_margin.add_theme_constant_override("margin_right", 20)
	outer_margin.add_theme_constant_override("margin_top", 44)
	outer_margin.add_theme_constant_override("margin_bottom", 36)
	overlay.add_child(outer_margin)

	var PanelPullUpRef = load("res://scripts/ui/panel_pull_up.gd")
	if PanelPullUpRef != null:
		PanelPullUpRef.watch(outer_margin, overlay)

	var is_light: bool = false
	if tree != null:
		var lib = tree.root.get_node_or_null("LifeLibrary")
		if lib != null and "data" in lib and lib.data != null:
			is_light = str(lib.data.get("theme", "")) == "light"

	# Card container
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.clip_contents = true

	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color("#edf3fa") if is_light else Color("#090f1d")
	card_style.border_color = Color("#00f0ff")
	card_style.set_border_width_all(3)
	card_style.set_corner_radius_all(16)
	card_style.shadow_color = Color(0, 0, 0, 0.85)
	card_style.shadow_size = 28
	card.add_theme_stylebox_override("panel", card_style)
	outer_margin.add_child(card)

	var close_picker = func():
		if is_instance_valid(overlay):
			var PanelCloseRef = load("res://scripts/ui/panel_close.gd")
			if PanelCloseRef != null:
				PanelCloseRef.dismiss(overlay, true, Callable(), card)
			else:
				overlay.queue_free()
		_active_overlay = null

	# Dismiss if tapping backdrop outside card
	overlay.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			close_picker.call()
		elif event is InputEventScreenTouch and event.pressed:
			close_picker.call()
	)

	var card_margin := MarginContainer.new()
	card_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_margin.add_theme_constant_override("margin_left", 20)
	card_margin.add_theme_constant_override("margin_right", 20)
	card_margin.add_theme_constant_override("margin_top", 18)
	card_margin.add_theme_constant_override("margin_bottom", 18)
	card.add_child(card_margin)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 14)
	card_margin.add_child(vbox)

	# 1. Header row
	var header := HBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_theme_constant_override("separation", 10)
	vbox.add_child(header)

	var title_lbl := Label.new()
	title_lbl.text = custom_title
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color("#00f0ff"))
	title_lbl.add_theme_font_size_override("font_size", 24)
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(title_lbl)

	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(56, 48)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	close_btn.add_theme_font_size_override("font_size", 22)
	close_btn.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#ffffff"))
	var close_sb := StyleBoxFlat.new()
	close_sb.bg_color = Color("#e2e8f0") if is_light else Color("#1e293b")
	close_sb.border_color = Color("#0284c7") if is_light else Color("#38bdf8")
	close_sb.set_border_width_all(2)
	close_sb.set_corner_radius_all(10)
	close_btn.add_theme_stylebox_override("normal", close_sb)
	close_btn.pressed.connect(close_picker)
	header.add_child(close_btn)

	# 2. Subtitle info
	var sub_lbl := Label.new()
	sub_lbl.text = "Select your country of origin from the global sovereign registry."
	sub_lbl.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
	sub_lbl.add_theme_font_size_override("font_size", 18)
	sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(sub_lbl)

	# 3. Search Box for instant filtering
	var search_input := LineEdit.new()
	search_input.name = "CountrySearchInput"
	search_input.placeholder_text = "🔍 Search country..."
	search_input.custom_minimum_size.y = 54
	search_input.add_theme_font_size_override("font_size", 20)
	search_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_DEFAULT
	search_input.virtual_keyboard_enabled = true

	var sb_input := StyleBoxFlat.new()
	sb_input.bg_color = Color("#ffffff") if is_light else Color("#0f172a")
	sb_input.border_color = Color("#0284c7")
	sb_input.set_border_width_all(2)
	sb_input.set_corner_radius_all(10)
	sb_input.content_margin_left = 14
	sb_input.content_margin_right = 14
	search_input.add_theme_stylebox_override("normal", sb_input)
	search_input.add_theme_stylebox_override("focus", sb_input)
	search_input.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#ffffff"))
	search_input.add_theme_color_override("placeholder_color", Color("#94a3b8") if is_light else Color("#64748b"))
	vbox.add_child(search_input)

	var MobileKeyboardRef = load("res://scripts/ui/mobile_keyboard_manager.gd")
	if MobileKeyboardRef != null:
		MobileKeyboardRef.attach_to_input(search_input, "Search country...")

	# 4. Scrollable Container for all countries (Naturally handled by TouchScrollController!)
	var scroll := ScrollContainer.new()
	scroll.name = "CountryListScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.clip_contents = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	vbox.add_child(scroll)

	var list_container := VBoxContainer.new()
	list_container.name = "CountryListContainer"
	list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_container.add_theme_constant_override("separation", 8)
	scroll.add_child(list_container)

	var CreationOptionsRef = load("res://scripts/core/creation_options.gd")
	var countries_list: Array = CreationOptionsRef.COUNTRIES if CreationOptionsRef != null else []

	var selected_target_btn: Button = null

	for i in range(countries_list.size()):
		var entry: Array = countries_list[i]
		var c_name: String = str(entry[0])
		var col: int = int(entry[1])
		var row: int = int(entry[2])
		var is_selected := c_name.to_lower() == current_country.to_lower()

		var btn := Button.new()
		btn.name = "Country_" + c_name.replace(" ", "_")
		btn.text = "   " + c_name + ("  ✓" if is_selected else "")
		btn.custom_minimum_size.y = 64
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 22)
		btn.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

		var flag_icon: Texture2D = CreationOptionsRef.flag_texture(col, row) if CreationOptionsRef != null else null
		if flag_icon != null:
			btn.icon = flag_icon
			btn.expand_icon = true
			btn.add_theme_constant_override("icon_max_width", 54)

		# Styling
		var sb_btn_normal := StyleBoxFlat.new()
		if is_light:
			sb_btn_normal.bg_color = Color("#bae6fd") if is_selected else Color("#e2e8f0")
			sb_btn_normal.border_color = Color("#0284c7") if is_selected else Color("#94a3b8")
		else:
			sb_btn_normal.bg_color = Color("#0f314d") if is_selected else Color("#0d1b33")
			sb_btn_normal.border_color = Color("#00f0ff") if is_selected else Color("#1e3a5f")
		sb_btn_normal.set_border_width_all(2 if is_selected else 1)
		sb_btn_normal.set_corner_radius_all(10)
		sb_btn_normal.content_margin_left = 16
		sb_btn_normal.content_margin_right = 16

		var sb_btn_hover := sb_btn_normal.duplicate() as StyleBoxFlat
		sb_btn_hover.bg_color = Color("#bae6fd") if is_light else Color("#162c54")
		sb_btn_hover.border_color = Color("#0284c7") if is_light else Color("#38bdf8")

		var sb_btn_pressed := sb_btn_normal.duplicate() as StyleBoxFlat
		sb_btn_pressed.bg_color = Color("#7dd3fc") if is_light else Color("#0284c7")
		sb_btn_pressed.border_color = Color("#0284c7") if is_light else Color("#00f0ff")

		btn.add_theme_stylebox_override("normal", sb_btn_normal)
		btn.add_theme_stylebox_override("hover", sb_btn_hover)
		btn.add_theme_stylebox_override("pressed", sb_btn_pressed)
		if is_light:
			btn.add_theme_color_override("font_color", Color("#0284c7") if is_selected else Color("#0f172a"))
			btn.add_theme_color_override("font_hover_color", Color("#0369a1"))
			btn.add_theme_color_override("font_pressed_color", Color("#0284c7"))
		else:
			btn.add_theme_color_override("font_color", Color("#00f0ff") if is_selected else Color("#e2e8f0"))
			btn.add_theme_color_override("font_hover_color", Color("#ffffff"))
			btn.add_theme_color_override("font_pressed_color", Color("#ffffff"))

		if is_selected:
			selected_target_btn = btn

		# Exact button press logic:
		# If a screen touch is dragged more than 16px or held for more than 650ms,
		# it is counted as a scroll gesture and MUST NOT select the button!
		var touch_state := {
			"start_pos": Vector2.ZERO,
			"start_time": 0,
			"was_dragged": false,
			"selection_handled": false
		}

		var do_select = func():
			if touch_state.selection_handled or touch_state.was_dragged:
				return
			if touch_state.start_time > 0 and (Time.get_ticks_msec() - int(touch_state.start_time)) > 650:
				return
			touch_state.selection_handled = true

			if target_option_button != null and is_instance_valid(target_option_button):
				for idx in range(target_option_button.item_count):
					if target_option_button.get_item_text(idx) == c_name:
						target_option_button.select(idx)
						target_option_button.text = c_name
						if flag_icon != null:
							target_option_button.icon = flag_icon
						target_option_button.item_selected.emit(idx)
						break
			if on_selected.is_valid():
				on_selected.call(c_name, i)
			close_picker.call()

		btn.gui_input.connect(func(event: InputEvent):
			var start_pos: Vector2 = touch_state.start_pos
			var start_time: int = int(touch_state.start_time)
			if event is InputEventScreenTouch:
				var st := event as InputEventScreenTouch
				if st.pressed:
					touch_state.start_pos = st.position
					touch_state.start_time = Time.get_ticks_msec()
					touch_state.was_dragged = false
				else:
					var dist: float = (st.position - start_pos).length()
					var duration: int = Time.get_ticks_msec() - start_time
					# If finger dragged >= 16px or held > 650ms, this was a swipe/scroll!
					if dist >= 16.0 or duration > 650 or bool(touch_state.was_dragged):
						touch_state.was_dragged = true
						return
					do_select.call()
			elif event is InputEventScreenDrag:
				var sd := event as InputEventScreenDrag
				if (sd.position - start_pos).length() >= 16.0:
					touch_state.was_dragged = true
			elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				var mb := event as InputEventMouseButton
				if mb.pressed:
					touch_state.start_pos = mb.position
					touch_state.start_time = Time.get_ticks_msec()
					touch_state.was_dragged = false
				else:
					var dist: float = (mb.position - start_pos).length()
					var duration: int = Time.get_ticks_msec() - start_time
					if dist >= 16.0 or duration > 650 or bool(touch_state.was_dragged):
						touch_state.was_dragged = true
						return
					do_select.call()
			elif event is InputEventMouseMotion:
				var mm := event as InputEventMouseMotion
				if (mm.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
					if (mm.position - start_pos).length() >= 16.0:
						touch_state.was_dragged = true
		)

		btn.pressed.connect(func():
			do_select.call()
		)

		list_container.add_child(btn)

	# Filter logic on search text change
	search_input.text_changed.connect(func(query: String):
		var q := query.strip_edges().to_lower()
		for child in list_container.get_children():
			if child is Button:
				var clean_name: String = child.text.replace("✓", "").strip_edges().to_lower()
				child.visible = q.is_empty() or clean_name.contains(q)
	)

	# Auto-scroll to selected country once rendered
	if selected_target_btn != null:
		(func():
			if is_instance_valid(selected_target_btn) and is_instance_valid(scroll):
				scroll.ensure_control_visible(selected_target_btn)
		).call_deferred()

	return overlay
