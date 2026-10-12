extends Node

# =============================================================================
# LIFE.EXE — DAILY WAGE & GIG EMPLOYMENT TEST SUITE
# =============================================================================

const DailyJobsCatalogScript = preload("res://scripts/economy/daily_jobs_catalog.gd")
const DailyWageManagerScript = preload("res://scripts/economy/daily_wage_manager.gd")
const GigManagerScript       = preload("res://scripts/economy/gig_manager.gd")
const MonthlySettlementCoordinator = preload("res://scripts/economy/monthly_settlement_coordinator.gd")
const TaxSystem              = preload("res://scripts/economy/tax_system.gd")

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
	print("🧪 RUNNING LIFE.EXE DAILY WAGE & GIG EMPLOYMENT TESTS")
	print("=======================================================")

	test_daily_jobs_catalog()
	test_age_restrictions_and_eligibility()
	test_daily_wage_processing_and_schedules()
	test_daily_job_stat_losses_are_gradual()
	test_missed_shifts_illness_and_incarceration()
	test_idempotency_and_multi_day_catchup()
	test_gig_system_and_capacity_limits()
	test_gig_reputation_and_progression()
	test_employment_compatibility()
	test_tax_withholding_and_annual_reconciliation()
	test_save_load_persistence()

	print("\n=======================================================")
	print("🎉 ALL DAILY WAGE & GIG TESTS PASSED (%d/%d assertions)!" % [passed_assertions, total_assertions])
	print("=======================================================")
	get_tree().quit(0)


# =============================================================================
# 1. CATALOG INTEGRITY & DEFINITIONS
# =============================================================================
func test_daily_jobs_catalog() -> void:
	print("\n--- 1. Testing Daily Jobs Catalog Integrity ---")
	var all_jobs := DailyJobsCatalogScript.get_all_jobs()
	assert_check(all_jobs.size() == 23, "Catalog contains exactly 23 required jobs (Found: %d)" % all_jobs.size())

	# Check categories
	var cats := DailyJobsCatalogScript.CATEGORIES
	assert_check(cats.size() == 4, "Catalog has 4 employment categories")

	var entry_jobs := DailyJobsCatalogScript.get_jobs_by_category(DailyJobsCatalogScript.CATEGORY_ENTRY)
	var manual_jobs := DailyJobsCatalogScript.get_jobs_by_category(DailyJobsCatalogScript.CATEGORY_MANUAL)
	var gig_jobs := DailyJobsCatalogScript.get_jobs_by_category(DailyJobsCatalogScript.CATEGORY_GIG)
	var skilled_jobs := DailyJobsCatalogScript.get_jobs_by_category(DailyJobsCatalogScript.CATEGORY_SKILLED)

	assert_check(entry_jobs.size() == 6, "Entry-level jobs count is 6 (Found: %d)" % entry_jobs.size())
	assert_check(manual_jobs.size() == 5, "Manual labor jobs count is 5 (Found: %d)" % manual_jobs.size())
	assert_check(gig_jobs.size() == 7, "Gig work assignments count is 7 (Found: %d)" % gig_jobs.size())
	assert_check(skilled_jobs.size() == 5, "Skilled daily jobs count is 5 (Found: %d)" % skilled_jobs.size())

	# Verify every job definition has required metadata
	for j in all_jobs:
		var j_id: String = str(j.get("id", ""))
		assert_check(j.has("title") and j.has("payment_type") and j.has("min_age"), "Job '%s' has basic fields" % j_id)
		assert_check(j.has("daily_wage") and int(j.get("daily_wage")) > 0, "Job '%s' has positive pay" % j_id)
		assert_check(j.has("workdays") and (j.workdays is Array), "Job '%s' has workdays schedule" % j_id)
		assert_check(j.has("stat_effects"), "Job '%s' has stat effects configuration" % j_id)

	# Verify day of week calculation: Jan 1, 2026 was a Thursday (ISO day 4)
	var dow := DailyJobsCatalogScript.calculate_day_of_week(2026, 1, 1)
	assert_check(dow == 4, "Jan 1, 2026 is ISO day 4 (Thursday)")
	assert_check(DailyJobsCatalogScript.get_day_name(4) == "Thursday", "Day 4 name is Thursday")


