extends Node

const MonthlySettlementCoordinator = preload("res://scripts/economy/monthly_settlement_coordinator.gd")
const AssetCatalog = preload("res://scripts/economy/asset_catalog.gd")
const RentalManager = preload("res://scripts/economy/rental_manager.gd")
const MortgageManager = preload("res://scripts/economy/mortgage_manager.gd")
const TaxSystem = preload("res://scripts/economy/tax_system.gd")

var total_assertions: int = 0
var passed_assertions: int = 0


func _ready() -> void:
	print("=======================================================")
	print("🧪 RUNNING STAGE 3 MONTHLY SETTLEMENT TEST SUITE")
	print("=======================================================")

	test_payroll_and_unemployment()
	test_tax_withholding_progressive()
	test_property_maintenance_and_nonexistent_assets()
	test_recurring_expenses_rent_mortgages_subscriptions()
	test_insufficient_funds_and_debt_rollover()
	test_different_month_lengths_and_calendar_dates()
	test_idempotency_and_save_load()
	test_multi_month_catch_up()
	test_twelve_month_accounting_consistency_and_zero_drift()
	test_annual_fiscal_tax_reconciliation()

	print("\n=======================================================")
	print("🎉 ALL STAGE 3 TESTS PASSED (%d/%d assertions)!" % [passed_assertions, total_assertions])
	print("=======================================================")
	get_tree().quit(0)


func assert_true(cond: bool, msg: String) -> void:
	total_assertions += 1
	if not cond:
		push_error("Assertion FAILED: " + msg)
		assert(false, msg)
	passed_assertions += 1
	print("  ✓ " + msg)


# -----------------------------------------------------------------------------
# 1. PAYROLL & UNEMPLOYMENT
# -----------------------------------------------------------------------------
func test_payroll_and_unemployment() -> void:
	print("\n--- 1. Testing Payroll & Unemployment ---")
	PlayerData.reset_player()
	PlayerData.age = 25
	PlayerData.job_title = "Junior Software Engineer"
	PlayerData.job_company = "TechCorp"
	PlayerData.job_id = "swe_jr"
	PlayerData.job_salary = 60000
	PlayerData.bank_savings = 1000
	PlayerData.money = 0

	# Employed payout: $60,000 / 12 = $5,000
	var res1 := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 1)
	assert_true(res1.get("settled", false), "Employed player month settled")
	# Bank savings: initial 1000 + 5000 salary + 2.5% interest on 1000 ($2) - taxes/living
	assert_true(PlayerData.cumulative_salary_paid_this_year == 5000, "Cumulative salary tracked $5,000")
	var has_sal_trans := false
	for t in PlayerData.transaction_history:
		if t.get("category") == MonthlySettlementCoordinator.CATEGORY_PAYROLL and t.get("amount") == 5000:
			has_sal_trans = true
			break
	assert_true(has_sal_trans, "Salary transaction recorded in transaction_history")

	# Unemployed player payout: must be $0
	PlayerData.job_title = ""
	PlayerData.job_id = ""
	PlayerData.job_salary = 0
	var cum_before := PlayerData.cumulative_salary_paid_this_year
	var res2 := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 2)
	assert_true(res2.get("settled", false), "Month 2 settled for unemployed player")
	assert_true(PlayerData.cumulative_salary_paid_this_year == cum_before, "No salary added to unemployed player")

	# Prison check: has job title/salary but is in prison -> $0 paid
	PlayerData.job_title = "Senior Architect"
	PlayerData.job_id = "arch_sr"
	PlayerData.job_salary = 120000
	PlayerData.is_in_prison = true
	var res3 := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 3)
	assert_true(res3.get("settled", false), "Month 3 settled for prisoner")
	assert_true(PlayerData.cumulative_salary_paid_this_year == cum_before, "No salary paid to player in prison")


# -----------------------------------------------------------------------------
# 2. PROGRESSIVE TAX WITHHOLDING
# -----------------------------------------------------------------------------
func test_tax_withholding_progressive() -> void:
	print("\n--- 2. Testing Progressive Tax Withholding ---")
	PlayerData.reset_player()
	PlayerData.owned_assets.clear()
	PlayerData.age = 28
	PlayerData.job_title = "Data Analyst"
	PlayerData.job_company = "Metrics Inc"
	PlayerData.job_id = "data_analyst"
	PlayerData.job_salary = 60000 # $5,000/mo
	PlayerData.money = 20000
	PlayerData.bank_savings = 0

	# Calculation verification:
	# Annualized gross: $60,000. Standard deduction: $12,000. Taxable: $48,000.
	# Tier 1 (10% on $35k) = $3,500. Tier 2 (15% on $13k) = $1,950. Total annual tax = $5,450.
	# Monthly tax withholding = round(5450 / 12) = $454.
	var with_info := TaxSystem.calculate_monthly_withholding(PlayerData)
	assert_true(not with_info.get("is_exempt", true), "Adult is not tax exempt")
	assert_true(int(with_info.get("monthly_income_tax", 0)) == 454, "Monthly income tax withholding is exactly $454")

	var withheld_before := PlayerData.taxes_withheld_this_year
	MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 1)
	assert_true(PlayerData.taxes_withheld_this_year == withheld_before + 454, "Taxes withheld increased by $454")

	# Minor (<18) exemption
	PlayerData.age = 15
	var minor_with := TaxSystem.calculate_monthly_withholding(PlayerData)
	assert_true(minor_with.get("is_exempt", false), "Minor is tax exempt")
	assert_true(int(minor_with.get("total_monthly_withholding", -1)) == 0, "Minor total withholding is $0")


