class_name MortgageManager
extends RefCounted

const DOWN_PAYMENT_RATE := 0.10 # 10% down payment required
const PROPERTY_MAINTENANCE_RATE := 0.02 # 2.0% annual maintenance cost
const PROPERTY_DEPRECIATION_RATE := 0.025 # 2.5% annual depreciation

const MORTGAGE_TERMS := [
	{
		"years": 10,
		"apr": 0.045,
		"label": "10-Year Fixed Mortgage"
	},
	{
		"years": 15,
		"apr": 0.050,
		"label": "15-Year Fixed Mortgage"
	},
	{
		"years": 20,
		"apr": 0.055,
		"label": "20-Year Fixed Mortgage"
	},
	{
		"years": 30,
		"apr": 0.060,
		"label": "30-Year Fixed Mortgage"
	}
]


static func calculate_mortgage_plan(price: int, term_years: int, apr: float, down_payment_rate: float = DOWN_PAYMENT_RATE) -> Dictionary:
	var down_payment: int = int(round(float(price) * down_payment_rate))
	var principal: int = maxi(0, price - down_payment)
	var annual_principal: int = maxi(1, int(round(float(principal) / float(maxi(1, term_years)))))
	var annual_interest: int = int(round(float(principal) * apr))
	var annual_total: int = annual_principal + annual_interest

	# Calculate total interest paid over the duration
	var total_interest: int = 0
	var temp_principal: int = principal
	for _y in range(term_years):
		var y_int: int = int(round(float(temp_principal) * apr))
		total_interest += y_int
		var y_prin: int = mini(temp_principal, annual_principal)
		temp_principal -= y_prin
		if temp_principal <= 0:
			break

	return {
		"term_years": term_years,
		"apr": apr,
		"apr_pct": apr * 100.0,
		"price": price,
		"down_payment": down_payment,
		"principal": principal,
		"annual_principal": annual_principal,
		"annual_interest": annual_interest,
		"annual_payment": annual_total,
		"total_interest": total_interest,
		"total_cost": down_payment + principal + total_interest
	}


static func can_apply_mortgage(player_data: Node, price: int, term_years: int, apr: float) -> Dictionary:
	if player_data.age < 18:
		return {
			"allowed": false,
			"reason": "Legal Requirement: You must be at least 18 years old to apply for a real estate mortgage."
		}

	var plan := calculate_mortgage_plan(price, term_years, apr)
	var down_payment: int = int(plan.get("down_payment", 0))
	var total_avail: int = player_data.money + player_data.bank_savings

	if total_avail < down_payment:
		return {
			"allowed": false,
			"reason": "Insufficient Funds: Requires $%s down payment (Available: $%s)." % [
				_format_number(down_payment), _format_number(total_avail)
			]
		}

	if int(player_data.credit_score) < 580:
		return {
			"allowed": false,
			"reason": "Declined: Credit score must be at least 580 to qualify for a residential mortgage (Current: %d)." % player_data.credit_score
		}

	return {
		"allowed": true,
		"plan": plan
	}


static func apply_for_mortgage(player_data: Node, item_id: String, term_years: int, apr: float) -> Dictionary:
	var actual_id := "prop_capsule" if item_id == "prop_starter_home" else item_id
	var item: Dictionary = AssetCatalog.ITEMS.get(actual_id, {})
	if item.is_empty():
		return {
			"success": false,
			"message": "Property not found in catalog."
		}

	var price: int = int(item.get("price", 0))
	var eval := can_apply_mortgage(player_data, price, term_years, apr)
	if not bool(eval.get("allowed", false)):
		return {
			"success": false,
			"message": str(eval.get("reason", "Mortgage application declined."))
		}

	var plan: Dictionary = eval.get("plan", {})
	var down_payment: int = int(plan.get("down_payment", 0))

	# Debit down payment from player funds
	player_data.debit_funds(down_payment)

	# Grant property asset to player
	var new_asset: Dictionary = AssetCatalog.create_asset_instance(actual_id, player_data.age)
	new_asset["financed_with_mortgage"] = true
	player_data.owned_assets.append(new_asset)

	# Create mortgage record
	var instance_id: String = str(new_asset.get("instance_id", ""))
	var mortgage := {
		"id": "mtg_%s_%d_%d" % [actual_id, player_data.age, randi() % 10000],
		"property_id": actual_id,
		"property_name": str(item.get("name", "Home")),
		"instance_id": instance_id,
		"original_principal": int(plan.get("principal", 0)),
		"remaining_principal": int(plan.get("principal", 0)),
		"interest_rate": apr,
		"term_years": term_years,
		"years_left": term_years,
		"annual_principal": int(plan.get("annual_principal", 0)),
		"annual_interest": int(plan.get("annual_interest", 0)),
		"annual_payment": int(plan.get("annual_payment", 0)),
		"down_payment": down_payment
	}

	player_data.mortgages.append(mortgage)
	player_data.happiness = mini(100, player_data.happiness + int(item.get("happiness_bonus", 12)))
	player_data.modify_credit_score(5)

	if player_data.has_method("add_milestone"):
		player_data.add_milestone("Secured %d-year mortgage for %s." % [term_years, item.get("name", "Property")], player_data.age, "🏡")

	return {
		"success": true,
		"mortgage": mortgage,
		"asset": new_asset,
		"message": "Congratulations! You secured a %d-year mortgage for %s at %.1f%% APR (Paid $%s down payment, Annual: $%s/yr)." % [
			term_years, item.get("name", "Property"), apr * 100.0, _format_number(down_payment), _format_number(int(plan.get("annual_payment", 0)))
		]
	}