# =============================================================================
# 2. AGE RESTRICTIONS & ELIGIBILITY GATES
# =============================================================================
func test_age_restrictions_and_eligibility() -> void:
	print("\n--- 2. Testing Age Restrictions & Eligibility Gates ---")
	PlayerData.reset_player()
	PlayerData.age = 12
	PlayerData.health = 80
	PlayerData.smarts = 60
	PlayerData.looks = 50
	PlayerData.happiness = 70

	# 12-year-olds: Car washer is allowed (min_age 12)
	var car_wash := DailyJobsCatalogScript.get_job_by_id("car_washer")
	var check_cw := DailyJobsCatalogScript.can_apply(car_wash, PlayerData)
	assert_check(bool(check_cw.get("allowed", false)), "12yo can apply for light Car Washer job")

	# 12-year-olds: Warehouse worker is prohibited (hazardous labor, min_age 18)
	var warehouse := DailyJobsCatalogScript.get_job_by_id("warehouse_worker")
	var check_wh := DailyJobsCatalogScript.can_apply(warehouse, PlayerData)
	assert_check(not bool(check_wh.get("allowed", true)), "12yo CANNOT apply for hazardous Warehouse Worker")

	# 12-year-olds: Electrician is prohibited (requires trade/18+)
	var electrician := DailyJobsCatalogScript.get_job_by_id("electrician")
	var check_el := DailyJobsCatalogScript.can_apply(electrician, PlayerData)
	assert_check(not bool(check_el.get("allowed", true)), "12yo CANNOT apply for licensed Electrician")

	# Age 14: Café Assistant allowed (min_age 14)
	PlayerData.age = 14
	var cafe := DailyJobsCatalogScript.get_job_by_id("cafe_assistant")
	var check_cafe := DailyJobsCatalogScript.can_apply(cafe, PlayerData)
	assert_check(bool(check_cafe.get("allowed", false)), "14yo can apply for Café Assistant")

	# Age 14: Restaurant server is prohibited (min_age 16)
	var server := DailyJobsCatalogScript.get_job_by_id("restaurant_server")
	var check_server := DailyJobsCatalogScript.can_apply(server, PlayerData)
	assert_check(not bool(check_server.get("allowed", true)), "14yo CANNOT apply for Restaurant Server (requires 16)")

	# Age 16: Restaurant server allowed
	PlayerData.age = 16
	var check_server16 := DailyJobsCatalogScript.can_apply(server, PlayerData)
	assert_check(bool(check_server16.get("allowed", false)), "16yo can apply for Restaurant Server")

	# Age 18: Hazardous manual labor and trades unlocked
	PlayerData.age = 18
	var check_wh18 := DailyJobsCatalogScript.can_apply(warehouse, PlayerData)
	assert_check(bool(check_wh18.get("allowed", false)), "18yo can apply for Warehouse Worker")


