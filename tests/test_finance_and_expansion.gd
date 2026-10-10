extends Node

const CryptoMarket = preload("res://scripts/economy/crypto_market.gd")

func _ready() -> void:
	print("--- BEGINNING COMPREHENSIVE VERIFICATION TEST ---")
	
	# 1. Test BusinessManager expansion
	print("\n[TEST 1] Verifying BusinessManager expansion...")
	var categories: Array = BusinessManager.get_categories()
	assert(categories.size() == 7, "Expected 7 categories, got %d" % categories.size())
	for cat in categories:
		var cat_id: String = str(cat.get("id", ""))
		var biz_in_cat: Array = BusinessManager.get_businesses_in_category(cat_id)
		print("Category '%s' has %d businesses." % [cat_id, biz_in_cat.size()])
		assert(biz_in_cat.size() >= 7, "Category %s has fewer than 7 businesses!" % cat_id)
	var all_biz: Array = BusinessManager.get_all_business_types()
	print("Total business varieties: %d" % all_biz.size())
	assert(all_biz.size() >= 47, "Expected at least 47 total businesses, got %d" % all_biz.size())
	
	# 2. Test LicenseManager expansion
	print("\n[TEST 2] Verifying LicenseManager expansion...")
	var test_licenses := [
		"license_distillery_master", "license_commercial_baking",
		"license_commercial_cdl", "license_helicopter_commercial",
		"license_tactical_security", "license_armorer",
		"license_general_contractor", "license_veterinary",
		"license_clinical_pharmacist", "license_finra_series7",
		"license_patent_bar", "license_nuclear_operator",
		"license_physical_therapist"
	]
	for lic_id in test_licenses:
		var lic: Dictionary = LicenseManager.get_license_by_id(lic_id)
		assert(not lic.is_empty(), "License %s not found!" % lic_id)
		print("License '%s' verified: %s" % [lic_id, lic.get("name", "")])
		
	# 3. Test EducationCatalog expansion
	print("\n[TEST 3] Verifying EducationCatalog expansion...")
	var test_majors := [
		"veterinary", "pharmacy", "civil_engineering",
		"game_design", "nuclear_physics", "kinesiology"
	]
	for m in test_majors:
		var inst: Dictionary = EducationCatalog.get_institution_by_major(m)
		assert(not inst.is_empty(), "Institution for major %s not found!" % m)
		var display_name: String = EducationCatalog.get_major_display_name(m)
		print("Major '%s' verified: %s (School: %s)" % [m, display_name, inst.get("name", "")])
		
	# 4. Test Jobs & Career Paths expansion
	print("\n[TEST 4] Verifying Jobs & Career Paths expansion...")
	var jobs_catalog: Array = JobManager.get_all_jobs()
	print("Total jobs in catalog: %d" % jobs_catalog.size())
	assert(jobs_catalog.size() >= 105, "Expected at least 105 total jobs, got %d" % jobs_catalog.size())
	for cat in JobManager.get_categories():
		var cat_id: String = str(cat.get("id", ""))
		var jobs_in_cat: Array = JobManager.get_jobs_in_category(cat_id)
		print("Job category '%s' has %d jobs." % [cat_id, jobs_in_cat.size()])
		assert(jobs_in_cat.size() >= 8, "Job category %s has fewer than 8 jobs!" % cat_id)
	
	# Verify career paths for all jobs
	var career_file := FileAccess.open("res://data/economy/career_paths.json", FileAccess.READ)
	assert(career_file != null, "Could not open career_paths.json")
	var career_json = JSON.parse_string(career_file.get_as_text())
	career_file.close()
	assert(typeof(career_json) == TYPE_DICTIONARY, "career_paths.json is not a Dictionary")
	for j in jobs_catalog:
		var jid: String = str(j.get("id", ""))
		assert(career_json.has(jid), "Missing career path for job %s!" % jid)
	print("All %d jobs have verified career paths." % jobs_catalog.size())
	
	# 5. Test CryptoMarket engine & PlayerData integration
	print("\n[TEST 5] Verifying CryptoMarket engine & PlayerData integration...")
	PlayerData.reset_player()
	PlayerData.age = 25
	PlayerData.money = 100000
	PlayerData.bank_savings = 50000
	CryptoMarket.ensure(PlayerData)
	
	var initial_port_val: int = CryptoMarket.portfolio_value(PlayerData)
	assert(initial_port_val == 0, "Initial crypto portfolio value should be 0")
	
	# Buy Bitcoin
	var buy_res: Dictionary = CryptoMarket.buy(PlayerData, "btc", 5000.0)
	print("Buy BTC result: %s" % buy_res.get("message", ""))
	assert(bool(buy_res.get("success", false)), "Buy BTC failed!")
	assert(PlayerData.crypto_wallet.has("coins"), "Wallet missing coins!")
	var holding: Dictionary = CryptoMarket.get_holding(PlayerData, "btc")
	var btc_amount: float = float(holding.get("amount", 0.0))
	assert(btc_amount > 0.0, "BTC amount should be > 0")
	
	var port_val_after_buy: int = CryptoMarket.portfolio_value(PlayerData)
	print("Portfolio value after buying $5,000 BTC: $%d" % port_val_after_buy)
	assert(port_val_after_buy > 4900, "Portfolio value should be approx $4975 after 0.5% fee")
	
	# Check net worth incorporates crypto
	var personal_nw: int = PlayerData.get_personal_net_worth()
	print("Personal Net Worth with Crypto: $%d" % personal_nw)
	assert(personal_nw >= 149000, "Personal net worth must include crypto holdings")
	
	# Sell half Bitcoin
	var sell_res: Dictionary = CryptoMarket.sell(PlayerData, "btc", btc_amount * 0.5)
	print("Sell BTC result: %s" % sell_res.get("message", ""))
	assert(bool(sell_res.get("success", false)), "Sell BTC failed!")
	
	# Advance year in crypto market
	CryptoMarket.advance_year(PlayerData)
	var sentiment: Dictionary = CryptoMarket.get_sentiment_info(PlayerData)
	print("Crypto Market advanced to new year. Sentiment: %s" % sentiment.get("label", ""))
	
	# 6. Test Main Scene loading & UI node hierarchy
	print("\n[TEST 6] Verifying Main Scene and Finance UI wiring...")
	var main_scene: PackedScene = load("res://scenes/main/main_screen.tscn")
	assert(main_scene != null, "Failed to load main_screen.tscn")
	var root_node = main_scene.instantiate()
	add_child(root_node)
	
	var act_list = root_node.get_node("ActivitiesPanel/ActMargin/ActContent/ActScroll/ActList")
	assert(act_list != null, "ActList not found!")
	
	# Verify BankActItem was replaced by FinanceActItem
	var finance_act_item = act_list.get_node_or_null("FinanceActItem")
	assert(finance_act_item != null, "FinanceActItem not found in ActList!")
	print("FinanceActItem text: '%s'" % finance_act_item.text)
	assert(finance_act_item.text == "🏛️  Finance", "FinanceActItem text mismatch!")
	
	var old_bank_item = act_list.get_node_or_null("BankActItem")
	assert(old_bank_item == null, "Old loose BankActItem still exists in ActList!")
	
	var loose_finance_market_item = act_list.get_node_or_null("FinanceMarketItem")
	assert(loose_finance_market_item == null, "Loose FinanceMarketItem should NOT be in ActList!")
	
	# Test opening Finance Hub Modal
	root_node._on_finance_item_pressed()
	var hub_overlay = root_node.finance_hub_modal_overlay
	assert(hub_overlay != null and hub_overlay.visible, "Finance Hub modal overlay did not open!")
	print("Finance Hub modal successfully opened!")
	
	# Test opening Crypto Exchange Modal
	root_node._show_crypto_exchange_modal()
	var crypto_overlay = root_node.crypto_modal_overlay
	assert(crypto_overlay != null and crypto_overlay.visible, "Crypto Exchange modal overlay did not open!")
	print("Cryptocurrency Exchange modal successfully opened!")
	
	# Clean up
	root_node.queue_free()
	
	print("\n==============================================")
	print("ALL VERIFICATION TESTS COMPLETED SUCCESSFULLY!")
	print("==============================================")
	get_tree().quit(0)
