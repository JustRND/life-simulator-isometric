class_name RentalManager
extends RefCounted

const RENTAL_CATALOG: Array[Dictionary] = [
	{
		"id": "rent_micro_studio",
		"name": "Micro Urban Studio",
		"monthly_rent": 550,
		"annual_rent": 6600,
		"happiness_bonus": 5,
		"desc": "A compact modern efficiency studio in the city center. Low maintenance, ideal for independent young adults starting out.",
		"image_glyph": "🏙️"
	},
	{
		"id": "rent_suburban_flat",
		"name": "Suburban 1-Bedroom Flat",
		"monthly_rent": 950,
		"annual_rent": 11400,
		"happiness_bonus": 8,
		"desc": "A bright one-bedroom apartment with a balcony and tranquil courtyard garden views. Includes underground parking.",
		"image_glyph": "🏢"
	},
	{
		"id": "rent_downtown_loft",
		"name": "Downtown High-Ceiling Loft",
		"monthly_rent": 1750,
		"annual_rent": 21000,
		"happiness_bonus": 12,
		"desc": "An industrial-chic open loft with exposed brick walls, 14-foot ceilings, polished timber floors, and quick subway access.",
		"image_glyph": "🌆"
	},
	{
		"id": "rent_townhouse_family",
		"name": "Suburban 3-Bedroom Family House",
		"monthly_rent": 3100,
		"annual_rent": 37200,
		"happiness_bonus": 16,
		"desc": "A spacious two-story detached family home with a fenced backyard, patio, double garage, and leafy neighborhood streets.",
		"image_glyph": "🏡"
	},
	{
		"id": "rent_skyline_penthouse",
		"name": "Metropolis Skyline Penthouse",
		"monthly_rent": 7200,
		"annual_rent": 86400,
		"happiness_bonus": 22,
		"desc": "A glamorous high-rise penthouse with private rooftop terrace, panoramic floor-to-ceiling glass views, and 24/7 concierge.",
		"image_glyph": "🌅"
	},
	{
		"id": "rent_coastal_villa",
		"name": "Pacific Coast Luxury Villa",
		"monthly_rent": 15000,
		"annual_rent": 180000,
		"happiness_bonus": 30,
		"desc": "An elite gated oceanfront architectural villa with private infinity pool, direct beach trail, and private manicured estate grounds.",
		"image_glyph": "🏰"
	}
]


static func get_rental_item(rental_id: String) -> Dictionary:
	for item in RENTAL_CATALOG:
		if str(item.get("id", "")) == rental_id:
			return item
	return {}


static func has_active_lease(player_data: Node) -> bool:
	if not "rented_property" in player_data:
		return false
	var rent_dict: Dictionary = player_data.rented_property
	return not rent_dict.is_empty() and str(rent_dict.get("id", "")) != ""


static func can_rent(player_data: Node, rental_id: String) -> Dictionary:
	if player_data.age < 18:
		return {
			"allowed": false,
			"reason": "Legal Requirement: You must be at least 18 years old to sign a residential lease (Currently living with family)."
		}

	var item := get_rental_item(rental_id)
	if item.is_empty():
		return {
			"allowed": false,
			"reason": "Rental property listing not found."
		}

	var ann_rent: int = int(item.get("annual_rent", 0))
	var total_avail: int = player_data.money + player_data.bank_savings
	if total_avail < ann_rent:
		return {
			"allowed": false,
			"reason": "Insufficient Funds: Requires first year's rent of $%s upfront (Available: $%s)." % [
				_format_number(ann_rent), _format_number(total_avail)
			]
		}

	return {"allowed": true, "item": item}


static func sign_lease(player_data: Node, rental_id: String) -> Dictionary:
	var check := can_rent(player_data, rental_id)
	if not bool(check.get("allowed", false)):
		return {
			"success": false,
			"message": str(check.get("reason", "Cannot sign rental lease."))
		}

	var item: Dictionary = check.get("item", {})
	var ann_rent: int = int(item.get("annual_rent", 0))
	var m_rent: int = int(item.get("monthly_rent", 0))
	var prop_name: String = str(item.get("name", "Rental Home"))

	# Debit 1st year's rent
	player_data.debit_funds(ann_rent)

	# Set rented property on player (NOTE: completely separate from owned_assets!)
	player_data.rented_property = {
		"id": rental_id,
		"name": prop_name,
		"monthly_rent": m_rent,
		"annual_rent": ann_rent,
		"happiness_bonus": int(item.get("happiness_bonus", 8)),
		"years_leased": 1,
		"lease_start_age": player_data.age,
		"image_glyph": str(item.get("image_glyph", "🏠"))
	}

	player_data.happiness = mini(100, player_data.happiness + int(item.get("happiness_bonus", 8)))

	if player_data.has_method("add_milestone"):
		player_data.add_milestone("Signed 1-year residential lease for %s." % prop_name, player_data.age, "🏠")

	return {
		"success": true,
		"message": "Congratulations! You signed a lease for %s at $%s/month ($%s/year) and moved into your new residence." % [
			prop_name, _format_number(m_rent), _format_number(ann_rent)
		]
	}


static func terminate_lease(player_data: Node) -> Dictionary:
	if not has_active_lease(player_data):
		return {
			"success": false,
			"message": "You do not currently have an active rental lease."
		}

	var old_name: String = str(player_data.rented_property.get("name", "Rental Home"))
	player_data.rented_property.clear()

	return {
		"success": true,
		"message": "You terminated your lease on %s and moved out." % old_name
	}


static func process_yearly_rent(player_data: Node) -> Array[String]:
	var logs: Array[String] = []
	if not has_active_lease(player_data):
		return logs

	var rent_dict: Dictionary = player_data.rented_property
	var ann_rent: int = int(rent_dict.get("annual_rent", 0))
	var prop_name: String = str(rent_dict.get("name", "Rental Home"))
	var total_avail: int = player_data.money + player_data.bank_savings

	if total_avail >= ann_rent:
		player_data.debit_funds(ann_rent)
		rent_dict["years_leased"] = int(rent_dict.get("years_leased", 1)) + 1
		player_data.happiness = mini(100, player_data.happiness + int(rent_dict.get("happiness_bonus", 5)))
		logs.append("🏠 RENT PAYMENT: Paid $%s for your annual lease of %s (Leased for %d years)." % [
			_format_number(ann_rent), prop_name, int(rent_dict["years_leased"])
		])
	else:
		# Cannot afford annual rent -> eviction!
		var paid: int = mini(total_avail, ann_rent)
		if paid > 0:
			player_data.debit_funds(paid)
		var shortfall: int = ann_rent - paid
		player_data.debt += shortfall
		player_data.rented_property.clear()
		player_data.happiness = maxi(0, player_data.happiness - 18)
		player_data.modify_credit_score(-20)
		logs.append("⚠️ EVICTION NOTICE: You could not afford the $%s annual rent for %s! Your lease was terminated, shortfall of $%s added to debt, and you were evicted." % [
			_format_number(ann_rent), prop_name, _format_number(shortfall)
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
