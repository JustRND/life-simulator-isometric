extends Node

## Comprehensive Verification Suite for Stage 4: Character Needs (Hunger & Thirst).
## Validates depletion, thresholds, non-overlapping debuffs, stat restoration,
## depleted health damage, purchasing, inventory, auto-consumption, pausing, and save/load.

var total_assertions: int = 0
var passed_assertions: int = 0


func _ready() -> void:
	print("\n=======================================================")
	print("🧪 RUNNING STAGE 4 CHARACTER NEEDS TEST SUITE")
	print("=======================================================")

	test_daily_depletion_and_pausing()
	test_tiers_and_thresholds()
	test_debuffs_to_existing_stats()
	test_prevention_of_duplicate_modifiers()
	test_consumption_and_stat_recovery()
	test_depleted_health_attrition_no_instant_death()
	test_purchasing_and_transaction_integration()
	test_manual_consumption_from_inventory()
	test_auto_consumption_system()
	test_age_aware_balancing()
	test_save_load_and_version4_migration()
	test_configurable_tunability()

	print("\n=======================================================")
	print("🎉 ALL STAGE 4 TESTS COMPLETED: (%d/%d assertions passed)!" % [passed_assertions, total_assertions])
	print("=======================================================\n")

	if passed_assertions == total_assertions:
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func assert_true(condition: bool, message: String) -> void:
	total_assertions += 1
	if condition:
		passed_assertions += 1
		print("  ✓ %s" % message)
	else:
		push_error("Assertion FAILED: %s" % message)
		print("  ✗ FAILED: %s" % message)


# -----------------------------------------------------------------------------
# 1. DAILY DEPLETION & PAUSED CLOCK
# -----------------------------------------------------------------------------
func test_daily_depletion_and_pausing() -> void:
	print("\n--- 1. Testing Daily Depletion & Paused Clock ---")
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.age = 25
	PlayerData.hunger = 100.0
	PlayerData.thirst = 100.0
	PlayerData.auto_consume_enabled = false # Disable to test pure depletion
	NeedsManager.reset_config_to_defaults()

	# 1 day active unpaused depletion (adult: 2.5 hunger, 4.0 thirst)
	var res1 := NeedsManager.process_daily_needs(PlayerData, 1)
	assert_true(res1.get("processed", false), "Active day processed successfully")
	assert_true(is_equal_approx(PlayerData.hunger, 97.5), "Hunger decreased by 2.5 (now 97.5)")
	assert_true(is_equal_approx(PlayerData.thirst, 96.0), "Thirst decreased by 4.0 (now 96.0)")

	# 5 days active unpaused depletion
	NeedsManager.process_daily_needs(PlayerData, 5)
	assert_true(is_equal_approx(PlayerData.hunger, 85.0), "Hunger after 6 days is 85.0 (100 - 15)")
	assert_true(is_equal_approx(PlayerData.thirst, 76.0), "Thirst after 6 days is 76.0 (100 - 24)")

	# Paused gameplay check
	GameClock.set_paused(true, "test_pause_menu")
	var h_before := PlayerData.hunger
	var t_before := PlayerData.thirst
	var res_paused := NeedsManager.process_daily_needs(PlayerData, 1)
	assert_true(not res_paused.get("processed", true), "Paused gameplay rejected daily depletion")
	assert_true(PlayerData.hunger == h_before, "Hunger remained unchanged while paused")
	assert_true(PlayerData.thirst == t_before, "Thirst remained unchanged while paused")

	GameClock.set_paused(false, "test_pause_menu")
	var res_resumed := NeedsManager.process_daily_needs(PlayerData, 1)
	assert_true(res_resumed.get("processed", false), "Resumed clock resumed needs depletion")