# =============================================================================
# 3. DAILY WAGE PROCESSING & WORK SCHEDULES
# =============================================================================
func test_daily_wage_processing_and_schedules() -> void:
	print("\n--- 3. Testing Daily Wage Processing & Schedules ---")
	PlayerData.reset_player()
	PlayerData.age = 20
	PlayerData.money = 100
	PlayerData.health = 90
	PlayerData.happiness = 70
	PlayerData.daily_wage_last_paid = {"year": 0, "month": 0, "day": 0}

	# Assign Café Assistant: $85/day, workdays [1, 2, 3, 4, 5] (Mon-Fri)
	var cafe_def := DailyJobsCatalogScript.get_job_by_id("cafe_assistant")
	PlayerData.job_id = "cafe_assistant"
	PlayerData.job_title = "Café Assistant"
	PlayerData.job_company = "Bean & Brew"
	PlayerData.job_payment_type = DailyJobsCatalogScript.PAYMENT_TYPE_DAILY_WAGE

	# Jan 3, 2026 is Saturday (ISO 6) -> Scheduled Day Off
	var dow_sat := DailyJobsCatalogScript.calculate_day_of_week(2026, 1, 3)
	assert_check(dow_sat == 6, "Jan 3, 2026 is Saturday")

	var res_sat := DailyWageManagerScript.process_daily_wages(PlayerData, 2026, 1, 3)
	assert_check(bool(res_sat.get("processed", false)), "Day 3 processed")
	assert_check(int(res_sat.get("total_net", -1)) == 0, "No wage paid on scheduled Saturday off ($0)")
	assert_check(PlayerData.money == 100, "Money unchanged on day off")

	# Reset last paid so we can test Monday
	PlayerData.daily_wage_last_paid = {"year": 0, "month": 0, "day": 0}

	# Jan 5, 2026 is Monday (ISO 1) -> Scheduled Workday
	var dow_mon := DailyJobsCatalogScript.calculate_day_of_week(2026, 1, 5)
	assert_check(dow_mon == 1, "Jan 5, 2026 is Monday")

	var money_before := PlayerData.money
	var res_mon := DailyWageManagerScript.process_daily_wages(PlayerData, 2026, 1, 5)
	assert_check(bool(res_mon.get("processed", false)), "Day 5 processed")
	var net_earned: int = int(res_mon.get("total_net", 0))
	assert_check(net_earned > 0, "Wage paid on scheduled Monday (Earned net: $%d)" % net_earned)
	assert_check(PlayerData.money == money_before + net_earned, "Wallet updated with net wage")
	assert_check(PlayerData.daily_wage_earnings_this_year == 85, "Annual gross wage tracked ($85)")
	assert_check(PlayerData.daily_earnings_log.size() == 1, "Daily earnings logged")
	assert_check(PlayerData.transaction_history.size() == 1, "Transaction recorded in ledger")


func test_daily_job_stat_losses_are_gradual() -> void:
	print("\n--- Testing daily job stat losses are gradual ---")
	PlayerData.reset_player()
	PlayerData.age = 20
	PlayerData.health = 90
	PlayerData.mental_state = 80
	PlayerData.job_id = "restaurant_server"
	PlayerData.job_title = "Restaurant Server"
	PlayerData.job_company = "Test Bistro"
	PlayerData.job_payment_type = DailyJobsCatalogScript.PAYMENT_TYPE_DAILY_WAGE

	# Twenty scheduled weekday shifts should apply only the accumulated 5% of
	# catalog per-shift health and mental-state penalties.
	for day in range(5, 31):
		DailyWageManagerScript.process_daily_wages(PlayerData, 2026, 1, day)

	assert_check(PlayerData.health == 88, "Twenty restaurant shifts reduce health by 2, not 40 (actual: %d)" % PlayerData.health)
	assert_check(PlayerData.mental_state == 79, "Twenty restaurant shifts reduce mental state by 1, not 20 (actual: %d)" % PlayerData.mental_state)


# =============================================================================
# 4. MISSED SHIFTS (ILLNESS & INCARCERATION)
# =============================================================================
func test_missed_shifts_illness_and_incarceration() -> void:
	print("\n--- 4. Testing Missed Shifts (Illness & Incarceration) ---")
	PlayerData.reset_player()
	PlayerData.age = 22
	PlayerData.money = 200
	PlayerData.job_id = "cafe_assistant"
	PlayerData.job_title = "Café Assistant"
	PlayerData.job_company = "Bean & Brew"
	PlayerData.job_payment_type = DailyJobsCatalogScript.PAYMENT_TYPE_DAILY_WAGE

	# Case A: Too sick (Health <= 15) on Monday Jan 5, 2026
	PlayerData.health = 10
	PlayerData.daily_wage_last_paid = {"year": 0, "month": 0, "day": 0}

	var res_ill := DailyWageManagerScript.process_daily_wages(PlayerData, 2026, 1, 5)
	assert_check(int(res_ill.get("total_net", -1)) == 0, "Sick worker earns $0 for missed shift")
	assert_check(res_ill.get("missed_shifts", []).size() == 1, "Illness missed shift recorded")
	assert_check(PlayerData.money == 200, "Money unchanged when shift is missed")

	# Case B: Incarcerated (is_in_prison = true)
	PlayerData.health = 100
	PlayerData.is_in_prison = true
	PlayerData.daily_wage_last_paid = {"year": 0, "month": 0, "day": 0}

	var res_prison := DailyWageManagerScript.process_daily_wages(PlayerData, 2026, 1, 5)
	assert_check(int(res_prison.get("total_net", -1)) == 0, "Incarcerated worker earns $0 for missed shift")
	assert_check(res_prison.get("missed_shifts", []).size() == 1, "Prison missed shift recorded")


