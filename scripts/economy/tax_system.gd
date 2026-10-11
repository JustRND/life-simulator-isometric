class_name TaxSystem
extends RefCounted

# =============================================================================
# TAX SYSTEM ARCHITECTURE
# Extensible progressive tax system for Life Simulator Isometric.
# Supports:
# 1. Progressive Income Tax (Marginal brackets, standard deduction, pension/charity deductions)
# 2. Progressive Capital Gains Tax (Stocks, cryptocurrencies, real estate sales)
# 3. Progressive Property Tax (Real estate assessments & multi-property surcharges)
# 4. Progressive Business Tax (Commercial corporate profits & conglomerate scale)
# Designed with modular policy profiles for future expansion (e.g. international tax havens, audits).
# =============================================================================

# Standard Personal Exemption / Deduction
const STANDARD_DEDUCTION: int = 12000

# 1. Progressive Income Tax Brackets (Marginal brackets on taxable income after deductions)
const INCOME_BRACKETS: Array[Dictionary] = [
	{"limit": 35000, "rate": 0.10, "label": "10% ($12K – $47K)"},
	{"limit": 85000, "rate": 0.15, "label": "15% ($47K – $97K)"},
	{"limit": 180000, "rate": 0.22, "label": "22% ($97K – $192K)"},
	{"limit": 350000, "rate": 0.28, "label": "28% ($192K – $362K)"},
	{"limit": 600000, "rate": 0.33, "label": "33% ($362K – $612K)"},
	{"limit": -1, "rate": 0.37, "label": "37% (Over $612K)"}
]

# 2. Progressive Capital Gains Tax Brackets (On net realized gains across stocks, crypto, real estate)
const CAPITAL_GAINS_EXEMPTION: int = 15000 # 0% tax on first $15,000 of net gains

const CAPITAL_GAINS_BRACKETS: Array[Dictionary] = [
	{"limit": 45000, "rate": 0.10, "label": "10% ($15K – $60K)"},
	{"limit": 185000, "rate": 0.15, "label": "15% ($60K – $200K)"},
	{"limit": 400000, "rate": 0.20, "label": "20% ($200K – $600K)"},
	{"limit": -1, "rate": 0.25, "label": "25% (Over $600K)"}
]

# 3. Progressive Property Tax Brackets (Assessed on real estate market valuation)
const PROPERTY_VALUATION_BRACKETS: Array[Dictionary] = [
	{"limit": 300000, "rate": 0.008, "label": "0.8% (Tier 1: Up to $300K)"},
	{"limit": 1000000, "rate": 0.012, "label": "1.2% (Tier 2: $300K – $1M)"},
	{"limit": 3000000, "rate": 0.016, "label": "1.6% (Tier 3: $1M – $3M)"},
	{"limit": 6000000, "rate": 0.020, "label": "2.0% (Tier 4: $3M – $6M)"},
	{"limit": -1, "rate": 0.025, "label": "2.5% (Tier 5: Over $6M Luxury Estate)"}
]
const MULTI_PROPERTY_SURCHARGE_2ND: float = 0.0025 # +0.25% surcharge for 2nd home
const MULTI_PROPERTY_SURCHARGE_3RD_PLUS: float = 0.0050 # +0.50% surcharge for 3rd+ home

# 4. Progressive Business Tax Brackets (On net operating profit)
const BUSINESS_PROFIT_BRACKETS: Array[Dictionary] = [
	{"limit": 100000, "rate": 0.15, "label": "15% (Small Business: Up to $100K)"},
	{"limit": 500000, "rate": 0.21, "label": "21% (Medium Enterprise: $100K – $500K)"},
	{"limit": 2500000, "rate": 0.28, "label": "28% (Commercial Firm: $500K – $2.5M)"},
	{"limit": 10000000, "rate": 0.33, "label": "33% (Corporate Conglomerate: $2.5M – $10M)"},
	{"limit": -1, "rate": 0.38, "label": "38% (Multinational Corp: Over $10M)"}
]
const CONGLOMERATE_SURCHARGE_PER_BIZ: float = 0.02 # +2% per additional business owned (capped at +10%)

# Extensible Policy Profiles
static var active_policy_id: String = "standard"


