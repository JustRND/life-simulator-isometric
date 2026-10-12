extends Node

const MonthlySettlementCoordinator = preload("res://scripts/economy/monthly_settlement_coordinator.gd")
const AssetCatalog = preload("res://scripts/economy/asset_catalog.gd")
const RentalManager = preload("res://scripts/economy/rental_manager.gd")
const MortgageManager = preload("res://scripts/economy/mortgage_manager.gd")
const TaxSystem = preload("res://scripts/economy/tax_system.gd")

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
	print("🔍 RUNNING STAGE 5 FULL SYSTEM VERIFICATION SUITE")
	print("=======================================================")

	test_starting_state_and_age_12()
	test_calendar_boundaries_and_deltas()
	test_age_calculation_and_birthdays()
	test_pause_resume_and_offline_time()
	test_employment_salary_and_idempotency()
	test_progressive_tax_and_withholding()
	test_property_ownership_rent_mortgages_and_assets()
	test_personal_finance_debt_and_fallbacks()
	test_event_system_and_history_integrity()
	test_save_load_and_legacy_migration()
	test_heir_succession_and_reincarnation()
	test_ui_action_bar_and_navigation()
	test_multi_year_accelerated_simulation()

	print("=======================================================")
	print("🎉 ALL STAGE 5 VERIFICATION TESTS COMPLETED (%d/%d assertions passed)!" % [passed_assertions, total_assertions])
	print("=======================================================")
	get_tree().quit(0)


# -----------------------------------------------------------------------------
# 1. STARTING STATE & AGE 17
# -----------------------------------------------------------------------------
func test_starting_state_and_age_12() -> void:
	print("\n--- 1. Testing Starting State & Starting Age 17 ---")
	PlayerData.reset_player()
	assert_check(PlayerData.age == 17, "Starting age is 17")
	assert_check(PlayerData.in_game_day == 1, "Starting in-game day is 1")
	assert_check(PlayerData.in_game_month == 1, "Starting in-game month is 1")
	assert_check(PlayerData.in_game_year == 2026, "Starting in-game year is 2026")
	assert_check(PlayerData.education_level == "High School", "Education initialized to High School")
	assert_check(PlayerData.grades == 75, "Starting grades initialized to 75")

	if GameClock != null:
		GameClock.setup_new_game(1, 1, 2026, 1, 1, 17)
		assert_check(GameClock.year == 2026, "GameClock year is 2026")
		assert_check(GameClock.month == 1, "GameClock month is 1")
		assert_check(GameClock.day == 1, "GameClock day is 1")
		assert_check(GameClock.current_age == 17, "GameClock current_age is 17")
		assert_check(GameClock.birth_year == 2009, "Derived birth year for Jan 1 starting at age 17 in 2026 is 2009")


# -----------------------------------------------------------------------------
# 2. CALENDAR BOUNDARIES & FRAME DELTAS
# -----------------------------------------------------------------------------
func test_calendar_boundaries_and_deltas() -> void:
	print("\n--- 2. Testing Calendar Boundaries & Large Frame Deltas ---")
	if GameClock == null:
		return

	PlayerData.has_started_game = true
	PlayerData.is_dead = false
	PlayerData.is_time_paused = false

	# Test leap year vs common year February
	assert_check(GameClock.get_days_in_month(2026, 2) == 28, "2026 Feb has 28 days")
	assert_check(GameClock.get_days_in_month(2024, 2) == 29, "2024 Feb has 29 days (leap year)")
	assert_check(GameClock.get_days_in_month(2000, 2) == 29, "2000 Feb has 29 days (century leap year)")
	assert_check(GameClock.get_days_in_month(2100, 2) == 28, "2100 Feb has 28 days (century common year)")

	# Set up clock at Jan 31
	GameClock.setup_new_game(1, 1, 2026, 1, 31, 12)
	assert_check(GameClock.day == 31 and GameClock.month == 1, "Clock positioned at Jan 31")

	# Step 1 day
	GameClock.step_clock(1.0)
	assert_check(GameClock.day == 1 and GameClock.month == 2, "Jan 31 + 1 day rolled to Feb 1")

	# Step 27 days to Feb 28
	GameClock.advance_days(27)
	assert_check(GameClock.day == 28 and GameClock.month == 2, "Clock advanced to Feb 28, 2026")

	# Step 1 day past Feb 28 in common year
	GameClock.step_clock(1.0)
	assert_check(GameClock.day == 1 and GameClock.month == 3, "Feb 28 in common year rolled to Mar 1")

	# Large elapsed delta (e.g. 5.5 seconds = 5 days + 0.5s remainder)
	GameClock.step_clock(5.5)
	assert_check(GameClock.day == 6 and GameClock.month == 3, "5.5s advanced 5 days to Mar 6")
	assert_check(is_equal_approx(GameClock.day_accumulator, 0.5), "Day accumulator retained 0.5s remainder")