# =============================================================================
# 5. IDEMPOTENCY & MULTI-DAY CATCH-UP
# =============================================================================
func test_idempotency_and_multi_day_catchup() -> void:
	print("\n--- 5. Testing Idempotency & Multi-Day Catch-Up ---")
	PlayerData.reset_player()
	PlayerData.age = 25
	PlayerData.money = 0
	PlayerData.job_id = "warehouse_worker"
	PlayerData.job_title = "Warehouse Worker"
	PlayerData.job_company = "Apex Logistics"
	PlayerData.job_payment_type = DailyJobsCatalogScript.PAYMENT_TYPE_DAILY_WAGE

	# 1. Process Jan 5, 2026 (Monday, $120/day)
	var res1 := DailyWageManagerScript.process_daily_wages(PlayerData, 2026, 1, 5)
	assert_check(bool(res1.get("processed", false)), "Day 5 processed first time")
	var money_after_1 := PlayerData.money
	assert_check(money_after_1 > 0, "Money credited on Day 5")

	# 2. Attempt duplicate call for same date
	var res2 := DailyWageManagerScript.process_daily_wages(PlayerData, 2026, 1, 5)
	assert_check(not bool(res2.get("processed", true)), "Duplicate day payment REJECTED (Idempotency)")
	assert_check(PlayerData.money == money_after_1, "Money unchanged after duplicate call")

	# 3. Catch up over multiple elapsed days: Jan 6 to Jan 9 (Tue, Wed, Thu, Fri = 4 workdays)
	# Current last_paid is Jan 5, 2026
	var res_catchup := DailyWageManagerScript.process_catch_up(PlayerData, 2026, 1, 9)
	assert_check(bool(res_catchup.get("processed", false)), "Catch-up processed successfully")
	assert_check(int(res_catchup.get("days_processed", 0)) == 4, "Processed exactly 4 intervening days (Found: %d)" % int(res_catchup.get("days_processed", 0)))
	assert_check(PlayerData.daily_wage_last_paid.day == 9, "Last paid cursor updated to Day 9")


