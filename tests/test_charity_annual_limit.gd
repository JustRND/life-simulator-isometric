extends Node

func _ready() -> void:
	print("=== BEGIN CHARITY ANNUAL LIMIT & BLESSINGS REMOVAL TEST ===")

	PlayerData.reset_player()
	PlayerData.first_name = "Philanthropist"
	PlayerData.age = 20
	PlayerData.money = 20000
	PlayerData.bank_savings = 50000
	PlayerData.karma = 25
	PlayerData.happiness = 30
	PlayerData.health = 40
	PlayerData.smarts = 40
	PlayerData.active_buffs.clear()

	# 1. CATALOG VERIFICATION: No permanent buffs, only karma & happiness
	var charities = CharityManager.get_all_charities()
	assert(charities.size() >= 6, "Must have all 6 charity tiers")
	for c in charities:
		var c_id: String = str(c.get("id", ""))
		assert(not c.has("buff_id"), "Charity %s must NOT define buff_id" % c_id)
		assert(not c.has("buff_name"), "Charity %s must NOT define buff_name" % c_id)
		assert(not c.has("buff_desc"), "Charity %s must NOT define buff_desc" % c_id)
		assert(not c.has("smarts_boost"), "Charity %s must NOT define smarts_boost" % c_id)
		assert(not c.has("health_boost"), "Charity %s must NOT define health_boost" % c_id)
		assert(int(c.get("hidden_karma_boost", 0)) > 0, "Charity %s must have karma boost" % c_id)
		assert(int(c.get("happiness_boost", 0)) > 0, "Charity %s must have happiness boost" % c_id)
	print("✔ CHECK 1: Charity catalog has no permanent buffs and only karma & happiness boosts.")

	# 2. INSTANTIATE MAIN SCREEN & VERIFY UI
	var main_res := load("res://scenes/main/main_screen.tscn") as PackedScene
	assert(main_res != null, "main_screen.tscn must load")
	var main = main_res.instantiate()
	add_child(main)

	if main.disclaimer_screen != null:
		main.disclaimer_screen.hide()
	if main.loading_screen != null:
		main.loading_screen.hide()

	await get_tree().process_frame
	await get_tree().process_frame

	PlayerData.reset_player()
	PlayerData.first_name = "Philanthropist"
	PlayerData.age = 20
	PlayerData.money = 20000
	PlayerData.bank_savings = 50000
	PlayerData.karma = 25
	PlayerData.happiness = 30
	PlayerData.health = 40
	PlayerData.smarts = 40
	PlayerData.last_charity_donation_age = -1
	PlayerData.active_buffs.clear()

	main._show_charity_modal()
	assert(main.charity_modal_overlay != null and is_instance_valid(main.charity_modal_overlay), "Charity modal must open")

	# Check modal tree: ensure NO active blessings card is shown
	var modal_text_dump: String = ""
	var queue: Array[Node] = [main.charity_modal_overlay]
	while not queue.is_empty():
		var curr = queue.pop_front()
		if curr is Label:
			modal_text_dump += " " + curr.text
		for ch in curr.get_children():
			queue.append(ch)

	assert(not modal_text_dump.contains("ACTIVE PERMANENT PHILANTHROPIC BLESSINGS"), "Must not display blessings card in modal")
	assert(not modal_text_dump.contains("[Cosmic Blessing]"), "Must not display [Cosmic Blessing]")
	assert(not modal_text_dump.contains("[Unlocked]"), "Must not display [Unlocked] buff labels")
	assert(modal_text_dump.contains("Spiritual Impact: Elevates your karma and boosts happiness"), "Must display non-permanent spiritual impact")
	print("✔ CHECK 2: Modal UI contains no blessings cards or permanent buff indicators.")

	# 3. VERIFY DONATION & STAT INCREASES (NO BUFFS)
	var prev_funds = PlayerData.get_available_funds()
	var prev_karma = PlayerData.karma
	var prev_happiness = PlayerData.happiness

	var don_res = CharityManager.donate(PlayerData, "charity_food_bank")
	assert(don_res.get("success", false) == true, "Donation must succeed")
	assert(PlayerData.get_available_funds() == prev_funds - 100, "Funds must be debited by $100")
	assert(PlayerData.karma > prev_karma, "Karma must increase")
	assert(PlayerData.happiness > prev_happiness, "Happiness must increase")
	assert(PlayerData.active_buffs.is_empty(), "No permanent buffs must be added to active_buffs")
	assert(PlayerData.last_charity_donation_age == 20, "last_charity_donation_age must be set to 20")
	print("✔ CHECK 3: Donation successfully granted karma and happiness with NO permanent buffs.")

	# 4. VERIFY STRICT ONCE A YEAR LIMIT ACROSS ALL CHARITIES
	assert(CharityManager.has_donated_this_year(PlayerData) == true, "has_donated_this_year must be true")
	for c in charities:
		var c_id: String = str(c.get("id", ""))
		var eval_res = CharityManager.can_donate(PlayerData, c_id)
		assert(eval_res.get("allowed", true) == false, "Donation to %s must be BLOCKED in same year" % c_id)
		assert(eval_res.get("reason", "").contains("once per year"), "Reason must specify once per year limitation")
	print("✔ CHECK 4: All charities are locked out after 1 donation in the same year.")

	# 5. VERIFY ABSENCE OF PERMANENT STAT FLOORS
	PlayerData.happiness = 10
	PlayerData.health = 10
	PlayerData.smarts = 10
	PlayerData.enforce_buffs_and_debuffs()
	assert(PlayerData.happiness == 10, "Happiness must NOT be clamped to 50%+")
	assert(PlayerData.health == 10, "Health must NOT be clamped")
	assert(PlayerData.smarts == 10, "Smarts must NOT be clamped")
	print("✔ CHECK 5: No permanent stat floor protections exist.")

	# 6. VERIFY AGING UP RESETS DONATION CAPABILITY
	PlayerData.age = 21
	assert(CharityManager.has_donated_this_year(PlayerData) == false, "Aging up must reset has_donated_this_year")
	var new_eval = CharityManager.can_donate(PlayerData, "charity_animal_shelter")
	assert(new_eval.get("allowed", false) == true, "Must be allowed to donate in new year")
	print("✔ CHECK 6: Aging up correctly unlocks annual charity donation.")

	# 7. VERIFY SAVE AND LOAD INTEGRITY
	CharityManager.donate(PlayerData, "charity_animal_shelter")
	assert(PlayerData.last_charity_donation_age == 21, "Donation recorded at age 21")
	SaveManager.save_game()

	PlayerData.reset_player()
	assert(PlayerData.last_charity_donation_age == -1, "Reset clears charity donation age")

	SaveManager.load_game()
	assert(PlayerData.last_charity_donation_age == 21, "Loaded game restores last_charity_donation_age = 21")
	assert(PlayerData.age == 21, "Loaded age is 21")
	assert(CharityManager.has_donated_this_year(PlayerData) == true, "Loaded state recognizes annual limit reached")
	assert(PlayerData.active_buffs.is_empty(), "No legacy charity buffs in active_buffs after load")
	print("✔ CHECK 7: Save & Load persistence and legacy buff cleansing verified.")

	print("\n⭐⭐⭐ ALL CHARITY ANNUAL LIMIT TESTS PASSED SUCCESSFULLY! ⭐⭐⭐\n")
	var fa := FileAccess.open("res://test_charity_result.txt", FileAccess.WRITE)
	if fa != null:
		fa.store_string("SUCCESS: ALL 7 CHECKS PASSED!\nCheck 1: Catalog cleaned of permanent blessings.\nCheck 2: Modal UI has no blessing card.\nCheck 3: Donation gives karma and happiness without permanent buffs.\nCheck 4: Locked out from donating to any other charity in same year.\nCheck 5: No permanent stat floor protections exist.\nCheck 6: Aging up unlocks charity donation.\nCheck 7: Save & Load persistence and legacy buff cleanup.")
		fa.close()
	get_tree().quit(0)
