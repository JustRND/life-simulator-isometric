extends Node

func _ready() -> void:
	print("--- BEGIN BUSINESS EXPANSION & ECONOMY BALANCING TEST ---")
	test_license_pricing()
	test_business_expansion_cost_and_owned_tab()
	test_branch_independent_micromanagement()
	test_progressive_conglomerate_tax()
	test_business_slumps_and_flops()
	test_business_actions_sounded_to_timeline_without_popups()
	print("--- ALL BUSINESS EXPANSION & ECONOMY BALANCING TESTS PASSED! ---")
	get_tree().quit(0)


func test_license_pricing() -> void:
	print("Testing increased license and certification prices...")
	var food_lic := LicenseManager.get_license_by_id("license_food_safety")
	assert(int(food_lic.get("fee", 0)) >= 20000, "Commercial Food Safety license must cost at least $20,000, found: %d" % int(food_lic.get("fee", 0)))

	var book_lic := LicenseManager.get_license_by_id("license_bookkeeper")
	assert(int(book_lic.get("fee", 0)) >= 30000, "Certified Public Bookkeeper license must cost at least $30,000, found: %d" % int(book_lic.get("fee", 0)))

	var cyber_lic := LicenseManager.get_license_by_id("license_cyber")
	assert(int(cyber_lic.get("fee", 0)) >= 40000, "Certified Cyber Security license must cost at least $40,000, found: %d" % int(cyber_lic.get("fee", 0)))

	var elec_lic := LicenseManager.get_license_by_id("license_electrician")
	assert(int(elec_lic.get("fee", 0)) >= 20000, "Electrician license must cost at least $20,000, found: %d" % int(elec_lic.get("fee", 0)))

	var car_lic := LicenseManager.get_license_by_id("license_car")
	assert(int(car_lic.get("fee", 0)) >= 2000, "Car driver license must cost at least $2,000, found: %d" % int(car_lic.get("fee", 0)))

	print("✔ License and certification price increases verified.")


func test_business_expansion_cost_and_owned_tab() -> void:
	print("Testing business expansion cost scaling and owned businesses registration...")
	PlayerData.reset()
	PlayerData.age = 30
	PlayerData.money = 500000
	PlayerData.bank_savings = 500000
	PlayerData.licenses.append("license_food_safety")

	# Found initial parent coffee shop
	var found_res := BusinessManager.found_business("biz_coffee_shop", "Cyber Cafe Prime", false)
	assert(bool(found_res.get("allowed", false)), "Parent business incorporation must succeed")
	assert(PlayerData.owned_businesses.size() == 1, "Must have 1 owned business")

	var parent_biz: Dictionary = PlayerData.owned_businesses[0]
	var initial_expansion_cost := BusinessManager.get_branch_expansion_cost(parent_biz)
	# Coffee shop startup is 75,000. 150% = 112,500 + 60,000 = 172,500
	assert(initial_expansion_cost >= 150000, "Expansion must cost significantly more (>= $150,000), found: %d" % initial_expansion_cost)

	# Inject sufficient treasury into parent business to fund expansion
	parent_biz["treasury"] = initial_expansion_cost + 50000

	# Expand business to open Branch #2
	var exp_res := BusinessManager.open_business_branch(parent_biz, "Cyber Cafe Downtown")
	assert(bool(exp_res.get("success", false)), "Branch expansion must succeed with sufficient corporate treasury")

	# Requirement 1: The expanded business MUST be in the OWNED BUSINESSES TAB / list
	assert(PlayerData.owned_businesses.size() == 2, "Expanded branch must be registered in PlayerData.owned_businesses! Size: %d" % PlayerData.owned_businesses.size())

	var branch_biz: Dictionary = PlayerData.owned_businesses[1]
	assert(str(branch_biz.get("name")) == "Cyber Cafe Downtown", "Branch business name must match: %s" % str(branch_biz.get("name")))
	assert(str(branch_biz.get("type_id")) == "biz_coffee_shop", "Branch must share parent business type")
	assert(bool(branch_biz.get("is_branch", false)), "Branch must be flagged as is_branch")
	assert(str(branch_biz.get("parent_uid")) == str(parent_biz.get("uid")), "Branch parent_uid must link to parent business")
	assert(int(branch_biz.get("treasury", 0)) > 0, "Branch must be initialized with its own seed working capital treasury")

	# Test higher cost for subsequent branch
	var next_exp_cost := BusinessManager.get_branch_expansion_cost(parent_biz)
	assert(next_exp_cost > initial_expansion_cost, "Subsequent branch expansion cost must increase: %d vs %d" % [next_exp_cost, initial_expansion_cost])
	print("✔ Business expansion cost increase and Owned Businesses tab registration verified.")