# =============================================================================
# 6. GIG SYSTEM & MONTHLY CAPACITY LIMITS
# =============================================================================
func test_gig_system_and_capacity_limits() -> void:
	print("\n--- 6. Testing Gig System & Monthly Capacity Limits ---")
	PlayerData.reset_player()
	PlayerData.age = 18
	PlayerData.money = 0
	PlayerData.health = 90
	PlayerData.smarts = 80
	PlayerData.in_game_year = 2026
	PlayerData.in_game_month = 1
	PlayerData.in_game_day = 1

	# Every player has one shared allowance of four on-demand gigs per month.
	assert_check(GigManagerScript.get_monthly_capacity(PlayerData) == 4, "Monthly gig capacity is 4")
	assert_check(GigManagerScript.get_remaining_capacity(PlayerData) == 4, "Remaining monthly gig capacity is 4")

	var gigs := GigManagerScript.generate_available_gigs(PlayerData)
	assert_check(gigs.size() > 0, "Available gigs generated")
	var gig_sample: Dictionary = gigs[0]

	# Complete Gig 1
	var comp1 := GigManagerScript.complete_gig(PlayerData, gig_sample)
	assert_check(bool(comp1.get("success", false)), "Gig 1 completed successfully")
	assert_check(PlayerData.gigs_completed_this_month == 1, "Gigs completed this month is 1")
	assert_check(GigManagerScript.get_remaining_capacity(PlayerData) == 3, "Remaining monthly capacity is 3")

	# Complete Gig 2
	var comp2 := GigManagerScript.complete_gig(PlayerData, gig_sample)
	assert_check(bool(comp2.get("success", false)), "Gig 2 completed successfully")
	assert_check(PlayerData.gigs_completed_this_month == 2, "Gigs completed this month is 2")

	# Complete Gig 3
	var comp3 := GigManagerScript.complete_gig(PlayerData, gig_sample)
	assert_check(bool(comp3.get("success", false)), "Gig 3 completed successfully")
	assert_check(PlayerData.gigs_completed_this_month == 3, "Gigs completed this month is 3")

	# Complete Gig 4
	var comp4 := GigManagerScript.complete_gig(PlayerData, gig_sample)
	assert_check(bool(comp4.get("success", false)), "Gig 4 completed successfully")
	assert_check(PlayerData.gigs_completed_this_month == 4, "Gigs completed this month is 4")
	assert_check(GigManagerScript.get_remaining_capacity(PlayerData) == 0, "Remaining monthly capacity is 0")

	# Attempt Gig 5 (shared monthly limit reached)
	var comp5 := GigManagerScript.complete_gig(PlayerData, gig_sample)
	assert_check(not bool(comp5.get("success", true)), "Gig 5 REJECTED: Monthly capacity limit reached")

	# Employment status does not change the shared monthly pool.
	PlayerData.assign_part_time_job(DailyJobsCatalogScript.get_job_by_id("cafe_assistant"))
	assert_check(GigManagerScript.get_monthly_capacity(PlayerData) == 4, "Part-time worker monthly gig capacity remains 4")

	# Full-time and part-time employment together still leave four gig slots.
	PlayerData.quit_part_time_job()
	PlayerData.job_title = "Accountant"
	assert_check(GigManagerScript.get_monthly_capacity(PlayerData) == 4, "Full-time worker monthly gig capacity remains 4")

	# Dual employment must not produce the old 0/0 state.
	PlayerData.assign_part_time_job(DailyJobsCatalogScript.get_job_by_id("cafe_assistant"))
	assert_check(GigManagerScript.get_monthly_capacity(PlayerData) == 4, "Dual-employed monthly gig capacity remains 4")

	# A new calendar month restores the shared pool.
	PlayerData.in_game_month = 2
	assert_check(GigManagerScript.get_remaining_capacity(PlayerData) == 4, "Monthly gig capacity resets to 4 next month")


# =============================================================================
# 7. GIG REPUTATION & PROGRESSION
# =============================================================================
func test_gig_reputation_and_progression() -> void:
	print("\n--- 7. Testing Gig Reputation & Progression ---")
	PlayerData.reset_player()
	PlayerData.age = 20

	# 0 points -> Novice tier, 1.0x multiplier
	var tier0 := GigManagerScript.get_reputation_tier(0)
	assert_check(tier0.title == "Novice", "0 pts is Novice tier")
	assert_check(tier0.pay_mult == 1.0, "Novice pay multiplier is 1.0")

	# 35 points -> Experienced tier, 1.15x multiplier
	var tier35 := GigManagerScript.get_reputation_tier(35)
	assert_check(tier35.title == "Experienced", "35 pts is Experienced tier")
	assert_check(tier35.pay_mult == 1.15, "Experienced pay multiplier is 1.15")

	# 80 points -> Specialist tier, 1.30x multiplier
	var tier80 := GigManagerScript.get_reputation_tier(80)
	assert_check(tier80.title == "Specialist", "80 pts is Specialist tier")
	assert_check(tier80.pay_mult == 1.30, "Specialist pay multiplier is 1.30")

	# 160 points -> Master Freelancer tier, 1.50x multiplier
	var tier160 := GigManagerScript.get_reputation_tier(160)
	assert_check(tier160.title == "Master Freelancer", "160 pts is Master Freelancer tier")
	assert_check(tier160.pay_mult == 1.50, "Master Freelancer pay multiplier is 1.50")

	# Add reputation points to PlayerData
	GigManagerScript.add_reputation(PlayerData, "freelance_writer", 40)
	assert_check(GigManagerScript.get_reputation_points(PlayerData, "freelance_writer") == 40, "Reputation points updated on player")


