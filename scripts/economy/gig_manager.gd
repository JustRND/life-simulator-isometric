class_name GigManager
extends RefCounted

# =============================================================================
# GIG MANAGER
# Life.exe Reusable On-Demand Gig Work System.
# Manages assignments, monthly limits, reputation progression, skill checks,
# instant per-task payouts, and tax ledger recording.
# =============================================================================

const DailyJobsCatalogScript = preload("res://scripts/economy/daily_jobs_catalog.gd")

const MAX_GIGS_PER_MONTH := 4

# Reputation Tiers
const REPUTATION_TIERS: Array[Dictionary] = [
	{"min_pts": 0,   "title": "Novice",            "pay_mult": 1.00, "badge": "🌱"},
	{"min_pts": 30,  "title": "Experienced",       "pay_mult": 1.15, "badge": "⭐"},
	{"min_pts": 75,  "title": "Specialist",        "pay_mult": 1.30, "badge": "🔥"},
	{"min_pts": 150, "title": "Master Freelancer", "pay_mult": 1.50, "badge": "👑"}
]

# Specific thematic gig assignment templates
const GIG_TEMPLATES: Dictionary = {
	"food_delivery_rider": [
		{"client": "Downtown Sushi", "task": "Deliver 4 bento boxes to a financial district high-rise.", "bonus": 5},
		{"client": "Neon Burger Bar", "task": "Rush delivery of midnight burgers across the rainy district.", "bonus": 8},
		{"client": "Artisan Pizza Co.", "task": "Transport 3 piping-hot gourmet pizzas to a suburban birthday party.", "bonus": 6}
	],
	"package_courier": [
		{"client": "Law Offices of Vance & Co.", "task": "Deliver urgent notarized contracts across town before closing.", "bonus": 10},
		{"client": "CyberTech Labs", "task": "Hand-carry delicate optical microchips to a testing facility.", "bonus": 12},
		{"client": "City Architectural Studio", "task": "Transport architectural blueprints to an active job site.", "bonus": 8}
	],
	"freelance_graphic_designer": [
		{"client": "Indie Coffee Roastery", "task": "Design a minimalist vector logo and coffee bean pouch packaging.", "bonus": 25},
		{"client": "Synthetix Apparel", "task": "Illustrate a futuristic cyberpunk cyber-jacket graphic for streetwear.", "bonus": 30},
		{"client": "Solaria Wellness Spa", "task": "Create modern social media banner ads and promotional flyers.", "bonus": 20}
	],
	"freelance_writer": [
		{"client": "TechPulse Magazine", "task": "Write a 1,200-word investigative article on clean energy breakthroughs.", "bonus": 20},
		{"client": "Culinary Explorer Blog", "task": "Draft a lively review of hidden downtown street food stalls.", "bonus": 15},
		{"client": "Apex Software Solutions", "task": "Polish customer documentation and write release notes for an app update.", "bonus": 18}
	],
	"private_tutor": [
		{"client": "The Henderson Family", "task": "Tutor a 7th grader through polynomial algebra homework.", "bonus": 12},
		{"client": "The Nakamura Family", "task": "Help a high school sophomore study for a chemistry final exam.", "bonus": 15},
		{"client": "The Miller Family", "task": "Review essay grammar, thesis structure, and historical references.", "bonus": 10}
	],
	"pet_sitter": [
		{"client": "Mrs. Gable", "task": "Walk two energetic golden retrievers through Maple Park and play fetch.", "bonus": 10},
		{"client": "Dr. Aris Thorne", "task": "Feed a pair of Siamese felines and change water fountain filters.", "bonus": 8},
		{"client": "The Vance Household", "task": "Host an adorable corgi for an afternoon of outdoor agility play.", "bonus": 12}
	],
	"photographer": [
		{"client": "Boutique Fashion Label", "task": "Shoot an editorial lookbook featuring summer streetwear.", "bonus": 25},
		{"client": "City Real Estate Agency", "task": "Photograph interior staging of a renovated penthouse condo.", "bonus": 30},
		{"client": "Local Indie Rock Band", "task": "Capture dynamic live stage photos during an underground music gig.", "bonus": 20}
	]
}


# =============================================================================
# CAPACITY & AVAILABILITY
# =============================================================================

static func get_monthly_capacity(_player_data: Node) -> int:
	return MAX_GIGS_PER_MONTH