# -----------------------------------------------------------------------------
# 2. TIERS & THRESHOLDS
# -----------------------------------------------------------------------------
func test_tiers_and_thresholds() -> void:
	print("\n--- 2. Testing Tiers & Thresholds (Normal, Low, Critical, Depleted) ---")
	assert_true(NeedsManager.get_tier(100.0) == NeedsManager.TIER_NORMAL, "100% is NORMAL")
	assert_true(NeedsManager.get_tier(45.0) == NeedsManager.TIER_NORMAL, "45% is NORMAL (>40)")
	assert_true(NeedsManager.get_tier(40.0) == NeedsManager.TIER_LOW, "40% is LOW (threshold_low)")
	assert_true(NeedsManager.get_tier(20.0) == NeedsManager.TIER_LOW, "20% is LOW")
	assert_true(NeedsManager.get_tier(15.0) == NeedsManager.TIER_CRITICAL, "15% is CRITICAL (threshold_critical)")
	assert_true(NeedsManager.get_tier(5.0) == NeedsManager.TIER_CRITICAL, "5% is CRITICAL")
	assert_true(NeedsManager.get_tier(0.0) == NeedsManager.TIER_DEPLETED, "0% is DEPLETED")


# -----------------------------------------------------------------------------
# 3. DEBUFFS TO EXISTING STATS ONLY
# -----------------------------------------------------------------------------
func test_debuffs_to_existing_stats() -> void:
	print("\n--- 3. Testing Debuffs to Existing Stats (Happiness & Mental State) ---")
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.age = 25
	PlayerData.happiness = 80
	PlayerData.mental_state = 80
	PlayerData.auto_consume_enabled = false

	# Set hunger to LOW (30%)
	PlayerData.hunger = 30.0
	PlayerData.thirst = 90.0 # Normal
	NeedsManager.reconcile_stat_modifiers(PlayerData)

	assert_true(NeedsManager.has_stat_modifier(PlayerData, "needs_hunger_low_hap"), "Low hunger modifier applied")
	assert_true(PlayerData.happiness == 70, "Happiness reduced from 80 to 70 (-10 low hunger debuff)")
	assert_true(PlayerData.mental_state == 80, "Mental state unaffected by low hunger")

	# Set thirst to LOW (30%) as well
	PlayerData.thirst = 30.0
	NeedsManager.reconcile_stat_modifiers(PlayerData)
	assert_true(NeedsManager.has_stat_modifier(PlayerData, "needs_thirst_low_hap"), "Low thirst happiness modifier applied")
	assert_true(NeedsManager.has_stat_modifier(PlayerData, "needs_thirst_low_men"), "Low thirst mental state modifier applied")
	assert_true(PlayerData.happiness == 60, "Happiness reduced to 60 (80 - 10 hunger - 10 thirst)")
	assert_true(PlayerData.mental_state == 75, "Mental state reduced to 75 (80 - 5 thirst)")

	# Set hunger to CRITICAL (10%)
	PlayerData.hunger = 10.0
	NeedsManager.reconcile_stat_modifiers(PlayerData)
	assert_true(not NeedsManager.has_stat_modifier(PlayerData, "needs_hunger_low_hap"), "Low hunger modifier removed on critical transition")
	assert_true(NeedsManager.has_stat_modifier(PlayerData, "needs_hunger_crit_hap"), "Critical hunger happiness modifier applied (-25)")
	assert_true(NeedsManager.has_stat_modifier(PlayerData, "needs_hunger_crit_men"), "Critical hunger mental modifier applied (-10)")
	# 80 base - 25 crit hunger - 10 low thirst = 45
	assert_true(PlayerData.happiness == 45, "Happiness accurately reflects critical hunger (-25) + low thirst (-10)")
	# 80 base - 10 crit hunger - 5 low thirst = 65
	assert_true(PlayerData.mental_state == 65, "Mental state accurately reflects critical hunger (-10) + low thirst (-5)")


# -----------------------------------------------------------------------------
# 4. PREVENTION OF OVERLAPPING / DUPLICATE DEBUFFS
# -----------------------------------------------------------------------------
func test_prevention_of_duplicate_modifiers() -> void:
	print("\n--- 4. Testing Prevention of Overlapping & Duplicate Debuffs ---")
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.age = 25
	PlayerData.happiness = 75
	PlayerData.mental_state = 75
	PlayerData.hunger = 30.0 # LOW
	PlayerData.thirst = 80.0 # NORMAL
	PlayerData.auto_consume_enabled = false

	# Reconcile once
	NeedsManager.reconcile_stat_modifiers(PlayerData)
	assert_true(PlayerData.happiness == 65, "First reconciliation drops happiness to 65")

	# Repeated re-application must NOT stack or re-apply
	var applied_again := NeedsManager.apply_stat_modifier(PlayerData, "needs_hunger_low_hap", "happiness", -10)
	assert_true(not applied_again, "Direct duplicate modifier application was rejected")
	assert_true(PlayerData.happiness == 65, "Happiness unchanged on duplicate application attempt")

	# Reconciling 10 times in a row produces identical result
	for _i in range(10):
		NeedsManager.reconcile_stat_modifiers(PlayerData)
	assert_true(PlayerData.happiness == 65, "Happiness remains strictly 65 after 10 redundant reconciliation passes")


