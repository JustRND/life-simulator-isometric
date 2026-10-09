extends Node

const MainScreenScene = preload("res://scenes/main/main_screen.tscn")

func _ready() -> void:
	print("--- BEGIN UI LAYOUT & PANEL FIXES VERIFICATION ---")
	test_funds_counter_theme()
	test_duplicate_text_prevention()
	test_assets_panel_business_relocation()
	test_custom_business_name_input()
	test_modal_clipping_fixes()
	test_vehicle_purchase_license_gating()
	test_charity_activities_button_and_donations()
	test_education_exploit_text_removal()
	test_panel_bottom_bar_hiding_and_settings_fullscreen()
	test_activity_anti_spam_once_per_age()
	print("--- ALL UI LAYOUT & PANEL FIXES VERIFIED SUCCESSFULLY! ---")
	get_tree().quit(0)

func test_funds_counter_theme() -> void:
	print("Testing Cash and Bank Balance Counter Theme...")
	var screen = MainScreenScene.instantiate()
	add_child(screen)

	var balance_lbl: Label = screen.get_node_or_null("ProfileStrip/ProfileMargin/ProfileRow/BalanceLabel")
	assert(balance_lbl != null, "BalanceLabel must exist")
	assert(balance_lbl.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER, "BalanceLabel must be centered")

	var sb: StyleBoxFlat = balance_lbl.get_theme_stylebox("normal") as StyleBoxFlat
	assert(sb != null, "BalanceLabel must have a cyber StyleBoxFlat theme")
	assert(sb.border_color == Color("#10b981"), "BalanceLabel must have emerald cyber border")
	assert(sb.corner_radius_top_left >= 10, "BalanceLabel must have rounded corners")

	PlayerData.money = 420
	PlayerData.bank_savings = 580
	screen.update_ui()
	assert(balance_lbl.text.contains("💵 $420 CASH"), "BalanceLabel must show CASH caption and amount: %s" % balance_lbl.text)
	assert(balance_lbl.text.contains("🏦 $580") and (balance_lbl.text.contains("BANK BALANCE") or balance_lbl.text.contains("BANK")), "BalanceLabel must show BANK caption and amount: %s" % balance_lbl.text)
	print("✔ Cash and Bank Balance counter theme verified.")
	screen.queue_free()

func test_duplicate_text_prevention() -> void:
	print("Testing Duplicate Text Prevention...")
	var screen = MainScreenScene.instantiate()
	add_child(screen)

	# Test identical text passed
	var b1: Button = screen._create_disabled_cyber_button("Insufficient funds: Fee is $450", "Insufficient funds: Fee is $450")
	assert(b1.text == "🔒 Insufficient funds: Fee is $450", "Duplicate text must be collapsed to a single line: %s" % b1.text)

	# Test leading lock emoji already on text
	var b2: Button = screen._create_disabled_cyber_button("🔒 Insufficient funds: Fee is $450", "Insufficient funds: Fee is $450")
	assert(b2.text == "🔒 Insufficient funds: Fee is $450", "Pre-existing lock must not cause double lock: %s" % b2.text)

	# Test empty reason
	var b3: Button = screen._create_disabled_cyber_button("Requires Driving License", "")
	assert(b3.text == "🔒 Requires Driving License", "Empty reason must show single line: %s" % b3.text)

	# Test distinct reason
	var b4: Button = screen._create_disabled_cyber_button("Requires Driving License", "Take exam in Licensing Panel")
	assert(b4.text.begins_with("🔒 Requires Driving License\n"), "Distinct reason should appear on second line: %s" % b4.text)
	assert(not b4.text.contains("🔒 🔒"), "Must never have double lock emoji")

	print("✔ Duplicate requirement text prevention verified.")
	screen.queue_free()