# Compatibility alias for older callers. Gig capacity is now monthly.
static func get_daily_capacity(player_data: Node) -> int:
	return get_monthly_capacity(player_data)


static func get_gigs_completed_this_month(player_data: Node) -> int:
	if player_data == null:
		return 0
	_ensure_month_reset(player_data)
	return int(player_data.get("gigs_completed_this_month")) if player_data.get("gigs_completed_this_month") != null else 0


# Compatibility alias for older callers. The counter is now monthly.
static func get_gigs_completed_today(player_data: Node) -> int:
	return get_gigs_completed_this_month(player_data)


static func get_remaining_capacity(player_data: Node) -> int:
	return maxi(0, get_monthly_capacity(player_data) - get_gigs_completed_this_month(player_data))


static func can_accept_gig(player_data: Node) -> Dictionary:
	if player_data == null or bool(player_data.get("is_dead")):
		return {"allowed": false, "reason": "Character unavailable."}
	if bool(player_data.get("is_in_prison")):
		return {"allowed": false, "reason": "Cannot perform gig work while incarcerated."}
	if bool(player_data.get("is_in_mental_institution")):
		return {"allowed": false, "reason": "Cannot perform gig work while under inpatient care."}
	var cur_hl: int = int(player_data.get("health")) if player_data.get("health") != null else 100
	if cur_hl <= 15:
		return {"allowed": false, "reason": "You are too sick or exhausted to work gigs today. Rest and recover."}
	if get_remaining_capacity(player_data) <= 0:
		var cap := get_monthly_capacity(player_data)
		return {
			"allowed": false,
			"reason": "Monthly gig limit reached (%d/%d completed this month). Available again next month." % [cap, cap]
		}
	return {"allowed": true, "reason": "Ready"}


static func _ensure_month_reset(player_data: Node) -> void:
	if player_data == null:
		return
	var cur_y: int = int(player_data.get("in_game_year")) if player_data.get("in_game_year") != null else 2026
	var cur_m: int = int(player_data.get("in_game_month")) if player_data.get("in_game_month") != null else 1
	if Engine.has_singleton("GameClock"):
		var gc = Engine.get_singleton("GameClock")
		cur_y = gc.year
		cur_m = gc.month

	var last_month: Dictionary = player_data.get("last_gig_month") if player_data.get("last_gig_month") is Dictionary else {}
	if last_month.get("year", 0) != cur_y or last_month.get("month", 0) != cur_m:
		player_data.gigs_completed_this_month = 0
		player_data.last_gig_month = {"year": cur_y, "month": cur_m}


# =============================================================================
# REPUTATION & PROGRESSION
# =============================================================================

static func get_reputation_points(player_data: Node, gig_type: String = "") -> int:
	if player_data == null or not ("gig_reputation" in player_data):
		return 0
	var rep_dict: Dictionary = player_data.gig_reputation
	if gig_type != "":
		return int(rep_dict.get(gig_type, 0))
	var total: int = 0
	for pts in rep_dict.values():
		total += int(pts)
	return total


static func get_reputation_tier(points: int) -> Dictionary:
	var active_tier: Dictionary = REPUTATION_TIERS[0]
	for t in REPUTATION_TIERS:
		if points >= int(t["min_pts"]):
			active_tier = t
	return active_tier


static func add_reputation(player_data: Node, gig_type: String, points: int) -> void:
	if player_data == null:
		return
	if not ("gig_reputation" in player_data):
		player_data.gig_reputation = {}
	var cur := int(player_data.gig_reputation.get(gig_type, 0))
	player_data.gig_reputation[gig_type] = cur + points


# =============================================================================
# GIG POOL GENERATION
# =============================================================================

