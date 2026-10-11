extends Node

func _ready() -> void:
	print("--- BEGIN TEST PROGRESSION REWORK ---")
	test_starting_state()
	test_calendar_and_realtime_day_progression()
	test_monthly_financial_systems()
	test_year_rollover_and_aging()
	test_inheritance_mechanics()
	test_ui_action_bar_and_version()
	print("--- ALL PROGRESSION REWORK TESTS PASSED! ---")
	get_tree().quit(0)


func assert_true(cond: bool, msg: String) -> void:
	if not cond:
		push_error("ASSERTION FAILED: " + msg)
		print("FAILED: " + msg)
		get_tree().quit(1)
		assert(false, msg)
	else:
		print("  ✓ " + msg)


func test_starting_state() -> void:
	print("\nTesting Starting State (Age 12 & Calendar)...")
	PlayerData.reset_player()
	assert_true(PlayerData.age == 12, "Default player age is 12 (was 0)")
	assert_true(PlayerData.in_game_day == 1, "Initial in-game day is 1")
	assert_true(PlayerData.in_game_month == 1, "Initial in-game month is 1")
	assert_true(PlayerData.in_game_year == 1, "Initial in-game year is 1")
	assert_true(PlayerData.education_level == "Middle School", "Initial education is Middle School")
	assert_true(PlayerData.get_date_string() == "Month 1, Day 1", "Date string formats correctly")
	assert_true(PlayerData.get_stage_name() == "Child", "Age 12 stage name is Child")


func test_calendar_and_realtime_day_progression() -> void:
	print("\nTesting Real-Time Calendar Tick (1s = 1 day)...")
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.is_dead = false
	PlayerData.is_time_paused = false
	PlayerData.in_game_day = 1
	PlayerData.in_game_month = 1

	var main_screen = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_screen)
	main_screen.hide_new_game_screen()
	PlayerData.has_started_game = true
	PlayerData.is_dead = false
	PlayerData.is_time_paused = false
	PlayerData.in_game_day = 1
	PlayerData.in_game_month = 1

	# Simulate 1 second elapsed
	main_screen._process(1.0)
	assert_true(PlayerData.in_game_day == 2, "1 second advances exactly 1 in-game day (now day 2)")

	# Simulate 5 seconds elapsed
	main_screen._process(5.0)
	assert_true(PlayerData.in_game_day == 7, "5 seconds advances 5 in-game days (now day 7)")

	main_screen.queue_free()


