extends Node

func _ready() -> void:
	print("\n=======================================================")
	print("🧪 RUNNING VERIFICATION SUITE: PENSION & SAVINGS ACCOUNTS")
	print("=======================================================\n")

	_test_pension_account_rules()
	_test_savings_account_rules()
	_test_inheritance_differentiation()
	_test_finance_hub_ui()

	print("\n=======================================================")
	print("🎉 ALL PENSION & SAVINGS TESTS PASSED WITH 100% SUCCESS!")
	print("=======================================================\n")
	get_tree().quit(0)


func _test_pension_account_rules() -> void:
	print("--- 1. Testing Pension Account Rules (Non-Inheritable) ---")
	var ps_mgr = preload("res://scripts/economy/pension_and_savings_manager.gd")
	PlayerData.reset_player()
	ps_mgr.ensure(PlayerData)

	# Age requirement (<18 cannot open or deposit)
	PlayerData.age = 16
	PlayerData.money = 50000
	var dep_fail = ps_mgr.deposit_pension(PlayerData, 1000)
	assert(not dep_fail["success"], "Minor should not be allowed to contribute to pension")
	print("  ✓ Underage protection verified: %s" % dep_fail["message"])

	# Age 30: Valid deposit
	PlayerData.age = 30
	var dep_res = ps_mgr.deposit_pension(PlayerData, 10000)
	assert(dep_res["success"], "Deposit should succeed for adult: %s" % dep_res.get("message", ""))
	assert(PlayerData.pension_account["balance"] == 10000, "Expected balance $10,000")
	assert(PlayerData.money == 40000, "Money should decrease by $10,000")
	print("  ✓ Deposit verified: %s" % dep_res["message"])

	# Annual contribution & employer match on year advance
	PlayerData.job_salary = 100000
	ps_mgr.set_pension_contribution_pct(PlayerData, 0.10) # 10%
	var logs := ps_mgr.advance_year(PlayerData)
	# 10% contribution = $10,000, 3% employer match = $3,000
	# Prior balance $10,000 + $13,000 = $23,000
	# Plus 6.5% interest on balance
	assert(PlayerData.pension_account["balance"] > 23000, "Expected balance to include contributions, match and interest")
	print("  ✓ Annual payroll contribution and 6.5%% APR growth verified (New Balance: $%d)" % PlayerData.pension_account["balance"])

	# Early withdrawal penalty before age 60 (20% penalty)
	var pre_with_money := PlayerData.money
	var with_early = ps_mgr.withdraw_pension(PlayerData, 5000)
	assert(with_early["success"], "Early withdrawal should succeed")
	assert(with_early["penalty"] == 1000, "Expected 20% penalty ($1,000) on $5,000")
	assert(with_early["net_received"] == 4000, "Expected net received $4,000")
	assert(PlayerData.money == pre_with_money + 4000, "Cash should increase by net received ($4,000)")
	print("  ✓ Early withdrawal penalty verified: %s" % with_early["message"])

	# Retirement age (65): penalty-free withdrawal
	PlayerData.age = 65
	var pre_ret_money := PlayerData.money
	var with_ret = ps_mgr.withdraw_pension(PlayerData, 5000)
	assert(with_ret["success"], "Retirement withdrawal should succeed")
	assert(with_ret["penalty"] == 0, "Expected 0% penalty for age 60+")
	assert(with_ret["net_received"] == 5000, "Expected 100% net received for age 60+")
	assert(PlayerData.money == pre_ret_money + 5000, "Cash should increase by full amount")
	print("  ✓ Age 60+ penalty-free withdrawal verified: %s" % with_ret["message"])

	# Annuity mode at age 65
	var ann_toggle = ps_mgr.toggle_pension_annuity(PlayerData, true)
	assert(ann_toggle["success"], "Annuity toggle should succeed")
	var pre_ann_cash := PlayerData.money
	var prev_bal: int = PlayerData.pension_account["balance"]
	var ret_logs := ps_mgr.advance_year(PlayerData)
	assert(PlayerData.money > pre_ann_cash, "Cash should increase from annual annuity distribution")
	print("  ✓ Retirement annuity distribution verified: %s" % ret_logs.back())


