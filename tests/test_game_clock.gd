extends Node

func _ready() -> void:
	print("--- BEGIN TEST GAME CLOCK (STAGE 2) ---")
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.is_dead = false
	PlayerData.is_time_paused = false
	test_calendar_constants_and_leap_year()
	test_day_month_year_boundaries()
	test_deterministic_age_calculation_and_birthdays()
	test_realtime_accumulator_and_long_frame_delays()
	test_pause_and_resume_system()
	test_save_and_reload()
	test_legacy_save_migration()
	test_duplicate_game_clock_prevention()
	print("--- ALL GAME CLOCK TESTS PASSED SUCCESSFULLY! ---")
	get_tree().quit(0)


func assert_true(cond: bool, msg: String) -> void:
	if not cond:
		push_error("ASSERTION FAILED: " + msg)
		print("FAILED: " + msg)
		get_tree().quit(1)
		assert(false, msg)
	else:
		print("  ✓ " + msg)


func test_calendar_constants_and_leap_year() -> void:
	print("\nTesting Gregorian Calendar Constants & Leap Year Rules...")
	# 1. Leap year rules
	assert_true(GameClock.is_leap_year(2024), "2024 is a leap year (divisible by 4)")
	assert_true(not GameClock.is_leap_year(2025), "2025 is not a leap year")
	assert_true(not GameClock.is_leap_year(2026), "2026 is not a leap year")
	assert_true(GameClock.is_leap_year(2028), "2028 is a leap year")
	assert_true(not GameClock.is_leap_year(1900), "1900 is not a leap year (century rule: divisible by 100 but not 400)")
	assert_true(GameClock.is_leap_year(2000), "2000 is a leap year (400-year rule: divisible by 400)")
	assert_true(not GameClock.is_leap_year(2100), "2100 is not a leap year (century rule)")
	assert_true(GameClock.is_leap_year(2400), "2400 is a leap year (400-year rule)")

	# 2. Month lengths
	assert_true(GameClock.get_days_in_month(2026, 1) == 31, "January has 31 days")
	assert_true(GameClock.get_days_in_month(2026, 2) == 28, "February 2026 has 28 days")
	assert_true(GameClock.get_days_in_month(2024, 2) == 29, "February 2024 (leap) has 29 days")
	assert_true(GameClock.get_days_in_month(2026, 4) == 30, "April has 30 days")
	assert_true(GameClock.get_days_in_month(2026, 7) == 31, "July has 31 days")
	assert_true(GameClock.get_days_in_month(2026, 8) == 31, "August has 31 days")
	assert_true(GameClock.get_days_in_month(2026, 12) == 31, "December has 31 days")

	# 3. Month names
	assert_true(GameClock.get_month_name(1) == "January", "Month 1 is January")
	assert_true(GameClock.get_month_name(12) == "December", "Month 12 is December")
	assert_true(GameClock.month_name_to_index("March") == 3, "March resolves to index 3")
	assert_true(GameClock.month_name_to_index("nov") == 11, "Short 'nov' resolves to index 11")