# -----------------------------------------------------------------------------
# 5. RECOVERY & EXACT STAT RESTORATION
# -----------------------------------------------------------------------------
func test_consumption_and_stat_recovery() -> void:
	print("\n--- 5. Testing Consumption & Exact Stat Restoration ---")
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.age = 25
	PlayerData.happiness = 75
	PlayerData.mental_state = 75
	PlayerData.hunger = 20.0 # LOW
	PlayerData.thirst = 10.0 # CRITICAL
	PlayerData.auto_consume_enabled = false

	NeedsManager.reconcile_stat_modifiers(PlayerData)
	# Hunger Low: -10 hap. Thirst Crit: -30 hap, -20 men.
	# Happiness: 75 - 10 - 30 = 35. Mental State: 75 - 20 = 55.
	assert_true(PlayerData.happiness == 35, "Compounded debuffs drop happiness to 35")
	assert_true(PlayerData.mental_state == 55, "Compounded debuffs drop mental state to 55")

	# Give player food and drink in pantry
	PlayerData.add_inventory_item("fresh_meal", 2)
	PlayerData.add_inventory_item("water_bottle", 3)

	# Drink water (+35 thirst -> 45%, transitions to NORMAL)
	NeedsManager.consume_item(PlayerData, "water_bottle")
	assert_true(PlayerData.thirst == 45.0, "Thirst restored to 45%")
	assert_true(PlayerData.get_inventory_item_count("water_bottle") == 2, "Water bottle count reduced to 2")

	# Drink second bottle (+35 thirst -> 80%)
	NeedsManager.consume_item(PlayerData, "water_bottle")
	assert_true(PlayerData.thirst == 80.0, "Thirst fully restored to 80% (NORMAL)")

	# Eat meal (+65 hunger -> 85% NORMAL, +20 thirst -> 100% NORMAL)
	NeedsManager.consume_item(PlayerData, "fresh_meal")
	assert_true(PlayerData.hunger == 85.0, "Hunger restored to 85% (NORMAL)")
	assert_true(PlayerData.thirst == 100.0, "Thirst clamped to 100% maximum")

	# Modifiers should be completely cleared and stats restored to original baseline 75!
	assert_true(PlayerData.active_stat_modifiers.is_empty(), "All temporary stat modifiers removed upon recovery")
	assert_true(PlayerData.happiness == 75, "Happiness perfectly restored to original baseline 75")
	assert_true(PlayerData.mental_state == 75, "Mental state perfectly restored to original baseline 75")


# -----------------------------------------------------------------------------
# 6. DEPLETED HEALTH ATTRITION & NO INSTANT DEATH
# -----------------------------------------------------------------------------
func test_depleted_health_attrition_no_instant_death() -> void:
	print("\n--- 6. Testing Depleted Health Attrition (No Instant Death) ---")
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.age = 25
	PlayerData.health = 80
	PlayerData.hunger = 0.0 # DEPLETED (3 dmg/day)
	PlayerData.thirst = 0.0 # DEPLETED (5 dmg/day)
	PlayerData.auto_consume_enabled = false
	PlayerData.is_dead = false

	# Missing 1 day: takes 3 (hunger) + 5 (thirst) = 8 damage
	NeedsManager.process_daily_needs(PlayerData, 1)
	assert_true(PlayerData.health == 72, "1 day of zero food & water deals 8 health damage (80 -> 72)")
	assert_true(not PlayerData.is_dead, "Player did NOT die from 1 missed day (no instant death)")

	# Missing 5 more days: 5 * 8 = 40 damage
	NeedsManager.process_daily_needs(PlayerData, 5)
	assert_true(PlayerData.health == 32, "6 total days without food/water leaves player alive at 32 HP")
	assert_true(not PlayerData.is_dead, "Player remains alive after nearly a week without sustenance")

	# Prolonged deprivation (5 more days -> 5 * 8 = 40 damage -> exceeds 32 HP -> death)
	NeedsManager.process_daily_needs(PlayerData, 5)
	assert_true(PlayerData.health == 0, "Health drops to 0 after extended fatal deprivation")
	assert_true(PlayerData.is_dead, "Player died from prolonged starvation & dehydration")
	assert_true("Dehydration" in PlayerData.cause_of_death or "Starvation" in PlayerData.cause_of_death, "Authoritative cause of death recorded")