# -----------------------------------------------------------------------------
# 1. PROGRESSIVE INCOME TAX CALCULATION
# -----------------------------------------------------------------------------
static func calculate_income_tax(gross_income: int, deductions: int = 0) -> Dictionary:
	var total_deductions := STANDARD_DEDUCTION + maxi(0, deductions)
	var taxable_income: int = maxi(0, gross_income - total_deductions)
	var tax_due: int = 0
	var brackets_breakdown: Array[Dictionary] = []

	var prev_limit: int = 0
	for b in INCOME_BRACKETS:
		var limit: int = int(b.get("limit", -1))
		var rate: float = float(b.get("rate", 0.0))
		var label: String = str(b.get("label", ""))

		if taxable_income <= prev_limit:
			brackets_breakdown.append({
				"label": label,
				"rate": rate,
				"taxable_amount": 0,
				"tax_amount": 0
			})
			continue

		var bracket_capacity: int = (limit - prev_limit) if limit > 0 else 999999999
		var taxable_in_bracket: int = mini(taxable_income - prev_limit, bracket_capacity)
		var tax_in_bracket: int = int(round(float(taxable_in_bracket) * rate))
		tax_due += tax_in_bracket

		brackets_breakdown.append({
			"label": label,
			"rate": rate,
			"taxable_amount": taxable_in_bracket,
			"tax_amount": tax_in_bracket
		})

		if limit > 0:
			prev_limit = limit
		else:
			break

	var effective_rate: float = (float(tax_due) / float(maxi(1, gross_income))) if gross_income > 0 else 0.0

	return {
		"gross_income": gross_income,
		"standard_deduction": STANDARD_DEDUCTION,
		"itemized_deductions": maxi(0, deductions),
		"total_deductions": total_deductions,
		"taxable_income": taxable_income,
		"tax_due": tax_due,
		"effective_rate": effective_rate,
		"brackets": brackets_breakdown
	}


# -----------------------------------------------------------------------------
# 2. PROGRESSIVE CAPITAL GAINS TAX CALCULATION
# -----------------------------------------------------------------------------
static func calculate_capital_gains_tax(realized_gains: int, realized_losses: int = 0) -> Dictionary:
	var net_gains: int = maxi(0, realized_gains - realized_losses)
	var taxable_gains: int = maxi(0, net_gains - CAPITAL_GAINS_EXEMPTION)
	var tax_due: int = 0
	var brackets_breakdown: Array[Dictionary] = []

	var prev_limit: int = 0
	for b in CAPITAL_GAINS_BRACKETS:
		var limit: int = int(b.get("limit", -1))
		var rate: float = float(b.get("rate", 0.0))
		var label: String = str(b.get("label", ""))

		if taxable_gains <= prev_limit:
			brackets_breakdown.append({
				"label": label,
				"rate": rate,
				"taxable_amount": 0,
				"tax_amount": 0
			})
			continue

		var bracket_capacity: int = (limit - prev_limit) if limit > 0 else 999999999
		var taxable_in_bracket: int = mini(taxable_gains - prev_limit, bracket_capacity)
		var tax_in_bracket: int = int(round(float(taxable_in_bracket) * rate))
		tax_due += tax_in_bracket

		brackets_breakdown.append({
			"label": label,
			"rate": rate,
			"taxable_amount": taxable_in_bracket,
			"tax_amount": tax_in_bracket
		})

		if limit > 0:
			prev_limit = limit
		else:
			break

	var effective_rate: float = (float(tax_due) / float(maxi(1, net_gains))) if net_gains > 0 else 0.0

	return {
		"realized_gains": realized_gains,
		"realized_losses": realized_losses,
		"net_gains": net_gains,
		"exemption": CAPITAL_GAINS_EXEMPTION,
		"taxable_gains": taxable_gains,
		"tax_due": tax_due,
		"effective_rate": effective_rate,
		"brackets": brackets_breakdown
	}


