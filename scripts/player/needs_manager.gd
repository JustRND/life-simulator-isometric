extends Node

## Centralized Character Needs Manager for Life.exe (Stage 4 Migration).
## Authoritatively manages hunger, thirst, temporary stat modifiers,
## consumable pantry inventory, purchasing, consumption, and auto-consumption.

signal needs_updated(hunger: float, thirst: float)
signal threshold_changed(need_type: String, old_tier: String, new_tier: String)
signal item_consumed(item_id: String, restored_hunger: float, restored_thirst: float)
signal item_purchased(item_id: String, cost: int)
signal health_attrition_taken(damage: int, reason: String)

# Singleton reference
static var instance: Node = null

static func get_instance() -> Node:
	return instance

# Need Tiers
const TIER_NORMAL: String = "NORMAL"
const TIER_LOW: String = "LOW"
const TIER_CRITICAL: String = "CRITICAL"
const TIER_DEPLETED: String = "DEPLETED"

# Category identifiers for transaction history
const CATEGORY_LIFESTYLE: String = "lifestyle"

# Centralized settings configuration file path
const CONFIG_FILE_PATH: String = "res://data/needs_config.json"

# Configurable tunables (tunable from res://data/needs_config.json and at runtime)
var config: Dictionary = {
	"hunger_decay_per_day": 0.2,       # ~500 in-game days (8m 20s) to deplete from 100 to 0
	"thirst_decay_per_day": 0.3,       # ~333 in-game days (5m 33s) to deplete from 100 to 0
	"starvation_damage_per_day": 3,     # Health damage per day when hunger == 0
	"dehydration_damage_per_day": 5,    # Health damage per day when thirst == 0
	"threshold_low": 40.0,              # <= 40% is LOW
	"threshold_critical": 15.0,         # <= 15% is CRITICAL
	"auto_consume_threshold": 50.0,     # When <= 50%, auto-consume will look into pantry
	"age_minor_decay_mult": 1.0,        # Minors (<18) decay multiplier
	"age_senior_decay_mult": 1.0,       # Seniors (>=65) decay multiplier
	"debuff_hunger_low_happiness": -10,
	"debuff_hunger_crit_happiness": -25,
	"debuff_hunger_crit_mental": -10,
	"debuff_hunger_dep_happiness": -40,
	"debuff_hunger_dep_mental": -25,
	"debuff_thirst_low_happiness": -10,
	"debuff_thirst_low_mental": -5,
	"debuff_thirst_crit_happiness": -30,
	"debuff_thirst_crit_mental": -20,
	"debuff_thirst_dep_happiness": -50,
	"debuff_thirst_dep_mental": -35
}

# Catalog of consumables & pantry grocery items
const ITEMS_CATALOG: Dictionary = {
	"water_bottle": {
		"id": "water_bottle",
		"name": "Spring Water Bottle",
		"category": "drink",
		"cost": 2,
		"restores_hunger": 0.0,
		"restores_thirst": 35.0,
		"icon": "💧",
		"desc": "Crisp mountain spring water. Quickly quenches thirst."
	},
	"quick_snack": {
		"id": "quick_snack",
		"name": "Granola Energy Bar",
		"category": "food",
		"cost": 4,
		"restores_hunger": 30.0,
		"restores_thirst": 5.0,
		"icon": "🍫",
		"desc": "Oats, nuts, and honey. A quick bite on the go."
	},
	"fresh_meal": {
		"id": "fresh_meal",
		"name": "Nutritious Deli Meal",
		"category": "meal",
		"cost": 15,
		"restores_hunger": 65.0,
		"restores_thirst": 20.0,
		"icon": "🍲",
		"desc": "Fresh grilled protein, garden vegetables, and warm broth."
	},
	"water_pack_6": {
		"id": "water_pack_6",
		"name": "Mineral Water 6-Pack",
		"category": "bundle",
		"cost": 10,
		"icon": "🧃",
		"desc": "Six bottled spring waters bundled at a discount.",
		"bundled_items": [
			{"id": "water_bottle", "count": 6}
		]
	},
	"weekly_groceries": {
		"id": "weekly_groceries",
		"name": "Weekly Groceries Basket",
		"category": "bundle",
		"cost": 65,
		"icon": "🛒",
		"desc": "Seven hearty meals and seven bottled drinks for your home pantry.",
		"bundled_items": [
			{"id": "fresh_meal", "count": 7},
			{"id": "water_bottle", "count": 7}
		]
	},
	"monthly_pantry": {
		"id": "monthly_pantry",
		"name": "Monthly Bulk Pantry Supply",
		"category": "bundle",
		"cost": 240,
		"icon": "📦",
		"desc": "Wholesale bulk supply of 30 complete meals and 30 bottled waters.",
		"bundled_items": [
			{"id": "fresh_meal", "count": 30},
			{"id": "water_bottle", "count": 30}
		]
	}
}