# -----------------------------------------------------------------------------
# 3. PROPERTY MAINTENANCE & NONEXISTENT ASSETS
# -----------------------------------------------------------------------------
func test_property_maintenance_and_nonexistent_assets() -> void:
	print("\n--- 3. Testing Property Maintenance & Nonexistent Assets ---")
	PlayerData.reset_player()
	PlayerData.age = 30
	PlayerData.money = 50000
	PlayerData.bank_savings = 50000
	PlayerData.owned_assets.clear()

	# Empty assets: no maintenance charged
	var funds_before := PlayerData.get_available_funds()
	var logs_empty := AssetCatalog.process_monthly_assets(PlayerData, 1)
	assert_true(logs_empty.is_empty(), "No upkeep logs for empty portfolio")
	assert_true(PlayerData.get_available_funds() == funds_before, "No upkeep charged for nonexistent assets")

	# Add 1 property ($300,000) and 1 car ($30,000, annual upkeep $1,200)
	var prop := AssetCatalog.create_asset_instance("prop_starter_home")
	prop["current_value"] = 300000
	PlayerData.owned_assets.append(prop)

	# Property monthly maintenance = round(300000 * 0.02 / 12) = $500
	var prop_m := AssetCatalog.get_monthly_upkeep(prop)
	assert_true(prop_m == 500, "Property monthly maintenance is $500")

	# Settle month
	var funds_pre := PlayerData.get_available_funds()
	AssetCatalog.process_monthly_assets(PlayerData, 1)
	var funds_post := PlayerData.get_available_funds()
	assert_true(funds_pre - funds_post == 500, "Exactly $500 maintenance debited for owned property")

	# Minor protection (<18): family covers maintenance
	PlayerData.age = 16
	var funds_minor_pre := PlayerData.get_available_funds()
	AssetCatalog.process_monthly_assets(PlayerData, 2)
	assert_true(PlayerData.get_available_funds() == funds_minor_pre, "Minors not charged for property maintenance")


# -----------------------------------------------------------------------------
# 4. RECURRING EXPENSES (RENT, MORTGAGES, SUBSCRIPTIONS)
# -----------------------------------------------------------------------------
func test_recurring_expenses_rent_mortgages_subscriptions() -> void:
	print("\n--- 4. Testing Recurring Expenses (Rent, Mortgages, Subscriptions) ---")
	PlayerData.reset_player()
	PlayerData.age = 26
	PlayerData.money = 20000
	PlayerData.bank_savings = 20000

	# 1. Rental Lease: $550/mo
	var sign_res := RentalManager.sign_lease(PlayerData, "rent_micro_studio")
	assert_true(sign_res.get("success", false), "Signed rental lease")
	assert_true(RentalManager.has_active_lease(PlayerData), "Active lease confirmed")

	# 2. Gym membership: $300/yr -> $25/mo
	PlayerData.has_gym_membership = true
	PlayerData.gym_membership_annual_fee = 300

	# 3. University Tuition: $12,000/yr -> $1,000/mo
	PlayerData.education_level = "University Student"
	PlayerData.has_scholarship = false
	PlayerData.university_tuition = 12000

	var avail_before := PlayerData.get_available_funds()
	var res := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 1)
	assert_true(res.get("settled", false), "Month settled with active subscriptions")

	# Check that rent ($550), gym ($25), tuition ($1000), and living expenses ($250) were processed
	var has_rent := false
	var has_gym := false
	var has_tuition := false
	for t in PlayerData.transaction_history:
		var desc: String = str(t.get("description", ""))
		if "Rent" in desc: has_rent = true
		if "Gym" in desc: has_gym = true
		if "Tuition" in desc: has_tuition = true
	assert_true(has_rent, "Rent transaction logged")
	assert_true(has_gym, "Gym membership transaction logged")
	assert_true(has_tuition, "University tuition transaction logged")


