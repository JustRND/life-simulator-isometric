class_name VenueManager
extends RefCounted

## VenueManager coordinates venue entry checks, dining and beverage orders,
## intoxication and hangover mechanics, discrete activities, and NPC social interactions.

const VenueCatalog = preload("res://scripts/venues/venue_catalog.gd")
const NameCatalog = preload("res://scripts/core/name_catalog.gd")
const PortraitCatalog = preload("res://scripts/core/portrait_catalog.gd")
const NpcLifeProgress = preload("res://scripts/core/npc_life_progress.gd")
const RomanceRules = preload("res://scripts/core/romance_rules.gd")

const PERSONALITY_POOL: Array[String] = [
	"Outgoing & Charismatic",
	"Analytical & Witty",
	"Creative & Dreamy",
	"Adventurous & Bold",
	"Laid-back & Easygoing",
	"Passionate & Energetic",
	"Thoughtful & Empathetic",
	"Charming & Sophisticated"
]

const INTERESTS_POOL: Array[String] = [
	"Live Music & Synth",
	"Gourmet Gastronomy",
	"Indie Gaming & VR",
	"Literature & Sci-Fi",
	"Craft Mixology & Roasting",
	"Fitness & Bouldering",
	"Modern Architecture",
	"Astronomy & Space",
	"Cinema & Stand-Up Comedy",
	"Digital Art & Photography"
]

# -----------------------------------------------------------------------------
# 1. ENTRY & COVER CHARGE
# -----------------------------------------------------------------------------

static func can_enter_venue(player: Node, venue: Dictionary) -> Dictionary:
	if player == null or venue.is_empty():
		return {"allowed": false, "reason": "invalid_parameters", "message": "Invalid venue or player data."}

	var p_age: int = int(player.get("age"))
	var min_age: int = int(venue.get("min_age", 0))

	# Age Gate Enforcement
	if p_age < min_age:
		var v_name: String = str(venue.get("name", "this venue"))
		return {
			"allowed": false,
			"reason": "age",
			"message": "🔞 Entry Denied: You must be at least %d years old to enter %s (Current age: %d)." % [min_age, v_name, p_age]
		}

	# Cover Charge Affordability
	var cover: int = int(venue.get("cover_charge", 0))
	if cover > 0 and not player.can_afford(cover):
		return {
			"allowed": false,
			"reason": "funds",
			"message": "💸 Entry Denied: You cannot afford the $%d cover charge for %s." % [cover, str(venue.get("name", "Venue"))]
		}

	return {"allowed": true, "reason": "ok", "message": "Welcome to %s." % str(venue.get("name", "Venue"))}


static func pay_cover_charge(player: Node, venue: Dictionary) -> Dictionary:
	var cover: int = int(venue.get("cover_charge", 0))
	if cover <= 0:
		return {"success": true, "cost": 0, "message": "Free admission."}

	if not player.can_afford(cover):
		return {"success": false, "cost": 0, "message": "Cannot afford cover charge."}

	if not player.debit_funds(cover):
		return {"success": false, "cost": 0, "message": "Payment processing failed."}

	var v_name: String = str(venue.get("name", "Venue"))
	player.record_transaction("Entertainment", -cover, "Cover charge for %s" % v_name)
	player.record_venue_visit(str(venue.get("id", "")), "cover_charge", cover)

	return {
		"success": true,
		"cost": cover,
		"message": "Paid $%d cover charge for %s." % [cover, v_name]
	}


# -----------------------------------------------------------------------------
# 2. MENU PURCHASES & REFRESHMENTS
# -----------------------------------------------------------------------------

