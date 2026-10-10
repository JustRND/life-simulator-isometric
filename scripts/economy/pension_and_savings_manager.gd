extends Node

# -----------------------------------------------------------------------------
# PENSION & SAVINGS MANAGER
# Handles:
# 1. PENSION ACCOUNT (CANNOT BE INHERITED) - Tax-advantaged 6.5% APR retirement
#    fund with employer match, age 60+ penalty-free retirement, annuity payouts.
#    Strictly non-transferable; forfeited upon character death/succession.
# 2. SAVINGS ACCOUNT (CAN BE INHERITED) - High-Yield 4.2% APY generational
#    wealth account. Fully passed down to children/heirs upon succession.
# -----------------------------------------------------------------------------

const PENSION_ANNUAL_GROWTH: float = 0.065   # 6.5% annual compounding return
const PENSION_EARLY_PENALTY: float = 0.20    # 20% early tax penalty before age 60
const PENSION_RETIREMENT_AGE: int = 60       # Full vesting age
const PENSION_ANNUITY_RATE: float = 0.08     # 8% annual payout when annuity is active

const SAVINGS_ANNUAL_GROWTH: float = 0.042   # 4.2% High-Yield APY compounding return


static func ensure(player_data: Node) -> void:
	if not "pension_account" in player_data or not (player_data.pension_account is Dictionary):
		player_data.pension_account = {}

	var p: Dictionary = player_data.pension_account
	if not p.has("balance"): p["balance"] = 0
	if not p.has("total_contributed"): p["total_contributed"] = 0
	if not p.has("contribution_pct"): p["contribution_pct"] = 0.05 # 5% default
	if not p.has("employer_match_pct"): p["employer_match_pct"] = 0.03 # 3% default
	if not p.has("interest_rate"): p["interest_rate"] = PENSION_ANNUAL_GROWTH
	if not p.has("is_annuity_active"): p["is_annuity_active"] = false
	if not p.has("total_annuity_paid"): p["total_annuity_paid"] = 0
	if not p.has("last_year_interest"): p["last_year_interest"] = 0
	if not p.has("is_enrolled"): p["is_enrolled"] = false

	if not "savings_account" in player_data or not (player_data.savings_account is Dictionary):
		player_data.savings_account = {}

	var s: Dictionary = player_data.savings_account
	if not s.has("balance"): s["balance"] = 0
	if not s.has("total_deposited"): s["total_deposited"] = 0
	if not s.has("total_withdrawn"): s["total_withdrawn"] = 0
	if not s.has("total_interest_earned"): s["total_interest_earned"] = 0
	if not s.has("interest_rate"): s["interest_rate"] = SAVINGS_ANNUAL_GROWTH
	if not s.has("last_year_interest"): s["last_year_interest"] = 0
	if not s.has("is_open"): s["is_open"] = true