# Previous tiers tracking for transition notification deduplication
var _prev_hunger_tier: String = TIER_NORMAL
var _prev_thirst_tier: String = TIER_NORMAL


func _enter_tree() -> void:
	if instance != null and instance != self:
		queue_free()
		return
	instance = self


func _exit_tree() -> void:
	if instance == self:
		instance = null


func _ready() -> void:
	load_config()
	if has_node("/root/GameClock"):
		var clock = get_node("/root/GameClock")
		if clock != null and not clock.day_changed.is_connected(_on_clock_day_changed):
			clock.day_changed.connect(_on_clock_day_changed)


func _on_clock_day_changed(_year: int, _month: int, _day: int) -> void:
	if has_node("/root/PlayerData"):
		var pd = get_node("/root/PlayerData")
		if pd != null:
			process_daily_needs(pd, 1)
			if pd.has_method("process_daily_venues_and_intoxication"):
				pd.process_daily_venues_and_intoxication()
			if pd.has_method("process_daily_employment_tick"):
				pd.process_daily_employment_tick(_year, _month, _day)


# -----------------------------------------------------------------------------
# 1. CONFIGURATION & TUNING
# -----------------------------------------------------------------------------

## Loads configuration tunables from a centralized JSON settings file.
func load_config(path: String = CONFIG_FILE_PATH) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var text := file.get_as_text()
	file.close()
	var json_data = JSON.parse_string(text)
	if typeof(json_data) != TYPE_DICTIONARY:
		return false
	for k in json_data:
		config[k] = json_data[k]
	return true


## Saves the current configuration tunables to the centralized JSON settings file.
func save_config(path: String = CONFIG_FILE_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(config, "\t"))
	file.close()
	return true


func set_config_value(key: String, value: Variant) -> void:
	config[key] = value


func get_config_value(key: String, default_val: Variant = null) -> Variant:
	return config.get(key, default_val)


func reset_config_to_defaults() -> void:
	config["hunger_decay_per_day"] = 0.2
	config["thirst_decay_per_day"] = 0.3
	config["starvation_damage_per_day"] = 3
	config["dehydration_damage_per_day"] = 5
	config["threshold_low"] = 40.0
	config["threshold_critical"] = 15.0
	config["auto_consume_threshold"] = 50.0
	config["age_minor_decay_mult"] = 1.0
	config["age_senior_decay_mult"] = 1.0
	config["debuff_hunger_low_happiness"] = -10
	config["debuff_hunger_crit_happiness"] = -25
	config["debuff_hunger_crit_mental"] = -10
	config["debuff_hunger_dep_happiness"] = -40
	config["debuff_hunger_dep_mental"] = -25
	config["debuff_thirst_low_happiness"] = -10
	config["debuff_thirst_low_mental"] = -5
	config["debuff_thirst_crit_happiness"] = -30
	config["debuff_thirst_crit_mental"] = -20
	config["debuff_thirst_dep_happiness"] = -50
	config["debuff_thirst_dep_mental"] = -35
	load_config()


# -----------------------------------------------------------------------------
# 2. TIERS & THRESHOLDS
# -----------------------------------------------------------------------------

func get_tier(value: float) -> String:
	if value <= 0.0:
		return TIER_DEPLETED
	if value <= float(config.get("threshold_critical", 15.0)):
		return TIER_CRITICAL
	if value <= float(config.get("threshold_low", 40.0)):
		return TIER_LOW
	return TIER_NORMAL


func get_hunger_tier(player_data: Node) -> String:
	return get_tier(float(player_data.get("hunger")))


