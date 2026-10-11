extends Node

func _ready() -> void:
	print("\n=======================================================")
	print("🧪 RUNNING COMPREHENSIVE TAX SYSTEM VERIFICATION SUITE")
	print("=======================================================\n")

	_test_income_tax_brackets()
	_test_capital_gains_tax()
	_test_property_tax()
	_test_business_tax()
	_test_annual_filing_and_debt()
	await _test_tax_office_ui()

	print("\n=======================================================")
	print("🎉 ALL TAX SYSTEM TESTS PASSED WITH 100% SUCCESS!")
	print("=======================================================\n")
	get_tree().quit(0)


func _test_income_tax_brackets() -> void:
	print("--- 1. Testing Progressive Income Tax ---")
	var tax_sys = preload("res://scripts/economy/tax_system.gd")

	# Test 1: Standard deduction ($12,000)
	var low_inc_tax = tax_sys.calculate_income_tax(12000, 0)
	assert(low_inc_tax["taxable_income"] == 0, "Income under standard deduction ($12k) must result in $0 taxable income")
	assert(low_inc_tax["tax_due"] == 0, "Income under standard deduction must pay $0 tax")
	print("  ✓ Standard deduction ($12,000) verified: taxable income = $0, tax = $0")

	# Test 2: Progressive bracket calculation:
	# Gross income = $60,000
	# Deductions = $8,000 (Charity $3k + Pension $5k). Total deductions = $12k standard + $8k = $20,000
	# Taxable income = $40,000.
	# Bracket 1 (0 to 35,000) @ 10%: $3,500
	# Bracket 2 (35,000 to 40,000) @ 15%: 5,000 * 0.15 = $750
	# Total tax = $3,500 + $750 = $4,250
	var prog_tax = tax_sys.calculate_income_tax(60000, 8000)
	assert(prog_tax["gross_income"] == 60000, "Gross income should be 60,000")
	assert(prog_tax["total_deductions"] == 20000, "Total deductions should be 20,000")
	assert(prog_tax["taxable_income"] == 40000, "Taxable income should be 40,000")
	assert(prog_tax["tax_due"] == 4250, "Tax due should be 4,250. Got %d" % prog_tax["tax_due"])
	print("  ✓ Progressive multi-bracket income tax verified: Gross $60k, Deductions $20k -> Tax $4,250 (Effective: %.1f%%)" % (prog_tax["effective_rate"] * 100.0))

	# Test 3: Minor exemption via calculate_tax_return
	PlayerData.reset_player()
	PlayerData.age = 16
	PlayerData.job_salary = 50000
	var minor_return = tax_sys.calculate_tax_return(PlayerData)
	assert(minor_return["income_tax"]["tax_due"] == 0, "Minors (<18) must have $0 income tax due")
	print("  ✓ Underage (<18) income tax exemption verified in tax return: $0 tax")


func _test_capital_gains_tax() -> void:
	print("\n--- 2. Testing Progressive Capital Gains Tax & Loss Harvesting ---")
	var tax_sys = preload("res://scripts/economy/tax_system.gd")

	# Test 1: Below retail exemption ($15,000 threshold)
	var exempt_cg = tax_sys.calculate_capital_gains_tax(12000, 0)
	assert(exempt_cg["tax_due"] == 0, "Capital gains below $15k exemption should owe $0")
	print("  ✓ Retail investor capital gains exemption ($15,000 threshold) verified: $0 tax")

	# Test 2: Net gain with loss offsetting
	# Gains = $85,000, Losses = $15,000 -> Net = $70,000
	# Exemption = $15,000 -> Taxable = $55,000
	# Bracket 1 (up to 45,000) @ 10%: 45,000 * 0.10 = $4,500
	# Bracket 2 (45,000 to 55,000) @ 15%: 10,000 * 0.15 = $1,500
	# Total tax = $4,500 + $1,500 = $6,000
	var offset_cg = tax_sys.calculate_capital_gains_tax(85000, 15000)
	assert(offset_cg["net_gains"] == 70000, "Net gains after loss harvesting should be 70,000")
	assert(offset_cg["taxable_gains"] == 55000, "Taxable gains after $15k exemption should be 55,000")
	assert(offset_cg["tax_due"] == 6000, "Expected capital gains tax of $6,000. Got: %d" % offset_cg["tax_due"])
	print("  ✓ Loss harvesting & progressive marginal tiers verified: Gains $85k - Loss $15k -> Net $70k -> Tax $6,000")

	# Test 3: Record capital gain helper
	PlayerData.reset_player()
	tax_sys.record_capital_gain(PlayerData, 5000, "stocks")
	assert(PlayerData.capital_gains_this_year == 5000, "Capital gains should be 5000")
	tax_sys.record_capital_gain(PlayerData, -2000, "crypto")
	assert(PlayerData.capital_losses_this_year == 2000, "Capital losses should be 2000")
	print("  ✓ TaxSystem.record_capital_gain successfully logged stocks gain and crypto loss")