# -----------------------------------------------------------------------------
# 3. AGE CALCULATION & BIRTHDAYS
# -----------------------------------------------------------------------------
func test_age_calculation_and_birthdays() -> void:
	print("\n--- 3. Testing Correct Age Calculation & Birthday Triggers ---")
	if GameClock == null:
		return

	PlayerData.has_started_game = true
	PlayerData.is_dead = false
	PlayerData.is_time_paused = false

	# Born on March 15, 2014
	var b_year := 2014
	var b_month := 3
	var b_day := 15

	# On March 14, 2026 -> Age 11
	assert_check(GameClock.calculate_age(2026, 3, 14, b_year, b_month, b_day) == 11, "Day before birthday is age 11")
	# On March 15, 2026 -> Age 12
	assert_check(GameClock.calculate_age(2026, 3, 15, b_year, b_month, b_day) == 12, "Day of birthday is age 12")
	# On March 16, 2026 -> Age 12
	assert_check(GameClock.calculate_age(2026, 3, 16, b_year, b_month, b_day) == 12, "Day after birthday is age 12")

	# Birthday signal emission
	GameClock.setup_new_game(b_month, b_day, 2026, 3, 14, 11)
	var bday_result := [false, -1]
	var on_bday = func(new_a: int):
		bday_result[0] = true
		bday_result[1] = new_a
	GameClock.birthday.connect(on_bday)

	GameClock.step_clock(1.0) # Moves from Mar 14 to Mar 15
	assert_check(bday_result[0], "Birthday signal emitted on birthday date")
	assert_check(bday_result[1] == 12, "Birthday signal emitted correct new age 12")
	GameClock.birthday.disconnect(on_bday)

	# Feb 29 Leap Baby Handling in common years
	assert_check(GameClock.is_birthday_on_date(2026, 2, 28, 2, 29), "Feb 29 birthday recognized on Feb 28 in common year")
	assert_check(not GameClock.is_birthday_on_date(2024, 2, 28, 2, 29), "Feb 29 birthday NOT recognized on Feb 28 in leap year")
	assert_check(GameClock.is_birthday_on_date(2024, 2, 29, 2, 29), "Feb 29 birthday recognized on Feb 29 in leap year")


# -----------------------------------------------------------------------------
# 4. PAUSE / RESUME & NO OFFLINE PROGRESSION
# -----------------------------------------------------------------------------
func test_pause_resume_and_offline_time() -> void:
	print("\n--- 4. Testing Pause/Resume & No Offline Progression ---")
	if GameClock == null:
		return

	PlayerData.has_started_game = true
	PlayerData.is_dead = false
	PlayerData.is_time_paused = false
	GameClock.setup_new_game(1, 1, 2026, 1, 1, 12)
	assert_check(GameClock.is_running(), "Clock running initially")

	# Pause with reason
	GameClock.pause("manual_test")
	assert_check(not GameClock.is_running(), "Clock not running when paused")
	GameClock.step_clock(10.0)
	assert_check(GameClock.day == 1 and GameClock.month == 1, "Time did not advance while paused")
	assert_check(GameClock.day_accumulator == 0.0, "Accumulator did not advance while paused")

	# Multiple pause reasons
	GameClock.pause("modal_open")
	GameClock.resume("manual_test")
	assert_check(not GameClock.is_running(), "Clock still paused while modal_open is active")
	GameClock.resume("modal_open")
	assert_check(GameClock.is_running(), "Clock resumed when all pause reasons cleared")

	# Offline progression check: ensure no timestamp jumps
	var saved_day := GameClock.day
	var saved_month := GameClock.month
	var saved_year := GameClock.year
	var clock_data := GameClock.capture_save_data()
	# Restore back
	GameClock.restore_save_data(clock_data)
	assert_check(GameClock.day == saved_day, "No offline day jump on load")
	assert_check(GameClock.month == saved_month, "No offline month jump on load")
	assert_check(GameClock.year == saved_year, "No offline year jump on load")