# =============================================================================
# 8. EMPLOYMENT COMPATIBILITY (PRIMARY + PART-TIME)
# =============================================================================
func test_employment_compatibility() -> void:
	print("\n--- 8. Testing Employment Compatibility ---")
	PlayerData.reset_player()
	PlayerData.age = 24
	PlayerData.health = 90
	PlayerData.smarts = 75

	# 1. Unemployed player takes a primary full-time job
	PlayerData.job_id = "swe_jr"
	PlayerData.job_title = "Junior Software Engineer"
	PlayerData.job_salary = 60000
	PlayerData.job_payment_type = DailyJobsCatalogScript.PAYMENT_TYPE_MONTHLY_SALARY

	# 2. Cannot take another full-time job without resigning
	var construction := DailyJobsCatalogScript.get_job_by_id("construction_helper") # full_time
	var can_take_ft2 := DailyJobsCatalogScript.can_apply(construction, PlayerData)
	assert_check(not bool(can_take_ft2.get("allowed", true)), "Cannot hold 2 simultaneous full-time jobs")

	# 3. CAN take a compatible part-time job
	var cafe_pt := DailyJobsCatalogScript.get_job_by_id("cafe_assistant") # part_time
	var can_take_pt := DailyJobsCatalogScript.can_apply(cafe_pt, PlayerData)
	assert_check(bool(can_take_pt.get("allowed", false)), "Can take compatible part-time job alongside full-time career")

	PlayerData.assign_part_time_job(cafe_pt, "Downtown Beans")
	assert_check(PlayerData.has_part_time_job(), "Player has part-time job")
	assert_check(PlayerData.get_part_time_job().company == "Downtown Beans", "Part-time job company set")

	# 4. Quitting part-time job keeps primary intact
	PlayerData.quit_part_time_job()
	assert_check(not PlayerData.has_part_time_job(), "Part-time job cleared")
	assert_check(PlayerData.job_title == "Junior Software Engineer", "Primary job remains intact")


# =============================================================================
# 9. TAX INTEGRATION & RECONCILIATION
# =============================================================================
func test_tax_withholding_and_annual_reconciliation() -> void:
	print("\n--- 9. Testing Tax Withholding & Annual Tax Reconciliation ---")
	PlayerData.reset_player()
	PlayerData.age = 25
	PlayerData.money = 0
	PlayerData.bank_savings = 5000
	PlayerData.job_title = "Junior Software Engineer"
	PlayerData.job_salary = 60000
	PlayerData.job_payment_type = DailyJobsCatalogScript.PAYMENT_TYPE_MONTHLY_SALARY

	# Earn some daily wages and gig money
	PlayerData.daily_wage_earnings_this_year = 4000
	PlayerData.taxable_daily_wages_this_year = 4000
	PlayerData.taxes_withheld_this_year = 600
	PlayerData.gig_earnings_this_year = 2000

	# Process monthly settlement (Month 1)
	# Monthly settlement should pay salaried job ($5000 gross) and NOT double-pay daily wages
	var res_monthly := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 1)
	assert_check(bool(res_monthly.get("settled", false)), "Monthly settlement processed")

	# Annual tax return calculation
	var ret_calc := TaxSystem.calculate_tax_return(PlayerData)
	var inc_tax: Dictionary = ret_calc.get("income_tax", {})
	var gross_inc: int = int(inc_tax.get("gross_income", 0))

	# Gross personal income should include job salary + daily wages + gig earnings
	# Salary 60,000 + Daily 4,000 + Gig 2,000 = 66,000
	assert_check(gross_inc == 66000, "Gross personal income includes salary + daily wages + gigs ($66,000, Found: $%d)" % gross_inc)

	# Taxes withheld should credit the $600 from daily/gig work + monthly payroll withholding
	var total_withheld: int = int(PlayerData.taxes_withheld_this_year)
	assert_check(total_withheld >= 600, "Total taxes withheld credits daily/gig withholdings (Withheld: $%d)" % total_withheld)

	# Reconcile annual taxes (Month 12)
	TaxSystem.reconcile_annual_taxes(PlayerData)
	assert_check(PlayerData.daily_wage_earnings_this_year == 0, "Annual daily wage earnings reset after reconciliation")
	assert_check(PlayerData.gig_earnings_this_year == 0, "Annual gig earnings reset after reconciliation")