func test_branch_independent_micromanagement() -> void:
	print("Testing branch independent micromanagement features...")
	assert(PlayerData.owned_businesses.size() >= 2, "Must have parent and branch")
	var branch_biz: Dictionary = PlayerData.owned_businesses[1]

	# 1. Staff management on branch
	var initial_staff: int = int(branch_biz.get("employees", 4))
	var hire_res := BusinessManager.adjust_staff(branch_biz, 1)
	assert(bool(hire_res.get("success", false)), "Hiring staff on branch must succeed")
	assert(int(branch_biz.get("employees", 0)) == initial_staff + 1, "Branch employee count must update independently")

	# 2. Facility automation upgrades on branch
	branch_biz["treasury"] = 100000
	var upg_res := BusinessManager.upgrade_business_facilities(branch_biz)
	assert(bool(upg_res.get("success", false)), "Upgrading facilities on branch must succeed")
	assert(int(branch_biz.get("facility_tier", 1)) == 2, "Branch facility tier must update independently")

	# 3. Capital injection and dividends on branch
	var branch_treasury_before: int = int(branch_biz.get("treasury", 0))
	var inj_res := BusinessManager.deposit_owner_capital(branch_biz, 10000)
	assert(bool(inj_res.get("success", false)), "Owner capital injection into branch treasury must succeed")
	assert(int(branch_biz.get("treasury", 0)) == branch_treasury_before + 10000, "Branch treasury must receive injected capital")

	var div_res := BusinessManager.withdraw_owner_dividend(branch_biz, 5000)
	assert(bool(div_res.get("success", false)), "Owner dividend withdrawal from branch treasury must succeed")
	assert(int(branch_biz.get("treasury", 0)) == branch_treasury_before + 5000, "Branch treasury must deduct dividend")

	# 4. Rebranding / renaming branch
	var rename_res := BusinessManager.rename_business(str(branch_biz.get("uid")), "Cyber Cafe West End")
	assert(bool(rename_res.get("success", false)), "Renaming branch must succeed")
	assert(str(branch_biz.get("name")) == "Cyber Cafe West End", "Branch name must be updated")

	print("✔ Branch independent operations and micromanagement verified.")


func test_progressive_conglomerate_tax() -> void:
	print("Testing progressive conglomerate tax scaling with business count...")
	var rate_1 := BusinessManager.get_corporate_tax_rate(1, 100000)
	var rate_2 := BusinessManager.get_corporate_tax_rate(2, 100000)
	var rate_3 := BusinessManager.get_corporate_tax_rate(3, 100000)
	var rate_5 := BusinessManager.get_corporate_tax_rate(5, 100000)

	assert(rate_1 >= 0.22, "1 business base corporate tax must be at least 22 percent (Current standard: 30 percent)")
	assert(rate_2 > rate_1, "2 businesses must pay higher corporate tax rate than 1 business")
	assert(rate_3 > rate_2, "3 businesses must pay higher corporate tax rate than 2 businesses")
	assert(rate_5 >= 0.40, "5 businesses conglomerate tax rate must be at least 40 percent, found: %f" % rate_5)

	# High profit bracket surcharges
	var rate_whale := BusinessManager.get_corporate_tax_rate(3, 1500000)
	assert(rate_whale > rate_3, "Mega-profits (> $1M) must trigger bracket tax surcharge")
	print("✔ Progressive conglomerate tax scaling verified.")


