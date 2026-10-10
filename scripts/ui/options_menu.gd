extends Node

const Creation = preload("res://scripts/core/creation_options.gd")
const Portraits = preload("res://scripts/core/portrait_catalog.gd")
var main: Control
var pages: Node
var notifications: Array = []
var showing_notice := false


func install(screen: Control, settings_pages: Node) -> void:
	main = screen
	pages = settings_pages
	var menu_card: PanelContainer = main.settings_overlay.get_node("SettingsCard")
	var menu_style: StyleBoxFlat = menu_card.get_theme_stylebox("panel").duplicate()
	menu_style.bg_color.a = 1.0
	menu_card.add_theme_stylebox_override("panel", menu_style)
	var content: VBoxContainer = main.settings_overlay.get_node("SettingsCard/SettingsMargin").find_child("SettingsContent", true, false)
	for child in content.get_children():
		if child is Control:
			child.hide()
	var menu := VBoxContainer.new()
	menu.set_meta("reference_menu", true)
	menu.add_theme_constant_override("separation", 16)
	content.add_child(menu)
	var title: Label = main.settings_overlay.find_child("SettingsTitle", true, false)
	title.text = "OPTIONS"
	section(menu, "STORE")
	button(menu, "Life.exe Shop", func(): main.settings_overlay.hide(); main.get_node("ShopPanel").open_shop())
	section(menu, "GAMEPLAY")
	button(menu, "Create A New Life", _new_life)
	button(menu, "Save Life", _save_life)
	button(menu, "Load Life", _load_life)
	section(menu, "ACCOUNT")
	button(menu, "Account Login", pages._open_account)
	button(menu, "T&C", func(): pages._open_document("Terms & Conditions", pages.TERMS))
	button(menu, "Privacy Protection", func(): pages._open_document("Privacy Policy", pages.PRIVACY))
	section(menu, "COLLECTIBLES")
	button(menu, "Achievements", _achievements)
	section(menu, "CONFIGURE")
	button(menu, "Custom Cities", _cities)
	button(menu, "Custom People", _people)
	button(menu, "Settings", _settings)
	button(menu, "Themes", _themes)
	LifeLibrary.achievement_unlocked.connect(_queue_notice)
	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(func():
		if not main.new_game_panel.visible and (main.loading_screen == null or not main.loading_screen.visible) and (main.disclaimer_screen == null or not main.disclaimer_screen.visible):
			LifeLibrary.check_achievements()
	)
	add_child(timer)
	timer.start()
	AudioServer.set_bus_mute(0, bool(LifeLibrary.data.get("muted", false)))


func section(parent: Node, text: String) -> Label:
	var label: Label = pages._label(text, 26)
	if parent.has_meta("reference_menu"):
		label.set_meta("reference_section", true)
	var is_light: bool = LifeLibrary.data.theme == "light"
	label.add_theme_color_override("font_color", Color("#b45309") if is_light else Color("#ffd481"))
	parent.add_child(label)
	return label


func button(parent: Node, text: String, action: Callable) -> Button:
	var result: Button = pages._button(text, parent, action)
	result.set_meta("options_button", true)
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return result


func modal(title: String, description: String) -> Dictionary:
	return main._create_cyber_modal(title, description, Color("#64e6ff"))


func confirm(title: String, description: String, action: Callable) -> void:
	var view := modal(title, description)
	button(view.list, "Continue", func(): view.overlay.queue_free(); action.call())
	button(view.list, "Cancel", func(): view.overlay.queue_free())


func _new_life() -> void:
	confirm("CREATE A NEW LIFE", "Progress since your last named save will be lost. Save Life first if you want to keep this character. Your saved lives and collectibles will remain.", func():
		var previous := SaveManager.capture_data().duplicate(true)
		PlayerData.reset_player()
		if not SaveManager.save_game():
			SaveManager.apply_data(previous)
			modal("STORAGE ERROR", "Could not prepare a new life. Please check available storage.")
			return
		LifeLibrary.data.active_slot = ""
		LifeLibrary.persist()
		get_tree().reload_current_scene()
	)


func _save_life() -> void:
	if not PlayerData.has_started_game:
		modal("SAVE LIFE", "Start a life before creating a save.")
		return
	var view := modal("SAVE LIFE", "%s • Age %d\nNamed saves are stored locally on this device, separately from automatic resume progress." % [PlayerData.first_name, PlayerData.age])
	var active_path := LifeLibrary.slot_path(LifeLibrary.current_slot())
	if not active_path.is_empty() and FileAccess.file_exists(active_path):
		section(view.list, "This life already has a save. Choose how to save:")
		button(view.list, "Overwrite Existing Save File", func(): _write_slot(view, true))
	button(view.list, "Create A New Save File", func(): _write_slot(view, false))
	button(view.list, "Cancel", func(): view.overlay.queue_free())


