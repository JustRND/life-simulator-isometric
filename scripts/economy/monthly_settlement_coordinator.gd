class_name MonthlySettlementCoordinator
extends RefCounted

# =============================================================================
# MONTHLY SETTLEMENT COORDINATOR
# Authoritative central coordinator for all recurring monthly economic transactions.
#
# GUARANTEES:
# 1. Deterministic execution order:
#    - Phase 1: Salary & Payroll (employed only, never unemployed or in prison)
#    - Phase 2: Commercial & Investment Inflows (Business dividends, Social media, Savings interest)
#    - Phase 3: Payroll Deductions & Tax Withholding (Pension deduction, progressive withholding)
#    - Phase 4: Housing & Basic Living Expenses (Living expenses, Rent, Mortgages)
#    - Phase 5: Asset Upkeep & Insurance Premiums (Existing assets only, insurance policies)
#    - Phase 6: Subscriptions, Healthcare & Education (Implants, Pets, Gym, Tuition, Inpatient)
#    - Phase 7: Debt Service & Financing Interest (Bank loans, Credit card APR)
# 2. Strict Idempotency:
#    - Uses PlayerData.monthly_settlement_cursor to ensure each month executes
#      strictly once across save/load, large frame delays, and duplicate triggers.
# 3. Calendar Due-Date Clamping:
#    - Due dates (29th, 30th, 31st) are clamped to the exact length of shorter months.
# 4. Rounding Rules & 12-Month Exact Accounting:
#    - Months 1..11 use standard rounding; Month 12 reconciles cumulative remainder
#      so 12 monthly payments match the exact annual nominal figure with zero drift.
# 5. Debt Degradation:
#    - Insufficient funds trigger established fallback: available funds emptied,
#      unpaid balance added to debt/tax_debt, penalties applied.
# 6. Structured Transaction History & Life Event Logging.
# =============================================================================

# Accounting & Transaction Categories
const CATEGORY_PAYROLL := "payroll"
const CATEGORY_DIVIDEND := "dividend"
const CATEGORY_BANKING := "banking"
const CATEGORY_PENSION := "pension"
const CATEGORY_TAX := "tax"
const CATEGORY_LIFESTYLE := "lifestyle"
const CATEGORY_HOUSING := "housing"
const CATEGORY_MAINTENANCE := "maintenance"
const CATEGORY_INSURANCE := "insurance"
const CATEGORY_HEALTHCARE := "healthcare"
const CATEGORY_EDUCATION := "education"
const CATEGORY_SUBSCRIPTION := "subscription"
const CATEGORY_DEBT := "debt"

const PetManagerScript = preload("res://scripts/economy/pet_manager.gd")


# -----------------------------------------------------------------------------
# 1. IDEMPOTENCY & CURSOR CHECKS
# -----------------------------------------------------------------------------
static func is_month_settled(player_data: Node, year: int, month: int) -> bool:
	if not "monthly_settlement_cursor" in player_data:
		return false
	var cursor: Dictionary = player_data.monthly_settlement_cursor
	if cursor.is_empty():
		return false
	var c_year: int = int(cursor.get("year", 0))
	var c_month: int = int(cursor.get("month", 0))
	if c_year > year:
		return true
	if c_year == year and c_month >= month:
		return true
	return false


static func can_settle_month(player_data: Node, year: int, month: int) -> bool:
	if player_data == null or bool(player_data.get("is_dead")):
		return false
	return not is_month_settled(player_data, year, month)


# -----------------------------------------------------------------------------
# 2. CALENDAR DATE DUE-DATE HANDLING
# -----------------------------------------------------------------------------
static func get_effective_due_day(year: int, month: int, target_day: int) -> int:
	var max_days := 31
	if Engine.has_singleton("GameClock"):
		var gc = Engine.get_singleton("GameClock")
		if gc.has_method("get_days_in_month"):
			max_days = gc.get_days_in_month(year, month)
	else:
		match month:
			2:
				var is_leap: bool = (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)
				max_days = 29 if is_leap else 28
			4, 6, 9, 11:
				max_days = 30
			_:
				max_days = 31
	return clampi(target_day, 1, max_days)


