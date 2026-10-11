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

	# 2. Verify TimeRow contents: PauseTimeButton and TimeCounterLabel
	var pause_btn = main_scene.find_child("PauseTimeButton", true, false) as Button
	var time_lbl = main_scene.find_child("TimeCounterLabel", true, false) as Label

	assert_check(pause_btn != null, "PauseTimeButton exists inside TimeRow")
	assert_check(time_lbl != null, "TimeCounterLabel exists inside TimeRow")
	assert_check(pause_btn.get_parent() == time_row, "PauseTimeButton parent is TimeRow")
	assert_check(time_lbl.get_parent() == time_row, "TimeCounterLabel parent is TimeRow")

	# Verify AgeRow no longer contains TimeCounterLabel
	assert_check(time_lbl.get_parent() != age_row, "TimeCounterLabel is no longer beside AgeLabel in AgeRow")

	# 3. Test initial state (unpaused)
	PlayerData.is_time_paused = false
	main_scene._update_time_and_age_labels()
	assert_check("Pause" in pause_btn.text or "⏸️" in pause_btn.text, "Pause button displays Pause icon/text when running: '%s'" % pause_btn.text)
	assert_check("📅" in time_lbl.text, "Time label displays calendar icon when running: '%s'" % time_lbl.text)

	# 4. Test clicking Pause button
	pause_btn.emit_signal("pressed")
	assert_check(PlayerData.is_time_paused == true, "Clicking PauseTimeButton pauses time")
	assert_check("Resume" in pause_btn.text or "▶️" in pause_btn.text, "Pause button updates to Resume icon/text: '%s'" % pause_btn.text)
	assert_check("PAUSED" in time_lbl.text, "Time label displays PAUSED indicator: '%s'" % time_lbl.text)

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