func test_day_month_year_boundaries() -> void:
	print("\nTesting Calendar Rollover Boundaries (Day, Month, Year)...")
	GameClock.setup_new_game(1, 1, 2026, 1, 31, 12)
	assert_true(GameClock.month == 1 and GameClock.day == 31, "Setup at January 31, 2026")

	# Jan 31 -> Feb 1
	var day_signals: Array = []
	var month_signals: Array = []
	var year_signals: Array = []

	var c_day = func(y, m, d): day_signals.append([y, m, d])
	var c_month = func(y, m): month_signals.append([y, m])
	var c_year = func(y): year_signals.append(y)

	GameClock.day_changed.connect(c_day)
	GameClock.month_changed.connect(c_month)
	GameClock.year_changed.connect(c_year)

	GameClock.advance_days(1)
	assert_true(GameClock.month == 2 and GameClock.day == 1, "Jan 31 + 1 day rolls over to Feb 1")
	assert_true(month_signals.size() == 1 and month_signals[0] == [2026, 2], "month_changed emitted for Feb 2026")

	# Feb 28 in 2026 (non-leap) -> Mar 1
	GameClock.year = 2026
	GameClock.month = 2
	GameClock.day = 28
	GameClock.advance_days(1)
	assert_true(GameClock.month == 3 and GameClock.day == 1, "Feb 28 in common year rolls over to Mar 1")

	# Feb 28 in 2024 (leap) -> Feb 29
	GameClock.year = 2024
	GameClock.month = 2
	GameClock.day = 28
	month_signals.clear()
	GameClock.advance_days(1)
	assert_true(GameClock.month == 2 and GameClock.day == 29, "Feb 28 in leap year 2024 advances to Feb 29")
	assert_true(month_signals.is_empty(), "Month did not roll over on leap day")

	# Feb 29 in 2024 -> Mar 1
	GameClock.advance_days(1)
	assert_true(GameClock.month == 3 and GameClock.day == 1, "Feb 29 rolls over to Mar 1")

	# Apr 30 -> May 1
	GameClock.month = 4
	GameClock.day = 30
	GameClock.advance_days(1)
	assert_true(GameClock.month == 5 and GameClock.day == 1, "Apr 30 rolls over to May 1")

	# Dec 31, 2026 -> Jan 1, 2027 (Year rollover)
	GameClock.year = 2026
	GameClock.month = 12
	GameClock.day = 31
	year_signals.clear()
	GameClock.advance_days(1)
	assert_true(GameClock.year == 2027 and GameClock.month == 1 and GameClock.day == 1, "Dec 31, 2026 rolls over to Jan 1, 2027")
	assert_true(year_signals.size() == 1 and year_signals[0] == 2027, "year_changed emitted for 2027")

	GameClock.day_changed.disconnect(c_day)
	GameClock.month_changed.disconnect(c_month)
	GameClock.year_changed.disconnect(c_year)


func test_deterministic_age_calculation_and_birthdays() -> void:
	print("\nTesting Deterministic Age Calculation & Birthday Triggers...")
	# 1. calculate_age pure determinism: same date ALWAYS produces the same age
	var b_y := 2014
	var b_m := 1
	var b_d := 1
	for _i in range(50):
		var age_dec31 := GameClock.calculate_age(2025, 12, 31, b_y, b_m, b_d)
		var age_jan1 := GameClock.calculate_age(2026, 1, 1, b_y, b_m, b_d)
		assert_true(age_dec31 == 11, "Day before birthday is always age 11")
		assert_true(age_jan1 == 12, "Day of birthday is always age 12")

	# 2. Starting age 12 birth year derivation
	var derived_y := GameClock.derive_birth_year(2026, 1, 1, 1, 1, 12)
	assert_true(derived_y == 2014, "Derived birth year for Jan 1 birthday starting Jan 1 2026 is 2014")

	# Birthday later in the year (e.g. October 15)
	var derived_oct := GameClock.derive_birth_year(2026, 1, 1, 10, 15, 12)
	assert_true(derived_oct == 2013, "Derived birth year for Oct 15 birthday starting Jan 1 2026 is 2013")
	assert_true(GameClock.calculate_age(2026, 1, 1, derived_oct, 10, 15) == 12, "Verified starting age is 12 on Jan 1 2026")
	assert_true(GameClock.calculate_age(2026, 10, 15, derived_oct, 10, 15) == 13, "Turns 13 on Oct 15 2026")

	# 3. Leap day birthday handling (Feb 29)
	var leap_b_y := 2020
	var leap_b_m := 2
	var leap_b_d := 29
	# In non-leap year 2021: celebrated on Feb 28
	assert_true(GameClock.is_birthday_on_date(2021, 2, 28, leap_b_m, leap_b_d), "Feb 29 birthday recognized on Feb 28 in non-leap year")
	assert_true(GameClock.calculate_age(2021, 2, 28, leap_b_y, leap_b_m, leap_b_d) == 1, "Leap baby turns 1 on Feb 28 of non-leap year")
	# In leap year 2024: celebrated on Feb 29
	assert_true(not GameClock.is_birthday_on_date(2024, 2, 28, leap_b_m, leap_b_d), "Feb 29 birthday not triggered on Feb 28 in leap year")
	assert_true(GameClock.is_birthday_on_date(2024, 2, 29, leap_b_m, leap_b_d), "Feb 29 birthday triggered on Feb 29 in leap year")
	assert_true(GameClock.calculate_age(2024, 2, 29, leap_b_y, leap_b_m, leap_b_d) == 4, "Leap baby turns 4 on Feb 29 in 2024")

	# 4. Birthday signal emission
	var birthday_signals: Array = []
	var c_bday = func(age): birthday_signals.append(age)
	GameClock.birthday.connect(c_bday)

	GameClock.setup_new_game(5, 20, 2026, 5, 19, 12)
	GameClock.advance_days(1)
	assert_true(GameClock.month == 5 and GameClock.day == 20, "Advanced to birthday date May 20")
	assert_true(birthday_signals.size() == 1 and birthday_signals[0] == 13, "birthday signal emitted with new age 13")

	GameClock.birthday.disconnect(c_bday)


