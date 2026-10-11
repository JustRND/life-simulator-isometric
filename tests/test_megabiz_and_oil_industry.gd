extends Node

func _ready() -> void:
	print("==================================================")
	print("STARTING MEGABIZ, OIL INDUSTRY & DATA CENTERS TEST")
	print("==================================================")

	# 1. VERIFY BUSINESS REGISTRATIONS IN BUSINESS_MANAGER
	print("\n[TEST 1] Verifying business definitions...")
	var req_biz_ids := [
		"biz_large_nuclear_reactor",
		"biz_oil_exploration",
		"biz_onshore_oil_field",
		"biz_oil_drilling_contractor",
		"biz_crude_oil_pipeline",
		"biz_lng_export_terminal",
		"biz_offshore_oil_rig",
		"biz_petrochemical_refinery",
		"biz_cloud_data_center",
		"biz_hyperscale_data_center"
	]
	for bid in req_biz_ids:
		var def := BusinessManager.get_business_type_by_id(bid)
		assert(not def.is_empty(), "Business %s not found!" % bid)
		print("  ✔ Found %s: %s (Category: %s, Startup: $%d, Rev: $%d-$%d, OpEx: $%d)" % [
			bid, def.get("name", ""), def.get("category", ""),
			int(def.get("startup_cost", 0)),
			int(def.get("base_revenue_min", 0)),
			int(def.get("base_revenue_max", 0)),
			int(def.get("base_opex", 0))
		])

	# Verify Nuclear Plant is in the billions
	var nuke := BusinessManager.get_business_type_by_id("biz_large_nuclear_reactor")
	assert(int(nuke["startup_cost"]) >= 9000000000, "Large Nuclear Plant startup cost must be >= $9 Billion!")
	assert(str(nuke["category"]) == "energy", "Nuclear plant must be in energy category!")

	# Verify Offshore Oil Rig and Refinery are in the billions
	var rig := BusinessManager.get_business_type_by_id("biz_offshore_oil_rig")
	assert(int(rig["startup_cost"]) >= 1000000000, "Offshore Rig startup cost must be >= $1 Billion!")
	assert(str(rig["category"]) == "oil_gas", "Offshore Rig must be in oil_gas category!")

	var ref := BusinessManager.get_business_type_by_id("biz_petrochemical_refinery")
	assert(int(ref["startup_cost"]) >= 3000000000, "Refinery startup cost must be >= $3 Billion!")
	assert(str(ref["category"]) == "oil_gas", "Refinery must be in oil_gas category!")

	# Verify Hyperscale Data Center is in the billions
	var dc := BusinessManager.get_business_type_by_id("biz_hyperscale_data_center")
	assert(int(dc["startup_cost"]) >= 1500000000, "Hyperscale Data Center startup cost must be >= $1.5 Billion!")
	assert(str(dc["category"]) == "tech_media", "Hyperscale Data Center must be in tech_media category!")

	# 2. VERIFY OIL_GAS CATEGORY & LICENSES
	print("\n[TEST 2] Verifying oil_gas category and licenses...")
	var oil_cat := BusinessManager.get_category_by_id("oil_gas")
	assert(not oil_cat.is_empty(), "oil_gas category must exist!")
	var oil_biz := BusinessManager.get_businesses_in_category("oil_gas")
	assert(oil_biz.size() == 7, "Expected exactly 7 oil_gas enterprises, got %d" % oil_biz.size())
	print("  ✔ oil_gas category verified with %d enterprises." % oil_biz.size())

	var petro_lic := LicenseManager.get_license_by_id("license_petroleum_drilling")
	assert(not petro_lic.is_empty(), "license_petroleum_drilling must exist!")
	var offshore_lic := LicenseManager.get_license_by_id("license_offshore_drilling")
	assert(not offshore_lic.is_empty(), "license_offshore_drilling must exist!")
	print("  ✔ Petroleum and offshore drilling licenses verified.")

	# 3. TEST INCORPORATION & LIFECYCLE OF LARGE NUCLEAR REACTOR ($9.5B)
	print("\n[TEST 3] Testing incorporation and annual cycle of Large Nuclear Reactor...")
	PlayerData.reset_player()
	PlayerData.age = 35
	PlayerData.grant_license("license_nuclear_operator")
	PlayerData.money = 15000000000 # $15 Billion
	PlayerData.bank_savings = 5000000000 # $5 Billion
	var start_wealth: int = PlayerData.money + PlayerData.bank_savings

	var nuke_res := BusinessManager.found_business("biz_large_nuclear_reactor", "Apex Horizon Nuclear Power")
	assert(bool(nuke_res.get("allowed", false)), "Failed to incorporate Large Nuclear Reactor: %s" % nuke_res.get("reason", ""))
	var nuke_biz: Dictionary = nuke_res.get("business", {})
	assert(nuke_biz.get("name") == "Apex Horizon Nuclear Power", "Incorrect business name!")
	assert(int(nuke_biz.get("treasury", 0)) == int(9500000000 * 0.20), "Treasury should be seeded with 20%% of startup cost!")
	assert(PlayerData.money + PlayerData.bank_savings == start_wealth - 9500000000, "Startup cost of $9.5B was not properly deducted!")
	print("  ✔ Large Nuclear Reactor successfully incorporated. Treasury seeded with $%d." % int(nuke_biz.get("treasury", 0)))

	# Process annual cycle
	var pre_bank: int = PlayerData.bank_savings
	var pre_treasury: int = int(nuke_biz.get("treasury", 0))
	BusinessManager.simulate_yearly_businesses()

	var post_rev: int = int(nuke_biz.get("annual_revenue", 0))
	var post_opex: int = int(nuke_biz.get("annual_opex", 0))
	var post_net: int = int(nuke_biz.get("net_profit", 0))
	var post_treasury: int = int(nuke_biz.get("treasury", 0))
	var post_bank: int = PlayerData.bank_savings

	print("  ✔ Nuclear Year 1: Revenue: $%d | OpEx: $%d | Net: $%d | Treasury: $%d | Player Bank: $%d" % [
		post_rev, post_opex, post_net, post_treasury, post_bank
	])
	assert(post_rev > 1000000000, "Nuclear revenue should be in the billions!")
	assert(post_opex > 500000000, "Nuclear opex should be hundreds of millions to billions!")
	if post_net > 0:
		assert(post_bank > pre_bank, "20% net profit distribution should have credited player bank account!")

	# 4. TEST INCORPORATION & LIFECYCLE OF DEEPWATER OFFSHORE OIL RIG ($1.5B)
	print("\n[TEST 4] Testing incorporation of Deepwater Offshore Oil Rig...")
	PlayerData.grant_license("license_offshore_drilling")
	var rig_res := BusinessManager.found_business("biz_offshore_oil_rig", "Pacific Titan Deepwater Rig")
	assert(bool(rig_res.get("allowed", false)), "Failed to incorporate Offshore Rig: %s" % rig_res.get("reason", ""))
	var rig_biz: Dictionary = rig_res.get("business", {})
	assert(int(rig_biz.get("treasury", 0)) == int(1500000000 * 0.20), "Offshore Rig treasury should be seeded with 20%!")
	print("  ✔ Deepwater Offshore Rig successfully incorporated.")

	# 5. TEST INCORPORATION & LIFECYCLE OF HYPERSCALE DATA CENTER ($1.85B)
	print("\n[TEST 5] Testing incorporation of Hyperscale Data Center Campus...")
	PlayerData.grant_license("license_cyber")
	var dc_res := BusinessManager.found_business("biz_hyperscale_data_center", "OmniNet Hyperscale AI Campus")
	assert(bool(dc_res.get("allowed", false)), "Failed to incorporate Hyperscale Data Center: %s" % dc_res.get("reason", ""))
	var dc_biz: Dictionary = dc_res.get("business", {})
	assert(int(dc_biz.get("treasury", 0)) == int(1850000000 * 0.20), "Data Center treasury should be seeded with 20%!")
	print("  ✔ Hyperscale Data Center successfully incorporated.")

	# 6. TEST CORPORATE TAX ON CONGLOMERATE SCALE
	print("\n[TEST 6] Testing progressive corporate taxes on 3 multi-billion enterprises...")
	assert(PlayerData.owned_businesses.size() == 3, "Expected 3 owned businesses, got %d" % PlayerData.owned_businesses.size())
	BusinessManager.simulate_yearly_businesses()

	for b in PlayerData.owned_businesses:
		var tax_info := TaxSystem.calculate_business_tax({"annual_revenue": b["annual_revenue"], "annual_opex": b["annual_opex"]}, PlayerData.owned_businesses.size())
		var net: int = int(b.get("net_profit", 0))
		if net > 0:
			var eff_rate: float = float(tax_info.get("effective_rate", 0.0))
			print("  ✔ %s: Net Profit: $%d | Effective Tax Rate: %.2f%% | Tax Due: $%d" % [
				b.get("name", ""), net, eff_rate * 100.0, int(tax_info.get("tax_due", 0))
			])
			assert(eff_rate >= 0.33, "Effective tax rate on $100M+ corporate profit with 3 businesses should be >= 33%!")

	# 7. TEST BRANCH EXPANSION AND COMMERCIAL LOAN ON MULTI-BILLION ENTERPRISES
	print("\n[TEST 7] Testing branch expansion and commercial loans...")
	var exp_cost: int = BusinessManager.get_branch_expansion_cost(nuke_biz)
	print("  Nuclear Branch #2 Expansion Cost: $%d" % exp_cost)
	assert(exp_cost > 10000000000, "Branch expansion for $9.5B nuclear station must be > $10 Billion!")

	# Provide adequate treasury to expand
	nuke_biz["treasury"] = exp_cost + 1000000
	var exp_res := BusinessManager.open_business_branch(nuke_biz, "Sector 7 Reactor Extension")
	assert(bool(exp_res.get("success", false)), "Nuclear branch expansion failed: %s" % exp_res.get("message", ""))
	assert(int(nuke_biz.get("branches", 1)) == 2, "Branch count should be 2!")
	print("  ✔ Successfully expanded Nuclear Power Station to Branch #2.")

	# Commercial loan test
	var loan_res := BusinessManager.take_business_loan(nuke_biz, 500000000) # $500M loan
	assert(bool(loan_res.get("success", false)), "Commercial loan failed: %s" % loan_res.get("message", ""))
	assert(int(nuke_biz.get("loan_balance", 0)) == 500000000, "Loan balance should be $500M!")
	print("  ✔ Successfully disbursed $500M commercial loan.")

	var repay_res := BusinessManager.repay_business_loan(nuke_biz, 200000000) # Repay $200M
	assert(bool(repay_res.get("success", false)), "Repay loan failed: %s" % repay_res.get("message", ""))
	assert(int(nuke_biz.get("loan_balance", 0)) == 300000000, "Remaining loan should be $300M!")
	print("  ✔ Successfully repaid $200M towards commercial loan.")

	print("\n==================================================")
	print("ALL MEGABIZ, OIL INDUSTRY & DATA CENTER TESTS PASSED!")
	print("==================================================")
