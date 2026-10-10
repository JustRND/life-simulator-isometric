extends RefCounted

const GIFTS := [
	{"emoji": "💐", "name": "Wildflower Bouquet", "cost": 50, "joy": 4},
	{"emoji": "🌹", "name": "Rose Bouquet", "cost": 150, "joy": 8},
	{"emoji": "💍", "name": "Silver Engagement Ring", "cost": 500, "joy": 12},
	{"emoji": "💎", "name": "Diamond Engagement Ring", "cost": 2500, "joy": 20},
	{"emoji": "👑", "name": "Platinum Heirloom Ring", "cost": 7500, "joy": 30}
]

static func engaged(player: Node) -> bool:
	return player.has_partner() and player.get_partner_status() in ["Fiancé", "Fiancée"]

static func normalize(player: Node) -> void:
	if not player.has_partner():
		return
	if not player.partner.has("happiness"):
		player.partner["happiness"] = 50
	# Legacy engagements begin their waiting period at the age they are loaded.
	if engaged(player) and not player.partner.has("engaged_age"):
		player.partner["engaged_age"] = player.age
	if player.has_method("is_married") and player.is_married():
		if player.has_method("update_partner_family_name_on_marriage"):
			var cur_p_name: String = str(player.partner.get("name", "")).strip_edges()
			var fam: String = player.get_family_name()
			var tokens: PackedStringArray = cur_p_name.split(" ", false)
			if tokens.size() <= 1 or (not fam.is_empty() and tokens[tokens.size() - 1] != fam):
				player.update_partner_family_name_on_marriage()

static func can_marry(player: Node) -> bool:
	normalize(player)
	return engaged(player) and not player.is_dead and player.age >= 18 and player.age > int(player.partner["engaged_age"])

static func date_result(player: Node, candidate: Dictionary, accepted: bool, roll: float) -> String:
	if player.is_dead or player.is_in_prison or player.age < 18 or player.has_partner() or int(candidate.get("age", 0)) < 18:
		return ""
	var name := str(candidate.get("name", "Your date"))
	if not accepted:
		return "You politely declined %s's invitation to go on a date." % name
	var chance := clampf(0.35 + float(candidate.get("compatibility", 50)) * 0.003 + float(player.looks) * 0.001, 0.25, 0.85)
	if roll < chance:
		player.partner = candidate.duplicate(true)
		player.partner.merge({"status": "Girlfriend" if candidate.get("gender") == "FEMALE" else "Boyfriend", "relationship": 78, "happiness": 65, "years_together": 0, "is_alive": true}, true)
		player.last_partner_interact_age = player.age
		player.happiness = clampi(player.happiness + 12, 0, 100)
		return "Your date with %s went wonderfully! You both decided to start a relationship." % name
	player.happiness = clampi(player.happiness - 8, 0, 100)
	return "Your date with %s failed to leave a good impression. There was no romantic connection." % name

static func propose(player: Node, gift_ids: Array, roll: float) -> String:
	if player.is_dead or player.age < 18 or not player.has_partner() or player.get_partner_status() not in ["Boyfriend", "Girlfriend"]:
		return ""
	var cost := 0
	var joy := 0
	var names: Array[String] = []
	var seen: Array = []
	for id in gift_ids:
		if not id is int or id < 0 or id >= GIFTS.size() or seen.has(id):
			return ""
		seen.append(id)
		cost += int(GIFTS[id].cost)
		joy += int(GIFTS[id].joy)
		names.append(GIFTS[id].name)
	if seen.is_empty() or not player.can_afford(cost):
		return ""
	normalize(player)
	player.debit_funds(cost)
	player.partner["happiness"] = clampi(int(player.partner.happiness) + joy, 0, 100)
	player.set_partner_relationship(player.get_partner_relationship() + mini(15, int(joy * 0.5)))
	player.last_partner_interact_age = player.age
	var intro := "💍 You gave %s %s ($%d). " % [player.get_partner_name(), ", ".join(names), cost]
	var chance := clampf(float(player.get_partner_relationship()) / 100.0 + float(joy) / 300.0, 0.1, 0.95)
	if roll < chance:
		player.partner["status"] = "Fiancée" if player.partner.get("gender") == "FEMALE" else "Fiancé"
		player.partner["engaged_age"] = player.age
		player.partner["last_delay_age"] = player.age
		player.happiness = clampi(player.happiness + 20, 0, 100)
		return intro + "They accepted your proposal! You are engaged. You can marry from age %d." % (player.age + 1)
	player.happiness = clampi(player.happiness - 10, 0, 100)
	return intro + "They appreciated the gifts but were not ready to get engaged."

static func delay_wedding(player: Node, explicit_postpone: bool = false) -> String:
	if player.is_dead or not engaged(player):
		return ""
	normalize(player)
	var engaged_age := int(player.partner.engaged_age)
	if player.age <= engaged_age or int(player.partner.get("last_delay_age", engaged_age)) >= player.age:
		return ""
	# The first eligible wedding year is a grace period until explicitly postponed.
	if not explicit_postpone and player.age <= engaged_age + 1:
		return ""
	var years_delayed: int = player.age - engaged_age - (0 if explicit_postpone else 1)
	var count := maxi(int(player.partner.get("delay_count", 0)) + 1, years_delayed)
	player.partner["delay_count"] = count
	player.partner["last_delay_age"] = player.age
	var loss := mini(30, count * 4)
	var sadness := mini(20, count * 3)
	player.set_partner_relationship(player.get_partner_relationship() - loss)
	player.partner["happiness"] = clampi(int(player.partner.happiness) - sadness, 0, 100)
	player.happiness = clampi(player.happiness - sadness, 0, 100)
	return "Your wedding with %s remains postponed. The growing uncertainty strains your bond. Relationship -%d; your happiness and partner happiness -%d." % [player.get_partner_name(), loss, sadness]

static func marry(player: Node, cost: int, ceremony: String, happiness_gain: int = 35) -> String:
	if not can_marry(player) or cost < 0 or not player.can_afford(cost):
		return ""
	player.debit_funds(cost)
	player.partner["status"] = "Wife" if player.partner.get("gender") == "FEMALE" else "Husband"
	player.partner["married_age"] = player.age
	player.set_partner_relationship(player.get_partner_relationship() + 20)
	player.partner["happiness"] = clampi(int(player.partner.happiness) + happiness_gain, 0, 100)
	player.happiness = clampi(player.happiness + happiness_gain, 0, 100)
	player.last_partner_interact_age = player.age
	if player.has_method("update_partner_family_name_on_marriage"):
		player.update_partner_family_name_on_marriage()
	return "💍 MARRIED: You and %s celebrated your %s ($%d)! Both partners' happiness +%d." % [player.get_partner_name(), ceremony, cost, happiness_gain]