func test_realtime_accumulator_and_long_frame_delays() -> void:
	print("\nTesting Real-Time Delta Accumulator & Long Frame Delays...")
	GameClock.setup_new_game(1, 1, 2026, 1, 1, 12)
	PlayerData.has_started_game = true
	PlayerData.is_dead = false
	PlayerData.is_time_paused = false

	# 1. Partial seconds accumulation
	GameClock.step_clock(0.3)
	assert_true(is_equal_approx(GameClock.day_accumulator, 0.3), "Accumulator stores 0.3s")
	assert_true(GameClock.day == 1, "Day does not advance with < 1.0s elapsed")

	GameClock.step_clock(0.7)
	assert_true(is_equal_approx(GameClock.day_accumulator, 0.0), "Accumulator rolled over at 1.0s")
	assert_true(GameClock.day == 2, "Day advances to 2 at 1.0s accumulated")

	# 2. Frame delay: 3.5 seconds in a single tick
	GameClock.step_clock(3.5)
	assert_true(GameClock.day == 5, "3.5s advances 3 full days (day 2 -> day 5)")
	assert_true(is_equal_approx(GameClock.day_accumulator, 0.5), "Remaining 0.5s accumulator preserved")

	# 3. Very long frame delay across month boundary (30.0s)
	GameClock.day = 25
	GameClock.month = 1
	GameClock.day_accumulator = 0.0
	GameClock.step_clock(10.0) # Jan 25 + 10 days = Jan 35 -> Feb 4
	assert_true(GameClock.month == 2 and GameClock.day == 4, "10-day frame delay seamlessly crosses January boundary into February")


func test_pause_and_resume_system() -> void:
	print("\nTesting Multi-Reason Pause & Lock System...")
	GameClock.setup_new_game(1, 1, 2026, 1, 1, 12)
	PlayerData.has_started_game = true
	PlayerData.is_dead = false
	PlayerData.is_time_paused = false

	assert_true(GameClock.is_running(), "GameClock is running initially")

	# Pause with reason 'pause_menu'
	GameClock.pause("pause_menu")
	assert_true(not GameClock.is_running(), "Clock is not running when pause_menu active")
	var initial_acc := GameClock.day_accumulator
	var initial_day := GameClock.day
	GameClock.step_clock(5.0)
	assert_true(GameClock.day == initial_day, "Day did not advance while paused")
	assert_true(GameClock.day_accumulator == initial_acc, "Accumulator did not advance while paused")

	# Add second pause reason 'modal_dialog'
	GameClock.pause("modal_dialog")
	GameClock.resume("pause_menu")
	assert_true(not GameClock.is_running(), "Clock remains paused because modal_dialog is still active")

	GameClock.resume("modal_dialog")
	assert_true(GameClock.is_running(), "Clock resumes when all pause reasons are cleared")

	# Test external progression check callback
	var block_state := {"should_block": true}
	GameClock.external_progression_check = func(): return not block_state["should_block"]
	assert_true(not GameClock.is_running(), "External check returning false pauses clock")
	block_state["should_block"] = false
	assert_true(GameClock.is_running(), "External check returning true allows clock to run")
	GameClock.external_progression_check = Callable()