func get_thirst_tier(player_data: Node) -> String:
	return get_tier(float(player_data.get("thirst")))


# -----------------------------------------------------------------------------
# 3. AGE-AWARE DECAY CALCULATIONS
# -----------------------------------------------------------------------------

func get_effective_hunger_decay(player_data: Node) -> float:
	var base_decay: float = float(config.get("hunger_decay_per_day", 0.2))
	var age: int = int(player_data.get("age"))
	var mult: float = 1.0
	if age < 18:
		mult = float(config.get("age_minor_decay_mult", 1.0))
	elif age >= 65:
		mult = float(config.get("age_senior_decay_mult", 1.0))
	return base_decay * mult


func get_effective_thirst_decay(player_data: Node) -> float:
	var base_decay: float = float(config.get("thirst_decay_per_day", 0.3))
	var age: int = int(player_data.get("age"))
	var mult: float = 1.0
	if age < 18:
		mult = float(config.get("age_minor_decay_mult", 1.0))
	elif age >= 65:
		mult = float(config.get("age_senior_decay_mult", 1.0))
	return base_decay * mult


# -----------------------------------------------------------------------------
# 4. CENTRALIZED TEMPORARY STAT MODIFIERS (PREVENTS OVERLAPPING DEBUFFS)
# -----------------------------------------------------------------------------

## Applies a temporary modifier to an existing stat on PlayerData.
## If mod_id already exists in active_stat_modifiers, it is NOT applied again,
## strictly preventing duplicate or overlapping debuffs.
func apply_stat_modifier(player_data: Node, mod_id: String, stat_name: String, delta: int, source: String = "needs") -> bool:
	if not ("active_stat_modifiers" in player_data) or not (player_data.active_stat_modifiers is Dictionary):
		return false
	if player_data.active_stat_modifiers.has(mod_id):
		return false # Already applied! Prevent double-dipping.

	var cur_val: int = int(player_data.get(stat_name))
	var new_val: int = clampi(cur_val + delta, 0, 100)
	player_data.set(stat_name, new_val)

	player_data.active_stat_modifiers[mod_id] = {
		"stat": stat_name,
		"delta": delta,
		"source": source
	}
	return true


## Removes a temporary modifier and cleanly restores the underlying stat.
func remove_stat_modifier(player_data: Node, mod_id: String) -> bool:
	if not ("active_stat_modifiers" in player_data) or not (player_data.active_stat_modifiers is Dictionary):
		return false
	if not player_data.active_stat_modifiers.has(mod_id):
		return false

	var mod_info: Dictionary = player_data.active_stat_modifiers[mod_id]
	var stat_name: String = str(mod_info.get("stat", ""))
	var delta: int = int(mod_info.get("delta", 0))

	# Revert the delta cleanly
	var cur_val: int = int(player_data.get(stat_name))
	var restored_val: int = clampi(cur_val - delta, 0, 100)
	player_data.set(stat_name, restored_val)

	player_data.active_stat_modifiers.erase(mod_id)
	return true


func has_stat_modifier(player_data: Node, mod_id: String) -> bool:
	if "active_stat_modifiers" in player_data and player_data.active_stat_modifiers is Dictionary:
		return player_data.active_stat_modifiers.has(mod_id)
	return false


## Clears all tracked temporary stat modifiers, reverting every applied delta.
func clear_all_stat_modifiers(player_data: Node) -> void:
	if not ("active_stat_modifiers" in player_data) or not (player_data.active_stat_modifiers is Dictionary):
		return
	var mod_keys: Array = player_data.active_stat_modifiers.keys().duplicate()
	for mod_id in mod_keys:
		remove_stat_modifier(player_data, str(mod_id))
	player_data.active_stat_modifiers.clear()