func _write_slot(view: Dictionary, overwrite: bool) -> void:
	if LifeLibrary.save_slot(overwrite):
		view.overlay.queue_free()
		modal("LIFE SAVED", "Your life was saved locally. Find it under Options → Load Life.")
	else:
		section(view.list, "Save failed. Check available storage; your existing save was kept.")


func _load_life() -> void:
	var view := modal("LOAD LIFE", "Choose a local save. You will be asked before replacing the current life.")
	var saved_lives := LifeLibrary.slots()
	if saved_lives.is_empty():
		section(view.list, "No named saves yet. Use Save Life to create one.")
	for entry in saved_lives:
		button(view.list, "%s • Age %d\n%s • %s" % [entry.name, entry.age, entry.date, str(entry.id).left(6)], func():
			confirm("LOAD %s?" % str(entry.name).to_upper(), "Current progress that has not been saved to a named slot will be replaced. Other saved lives will remain.", func():
				if LifeLibrary.load_slot(entry.id):
					get_tree().reload_current_scene()
				else:
					modal("LOAD FAILED", "The save could not be read. The current life has not been replaced.")
			)
		)


func _achievements() -> void:
	var view := modal("ACHIEVEMENTS", "%d / %d unlocked • Shared across your local lives" % [LifeLibrary.data.achievements.size(), LifeLibrary.ACHIEVEMENTS.size()])
	for entry in LifeLibrary.ACHIEVEMENTS:
		var unlocked: bool = LifeLibrary.data.achievements.has(entry[0])
		section(view.list, ("🏆 " if unlocked else "🔒 ") + entry[1])
		var label: Label = pages._label(entry[2] + ("\nUnlocked " + str(LifeLibrary.data.achievements[entry[0]]) if unlocked else "\nLocked"), 24)
		view.list.add_child(label)


func country_picker(parent: Node) -> OptionButton:
	var picker := OptionButton.new()
	picker.custom_minimum_size.y = 76
	picker.add_theme_font_size_override("font_size", 26)
	for country in Creation.COUNTRIES:
		picker.add_icon_item(Creation.get_flag_for_country(country[0]), country[0])
	picker.get_popup().add_theme_constant_override("icon_max_width", 48)
	picker.add_theme_constant_override("icon_max_width", 48)
	parent.add_child(picker)
	_style_input(picker)
	picker.get_popup().about_to_popup.connect(func():
		var light: bool = LifeLibrary.data.theme == "light"
		picker.get_popup().add_theme_stylebox_override("panel", pages._style(Color("#edf3fa") if light else Color("#12213b"), Color("#40647e"), 16))
		picker.get_popup().add_theme_color_override("font_color", Color("#17394a") if light else Color("#aee4f5"))
	)
	return picker


func _style_input(control: Control) -> void:
	var is_light: bool = LifeLibrary.data.theme == "light"
	control.add_theme_stylebox_override("normal", pages._style(Color("#edf3fa") if is_light else Color("#12213b"), Color("#0284c7") if is_light else Color("#40647e"), 16))
	control.add_theme_stylebox_override("pressed", pages._style(Color("#93c5fd") if is_light else Color("#244767"), Color("#0369a1") if is_light else Color("#64e6ff"), 16))
	control.add_theme_stylebox_override("hover", pages._style(Color("#bfdbfe") if is_light else Color("#1d3353"), Color("#0284c7") if is_light else Color("#64e6ff"), 16))
	control.add_theme_stylebox_override("focus", pages._style(Color(0, 0, 0, 0), Color("#b45309") if is_light else Color("#ffd481"), 0))
	control.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#aee4f5"))
	control.add_theme_font_size_override("font_size", 26)


func field(parent: Node, placeholder: String) -> LineEdit:
	var edit := LineEdit.new()
	edit.placeholder_text = placeholder
	edit.max_length = 48
	edit.custom_minimum_size.y = 76
	edit.add_theme_font_size_override("font_size", 26)
	parent.add_child(edit)
	_style_input(edit)
	MobileKeyboardManager.attach_to_input(edit, placeholder)
	return edit


var cities_overlay: Control
var people_overlay: Control
var themes_overlay: Control