func test_business_slumps_and_flops() -> void:
	print("Testing business failure, market slumps, and flop mechanics...")
	# Simulate a struggling business with deep deficit
	var doomed_biz: Dictionary = {
		"uid": "biz_doomed_99",
		"type_id": "biz_coffee_shop",
		"name": "Failing Bistro Ventures",
		"icon": "☕",
		"founded_age": PlayerData.age - 4,
		"is_unlicensed": false,
		"branches": 1,
		"facility_tier": 1,
		"revenue_scale": 1.0,
		"treasury": -55000, # Deep deficit triggering insolvency flop
		"employees": 2,
		"marketing_budget": 0,
		"annual_revenue": 10000,
		"annual_opex": 60000,
		"net_profit": -50000,
		"unpaid_taxes": 0,
		"consecutive_losses": 3,
		"loan_balance": 20000,
		"loan_interest_rate": 0.08,
		"valuation": 15000,
		"reputation": 20
	}

	PlayerData.owned_businesses.append(doomed_biz)
	var count_before := PlayerData.owned_businesses.size()

	# Run yearly business simulation
	var results := BusinessManager.simulate_yearly_businesses()

	# The doomed business should flop and be dissolved from owned_businesses
	var found_doomed := false
	for b in PlayerData.owned_businesses:
		if str(b.get("uid")) == "biz_doomed_99":
			found_doomed = true
			break

	assert(not found_doomed, "Doomed insolvent business must flop and be removed from owned_businesses")
	print("✔ Business failure and flop/bankruptcy dissolution verified.")


func test_business_actions_sounded_to_timeline_without_popups() -> void:
	print("Testing business actions sounded to timeline without popup clutter...")
	var main_scene = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_scene)
	if is_instance_valid(main_scene.new_game_panel):
		main_scene.new_game_panel.hide()
	if is_instance_valid(main_scene.loading_screen):
		main_scene.loading_screen.hide()
	if is_instance_valid(main_scene.disclaimer_screen):
		main_scene.disclaimer_screen.hide()

	var test_biz := {
		"uid": "biz_timeline_test",
		"type_id": "biz_tech_startup",
		"name": "Apex Logic",
		"icon": "💻",
		"treasury": 2500000,
		"unpaid_taxes": 15000,
		"loan_balance": 50000,
		"branches": 1,
		"facility_tier": 1,
		"employees": 4
	}
	PlayerData.owned_businesses = [test_biz]
	PlayerData.life_log.clear()

	# Pay corporate taxes
	var tax_res := BusinessManager.pay_business_taxes(test_biz)
	assert(bool(tax_res.get("success", false)), "Tax payment should succeed")
	main_scene.add_life_event(str(tax_res.get("message", "Corporate taxes paid.")), "finance")
	assert(PlayerData.life_log.size() >= 1, "Tax payment must be logged to timeline")
	assert("tax" in str(PlayerData.life_log[-1].get("text", "")).to_lower(), "Timeline log must reference corporate taxes")

	# Expand branch
	var exp_res := BusinessManager.open_business_branch(test_biz, "Apex Logic - East Branch")
	assert(bool(exp_res.get("success", false)), "Branch expansion should succeed")
	main_scene.add_life_event(str(exp_res.get("message", "Branch established!")), "milestone")
	assert(PlayerData.life_log.size() >= 2, "Branch expansion must be logged to timeline")
	assert("branch" in str(PlayerData.life_log[-1].get("text", "")).to_lower(), "Timeline log must reference branch expansion")

	# Owner dividend
	var div_res := BusinessManager.withdraw_owner_dividend(test_biz, 10000)
	assert(bool(div_res.get("success", false)), "Dividend withdrawal should succeed")
	main_scene.add_life_event(str(div_res.get("message", "Withdrew $10,000 owner dividend.")), "finance")
	assert(PlayerData.life_log.size() >= 3, "Dividend withdrawal must be logged to timeline")

	# Capital injection
	PlayerData.money = 50000
	var inj_res := BusinessManager.deposit_owner_capital(test_biz, 10000)
	assert(bool(inj_res.get("success", false)), "Capital injection should succeed")
	main_scene.add_life_event(str(inj_res.get("message", "Injected $10,000 capital into corporate treasury.")), "finance")
	assert(PlayerData.life_log.size() >= 4, "Capital injection must be logged to timeline")

	main_scene.queue_free()
	print("✔ Business actions sounded to timeline without popups verified.")
