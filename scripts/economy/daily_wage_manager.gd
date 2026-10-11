class_name DailyWageManager
extends RefCounted

# =============================================================================
# DAILY WAGE MANAGER
# Life.exe Daily Wage Processing Engine.
# Authoritatively processes daily wage shifts, work schedules, days off,
# illness/missed shifts, tax withholding, and transaction ledger recording.
# =============================================================================

const DailyJobsCatalogScript = preload("res://scripts/economy/daily_jobs_catalog.gd")

const CATEGORY_PAYROLL := "payroll"


# =============================================================================
# IDEMPOTENCY & DATE CHECKS
# =============================================================================

static func is_day_processed(player_data: Node, year: int, month: int, day: int) -> bool:
	if player_data == null or not ("daily_wage_last_paid" in player_data):
		return false
	var last_paid: Dictionary = player_data.daily_wage_last_paid
	if last_paid.is_empty():
		return false
	var lp_y: int = int(last_paid.get("year", 0))
	var lp_m: int = int(last_paid.get("month", 0))
	var lp_d: int = int(last_paid.get("day", 0))

	if lp_y > year:
		return true
	if lp_y == year and lp_m > month:
		return true
	if lp_y == year and lp_m == month and lp_d >= day:
		return true
	return false


# =============================================================================
# DAILY WAGE SHIFT PROCESSING
# =============================================================================