static func generate_available_gigs(player_data: Node) -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	var base_gigs := DailyJobsCatalogScript.get_gigs()
	var player_age: int = int(player_data.get("age")) if (player_data != null and player_data.get("age") != null) else 17

	for g in base_gigs:
		var g_id: String = str(g.get("id", ""))
		var min_age: int = int(g.get("min_age", 16))
		if player_age < min_age:
			continue

		var rep_pts := get_reputation_points(player_data, g_id)
		var tier_info := get_reputation_tier(rep_pts)
		var pay_mult: float = float(tier_info.get("pay_mult", 1.0))

		var templates: Array = GIG_TEMPLATES.get(g_id, [])
		var template: Dictionary = templates.pick_random() if not templates.is_empty() else {
			"client": "Local Client",
			"task": "Complete standard assignment on schedule.",
			"bonus": 0
		}

		var base_pay: int = int(g.get("daily_wage", 40))
		var bonus_val: int = int(template.get("bonus", 0))
		var total_est_pay: int = int(round(float(base_pay + bonus_val) * pay_mult))

		var gig_instance := {
			"gig_id": g_id,
			"title": str(g.get("title", "")),
			"category": str(g.get("category", "")),
			"payment_type": DailyJobsCatalogScript.PAYMENT_TYPE_PER_TASK,
			"client_name": str(template.get("client", "Client")),
			"task_description": str(template.get("task", "")),
			"base_pay": base_pay,
			"bonus_pay": bonus_val,
			"payout": total_est_pay,
			"min_age": min_age,
			"hours": int(g.get("hours_per_shift", 2)),
			"requirements": g.get("requirements", {}),
			"stat_effects": g.get("stat_effects", {}),
			"reputation_tier": tier_info.get("title", "Novice"),
			"reputation_badge": tier_info.get("badge", "🌱"),
			"reputation_points": rep_pts
		}
		available.append(gig_instance)

	return available


# =============================================================================
# GIG EXECUTION & SETTLEMENT
# =============================================================================

