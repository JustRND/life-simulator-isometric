extends Node

func _ready() -> void:
	print("=== BEGIN TEST: GRADES, GPA & SMARTNESS-BASED SCALING AUDIT ===")

	LifeLibrary.data.theme = "dark"
	LifeLibrary.data.muted = false
	AudioServer.set_bus_mute(0, false)
	PlayerData.reset_player()
	PlayerData.has_started_game = true

	# -------------------------------------------------------------
	# 1. AUDIT GPA CALCULATION CODE & CONVERSION
	# -------------------------------------------------------------
	print("\n--- 1. AUDITING GPA CALCULATION CODE ---")
	var test_grades := [
		{"grades": 100, "expected_gpa": 4.00, "letter": "A+"},
		{"grades": 95, "expected_gpa": 3.80, "letter": "A+"},
		{"grades": 85, "expected_gpa": 3.40, "letter": "A"},
		{"grades": 80, "expected_gpa": 3.20, "letter": "B"},
		{"grades": 75, "expected_gpa": 3.00, "letter": "B"},
		{"grades": 70, "expected_gpa": 2.80, "letter": "C"},
		{"grades": 65, "expected_gpa": 2.60, "letter": "C"},
		{"grades": 55, "expected_gpa": 2.20, "letter": "D"},
		{"grades": 50, "expected_gpa": 2.00, "letter": "F (Failing)"},
		{"grades": 0, "expected_gpa": 0.00, "letter": "0% (Course Required)"}
	]

	for entry in test_grades:
		PlayerData.grades = int(entry["grades"])
		var calc_gpa: float = PlayerData.get_gpa()
		var letter: String = PlayerData.get_letter_grade()
		print("  ✔ Grades: %3d%% -> GPA: %.2f (Expected: %.2f), Letter: %s" % [PlayerData.grades, calc_gpa, float(entry["expected_gpa"]), letter])
		assert(is_equal_approx(calc_gpa, float(entry["expected_gpa"])), "GPA calculation mismatch for grade %d" % entry["grades"])
		assert(letter == String(entry["letter"]), "Letter grade mismatch for grade %d" % entry["grades"])

	print("✅ CHECK 1 PASSED: GPA calculation code verified across full 0-100% scale.")

	# -------------------------------------------------------------
	# 2. AUDIT DIRECT SMARTNESS SCALING ON GRADES GAIN
	# -------------------------------------------------------------
	print("\n--- 2. AUDITING SMARTNESS DIRECT EFFECT ON GRADES GAIN ---")
	# Rule: lower smartness = harder grades gain; higher smartness = easier grades gain.
	var base_gain := 10
	var smartness_levels := [5, 20, 50, 75, 95]
	var prev_gain := 0

	for s_val in smartness_levels:
		PlayerData.smarts = s_val
		var mult: float = PlayerData.get_grades_gain_multiplier()
		var actual_gain: int = PlayerData.calculate_grades_gain(base_gain)
		print("  ✔ Smarts: %2d -> Multiplier: %.3fx -> Gain from base %d: +%d%%" % [s_val, mult, base_gain, actual_gain])
		assert(actual_gain > prev_gain, "Higher smartness must produce strictly greater or equal grades gain!")
		prev_gain = actual_gain

	# Test low smartness (struggling)
	PlayerData.smarts = 10
	var low_gain: int = PlayerData.calculate_grades_gain(10)
	# Test high smartness (genius)
	PlayerData.smarts = 90
	var high_gain: int = PlayerData.calculate_grades_gain(10)
	print("  ✔ Low Smarts (10) Gain: +%d%% vs High Smarts (90) Gain: +%d%% (Ratio: %.2fx)" % [low_gain, high_gain, float(high_gain) / float(low_gain)])
	assert(low_gain < 7, "Low smartness must make grade gain harder (< 7 from base 10)")
	assert(high_gain > 13, "High smartness must make grade gain easier (> 13 from base 10)")
	print("✅ CHECK 2 PASSED: Direct smartness scaling confirmed: lower smartness = harder, higher smartness = easier.")

	# -------------------------------------------------------------
	# 3. AUDIT 5% YEARLY DEGRADATION RATE (WHEN NOT MAINTAINED)
	# -------------------------------------------------------------
	print("\n--- 3. AUDITING 5% YEARLY DEGRADATION WHEN NOT MAINTAINED ---")
	var main_scene_res = load("res://scenes/main/main_screen.tscn")
	var main_scene = main_scene_res.instantiate()
	add_child(main_scene)
	await get_tree().process_frame

	# Set up a student at High School who neglects schooling
	PlayerData.age = 15
	PlayerData.education_level = "High School"
	PlayerData.grades = 85
	PlayerData.last_school_activity_age = -1 # Not studied this year

	print("  Initial state at age 15: Grades = %d%% (GPA: %.2f)" % [PlayerData.grades, PlayerData.get_gpa()])

	# Age up to 16 without studying
	main_scene._process_yearly_grades_decay(15)
	print("  After 1 unmaintained year (age 16): Grades = %d%% (GPA: %.2f)" % [PlayerData.grades, PlayerData.get_gpa()])
	assert(PlayerData.grades == 80, "Grades must degrade by exactly 5%% yearly if not maintained! Expected 80, got %d" % PlayerData.grades)

	# Age up to 17 without studying
	main_scene._process_yearly_grades_decay(16)
	print("  After 2 unmaintained years (age 17): Grades = %d%% (GPA: %.2f)" % [PlayerData.grades, PlayerData.get_gpa()])
	assert(PlayerData.grades == 75, "Grades must degrade by exactly 5%% yearly if not maintained! Expected 75, got %d" % PlayerData.grades)

	# Age up to 18 without studying
	main_scene._process_yearly_grades_decay(17)
	print("  After 3 unmaintained years (age 18): Grades = %d%% (GPA: %.2f)" % [PlayerData.grades, PlayerData.get_gpa()])
	assert(PlayerData.grades == 70, "Grades must degrade by exactly 5%% yearly if not maintained! Expected 70, got %d" % PlayerData.grades)

	print("✅ CHECK 3 PASSED: Unmaintained schooling degrades by exactly 5% yearly (does not degrade too quickly).")

	# -------------------------------------------------------------
	# 4. AUDIT MAINTENANCE (NO DECAY WHEN ACTIVELY STUDIED)
	# -------------------------------------------------------------
	print("\n--- 4. AUDITING ACTIVE MAINTENANCE (ZERO DECAY) ---")
	PlayerData.age = 18
	PlayerData.education_level = "High School"
	PlayerData.grades = 70
	PlayerData.smarts = 50
	PlayerData.last_school_activity_age = 18 # Maintained!

	main_scene._process_yearly_grades_decay(18)
	print("  After maintained year at age 18: Grades = %d%%" % PlayerData.grades)
	assert(PlayerData.grades >= 70, "Maintained schooling must NOT degrade!")
	print("✅ CHECK 4 PASSED: Maintained schooling preserves grades without decay.")

	# -------------------------------------------------------------
	# 5. AUDIT EVENT EFFECTS WITH SMARTNESS SCALING
	# -------------------------------------------------------------
	print("\n--- 5. AUDITING EVENT EFFECTS SCALED BY SMARTNESS ---")
	# Low smarts player gets event +10 grades
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.grades = 50
	PlayerData.smarts = 15
	PlayerData.apply_effects({"grades": 10})
	var low_s_final_grade := PlayerData.grades
	var low_s_gained := low_s_final_grade - 50
	print("  Low Smarts (15) received event (+10 base): Gained +%d%% (Total: %d%%)" % [low_s_gained, low_s_final_grade])

	# High smarts player gets event +10 grades
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.grades = 50
	PlayerData.smarts = 90
	PlayerData.apply_effects({"grades": 10})
	var high_s_final_grade := PlayerData.grades
	var high_s_gained := high_s_final_grade - 50
	print("  High Smarts (90) received event (+10 base): Gained +%d%% (Total: %d%%)" % [high_s_gained, high_s_final_grade])

	assert(high_s_gained > low_s_gained, "High smarts player must gain more grades from event than low smarts player")
	print("✅ CHECK 5 PASSED: Event effects correctly honor smartness scaling.")

	# -------------------------------------------------------------
	# 6. AUDIT ADULT UNMAINTAINED 5% YEARLY DEGRADATION
	# -------------------------------------------------------------
	print("\n--- 6. AUDITING ADULT UNMAINTAINED DEGRADATION ---")
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.age = 25
	PlayerData.education_level = "High School Graduate"
	PlayerData.job_id = "" # Unemployed / non-intellectual
	PlayerData.grades = 75
	PlayerData.last_school_activity_age = -1

	main_scene._process_yearly_grades_decay(25)
	print("  Adult age 25 unmaintained: Grades = %d%% (Expected 70%%)" % PlayerData.grades)
	assert(PlayerData.grades == 70, "Adult unmaintained grades must degrade by 5% yearly")
	print("✅ CHECK 6 PASSED: Adult qualification degrades at measured 5% yearly rate.")

	print("\n⭐⭐⭐ ALL GRADES, GPA & SMARTNESS-BASED SCALING TESTS PASSED PERFECTLY! ⭐⭐⭐")
	get_tree().quit(0)