func test_monthly_financial_systems() -> void:
	print("\nTesting Monthly Financial Cycles...")
	PlayerData.reset_player()
	PlayerData.age = 25
	PlayerData.money = 10000
	PlayerData.bank_savings = 50000
	PlayerData.job_title = "Software Engineer"
	PlayerData.job_company = "CyberTech Corp"
	PlayerData.job_salary = 120000 # $120,000 / yr = $10,000 / mo

	var initial_bank: int = PlayerData.bank_savings
	var m_salary: int = int(round(float(PlayerData.job_salary) / 12.0))
	PlayerData.receive_salary(m_salary)
	assert_true(PlayerData.bank_savings == initial_bank + 10000, "Monthly salary deposits 1/12th annual salary ($10,000)")

	# 1. Monthly Rental
	var rent_res := RentalManager.can_rent(PlayerData, "rent_micro_studio")
	assert_true(rent_res.get("allowed", false), "Adult can rent micro studio")
	var lease_res := RentalManager.sign_lease(PlayerData, "rent_micro_studio")
	assert_true(lease_res.get("success", false), "Lease successfully signed with monthly rent upfront")
	var rent_logs := RentalManager.process_monthly_rent(PlayerData)
	assert_true(not rent_logs.is_empty(), "Monthly rent deduction processed successfully")

	# 2. Monthly Mortgages
	var mtg_plan := MortgageManager.calculate_mortgage_plan(100000, 15, 0.05)
	assert_true(mtg_plan.has("principal"), "Mortgage plan calculated")
	var mtg_eval := MortgageManager.can_apply_mortgage(PlayerData, 100000, 15, 0.05)
	assert_true(mtg_eval.get("allowed", false), "Can apply for mortgage")
	var mtg_apply := MortgageManager.apply_for_mortgage(PlayerData, "prop_starter_home", 15, 0.05)
	assert_true(mtg_apply.get("success", false), "Mortgage approved and granted")
	var mtg_logs := MortgageManager.process_monthly_mortgages(PlayerData)
	assert_true(not mtg_logs.is_empty(), "Monthly mortgage installment processed successfully")

	# 3. Monthly Asset Upkeep & Property Maintenance
	var car := AssetCatalog.create_asset_instance("car_sedan", 25)
	PlayerData.owned_assets.append(car)
	var m_car_upkeep: int = AssetCatalog.get_monthly_upkeep(car)
	assert_true(m_car_upkeep == maxi(1, int(round(1900.0 / 12.0))), "Car monthly upkeep is 1/12th annual ($%d/mo)" % m_car_upkeep)

	var house := AssetCatalog.create_asset_instance("prop_townhouse", 25)
	PlayerData.owned_assets.append(house)
	var m_house_maint: int = AssetCatalog.get_monthly_upkeep(house)
	assert_true(m_house_maint > 0, "House monthly maintenance is positive ($%d/mo)" % m_house_maint)

	var asset_logs := AssetCatalog.process_monthly_assets(PlayerData)
	assert_true(PlayerData.owned_assets.size() >= 2, "Owned assets preserved during monthly upkeep")

	# 4. Monthly Pet Care & Food Upkeep
	var puppy_spec: Dictionary = {
		"type": "dog",
		"breed": "Cyber Corgi",
		"price": 1200,
		"upkeep": 240
	}
	var pet_res := PetManager.adopt_pet(PlayerData, puppy_spec, "Pixel", true)
	assert_true(pet_res.get("success", false), "Adopted pet for monthly care testing")
	var corgi: Dictionary = PlayerData.pets[0]
	var m_pet_upkeep: int = PetManager.get_monthly_pet_upkeep(corgi)
	assert_true(m_pet_upkeep == maxi(5, int(round(240.0 / 12.0))), "Pet monthly upkeep is 1/12th annual ($%d/mo)" % m_pet_upkeep)
	var pet_logs := PetManager.process_monthly_pets(PlayerData)
	assert_true(PlayerData.pets.size() >= 1, "Pet maintained successfully through monthly care cycle")

	# 5. Monthly Neural Specialist Maintenance
	PlayerData.money = 5000000
	var install_res := PlayerData.install_neural_implant("cortex_neurolink_mk1")
	assert_true(install_res.get("success", false), "Installed neural implant")
	var m_neural := PlayerData.get_monthly_neural_maintenance()
	assert_true(m_neural > 0, "Monthly neural maintenance is positive ($%d)" % m_neural)
	var neural_logs := PlayerData.process_monthly_neural_implants()
	assert_true(not neural_logs.is_empty(), "Monthly neural implant maintenance auto-debited")

	# 5. Monthly Asset Insurance
	var ins_buy := AssetInsuranceManager.buy_insurance(PlayerData, AssetInsuranceManager.CATEGORY_VEHICLE)
	assert_true(ins_buy.get("success", false), "Vehicle insurance purchased with monthly premium")
	var ins_logs := AssetInsuranceManager.process_monthly_insurance(PlayerData)
	assert_true(not ins_logs.is_empty(), "Monthly asset insurance processed successfully")

	# 6. Monthly Taxes
	var tax_res := TaxSystem.process_monthly_taxes(PlayerData)
	assert_true(tax_res.has("monthly_due"), "Monthly tax report returned valid assessment")

	# 7. Monthly Pension Account Processing
	var ps_mgr = preload("res://scripts/economy/pension_and_savings_manager.gd")
	ps_mgr.ensure(PlayerData)
	ps_mgr.set_pension_contribution_pct(PlayerData, 0.10)
	var pre_pension_bal: int = int(PlayerData.pension_account.get("balance", 0))
	var ps_logs := ps_mgr.process_monthly_accounts(PlayerData)
	var post_pension_bal: int = int(PlayerData.pension_account.get("balance", 0))
	assert_true(post_pension_bal > pre_pension_bal, "Monthly pension contribution and employer match credited ($%d -> $%d)" % [pre_pension_bal, post_pension_bal])

	# 8. Monthly Social Media Monetization
	var sm_mgr = preload("res://scripts/economy/social_media_manager.gd")
	PlayerData.social_media["instagram"] = {
		"followers": 50000,
		"verified": true,
		"posts_this_year": 1,
		"post_age": PlayerData.age,
		"is_suspended": false
	}
	var pre_sm_money: int = PlayerData.money
	var sm_logs := sm_mgr.process_monthly_social_media(PlayerData)
	assert_true(PlayerData.money > pre_sm_money, "Monthly social media creator payout credited ($%d -> $%d)" % [pre_sm_money, PlayerData.money])

	# 9. Monthly Commercial Business Profit Dividends
	var biz_mgr = preload("res://scripts/economy/business_manager.gd")
	PlayerData.owned_businesses = [{
		"id": "biz_tech_startup",
		"name": "Nova Cybernetics",
		"type": "it_startup",
		"category": "Technology",
		"equity_share": 1.0,
		"capital": 250000,
		"total_revenue": 120000,
		"total_expenses": 60000,
		"net_profit": 60000,
		"employee_count": 5,
		"annual_payroll": 30000,
		"years_active": 2,
		"historical_profits": [60000]
	}]
	var pre_biz_bank: int = PlayerData.bank_savings
	var biz_logs := biz_mgr.process_monthly_dividends(PlayerData)
	assert_true(PlayerData.bank_savings > pre_biz_bank, "Monthly business dividend credited ($%d -> $%d)" % [pre_biz_bank, PlayerData.bank_savings])