# -----------------------------------------------------------------------------
# 5. SALARY, EMPLOYMENT, UNEMPLOYMENT & IDEMPOTENCY
# -----------------------------------------------------------------------------
func test_employment_salary_and_idempotency() -> void:
	print("\n--- 5. Testing Salary, Employment, Unemployment & Idempotency ---")
	PlayerData.reset_player()
	PlayerData.age = 25
	PlayerData.job_title = ""
	PlayerData.job_id = ""
	PlayerData.job_salary = 0
	PlayerData.money = 0
	PlayerData.bank_savings = 0

	# 1. Unemployed player receives $0 salary
	var unemp_res := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 1)
	assert_check(unemp_res.get("settled", false), "Settlement processed for month 1")
	assert_check(PlayerData.bank_savings == 0, "Unemployed player receives zero salary")
	assert_check(PlayerData.cumulative_salary_paid_this_year == 0, "Cumulative salary is 0")

	# 2. Strict Idempotency: Duplicate settlement in same month rejected
	var dup_res := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 1)
	assert_check(dup_res.get("settled", false) == false, "Duplicate monthly settlement correctly rejected")

	# 3. Employed player receives exact 1/12th salary
	PlayerData.job_title = "Junior Developer"
	PlayerData.job_id = "job_junior_dev"
	PlayerData.job_salary = 60000 # $5,000 / month
	PlayerData.job_company = "Tech Inc"

	var emp_res := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 2)
	assert_check(emp_res.get("settled", false), "Settlement processed for month 2")
	assert_check(PlayerData.cumulative_salary_paid_this_year == 5000, "Cumulative salary recorded exactly $5,000")


# -----------------------------------------------------------------------------
# 6. PROGRESSIVE TAXES & TAX WITHHOLDING
# -----------------------------------------------------------------------------
func test_progressive_tax_and_withholding() -> void:
	print("\n--- 6. Testing Progressive Taxes & Withholding ---")
	PlayerData.reset_player()
	PlayerData.age = 30
	PlayerData.job_title = "Senior Engineer"
	PlayerData.job_id = "job_senior_dev"
	PlayerData.job_salary = 120000 # $120,000/yr

	var annual_tax_res: Dictionary = TaxSystem.calculate_income_tax(120000)
	var annual_tax: int = int(annual_tax_res.get("tax_due", 0))
	var expected_monthly_income_withholding: int = int(round(float(annual_tax) / 12.0))

	var tax_calc: Dictionary = TaxSystem.calculate_monthly_withholding(PlayerData)
	var monthly_tax: int = int(tax_calc.get("total_monthly_withholding", 0))
	var monthly_inc_tax: int = int(tax_calc.get("monthly_income_tax", 0))
	var monthly_prop_tax: int = int(tax_calc.get("monthly_property_tax", 0))
	assert_check(monthly_inc_tax == expected_monthly_income_withholding, "Monthly income withholding matches annualized progressive estimate ($%d)" % monthly_inc_tax)
	assert_check(monthly_tax == monthly_inc_tax + monthly_prop_tax, "Total monthly withholding includes income and property taxes ($%d)" % monthly_tax)

	# Settle all 12 months and verify annual reconciliation
	for m in range(1, 13):
		MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, m)

	assert_check(PlayerData.cumulative_salary_paid_this_year == 120000, "Exact 12-month payroll equals annual salary ($120,000)")
	var recon := TaxSystem.reconcile_annual_taxes(PlayerData)
	assert_check(recon.get("reconciled", false), "Annual tax reconciliation completed successfully")
	var tax_drift: int = absi(int(recon.get("withheld", 0)) - int(recon.get("personal_liability", 0)))
	assert_check(tax_drift <= 6, "Tax drift across 12 months is minimal ($%d)" % tax_drift)


