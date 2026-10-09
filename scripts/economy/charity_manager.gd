class_name CharityManager
extends RefCounted

const CHARITIES: Array[Dictionary] = [
	{
		"id": "charity_food_bank",
		"name": "Metropolitan Food Bank & Homeless Relief",
		"icon": "🍲",
		"donation_amount": 100,
		"min_age": 6,
		"hidden_karma_boost": 15,
		"happiness_boost": 15,
		"description": "Provides warm meals, hygiene kits, and emergency shelter beds to struggling families and impoverished citizens across metropolitan back alleys."
	},
	{
		"id": "charity_animal_shelter",
		"name": "City Stray Animal Rescue & Wildlife Sanctuary",
		"icon": "🐾",
		"donation_amount": 350,
		"min_age": 8,
		"hidden_karma_boost": 20,
		"happiness_boost": 20,
		"description": "Rescues abandoned pets from city streets, provides veterinary care, and rehabilitates injured native wildlife in an open eco-sanctuary."
	},
	{
		"id": "charity_youth_tech",
		"name": "Underprivileged Youth STEM & Coding Academy",
		"icon": "💻",
		"donation_amount": 1200,
		"min_age": 12,
		"hidden_karma_boost": 28,
		"happiness_boost": 22,
		"description": "Sponsors free programming bootcamps, hardware workstations, and neural-interface scholarships for low-income students in industrial districts."
	},
	{
		"id": "charity_medical_aid",
		"name": "St. Jude Medical Relief & Free Indigent Clinic",
		"icon": "🩺",
		"donation_amount": 3500,
		"min_age": 16,
		"hidden_karma_boost": 35,
		"happiness_boost": 25,
		"description": "Delivers life-saving antibiotics, neonatal support, and essential trauma surgeries to destitute patients unable to afford corporate hospital care."
	},
	{
		"id": "charity_ocean_clean",
		"name": "Global Pacific Ocean & Bio-Reef Restoration",
		"icon": "🌊",
		"donation_amount": 8000,
		"min_age": 16,
		"hidden_karma_boost": 45,
		"happiness_boost": 30,
		"description": "Deploys autonomous solar cleaning vessels to extract tons of ocean plastic, restoring fragile bioluminescent coral barrier reefs."
	},
	{
		"id": "charity_childrens_wing",
		"name": "Grand Children's Hospital Memorial Pavilion",
		"icon": "🏛️",
		"donation_amount": 50000,
		"min_age": 18,
		"hidden_karma_boost": 60,
		"happiness_boost": 35,
		"description": "Endows an advanced pediatric intensive care pavilion in your name, funding medical care for impoverished and sick children."
	}
]

static func get_all_charities() -> Array[Dictionary]:
	return CHARITIES.duplicate(true)

static func get_charity_by_id(charity_id: String) -> Dictionary:
	for c in CHARITIES:
		if str(c.get("id", "")) == charity_id:
			return c.duplicate(true)
	return {}

static func has_donated_this_year(player_data: Node) -> bool:
	var l_age = player_data.get("last_charity_donation_age")
	if l_age is int:
		return l_age == player_data.age
	elif l_age is Dictionary:
		for v in l_age.values():
			if int(v) == player_data.age:
				return true
	return false

static func can_donate(player_data: Node, charity_id: String) -> Dictionary:
	var def := get_charity_by_id(charity_id)
	if def.is_empty():
		return {"allowed": false, "reason": "Charity organization not found."}

	var min_age: int = int(def.get("min_age", 6))
	if player_data.age < min_age:
		return {
			"allowed": false,
			"reason": "Age Restricted: Must be at least Age %d+ to make this donation (Current Age: %d)." % [min_age, player_data.age]
		}

	# Ensure player can only donate once a year across all charities
	if has_donated_this_year(player_data):
		return {
			"allowed": false,
			"reason": "Annual Donation Made: You can only donate once per year (Age %d). Contributions reset next year." % player_data.age
		}

	var cost: int = int(def.get("donation_amount", 100))
	var total_funds: int = player_data.money + player_data.bank_savings
	if total_funds < cost:
		return {
			"allowed": false,
			"reason": "Insufficient funds: Donation is $%d (Available Funds: $%d)." % [cost, total_funds]
		}

	return {"allowed": true, "reason": "Ready to donate."}

static func donate(player_data: Node, charity_id: String) -> Dictionary:
	var eval := can_donate(player_data, charity_id)
	if not bool(eval.get("allowed", false)):
		return eval

	var def := get_charity_by_id(charity_id)
	var cost: int = int(def.get("donation_amount", 100))

	# Debit funds: cash first, then bank savings
	player_data.debit_funds(cost)

	# Record donation age (only once a year allowed)
	player_data.last_charity_donation_age = player_data.age

	# Karma and Happiness boosts (strictly non-permanent stat additions)
	var karma_boost: int = int(def.get("hidden_karma_boost", 15))
	var hap_boost: int = int(def.get("happiness_boost", 15))

	player_data.karma = clampi(player_data.karma + karma_boost, 0, 100)
	player_data.happiness = clampi(player_data.happiness + hap_boost, 0, 100)

	# Track donation history if properties exist
	if "total_donated_charity" in player_data:
		player_data.total_donated_charity += cost
	if "charity_donations_count" in player_data:
		player_data.charity_donations_count += 1

	var c_name: String = str(def.get("name", "Charity"))
	var msg: String = "You contributed $%d to %s.\nYour generous donation elevated your karma and brought deep joy (+%d%% Happiness)!" % [cost, c_name, hap_boost]

	return {
		"allowed": true,
		"success": true,
		"message": msg,
		"charity": def
	}
