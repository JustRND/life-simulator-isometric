extends Node

const MortgageManager = preload("res://scripts/economy/mortgage_manager.gd")
const RentalManager = preload("res://scripts/economy/rental_manager.gd")
const AssetCatalog = preload("res://scripts/economy/asset_catalog.gd")

func _ready() -> void:
	print("==================================================")
	print("--- Running Test Mortgage, Rental & Housing System ---")
	print("==================================================")
	run_all_tests()
	print("==================================================")
	print("--- ALL MORTGAGE & RENTAL TESTS PASSED! ---")
	print("==================================================")
	get_tree().quit()

func run_all_tests() -> void:
	PlayerData.reset_player()

	test_housing_prices_increased()
	test_property_maintenance_and_depreciation()
	test_rental_system_and_separation_from_owned_assets()
	test_mortgage_calculations_and_options()
	test_mortgage_lifecycle_and_years_left()
	test_selling_property_with_mortgage()
	test_save_load_persistence()
	test_ui_scene_elements()

func test_housing_prices_increased() -> void:
	print("\n[TEST] 1. Housing Prices Scaled Up")
	var starter: Dictionary = AssetCatalog.get_item("prop_capsule")
	assert(not starter.is_empty(), "Starter property prop_capsule must exist")
	var starter_price: int = int(starter.get("price", 0))
	assert(starter_price >= 200000, "Starter property price should be increased (>= $200,000, got: %d)" % starter_price)
	
	var luxury_penthouse: Dictionary = AssetCatalog.get_item("prop_penthouse")
	assert(not luxury_penthouse.is_empty(), "prop_penthouse must exist")
	var penthouse_price: int = int(luxury_penthouse.get("price", 0))
	assert(penthouse_price >= 3500000, "Penthouse price should be >= $3,500,000, got: %d" % penthouse_price)

	var cyber_mansion: Dictionary = AssetCatalog.get_item("prop_cyber_mansion")
	assert(not cyber_mansion.is_empty(), "prop_cyber_mansion must exist")
	var mansion_price: int = int(cyber_mansion.get("price", 0))
	assert(mansion_price >= 40000000, "Cyber mansion price should be scaled up (>= $40,000,000, got: %d)" % mansion_price)

	var chateau: Dictionary = AssetCatalog.get_item("prop_chateau")
	assert(not chateau.is_empty(), "prop_chateau must exist")
	var chateau_price: int = int(chateau.get("price", 0))
	assert(chateau_price >= 60000000, "Chateau price should be scaled up (>= $60,000,000, got: %d)" % chateau_price)
	print("  PASS: Housing prices successfully increased and verified.")

func test_property_maintenance_and_depreciation() -> void:
	print("\n[TEST] 2. Property Maintenance Cost (2%) and Depreciation (2.5%/yr)")
	PlayerData.reset_player()
	PlayerData.age = 25
	PlayerData.money = 500000
	PlayerData.bank_savings = 500000

	# Ensure single property
	PlayerData.owned_assets.clear()
	var prop := AssetCatalog.create_asset_instance("prop_house")
	var initial_val: int = int(prop.get("current_value", 0))
	PlayerData.owned_assets.append(prop)

	# Verify maintenance is 2%
	var expected_upkeep: int = int(round(float(initial_val) * 0.02))
	var funds_before = PlayerData.money + PlayerData.bank_savings

	# Process 1 year
	var logs = AssetCatalog.process_yearly_assets(PlayerData)
	var funds_after = PlayerData.money + PlayerData.bank_savings
	var actual_upkeep_paid = funds_before - funds_after

	assert(actual_upkeep_paid == expected_upkeep, "Maintenance cost must be exactly 2%% of asset value. Expected %d, got %d" % [expected_upkeep, actual_upkeep_paid])
	var cur_val_after: int = int(prop.get("current_value", 0))
	assert(cur_val_after < initial_val, "Property must depreciate over years. Initial: %d, New: %d" % [initial_val, cur_val_after])

	var expected_depreciated: int = int(round(float(initial_val) * (1.0 - 0.025)))
	assert(cur_val_after == expected_depreciated, "Property value after 1 yr must depreciate by 2.5%%. Expected %d, got %d" % [expected_depreciated, cur_val_after])
	print("  PASS: Maintenance cost percentage (2%%) and depreciation (2.5%%) verified.")