func test_assets_panel_business_relocation() -> void:
	print("Testing Assets Panel Business Button Relocation...")
	var screen = MainScreenScene.instantiate()
	add_child(screen)

	screen._render_assets_list()
	var assets_list: VBoxContainer = screen.get_node_or_null("AssetsPanel/AssetsMargin/AssetsContent/AssetsScroll/AssetsList")
	assert(assets_list != null, "AssetsList must exist")

	# First card is Dealerships / Showrooms
	var store_card: PanelContainer = assets_list.get_child(0) as PanelContainer
	var all_buttons = store_card.find_children("*", "Button", true, false)
	# Check all buttons inside dealerships card: MUST NOT contain Cyber Enterprises
	for btn in all_buttons:
		var b := btn as Button
		assert(not b.text.contains("Cyber Enterprises"), "Cyber Enterprises MUST NOT be inside Dealerships/Showrooms! Found: %s" % b.text)

	# Find the Business section: MUST be located below OWNED REAL ESTATE & PROPERTIES
	var children = assets_list.get_children()
	var real_estate_idx: int = -1
	var business_idx: int = -1

	for i in range(children.size()):
		var c = children[i]
		var txt: String = ""
		for l in c.find_children("*", "Label", true, false):
			txt += (l as Label).text + " "
		if txt.contains("OWNED REAL ESTATE"):
			real_estate_idx = i
		elif txt.contains("COMMERCIAL ENTERPRISES"):
			business_idx = i

	assert(real_estate_idx != -1, "Real Estate section must exist")
	assert(business_idx != -1, "Commercial Enterprises section must exist")
	assert(business_idx > real_estate_idx, "Commercial Enterprises MUST be located below Real Estate! Real Estate: %d, Business: %d" % [real_estate_idx, business_idx])

	# Verify business button exists inside the Commercial Enterprises section
	var biz_section = children[business_idx]
	var found_biz_btn: bool = false
	for b in biz_section.find_children("*", "Button", true, false):
		if (b as Button).text.contains("Cyber Enterprises"):
			found_biz_btn = true
			break
	assert(found_biz_btn, "Business button must exist inside the Commercial Enterprises section")

	print("✔ Business button relocated below Owned Real Estate verified.")
	screen.queue_free()

func test_custom_business_name_input() -> void:
	print("Testing Custom Business Name Input & Incorporation...")
	PlayerData.reset()
	PlayerData.age = 25
	PlayerData.money = 500000
	PlayerData.degrees.append({
		"major": "food_science",
		"major_title": "Food Science & Culinary Arts"
	})

	var eval := BusinessManager.can_found_business("biz_coffee_shop")
	assert(eval["allowed"], "Player with degree and money should be allowed to found business: %s" % str(eval))

	var custom_name := "Neo-Shinjuku Espresso Bar"
	var res := BusinessManager.found_business("biz_coffee_shop", custom_name)
	assert(res.get("allowed", false), "Founding business should succeed: %s" % str(res))

	var found_biz = res.get("business", {})
	assert(found_biz.get("name") == custom_name, "Registered business name must match custom user input: %s" % found_biz.get("name"))

	# Verify in player data
	assert(PlayerData.owned_businesses.size() == 1, "Player must own 1 business")
	assert(PlayerData.owned_businesses[0]["name"] == custom_name, "Owned business name must match custom name")

	print("✔ Custom business name input and founding verified.")

func test_modal_clipping_fixes() -> void:
	print("Testing Modal Clipping Fixes...")
	var screen = MainScreenScene.instantiate()
	add_child(screen)

	var modal_dict: Dictionary = screen._create_cyber_modal("TEST MODAL", "Test Subtitle", Color("#38bdf8"))
	var overlay: ColorRect = modal_dict["overlay"]
	var card: PanelContainer = modal_dict["card"]
	var scroll: ScrollContainer = modal_dict["scroll"]
	var close_btn: Button = modal_dict["close_button"]

	assert(overlay != null and is_instance_valid(overlay), "Overlay must exist")
	assert(card != null and is_instance_valid(card), "Card must exist")
	assert(card.clip_contents, "Card must have clip_contents = true")
	assert(card.size_flags_horizontal == Control.SIZE_EXPAND_FILL, "Card must expand to fill")
	assert(card.size_flags_vertical == Control.SIZE_EXPAND_FILL, "Card must expand to fill")

	assert(scroll != null and is_instance_valid(scroll), "ScrollContainer must exist")
	assert(scroll.clip_contents, "ScrollContainer must have clip_contents = true")
	assert(scroll.size_flags_vertical == Control.SIZE_EXPAND_FILL, "ScrollContainer must expand to fill remaining height")

	assert(close_btn != null and is_instance_valid(close_btn), "Close button must exist")

	overlay.queue_free()
	screen.queue_free()
	print("✔ Modal non-clipping architecture verified.")