static func order_menu_item(player: Node, venue: Dictionary, item: Dictionary, companion_mode: String = "solo", companion_data: Dictionary = {}) -> Dictionary:
	if player == null or venue.is_empty() or item.is_empty():
		return {"success": false, "message": "Invalid order details."}

	var p_age: int = int(player.get("age"))
	var alc: int = int(item.get("alcohol_level", 0))

	# Alcohol Age Verification (Strictly enforced at legal drinking age)
	if alc > 0 and p_age < VenueCatalog.LEGAL_DRINKING_AGE:
		return {
			"success": false,
			"message": "🔞 ID Check Failed: The bartender refuses service. You must be at least %d years old to purchase alcoholic beverages (Current age: %d)." % [VenueCatalog.LEGAL_DRINKING_AGE, p_age]
		}

	var base_price: int = int(item.get("price", 0))
	var total_price: int = base_price

	if companion_mode in ["friend", "date"]:
		total_price = base_price * 2 # Player covers both themselves and companion

	if not player.can_afford(total_price):
		return {
			"success": false,
			"message": "💸 Insufficient Funds: You need $%d for this purchase (Available: $%d)." % [total_price, player.get_available_funds()]
		}

	if not player.debit_funds(total_price):
		return {"success": false, "message": "Transaction declined. Funds could not be debited."}

	# Transaction history integration
	var item_name: String = str(item.get("name", "Item"))
	var venue_name: String = str(venue.get("name", "Venue"))
	var trans_desc: String = "%s at %s" % [item_name, venue_name]

	if companion_mode == "date":
		trans_desc += " (Date with %s)" % player.get_partner_name()
	elif companion_mode == "friend":
		trans_desc += " (With %s)" % str(companion_data.get("name", "a friend"))

	player.record_transaction("Food & Dining", -total_price, trans_desc)

	# Apply Hunger, Thirst, Health, and Happiness
	var hunger_delta: float = float(item.get("hunger", 0.0))
	var thirst_delta: float = float(item.get("thirst", 0.0))
	var health_delta: int = int(item.get("health", 0))
	var happiness_delta: int = int(item.get("happiness", 0))

	if hunger_delta > 0.0:
		player.modify_hunger(hunger_delta)
	if thirst_delta > 0.0:
		player.modify_thirst(thirst_delta)
	if health_delta != 0:
		player.modify_health(health_delta)
	if happiness_delta != 0:
		player.modify_happiness(happiness_delta)

	# Intoxication and Alcohol Dynamics
	var consequence_text: String = ""
	if alc > 0:
		var current_intox: int = player.apply_intoxication(alc)
		if current_intox >= 80:
			# Non-graphic excessive drinking consequence
			var roll := randf()
			if roll < 0.35:
				consequence_text = "⚠️ Intoxication: You felt clumsy and spilled some drink on your sleeve (-5 Happiness)."
				player.modify_happiness(-5)
			elif roll < 0.70 and player.get_available_funds() >= 30:
				consequence_text = "💸 Foggy Judgment: Feeling overly generous in your buzz, you tipped the staff an extra $30."
				player.debit_funds(30)
				player.record_transaction("Entertainment", -30, "Overly generous tip at %s" % venue_name)
			else:
				consequence_text = "😵 Buzz Warning: The room is spinning slightly. Remember to hydrate and stay safe!"
	else:
		# Non-alcoholic refreshments provide clear-headed well-being
		if item.get("type", "") == "drink":
			consequence_text = "✨ You enjoyed a refreshing, non-alcoholic drink, staying hydrated and clear-headed."

	# Companion relationship reactions
	var companion_feedback: String = ""
	if companion_mode == "date" and player.has_partner():
		var p_boost: int = 6
		if str(venue.get("category", "")) == "fine_dining":
			p_boost = 14
		elif str(venue.get("category", "")) == "cafes":
			p_boost = 8

		player.set_partner_relationship(player.get_partner_relationship() + p_boost)
		if player.partner is Dictionary and player.partner.has("happiness"):
			player.partner["happiness"] = clampi(int(player.partner.happiness) + p_boost, 0, 100)
		companion_feedback = "❤️ %s had a wonderful time sharing %s with you! (Relationship +%d)" % [player.get_partner_name(), item_name, p_boost]

	elif companion_mode == "friend" and not companion_data.is_empty():
		var f_id: String = str(companion_data.get("id", ""))
		var f_name: String = str(companion_data.get("name", "Friend"))
		var f_boost: int = 10
		player.modify_friend_relationship(f_id, f_boost)
		companion_feedback = "🤝 %s loved catching up over %s! (Friendship +%d)" % [f_name, item_name, f_boost]

	# Record venue visit
	player.record_venue_visit(str(venue.get("id", "")), str(item.get("id", "")), total_price)

	var success_msg: String = "Purchased %s for $%d." % [item_name, total_price]
	if companion_feedback != "":
		success_msg += "\n" + companion_feedback
	if consequence_text != "":
		success_msg += "\n" + consequence_text

	return {
		"success": true,
		"message": success_msg,
		"item": item,
		"total_price": total_price,
		"consequence": consequence_text,
		"companion_mode": companion_mode
	}