func test_year_rollover_and_aging() -> void:
	print("\nTesting Year Rollover & Aging (Month 12 -> Month 1)...")
	var main_screen = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_screen)
	main_screen.hide_new_game_screen()
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.is_dead = false
	PlayerData.is_time_paused = false
	PlayerData.age = 12
	PlayerData.in_game_day = 30
	PlayerData.in_game_month = 12
	PlayerData.in_game_year = 1

	# Advance 1 day past Day 30 of Month 12 -> triggers Month 1 of next year and age_up()
	main_screen._process(1.0)
	assert_true(PlayerData.in_game_day == 1, "Day rolls over from 30 to 1")
	assert_true(PlayerData.in_game_month == 1, "Month rolls over from 12 to 1")
	assert_true(PlayerData.age == 13, "Character successfully ages up from 12 to 13 upon year completion")
	assert_true(PlayerData.in_game_year == 2, "In-game year increments to 2")

	main_screen.queue_free()


func test_inheritance_mechanics() -> void:
	print("\nTesting Death & Inheritance Succession...")
	PlayerData.reset_player()
	PlayerData.first_name = "Grand Patriarch"
	PlayerData.age = 70
	PlayerData.money = 250000
	PlayerData.bank_savings = 1000000
	PlayerData.children = [
		{"name": "Eldest Heir", "age": 28, "gender": "FEMALE", "ethnicity": "white", "portrait_track": 1, "portrait_variant": 1}
	]

	var heir_data: Dictionary = PlayerData.children[0]
	var liquid_total: int = PlayerData.money + PlayerData.bank_savings
	PlayerData.takeover_as_heir(heir_data, liquid_total, PlayerData.owned_assets, "child")

	assert_true(PlayerData.first_name == "Eldest Heir", "Heir took over first name")
	assert_true(PlayerData.age == 28, "Heir maintained their respective age (28)")
	assert_true(PlayerData.bank_savings >= liquid_total, "Liquid estate transferred to heir's bank balance ($%d)" % PlayerData.bank_savings)
	assert_true(PlayerData.in_game_day == 1 and PlayerData.in_game_month == 1, "Succession reset in-game calendar to start of cycle")


func test_ui_action_bar_and_version() -> void:
	print("\nTesting UI Action Bar, Labels & Version Numbers...")
	var main_screen = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_screen)

	# 1. Version checks
	var ver_label: Label = main_screen.find_child("AlphaVersionLabel", true, false) as Label
	assert_true(ver_label != null and ver_label.text == "v0.3.0", "Top-right version badge displays 'v0.3.0'")

	var loading_label: Label = main_screen.find_child("LoadingDetailsLabel", true, false) as Label
	assert_true(loading_label != null and loading_label.text == "v0.3.0 • Progression Rework", "Loading screen details label displays 'v0.3.0 • Progression Rework'")

	# 2. Time Counter beside Age Counter
	var age_lbl: Label = main_screen.find_child("AgeLabel", true, false) as Label
	var time_lbl: Label = main_screen.find_child("TimeCounterLabel", true, false) as Label
	assert_true(age_lbl != null, "AgeLabel exists")
	assert_true(time_lbl != null, "TimeCounterLabel exists beside AgeLabel")
	assert_true(age_lbl.get_parent() == time_lbl.get_parent(), "AgeLabel and TimeCounterLabel share the same parent container (AgeRow)")

	# 3. Action Bar Compacting (No AgeButton, No AgeSpacer, 4 Buttons)
	var age_btn = main_screen.find_child("AgeButton", true, false)
	assert_true(age_btn == null, "AgeButton has been removed from main screen")

	var age_spacer = main_screen.find_child("AgeSpacer", true, false)
	assert_true(age_spacer == null, "AgeSpacer has been removed from ActionRow")

	var action_row = main_screen.find_child("ActionRow", true, false)
	assert_true(action_row != null, "ActionRow exists")
	var button_count: int = 0
	var button_names: Array[String] = []
	for child in action_row.get_children():
		if child is Button:
			button_count += 1
			button_names.append(child.name)
	assert_true(button_count == 4, "Action bar has strictly 4 buttons (found: %d -> %s)" % [button_count, str(button_names)])

	var infant_btn: Button = main_screen.find_child("InfantButton", true, false) as Button
	assert_true(infant_btn != null and infant_btn.text == "Life Overview", "First action button text is 'Life Overview'")

	main_screen.queue_free()