func test_rental_system_and_separation_from_owned_assets() -> void:
	print("\n[TEST] 3. Rental System - Renting Does NOT Equal Owning")
	PlayerData.reset_player()
	PlayerData.age = 22
	PlayerData.money = 25000
	PlayerData.bank_savings = 10000

	# Clear owned assets
	PlayerData.owned_assets.clear()
	assert(PlayerData.owned_assets.size() == 0, "Owned assets should be empty for this test")
	var initial_net_worth = PlayerData.get_net_worth()

	# Sign a rental lease
	var rent_res = RentalManager.sign_lease(PlayerData, "rent_micro_studio")
	assert(rent_res.get("success"), "Signing rental lease should succeed: %s" % rent_res.get("message"))
	assert(PlayerData.has_rented_property(), "Player should have rented property")
	assert(RentalManager.has_active_lease(PlayerData), "RentalManager should confirm active lease")

	# Critical requirement: Renting does NOT equal owning!
	assert(PlayerData.owned_assets.size() == 0, "Rented property must NEVER appear in owned_assets!")
	for asset in PlayerData.owned_assets:
		assert(asset.get("id") != "rent_micro_studio", "Rented property must not be in owned_assets")

	# Rental must NOT inflate net worth
	assert(PlayerData.get_net_worth() <= initial_net_worth, "Rented property must NEVER be counted in player net worth!")

	# Annual rent processing
	var funds_before = PlayerData.money + PlayerData.bank_savings
	var lease = PlayerData.rented_property
	var annual_rent = int(lease.get("annual_rent", 0))
	var rent_logs = RentalManager.process_yearly_rent(PlayerData)
	var funds_after = PlayerData.money + PlayerData.bank_savings
	assert(funds_before - funds_after == annual_rent, "Annual rent must be debited during age-up")

	# Terminate lease
	var term_res = RentalManager.terminate_lease(PlayerData)
	assert(term_res.get("success"), "Terminating lease should succeed")
	assert(not PlayerData.has_rented_property(), "Player should have no rented property after termination")
	print("  PASS: Rental logic verified; completely isolated from owned assets.")

func test_mortgage_calculations_and_options() -> void:
	print("\n[TEST] 4. Mortgage Options & Calculations (10, 15, 20, 30 Years)")
	var house_price = 500000

	for term_def in MortgageManager.MORTGAGE_TERMS:
		var term: int = int(term_def["years"])
		var apr: float = float(term_def["apr"])
		var plan = MortgageManager.calculate_mortgage_plan(house_price, term, apr)
		
		assert(plan.has("down_payment"), "Plan must have down_payment")
		assert(plan.has("principal"), "Plan must have principal")
		assert(plan.has("annual_payment"), "Plan must have annual_payment")
		assert(plan.has("annual_principal"), "Plan must have annual_principal")
		assert(plan.has("annual_interest"), "Plan must have annual_interest")
		assert(plan.has("apr"), "Plan must have apr")
		assert(plan.has("term_years"), "Plan must have term_years")

		assert(plan["down_payment"] == int(round(house_price * 0.10)), "Down payment must be 10%%")
		assert(plan["principal"] == house_price - plan["down_payment"], "Principal must be 90%%")
		assert(plan["annual_principal"] > 0, "Annual principal expense must be > 0")
		assert(plan["annual_interest"] > 0, "Annual interest expense must be > 0")
		assert(plan["annual_payment"] == plan["annual_principal"] + plan["annual_interest"], "Annual payment = principal + interest")

	print("  PASS: Mortgage terms 10, 15, 20, 30 verified with interest rate, principal expense & interest expense.")