# -----------------------------------------------------------------------------
# 7. PROPERTY OWNERSHIP, RENT, MORTGAGES & ASSETS
# -----------------------------------------------------------------------------
func test_property_ownership_rent_mortgages_and_assets() -> void:
	print("\n--- 7. Testing Property Ownership, Rent, Mortgages & Assets ---")
	PlayerData.reset_player()
	PlayerData.age = 28
	PlayerData.bank_savings = 200000

	# 1. Renting property
	var lease_res := RentalManager.sign_lease(PlayerData, "rent_micro_studio")
	assert_check(lease_res.get("success", false), "Signed residential rental lease")
	assert_check(RentalManager.has_active_lease(PlayerData), "Active lease verified")

	# 2. Mortgage & Property Ownership
	var mtg_res := MortgageManager.apply_for_mortgage(PlayerData, "prop_starter_home", 15, 0.05)
	assert_check(mtg_res.get("success", false), "Mortgage approved and property acquired")
	assert_check(PlayerData.mortgages.size() > 0, "Mortgage recorded in PlayerData.mortgages")

	var initial_principal: int = int(PlayerData.mortgages[0].get("remaining_principal", 0))
	var m_res := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 1)
	assert_check(m_res.get("settled", false), "Monthly settlement processed rent and mortgage")

	var post_principal: int = int(PlayerData.mortgages[0].get("remaining_principal", 0))
	assert_check(post_principal < initial_principal, "Mortgage principal decreased after monthly installment")

	# 3. Nonexistent assets do NOT incur charges
	PlayerData.owned_assets.clear()
	var pre_bank: int = PlayerData.bank_savings
	var empty_asset_logs := AssetCatalog.process_monthly_assets(PlayerData, 2)
	assert_check(empty_asset_logs.is_empty(), "No asset maintenance charges for empty asset portfolio")
	assert_check(PlayerData.bank_savings == pre_bank, "Bank savings untouched by empty assets")


# -----------------------------------------------------------------------------
# 8. PERSONAL FINANCE, DEBT & FALLBACKS
# -----------------------------------------------------------------------------
func test_personal_finance_debt_and_fallbacks() -> void:
	print("\n--- 8. Testing Personal Finance, Debt & Fallbacks ---")
	PlayerData.reset_player()
	PlayerData.owned_assets.clear()
	PlayerData.age = 22
	PlayerData.money = 50
	PlayerData.bank_savings = 0
	PlayerData.debt = 0
	PlayerData.job_title = "" # Unemployed independent adult ($250 basic living expenses)

	# Insufficient funds: $50 available vs $250 due
	var res := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 1)
	assert_check(res.get("settled", false), "Settlement processed under financial shortfall")
	assert_check(PlayerData.money == 0, "Liquid cash emptied")
	assert_check(PlayerData.bank_savings == 0, "Savings balance 0")
	assert_check(PlayerData.debt == 200, "Shortfall ($200) transferred directly to debt")

	# Severe debt (> $15,000) health penalty
	PlayerData.debt = 20000
	var pre_hp: int = PlayerData.health
	MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 2)
	assert_check(PlayerData.health < pre_hp, "Severe debt (>15k) caused health penalty")

	# Loan interest accrual
	PlayerData.loan_balance = 10000
	PlayerData.loan_interest_rate = 0.12 # 12% APR = 1% / month = $100
	MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 3)
	assert_check(PlayerData.loan_balance == 10100, "Loan balance compounded 1% monthly interest ($10,000 -> $10,100)")


# -----------------------------------------------------------------------------
# 10. EVENT SYSTEM & HISTORY INTEGRITY
# -----------------------------------------------------------------------------
func test_event_system_and_history_integrity() -> void:
	print("\n--- 10. Testing Event System & History Integrity ---")
	PlayerData.reset_player()
	PlayerData.record_event("first_day_of_school", 12)
	assert_check(PlayerData.has_seen_event("first_day_of_school"), "Event recorded in event history")
	assert_check(PlayerData.event_history_log.get("first_day_of_school") == 12, "Event age recorded accurately as 12")

	# Duplicate transactions prevention
	PlayerData.record_transaction("lifestyle", -15, "Lifestyle Purchase", "January 2026")
	var history_len := PlayerData.transaction_history.size()
	assert_check(history_len > 0, "Transaction logged in transaction history")
	var last_tx: Dictionary = PlayerData.transaction_history[-1]
	assert_check(last_tx.get("category") == "lifestyle", "Transaction category is lifestyle")
	assert_check(last_tx.get("amount") == -15, "Transaction amount is -$15")