# -----------------------------------------------------------------------------
# 3. VENUE ACTIVITIES (Dancing, VIP Lounge, Trivia, etc.)
# -----------------------------------------------------------------------------

static func perform_activity(player: Node, venue: Dictionary, activity: Dictionary, companion_mode: String = "solo", companion_data: Dictionary = {}) -> Dictionary:
	if player == null or venue.is_empty() or activity.is_empty():
		return {"success": false, "message": "Invalid activity parameters."}

	var p_age: int = int(player.get("age"))
	var min_age: int = int(venue.get("min_age", 0))

	if p_age < min_age:
		return {
			"success": false,
			"message": "🔞 Underage: You must be at least %d years old to participate in activities here." % min_age
		}

	var cost: int = int(activity.get("cost", 0))
	if cost > 0:
		if not player.can_afford(cost):
			return {"success": false, "message": "💸 You cannot afford this activity ($%d needed)." % cost}
		if not player.debit_funds(cost):
			return {"success": false, "message": "Payment processing failed."}

		var v_name: String = str(venue.get("name", "Venue"))
		var act_name: String = str(activity.get("name", "Activity"))
		player.record_transaction("Entertainment", -cost, "%s at %s" % [act_name, v_name])

	# Stat adjustments
	var hap_gain: int = int(activity.get("happiness", 0))
	var hunger_burn: float = float(activity.get("hunger_cost", 0.0))
	var thirst_burn: float = float(activity.get("thirst_cost", 0.0))
	var health_eff: int = int(activity.get("health_effect", 0))

	if hap_gain > 0:
		player.modify_happiness(hap_gain)
	if hunger_burn > 0.0:
		player.modify_hunger(-hunger_burn)
	if thirst_burn > 0.0:
		player.modify_thirst(-thirst_burn)
	if health_eff != 0:
		player.modify_health(health_eff)

	# Companion reactions
	var comp_note: String = ""
	if companion_mode == "date" and player.has_partner():
		var p_gain: int = 10
		player.set_partner_relationship(player.get_partner_relationship() + p_gain)
		comp_note = "❤️ %s thoroughly enjoyed the experience with you! (Relationship +%d)" % [player.get_partner_name(), p_gain]
	elif companion_mode == "friend" and not companion_data.is_empty():
		var f_id: String = str(companion_data.get("id", ""))
		var f_name: String = str(companion_data.get("name", "Friend"))
		var f_gain: int = 12
		player.modify_friend_relationship(f_id, f_gain)
		comp_note = "🤝 %s had a blast hanging out with you! (Friendship +%d)" % [f_name, f_gain]

	# Outcome selection
	var outcomes: Array = activity.get("outcomes", [])
	var chosen_outcome: String = ""
	if not outcomes.is_empty():
		chosen_outcome = str(outcomes.pick_random())
	else:
		chosen_outcome = "You enjoyed participating in %s." % str(activity.get("name", "the activity"))

	if comp_note != "":
		chosen_outcome += "\n" + comp_note

	player.record_venue_visit(str(venue.get("id", "")), str(activity.get("id", "")), cost)

	return {
		"success": true,
		"message": chosen_outcome,
		"activity": activity,
		"cost": cost
	}


# -----------------------------------------------------------------------------
# 4. NPC GENERATION & SOCIAL INTERACTIONS
# -----------------------------------------------------------------------------