func test_mortgage_lifecycle_and_years_left() -> void:
	print("\n[TEST] 5. Mortgage Lifecycle, Years Left Counter & Age-up Payments")
	PlayerData.reset_player()
	PlayerData.age = 28
	PlayerData.money = 200000
	PlayerData.bank_savings = 100000
	PlayerData.owned_assets.clear()
	PlayerData.mortgages.clear()

	var cat_item: Dictionary = AssetCatalog.get_item("prop_condo")
	var price: int = int(cat_item.get("price", 0))

	# Apply for 15-year mortgage
	var apply_res = MortgageManager.apply_for_mortgage(PlayerData, "prop_condo", 15, 0.050)
	assert(apply_res.get("success"), "Mortgage application should succeed: %s" % apply_res.get("message"))
	assert(PlayerData.mortgages.size() == 1, "Player should have 1 active mortgage")
	assert(PlayerData.owned_assets.size() == 1, "Player should own 1 asset from mortgage")

	var mortgage: Dictionary = PlayerData.mortgages[0]
	assert(mortgage["term_years"] == 15, "Term should be 15")
	assert(mortgage["years_left"] == 15, "Years left should start at 15")
	assert(mortgage["remaining_principal"] > 0, "Remaining principal should be > 0")

	# Total debt check
	assert(PlayerData.get_total_debt() >= mortgage["remaining_principal"], "Total debt should include mortgage principal")

	# Age up 1 year
	var funds_before = PlayerData.money + PlayerData.bank_savings
	var mort_logs = MortgageManager.process_yearly_mortgages(PlayerData)
	var funds_after = PlayerData.money + PlayerData.bank_savings
	assert(funds_after < funds_before, "Mortgage payment should be debited on age-up")

	var updated_mortgage: Dictionary = PlayerData.mortgages[0]
	assert(updated_mortgage["years_left"] == 14, "Years left counter must decrement to 14, got %d" % updated_mortgage["years_left"])
	assert(updated_mortgage["remaining_principal"] < mortgage["original_principal"], "Remaining principal must decrease")
	print("  PASS: Mortgage years left counter and annual amortization verified.")

func test_selling_property_with_mortgage() -> void:
	print("\n[TEST] 6. Selling Property with Active Mortgage Settles Debt First")
	assert(PlayerData.mortgages.size() == 1, "Should have 1 active mortgage from previous test")
	var prop: Dictionary = PlayerData.owned_assets[0]
	var instance_id: String = str(prop["instance_id"])
	var mortgage_before: Dictionary = PlayerData.mortgages[0]
	var remaining_debt: int = int(mortgage_before["remaining_principal"])
	var money_before: int = PlayerData.money

	var sell_res = AssetCatalog.sell_asset(PlayerData, instance_id)
	assert(sell_res.get("success"), "Selling property with mortgage should succeed")
	assert(PlayerData.mortgages.size() == 0, "Mortgage should be fully settled upon property sale")
	assert(not PlayerData.has_active_mortgage(), "Player should have no active mortgages")

	var cash_proceeds: int = int(sell_res.get("cash_proceeds", 0))
	var sale_price: int = int(sell_res.get("sale_price", 0))
	assert(cash_proceeds == sale_price - remaining_debt, "Cash proceeds must equal sale price minus mortgage debt")
	assert(PlayerData.money == money_before + cash_proceeds, "Cash must increase by cash proceeds")
	print("  PASS: Property sale settles mortgage debt before releasing equity.")