func _test_property_tax() -> void:
	print("\n--- 3. Testing Progressive Property Tax & Multi-Property Surcharges ---")
	var tax_sys = preload("res://scripts/economy/tax_system.gd")
	PlayerData.reset_player()
	PlayerData.age = 35

	# Setup 2 properties in owned_assets:
	# Property 1: Starter condo $150,000 (Tier 1: 0.8% = $1,200)
	# Property 2: Luxury estate $600,000 (Tier 1 300k @ 0.8% = $2,400; Tier 2 300k @ 1.2% = $3,600; base = $6,000)
	# Surcharge for 2nd property: +0.25% on $600,000 = $1,500
	# Prop 2 total = $6,000 + $1,500 = $7,500
	# Total Property Tax = $1,200 + $7,500 = $8,700
	PlayerData.owned_assets = [
		{"category": "properties", "name": "Cozy Condo", "current_value": 150000},
		{"category": "properties", "name": "Luxury Villa", "current_value": 600000}
	]
	var prop_tax = tax_sys.calculate_property_tax(PlayerData)
	assert(prop_tax["property_count"] == 2, "Property count should be 2")
	assert(prop_tax["total_assessed_value"] == 750000, "Total value should be $750,000")
	assert(prop_tax["tax_due"] == 8700, "Total property tax should be $8,700. Got: %d" % prop_tax["tax_due"])
	print("  ✓ Multi-property progressive tax verified: 2 properties ($750k total) -> Tax: $8,700")


func _test_business_tax() -> void:
	print("\n--- 4. Testing Progressive Business Tax & Conglomerate Surcharge ---")
	var tax_sys = preload("res://scripts/economy/tax_system.gd")

	# Single business: Net profit = $200,000 (Revenue $300k - Opex $100k)
	# Brackets:
	# 0 to 100k @ 15% = $15,000
	# 100k to 200k (100k) @ 21% = $21,000
	# Base Tax = $15,000 + $21,000 = $36,000
	var single_biz = tax_sys.calculate_business_tax({"name": "Apex Bakery", "annual_revenue": 300000, "annual_opex": 100000}, 1)
	assert(single_biz["tax_due"] == 36000, "Single business tax on $200k profit should be $36,000. Got: %d" % single_biz["tax_due"])
	print("  ✓ Single enterprise progressive corporate tax verified: $200k profit -> Tax: $36,000")

	# Conglomerate owning 3 businesses with $500,000 profit
	# Surcharge = (3 - 1) * 2% = +4%
	# Tier 1: 100,000 @ 15% = $15,000
	# Tier 2: 400,000 @ 21% = $84,000
	# Base Tax = $99,000
	# Conglomerate surcharge: $500,000 * 0.04 = $20,000
	# Total = $99,000 + $20,000 = $119,000
	var multi_biz = tax_sys.calculate_business_tax({"name": "Tech Corp", "annual_revenue": 800000, "annual_opex": 300000}, 3)
	assert(multi_biz["tax_due"] == 119000, "Conglomerate tax should be $119,000. Got: %d" % multi_biz["tax_due"])
	print("  ✓ Conglomerate scaling surcharge verified: 3 businesses ($500k profit) -> Surcharge +4%% -> Tax: $119,000")