func test_save_and_reload() -> void:
	print("\nTesting Save and Reload Cycle...")
	GameClock.setup_new_game(6, 18, 2028, 8, 25, 14)
	GameClock.day_accumulator = 0.65
	GameClock.pause("test_pause")

	var save_dict := GameClock.capture_save_data()
	assert_true(int(save_dict.get("calendar_year", 0)) == 2028, "Save captures calendar year")
	assert_true(int(save_dict.get("calendar_month", 0)) == 8, "Save captures calendar month")
	assert_true(int(save_dict.get("calendar_day", 0)) == 25, "Save captures calendar day")
	assert_true(int(save_dict.get("birth_year", 0)) == 2014, "Save captures birth year")
	assert_true(int(save_dict.get("birth_month", 0)) == 6, "Save captures birth month")
	assert_true(int(save_dict.get("birth_day", 0)) == 18, "Save captures birth day")
	assert_true(int(save_dict.get("current_age", 0)) == 14, "Save captures current age")
	assert_true(is_equal_approx(float(save_dict.get("day_accumulator", 0.0)), 0.65), "Save captures accumulator")

	# Reset and restore
	GameClock.setup_new_game(1, 1, 2026, 1, 1, 12)
	GameClock.restore_save_data(save_dict)

	assert_true(GameClock.year == 2028, "Restored year is 2028")
	assert_true(GameClock.month == 8, "Restored month is 8")
	assert_true(GameClock.day == 25, "Restored day is 25")
	assert_true(GameClock.birth_year == 2014, "Restored birth year is 2014")
	assert_true(GameClock.current_age == 14, "Restored age is 14")
	assert_true(is_equal_approx(GameClock.day_accumulator, 0.65), "Restored accumulator is 0.65")
	assert_true(PlayerData.age == 14, "PlayerData age synced to 14")
	assert_true(PlayerData.in_game_year == 2028, "PlayerData year synced to 2028")


func test_legacy_save_migration() -> void:
	print("\nTesting Safe Migration for Legacy Saves (Preserving Age & Wealth)...")
	PlayerData.reset_player()
	var legacy_save: Dictionary = {
		"first_name": "Marcus Legacy",
		"has_started_game": true,
		"age": 35,
		"in_game_year": 4,
		"in_game_month": 5,
		"in_game_day": 12,
		"birth_month": "March",
		"birth_day": 10,
		"money": 125000,
		"bank_savings": 500000,
		"life_milestones": [{"text": "Graduated University", "age": 22}],
		"owned_assets": [{"id": "car_sedan", "name": "Sedan"}]
	}


	SaveManager.apply_data(legacy_save)

	assert_true(PlayerData.age == 35, "Legacy age preserved at 35 (not reset to 12)")
	assert_true(PlayerData.money == 125000, "Legacy money preserved ($125,000)")
	assert_true(PlayerData.bank_savings == 500000, "Legacy savings preserved ($500,000)")
	assert_true(PlayerData.owned_assets.size() == 1, "Legacy assets preserved")
	assert_true(GameClock.current_age == 35, "GameClock age reflects migrated age 35")
	assert_true(GameClock.year == 2029, "Relative year 4 mapped to Gregorian baseline 2029 (2026 + 3)")
	assert_true(GameClock.month == 5, "Migrated month is 5")
	assert_true(GameClock.day == 12, "Migrated day is 12")

	# Verify deterministic age calculation reproduces exact age
	var re_calc := GameClock.calculate_age(GameClock.year, GameClock.month, GameClock.day, GameClock.birth_year, GameClock.birth_month, GameClock.birth_day)
	assert_true(re_calc == 35, "Deterministic calculate_age on migrated character produces exactly 35")


func test_duplicate_game_clock_prevention() -> void:
	print("\nTesting Duplicate GameClock Instance Prevention...")
	var initial_instance = GameClock.get_instance()
	assert_true(initial_instance != null, "Original GameClock autoload instance exists")

	# Attempt to instantiate a duplicate clock
	var duplicate_script = load("res://scripts/core/game_clock.gd")
	var duplicate_node = duplicate_script.new()
	add_child(duplicate_node)

	# The duplicate node's _enter_tree should detect existing instance and call queue_free()
	assert_true(duplicate_node.is_queued_for_deletion(), "Duplicate GameClock is queued for deletion immediately")
	assert_true(GameClock.get_instance() == initial_instance, "Authoritative GameClock instance was preserved")
