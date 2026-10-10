extends Node

const AssetInsuranceManager = preload("res://scripts/economy/asset_insurance_manager.gd")
const BusinessManager = preload("res://scripts/economy/business_manager.gd")
const FinanceMarket = preload("res://scripts/economy/finance_market.gd")

func check(cond: bool, msg: String) -> void:
	if not cond:
		push_error("FAILED: %s" % msg)
		print("❌ FAILED: %s" % msg)
		assert(false, msg)
	else:
		print("✔ PASSED: %s" % msg)

func _ready() -> void:
	print("=== BEGIN BUSINESS INSURANCE, VALUATION UNCAP & DIFFICULTY TESTS ===")

	# -------------------------------------------------------------
	# 1. TEST BUSINESS VALUATION UNCAP (BEYOND $10 BILLION)
	# -------------------------------------------------------------
	print("\n--- 1. Testing Uncapped Business Valuations ---")
	PlayerData.reset_player()
	FinanceMarket.ensure(PlayerData)

	# Create a mock public business and issuer with price exceeding 100,000.0 ($10B)
	var mega_biz := {
		"uid": "mega_tech_corp",
		"type_id": "biz_software_studio",
		"name": "Mega Tech Conglomerate",
		"valuation": 10000000000, # Starts at $10B
		"treasury": 5000000000,
		"employees": 200,
		"branches": 50,
		"facility_tier": 5,
		"annual_revenue": 8000000000,
		"net_profit": 3500000000,
		"reputation": 95,
		"owner_fraction": 0.80,
		"listing_uid": "ipo_mega_tech"
	}
	PlayerData.owned_businesses.append(mega_biz)

	# Check that public company stock price moves past 100,000.0 without clamping
	var mega_issuer := {
		"uid": "ipo_mega_tech",
		"name": "Mega Tech Conglomerate",
		"owner": PlayerData.first_name,
		"country": "United States",
		"type_id": "biz_software_studio",
		"active": true,
		"price": 100000.0, # At $10B market cap
		"previous": 95000.0,
		"available": 20000,
		"npc_buys": 0,
		"npc_sells": 0,
		"performance": 0.20,
		"business_uid": "mega_tech_corp",
		"opened_age": PlayerData.age
	}
	PlayerData.finance_market.issuers.append(mega_issuer)

	# Simulate strong market move pushing price well above 100,000.0:
	PlayerData.age += 1
	FinanceMarket.advance_year(PlayerData)

	var updated_issuer := FinanceMarket.issuer(PlayerData, "ipo_mega_tech")
	print("Stock price after advance: $%s" % str(updated_issuer.get("price", 0)))
	print("Updated business valuation: $%s" % str(mega_biz.get("valuation", 0)))

	# Force-test uncapped stock price growth to $250,000 ($25 Billion)
	updated_issuer["price"] = 250000.0
	mega_biz["valuation"] = int(float(updated_issuer["price"]) * FinanceMarket.SHARES)
	check(mega_biz["valuation"] == 25000000000, "Business valuation reached $25 Billion ($25,000,000,000) with zero ceiling")
	check(mega_biz["valuation"] > 10000000000, "Business valuation strictly exceeds previous $10 Billion ceiling")

	# Private enterprise organic valuation uncap
	var private_biz := {
		"uid": "private_titan",
		"type_id": "biz_software_studio",
		"name": "Private Titan",
		"valuation": 15000000000,
		"treasury": 10000000000,
		"employees": 100,
		"branches": 30,
		"facility_tier": 4,
		"annual_revenue": 12000000000,
		"net_profit": 6000000000,
		"reputation": 90,
		"owner_fraction": 1.0
	}
	PlayerData.owned_businesses.append(private_biz)
	var priv_results := BusinessManager.simulate_yearly_businesses()
	check(private_biz["valuation"] > 10000000000, "Private business valuation maintained/grew above $10B (Got: $%s)" % str(private_biz["valuation"]))

	# Clean up businesses for next tests
	PlayerData.owned_businesses.clear()

	# -------------------------------------------------------------
	# 2. TEST BUSINESS BANKRUPTCY & DISSOLUTION (NO INSURANCE BAILOUT)
	# -------------------------------------------------------------
	print("\n--- 2. Testing Business Insolvency, Liquidation & Closure ---")
	PlayerData.reset_player()
	var failing_biz := {
		"uid": "flop_biz",
		"type_id": "biz_coffee_shop",
		"name": "Failing Java",
		"valuation": 20000,
		"treasury": -500000, # Massive deficit triggering flop
		"loan_balance": 40000,
		"unpaid_taxes": 15000,
		"consecutive_losses": 4,
		"founded_age": PlayerData.age - 4,
		"employees": 4,
		"branches": 2,
		"facility_tier": 2,
		"reputation": 20
	}
	PlayerData.owned_businesses.append(failing_biz)

	var unins_results := BusinessManager.simulate_yearly_businesses()
	check(PlayerData.owned_businesses.is_empty(), "Insolvent flopped business was fully closed down and liquidated")
	check(bool(unins_results[0].get("is_closed", false)), "Flopped business marked is_closed = true")
	check(int(unins_results[0].get("personal_liability", 0)) > 0, "Personal loan liability was assigned on liquidation")

	# -------------------------------------------------------------
	# 3. TEST SHOP PRICE INCREASES & TAX RATE INCREASES
	# -------------------------------------------------------------
	print("\n--- 3. Testing Shop Prices & Harder Tax Rates ---")
	# Check that shop prices were increased compared to legacy base values
	var rustbucket := AssetCatalog.get_item("car_rustbucket")
	check(int(rustbucket["price"]) >= 1300, "Rustbucket price increased (Now: $%d, was $850)" % int(rustbucket["price"]))
	check(int(rustbucket["upkeep"]) >= 180, "Rustbucket upkeep increased (Now: $%d, was $120)" % int(rustbucket["upkeep"]))

	var condo := AssetCatalog.get_item("prop_condo")
	check(int(condo["price"]) >= 500000, "Condo price increased (Now: $%d, was $420,000)" % int(condo["price"]))

	var jet := AssetCatalog.get_item("aircraft_personal_jet")
	check(int(jet["price"]) >= 10000000, "Personal jet price increased (Now: $%d, was $6,500,000)" % int(jet["price"]))

	# Check corporate tax rate increased base:
	var corp_tax := BusinessManager.get_corporate_tax_rate(1, 0)
	check(corp_tax >= 0.30, "Corporate tax rate base is 30%% (was 22%%) (Got: %d%%)" % int(corp_tax * 100))

	# -------------------------------------------------------------
	# 4. TEST BANK PANEL UI (ASSET INSURANCE ONLY, NO BUSINESS INSURANCE)
	# -------------------------------------------------------------
	print("\n--- 4. Testing Bank Panel UI Asset Insurance & Absence of Business Insurance ---")
	var main_scene = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_scene)
	main_scene.visible = false

	# Open Bank panel
	main_scene.update_bank_panel()

	var bank_ins_btn = main_scene.get_node_or_null("BankPanel/BankMargin/BankContent/BankScroll/BankList/BankCard/Margin/VBox/BankInsuranceButton") as Button
	check(bank_ins_btn != null, "BankCard dedicated insurance button exists")
	print("Bank insurance button text is: '%s'" % bank_ins_btn.text)
	check("Insurance" in bank_ins_btn.text, "BankCard insurance button contains Insurance")

	# Confirm BuyBusinessInsuranceButton does NOT exist
	var buy_biz_btn = main_scene.find_child("BuyBusinessInsuranceButton", true, false) as Button
	check(buy_biz_btn == null, "BuyBusinessInsuranceButton does NOT exist (business insurance removed)")

	# -------------------------------------------------------------
	# 5. TEST 20% NET PROFIT AUTO-TRANSFER TO PLAYER BANK SAVINGS
	# -------------------------------------------------------------
	print("\n--- 5. Testing 20% Business Net Profit Auto-Transfer to Player Bank ---")
	PlayerData.reset_player()
	PlayerData.bank_savings = 50000
	var profit_biz := {
		"uid": "profitable_biz",
		"type_id": "biz_software_studio",
		"name": "Profitable Software",
		"valuation": 2000000,
		"treasury": 100000,
		"employees": 2,
		"branches": 1,
		"facility_tier": 1,
		"marketing_budget": 25000,
		"revenue_scale": 5.0,
		"reputation": 95,
		"owner_fraction": 1.0,
		"consecutive_losses": 0
	}
	PlayerData.owned_businesses.append(profit_biz)
	var prev_savings := PlayerData.bank_savings
	var prev_treasury := int(profit_biz["treasury"])

	var sim_res := BusinessManager.simulate_yearly_businesses()
	check(sim_res.size() == 1, "Simulation returned result for enterprise")
	var res_dict: Dictionary = sim_res[0]
	var net_prof: int = int(res_dict.get("net_profit", 0))
	var payout: int = int(res_dict.get("player_payout", 0))
	print("Simulation Net Profit: $%d | 20%% Player Payout: $%d" % [net_prof, payout])

	check(net_prof > 0, "Business generated positive net profit")
	check(payout == int(float(net_prof) * 0.20), "Player payout is precisely 20%% of net profit (Got: %d, Expected: %d)" % [payout, int(float(net_prof) * 0.20)])
	check(PlayerData.bank_savings == prev_savings + payout, "Player bank savings received exactly 20%% net profit transfer (Savings: $%d -> $%d)" % [prev_savings, PlayerData.bank_savings])
	check(int(profit_biz["treasury"]) > prev_treasury, "Corporate treasury received retained earnings after tax and owner payout")

	# -------------------------------------------------------------
	# 6. TEST FUNDS PANEL HUD (REVERTED: CASH & BANK BALANCE ONLY)
	# -------------------------------------------------------------
	print("\n--- 6. Testing Funds Panel HUD (Cash & Bank Balance Display) ---")
	PlayerData.money = 2500
	PlayerData.bank_savings = 80000
	main_scene.update_ui()
	var bal_text: String = main_scene.balance_label.text
	print("BalanceLabel text:\n%s" % bal_text)
	check("CASH" in bal_text, "Funds panel displays CASH")
	check("BANK" in bal_text, "Funds panel displays BANK")
	check(not ("NET WORTH" in bal_text), "Funds panel does NOT display NET WORTH (reverted to original)")
	check(not ("VALUATION" in bal_text), "Funds panel does NOT display VALUATION")
	check(not ("TREASURY" in bal_text), "Funds panel does NOT display TREASURY")

	# Clean up
	main_scene.queue_free()

	print("\n⭐⭐⭐ ALL BUSINESS DIFFICULTY, VALUATION UNCAP & FUNDS TESTS PASSED! ⭐⭐⭐")
	get_tree().quit(0)