static func generate_venue_npc(player: Node, venue: Dictionary) -> Dictionary:
	var p_age: int = int(player.get("age")) if player != null else 20
	var is_minor: bool = p_age < 18

	var target_gender: String = ["MALE", "FEMALE"].pick_random()
	var cand_country: String = str(player.get("birthplace")) if player != null and str(player.get("birthplace")) != "" else "United States"
	var full_name: String = NameCatalog.random_name(cand_country, target_gender == "FEMALE")

	var cand_age: int = 20
	var cand_occ: String = "Student"
	var rel_status: String = "Single"

	if is_minor:
		# STRICT MINOR PROTECTION: Generate peer youth (ages 12-17), never adult romantic profiles
		cand_age = clampi(p_age + randi_range(-2, 2), 11, 17)
		cand_occ = "High School Student" if cand_age >= 14 else "Middle School Student"
		rel_status = "Single"
	else:
		# Adult patron (age 18-75)
		cand_age = clampi(p_age + randi_range(-5, 8), 18, 75)
		var occ_pool := [
			"Software Engineer", "Architect", "Graphic Designer", "Sound Producer",
			"Chef", "Research Scientist", "Biotech Analyst", "Marketing Director",
			"Photographer", "Fitness Coach", "Journalist", "Civil Engineer"
		]
		cand_occ = occ_pool.pick_random()
		rel_status = ["Single", "Single", "Single", "In a Relationship"].pick_random()

	var eth: String = PortraitCatalog.ETHNICITIES.pick_random()
	var track: int = randi_range(0, 3)

	# Shuffle 2-3 interests
	var shuffled_interests := INTERESTS_POOL.duplicate()
	shuffled_interests.shuffle()
	var chosen_interests: Array = [shuffled_interests[0], shuffled_interests[1]]

	var unique_id := "npc_%d_%d" % [Time.get_ticks_msec(), randi() % 100000]

	var npc := {
		"id": unique_id,
		"name": full_name,
		"gender": target_gender,
		"age": cand_age,
		"ethnicity": eth,
		"portrait_track": track,
		"portrait_variant": track,
		"personality": PERSONALITY_POOL.pick_random(),
		"interests": chosen_interests,
		"occupation": cand_occ,
		"relationship": randi_range(35, 50),
		"relationship_status": rel_status,
		"met_at": str(venue.get("name", "Venue")),
		"is_alive": true
	}

	NpcLifeProgress.ensure(npc)
	return npc