static func process_daily_wages(player_data: Node, year: int, month: int, day: int) -> Dictionary:
	if player_data == null or bool(player_data.get("is_dead")):
		return {"processed": false, "reason": "Character unavailable.", "total_net": 0, "logs": []}

	if is_day_processed(player_data, year, month, day):
		return {"processed": false, "reason": "Already processed for this date.", "total_net": 0, "logs": []}

	var dow: int = DailyJobsCatalogScript.calculate_day_of_week(year, month, day)
	var day_name: String = DailyJobsCatalogScript.get_day_name(dow)
	var date_label := "%s, %s %d, %d" % [day_name, DailyJobsCatalogScript.get_day_name(dow), day, year]

	var total_net: int = 0
	var total_gross: int = 0
	var total_tax: int = 0
	var logs: Array[String] = []
	var missed_shifts: Array[String] = []

	var age: int = int(player_data.get("age")) if player_data.get("age") != null else 17
	var in_prison: bool = bool(player_data.get("is_in_prison"))
	var in_institution: bool = bool(player_data.get("is_in_mental_institution"))
	var health: int = int(player_data.get("health")) if player_data.get("health") != null else 100

	# Gather active jobs that receive daily wages
	var active_daily_jobs: Array[Dictionary] = []

	# 1. Primary Job (if configured as DAILY_WAGE)
	var prim_id: String = str(player_data.get("job_id")) if player_data.get("job_id") != null else ""
	var prim_title: String = str(player_data.get("job_title")) if player_data.get("job_title") != null else ""
	var prim_catalog_def := DailyJobsCatalogScript.get_job_by_id(prim_id)
	var prim_payment_type := str(player_data.get("job_payment_type")) if player_data.get("job_payment_type") != null else ""
	if prim_payment_type == "" and not prim_catalog_def.is_empty():
		prim_payment_type = str(prim_catalog_def.get("payment_type", DailyJobsCatalogScript.PAYMENT_TYPE_MONTHLY_SALARY))

	if prim_title != "" and prim_payment_type == DailyJobsCatalogScript.PAYMENT_TYPE_DAILY_WAGE:
		var job_copy: Dictionary = prim_catalog_def.duplicate(true) if not prim_catalog_def.is_empty() else {}
		if job_copy.is_empty():
			job_copy = {
				"id": prim_id,
				"title": prim_title,
				"company": str(player_data.get("job_company")) if player_data.get("job_company") != null else "Employer",
				"daily_wage": int(round(float(player_data.get("job_salary")) / 260.0)) if player_data.get("job_salary") != null else 80,
				"workdays": [1, 2, 3, 4, 5],
				"stat_effects": {"happiness_delta": 0, "health_delta": -1, "mental_state_delta": 0}
			}
		else:
			job_copy["company"] = str(player_data.get("job_company")) if player_data.get("job_company") != null else "Employer"
		job_copy["is_primary"] = true
		active_daily_jobs.append(job_copy)

	# 2. Secondary / Part-Time Job
	if "part_time_job" in player_data and player_data.part_time_job is Dictionary:
		var pt_job: Dictionary = player_data.part_time_job
		if not pt_job.is_empty() and str(pt_job.get("payment_type", "")) == DailyJobsCatalogScript.PAYMENT_TYPE_DAILY_WAGE:
			var pt_copy: Dictionary = pt_job.duplicate(true)
			pt_copy["is_primary"] = false
			active_daily_jobs.append(pt_copy)

	# Process each active daily wage job
	for job in active_daily_jobs:
		var title: String = str(job.get("title", "Daily Job"))
		var company: String = str(job.get("company", "Employer"))
		var workdays: Array = job.get("workdays", [1, 2, 3, 4, 5])

		# Check if today is a scheduled workday
		if not workdays.has(dow):
			# Scheduled day off
			continue

		# Check availability conditions
		if in_prison:
			missed_shifts.append("Missed %s shift at %s: Incarcerated." % [title, company])
			continue

		if in_institution:
			missed_shifts.append("Missed %s shift at %s: Under inpatient psychiatric care." % [title, company])
			continue

		if health <= 15:
			missed_shifts.append("Missed %s shift at %s: Too sick or exhausted to work (Health: %d%%)." % [title, company, health])
			continue

		# Calculate Daily Pay & Tax Withholding
		var gross_wage: int = int(job.get("daily_wage", 80))
		var tax_withheld: int = 0

		if age >= 18:
			# Annualized withholding estimate
			var annual_est: int = gross_wage * 260
			var tax_info := TaxSystem.calculate_income_tax(annual_est)
			var annual_tax: int = int(tax_info.get("tax_due", 0))
			tax_withheld = int(round(float(annual_tax) / 260.0))

		var net_wage: int = maxi(0, gross_wage - tax_withheld)

		# Deposit funds into cash wallet
		var cur_money: int = int(player_data.get("money")) if player_data.get("money") != null else 0
		player_data.money = cur_money + net_wage

		# Track accumulators
		total_gross += gross_wage
		total_tax += tax_withheld
		total_net += net_wage

		if "daily_wage_earnings_this_year" in player_data:
			var cur_dw: int = int(player_data.get("daily_wage_earnings_this_year")) if player_data.get("daily_wage_earnings_this_year") != null else 0
			player_data.daily_wage_earnings_this_year = cur_dw + gross_wage
		if "taxable_daily_wages_this_year" in player_data:
			var cur_taxable: int = int(player_data.get("taxable_daily_wages_this_year")) if player_data.get("taxable_daily_wages_this_year") != null else 0
			player_data.taxable_daily_wages_this_year = cur_taxable + gross_wage

		if tax_withheld > 0:
			if "taxes_withheld_this_year" in player_data:
				var cur_tw: int = int(player_data.get("taxes_withheld_this_year")) if player_data.get("taxes_withheld_this_year") != null else 0
				player_data.taxes_withheld_this_year = cur_tw + tax_withheld
			if "taxes_paid_lifetime" in player_data:
				var cur_tpl: int = int(player_data.get("taxes_paid_lifetime")) if player_data.get("taxes_paid_lifetime") != null else 0
				player_data.taxes_paid_lifetime = cur_tpl + tax_withheld

		# Apply job stat effects
		var effects: Dictionary = job.get("stat_effects", {})
		if effects.has("happiness_delta"):
			var cur_h: int = int(player_data.get("happiness")) if player_data.get("happiness") != null else 50
			player_data.happiness = clampi(cur_h + int(effects["happiness_delta"]), 0, 100)
		if effects.has("health_delta"):
			var cur_hl: int = int(player_data.get("health")) if player_data.get("health") != null else 100
			player_data.health = clampi(cur_hl + int(effects["health_delta"]), 0, 100)
		if effects.has("mental_state_delta"):
			var cur_m: int = int(player_data.get("mental_state")) if player_data.get("mental_state") != null else 100
			player_data.mental_state = clampi(cur_m + int(effects["mental_state_delta"]), 0, 100)
		if effects.has("smarts_gain"):
			var cur_s: int = int(player_data.get("smarts")) if player_data.get("smarts") != null else 50
			player_data.smarts = clampi(cur_s + int(effects["smarts_gain"]), 0, 100)

		# Record transaction ledger entry
		var trans_desc := "Daily Wage: %s at %s [Gross: $%d, Tax: $%d]" % [title, company, gross_wage, tax_withheld]
		if player_data.has_method("record_transaction"):
			var b_after: int = (int(player_data.get("money")) if player_data.get("money") != null else 0) + (int(player_data.get("bank_savings")) if player_data.get("bank_savings") != null else 0)
			var d_after: int = int(player_data.get("debt")) if player_data.get("debt") != null else 0
			var entry := {
				"date": date_label,
				"age": age,
				"category": CATEGORY_PAYROLL,
				"amount": net_wage,
				"type": "income",
				"description": trans_desc,
				"balance_after": b_after,
				"debt_after": d_after,
				"gross_pay": gross_wage,
				"tax_withheld": tax_withheld,
				"net_pay": net_wage
			}
			player_data.transaction_history.append(entry)
			if player_data.transaction_history.size() > 500:
				player_data.transaction_history.pop_front()

		# Log daily earnings entry
		if "daily_earnings_log" in player_data and player_data.daily_earnings_log is Array:
			player_data.daily_earnings_log.append({
				"date": date_label,
				"job_title": title,
				"company": company,
				"gross_pay": gross_wage,
				"tax_withheld": tax_withheld,
				"net_pay": net_wage
			})
			if player_data.daily_earnings_log.size() > 60:
				player_data.daily_earnings_log.pop_front()

		logs.append("💵 Daily wage: Earned $%d net ($%d gross) working shift at %s." % [net_wage, gross_wage, company])

	# Update persistent idempotency cursor
	player_data.daily_wage_last_paid = {
		"year": year,
		"month": month,
		"day": day
	}

	return {
		"processed": true,
		"total_net": total_net,
		"total_gross": total_gross,
		"total_tax": total_tax,
		"logs": logs,
		"missed_shifts": missed_shifts
	}