# -----------------------------------------------------------------------------
# 7. PURCHASING & TRANSACTION SYSTEM INTEGRATION
# -----------------------------------------------------------------------------
func test_purchasing_and_transaction_integration() -> void:
	print("\n--- 7. Testing Purchasing & Transaction System Integration ---")
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.age = 22
	PlayerData.money = 100
	PlayerData.bank_savings = 0
	PlayerData.inventory.clear()
	PlayerData.transaction_history.clear()

	# Purchase Water Bottle ($2)
	var buy_w := NeedsManager.purchase_item(PlayerData, "water_bottle")
	assert_true(buy_w.get("success", false), "Water bottle purchased successfully")
	assert_true(PlayerData.money == 98, "Cash balance reduced by $2 (now $98)")
	assert_true(PlayerData.get_inventory_item_count("water_bottle") == 1, "Water bottle in pantry inventory")

	# Check transaction log
	var has_w_trans := false
	for t in PlayerData.transaction_history:
		if t.get("category") == "lifestyle" and t.get("amount") == -2:
			has_w_trans = true
			break
	assert_true(has_w_trans, "Water purchase logged in transaction_history with category 'lifestyle'")

	# Purchase Weekly Groceries Bundle ($65) -> unpacks 7 fresh meals and 7 water bottles
	var buy_g := NeedsManager.purchase_item(PlayerData, "weekly_groceries")
	assert_true(buy_g.get("success", false), "Weekly groceries bundle purchased")
	assert_true(PlayerData.money == 33, "Cash balance reduced by $65 (98 - 65 = 33)")
	assert_true(PlayerData.get_inventory_item_count("fresh_meal") == 7, "Pantry stocked with 7 meals")
	assert_true(PlayerData.get_inventory_item_count("water_bottle") == 8, "Pantry stocked with 8 water bottles (1 + 7)")

	# Insufficient funds check
	PlayerData.money = 1
	PlayerData.bank_savings = 0
	var buy_fail := NeedsManager.purchase_item(PlayerData, "fresh_meal") # costs $15
	assert_true(not buy_fail.get("success", true), "Purchase rejected when player lacks funds")
	assert_true(PlayerData.money == 1, "Funds untouched on failed purchase")


# -----------------------------------------------------------------------------
# 8. MANUAL CONSUMPTION FROM INVENTORY
# -----------------------------------------------------------------------------
func test_manual_consumption_from_inventory() -> void:
	print("\n--- 8. Testing Manual Consumption from Inventory ---")
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.hunger = 40.0
	PlayerData.thirst = 40.0
	PlayerData.inventory.clear()
	PlayerData.add_inventory_item("quick_snack", 2)

	# Consume 1 snack (+30 hunger, +5 thirst)
	var c_res := NeedsManager.consume_item(PlayerData, "quick_snack")
	assert_true(c_res.get("success", false), "Quick snack consumed")
	assert_true(PlayerData.hunger == 70.0, "Hunger increased by 30 to 70%")
	assert_true(PlayerData.thirst == 45.0, "Thirst increased by 5 to 45%")
	assert_true(PlayerData.get_inventory_item_count("quick_snack") == 1, "Remaining count is 1")

	# Consume second snack
	NeedsManager.consume_item(PlayerData, "quick_snack")
	assert_true(PlayerData.get_inventory_item_count("quick_snack") == 0, "Inventory count is now 0")
	assert_true(not PlayerData.has_inventory_item("quick_snack"), "Snack completely removed from inventory")

	# Consume nonexistent item fails cleanly
	var c_empty := NeedsManager.consume_item(PlayerData, "quick_snack")
	assert_true(not c_empty.get("success", true), "Cannot consume item not in inventory")