## Deterministically reconciles active hunger and thirst debuffs to the current need tiers.
## Ensures old tiers are removed and new tiers are applied without duplicates.
func reconcile_stat_modifiers(player_data: Node) -> void:
	var h_tier := get_hunger_tier(player_data)
	var t_tier := get_thirst_tier(player_data)

	# ---------------- Hunger Modifiers ----------------
	var hunger_mod_keys := [
		"needs_hunger_low_hap",
		"needs_hunger_crit_hap",
		"needs_hunger_crit_men",
		"needs_hunger_dep_hap",
		"needs_hunger_dep_men"
	]

	match h_tier:
		TIER_NORMAL:
			for k in hunger_mod_keys:
				remove_stat_modifier(player_data, k)
		TIER_LOW:
			remove_stat_modifier(player_data, "needs_hunger_crit_hap")
			remove_stat_modifier(player_data, "needs_hunger_crit_men")
			remove_stat_modifier(player_data, "needs_hunger_dep_hap")
			remove_stat_modifier(player_data, "needs_hunger_dep_men")
			apply_stat_modifier(player_data, "needs_hunger_low_hap", "happiness", int(config.get("debuff_hunger_low_happiness", -10)))
		TIER_CRITICAL:
			remove_stat_modifier(player_data, "needs_hunger_low_hap")
			remove_stat_modifier(player_data, "needs_hunger_dep_hap")
			remove_stat_modifier(player_data, "needs_hunger_dep_men")
			apply_stat_modifier(player_data, "needs_hunger_crit_hap", "happiness", int(config.get("debuff_hunger_crit_happiness", -25)))
			apply_stat_modifier(player_data, "needs_hunger_crit_men", "mental_state", int(config.get("debuff_hunger_crit_mental", -10)))
		TIER_DEPLETED:
			remove_stat_modifier(player_data, "needs_hunger_low_hap")
			remove_stat_modifier(player_data, "needs_hunger_crit_hap")
			remove_stat_modifier(player_data, "needs_hunger_crit_men")
			apply_stat_modifier(player_data, "needs_hunger_dep_hap", "happiness", int(config.get("debuff_hunger_dep_happiness", -40)))
			apply_stat_modifier(player_data, "needs_hunger_dep_men", "mental_state", int(config.get("debuff_hunger_dep_mental", -25)))

	# ---------------- Thirst Modifiers ----------------
	var thirst_mod_keys := [
		"needs_thirst_low_hap",
		"needs_thirst_low_men",
		"needs_thirst_crit_hap",
		"needs_thirst_crit_men",
		"needs_thirst_dep_hap",
		"needs_thirst_dep_men"
	]

	match t_tier:
		TIER_NORMAL:
			for k in thirst_mod_keys:
				remove_stat_modifier(player_data, k)
		TIER_LOW:
			remove_stat_modifier(player_data, "needs_thirst_crit_hap")
			remove_stat_modifier(player_data, "needs_thirst_crit_men")
			remove_stat_modifier(player_data, "needs_thirst_dep_hap")
			remove_stat_modifier(player_data, "needs_thirst_dep_men")
			apply_stat_modifier(player_data, "needs_thirst_low_hap", "happiness", int(config.get("debuff_thirst_low_happiness", -10)))
			apply_stat_modifier(player_data, "needs_thirst_low_men", "mental_state", int(config.get("debuff_thirst_low_mental", -5)))
		TIER_CRITICAL:
			remove_stat_modifier(player_data, "needs_thirst_low_hap")
			remove_stat_modifier(player_data, "needs_thirst_low_men")
			remove_stat_modifier(player_data, "needs_thirst_dep_hap")
			remove_stat_modifier(player_data, "needs_thirst_dep_men")
			apply_stat_modifier(player_data, "needs_thirst_crit_hap", "happiness", int(config.get("debuff_thirst_crit_happiness", -30)))
			apply_stat_modifier(player_data, "needs_thirst_crit_men", "mental_state", int(config.get("debuff_thirst_crit_mental", -20)))
		TIER_DEPLETED:
			remove_stat_modifier(player_data, "needs_thirst_low_hap")
			remove_stat_modifier(player_data, "needs_thirst_low_men")
			remove_stat_modifier(player_data, "needs_thirst_crit_hap")
			remove_stat_modifier(player_data, "needs_thirst_crit_men")
			apply_stat_modifier(player_data, "needs_thirst_dep_hap", "happiness", int(config.get("debuff_thirst_dep_happiness", -50)))
			apply_stat_modifier(player_data, "needs_thirst_dep_men", "mental_state", int(config.get("debuff_thirst_dep_mental", -35)))


# -----------------------------------------------------------------------------
# 5. DAILY PROCESSING PIPELINE
# -----------------------------------------------------------------------------