func test_vehicle_purchase_license_gating() -> void:
	print("Testing Vehicle Purchase License Requirements...")
	PlayerData.reset()
	PlayerData.age = 22
	PlayerData.money = 500000
	PlayerData.licenses.clear()

	# 1. Car requires license_car
	var car_eval := AssetCatalog.can_purchase_asset(PlayerData, "car_sedan")
	assert(not bool(car_eval.get("allowed", false)), "Car purchase must be blocked without car license")
	assert(str(car_eval.get("reason", "")).contains("Driver's License"), "Reason must mention Driver's License: %s" % car_eval.get("reason"))

	# 2. Motorcycle requires license_motorcycle
	var moto_eval := AssetCatalog.can_purchase_asset(PlayerData, "moto_cruiser")
	assert(not bool(moto_eval.get("allowed", false)), "Motorcycle purchase must be blocked without motorcycle license")
	assert(str(moto_eval.get("reason", "")).contains("Motorcycle Operator License"), "Reason must mention Motorcycle Operator License: %s" % moto_eval.get("reason"))

	# 3. Property does not require vehicle license
	var prop_eval := AssetCatalog.can_purchase_asset(PlayerData, "prop_condo")
	assert(bool(prop_eval.get("allowed", false)), "Property purchase should be allowed when funds and age match: %s" % prop_eval.get("reason"))

	# 4. Grant car license and verify car purchase succeeds
	PlayerData.licenses.append("license_car")
	var car_eval_with_lic := AssetCatalog.can_purchase_asset(PlayerData, "car_sedan")
	assert(bool(car_eval_with_lic.get("allowed", false)), "Car purchase should be allowed with car license: %s" % car_eval_with_lic.get("reason"))

	var buy_car_res := AssetCatalog.buy_asset(PlayerData, "car_sedan")
	assert(bool(buy_car_res.get("success", false)), "Car purchase must succeed: %s" % buy_car_res.get("message"))
	assert(PlayerData.owned_assets.size() == 1, "Player should have 1 owned asset")

	# 5. Grant motorcycle license and verify motorcycle purchase succeeds
	PlayerData.licenses.append("license_motorcycle")
	var moto_eval_with_lic := AssetCatalog.can_purchase_asset(PlayerData, "moto_cruiser")
	assert(bool(moto_eval_with_lic.get("allowed", false)), "Motorcycle purchase should be allowed with motorcycle license: %s" % moto_eval_with_lic.get("reason"))

	var buy_moto_res := AssetCatalog.buy_asset(PlayerData, "moto_cruiser")
	assert(bool(buy_moto_res.get("success", false)), "Motorcycle purchase must succeed: %s" % buy_moto_res.get("message"))
	assert(PlayerData.owned_assets.size() == 2, "Player should now have 2 owned assets")

	print("✔ Vehicle purchase license gating verified.")