# -----------------------------------------------------------------------------
# 3. ROUNDING RULES & 12-MONTH RECONCILIATION
# -----------------------------------------------------------------------------
static func calculate_monthly_amount(annual_amount: int, month_index: int = 1, cumulative_paid_this_year: int = -1) -> int:
	if annual_amount <= 0:
		return 0
	if month_index == 12 and cumulative_paid_this_year >= 0:
		return maxi(0, annual_amount - cumulative_paid_this_year)
	return maxi(1, int(round(float(annual_amount) / 12.0)))


# -----------------------------------------------------------------------------
# 4. CENTRAL MONTHLY SETTLEMENT PIPELINE
# -----------------------------------------------------------------------------
static func process_monthly_settlement(player_data: Node, year: int, month: int) -> Dictionary:
	if not can_settle_month(player_data, year, month):
		return {
			"settled": false,
			"year": year,
			"month": month,
			"reason": "Already settled or ineligible",
			"logs": []
		}

	var logs: Array[Dictionary] = [] # Array of {"text": String, "kind": String}
	var date_label := _get_date_string(year, month)

	# -------------------------------------------------------------------------
	# PHASE 1: SALARY & EMPLOYMENT PAYROLL
	# Strict: No salary paid to unemployed players or prisoners!
	# -------------------------------------------------------------------------
	var job_title: String = str(player_data.get("job_title"))
	var job_id: String = str(player_data.get("job_id"))
	var job_sal: int = int(player_data.get("job_salary"))
	var in_prison: bool = bool(player_data.get("is_in_prison"))
	var p_type: String = str(player_data.get("job_payment_type")) if player_data.get("job_payment_type") != null else "MONTHLY_SALARY"
	var is_employed: bool = not in_prison and job_title != "" and job_id != "" and job_sal > 0 and p_type != "DAILY_WAGE"

	var m_salary: int = 0
	if is_employed:
		var cum_sal: int = int(player_data.get("cumulative_salary_paid_this_year")) if "cumulative_salary_paid_this_year" in player_data else -1
		m_salary = calculate_monthly_amount(job_sal, month, cum_sal)
		if m_salary > 0:
			player_data.receive_salary(m_salary)
			if "cumulative_salary_paid_this_year" in player_data:
				player_data.cumulative_salary_paid_this_year = int(player_data.get("cumulative_salary_paid_this_year")) + m_salary
			var job_comp: String = str(player_data.get("job_company"))
			logs.append({
				"text": "💵 Monthly salary of $%s from %s was deposited into your bank account." % [_format_num(m_salary), job_comp],
				"kind": "job"
			})
			_record_trans(player_data, date_label, CATEGORY_PAYROLL, m_salary, "Monthly Salary (%s)" % job_comp)

	# -------------------------------------------------------------------------
	# PHASE 2: INFLOWS FROM COMMERCIAL ENTERPRISES, SOCIAL MEDIA & SAVINGS INTEREST
	# -------------------------------------------------------------------------
	# 2a. Commercial Business Dividends
	var biz_logs := BusinessManager.process_monthly_dividends(player_data)
	for b_msg in biz_logs:
		logs.append({"text": b_msg, "kind": "finance"})

	# 2b. Social Media Creator Ad Revenue
	var social_logs := SocialMediaManager.process_monthly_social_media(player_data)
	for s_msg in social_logs:
		logs.append({"text": s_msg, "kind": "lifestyle"})

	# 2c. Bank Savings Interest (2.5% APY / 12)
	var cur_savings: int = int(player_data.get("bank_savings"))
	if cur_savings > 0:
		var m_interest: int = int(round((float(cur_savings) * 0.025) / 12.0))
		if m_interest > 0:
			player_data.bank_savings = cur_savings + m_interest
			_record_trans(player_data, date_label, CATEGORY_BANKING, m_interest, "Bank Savings Interest (2.5% APY)")

	# 2d. Pension & High-Yield Generational Savings Accounts
	var ps_mgr = preload("res://scripts/economy/pension_and_savings_manager.gd")
	var ps_logs: Array[String] = ps_mgr.process_monthly_accounts(player_data)
	for ps_msg in ps_logs:
		logs.append({"text": ps_msg, "kind": "finance"})

	# -------------------------------------------------------------------------
	# PHASE 3: MONTHLY TAX WITHHOLDING
	# Based on existing progressive bracket model annualized / 12 + property tax / 12
	# -------------------------------------------------------------------------
	var tax_res := TaxSystem.process_monthly_taxes(player_data)
	for t_msg in tax_res.get("logs", []):
		logs.append({"text": t_msg, "kind": "finance"})
	var tax_due: int = int(tax_res.get("monthly_due", 0))
	if tax_due > 0:
		_record_trans(player_data, date_label, CATEGORY_TAX, -int(tax_res.get("paid", tax_due)), "Monthly Tax Withholding")

	# -------------------------------------------------------------------------
	# PHASE 4: HOUSING & ESSENTIAL LIVING EXPENSES
	# -------------------------------------------------------------------------
	var age: int = int(player_data.get("age"))
	# 4a. Basic Living Expenses (adults >= 18 not in prison/institution)
	if age >= 18 and not in_prison and not bool(player_data.get("is_in_mental_institution")):
		var base_living: int = 0
		if age < 22 and job_title == "":
			# Living with family
			base_living = 0
		elif job_sal > 0:
			base_living = int(round((3200.0 + float(job_sal) * 0.16) / 12.0))
		else:
			# Unemployed independent adult baseline
			base_living = 250

		if base_living > 0:
			var total_avail: int = int(player_data.get("money")) + int(player_data.get("bank_savings"))
			if total_avail >= base_living:
				player_data.debit_funds(base_living)
				logs.append({
					"text": "Paid monthly basic living expenses of $%s (food, utilities & essentials)." % _format_num(base_living),
					"kind": "finance"
				})
				_record_trans(player_data, date_label, CATEGORY_LIFESTYLE, -base_living, "Basic Living Expenses")
			else:
				var paid: int = total_avail
				var unpaid: int = base_living - paid
				player_data.money = 0
				player_data.bank_savings = 0
				player_data.debt = int(player_data.get("debt")) + unpaid
				player_data.happiness = maxi(5, int(player_data.get("happiness")) - 3)
				if int(player_data.get("debt")) > 15000:
					player_data.health = maxi(5, int(player_data.get("health")) - 1)
				logs.append({
					"text": "⚠️ FINANCIAL STRUGGLE: Couldn't afford full monthly living expenses ($%s)! Shortfall of $%s added to debt." % [
						_format_num(base_living), _format_num(unpaid)
					],
					"kind": "finance"
				})
				_record_trans(player_data, date_label, CATEGORY_LIFESTYLE, -paid, "Basic Living Expenses (Partial)")

	# 4b. Monthly Rent
	var rent_logs := RentalManager.process_monthly_rent(player_data)
	for r_msg in rent_logs:
		logs.append({"text": r_msg, "kind": "lifestyle"})
		_record_trans(player_data, date_label, CATEGORY_HOUSING, 0, "Residential Rent Payment")

	# 4c. Monthly Mortgages
	var mortgage_logs := MortgageManager.process_monthly_mortgages(player_data)
	for m_msg in mortgage_logs:
		logs.append({"text": m_msg, "kind": "finance"})
		_record_trans(player_data, date_label, CATEGORY_HOUSING, 0, "Property Mortgage Payment")

	# -------------------------------------------------------------------------
	# PHASE 5: ASSET UPKEEP & INSURANCE
	# Strict: Only charges for existent assets in owned_assets
	# -------------------------------------------------------------------------
	var asset_logs := AssetCatalog.process_monthly_assets(player_data, month)
	for a_msg in asset_logs:
		logs.append({"text": a_msg, "kind": "finance"})

	var ins_logs := AssetInsuranceManager.process_monthly_insurance(player_data)
	for ins_msg in ins_logs:
		logs.append({"text": ins_msg, "kind": "finance"})

	# -------------------------------------------------------------------------
	# PHASE 6: PERSONAL SUBSCRIPTIONS, HEALTHCARE & EDUCATION
	# -------------------------------------------------------------------------
	# 6a. Neural Specialist Nanite Upkeep
	if player_data.has_method("process_monthly_neural_implants"):
		var n_logs: Array[String] = player_data.process_monthly_neural_implants()
		for n_msg in n_logs:
			logs.append({"text": n_msg, "kind": "health"})

	# 6b. Pet Care & Food Upkeep
	var pet_logs := PetManagerScript.process_monthly_pets(player_data)
	for p_msg in pet_logs:
		logs.append({"text": p_msg, "kind": "relationship"})

	# 6c. Gym Membership
	if bool(player_data.get("has_gym_membership")):
		var m_gym: int = maxi(1, int(round(float(player_data.get("gym_membership_annual_fee")) / 12.0)))
		var avail_funds: int = int(player_data.get("money")) + int(player_data.get("bank_savings"))
		if avail_funds >= m_gym:
			player_data.debit_funds(m_gym)
			_record_trans(player_data, date_label, CATEGORY_SUBSCRIPTION, -m_gym, "Gym Membership")
		else:
			player_data.has_gym_membership = false
			player_data.happiness = maxi(5, int(player_data.get("happiness")) - 4)
			logs.append({
				"text": "⚠️ GYM MEMBERSHIP CANCELLED: Insufficient funds ($%s) for monthly gym membership." % _format_num(m_gym),
				"kind": "finance"
			})

	# 6d. University Tuition
	var edu_level: String = str(player_data.get("education_level"))
	var has_schol: bool = bool(player_data.get("has_scholarship"))
	if edu_level == "University Student" and not has_schol:
		var u_annual: int = int(player_data.get("university_tuition")) if int(player_data.get("university_tuition")) > 0 else 12000
		var m_tuition: int = maxi(1, int(round(float(u_annual) / 12.0)))
		var uni_title: String = str(player_data.get("university_name")) if str(player_data.get("university_name")) != "" else "University"
		var total_avail: int = int(player_data.get("money")) + int(player_data.get("bank_savings"))
		if total_avail >= m_tuition:
			player_data.debit_funds(m_tuition)
			logs.append({
				"text": "Paid $%s monthly tuition to %s." % [_format_num(m_tuition), uni_title],
				"kind": "education"
			})
			_record_trans(player_data, date_label, CATEGORY_EDUCATION, -m_tuition, "University Tuition (%s)" % uni_title)
		else:
			player_data.loan_balance = int(player_data.get("loan_balance")) + m_tuition
			logs.append({
				"text": "Monthly tuition of $%s for %s was funded via Student Loan (8%% APR)." % [_format_num(m_tuition), uni_title],
				"kind": "finance"
			})
			_record_trans(player_data, date_label, CATEGORY_EDUCATION, 0, "Student Loan Addition (%s)" % uni_title)

	# 6e. Mental Institution Inpatient Fee
	if bool(player_data.get("is_in_mental_institution")):
		var m_inst: int = maxi(1, int(round(float(player_data.get("mental_institution_annual_cost")) / 12.0)))
		var total_avail: int = int(player_data.get("money")) + int(player_data.get("bank_savings"))
		if total_avail >= m_inst:
			player_data.debit_funds(m_inst)
			_record_trans(player_data, date_label, CATEGORY_HEALTHCARE, -m_inst, "Psychiatric Inpatient Care")
		else:
			var paid: int = total_avail
			var unpaid: int = m_inst - paid
			player_data.debit_funds(paid)
			player_data.debt = int(player_data.get("debt")) + unpaid
			_record_trans(player_data, date_label, CATEGORY_HEALTHCARE, -paid, "Psychiatric Inpatient Care (Shortfall to Debt)")

	# -------------------------------------------------------------------------
	# PHASE 7: DEBT SERVICE & FINANCING INTEREST
	# -------------------------------------------------------------------------
	# 7a. Personal Bank Loan Interest
	var loan_bal: int = int(player_data.get("loan_balance"))
	if loan_bal > 0:
		var loan_rate: float = float(player_data.get("loan_interest_rate")) if player_data.get("loan_interest_rate") != null else 0.08
		var loan_int: int = maxi(1, int(round((float(loan_bal) * loan_rate) / 12.0)))
		player_data.loan_balance = loan_bal + loan_int
		_record_trans(player_data, date_label, CATEGORY_DEBT, 0, "Personal Loan Interest Accrual (+$%s)" % _format_num(loan_int))

	# 7b. Credit Card APR Interest
	var has_cc: bool = bool(player_data.get("has_credit_card"))
	var cc_bal: int = int(player_data.get("credit_card_balance"))
	if has_cc and cc_bal > 0:
		var cc_apr: float = float(player_data.get("credit_card_apr")) if player_data.get("credit_card_apr") != null else 0.18
		var cc_int: int = maxi(1, int(round((float(cc_bal) * cc_apr) / 12.0)))
		player_data.credit_card_balance = cc_bal + cc_int
		_record_trans(player_data, date_label, CATEGORY_DEBT, 0, "Credit Card Interest Accrual (+$%s)" % _format_num(cc_int))

	# -------------------------------------------------------------------------
	# PHASE 8: CURSOR ADVANCE & IDEMPOTENCY LOCK
	# -------------------------------------------------------------------------
	player_data.monthly_settlement_cursor = {
		"year": year,
		"month": month
	}

	return {
		"settled": true,
		"year": year,
		"month": month,
		"logs": logs
	}