## Processes daily needs depletion for one or multiple elapsed in-game days.
## Stops immediately if gameplay is paused or GameClock is stopped.
func process_daily_needs(player_data: Node, days_elapsed: int = 1) -> Dictionary:
	if days_elapsed <= 0:
		return {"processed": false, "reason": "zero_days"}

	# Paused gameplay check
	var clock = get_node_or_null("/root/GameClock")
	if clock != null and not clock.is_running():
		return {"processed": false, "reason": "clock_paused"}

	var h_decay := get_effective_hunger_decay(player_data) * float(days_elapsed)
	var t_decay := get_effective_thirst_decay(player_data) * float(days_elapsed)

	var cur_h: float = float(player_data.get("hunger"))
	var cur_t: float = float(player_data.get("thirst"))

	player_data.hunger = maxf(0.0, cur_h - h_decay)
	player_data.thirst = maxf(0.0, cur_t - t_decay)

	# Auto-consumption from pantry (if enabled)
	var auto_consumed: Array[String] = []
	if bool(player_data.get("auto_consume_enabled")):
		var ac_res := try_auto_consume(player_data)
		auto_consumed = ac_res.get("consumed", [])

	# Depleted state health attrition (gradual damage over time, prevents instant death)
	var total_attrition: int = 0
	if player_data.thirst <= 0.0:
		var d_dmg := int(config.get("dehydration_damage_per_day", 5)) * days_elapsed
		total_attrition += d_dmg
		_apply_attrition_damage(player_data, d_dmg, "severe dehydration")

	if player_data.hunger <= 0.0:
		var s_dmg := int(config.get("starvation_damage_per_day", 3)) * days_elapsed
		total_attrition += s_dmg
		_apply_attrition_damage(player_data, s_dmg, "prolonged starvation")

	# Reconcile modifiers to current tier
	reconcile_stat_modifiers(player_data)

	# Check and emit tier transition warnings
	_check_and_notify_tier_transitions(player_data)

	emit_signal("needs_updated", player_data.hunger, player_data.thirst)

	return {
		"processed": true,
		"days": days_elapsed,
		"hunger": player_data.hunger,
		"thirst": player_data.thirst,
		"auto_consumed": auto_consumed,
		"health_damage": total_attrition
	}


func _apply_attrition_damage(player_data: Node, damage: int, reason: String) -> void:
	if damage <= 0:
		return
	var cur_hp: int = int(player_data.get("health"))
	var new_hp: int = maxi(0, cur_hp - damage)
	player_data.health = new_hp
	emit_signal("health_attrition_taken", damage, reason)

	if player_data.has_method("add_life_event"):
		player_data.add_life_event("🚨 HEALTH DAMAGE: You took %d health damage due to %s! (Health: %d%%)" % [damage, reason, new_hp], "health")

	if new_hp <= 0 and not bool(player_data.get("is_dead")):
		player_data.is_dead = true
		player_data.cause_of_death = "Fatal Organ Failure from %s" % reason.capitalize()
		if player_data.has_method("add_life_event"):
			player_data.add_life_event("⚰️ TRAGIC PASSING: You succumbed to %s and passed away." % reason, "health")


func _check_and_notify_tier_transitions(player_data: Node) -> void:
	var h_tier := get_hunger_tier(player_data)
	var t_tier := get_thirst_tier(player_data)

	if h_tier != _prev_hunger_tier:
		emit_signal("threshold_changed", "hunger", _prev_hunger_tier, h_tier)
		if h_tier == TIER_LOW and player_data.has_method("add_life_event"):
			player_data.add_life_event("🥪 HUNGER: Your stomach is rumbling. You should eat something soon.", "lifestyle")
		elif h_tier == TIER_CRITICAL and player_data.has_method("add_life_event"):
			player_data.add_life_event("⚠️ STARVATION WARNING: You are intensely starving! Weakness and mood drop are taking hold.", "health")
		elif h_tier == TIER_DEPLETED and player_data.has_method("add_life_event"):
			player_data.add_life_event("🚨 CRITICAL STARVATION: You have zero food in your system! Physical health damage is occurring daily.", "health")
		_prev_hunger_tier = h_tier

	if t_tier != _prev_thirst_tier:
		emit_signal("threshold_changed", "thirst", _prev_thirst_tier, t_tier)
		if t_tier == TIER_LOW and player_data.has_method("add_life_event"):
			player_data.add_life_event("💧 THIRST: Your mouth feels dry. Consider having a drink of water.", "lifestyle")
		elif t_tier == TIER_CRITICAL and player_data.has_method("add_life_event"):
			player_data.add_life_event("⚠️ DEHYDRATION WARNING: You are severely parched! Severe headache and distress setting in.", "health")
		elif t_tier == TIER_DEPLETED and player_data.has_method("add_life_event"):
			player_data.add_life_event("🚨 CRITICAL DEHYDRATION: You are completely dehydrated! Organ stress is causing severe daily damage.", "health")
		_prev_thirst_tier = t_tier