# =============================================================================
# MULTI-DAY CATCH-UP PROCESSING
# =============================================================================

static func _days_in_month(y: int, m: int) -> int:
	if m < 1 or m > 12:
		return 30
	if m == 2 and ((y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)):
		return 29
	var days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	return days[m - 1]


static func process_catch_up(player_data: Node, to_year: int, to_month: int, to_day: int) -> Dictionary:
	if player_data == null:
		return {"processed": false, "days_processed": 0, "total_net": 0, "total_gross": 0, "total_tax": 0, "logs": []}

	var last_paid: Dictionary = player_data.daily_wage_last_paid if "daily_wage_last_paid" in player_data else {}
	var cur_y: int = int(last_paid.get("year", 0))
	var cur_m: int = int(last_paid.get("month", 0))
	var cur_d: int = int(last_paid.get("day", 0))

	# If never processed before, just process the target day
	if cur_y == 0 or cur_m == 0 or cur_d == 0:
		return process_daily_wages(player_data, to_year, to_month, to_day)

	var days_processed: int = 0
	var total_net: int = 0
	var total_gross: int = 0
	var total_tax: int = 0
	var all_logs: Array[String] = []
	var all_missed: Array[String] = []

	var safety_counter: int = 0
	while safety_counter < 365:
		safety_counter += 1
		# Advance one day
		cur_d += 1
		if cur_d > _days_in_month(cur_y, cur_m):
			cur_d = 1
			cur_m += 1
			if cur_m > 12:
				cur_m = 1
				cur_y += 1

		# Check if we passed target date
		if cur_y > to_year:
			break
		if cur_y == to_year and cur_m > to_month:
			break
		if cur_y == to_year and cur_m == to_month and cur_d > to_day:
			break

		var res := process_daily_wages(player_data, cur_y, cur_m, cur_d)
		if bool(res.get("processed", false)):
			days_processed += 1
			total_net += int(res.get("total_net", 0))
			total_gross += int(res.get("total_gross", 0))
			total_tax += int(res.get("total_tax", 0))
			for l in res.get("logs", []):
				all_logs.append(str(l))
			for m in res.get("missed_shifts", []):
				all_missed.append(str(m))

	return {
		"processed": days_processed > 0,
		"days_processed": days_processed,
		"total_net": total_net,
		"total_gross": total_gross,
		"total_tax": total_tax,
		"logs": all_logs,
		"missed_shifts": all_missed
	}