static func advance_year(player_data: Node) -> Array[String]:
	ensure(player_data)
	var logs: Array[String] = []

	var p: Dictionary = player_data.pension_account
	var s: Dictionary = player_data.savings_account

	# -------------------------------------------------------------------------
	# 1. PENSION ACCOUNT ANNUAL PROCESSING
	# -------------------------------------------------------------------------
	var p_balance: int = int(p.get("balance", 0))

	# A. Payroll Salary Contribution (if player has a job, enrolled, and not drawing annuity)
	if p.get("is_enrolled", false) and player_data.job_salary > 0 and not player_data.is_in_prison and not bool(p.get("is_annuity_active", false)):
		var c_pct: float = float(p.get("contribution_pct", 0.05))
		if c_pct > 0.001:
			var deduction: int = int(round(float(player_data.job_salary) * c_pct))
			# Can deduct if player has available funds or salary
			var actual_deduction := mini(deduction, player_data.get_available_funds())
			if actual_deduction > 0:
				player_data.debit_funds(actual_deduction)
				p_balance += actual_deduction
				p["total_contributed"] = int(p.get("total_contributed", 0)) + actual_deduction

				# Employer Match
				var m_pct: float = float(p.get("employer_match_pct", 0.03))
				var match_amount: int = int(round(float(player_data.job_salary) * m_pct))
				p_balance += match_amount

				logs.append("👴 PENSION CONTRIBUTION: $%s was contributed from your salary + $%s company match deposited into your retirement fund!" % [
					_format_num(actual_deduction), _format_num(match_amount)
				])

	# B. Compounding Growth
	if p_balance > 0:
		var p_growth: float = float(p.get("interest_rate", PENSION_ANNUAL_GROWTH))
		var p_interest: int = maxi(1, int(round(float(p_balance) * p_growth)))
		p_balance += p_interest
		p["last_year_interest"] = p_interest
		logs.append("👴 PENSION FUND: Your retirement pension balance accrued $%s in compounding investment returns (%.1f%% APR)." % [
			_format_num(p_interest), p_growth * 100.0
		])

	# C. Annuity Payouts (if age >= 60 and annuity active)
	if p_balance > 0 and bool(p.get("is_annuity_active", false)) and player_data.age >= PENSION_RETIREMENT_AGE:
		var payout: int = maxi(100, int(round(float(p_balance) * PENSION_ANNUITY_RATE)))
		payout = mini(payout, p_balance)
		p_balance -= payout
		player_data.money += payout
		p["total_annuity_paid"] = int(p.get("total_annuity_paid", 0)) + payout
		logs.append("👴 PENSION ANNUITY: You received $%s in monthly retirement annuity distribution from your pension fund!" % _format_num(payout))

	p["balance"] = p_balance

	# -------------------------------------------------------------------------
	# 2. SAVINGS ACCOUNT ANNUAL PROCESSING (INHERITABLE)
	# -------------------------------------------------------------------------
	var s_balance: int = int(s.get("balance", 0))
	if s_balance > 0:
		var s_rate: float = float(s.get("interest_rate", SAVINGS_ANNUAL_GROWTH))
		var s_interest: int = maxi(1, int(round(float(s_balance) * s_rate)))
		s_balance += s_interest
		s["balance"] = s_balance
		s["last_year_interest"] = s_interest
		s["total_interest_earned"] = int(s.get("total_interest_earned", 0)) + s_interest
		logs.append("💰 HIGH-YIELD SAVINGS: Your inheritable savings account accrued $%s in annual compounding interest (%.1f%% APY)." % [
			_format_num(s_interest), s_rate * 100.0
		])

	return logs


# -----------------------------------------------------------------------------
# PENSION ACTIONS
# -----------------------------------------------------------------------------

static func deposit_pension(player_data: Node, amount: int) -> Dictionary:
	ensure(player_data)
	if amount <= 0:
		return {"success": false, "message": "Invalid deposit amount."}
	if player_data.age < 18:
		return {"success": false, "message": "You must be at least 18 years old to open or contribute to a Pension Account."}

	var avail: int = player_data.get_available_funds()
	if avail < amount:
		return {"success": false, "message": "Insufficient funds. You have $%s available." % _format_num(avail)}

	player_data.debit_funds(amount)
	var p: Dictionary = player_data.pension_account
	p["balance"] = int(p.get("balance", 0)) + amount
	p["total_contributed"] = int(p.get("total_contributed", 0)) + amount
	p["is_enrolled"] = true

	return {
		"success": true,
		"message": "Successfully deposited $%s into your Pension Retirement Account (Current Balance: $%s)." % [
			_format_num(amount), _format_num(int(p["balance"]))
		]
	}


static func withdraw_pension(player_data: Node, amount: int) -> Dictionary:
	ensure(player_data)
	if amount <= 0:
		return {"success": false, "message": "Invalid withdrawal amount."}

	var p: Dictionary = player_data.pension_account
	var cur_bal: int = int(p.get("balance", 0))
	if cur_bal < amount:
		return {"success": false, "message": "Insufficient pension balance. You have $%s." % _format_num(cur_bal)}

	var is_retired: bool = player_data.age >= PENSION_RETIREMENT_AGE
	var penalty: int = 0
	var net_received: int = amount

	if not is_retired:
		penalty = int(round(float(amount) * PENSION_EARLY_PENALTY))
		net_received = amount - penalty

	p["balance"] = cur_bal - amount
	player_data.money += net_received

	var msg := ""
	if is_retired:
		msg = "Retirement Withdrawal: You withdrew $%s penalty-free from your Pension Account (Remaining Balance: $%s)." % [
			_format_num(amount), _format_num(int(p["balance"]))
		]
	else:
		msg = "⚠️ Early Withdrawal: You withdrew $%s from your Pension Account. A 20%% early withdrawal penalty ($%s) was deducted by tax authorities. Net received: $%s (Remaining: $%s)." % [
			_format_num(amount), _format_num(penalty), _format_num(net_received), _format_num(int(p["balance"]))
		]

	return {
		"success": true,
		"net_received": net_received,
		"penalty": penalty,
		"message": msg
	}