# -----------------------------------------------------------------------------
# 6. INVENTORY PURCHASING & SPENDING INTEGRATION
# -----------------------------------------------------------------------------

## Purchases a consumable or grocery bundle using PlayerData funds.
## Debits currency, creates a categorized transaction record, logs life event,
## and deposits items into player_data.inventory.
func purchase_item(player_data: Node, item_id: String) -> Dictionary:
	if not ITEMS_CATALOG.has(item_id):
		return {"success": false, "message": "Item not found in store catalog."}

	var item_def: Dictionary = ITEMS_CATALOG[item_id]
	var cost: int = int(item_def.get("cost", 0))
	var avail_funds: int = int(player_data.get("money")) + int(player_data.get("bank_savings"))

	if avail_funds < cost:
		return {
			"success": false,
			"message": "Insufficient funds! You need $%d but only have $%d." % [cost, avail_funds]
		}

	# Debit funds using existing debit logic
	if player_data.has_method("debit_funds"):
		player_data.debit_funds(cost)
	else:
		player_data.money = maxi(0, int(player_data.get("money")) - cost)

	# Record transaction with date & category
	var date_label := "Day %d" % int(player_data.get("in_game_day"))
	var clock = get_node_or_null("/root/GameClock")
	if clock != null:
		date_label = "%04d-%02d-%02d" % [clock.year, clock.month, clock.day]

	if player_data.has_method("record_transaction"):
		player_data.record_transaction(CATEGORY_LIFESTYLE, -cost, "Pantry Purchase: %s" % str(item_def.get("name", item_id)), date_label)

	# Handle bundle vs individual item
	var item_cat: String = str(item_def.get("category", ""))
	if item_cat == "bundle" and item_def.has("bundled_items"):
		for b_entry in item_def.get("bundled_items", []):
			var b_id: String = str(b_entry.get("id", ""))
			var b_cnt: int = int(b_entry.get("count", 1))
			player_data.add_inventory_item(b_id, b_cnt)
	else:
		player_data.add_inventory_item(item_id, 1)

	if player_data.has_method("add_life_event"):
		player_data.add_life_event("🛒 STORE: Purchased %s for $%d and stocked it in your pantry." % [str(item_def.get("name")), cost], "finance")

	emit_signal("item_purchased", item_id, cost)
	return {
		"success": true,
		"item": item_def,
		"cost": cost
	}


# -----------------------------------------------------------------------------
# 7. INVENTORY CONSUMPTION
# -----------------------------------------------------------------------------

## Consumes an item from player_data.inventory, restoring hunger and/or thirst.
## Removes unit from inventory, reconciles modifiers, and logs event.
func consume_item(player_data: Node, item_id: String) -> Dictionary:
	if not player_data.has_inventory_item(item_id):
		return {"success": false, "message": "You don't have any %s in your pantry." % item_id}

	var item_def: Dictionary = ITEMS_CATALOG.get(item_id, {})
	var r_hunger: float = float(item_def.get("restores_hunger", 0.0))
	var r_thirst: float = float(item_def.get("restores_thirst", 0.0))

	# Remove from inventory
	player_data.remove_inventory_item(item_id, 1)

	# Restore needs
	player_data.hunger = minf(100.0, float(player_data.get("hunger")) + r_hunger)
	player_data.thirst = minf(100.0, float(player_data.get("thirst")) + r_thirst)

	# Reconcile modifiers to restore stats
	reconcile_stat_modifiers(player_data)

	var item_name: String = str(item_def.get("name", item_id))
	if player_data.has_method("add_life_event"):
		player_data.add_life_event("🍽️ CONSUMED: Enjoyed a %s. (Hunger: %d%%, Thirst: %d%%)" % [
			item_name, int(round(player_data.hunger)), int(round(player_data.thirst))
		], "lifestyle")

	emit_signal("item_consumed", item_id, r_hunger, r_thirst)
	emit_signal("needs_updated", player_data.hunger, player_data.thirst)

	return {
		"success": true,
		"item_id": item_id,
		"restores_hunger": r_hunger,
		"restores_thirst": r_thirst,
		"new_hunger": player_data.hunger,
		"new_thirst": player_data.thirst
	}