# -----------------------------------------------------------------------------
# 3. PROGRESSIVE PROPERTY TAX CALCULATION
# -----------------------------------------------------------------------------
static func calculate_property_tax(player_data: Node) -> Dictionary:
	var properties: Array[Dictionary] = []
	if "owned_assets" in player_data and player_data.owned_assets is Array:
		for a in player_data.owned_assets:
			if a is Dictionary and str(a.get("category", "")) == "properties":
				properties.append(a)

	var total_assessed: int = 0
	var total_tax: int = 0
	var properties_breakdown: Array[Dictionary] = []

	# Minors (< 18) are exempt from property taxes (family covers estate taxes)
	var is_minor: bool = int(player_data.get("age")) < 18

	for i in range(properties.size()):
		var prop: Dictionary = properties[i]
		var val: int = int(prop.get("current_value", prop.get("purchase_price", 0)))
		total_assessed += val

		if is_minor or val <= 0:
			properties_breakdown.append({
				"name": str(prop.get("name", "Residential Property")),
				"value": val,
				"base_tax": 0,
				"surcharge": 0,
				"total_tax": 0,
				"effective_rate": 0.0,
				"is_primary": (i == 0)
			})
			continue

		# Progressive tax by valuation bracket
		var prop_tax: int = 0
		var prev_limit: int = 0
		for b in PROPERTY_VALUATION_BRACKETS:
			var limit: int = int(b.get("limit", -1))
			var rate: float = float(b.get("rate", 0.01))
			if val <= prev_limit:
				break
			var capacity: int = (limit - prev_limit) if limit > 0 else 999999999
			var in_bracket: int = mini(val - prev_limit, capacity)
			prop_tax += int(round(float(in_bracket) * rate))
			if limit > 0:
				prev_limit = limit
			else:
				break

		# Multi-property progressive surcharge (second home +0.25%, 3rd+ homes +0.50%)
		var surcharge_rate: float = 0.0
		if i == 1:
			surcharge_rate = MULTI_PROPERTY_SURCHARGE_2ND
		elif i >= 2:
			surcharge_rate = MULTI_PROPERTY_SURCHARGE_3RD_PLUS

		var surcharge_tax: int = int(round(float(val) * surcharge_rate))
		var full_prop_tax: int = prop_tax + surcharge_tax
		total_tax += full_prop_tax

		var eff_rate: float = (float(full_prop_tax) / float(maxi(1, val)))

		properties_breakdown.append({
			"name": str(prop.get("name", "Residential Property")),
			"value": val,
			"base_tax": prop_tax,
			"surcharge_rate": surcharge_rate,
			"surcharge": surcharge_tax,
			"total_tax": full_prop_tax,
			"effective_rate": eff_rate,
			"is_primary": (i == 0)
		})

	var overall_eff_rate: float = (float(total_tax) / float(maxi(1, total_assessed))) if total_assessed > 0 else 0.0

	return {
		"property_count": properties.size(),
		"total_assessed_value": total_assessed,
		"tax_due": total_tax,
		"effective_rate": overall_eff_rate,
		"properties": properties_breakdown,
		"is_minor_exempt": is_minor
	}


# -----------------------------------------------------------------------------
# 4. PROGRESSIVE BUSINESS TAX CALCULATION
# -----------------------------------------------------------------------------
static func calculate_business_tax(business: Dictionary, total_businesses: int) -> Dictionary:
	var rev: int = int(business.get("annual_revenue", 0))
	var opex: int = int(business.get("annual_opex", 0))
	var net_profit: int = rev - opex

	if net_profit <= 0:
		return {
			"name": str(business.get("name", "Business")),
			"revenue": rev,
			"opex": opex,
			"net_profit": net_profit,
			"tax_due": 0,
			"effective_rate": 0.0,
			"conglomerate_surcharge": 0.0
		}

	# Progressive marginal corporate tax on net profit
	var base_tax: int = 0
	var prev_limit: int = 0
	for b in BUSINESS_PROFIT_BRACKETS:
		var limit: int = int(b.get("limit", -1))
		var rate: float = float(b.get("rate", 0.20))
		if net_profit <= prev_limit:
			break
		var capacity: int = (limit - prev_limit) if limit > 0 else 999999999
		var in_bracket: int = mini(net_profit - prev_limit, capacity)
		base_tax += int(round(float(in_bracket) * rate))
		if limit > 0:
			prev_limit = limit
		else:
			break

	# Conglomerate scale surcharge (e.g. +2% per additional business owned, capped at 10%)
	var cong_rate: float = minf(0.10, maxi(0, total_businesses - 1) * CONGLOMERATE_SURCHARGE_PER_BIZ)
	var cong_tax: int = int(round(float(net_profit) * cong_rate))

	var total_biz_tax: int = base_tax + cong_tax
	var eff_rate: float = float(total_biz_tax) / float(maxi(1, net_profit))

	return {
		"name": str(business.get("name", "Business")),
		"revenue": rev,
		"opex": opex,
		"net_profit": net_profit,
		"base_tax": base_tax,
		"conglomerate_surcharge_rate": cong_rate,
		"conglomerate_surcharge": cong_tax,
		"tax_due": total_biz_tax,
		"effective_rate": eff_rate
	}