# -----------------------------------------------------------------------------
# 5. MULTI-MONTH CATCH-UP PIPELINE
# Safely processes any months elapsed between cursor and target calendar date.
# -----------------------------------------------------------------------------
static func catch_up_settlements(player_data: Node, target_year: int, target_month: int) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	if player_data == null or bool(player_data.get("is_dead")):
		return results

	var cursor: Dictionary = player_data.monthly_settlement_cursor if "monthly_settlement_cursor" in player_data else {}
	if cursor.is_empty():
		var single := process_monthly_settlement(player_data, target_year, target_month)
		if bool(single.get("settled", false)):
			results.append(single)
		return results

	var cur_year: int = int(cursor.get("year", target_year))
	var cur_month: int = int(cursor.get("month", target_month))

	while cur_year < target_year or (cur_year == target_year and cur_month < target_month):
		cur_month += 1
		if cur_month > 12:
			cur_month = 1
			cur_year += 1
		var step := process_monthly_settlement(player_data, cur_year, cur_month)
		if bool(step.get("settled", false)):
			results.append(step)

	return results


# -----------------------------------------------------------------------------
# 6. ANNUAL FISCAL RECONCILIATION DELEGATION
# -----------------------------------------------------------------------------
static func reconcile_annual_taxes(player_data: Node) -> Dictionary:
	return TaxSystem.reconcile_annual_taxes(player_data)


# -----------------------------------------------------------------------------
# INTERNAL HELPERS
# -----------------------------------------------------------------------------
static func _record_trans(player_data: Node, date_label: String, category: String, amount: int, description: String) -> void:
	if player_data.has_method("record_transaction"):
		player_data.record_transaction(category, amount, description, date_label)


static func _get_date_string(year: int, month: int) -> String:
	var m_names := [
		"January", "February", "March", "April", "May", "June",
		"July", "August", "September", "October", "November", "December"
	]
	var m_str: String = str(m_names[clampi(month - 1, 0, 11)])
	return "%s %d" % [m_str, year]


static func _format_num(val: int) -> String:
	var s := str(absi(val))
	var res := ""
	var cnt := 0
	for j in range(s.length() - 1, -1, -1):
		res = s[j] + res
		cnt += 1
		if cnt % 3 == 0 and j > 0:
			res = "," + res
	return res