func test_charity_activities_button_and_donations() -> void:
	print("Testing Charity Button and Philanthropy System...")
	var screen = MainScreenScene.instantiate()
	add_child(screen)

	# 1. Verify Charity Button exists in ActivitiesPanel
	var charity_btn: Button = screen.get_node_or_null("ActivitiesPanel/ActMargin/ActContent/ActScroll/ActList/CharityActItem")
	assert(charity_btn != null, "CharityActItem must exist under ActList in ActivitiesPanel")
	assert(charity_btn.text.contains("Charity"), "Charity button text must contain 'Charity': %s" % charity_btn.text)

	# 2. Verify charities catalog
	var charities := CharityManager.get_all_charities()
	assert(charities.size() >= 6, "Must provide multiple charity options (found %d)" % charities.size())

	# 3. Verify hidden karma rule across all charities!
	for c in charities:
		var desc: String = str(c.get("description", ""))
		var c_name: String = str(c.get("name", ""))

		# Description must NOT mention specific numerical karma value
		assert(not desc.to_lower().contains("karma +") and not desc.to_lower().contains("+1") and not desc.to_lower().contains("+2"), "Charity description must NEVER specify karma numerical boost: %s" % desc)

		assert(int(c.get("hidden_karma_boost", 0)) > 0, "Charity %s must have positive hidden karma boost" % c_name)
		assert(int(c.get("happiness_boost", 0)) > 0, "Charity %s must have positive happiness boost" % c_name)
		# Permanent blessings removed per user requirements
		assert(not c.has("buff_id"), "Charity %s must NOT grant permanent buffs" % c_name)

	# 4. Verify age requirement gating
	PlayerData.reset()
	PlayerData.age = 4
	PlayerData.money = 1000
	var age_eval := CharityManager.can_donate(PlayerData, "charity_food_bank")
	assert(not bool(age_eval.get("allowed", false)), "Player under min age should not be allowed to donate")

	# 5. Verify funds gating
	PlayerData.age = 18
	PlayerData.money = 50
	PlayerData.bank_savings = 0
	var funds_eval := CharityManager.can_donate(PlayerData, "charity_food_bank")
	assert(not bool(funds_eval.get("allowed", false)), "Player with insufficient funds should not be allowed to donate")

	# 6. Verify successful donation, hidden karma increase, happiness increase, NO permanent buffs
	PlayerData.money = 100000
	PlayerData.bank_savings = 50000
	PlayerData.karma = 10
	PlayerData.happiness = 30
	PlayerData.active_buffs.clear()

	var prev_funds := PlayerData.get_available_funds()
	var donate_res := CharityManager.donate(PlayerData, "charity_food_bank")
	assert(bool(donate_res.get("success", false)), "Donation should succeed: %s" % str(donate_res))
	assert(PlayerData.get_available_funds() == prev_funds - 100, "Should deduct $100 donation fee from available funds")
	assert(PlayerData.happiness > 30, "Happiness must increase significantly")
	assert(PlayerData.karma > 10, "Hidden karma must increase significantly")
	assert(PlayerData.active_buffs.is_empty(), "Must NOT grant permanent buffs")
	assert(PlayerData.total_donated_charity == 100, "Lifetime donated tracking must be updated")

	# 7. Verify NO buff protection floors (happiness can naturally drop)
	PlayerData.happiness = 10
	PlayerData.enforce_buffs_and_debuffs()
	assert(PlayerData.happiness == 10, "Charity must not permanently floor happiness at 50%")

	# 8. Test annual limit: donating to a second charity in the same year must be blocked
	var donate_second_eval := CharityManager.can_donate(PlayerData, "charity_childrens_wing")
	assert(not bool(donate_second_eval.get("allowed", false)), "Donating to another charity in the same year must be rejected")
	assert(donate_second_eval.get("reason", "").contains("once per year"), "Reason must mention once per year limit")

	screen.queue_free()
	print("✔ Charity button and philanthropy system verified.")

func test_education_exploit_text_removal() -> void:
	print("Testing Removal of 'Exploit' text across Education and Activity Panels...")
	var screen = MainScreenScene.instantiate()
	add_child(screen)

	# Verify script content does not contain exploit phrase in study/gating banners
	var script_src: String = FileAccess.get_file_as_string("res://scenes/main/main_screen.gd")
	assert(not script_src.contains("To prevent status modifier exploits"), "'To prevent status modifier exploits' must be removed from codebase")
	assert(not script_src.contains("exploit prevention"), "'exploit prevention' must be removed from workout banner")

	screen.queue_free()
	print("✔ Removal of exploit wording verified.")