static func complete_gig(player_data: Node, gig: Dictionary) -> Dictionary:
	var check := can_accept_gig(player_data)
	if not bool(check.get("allowed", false)):
		return {
			"success": false,
			"reason": str(check.get("reason", "Ineligible")),
			"earned_net": 0,
			"earned_gross": 0,
			"tax_withheld": 0
		}

	var age: int = int(player_data.get("age")) if player_data.get("age") != null else 17
	var min_age: int = int(gig.get("min_age", 16))
	if age < min_age:
		return {
			"success": false,
			"reason": "Age restriction: Must be at least %d years old." % min_age,
			"earned_net": 0,
			"earned_gross": 0,
			"tax_withheld": 0
		}

	# Check stat requirements
	var reqs: Dictionary = gig.get("requirements", {})
	var hl: int = int(player_data.get("health")) if player_data.get("health") != null else 100
	var sm: int = int(player_data.get("smarts")) if player_data.get("smarts") != null else 50
	var lk: int = int(player_data.get("looks")) if player_data.get("looks") != null else 50
	var hp: int = int(player_data.get("happiness")) if player_data.get("happiness") != null else 50

	if reqs.has("min_health") and hl < int(reqs["min_health"]):
		return {"success": false, "reason": "Requires at least %d Health." % int(reqs["min_health"]), "earned_net": 0}
	if reqs.has("min_smarts") and sm < int(reqs["min_smarts"]):
		return {"success": false, "reason": "Requires at least %d Smarts." % int(reqs["min_smarts"]), "earned_net": 0}
	if reqs.has("min_looks") and lk < int(reqs["min_looks"]):
		return {"success": false, "reason": "Requires at least %d Looks." % int(reqs["min_looks"]), "earned_net": 0}
	if reqs.has("min_happiness") and hp < int(reqs["min_happiness"]):
		return {"success": false, "reason": "Requires at least %d Happiness." % int(reqs["min_happiness"]), "earned_net": 0}

	# Payout calculations
	var gross_pay: int = int(gig.get("payout", 40))
	var tax_withheld: int = 0
	# Tax withholding applies only to legal adults (>= 18)
	if age >= 18:
		# 10% standard withholding on gig earnings
		tax_withheld = int(round(float(gross_pay) * 0.10))

	var net_pay: int = gross_pay - tax_withheld

	# Deposit net pay to player money
	var cur_m: int = int(player_data.get("money")) if player_data.get("money") != null else 0
	player_data.money = cur_m + net_pay

	# Track earnings and tax withholding
	if "gig_earnings_this_year" in player_data:
		var cur_ge: int = int(player_data.get("gig_earnings_this_year")) if player_data.get("gig_earnings_this_year") != null else 0
		player_data.gig_earnings_this_year = cur_ge + gross_pay
	if tax_withheld > 0:
		if "taxes_withheld_this_year" in player_data:
			var cur_tw: int = int(player_data.get("taxes_withheld_this_year")) if player_data.get("taxes_withheld_this_year") != null else 0
			player_data.taxes_withheld_this_year = cur_tw + tax_withheld
		if "taxes_paid_lifetime" in player_data:
			var cur_tpl: int = int(player_data.get("taxes_paid_lifetime")) if player_data.get("taxes_paid_lifetime") != null else 0
			player_data.taxes_paid_lifetime = cur_tpl + tax_withheld

	# Shared monthly capacity increment
	_ensure_month_reset(player_data)
	var cur_done: int = int(player_data.get("gigs_completed_this_month")) if player_data.get("gigs_completed_this_month") != null else 0
	player_data.gigs_completed_this_month = cur_done + 1

	# Build reputation
	var g_id: String = str(gig.get("gig_id", ""))
	var rep_gained: int = randi_range(8, 14)
	add_reputation(player_data, g_id, rep_gained)

	# Apply stat effects
	var effects: Dictionary = gig.get("stat_effects", {})
	if effects.has("happiness_delta"):
		var cur_hap: int = int(player_data.get("happiness")) if player_data.get("happiness") != null else 50
		player_data.happiness = clampi(cur_hap + int(effects["happiness_delta"]), 0, 100)
	if effects.has("health_delta"):
		var cur_hea: int = int(player_data.get("health")) if player_data.get("health") != null else 100
		player_data.health = clampi(cur_hea + int(effects["health_delta"]), 0, 100)
	if effects.has("mental_state_delta"):
		var cur_men: int = int(player_data.get("mental_state")) if player_data.get("mental_state") != null else 100
		player_data.mental_state = clampi(cur_men + int(effects["mental_state_delta"]), 0, 100)
	if effects.has("smarts_gain"):
		var cur_sma: int = int(player_data.get("smarts")) if player_data.get("smarts") != null else 50
		player_data.smarts = clampi(cur_sma + int(effects["smarts_gain"]), 0, 100)

	# Record transaction with separated gross, withholding, and net
	var date_label: String = ""
	if Engine.has_singleton("GameClock"):
		var gc = Engine.get_singleton("GameClock")
		date_label = "%s %d, %d" % [DailyJobsCatalogScript.get_day_name(DailyJobsCatalogScript.calculate_day_of_week(gc.year, gc.month, gc.day)), gc.day, gc.year]
	else:
		date_label = "Day %d" % (int(player_data.get("in_game_day")) if player_data.get("in_game_day") != null else 1)

	var desc_str := "Gig: %s (%s) [Gross: $%d, Tax: $%d]" % [
		str(gig.get("title")),
		str(gig.get("client_name", "Client")),
		gross_pay,
		tax_withheld
	]

	if player_data.has_method("record_transaction"):
		var b_after: int = (int(player_data.get("money")) if player_data.get("money") != null else 0) + (int(player_data.get("bank_savings")) if player_data.get("bank_savings") != null else 0)
		var d_after: int = int(player_data.get("debt")) if player_data.get("debt") != null else 0
		var entry := {
			"date": date_label,
			"age": age,
			"category": "payroll",
			"amount": net_pay,
			"type": "income",
			"description": desc_str,
			"balance_after": b_after,
			"debt_after": d_after,
			"gross_pay": gross_pay,
			"tax_withheld": tax_withheld,
			"net_pay": net_pay
		}
		player_data.transaction_history.append(entry)
		if player_data.transaction_history.size() > 500:
			player_data.transaction_history.pop_front()

	# Add to gig history
	if "gig_history" in player_data and player_data.gig_history is Array:
		player_data.gig_history.append({
			"title": gig.get("title"),
			"client": gig.get("client_name"),
			"gross_pay": gross_pay,
			"tax_withheld": tax_withheld,
			"net_pay": net_pay,
			"reputation_gained": rep_gained,
			"date": date_label
		})
		if player_data.gig_history.size() > 50:
			player_data.gig_history.pop_front()

	return {
		"success": true,
		"title": str(gig.get("title")),
		"client": str(gig.get("client_name")),
		"earned_gross": gross_pay,
		"tax_withheld": tax_withheld,
		"earned_net": net_pay,
		"reputation_gained": rep_gained,
		"remaining_capacity": get_remaining_capacity(player_data),
		"reason": "Gig completed successfully!"
	}