func test_save_load_persistence() -> void:
	print("\n[TEST] 7. Save / Load Persistence of Mortgages & Rented Property")
	PlayerData.reset_player()
	PlayerData.age = 30
	PlayerData.money = 300000
	PlayerData.bank_savings = 50000

	# Add rental and mortgage
	RentalManager.sign_lease(PlayerData, "rent_suburban_flat")
	MortgageManager.apply_for_mortgage(PlayerData, "prop_condo", 20, 0.055)

	var saved_mort_count = PlayerData.mortgages.size()
	assert(saved_mort_count == 1, "Should have 1 mortgage for save test")
	var saved_mort_years_left = PlayerData.mortgages[0]["years_left"]
	var saved_rent_id = PlayerData.rented_property.get("id")

	# Capture save data via SaveManager
	var save_dict = SaveManager.capture_data()
	assert(save_dict.has("mortgages"), "SaveManager must capture mortgages")
	assert(save_dict.has("rented_property"), "SaveManager must capture rented_property")

	# Reset player and restore
	PlayerData.reset_player()
	assert(PlayerData.mortgages.size() == 0, "Mortgages reset")
	assert(PlayerData.rented_property.is_empty(), "Rental reset")

	var restore_ok = SaveManager.apply_data(save_dict)
	assert(restore_ok, "apply_data should return true")
	assert(PlayerData.mortgages.size() == saved_mort_count, "Mortgages restored")
	assert(PlayerData.mortgages[0]["years_left"] == saved_mort_years_left, "Mortgage years left restored")
	assert(PlayerData.rented_property.get("id") == saved_rent_id, "Rented property restored")
	print("  PASS: Save/Load persistence verified.")

func test_ui_scene_elements() -> void:
	print("\n[TEST] 8. UI Scene Elements (Alpha Version, Rent Button, Activities, Mortgage Panel)")
	var main_scene_res = load("res://scenes/main/main_screen.tscn")
	assert(main_scene_res != null, "main_screen.tscn should load successfully")
	var main_scene = main_scene_res.instantiate()
	add_child(main_scene)

	# Verify Alpha v0.1.2 badge
	var alpha_label = main_scene.get_node_or_null("TopBar/Row/AlphaVersionMargin/AlphaBadge/AlphaBadgeMargin/AlphaVersionLabel")
	assert(alpha_label != null, "AlphaVersionLabel must exist in TopBar")
	assert("0.1.2" in alpha_label.text, "Alpha version badge must show 0.1.2, got: %s" % alpha_label.text)

	# Verify Rent a House button in Activities tab
	var rent_btn = main_scene.get_node_or_null("ActivitiesPanel/ActMargin/ActContent/ActScroll/ActList/RentHouseActItem")
	assert(rent_btn != null, "RentHouseActItem button must exist in ActivitiesPanel")
	assert("RENT A HOUSE" in rent_btn.text.to_upper(), "Rent button text should contain 'RENT A HOUSE'")

	# Test opening Mortgage Panel
	var prop_item: Dictionary = AssetCatalog.get_item("prop_house")
	assert(not prop_item.is_empty(), "prop_house must exist")
	
	# Open mortgage panel
	main_scene._open_mortgage_panel(prop_item, null)
	
	# Find mortgage modal overlay
	var mortgage_modal = null
	for child in main_scene.get_children():
		if child is Control and child.get_meta("is_mortgage_panel", false):
			mortgage_modal = child
			break
	
	assert(mortgage_modal != null, "Mortgage modal should be created and added to scene")
	
	# Verify "BACK TO PROPERTIES" button on top left corner
	var back_btn: Button = null
	for btn in mortgage_modal.find_children("*", "Button", true, false):
		if "BACK TO PROPERTIES" in btn.text.to_upper():
			back_btn = btn
			break
	
	assert(back_btn != null, "Top-left 'BACK TO PROPERTIES' button must exist in Mortgage Panel")
	print("  Found 'BACK TO PROPERTIES' button: %s" % back_btn.text)

	# Verify 4 mortgage term options exist (10, 15, 20, 30 years)
	var term_count: int = 0
	for label in mortgage_modal.find_children("*", "Label", true, false):
		if "YEAR FIXED" in label.text.to_upper():
			term_count += 1
	assert(term_count == 4, "Mortgage panel must display all 4 mortgage terms (10, 15, 20, 30), found %d" % term_count)
	print("  Found all %d mortgage term options in panel." % term_count)

	# Clean up modal
	mortgage_modal.queue_free()
	main_scene.queue_free()
	print("  PASS: UI Scene elements & Mortgage Panel verified.")