func test_panel_bottom_bar_hiding_and_settings_fullscreen() -> void:
	print("Testing Bottom Bar Hiding When Panels Open & Full Screen Settings...")
	var screen = MainScreenScene.instantiate()
	add_child(screen)

	PlayerData.age = 20

	# 1. Timeline (home): action bar and age button must be visible
	screen.show_tab("timeline")
	assert(screen.action_bar != null, "ActionBar must exist")
	assert(screen.age_button != null, "AgeButton must exist")
	assert(screen.action_bar.visible == true, "ActionBar must be visible on timeline")
	assert(screen.age_button.visible == true, "AgeButton must be visible on timeline")

	# 2. When opening panels, bottom 5 buttons (ActionBar + AgeButton) must be hidden
	var panels_to_test := ["activities", "relationships", "assets", "infant", "character", "bank", "settings"]
	for p in panels_to_test:
		screen.show_tab(p)
		assert(screen.action_bar.visible == false, "ActionBar must be HIDDEN when %s panel is open" % p)
		assert(screen.age_button.visible == false, "AgeButton must be HIDDEN when %s panel is open" % p)

		# Returning to timeline restores the bottom row
		screen.show_tab("timeline")
		assert(screen.action_bar.visible == true, "ActionBar must be RESTORED after closing %s panel" % p)
		assert(screen.age_button.visible == true, "AgeButton must be RESTORED after closing %s panel" % p)

	# 3. Settings panel format matching ActivitiesPanel
	var act_panel: PanelContainer = screen.activities_panel
	var settings_card: PanelContainer = screen.settings_overlay.get_node("SettingsCard")
	assert(settings_card != null, "SettingsCard must exist")

	# Full-screen layout matching: offset_top == 260.0, anchor_bottom == 1.0, anchor_right == 1.0
	assert(is_equal_approx(settings_card.offset_top, act_panel.offset_top), "SettingsCard offset_top (%f) must match ActivitiesPanel (%f)" % [settings_card.offset_top, act_panel.offset_top])
	assert(settings_card.anchor_bottom == 1.0, "SettingsCard anchor_bottom must be 1.0")
	assert(settings_card.anchor_right == 1.0, "SettingsCard anchor_right must be 1.0")

	# Margins matching ActivitiesPanel (42, 36, 42, 36)
	var settings_margin: MarginContainer = settings_card.get_node("SettingsMargin")
	var act_margin: MarginContainer = act_panel.get_node("ActMargin")
	assert(settings_margin.get_theme_constant("margin_left") == act_margin.get_theme_constant("margin_left"), "SettingsMargin left must match ActMargin")
	assert(settings_margin.get_theme_constant("margin_top") == act_margin.get_theme_constant("margin_top"), "SettingsMargin top must match ActMargin")
	assert(settings_margin.get_theme_constant("margin_right") == act_margin.get_theme_constant("margin_right"), "SettingsMargin right must match ActMargin")
	assert(settings_margin.get_theme_constant("margin_bottom") == act_margin.get_theme_constant("margin_bottom"), "SettingsMargin bottom must match ActMargin")

	# Title font size matching ActivitiesPanel (40)
	var settings_title: Label = settings_card.find_child("SettingsTitle", true, false)
	var act_title: Label = act_panel.find_child("ActTitle", true, false)
	assert(settings_title != null and act_title != null, "Titles must exist")
	assert(settings_title.get_theme_font_size("font_size") == act_title.get_theme_font_size("font_size"), "SettingsTitle font_size (%d) must match ActTitle (%d)" % [settings_title.get_theme_font_size("font_size"), act_title.get_theme_font_size("font_size")])

	# Close button size & font size matching ActivitiesPanel
	var close_settings_btn: Button = settings_card.find_child("CloseSettingsHeaderButton", true, false)
	var close_act_btn: Button = act_panel.find_child("CloseActButton", true, false)
	assert(close_settings_btn != null and close_act_btn != null, "Close buttons must exist")
	assert(close_settings_btn.custom_minimum_size == close_act_btn.custom_minimum_size, "CloseSettingsHeaderButton size must match CloseActButton")
	assert(close_settings_btn.get_theme_font_size("font_size") == close_act_btn.get_theme_font_size("font_size"), "Close button font sizes must match")
	# Shop button must NOT be present on main screen TopBar
	var topbar_row: HBoxContainer = screen.get_node("TopBar/Row")
	assert(topbar_row.find_child("ShopButton", true, false) == null, "ShopButton must NOT be present on main screen TopBar")

	screen.queue_free()
	print("✔ Bottom bar hiding, full screen settings layout, and shop button removal verified.")