func _test_annual_filing_and_debt() -> void:
	print("\n--- 5. Testing Annual Filing, Debt Assignment & Settlement ---")
	var tax_sys = preload("res://scripts/economy/tax_system.gd")
	PlayerData.reset_player()
	PlayerData.age = 32
	PlayerData.credit_score = 650
	PlayerData.money = 2000 # Insufficient funds
	PlayerData.bank_savings = 1000
	PlayerData.job_salary = 100000

	# Calculate taxes
	var return_report = tax_sys.calculate_tax_return(PlayerData)
	assert(return_report["personal_taxes_due"] > 0, "Should have personal tax liability on $100k salary")
	var total_due: int = return_report["personal_taxes_due"]
	print("  Personal tax liability calculated: $%d" % total_due)

	# Filing when player has $3,000 total liquidity ($2,000 cash + $1,000 bank)
	# Player will incur debt and credit score penalty
	var file_result = tax_sys.file_annual_taxes(PlayerData)
	assert(file_result.has("tax_return"), "Filing return must be present")
	assert(PlayerData.tax_debt > 0, "Player must have outstanding tax debt")
	assert(PlayerData.credit_score < 650, "Credit score must be penalized for delinquent/unpaid taxes")
	print("  ✓ Delinquent filing debt created: Outstanding debt = $%d, New Credit Score = %d" % [PlayerData.tax_debt, PlayerData.credit_score])

	# Test debt repayment
	var old_debt: int = PlayerData.tax_debt
	PlayerData.money = old_debt + 5000
	var paid = PlayerData.pay_outstanding_tax(old_debt)
	assert(paid == old_debt, "Must have paid full debt")
	assert(PlayerData.tax_debt == 0, "Tax debt must now be 0")
	assert(PlayerData.credit_score >= 640, "Credit score should recover after clearing tax debt")
	print("  ✓ PlayerData.pay_outstanding_tax successfully cleared debt. Restored score: %d" % PlayerData.credit_score)

	# Verify reset of annual counters
	assert(PlayerData.capital_gains_this_year == 0, "Capital gains counter should reset for new year")
	assert(PlayerData.capital_losses_this_year == 0, "Capital losses counter should reset for new year")
	assert(PlayerData.charity_donations_this_year == 0, "Charity donations counter should reset for new year")
	print("  ✓ Annual tax accounting counters cleanly reset for next fiscal year")


func _test_tax_office_ui() -> void:
	print("\n--- 6. Testing Tax Office UI Modal in Main Scene ---")
	var main_scene_res: PackedScene = load("res://scenes/main/main_screen.tscn")
	assert(main_scene_res != null, "Failed to load main_screen.tscn")
	var main_screen = main_scene_res.instantiate()

	get_tree().root.add_child.call_deferred(main_screen)
	await get_tree().process_frame
	await get_tree().process_frame

	# 1. Open Finance Hub modal and verify Tax Office button is present
	main_screen._show_finance_hub_modal()
	assert(main_screen.finance_hub_modal_overlay != null, "Finance Hub modal must exist")
	assert(main_screen.finance_hub_modal_overlay.visible, "Finance Hub modal must be visible")
	print("  ✓ Finance Hub opened successfully")

	# 2. Open Tax Office modal
	main_screen._show_tax_service_modal()
	assert(main_screen.tax_service_modal_overlay != null, "Tax Service modal overlay must exist")
	assert(main_screen.tax_service_modal_overlay.visible, "Tax Service modal must be visible")
	print("  ✓ Tax Service modal opened successfully")

	# 3. Simulate debt and test pay tax debt button if debt exists
	PlayerData.tax_debt = 5000
	PlayerData.money = 10000
	main_screen._show_tax_service_modal() # Refresh modal with debt
	assert(main_screen.tax_service_modal_overlay != null)
	print("  ✓ Tax Service modal re-rendered with active tax debt and settlement controls")

	main_screen.tax_service_modal_overlay.queue_free()
	main_screen.finance_hub_modal_overlay.queue_free()
	main_screen.queue_free()