static func set_pension_contribution_pct(player_data: Node, pct: float) -> void:
	ensure(player_data)
	var p: Dictionary = player_data.pension_account
	p["contribution_pct"] = clampf(pct, 0.0, 0.50)
	p["is_enrolled"] = pct > 0.001 or int(p.get("balance", 0)) > 0


static func toggle_pension_annuity(player_data: Node, active: bool) -> Dictionary:
	ensure(player_data)
	if player_data.age < PENSION_RETIREMENT_AGE:
		return {"success": false, "message": "Retirement annuity distributions unlock at age 60+."}

	var p: Dictionary = player_data.pension_account
	p["is_annuity_active"] = active
	var status_text := "activated" if active else "paused"
	return {
		"success": true,
		"message": "Annual Pension Annuity distribution %s (8%% annual payout during retirement)." % status_text
	}


# -----------------------------------------------------------------------------
# SAVINGS ACTIONS (INHERITABLE)
# -----------------------------------------------------------------------------

static func deposit_savings(player_data: Node, amount: int) -> Dictionary:
	ensure(player_data)
	if amount <= 0:
		return {"success": false, "message": "Invalid deposit amount."}
	if player_data.age < 13:
		return {"success": false, "message": "Banking accounts unlock at age 13 for youth accounts."}

	var avail: int = player_data.get_available_funds()
	if avail < amount:
		return {"success": false, "message": "Insufficient funds. You have $%s available." % _format_num(avail)}

	player_data.debit_funds(amount)
	var s: Dictionary = player_data.savings_account
	s["balance"] = int(s.get("balance", 0)) + amount
	s["total_deposited"] = int(s.get("total_deposited", 0)) + amount

	return {
		"success": true,
		"message": "Successfully deposited $%s into your Inheritable High-Yield Savings Account (Balance: $%s)." % [
			_format_num(amount), _format_num(int(s["balance"]))
		]
	}


static func withdraw_savings(player_data: Node, amount: int) -> Dictionary:
	ensure(player_data)
	if amount <= 0:
		return {"success": false, "message": "Invalid withdrawal amount."}

	var s: Dictionary = player_data.savings_account
	var cur_bal: int = int(s.get("balance", 0))
	if cur_bal < amount:
		return {"success": false, "message": "Insufficient savings balance. You have $%s." % _format_num(cur_bal)}

	s["balance"] = cur_bal - amount
	s["total_withdrawn"] = int(s.get("total_withdrawn", 0)) + amount
	player_data.money += amount

	return {
		"success": true,
		"message": "Successfully withdrew $%s from your Savings Account (Remaining Balance: $%s)." % [
			_format_num(amount), _format_num(int(s["balance"]))
		]
	}


# -----------------------------------------------------------------------------
# SUCCESSION / INHERITANCE HANDLER
# -----------------------------------------------------------------------------

static func handle_succession(late_player: Node, heir_player: Node) -> Dictionary:
	ensure(late_player)
	ensure(heir_player)

	var p_late: Dictionary = late_player.pension_account
	var s_late: Dictionary = late_player.savings_account

	var forfeited_pension: int = int(p_late.get("balance", 0))
	var inherited_savings: int = int(s_late.get("balance", 0))

	# 1. PENSION IS NOT INHERITED: Forfeited completely to retirement trust
	p_late["balance"] = 0
	heir_player.pension_account = {
		"balance": 0,
		"total_contributed": 0,
		"contribution_pct": 0.05,
		"employer_match_pct": 0.03,
		"interest_rate": PENSION_ANNUAL_GROWTH,
		"is_annuity_active": false,
		"total_annuity_paid": 0,
		"last_year_interest": 0,
		"is_enrolled": false
	}

	# 2. SAVINGS IS FULLY INHERITED: Added to heir's savings account
	heir_player.savings_account["balance"] = int(heir_player.savings_account.get("balance", 0)) + inherited_savings

	return {
		"forfeited_pension": forfeited_pension,
		"inherited_savings": inherited_savings
	}


static func _format_num(value: int) -> String:
	var s := str(absi(value))
	var out := ""
	var cnt := 0
	for i in range(s.length() - 1, -1, -1):
		if cnt > 0 and cnt % 3 == 0:
			out = "," + out
		out = s[i] + out
		cnt += 1
	if value < 0:
		out = "-" + out
	return out
