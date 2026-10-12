extends Node

var total_assertions: int = 0
var passed_assertions: int = 0


func assert_check(condition: bool, msg: String) -> void:
	total_assertions += 1
	if not condition:
		push_error("❌ ASSERTION FAILED: " + msg)
		print("  ❌ FAILED: " + msg)
		get_tree().quit(1)
		assert(false, msg)
	else:
		passed_assertions += 1
		print("  ✓ " + msg)


func _ready() -> void:
	print("=======================================================")
	print("🧪 TESTING PAUSE TIME BUTTON & TIME/CALENDAR RELOCATION")
	print("=======================================================")

	var main_scene_res = load("res://scenes/main/main_screen.tscn")
	assert_check(main_scene_res != null, "main_screen.tscn loaded successfully")

	var main_scene = main_scene_res.instantiate()
	add_child(main_scene)

	# 1. Verify container hierarchy
	var name_and_phase = main_scene.find_child("NameAndPhase", true, false) as VBoxContainer
	assert_check(name_and_phase != null, "NameAndPhase container exists")

	var name_lbl = main_scene.find_child("NameLabel", true, false) as Label
	var time_row = main_scene.find_child("TimeRow", true, false) as HBoxContainer
	var age_row = main_scene.find_child("AgeRow", true, false) as HBoxContainer
	var phase_lbl = main_scene.find_child("PhaseLabel", true, false) as Label

	assert_check(name_lbl != null, "NameLabel exists")
	assert_check(time_row != null, "TimeRow exists")
	assert_check(age_row != null, "AgeRow exists")
	assert_check(phase_lbl != null, "PhaseLabel exists")

	# Verify strict order: NameLabel -> TimeRow -> AgeRow -> PhaseLabel
	assert_check(name_lbl.get_parent() == name_and_phase, "NameLabel parent is NameAndPhase")
	assert_check(time_row.get_parent() == name_and_phase, "TimeRow parent is NameAndPhase")
	assert_check(age_row.get_parent() == name_and_phase, "AgeRow parent is NameAndPhase")
	assert_check(phase_lbl.get_parent() == name_and_phase, "PhaseLabel parent is NameAndPhase")

	var idx_name := name_lbl.get_index()
	var idx_time := time_row.get_index()
	var idx_age := age_row.get_index()
	var idx_phase := phase_lbl.get_index()

	assert_check(idx_time > idx_name, "TimeRow is positioned right under NameLabel (%d > %d)" % [idx_time, idx_name])
	assert_check(idx_time < idx_age, "TimeRow is positioned above AgeRow (%d < %d)" % [idx_time, idx_age])
	assert_check(idx_age < idx_phase, "AgeRow is positioned above PhaseLabel (%d < %d)" % [idx_age, idx_phase])

	# 2. Verify TimeRow contents and responsive house-overlay pause button
	var pause_btn = main_scene.find_child("PauseTimeButton", true, false) as Button
	var time_lbl = main_scene.find_child("TimeCounterLabel", true, false) as Label
	var house_overlay = main_scene.find_child("PauseHouseOverlay", true, false) as Control

	assert_check(pause_btn != null, "PauseTimeButton exists in house overlay")
	assert_check(house_overlay != null, "PauseHouseOverlay exists")
	assert_check(pause_btn.get_parent() == house_overlay, "PauseTimeButton parent is PauseHouseOverlay")
	var feed_panel = main_scene.find_child("LifeFeedPanel", true, false) as Control
	assert_check(feed_panel != null, "LifeFeedPanel exists")
	assert_check(house_overlay.anchor_right == 1.0 and is_equal_approx(house_overlay.offset_top, feed_panel.offset_top) and is_equal_approx(house_overlay.offset_bottom, feed_panel.offset_bottom), "PauseHouseOverlay tracks the runtime house panel bounds")
	assert_check(pause_btn.anchor_left == 1.0 and pause_btn.anchor_right == 1.0, "PauseTimeButton is anchored to overlay top-right")
	assert_check(pause_btn.get_theme_font_size("font_size") == 20, "PauseTimeButton uses the enlarged 20px label size")
	assert_check(pause_btn.custom_minimum_size.x >= 116.0 and pause_btn.custom_minimum_size.y >= 40.0, "PauseTimeButton has enough minimum space for its enlarged label")
	assert_check(house_overlay.visible, "PauseHouseOverlay is visible on the main game screen")
	main_scene.show_tab("activities")
	assert_check(not house_overlay.visible, "PauseHouseOverlay is hidden inside other panels")
	main_scene.show_tab("timeline")
	assert_check(house_overlay.visible, "PauseHouseOverlay returns on the main game screen")
	var overlay_rect := house_overlay.get_global_rect()
	var pause_rect := pause_btn.get_global_rect()
	assert_check(pause_rect.position.x >= overlay_rect.position.x and pause_rect.end.x <= overlay_rect.end.x, "PauseTimeButton stays within house overlay horizontally")
	assert_check(pause_rect.position.y >= overlay_rect.position.y and pause_rect.end.y <= overlay_rect.end.y, "PauseTimeButton stays within house overlay vertically")
	var viewport_rect: Rect2 = main_scene.get_viewport_rect()
	assert_check(pause_rect.position.x >= viewport_rect.position.x and pause_rect.end.x <= viewport_rect.end.x, "PauseTimeButton stays within the visible viewport horizontally")
	assert_check(pause_rect.position.y >= viewport_rect.position.y and pause_rect.end.y <= viewport_rect.end.y, "PauseTimeButton stays within the visible viewport vertically")
	assert_check(time_lbl != null, "TimeCounterLabel exists inside TimeRow")
	assert_check(time_lbl.get_parent() == time_row, "TimeCounterLabel parent is TimeRow")

	# Verify AgeRow no longer contains TimeCounterLabel
	assert_check(time_lbl.get_parent() != age_row, "TimeCounterLabel is no longer beside AgeLabel in AgeRow")

	# 3. Test initial state (unpaused)
	PlayerData.is_time_paused = false
	main_scene._update_time_and_age_labels()
	assert_check("Pause" in pause_btn.text or "⏸️" in pause_btn.text, "Pause button displays Pause icon/text when running: '%s'" % pause_btn.text)
	assert_check("📅" in time_lbl.text, "Time label displays calendar icon when running: '%s'" % time_lbl.text)
	var uses_short_weekday := false
	for weekday in ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]:
		if time_lbl.text.begins_with("📅 %s," % weekday):
			uses_short_weekday = true
			break
	assert_check(uses_short_weekday, "Time label uses abbreviated weekday names: '%s'" % time_lbl.text)
	assert_check(time_lbl.text.contains(" - "), "Time label uses numeric DD - MM - YY date format: '%s'" % time_lbl.text)
	assert_check(not time_lbl.text.contains("Month") and not time_lbl.text.contains("Day "), "Time label no longer uses Month/Day format: '%s'" % time_lbl.text)

	# 4. Test clicking Pause button
	pause_btn.emit_signal("pressed")
	assert_check(PlayerData.is_time_paused == true, "Clicking PauseTimeButton pauses time")
	assert_check("Resume" in pause_btn.text or "▶️" in pause_btn.text, "Pause button updates to Resume icon/text: '%s'" % pause_btn.text)
	assert_check(not time_lbl.text.contains("PAUSED"), "Time label does not append PAUSED text: '%s'" % time_lbl.text)
	assert_check(pause_btn.get_theme_stylebox("normal") != null, "Paused pause button retains highlighted style")

	# 5. Test clicking Resume button
	pause_btn.emit_signal("pressed")
	assert_check(PlayerData.is_time_paused == false, "Clicking Resume button unpauses time")
	assert_check("Pause" in pause_btn.text or "⏸️" in pause_btn.text, "Pause button restores Pause icon/text: '%s'" % pause_btn.text)

	# 6. Test Spacebar shortcut synchronization with Pause button
	PlayerData.has_started_game = true
	PlayerData.is_dead = false
	if main_scene.new_game_panel != null:
		main_scene.new_game_panel.visible = false
	var key_event := InputEventKey.new()
	key_event.pressed = true
	key_event.echo = false
	key_event.keycode = KEY_SPACE
	main_scene._unhandled_input(key_event)
	assert_check(PlayerData.is_time_paused == true, "Spacebar pauses time")
	assert_check("Resume" in pause_btn.text or "▶️" in pause_btn.text, "Pause button reflects paused state from spacebar: '%s'" % pause_btn.text)

	main_scene._unhandled_input(key_event)
	assert_check(PlayerData.is_time_paused == false, "Spacebar resumes time")
	assert_check("Pause" in pause_btn.text or "⏸️" in pause_btn.text, "Pause button reflects running state from spacebar: '%s'" % pause_btn.text)

	main_scene.free()

	print("\n=======================================================")
	print("🎉 ALL PAUSE BUTTON & TIME RELOCATION TESTS PASSED (%d/%d assertions)!" % [passed_assertions, total_assertions])
	print("=======================================================")
	get_tree().quit(0)