# =============================================================================
# 10. SAVE / LOAD PERSISTENCE
# =============================================================================
func test_save_load_persistence() -> void:
	print("\n--- 10. Testing Save/Load Persistence ---")
	PlayerData.reset_player()
	PlayerData.age = 28
	PlayerData.job_id = "warehouse_worker"
	PlayerData.job_title = "Warehouse Worker"
	PlayerData.job_payment_type = DailyJobsCatalogScript.PAYMENT_TYPE_DAILY_WAGE
	PlayerData.part_time_job = {
		"id": "cleaner",
		"title": "Cleaner",
		"company": "Sparkle Corp",
		"daily_wage": 75,
		"payment_type": DailyJobsCatalogScript.PAYMENT_TYPE_DAILY_WAGE
	}
	PlayerData.daily_wage_last_paid = {"year": 2026, "month": 3, "day": 15}
	PlayerData.daily_wage_earnings_this_year = 3200
	PlayerData.taxable_daily_wages_this_year = 3200
	PlayerData.daily_job_health_loss_fraction = 0.35
	PlayerData.daily_job_mental_loss_fraction = 0.65
	PlayerData.gig_earnings_this_year = 850
	PlayerData.gigs_completed_today = 2
	PlayerData.gigs_completed_this_month = 2
	PlayerData.last_gig_date = {"year": 2026, "month": 3, "day": 15}
	PlayerData.last_gig_month = {"year": 2026, "month": 3}
	PlayerData.gig_reputation = {"food_delivery_rider": 45, "freelance_writer": 80}
	PlayerData.gig_history = [{"title": "Gourmet Delivery", "net_pay": 45}]
	PlayerData.daily_earnings_log = [{"job_title": "Warehouse Worker", "net_pay": 110}]

	# Capture save state
	var saved_dict := SaveManager.capture_data()

	# Reset player data completely
	PlayerData.reset_player()
	assert_check(PlayerData.job_payment_type == "MONTHLY_SALARY", "Job payment type reset")
	assert_check(not PlayerData.has_part_time_job(), "Part-time job reset")
	assert_check(PlayerData.daily_wage_earnings_this_year == 0, "Earnings reset")

	# Restore save state
	SaveManager.apply_data(saved_dict)
	assert_check(PlayerData.job_payment_type == DailyJobsCatalogScript.PAYMENT_TYPE_DAILY_WAGE, "Restored job payment type")
	assert_check(PlayerData.has_part_time_job(), "Restored part-time job exists")
	assert_check(PlayerData.part_time_job.title == "Cleaner", "Restored part-time job title is Cleaner")
	assert_check(PlayerData.daily_wage_last_paid.day == 15, "Restored daily wage last paid day is 15")
	assert_check(PlayerData.daily_wage_earnings_this_year == 3200, "Restored daily wage earnings ($3,200)")
	assert_check(is_equal_approx(PlayerData.daily_job_health_loss_fraction, 0.35), "Restored fractional daily health loss progress")
	assert_check(is_equal_approx(PlayerData.daily_job_mental_loss_fraction, 0.65), "Restored fractional daily mental loss progress")
	assert_check(PlayerData.gig_earnings_this_year == 850, "Restored gig earnings ($850)")
	assert_check(PlayerData.gigs_completed_today == 2, "Restored gigs completed today is 2")
	assert_check(PlayerData.gigs_completed_this_month == 2, "Restored gigs completed this month is 2")
	assert_check(PlayerData.gig_reputation.get("freelance_writer") == 80, "Restored gig reputation")
	assert_check(PlayerData.gig_history.size() == 1, "Restored gig history")
	assert_check(PlayerData.daily_earnings_log.size() == 1, "Restored daily earnings log")