static func calculate_total_business_taxes(player_data: Node) -> Dictionary:
	var total_biz_tax: int = 0
	var total_net_profit: int = 0
	var total_revenue: int = 0
	var breakdowns: Array[Dictionary] = []

	var biz_list: Array = player_data.get("owned_businesses") if "owned_businesses" in player_data else []
	var total_count: int = biz_list.size()

	for b in biz_list:
		if b is Dictionary:
			var res: Dictionary = calculate_business_tax(b, total_count)
			total_biz_tax += int(res.get("tax_due", 0))
			total_net_profit += int(res.get("net_profit", 0))
			total_revenue += int(res.get("revenue", 0))
			breakdowns.append(res)

	var eff_rate: float = (float(total_biz_tax) / float(maxi(1, total_net_profit))) if total_net_profit > 0 else 0.0

	return {
		"business_count": total_count,
		"total_revenue": total_revenue,
		"total_net_profit": total_net_profit,
		"tax_due": total_biz_tax,
		"effective_rate": eff_rate,
		"businesses": breakdowns
	}


# -----------------------------------------------------------------------------
# 5. CONSOLIDATED ANNUAL TAX RETURN ESTIMATION
# -----------------------------------------------------------------------------
static func calculate_tax_return(player_data: Node) -> Dictionary:
	var age: int = int(player_data.get("age"))
	var is_adult: bool = age >= 18

	# A. Income & Deductions
	var job_salary: int = int(player_data.get("job_salary")) if not bool(player_data.get("is_in_prison")) else 0
	var freelance_income: int = int(player_data.get("freelance_earnings_this_year"))
	var social_income: int = int(player_data.get("social_media_earnings_this_year"))

	# Pension annuity income if active
	var pension_annuity: int = 0
	if "pension_account" in player_data and player_data.pension_account is Dictionary:
		pension_annuity = int(player_data.pension_account.get("last_annuity_payout", 0))

	var gross_personal_income: int = job_salary + freelance_income + social_income + pension_annuity

	# Deductions: Pension retirement contributions + Charity donations made this year
	var pension_deduction: int = 0
	if "pension_account" in player_data and player_data.pension_account is Dictionary:
		pension_deduction = int(player_data.pension_account.get("last_year_contribution", 0))

	var charity_deduction: int = int(player_data.get("charity_donations_this_year"))
	var total_itemized: int = pension_deduction + charity_deduction

	var income_tax_res: Dictionary
	if is_adult:
		income_tax_res = calculate_income_tax(gross_personal_income, total_itemized)
	else:
		income_tax_res = {
			"gross_income": gross_personal_income,
			"standard_deduction": 0,
			"itemized_deductions": 0,
			"total_deductions": 0,
			"taxable_income": 0,
			"tax_due": 0,
			"effective_rate": 0.0,
			"brackets": []
		}

	# B. Capital Gains Tax
	var cap_gains: int = int(player_data.get("capital_gains_this_year"))
	var cap_losses: int = int(player_data.get("capital_losses_this_year"))
	var cap_gains_res: Dictionary
	if is_adult:
		cap_gains_res = calculate_capital_gains_tax(cap_gains, cap_losses)
	else:
		cap_gains_res = {
			"realized_gains": cap_gains,
			"realized_losses": cap_losses,
			"net_gains": 0,
			"exemption": CAPITAL_GAINS_EXEMPTION,
			"taxable_gains": 0,
			"tax_due": 0,
			"effective_rate": 0.0,
			"brackets": []
		}

	# C. Property Tax
	var property_tax_res: Dictionary = calculate_property_tax(player_data)

	# D. Business Tax
	var business_tax_res: Dictionary = calculate_total_business_taxes(player_data)

	# Total Tax Assessment
	var personal_taxes_due: int = int(income_tax_res.get("tax_due", 0)) + int(cap_gains_res.get("tax_due", 0)) + int(property_tax_res.get("tax_due", 0))
	var corporate_taxes_due: int = int(business_tax_res.get("tax_due", 0))
	var grand_total_taxes: int = personal_taxes_due + corporate_taxes_due

	return {
		"tax_year": age,
		"is_adult": is_adult,
		"income_tax": income_tax_res,
		"capital_gains_tax": cap_gains_res,
		"property_tax": property_tax_res,
		"business_tax": business_tax_res,
		"personal_taxes_due": personal_taxes_due,
		"corporate_taxes_due": corporate_taxes_due,
		"grand_total_taxes": grand_total_taxes
	}