# -----------------------------------------------------------------------------
# 5. INSUFFICIENT FUNDS & DEBT DEGRADATION
# -----------------------------------------------------------------------------
func test_insufficient_funds_and_debt_rollover() -> void:
	print("\n--- 5. Testing Insufficient Funds & Debt Degradation ---")
	PlayerData.reset_player()
	PlayerData.owned_assets.clear()
	PlayerData.age = 25
	PlayerData.money = 100
	PlayerData.bank_savings = 0
	PlayerData.debt = 0

	# Adult basic living expenses are $250. Player only has $100.
	# Shortfall ($150) should be added to debt, liquid funds emptied to 0.
	var res := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 1)
	assert_true(res.get("settled", false), "Settlement completed under financial distress")
	assert_true(PlayerData.money == 0, "Cash balance emptied to $0")
	assert_true(PlayerData.bank_savings == 0, "Savings balance emptied to $0")
	assert_true(PlayerData.debt == 150, "Unpaid shortfall ($150) cleanly rolled over into debt")


# -----------------------------------------------------------------------------
# 6. CALENDAR DATE DUE-DATE HANDLING ACROSS MONTH LENGTHS
# -----------------------------------------------------------------------------
func test_different_month_lengths_and_calendar_dates() -> void:
	print("\n--- 6. Testing Calendar Date Due Dates Across Month Lengths ---")
	# Clamping day 31:
	var jan_day := MonthlySettlementCoordinator.get_effective_due_day(2026, 1, 31)
	assert_true(jan_day == 31, "January (31 days) keeps due date on 31st")

	var feb_common := MonthlySettlementCoordinator.get_effective_due_day(2026, 2, 31)
	assert_true(feb_common == 28, "February 2026 (common year) clamps due date to 28th")

	var feb_leap := MonthlySettlementCoordinator.get_effective_due_day(2024, 2, 31)
	assert_true(feb_leap == 29, "February 2024 (leap year) clamps due date to 29th")

	var apr_day := MonthlySettlementCoordinator.get_effective_due_day(2026, 4, 31)
	assert_true(apr_day == 30, "April (30 days) clamps due date to 30th")

	var due_15 := MonthlySettlementCoordinator.get_effective_due_day(2026, 2, 15)
	assert_true(due_15 == 15, "Mid-month due date (15th) untouched in February")


# -----------------------------------------------------------------------------
# 7. IDEMPOTENCY & SAVE/LOAD RESILIENCE
# -----------------------------------------------------------------------------
func test_idempotency_and_save_load() -> void:
	print("\n--- 7. Testing Idempotency & Save/Load Resilience ---")
	PlayerData.reset_player()
	PlayerData.age = 24
	PlayerData.job_title = "Junior QA Engineer"
	PlayerData.job_company = "BugBusters"
	PlayerData.job_id = "qa_jr"
	PlayerData.job_salary = 48000 # $4,000/mo
	PlayerData.money = 5000
	PlayerData.bank_savings = 5000

	# 1. Settle month (2026, 1)
	var res1 := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 1)
	assert_true(res1.get("settled", false), "First settlement of 2026-1 succeeded")
	var savings_after_m1 := PlayerData.bank_savings

	# 2. Call again for same month: must be idempotent and rejected
	assert_true(MonthlySettlementCoordinator.is_month_settled(PlayerData, 2026, 1), "Month 2026-1 marked settled")
	var res1_dup := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 1)
	assert_true(not res1_dup.get("settled", true), "Duplicate settlement for 2026-1 rejected")
	assert_true(PlayerData.bank_savings == savings_after_m1, "Savings unchanged on duplicate call")

	# 3. Save to disk, reload, and verify idempotency is preserved
	var test_save_path := "user://test_stage3_idempotency.json"
	var save_mgr = preload("res://scripts/core/save_manager.gd").new()
	var saved := save_mgr.save_game(test_save_path)
	assert_true(saved, "Game state saved with monthly cursor")

	# Tamper in-memory savings to verify restore
	PlayerData.bank_savings = 999999
	var loaded := save_mgr.load_game(test_save_path)
	assert_true(loaded, "Game state restored from disk")
	assert_true(PlayerData.bank_savings == savings_after_m1, "Bank savings restored accurately")
	assert_true(MonthlySettlementCoordinator.is_month_settled(PlayerData, 2026, 1), "Cursor restored from disk")

	# Re-attempt month 1 settlement on loaded state: must still be blocked!
	var res_after_load := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 1)
	assert_true(not res_after_load.get("settled", true), "Loaded save prevents double-paying current month")

	# Advancing to Month 2 succeeds cleanly
	var res2 := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 2)
	assert_true(res2.get("settled", false), "Month 2 settled cleanly after save reload")

	# Clean up test save file
	DirAccess.remove_absolute(ProjectSettings.globalize_path(test_save_path))