# -----------------------------------------------------------------------------
# 9. AUTO-CONSUMPTION SYSTEM
# -----------------------------------------------------------------------------
func test_auto_consumption_system() -> void:
	print("\n--- 9. Testing Auto-Consumption System (Zero Free Items, Zero Free Charges) ---")
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.age = 25
	PlayerData.hunger = 45.0 # <= 50% threshold
	PlayerData.thirst = 45.0 # <= 50% threshold
	PlayerData.auto_consume_enabled = true
	PlayerData.inventory.clear()
	PlayerData.money = 100
	PlayerData.bank_savings = 500

	# 1. Pantry has food and water
	PlayerData.add_inventory_item("fresh_meal", 1)
	PlayerData.add_inventory_item("water_bottle", 1)

	var ac_res := NeedsManager.try_auto_consume(PlayerData)
	assert_true(ac_res.get("triggered", false), "Auto-consume triggered")
	assert_true("water_bottle" in ac_res.get("consumed", []), "Water bottle auto-consumed from inventory")
	assert_true("fresh_meal" in ac_res.get("consumed", []), "Fresh meal auto-consumed from inventory")
	assert_true(PlayerData.inventory.is_empty(), "Inventory items expended")
	assert_true(PlayerData.money == 100, "Cash NOT charged during auto-consume (used purchased inventory)")
	assert_true(PlayerData.bank_savings == 500, "Savings NOT charged during auto-consume")

	# 2. Pantry is now empty -> Auto-consume MUST NOT create free resources or charge money
	PlayerData.hunger = 30.0
	PlayerData.thirst = 30.0
	var ac_empty := NeedsManager.try_auto_consume(PlayerData)
	assert_true(not ac_empty.get("triggered", true), "Auto-consume did not trigger with empty pantry")
	assert_true(PlayerData.hunger == 30.0, "Hunger not magically replenished without inventory")
	assert_true(PlayerData.thirst == 30.0, "Thirst not magically replenished without inventory")
	assert_true(PlayerData.money == 100, "Zero funds charged without player permission")

	# 3. Disabled auto-consume preference
	PlayerData.auto_consume_enabled = false
	PlayerData.add_inventory_item("water_bottle", 5)
	NeedsManager.process_daily_needs(PlayerData, 1)
	assert_true(PlayerData.get_inventory_item_count("water_bottle") == 5, "Items untouched when auto-consume is disabled")


# -----------------------------------------------------------------------------
# 10. AGE-AWARE BALANCING
# -----------------------------------------------------------------------------
func test_age_aware_balancing() -> void:
	print("\n--- 10. Testing Age-Aware Balancing ---")
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	NeedsManager.reset_config_to_defaults()

	# Minor (14 years old): decay multiplier is 0.5
	PlayerData.age = 14
	var m_hunger_decay := NeedsManager.get_effective_hunger_decay(PlayerData)
	var m_thirst_decay := NeedsManager.get_effective_thirst_decay(PlayerData)
	assert_true(is_equal_approx(m_hunger_decay, 1.25), "Minor hunger decay is 1.25/day (2.5 * 0.5)")
	assert_true(is_equal_approx(m_thirst_decay, 2.0), "Minor thirst decay is 2.0/day (4.0 * 0.5)")

	# Adult (30 years old): normal decay multiplier 1.0
	PlayerData.age = 30
	var a_hunger_decay := NeedsManager.get_effective_hunger_decay(PlayerData)
	var a_thirst_decay := NeedsManager.get_effective_thirst_decay(PlayerData)
	assert_true(is_equal_approx(a_hunger_decay, 2.5), "Adult hunger decay is 2.5/day")
	assert_true(is_equal_approx(a_thirst_decay, 4.0), "Adult thirst decay is 4.0/day")

	# Senior (70 years old): senior decay multiplier 1.1
	PlayerData.age = 70
	var s_hunger_decay := NeedsManager.get_effective_hunger_decay(PlayerData)
	assert_true(is_equal_approx(s_hunger_decay, 2.75), "Senior hunger decay is 2.75/day (2.5 * 1.1)")