func _cities() -> void:
	var view: Dictionary = main._refresh_cyber_modal(cities_overlay, "CUSTOM CITIES", "Cities are stored on this device and used in new birth stories for their matching country.", Color("#64e6ff"))
	cities_overlay = view.overlay
	var city := field(view.list, "City name")
	city.set_meta("mobile_kb_prompt_title", "Enter city name:")
	MobileKeyboardManager.attach_to_input(city, "Enter city name:")
	var country := country_picker(view.list)
	var status := section(view.list, "")
	button(view.list, "Add City", func():
		var error := LifeLibrary.add_city(city.text, country.get_item_text(country.selected))
		if error.is_empty():
			_cities()
		else:
			status.text = error
	)
	section(view.list, "YOUR CITIES")
	for entry in LifeLibrary.data.cities:
		section(view.list, "%s, %s" % [entry.name, entry.country])



func _people() -> void:
	var view: Dictionary = main._refresh_cyber_modal(people_overlay, "CUSTOM PEOPLE", "Create adult NPCs using the game's portraits. They can appear in dating encounters; all custom people may also appear in annual social encounters.", Color("#64e6ff"))
	people_overlay = view.overlay
	var name_field := field(view.list, "Full name")
	name_field.max_length = 40
	name_field.set_meta("is_name_input", true)
	name_field.set_meta("mobile_kb_prompt_title", "Enter full name for custom person:")
	MobileKeyboardManager.attach_to_input(name_field, "Enter full name for custom person:")
	var country := country_picker(view.list)
	var gender := OptionButton.new()
	gender.add_item("MALE")
	gender.add_item("FEMALE")
	gender.custom_minimum_size.y = 70
	view.list.add_child(gender)
	_style_input(gender)
	gender.get_popup().add_theme_stylebox_override("panel", pages._style(Color("#12213b"), Color("#40647e"), 16))
	section(view.list, "CHOOSE AVATAR")
	var selected := {"ethnicity": "white", "track": 0}
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	view.list.add_child(grid)
	var group := ButtonGroup.new()
	for ethnicity in Portraits.ETHNICITIES:
		for track in range(4):
			var avatar := Button.new()
			avatar.custom_minimum_size = Vector2(100, 100)
			avatar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			avatar.toggle_mode = true
			avatar.button_group = group
			avatar.button_pressed = ethnicity == "white" and track == 0
			avatar.icon = Portraits.get_portrait(25, "MALE", track, ethnicity)
			avatar.expand_icon = true
			avatar.add_theme_constant_override("icon_max_width", 90)
			avatar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			grid.add_child(avatar)
			_style_input(avatar)
			avatar.pressed.connect(func(): selected.ethnicity = ethnicity; selected.track = track)
			gender.item_selected.connect(func(index): avatar.icon = Portraits.get_portrait(25, gender.get_item_text(index), track, ethnicity))
	var status := section(view.list, "")
	button(view.list, "Add Person", func():
		var error := LifeLibrary.add_person({"name": name_field.text, "country": country.get_item_text(country.selected), "gender": gender.get_item_text(gender.selected), "ethnicity": selected.ethnicity, "portrait_track": selected.track})
		if error.is_empty():
			_people()
		else:
			status.text = error
	)
	section(view.list, "YOUR PEOPLE")
	for person in LifeLibrary.data.people:
		var row := button(view.list, "%s • %s" % [person.name, person.country], func(): pass)
		row.icon = Portraits.get_portrait(25, person.gender, person.portrait_track, person.ethnicity)
		row.expand_icon = true
		row.add_theme_constant_override("icon_max_width", 68)



func _settings() -> void:
	var view := modal("SETTINGS", "Audio, language and haptic preferences are saved on this device.")
	var audio := CheckButton.new()
	audio.text = "Mute sound"
	audio.button_pressed = AudioServer.is_bus_mute(0)
	audio.custom_minimum_size.y = 80
	audio.add_theme_font_size_override("font_size", 28)
	view.list.add_child(audio)
	audio.toggled.connect(func(value):
		AudioServer.set_bus_mute(0, value)
		LifeLibrary.data.muted = value
		LifeLibrary.persist()
	)
	var haptics := CheckButton.new()
	haptics.text = "Haptic feedback (Vibration)"
	haptics.button_pressed = bool(LifeLibrary.data.get("haptics_enabled", true))
	haptics.custom_minimum_size.y = 80
	haptics.add_theme_font_size_override("font_size", 28)
	view.list.add_child(haptics)
	haptics.toggled.connect(func(value):
		LifeLibrary.data.haptics_enabled = value
		LifeLibrary.persist()
	)
	section(view.list, "Language")
	var language := OptionButton.new()
	for title in ["English", "Bahasa Indonesia", "Русский"]:
		language.add_item(title)
	language.select(maxi(0, ["en", "id", "ru"].find(GameLocale.language())))
	_style_input(language)
	language.custom_minimum_size.y = 76
	view.list.add_child(language)
	section(view.list, "Interface localization: English, Indonesian and Russian. Legacy story text may remain in English.")
	var status := section(view.list, "")
	button(view.list, "Apply Preferences", func():
		var success := GameLocale.set_preferences(["en", "id", "ru"][language.selected], "USD")
		status.text = "Preferences saved." if success else "Could not save preferences."
		main.update_ui()
	)