# -----------------------------------------------------------------------------
# 6. ANNUAL TAX FILING EXECUTION (Run during age_up())
# -----------------------------------------------------------------------------
static func file_annual_taxes(player_data: Node) -> Dictionary:
	var tax_return: Dictionary = calculate_tax_return(player_data)
	var age: int = int(player_data.get("age"))
	var personal_due: int = int(tax_return.get("personal_taxes_due", 0))
	var logs: Array[String] = []

	var inc_due: int = int(tax_return.income_tax.get("tax_due", 0))
	var cap_due: int = int(tax_return.capital_gains_tax.get("tax_due", 0))
	var prop_due: int = int(tax_return.property_tax.get("tax_due", 0))

	# Only assess personal taxes if adult and tax due > 0
	if age >= 18 and personal_due > 0:
		var total_avail: int = int(player_data.get("money")) + int(player_data.get("bank_savings"))

		if total_avail >= personal_due:
			player_data.debit_funds(personal_due)
			player_data.taxes_paid_lifetime = int(player_data.get("taxes_paid_lifetime")) + personal_due
			player_data.modify_credit_score(5)

			var line_items: Array[String] = []
			if inc_due > 0: line_items.append("Income: $%s" % _format_num(inc_due))
			if cap_due > 0: line_items.append("Cap Gains: $%s" % _format_num(cap_due))
			if prop_due > 0: line_items.append("Property: $%s" % _format_num(prop_due))

			var detail_str: String = " (%s)" % " • ".join(line_items) if not line_items.is_empty() else ""
			logs.append("🏛️ ANNUAL TAX FILING: Filed annual tax return and paid $%s%s. Credit score maintained (+5 pts)." % [
				_format_num(personal_due), detail_str
			])
		else:
			# Insufficient funds -> Pay what is available, remaining becomes tax debt
			var paid: int = total_avail
			var unpaid: int = personal_due - paid
			player_data.money = 0
			player_data.bank_savings = 0
			player_data.tax_debt = int(player_data.get("tax_debt")) + unpaid
			player_data.taxes_paid_lifetime = int(player_data.get("taxes_paid_lifetime")) + paid
			player_data.modify_credit_score(-35)

			logs.append("⚠️ TAX AUDIT & DEFAULT: You could only pay $%s of your $%s annual tax assessment! The unpaid balance of $%s was added to your TAX DEBT. Credit score penalized (-35 pts)." % [
				_format_num(paid), _format_num(personal_due), _format_num(unpaid)
			])

	# Reset yearly accumulators
	player_data.capital_gains_this_year = 0
	player_data.capital_losses_this_year = 0
	if "freelance_earnings_this_year" in player_data:
		player_data.freelance_earnings_this_year = 0
	if "social_media_earnings_this_year" in player_data:
		player_data.social_media_earnings_this_year = 0
	if "charity_donations_this_year" in player_data:
		player_data.charity_donations_this_year = 0

	# Store the filed return for UI review
	player_data.last_tax_return = tax_return

	return {
		"tax_return": tax_return,
		"logs": logs
	}


# -----------------------------------------------------------------------------
# 7. HELPERS & TAX DEBT SETTLEMENT
# -----------------------------------------------------------------------------
static func record_capital_gain(player_data: Node, amount: int, source: String = "") -> void:
	if amount > 0:
		player_data.capital_gains_this_year = int(player_data.get("capital_gains_this_year")) + amount
	elif amount < 0:
		player_data.capital_losses_this_year = int(player_data.get("capital_losses_this_year")) + abs(amount)


static func pay_tax_debt(player_data: Node, amount: int = -1) -> Dictionary:
	var debt_val: int = int(player_data.get("tax_debt"))
	if debt_val <= 0:
		return {"success": false, "message": "No outstanding tax debt.", "paid": 0}

	var to_pay := debt_val if (amount <= 0 or amount > debt_val) else amount
	var avail: int = int(player_data.get("money")) + int(player_data.get("bank_savings"))
	to_pay = mini(to_pay, avail)

	if to_pay <= 0:
		return {"success": false, "message": "Insufficient funds to pay tax debt.", "paid": 0}

	player_data.debit_funds(to_pay)
	player_data.tax_debt = debt_val - to_pay
	player_data.taxes_paid_lifetime = int(player_data.get("taxes_paid_lifetime")) + to_pay

	if player_data.tax_debt == 0:
		player_data.modify_credit_score(25)
		return {
			"success": true,
			"message": "Paid off remaining $%s tax debt in full! Tax compliance restored (+25 credit score)." % _format_num(to_pay),
			"paid": to_pay
		}
	else:
		player_data.modify_credit_score(10)
		return {
			"success": true,
			"message": "Paid $%s towards tax debt. Remaining tax balance: $%s." % [_format_num(to_pay), _format_num(player_data.tax_debt)],
			"paid": to_pay
		}


static func _format_num(val: int) -> String:
	var s: String = str(abs(val))
	var res: String = ""
	var cnt: int = 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		cnt += 1
		if cnt % 3 == 0 and i > 0:
			res = "," + res
	return ("-" if val < 0 else "") + res