static func pay_off_mortgage(player_data: Node, mortgage_id: String) -> Dictionary:
	for i in range(player_data.mortgages.size()):
		var m: Dictionary = player_data.mortgages[i]
		if str(m.get("id", "")) == mortgage_id:
			var remaining: int = int(m.get("remaining_principal", 0))
			var total_avail: int = player_data.money + player_data.bank_savings
			if total_avail < remaining:
				return {
					"success": false,
					"message": "Insufficient funds to pay off remaining mortgage principal of $%s (Available: $%s)." % [
						_format_number(remaining), _format_number(total_avail)
					]
				}

			player_data.debit_funds(remaining)
			var prop_name: String = str(m.get("property_name", "Home"))
			player_data.mortgages.remove_at(i)
			player_data.modify_credit_score(15)
			if player_data.has_method("add_milestone"):
				player_data.add_milestone("Paid off full mortgage for %s." % prop_name, player_data.age, "🎉")

			return {
				"success": true,
				"message": "🎉 You fully paid off your remaining mortgage principal of $%s for %s! You now own the home free and clear." % [
					_format_number(remaining), prop_name
				]
			}

	return {
		"success": false,
		"message": "Mortgage not found."
	}


static func process_yearly_mortgages(player_data: Node) -> Array[String]:
	var logs: Array[String] = []
	for i in range(player_data.mortgages.size() - 1, -1, -1):
		var m: Dictionary = player_data.mortgages[i]
		var rem_p: int = int(m.get("remaining_principal", 0))
		var apr: float = float(m.get("interest_rate", 0.05))
		var term: int = maxi(1, int(m.get("term_years", 15)))
		var orig_p: int = int(m.get("original_principal", rem_p))
		var prop_name: String = str(m.get("property_name", "Home"))

		var ann_principal: int = maxi(1, int(round(float(orig_p) / float(term))))
		ann_principal = mini(ann_principal, rem_p)
		var ann_interest: int = int(round(float(rem_p) * apr))
		var total_payment: int = ann_principal + ann_interest

		m["annual_principal"] = ann_principal
		m["annual_interest"] = ann_interest
		m["annual_payment"] = total_payment

		var total_avail: int = player_data.money + player_data.bank_savings
		if total_avail >= total_payment:
			player_data.debit_funds(total_payment)
			m["remaining_principal"] = maxi(0, rem_p - ann_principal)
			var y_left: int = maxi(0, int(m.get("years_left", 1)) - 1)
			m["years_left"] = y_left

			logs.append("🏠 MORTGAGE PAYMENT: Paid $%s annual expense ($%s principal + $%s interest at %.1f%% APR) for %s. Remaining: $%s (%d years left)." % [
				_format_number(total_payment), _format_number(ann_principal), _format_number(ann_interest), apr * 100.0,
				prop_name, _format_number(int(m["remaining_principal"])), y_left
			])

			if y_left <= 0 or int(m["remaining_principal"]) <= 0:
				player_data.mortgages.remove_at(i)
				player_data.modify_credit_score(20)
				logs.append("🎉 MORTGAGE PAID IN FULL: Congratulations! You have fully paid off the mortgage on %s! Free and clear ownership achieved." % prop_name)
		else:
			# Shortfall handling
			var paid: int = mini(total_avail, total_payment)
			if paid > 0:
				player_data.debit_funds(paid)
			var shortfall: int = total_payment - paid
			player_data.debt += shortfall
			player_data.modify_credit_score(-15)
			logs.append("⚠️ MORTGAGE DEFAULT WARNING: Insufficient funds to make full $%s mortgage payment on %s. Paid $%s; shortfall of $%s added to debt, credit score penalized." % [
				_format_number(total_payment), prop_name, _format_number(paid), _format_number(shortfall)
			])

	return logs


static func _format_number(value: int) -> String:
	var s: String = str(absi(value))
	var result: String = ""
	var count: int = 0
	for j in range(s.length() - 1, -1, -1):
		result = s[j] + result
		count += 1
		if count % 3 == 0 and j > 0:
			result = "," + result
	return result