func _themes() -> void:
	var view: Dictionary = main._refresh_cyber_modal(themes_overlay, "THEMES", "Choose a look for the whole game. Your selection is saved locally.", Color("#64e6ff"))
	themes_overlay = view.overlay
	for mode in ["dark", "light"]:
		button(view.list, mode.capitalize() + (" • Selected" if LifeLibrary.data.theme == mode else ""), func():
			LifeLibrary.data.theme = mode
			LifeLibrary.persist()
			if main.has_method("on_theme_changed"):
				main.on_theme_changed()
			else:
				if main.has_node("ThemeController"):
					main.get_node("ThemeController").apply_theme()
				main.rebuild_life_feed()
				main.update_ui()
			_themes()
		)



func _queue_notice(title: String, description: String) -> void:
	notifications.append([title, description])
	if not showing_notice:
		_show_notice()


func _show_notice() -> void:
	if notifications.is_empty():
		showing_notice = false
		return
	showing_notice = true
	var entry: Array = notifications.pop_front()
	var toast := PanelContainer.new()
	toast.name = "AchievementToast"
	toast.z_index = 200
	toast.mouse_filter = Control.MOUSE_FILTER_PASS
	var is_light: bool = LifeLibrary.data.theme == "light"
	toast.add_theme_stylebox_override("panel", pages._style(Color("#edf3fa") if is_light else Color("#13243a"), Color("#b45309") if is_light else Color("#ffd481"), 24))
	main.add_child(toast)
	toast.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	toast.offset_left = 30
	toast.offset_right = -30
	toast.offset_top = -180
	toast.offset_bottom = -20

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	toast.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	hbox.add_theme_constant_override("separation", 16)
	margin.add_child(hbox)

	var label: Label = pages._label("★ ACHIEVEMENT UNLOCKED\n%s — %s" % entry, 26)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(label)

	var close_btn := Button.new()
	close_btn.name = "CloseAchievementButton"
	close_btn.text = "✕"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	close_btn.custom_minimum_size = Vector2(64, 64)
	close_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	close_btn.add_theme_font_size_override("font_size", 28)

	var x_color: Color = Color("#b45309") if is_light else Color("#ffd481")
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color("#000000", 0.08) if is_light else Color("#ffffff", 0.10)
	btn_style.border_color = x_color
	btn_style.set_border_width_all(2)
	btn_style.set_corner_radius_all(32)
	btn_style.content_margin_left = 12
	btn_style.content_margin_right = 12
	btn_style.content_margin_top = 8
	btn_style.content_margin_bottom = 8

	var btn_pressed := btn_style.duplicate() as StyleBoxFlat
	btn_pressed.bg_color = Color("#b45309", 0.25) if is_light else Color("#ffd481", 0.25)

	for state in ["normal", "hover", "focus"]:
		close_btn.add_theme_stylebox_override(state, btn_style)
	close_btn.add_theme_stylebox_override("pressed", btn_pressed)

	close_btn.add_theme_color_override("font_color", x_color)
	close_btn.add_theme_color_override("font_hover_color", x_color)
	close_btn.add_theme_color_override("font_focus_color", x_color)
	close_btn.add_theme_color_override("font_pressed_color", Color.WHITE if is_light else Color.BLACK)
	hbox.add_child(close_btn)

	var tween := toast.create_tween()
	tween.tween_property(toast, "position:y", 24.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_interval(3.5)
	tween.tween_property(toast, "modulate:a", 0.0, 0.25)
	tween.tween_callback(func():
		if is_instance_valid(toast):
			toast.queue_free()
		_show_notice()
	)

	var dismiss_toast := func():
		if not is_instance_valid(toast):
			return
		close_btn.disabled = true
		if tween != null and tween.is_valid():
			tween.kill()
		var exit_tween := toast.create_tween()
		exit_tween.set_parallel(true)
		exit_tween.tween_property(toast, "modulate:a", 0.0, 0.15)
		exit_tween.tween_property(toast, "position:y", -180.0, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		exit_tween.chain().tween_callback(func():
			if is_instance_valid(toast):
				toast.queue_free()
			_show_notice()
		)

	close_btn.pressed.connect(dismiss_toast)