static func socialize_with_npc(player: Node, npc: Dictionary, action_type: String) -> Dictionary:
	if player == null or npc.is_empty():
		return {"success": false, "message": "Invalid character or action."}

	var p_age: int = int(player.get("age"))
	var npc_age: int = int(npc.get("age", 0))
	var npc_name: String = str(npc.get("name", "Patron"))

	match action_type:
		"chat":
			var gain := randi_range(7, 13)
			var cur_rel := int(npc.get("relationship", 40))
			npc["relationship"] = clampi(cur_rel + gain, 0, 100)

			# If already in player's friends list, sync it
			player.modify_friend_relationship(str(npc.get("id", "")), gain)
			player.modify_happiness(6)

			var dialogs := [
				"You struck up a lively conversation with %s about %s. You both hit it off effortlessly!" % [npc_name, str(npc.get("interests", ["life"])[0])],
				"You and %s shared stories over the ambient venue music, laughing at each other's humor." % npc_name,
				"%s listened attentively to your thoughts and appreciated your warm perspective." % npc_name
			]
			return {
				"success": true,
				"message": dialogs.pick_random() + " (Relationship +%d)" % gain,
				"action": "chat",
				"relationship": int(npc.get("relationship", 50))
			}

		"buy_drink":
			var cost := 12
			if not player.can_afford(cost):
				return {"success": false, "message": "💸 You need $%d to buy %s a refreshment." % [cost, npc_name]}

			if not player.debit_funds(cost):
				return {"success": false, "message": "Transaction failed."}

			player.record_transaction("Social", -cost, "Treated %s to refreshment" % npc_name)

			var drink_gain := randi_range(12, 18)
			var cur_rel_2 := int(npc.get("relationship", 40))
			npc["relationship"] = clampi(cur_rel_2 + drink_gain, 0, 100)
			player.modify_friend_relationship(str(npc.get("id", "")), drink_gain)
			player.modify_happiness(8)

			var drink_text := "drink" if p_age >= 18 else "artisan soda"
			return {
				"success": true,
				"message": "You treated %s to a %s ($%d). They were delighted and thanked you warmly! (Relationship +%d)" % [npc_name, drink_text, cost, drink_gain],
				"action": "buy_drink",
				"relationship": int(npc.get("relationship", 50))
			}

		"gossip":
			var g_gain := randi_range(6, 12)
			var cur_rel_g := int(npc.get("relationship", 40))
			npc["relationship"] = clampi(cur_rel_g + g_gain, 0, 100)
			player.modify_friend_relationship(str(npc.get("id", "")), g_gain)
			player.modify_happiness(7)
			var rumors := [
				"You and %s traded juicy rumors about the local tech executives and corporate boardroom gossip.",
				"%s leaned in and whispered surprising gossip about the city's lively underground music scene.",
				"You shared stories about city life with %s, laughing at hilarious local urban legends."
			]
			return {
				"success": true,
				"message": "🗣️ " + (rumors.pick_random() % npc_name) + " (Relationship +%d)" % g_gain,
				"action": "gossip",
				"relationship": int(npc.get("relationship", 50))
			}

		"play_game":
			var cost_game := 5
			if not player.can_afford(cost_game):
				return {"success": false, "message": "💸 You need $%d to cover game tokens or play a match with %s." % [cost_game, npc_name]}
			player.debit_funds(cost_game)
			player.record_transaction("Social", -cost_game, "Venue game with %s" % npc_name)
			var won: bool = randf() < 0.55
			var game_rel := randi_range(8, 15)
			var cur_rel_pg := int(npc.get("relationship", 40))
			npc["relationship"] = clampi(cur_rel_pg + game_rel, 0, 100)
			player.modify_friend_relationship(str(npc.get("id", "")), game_rel)
			if won:
				player.modify_happiness(12)
				return {
					"success": true,
					"message": "🎯 You challenged %s to a quick venue game ($%d) and won with an impressive high score! (Relationship +%d)" % [npc_name, cost_game, game_rel],
					"action": "play_game",
					"relationship": int(npc.get("relationship", 50))
				}
			else:
				player.modify_happiness(6)
				return {
					"success": true,
					"message": "🎯 You played a spirited game with %s ($%d). They narrowly bested your score, but you both had great fun! (Relationship +%d)" % [npc_name, cost_game, game_rel],
					"action": "play_game",
					"relationship": int(npc.get("relationship", 50))
				}

		"befriend":
			var friend_added: bool = player.add_friend(npc)
			if not friend_added:
				return {
					"success": false,
					"message": "You and %s are already friends!" % npc_name
				}
			player.modify_happiness(12)
			return {
				"success": true,
				"message": "🤝 You exchanged contact numbers and social tags with %s! They are now listed in your Friends circle." % npc_name,
				"action": "befriend",
				"friend": npc
			}

		"ask_date":
			# MINOR PROTECTION RULES
			if p_age < 18 or npc_age < 18:
				return {
					"success": false,
					"message": "🛡️ Protection: Romantic dating is only available for consenting adults aged 18 and older."
				}

			if player.has_partner():
				return {
					"success": false,
					"message": "⚠️ You are already in a relationship with %s! Break up or divorce first before dating someone new." % player.get_partner_name()
				}

			if str(npc.get("relationship_status", "Single")) != "Single":
				return {
					"success": false,
					"message": "💔 %s politely smiled but mentioned they are already in a committed relationship." % npc_name
				}

			# Calculate date outcome
			var roll := randf()
			var result_str: String = RomanceRules.date_result(player, npc, true, roll)
			var is_dating: bool = player.has_partner() and str(player.partner.get("name", "")) == npc_name

			return {
				"success": is_dating,
				"message": result_str,
				"action": "ask_date"
			}

	return {"success": false, "message": "Unknown social action."}
