extends Node

const AssetInsuranceManager = preload("res://scripts/economy/asset_insurance_manager.gd")

func _ready() -> void:
	print("=== BEGIN ASSET INSURANCE SYSTEM VERIFICATION TEST ===")
	
	# -------------------------------------------------------------
	# 1. UNIT TEST: ASSET CLASSIFICATION & PRICING
	# -------------------------------------------------------------
	print("\n--- 1. Testing Asset Classification & Expensive Premiums ---")
	PlayerData.reset_player()
	PlayerData.money = 500000
	PlayerData.bank_savings = 500000

	assert(not AssetInsuranceManager.has_insurance(PlayerData, AssetInsuranceManager.CATEGORY_VEHICLE), "Should start uninsured for vehicles")
	assert(not AssetInsuranceManager.has_insurance(PlayerData, AssetInsuranceManager.CATEGORY_PROPERTY), "Should start uninsured for properties")

	# Base premium with zero assets
	var base_veh_prem: int = AssetInsuranceManager.get_annual_premium(PlayerData, AssetInsuranceManager.CATEGORY_VEHICLE)
	var base_prop_prem: int = AssetInsuranceManager.get_annual_premium(PlayerData, AssetInsuranceManager.CATEGORY_PROPERTY)
	assert(base_veh_prem == 2500, "Base vehicle premium should be $2,500 (got %d)" % base_veh_prem)
	assert(base_prop_prem == 6000, "Base property premium should be $6,000 (got %d)" % base_prop_prem)
	print("✔ Base premiums verified: Vehicle=$%d, Property=$%d" % [base_veh_prem, base_prop_prem])

	# Add assets and verify expensive scaling
	var test_car = {
		"instance_id": "test_car_1",
		"category": "cars",
		"name": "Apex GT Supercar",
		"purchase_price": 200000,
		"current_value": 200000
	}
	var test_mansion = {
		"instance_id": "test_prop_1",
		"category": "properties",
		"name": "Bel Air Modern Villa",
		"purchase_price": 2000000,
		"current_value": 2000000
	}
	PlayerData.owned_assets.append(test_car)
	PlayerData.owned_assets.append(test_mansion)

	var scaled_veh_prem: int = AssetInsuranceManager.get_annual_premium(PlayerData, AssetInsuranceManager.CATEGORY_VEHICLE)
	# 2500 + 200000 * 0.045 = 2500 + 9000 = 11500
	assert(scaled_veh_prem == 11500, "Scaled vehicle premium should be $11,500 (got %d)" % scaled_veh_prem)

	var scaled_prop_prem: int = AssetInsuranceManager.get_annual_premium(PlayerData, AssetInsuranceManager.CATEGORY_PROPERTY)
	# 6000 + 2000000 * 0.030 = 6000 + 60000 = 66000
	assert(scaled_prop_prem == 66000, "Scaled property premium should be $66,000 (got %d)" % scaled_prop_prem)
	print("✔ Expensive dynamic scaling verified: Vehicle ($200k car)=$%d/yr, Property ($2M villa)=$%d/yr" % [scaled_veh_prem, scaled_prop_prem])

	# -------------------------------------------------------------
	# 2. UNIT TEST: PURCHASE, YEARLY BILLING & CANCELLATION
	# -------------------------------------------------------------
	print("\n--- 2. Testing Purchase, Yearly Premium & Cancellation ---")
	var initial_funds: int = PlayerData.get_available_funds()
	var buy_res: Dictionary = AssetInsuranceManager.buy_insurance(PlayerData, AssetInsuranceManager.CATEGORY_VEHICLE)
	assert(buy_res["success"], "Vehicle insurance purchase should succeed")
	assert(AssetInsuranceManager.has_insurance(PlayerData, AssetInsuranceManager.CATEGORY_VEHICLE), "Vehicle insurance must be active")
	assert(PlayerData.get_available_funds() == initial_funds - 11500, "Funds must be debited by $11,500 premium")
	print("✔ Vehicle insurance purchase succeeded and initial premium debited.")

	# Attempt duplicate buy
	var dup_res: Dictionary = AssetInsuranceManager.buy_insurance(PlayerData, AssetInsuranceManager.CATEGORY_VEHICLE)
	assert(not dup_res["success"], "Duplicate insurance buy must fail")

	# Yearly billing simulation
	var yearly_funds_before: int = PlayerData.get_available_funds()
	var logs: Array[String] = AssetInsuranceManager.process_yearly_insurance(PlayerData)
	assert(logs.size() == 1, "Should log 1 annual insurance payment")
	assert(PlayerData.get_available_funds() == yearly_funds_before - 11500, "Annual renewal must debit $11,500")
	print("✔ Yearly insurance renewal debited successfully.")

	# Policy lapse when bankrupt
	PlayerData.money = 0
	PlayerData.bank_savings = 0
	var lapse_logs: Array[String] = AssetInsuranceManager.process_yearly_insurance(PlayerData)
	assert(not AssetInsuranceManager.has_insurance(PlayerData, AssetInsuranceManager.CATEGORY_VEHICLE), "Policy must lapse if unable to afford premium")
	print("✔ Policy lapse verified when funds are insufficient.")

	# Restore funds and cancel testing
	PlayerData.money = 100000
	PlayerData.bank_savings = 100000
	AssetInsuranceManager.buy_insurance(PlayerData, AssetInsuranceManager.CATEGORY_VEHICLE)
	var cancel_res: Dictionary = AssetInsuranceManager.cancel_insurance(PlayerData, AssetInsuranceManager.CATEGORY_VEHICLE)
	assert(cancel_res["success"], "Cancellation must succeed")
	assert(not AssetInsuranceManager.has_insurance(PlayerData, AssetInsuranceManager.CATEGORY_VEHICLE), "Must be uninsured after cancellation")
	print("✔ Cancellation verified.")

	# -------------------------------------------------------------
	# 3. UNIT TEST: DISASTER DESTRUCTION VS INSURANCE PROTECTION
	# -------------------------------------------------------------
	print("\n--- 3. Testing Disaster Protection & Asset Destruction ---")
	PlayerData.owned_assets.clear()
	PlayerData.owned_assets.append(test_car)
	PlayerData.owned_assets.append(test_mansion)

	# Case A: NO insurance -> Both assets destroyed!
	PlayerData.asset_insurance = {"vehicle": false, "property": false}
	var res_uninsured: Dictionary = AssetInsuranceManager.protect_assets_from_disaster(PlayerData, "Mega Earthquake")
	assert(res_uninsured["saved_assets"].is_empty(), "No assets saved when uninsured")
	assert(res_uninsured["lost_assets"].size() == 2, "Both assets must be destroyed when uninsured")
	assert(PlayerData.owned_assets.is_empty(), "PlayerData.owned_assets must be empty after uninsured disaster")
	print("✔ Uninsured disaster correctly destroyed all assets.")

	# Case B: Vehicle insurance only -> Vehicle saved, property destroyed!
	PlayerData.owned_assets.clear()
	PlayerData.owned_assets.append(test_car)
	PlayerData.owned_assets.append(test_mansion)
	PlayerData.asset_insurance = {"vehicle": true, "property": false}
	var res_partial: Dictionary = AssetInsuranceManager.protect_assets_from_disaster(PlayerData, "Mega Earthquake")
	assert(res_partial["saved_assets"].size() == 1 and res_partial["saved_assets"][0]["instance_id"] == "test_car_1", "Vehicle must be saved by vehicle insurance")
	assert(res_partial["lost_assets"].size() == 1 and res_partial["lost_assets"][0]["instance_id"] == "test_prop_1", "Property must be lost without property insurance")
	assert(PlayerData.owned_assets.size() == 1 and PlayerData.owned_assets[0]["instance_id"] == "test_car_1", "Only vehicle remains in owned_assets")
	print("✔ Partial insurance correctly preserved vehicle while destroying uninsured property.")

	# Case C: Both insured -> 100% saved!
	PlayerData.owned_assets.clear()
	PlayerData.owned_assets.append(test_car)
	PlayerData.owned_assets.append(test_mansion)
	PlayerData.asset_insurance = {"vehicle": true, "property": true}
	var res_full: Dictionary = AssetInsuranceManager.protect_assets_from_disaster(PlayerData, "Mega Earthquake")
	assert(res_full["saved_assets"].size() == 2, "Both assets saved with full insurance")
	assert(res_full["lost_assets"].is_empty(), "Zero assets lost with full insurance")
	assert(PlayerData.owned_assets.size() == 2, "All assets preserved in PlayerData.owned_assets")
	print("✔ Full insurance correctly protected 100% of assets from catastrophic destruction.")

	# -------------------------------------------------------------
	# 4. UI INTEGRATION TEST: BANK PANEL & INSURANCE CATEGORY
	# -------------------------------------------------------------
	print("\n--- 4. Testing Bank Panel UI & Insurance Underwriting Category ---")
	var main_scene = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_scene)
	await get_tree().process_frame
	await get_tree().process_frame

	PlayerData.age = 25
	PlayerData.bank_savings = 500000
	PlayerData.money = 500000
	PlayerData.asset_insurance = {"vehicle": false, "property": false}
	main_scene.show_tab("assets")
	await get_tree().process_frame
	main_scene._on_bank_button_pressed()
	await get_tree().process_frame
	await get_tree().process_frame

	# Check dedicated button in BankCard
	var bank_ins_btn = main_scene.get_node_or_null("BankPanel/BankMargin/BankContent/BankScroll/BankList/BankCard/Margin/VBox/BankInsuranceButton") as Button
	assert(bank_ins_btn != null, "Dedicated BankInsuranceButton must exist in BankCard")
	print("✔ Dedicated BankInsuranceButton found in BankCard: '%s'" % bank_ins_btn.text)

	# Check dedicated AssetInsuranceCard category in BankList
	var ins_card = main_scene.get_node_or_null("BankPanel/BankMargin/BankContent/BankScroll/BankList/AssetInsuranceCard") as PanelContainer
	assert(ins_card != null, "Dedicated AssetInsuranceCard must exist in BankList")
	print("✔ Dedicated AssetInsuranceCard category found in BankList.")

	# Check buy/cancel buttons inside AssetInsuranceCard
	var buy_veh_btn = ins_card.find_child("BuyVehicleInsuranceButton", true, false) as Button
	var buy_prop_btn = ins_card.find_child("BuyPropertyInsuranceButton", true, false) as Button
	assert(buy_veh_btn != null, "BuyVehicleInsuranceButton must exist")
	assert(buy_prop_btn != null, "BuyPropertyInsuranceButton must exist")
	print("✔ Buy buttons verified inside AssetInsuranceCard: Vehicle='%s', Property='%s'" % [buy_veh_btn.text, buy_prop_btn.text])

	# Test purchase through UI
	PlayerData.bank_savings = 500000
	PlayerData.asset_insurance = {"vehicle": false, "property": false}
	main_scene.update_bank_panel()
	await get_tree().process_frame
	
	main_scene._buy_asset_insurance(AssetInsuranceManager.CATEGORY_VEHICLE)
	await get_tree().process_frame
	assert(AssetInsuranceManager.has_insurance(PlayerData, AssetInsuranceManager.CATEGORY_VEHICLE), "UI buy must activate vehicle insurance")

	# Re-check updated card
	ins_card = main_scene.get_node_or_null("BankPanel/BankMargin/BankContent/BankScroll/BankList/AssetInsuranceCard") as PanelContainer
	assert(ins_card != null, "AssetInsuranceCard must exist after update")
	var cancel_veh_btn = ins_card.find_child("CancelVehicleInsuranceButton", true, false) as Button
	assert(cancel_veh_btn != null, "CancelVehicleInsuranceButton must replace Buy button after activation")
	print("✔ Reactive UI update verified: Buy button replaced with Cancel button.")

	# -------------------------------------------------------------
	# 5. PERSISTENCE TEST: SAVE & LOAD
	# -------------------------------------------------------------
	print("\n--- 5. Testing SaveManager Persistence ---")
	PlayerData.asset_insurance = {"vehicle": true, "property": true}
	SaveManager.save_game()

	PlayerData.asset_insurance = {"vehicle": false, "property": false}
	SaveManager.load_game()
	assert(PlayerData.asset_insurance.get("vehicle", false) == true, "Saved vehicle insurance must be true after load")
	assert(PlayerData.asset_insurance.get("property", false) == true, "Saved property insurance must be true after load")
	print("✔ Save & load persistence verified.")

	print("\n⭐⭐⭐ ALL ASSET INSURANCE SYSTEM TESTS PASSED PERFECTLY! ⭐⭐⭐")
	get_tree().quit(0)