func test_activity_anti_spam_once_per_age() -> void:
	print("Testing Activity Anti-Spam (Once per Age Limit)...")
	var screen = MainScreenScene.instantiate()
	add_child(screen)

	PlayerData.reset()
	PlayerData.age = 22
	PlayerData.money = 20000
	PlayerData.bank_savings = 50000

	# 1. Social Media Anti-Spam
	SocialMediaManager.create_account(PlayerData, "youtube")
	var post1 = SocialMediaManager.create_post(PlayerData, "youtube")
	assert(post1["success"], "First post must succeed")
	var post2 = SocialMediaManager.create_post(PlayerData, "youtube")
	assert(not post2["success"], "Second post at same age must be blocked: %s" % post2["message"])
	assert(post2["message"].contains("Annual Post Limit"), "Post message must mention annual limit")

	var ad1 = SocialMediaManager.buy_followers(PlayerData, "youtube", 0)
	assert(ad1["success"], "First ad campaign must succeed")
	var ad2 = SocialMediaManager.buy_followers(PlayerData, "youtube", 0)
	assert(not ad2["success"], "Second ad campaign at same age must be blocked: %s" % ad2["message"])
	assert(ad2["message"].contains("Annual Campaign Limit"), "Ad message must mention annual limit")

	var troll1 = SocialMediaManager.troll_someone(PlayerData, "youtube")
	assert(troll1["success"], "First troll must succeed")
	var troll2 = SocialMediaManager.troll_someone(PlayerData, "youtube")
	assert(not troll2["success"], "Second troll at same age must be blocked: %s" % troll2["message"])
	assert(troll2["message"].contains("Internet Cooldown") or troll2["message"].contains("next year"), "Troll message must mention cooldown until next year")

	# 2. Charity Anti-Spam
	var donate1 = CharityManager.donate(PlayerData, "charity_food_bank")
	assert(donate1["success"], "First donation to charity_food_bank must succeed")
	var can_donate_again = CharityManager.can_donate(PlayerData, "charity_food_bank")
	assert(not can_donate_again["allowed"], "Second donation to charity_food_bank at same age must be rejected")
	assert(can_donate_again["reason"].contains("Annual Donation Made") or can_donate_again["reason"].contains("next year"), "Must state annual contribution made")

	# 3. Salon & Spa Tracking & UI Lock
	assert(PlayerData.last_salon_activity_age == -1, "last_salon_activity_age starts at -1")
	PlayerData.last_salon_activity_age = PlayerData.age
	assert(PlayerData.last_salon_activity_age == 22, "last_salon_activity_age records current age")
	PlayerData.last_spa_activity_age = PlayerData.age
	assert(PlayerData.last_spa_activity_age == 22, "last_spa_activity_age records current age")

	# 4. Pet Interaction & Adoption Anti-Spam
	var cat_spec = {"id": "test_cat", "name": "Mimi", "type": "cat", "species": "Persian Cat", "breed": "Persian", "price": 0, "upkeep": 50, "icon": "🐱", "health": 90, "happiness": 90, "lifespan": 15}
	var adopt1 = PetManager.adopt_pet(PlayerData, cat_spec, "Mimi", true)
	assert(adopt1["success"], "First adoption must succeed")
	var adopt2 = PetManager.adopt_pet(PlayerData, cat_spec, "Kiki", true)
	assert(not adopt2["success"], "Second adoption at same age must be blocked")
	assert(adopt2["message"].contains("Annual Adoption Limit"), "Must cite annual adoption limit")

	var pet_inst = PlayerData.pets[0]
	var play1 = PetManager.interact_pet(PlayerData, pet_inst["id"], "play")
	assert(play1["success"], "First pet play must succeed")
	var play2 = PetManager.interact_pet(PlayerData, pet_inst["id"], "play")
	assert(not play2["success"], "Second pet play at same age must be blocked")

	# 5. Dating App Anti-Spam
	assert(PlayerData.last_dating_app_age == -1, "last_dating_app_age starts at -1")
	PlayerData.last_dating_app_age = PlayerData.age

	# 6. Save & Load Persistence of Anti-Spam variables
	SaveManager.save_game()
	PlayerData.reset()
	SaveManager.load_game()
	assert(PlayerData.last_salon_activity_age == 22, "last_salon_activity_age must persist")
	assert(PlayerData.last_spa_activity_age == 22, "last_spa_activity_age must persist")
	assert(PlayerData.last_dating_app_age == 22, "last_dating_app_age must persist")
	assert(PlayerData.last_pet_adoption_age == 22, "last_pet_adoption_age must persist")
	assert(PlayerData.last_charity_donation_age == 22, "last_charity_donation_age must persist as integer")

	# 7. Aging Up resets availability
	PlayerData.age = 23
	var post_new_age = SocialMediaManager.create_post(PlayerData, "youtube")
	assert(post_new_age["success"], "Post must succeed after aging up")
	var can_donate_new_age = CharityManager.can_donate(PlayerData, "charity_food_bank")
	assert(can_donate_new_age["allowed"], "Donation must be allowed after aging up")
	var play_new_age = PetManager.interact_pet(PlayerData, pet_inst["id"], "play")
	assert(play_new_age["success"], "Pet play must succeed after aging up")

	screen.queue_free()
	print("✔ All activity buttons anti-spam (once per age) verified successfully.")