# -----------------------------------------------------------------------------
# 8. AUTO-CONSUMPTION SYSTEM
# -----------------------------------------------------------------------------

## Automatically satisfies hunger and thirst from available inventory if needs
## drop below auto_consume_threshold.
## CRITICAL RULE: Uses ONLY available inventory. Does NOT create free resources
## and does NOT charge money without an actual store purchase.
func try_auto_consume(player_data: Node) -> Dictionary:
	var consumed: Array[String] = []
	var ac_thresh: float = float(config.get("auto_consume_threshold", 50.0))

	# 1. Thirst Priority (dehydration is more immediately dangerous)
	if float(player_data.get("thirst")) <= ac_thresh:
		var found_drink := ""
		# Pass 1: Look for category == "drink"
		for entry in player_data.inventory:
			var i_id: String = str(entry.get("id", ""))
			var def: Dictionary = ITEMS_CATALOG.get(i_id, {})
			if str(def.get("category", "")) == "drink" and float(def.get("restores_thirst", 0.0)) > 0.0 and int(entry.get("count", 0)) > 0:
				found_drink = i_id
				break
		# Pass 2: Fallback to any item with restores_thirst > 0
		if found_drink == "":
			for entry in player_data.inventory:
				var i_id: String = str(entry.get("id", ""))
				var def: Dictionary = ITEMS_CATALOG.get(i_id, {})
				if float(def.get("restores_thirst", 0.0)) > 0.0 and int(entry.get("count", 0)) > 0:
					found_drink = i_id
					break
		if found_drink != "":
			consume_item(player_data, found_drink)
			consumed.append(found_drink)

	# 2. Hunger Priority
	if float(player_data.get("hunger")) <= ac_thresh:
		var found_food := ""
		# Pass 1: Look for category in ["food", "meal"]
		for entry in player_data.inventory:
			var i_id: String = str(entry.get("id", ""))
			var def: Dictionary = ITEMS_CATALOG.get(i_id, {})
			if str(def.get("category", "")) in ["food", "meal"] and float(def.get("restores_hunger", 0.0)) > 0.0 and int(entry.get("count", 0)) > 0:
				found_food = i_id
				break
		# Pass 2: Fallback to any item with restores_hunger > 0
		if found_food == "":
			for entry in player_data.inventory:
				var i_id: String = str(entry.get("id", ""))
				var def: Dictionary = ITEMS_CATALOG.get(i_id, {})
				if float(def.get("restores_hunger", 0.0)) > 0.0 and int(entry.get("count", 0)) > 0:
					found_food = i_id
					break
		if found_food != "":
			consume_item(player_data, found_food)
			consumed.append(found_food)

	return {
		"triggered": consumed.size() > 0,
		"consumed": consumed
	}


# -----------------------------------------------------------------------------
# 9. STATUS & UI DATA HELPER
# -----------------------------------------------------------------------------

func get_needs_status(player_data: Node) -> Dictionary:
	var h: float = float(player_data.get("hunger"))
	var t: float = float(player_data.get("thirst"))
	return {
		"hunger": h,
		"thirst": t,
		"hunger_tier": get_hunger_tier(player_data),
		"thirst_tier": get_thirst_tier(player_data),
		"auto_consume_enabled": bool(player_data.get("auto_consume_enabled")),
		"active_modifiers": player_data.get("active_stat_modifiers") if "active_stat_modifiers" in player_data else {},
		"pantry_count": player_data.inventory.size() if "inventory" in player_data else 0
	}