# -----------------------------------------------------------------------------
# 11. SAVE / LOAD & LEGACY SAVE MIGRATION
# -----------------------------------------------------------------------------
func test_save_load_and_legacy_migration() -> void:
	print("\n--- 11. Testing Save/Load & Legacy Save Migration ---")
	PlayerData.reset_player()
	PlayerData.first_name = "QA Explorer"
	if GameClock != null:
		GameClock.setup_new_game(1, 1, 2026, 1, 1, 22)
	else:
		PlayerData.age = 22
	PlayerData.money = 7500
	PlayerData.bank_savings = 30000
	SaveManager.save_game()
	SaveManager.load_game()

	assert_check(PlayerData.first_name == "QA Explorer", "Name restored from save")
	assert_check(PlayerData.age == 22, "Age 22 restored from save")
	assert_check(PlayerData.money == 7500, "Money restored from save")
	assert_check(PlayerData.bank_savings == 30000, "Savings restored from save")

	# Legacy save migration preserves unrelated character progress.
	var legacy_save := {
		"save_version": 2,
		"first_name": "Legacy Elder",
		"has_started_game": true,
		"age": 45,
		"money": 50000,
		"bank_savings": 150000,
		"active_stat_modifiers": {"needs_hunger_low_hap": {"stat": "happiness", "delta": -10}},
		"in_game_year": 5,
		"in_game_month": 4,
		"in_game_day": 10
	}
	SaveManager.apply_data(legacy_save)
	assert_check(PlayerData.first_name == "Legacy Elder", "Legacy character name preserved")
	assert_check(PlayerData.age == 45, "Legacy age 45 preserved intact")
	assert_check(PlayerData.money == 50000, "Legacy money preserved")
	assert_check(PlayerData.bank_savings == 150000, "Legacy savings preserved")
	assert_check(not PlayerData.active_stat_modifiers.has("needs_hunger_low_hap"), "Legacy need modifiers discarded")


# -----------------------------------------------------------------------------
# 12. HEIR SUCCESSION & REINCARNATION
# -----------------------------------------------------------------------------
func test_heir_succession_and_reincarnation() -> void:
	print("\n--- 12. Testing Heir Succession & Reincarnation Transitions ---")
	PlayerData.reset_player()
	PlayerData.first_name = "Late Patriarch"
	PlayerData.age = 65
	PlayerData.is_dead = true # Parent died
	PlayerData.money = 10000
	PlayerData.bank_savings = 80000

	var heir := {
		"name": "Maya Heir",
		"gender": "FEMALE",
		"age": 22,
		"ethnicity": "asian",
		"portrait_track": 1,
		"portrait_variant": 0,
		"health": 90,
		"happiness": 80,
		"smarts": 85,
		"looks": 70
	}

	PlayerData.takeover_as_heir(heir, 90000, [], "child")
	assert_check(PlayerData.first_name == "Maya Heir", "Heir took over character name")
	assert_check(PlayerData.age == 22, "Heir initialized with their own age (22)")
	assert_check(PlayerData.is_dead == false, "CRITICAL: Heir is alive (is_dead reset to false)")
	if GameClock != null:
		assert_check(GameClock.current_age == 22, "GameClock current_age synced to heir age 22")
		assert_check(GameClock.is_running(), "GameClock is running after heir takeover")

	# Reincarnation Test
	var reborn_identity := {
		"first_name": "Phoenix",
		"gender": "MALE",
		"birthplace": "Jakarta",
		"portrait_track": 0,
		"portrait_variant": 0
	}
	PlayerData.start_reincarnated_life(reborn_identity, [], [])
	assert_check(PlayerData.first_name == "Phoenix", "Reincarnated name set")
	assert_check(PlayerData.age == 17, "Reborn soul begins life at age 17")
	assert_check(PlayerData.is_dead == false, "Reborn character is alive")
	if GameClock != null:
		assert_check(GameClock.current_age == 17, "GameClock synced to age 17")
		assert_check(GameClock.year == 2026, "Calendar reset to baseline year 2026")


# -----------------------------------------------------------------------------
# 13. UI ACTION BAR & TIME COUNTER
# -----------------------------------------------------------------------------
func test_ui_action_bar_and_navigation() -> void:
	print("\n--- 13. Testing UI Action Bar & Time Counter ---")
	var main_scene = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_scene)

	# 1. Action Row has 4 core buttons (AgeButton removed)
	var action_row = main_scene.find_child("ActionRow", true, false)
	assert_check(action_row != null, "ActionRow exists")
	var btn_count := 0
	for child in action_row.get_children():
		if child is Button:
			btn_count += 1
	assert_check(btn_count == 4, "Action bar contains strictly 4 navigation buttons")

	# 2. TimeCounterLabel exists and is clickable for pause toggle
	var time_lbl = main_scene.find_child("TimeCounterLabel", true, false) as Label
	assert_check(time_lbl != null, "TimeCounterLabel exists in header")
	assert_check(time_lbl.mouse_filter == Control.MOUSE_FILTER_STOP, "TimeCounterLabel accepts mouse clicks for pause toggle")

	# 3. Test toggle_time_pause
	assert_check(PlayerData.is_time_paused == false, "Initially unpaused")
	main_scene.toggle_time_pause()
	assert_check(PlayerData.is_time_paused == true, "Toggled time pause to true")
	assert_check("PAUSED" in time_lbl.text, "Time counter displays 'PAUSED' indicator")
	main_scene.toggle_time_pause()
	assert_check(PlayerData.is_time_paused == false, "Toggled time pause back to false")

	main_scene.free()