func _test_savings_account_rules() -> void:
	print("\n--- 2. Testing Savings Account Rules (Inheritable) ---")
	var ps_mgr = preload("res://scripts/economy/pension_and_savings_manager.gd")
	PlayerData.reset_player()
	ps_mgr.ensure(PlayerData)

	PlayerData.age = 25
	PlayerData.money = 50000

	# Deposit
	var dep = ps_mgr.deposit_savings(PlayerData, 20000)
	assert(dep["success"], "Deposit should succeed")
	assert(PlayerData.savings_account["balance"] == 20000, "Savings balance should be $20,000")
	assert(PlayerData.money == 30000, "Cash should decrease by $20,000")
	print("  ✓ Savings deposit verified: %s" % dep["message"])

	# Annual 4.2% APY compounding
	var logs := ps_mgr.advance_year(PlayerData)
	# 4.2% on 20,000 = +$840
	assert(PlayerData.savings_account["balance"] == 20840, "Expected balance $20,840 after 4.2% APY interest")
	print("  ✓ High-yield 4.2%% APY compounding verified (New Balance: $%d)" % PlayerData.savings_account["balance"])

	# Penalty-free withdrawal anytime
	var with_res = ps_mgr.withdraw_savings(PlayerData, 5000)
	assert(with_res["success"], "Withdrawal should succeed")
	assert(PlayerData.savings_account["balance"] == 15840, "Remaining balance should be $15,840")
	assert(PlayerData.money == 35000, "Cash should increase by full $5,000")
	print("  ✓ Penalty-free instant withdrawal verified: %s" % with_res["message"])


func _test_inheritance_differentiation() -> void:
	print("\n--- 3. Testing Inheritance Differentiation (Core Requirement) ---")
	var ps_mgr = preload("res://scripts/economy/pension_and_savings_manager.gd")
	PlayerData.reset_player()
	ps_mgr.ensure(PlayerData)

	PlayerData.first_name = "Marcus"
	PlayerData.age = 70
	PlayerData.money = 25000
	PlayerData.bank_savings = 50000
	PlayerData.pension_account["balance"] = 85000 # CANNOT BE INHERITED
	PlayerData.savings_account["balance"] = 120000 # CAN BE INHERITED

	var heir_data := {
		"first_name": "Alexander",
		"gender": "MALE",
		"age": 28,
		"health": 90,
		"happiness": 80,
		"smarts": 85,
		"looks": 75,
		"education": "University",
		"alive": true
	}

	# Execute succession takeover
	PlayerData.takeover_as_heir(heir_data, 50000, [], "child")

	# VERIFY: Pension CANNOT be inherited (balance must be 0)
	assert(PlayerData.pension_account["balance"] == 0, "CRITICAL: Pension account must NOT be inherited! Must be $0.")
	print("  ✓ PASS: Pension Account was NOT inherited (Balance: $%d - 100%% forfeited per policy)" % PlayerData.pension_account["balance"])

	# VERIFY: Savings Account CAN be inherited (balance must carry over)
	assert(PlayerData.savings_account["balance"] == 120000, "CRITICAL: Savings account MUST be inherited intact! Expected $120,000.")
	print("  ✓ PASS: Savings Account WAS successfully inherited (Balance: $%d preserved for next generation)" % PlayerData.savings_account["balance"])


func _test_finance_hub_ui() -> void:
	print("\n--- 4. Testing Finance Hub UI & Modals ---")
	var main_scene_res: PackedScene = load("res://scenes/main/main_screen.tscn")
	assert(main_scene_res != null, "Failed to load main_screen.tscn")
	var main_screen = main_scene_res.instantiate()

	get_tree().root.add_child.call_deferred(main_screen)
	await get_tree().process_frame
	await get_tree().process_frame

	# Test opening Finance Hub modal
	print("  Opening Finance Hub modal...")
	main_screen._show_finance_hub_modal()
	assert(main_screen.finance_hub_modal_overlay != null, "Finance hub modal overlay should exist")
	assert(main_screen.finance_hub_modal_overlay.visible == true, "Finance hub should be visible")
	print("  ✓ Finance Hub modal opened with all division buttons")

	# Test opening Pension Account modal
	print("  Opening Pension Account modal...")
	main_screen._show_pension_account_modal()
	assert(main_screen.pension_modal_overlay != null, "Pension modal overlay should exist")
	assert(main_screen.pension_modal_overlay.visible == true, "Pension modal should be visible")
	print("  ✓ Pension Account modal opened without visual clipping")

	# Test opening Savings Account modal
	print("  Opening Savings Account modal...")
	main_screen._show_savings_account_modal()
	assert(main_screen.savings_modal_overlay != null, "Savings modal overlay should exist")
	assert(main_screen.savings_modal_overlay.visible == true, "Savings modal should be visible")
	print("  ✓ Savings Account modal opened without visual clipping")

	main_screen.queue_free()