# -----------------------------------------------------------------------------
# 11. SAVE/LOAD & VERSION 4 MIGRATION
# -----------------------------------------------------------------------------
func test_save_load_and_version4_migration() -> void:
	print("\n--- 11. Testing Save/Load & Version 4 Migration ---")
	PlayerData.reset_player()
	PlayerData.age = 26
	PlayerData.hunger = 64.5
	PlayerData.thirst = 58.0
	PlayerData.auto_consume_enabled = false
	PlayerData.inventory.clear()
	PlayerData.add_inventory_item("water_bottle", 3)
	PlayerData.add_inventory_item("fresh_meal", 2)
	PlayerData.active_stat_modifiers["test_mod"] = {"stat": "happiness", "delta": -5, "source": "test"}

	var save_dict := SaveManager.capture_data()
	assert_true(save_dict.get("save_version") == 4, "Save format bumped to version 4")
	assert_true(is_equal_approx(float(save_dict.get("hunger")), 64.5), "Hunger captured in save dictionary")
	assert_true(is_equal_approx(float(save_dict.get("thirst")), 58.0), "Thirst captured in save dictionary")
	assert_true(not bool(save_dict.get("auto_consume_enabled")), "Auto-consume setting captured")
	assert_true(Array(save_dict.get("inventory")).size() == 2, "Inventory captured in save dictionary")

	# Mutate current state
	PlayerData.hunger = 100.0
	PlayerData.thirst = 100.0
	PlayerData.auto_consume_enabled = true
	PlayerData.inventory.clear()

	# Restore state from save
	SaveManager.apply_data(save_dict)
	assert_true(is_equal_approx(PlayerData.hunger, 64.5), "Hunger restored from save")
	assert_true(is_equal_approx(PlayerData.thirst, 58.0), "Thirst restored from save")
	assert_true(not PlayerData.auto_consume_enabled, "Auto-consume setting restored from save")
	assert_true(PlayerData.get_inventory_item_count("water_bottle") == 3, "Water bottle count restored accurately")
	assert_true(PlayerData.get_inventory_item_count("fresh_meal") == 2, "Fresh meal count restored accurately")

	# Safe legacy save migration (v3 save without needs)
	var legacy_v3_save: Dictionary = save_dict.duplicate(true)
	legacy_v3_save["save_version"] = 3
	legacy_v3_save.erase("hunger")
	legacy_v3_save.erase("thirst")
	legacy_v3_save.erase("inventory")
	legacy_v3_save.erase("auto_consume_enabled")

	SaveManager.apply_data(legacy_v3_save)
	assert_true(PlayerData.hunger == 100.0, "Legacy save defaults hunger cleanly to 100%")
	assert_true(PlayerData.thirst == 100.0, "Legacy save defaults thirst cleanly to 100%")
	assert_true(PlayerData.auto_consume_enabled == true, "Legacy save defaults auto-consume cleanly to true")


# -----------------------------------------------------------------------------
# 12. CONFIGURABLE TUNABILITY
# -----------------------------------------------------------------------------
func test_configurable_tunability() -> void:
	print("\n--- 12. Testing Configurable Tunability ---")
	NeedsManager.reset_config_to_defaults()
	assert_true(float(NeedsManager.get_config_value("hunger_decay_per_day")) == 2.5, "Default hunger decay is 2.5")

	NeedsManager.set_config_value("hunger_decay_per_day", 10.0)
	assert_true(float(NeedsManager.get_config_value("hunger_decay_per_day")) == 10.0, "Modified hunger decay to 10.0")

	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.age = 30
	PlayerData.hunger = 100.0
	PlayerData.auto_consume_enabled = false
	NeedsManager.process_daily_needs(PlayerData, 1)
	assert_true(is_equal_approx(PlayerData.hunger, 90.0), "Tuned decay rate (10.0) took effect immediately (100 -> 90)")

	NeedsManager.reset_config_to_defaults()
	assert_true(float(NeedsManager.get_config_value("hunger_decay_per_day")) == 2.5, "Reset config restores default rate")