# -----------------------------------------------------------------------------
# 8. MULTI-MONTH CATCH-UP PIPELINE
# -----------------------------------------------------------------------------
func test_multi_month_catch_up() -> void:
	print("\n--- 8. Testing Multi-Month Catch-Up Pipeline ---")
	PlayerData.reset_player()
	PlayerData.age = 22
	PlayerData.job_title = "Junior Designer"
	PlayerData.job_company = "Pixel Studio"
	PlayerData.job_id = "designer_jr"
	PlayerData.job_salary = 36000 # $3,000/mo
	PlayerData.bank_savings = 10000
	PlayerData.money = 0

	# Process Jan 2026
	MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, 1)

	# Simulate large frame delay / time skip to May 2026 (Month 5)
	# Catch up pipeline should process Feb (2), Mar (3), Apr (4), May (5)
	var caught_up := MonthlySettlementCoordinator.catch_up_settlements(PlayerData, 2026, 5)
	assert_true(caught_up.size() == 4, "Caught up exactly 4 elapsed months (Feb, Mar, Apr, May)")
	assert_true(MonthlySettlementCoordinator.is_month_settled(PlayerData, 2026, 5), "Cursor advanced to May 2026")
	assert_true(PlayerData.cumulative_salary_paid_this_year == 15000, "5 months of salary paid ($15,000 total)")


# -----------------------------------------------------------------------------
# 9. 12-MONTH ACCOUNTING CONSISTENCY & ZERO DRIFT
# -----------------------------------------------------------------------------
func test_twelve_month_accounting_consistency_and_zero_drift() -> void:
	print("\n--- 9. Testing 12-Month Accounting Consistency & Zero Currency Drift ---")
	PlayerData.reset_player()
	PlayerData.age = 28
	# $65,000 is intentionally NOT divisible by 12: 5416.666...
	PlayerData.job_title = "Lead Product Manager"
	PlayerData.job_company = "Tech Giant"
	PlayerData.job_id = "pm_lead"
	PlayerData.job_salary = 65000
	PlayerData.money = 100000
	PlayerData.bank_savings = 100000
	PlayerData.owned_assets.clear()

	# Owned house with $100,000 value (2% annual maintenance = $2,000/yr: 166.666.../mo)
	var house := AssetCatalog.create_asset_instance("prop_starter_home")
	house["current_value"] = 100000
	PlayerData.owned_assets.append(house)

	var initial_cumulative_sal := PlayerData.cumulative_salary_paid_this_year
	var initial_funds := PlayerData.get_available_funds()

	# Simulate entire 12-month calendar year
	for m in range(1, 13):
		var res := MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, m)
		assert_true(res.get("settled", false), "Month %d settled" % m)

	# 1. Total salary paid across 12 months must equal $65,000 EXACTLY
	assert_true(PlayerData.cumulative_salary_paid_this_year == 65000, "12-month salary total matches exact $65,000 (Zero Drift)")

	# 2. Total maintenance for the house across 12 months must equal $2,000 EXACTLY
	# Test via AssetCatalog 12-month cycle directly
	PlayerData.owned_assets.clear()
	PlayerData.owned_assets.append(house)
	var house_funds_before := PlayerData.money + PlayerData.bank_savings
	for m in range(1, 13):
		AssetCatalog.process_monthly_assets(PlayerData, m)
	var house_funds_after := PlayerData.money + PlayerData.bank_savings
	var total_maint_paid := house_funds_before - house_funds_after
	assert_true(total_maint_paid == 2000, "12-month property upkeep matches exact $2,000 (Zero Drift)")


# -----------------------------------------------------------------------------
# 10. ANNUAL FISCAL TAX RECONCILIATION
# -----------------------------------------------------------------------------
func test_annual_fiscal_tax_reconciliation() -> void:
	print("\n--- 10. Testing Annual Fiscal Tax Reconciliation ---")
	PlayerData.reset_player()
	PlayerData.age = 29
	PlayerData.job_title = "Software Engineer"
	PlayerData.job_company = "CodeCrafters"
	PlayerData.job_id = "swe"
	PlayerData.job_salary = 60000
	PlayerData.money = 50000
	PlayerData.bank_savings = 50000

	# Run 12 months of withholdings ($454 * 12 = $5,448 withheld)
	for m in range(1, 13):
		MonthlySettlementCoordinator.process_monthly_settlement(PlayerData, 2026, m)

	assert_true(PlayerData.taxes_withheld_this_year > 5000, "Withheld taxes across 12 months")

	# Reconcile annual return
	var recon := MonthlySettlementCoordinator.reconcile_annual_taxes(PlayerData)
	assert_true(recon.get("reconciled", false), "Annual reconciliation completed")
	assert_true(PlayerData.taxes_withheld_this_year == 0, "Taxes withheld accumulator reset for new fiscal year")
	assert_true(PlayerData.cumulative_salary_paid_this_year == 0, "Cumulative salary counter reset for new fiscal year")