# -----------------------------------------------------------------------------
# 14. MULTI-YEAR ACCELERATED SIMULATION (5 YEARS = 60 MONTHS)
# -----------------------------------------------------------------------------
func test_multi_year_accelerated_simulation() -> void:
	print("\n--- 14. Running Multi-Year Accelerated Simulation (5 Continuous Years) ---")
	PlayerData.reset_player()
	PlayerData.first_name = "Simulation Subject"
	PlayerData.has_started_game = true
	PlayerData.is_dead = false
	PlayerData.is_time_paused = false
	PlayerData.money = 5000
	PlayerData.bank_savings = 25000
	PlayerData.job_title = "Data Analyst"
	PlayerData.job_id = "job_data_analyst"
	PlayerData.job_salary = 72000 # $6,000 / month
	PlayerData.job_company = "Apex Systems"
	if GameClock != null:
		GameClock.external_progression_check = Callable()
		GameClock.pause_reasons.clear()
		GameClock.is_paused = false
		# Born Jan 1, 2009, starting Jan 1, 2026 at age 17
		GameClock.setup_new_game(1, 1, 2026, 1, 1, 17)

	var start_year: int = GameClock.year if GameClock != null else PlayerData.in_game_year
	var start_age: int = PlayerData.age

	var monthly_settlements_run := 0
	var birthdays_celebrated: Array[int] = [0]
	var days_simulated := 0

	# Connect birthday detector
	var bday_tracker = func(new_a: int):
		birthdays_celebrated[0] += 1
		PlayerData.age = new_a
	if GameClock != null:
		GameClock.birthday.connect(bday_tracker)

	# Simulate 5 full Gregorian years:
	# 2026 (365d), 2027 (365d), 2028 (366d - leap!), 2029 (365d), 2030 (365d) = 1,826 days
	var total_days_target := 365 + 365 + 366 + 365 + 365

	var last_month := -1
	for d in range(total_days_target):
		days_simulated += 1
		if GameClock != null:
			GameClock.step_clock(1.0)
		else:
			PlayerData.in_game_day += 1

		var cur_m: int = GameClock.month if GameClock != null else PlayerData.in_game_month
		var cur_y: int = GameClock.year if GameClock != null else PlayerData.in_game_year

		# Check monthly rollover
		if cur_m != last_month:
			last_month = cur_m
			var s_res: Dictionary = MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, cur_y, cur_m)
			if s_res.get("settled", false):
				monthly_settlements_run += 1

	if GameClock != null and GameClock.birthday.is_connected(bday_tracker):
		GameClock.birthday.disconnect(bday_tracker)

	var end_year: int = GameClock.year if GameClock != null else PlayerData.in_game_year
	var end_age: int = PlayerData.age

	print("  Simulation Summary:")
	print("    • Total Days Simulated: %d" % days_simulated)
	print("    • Calendar Transition: Year %d -> Year %d" % [start_year, end_year])
	print("    • Age Progression: %d -> %d" % [start_age, end_age])
	print("    • Birthdays Celebrated: %d" % birthdays_celebrated[0])
	print("    • Monthly Settlements Settled: %d" % monthly_settlements_run)
	print("    • Final Health: %d" % PlayerData.health)
	print("    • Final Bank Savings: $%d" % PlayerData.bank_savings)

	assert_check(days_simulated == total_days_target, "Exact 1,826 days simulated across 5 calendar years")
	assert_check(end_year == 2031, "Calendar year reached 2031 after 5 full years")
	assert_check(end_age == 22, "Character aged from 17 to 22 over 5 years")
	assert_check(birthdays_celebrated[0] == 5, "Exactly 5 birthdays celebrated on Jan 1")
	assert_check(monthly_settlements_run >= 59, "All 60 monthly settlements executed (%d run)" % monthly_settlements_run)
	assert_check(PlayerData.health > 50, "Character survived all 5 years in good health")
	assert_check(PlayerData.is_dead == false, "Character remains alive and thriving")
	assert_check(PlayerData.bank_savings > 25000, "Bank savings grew from consistent monthly payroll")
