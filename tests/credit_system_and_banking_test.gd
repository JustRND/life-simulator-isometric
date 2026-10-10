extends Node

var failures := 0
var log_lines: Array[String] = []


func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		log_lines.append("❌ FAILED: " + description)
		push_error("FAILED: " + description)
	else:
		log_lines.append("✔ PASSED: " + description)


func _ready() -> void:
	print("=== RUNNING CREDIT SYSTEM & BANKING COMPREHENSIVE TESTS ===")
	LifeLibrary.profile_path = "user://credit_test_profile.json"
	
	# -------------------------------------------------------------
	# 1. SHARES PURCHASES CANNOT BE MADE WITH CASH (BANK BALANCE ONLY)
	# -------------------------------------------------------------
	PlayerData.reset_player()
	PlayerData.first_name = "Finance Tester"
	PlayerData.has_started_game = true
	PlayerData.age = 25
	PlayerData.money = 500000 # Cash only!
	PlayerData.bank_savings = 0
	
	FinanceMarket.ensure(PlayerData)
	var active_listings := FinanceMarket.active(PlayerData)
	check(active_listings.size() > 0, "Market has active listings")
	var stock: Dictionary = active_listings[0]
	
	# Attempt to buy shares with cash only:
	var cash_result := FinanceMarket.trade(PlayerData, stock.uid, 10, true)
	check(cash_result.begins_with("Insufficient bank balance"), "Shares purchase with cash alone must be declined (%s)" % cash_result)
	check(not PlayerData.finance_market.holdings.has(stock.uid), "No shares purchased with cash")
	check(PlayerData.money == 500000, "Cash untouched by rejected trade")
	
	# Fund bank savings and buy:
	PlayerData.deposit_cash(200000)
	check(PlayerData.bank_savings == 200000 and PlayerData.money == 300000, "Deposited cash into bank")
	var bank_before := PlayerData.bank_savings
	var buy_result := FinanceMarket.trade(PlayerData, stock.uid, 10, true)
	check(buy_result.begins_with("Bought 10 shares"), "Shares purchase succeeds using bank balance (%s)" % buy_result)
	check(PlayerData.bank_savings < bank_before, "Bank balance debited for stock purchase")
	check(PlayerData.money == 300000, "Cash was completely untouched by stock purchase")
	
	# Selling shares deposits back into bank balance:
	var bank_before_sell := PlayerData.bank_savings
	var sell_result := FinanceMarket.trade(PlayerData, stock.uid, 10, false)
	check(sell_result.begins_with("Sold 10 shares"), "Shares sold successfully")
	check(PlayerData.bank_savings > bank_before_sell, "Sale proceeds deposited into bank balance")
	check(PlayerData.money == 300000, "Cash remained untouched on stock sale")
	
	# -------------------------------------------------------------
	# 1b. PURCHASING IN-GAME PRIORITIZES BANK BALANCE FIRST THEN CASH
	# -------------------------------------------------------------
	PlayerData.bank_savings = 1000
	PlayerData.money = 500
	check(PlayerData.debit_funds(400), "Can debit 400")
	check(PlayerData.bank_savings == 600 and PlayerData.money == 500, "Debit prioritized bank balance (bank: 600, cash: 500)")
	
	# Debit more than remaining bank balance:
	check(PlayerData.debit_funds(800), "Can debit 800")
	check(PlayerData.bank_savings == 0 and PlayerData.money == 300, "Remaining 200 taken from cash after bank exhausted (bank: 0, cash: 300)")
	check(not PlayerData.debit_funds(301), "Cannot debit more than total available funds")
	check(PlayerData.debit_funds(300), "Can debit all remaining cash")
	check(PlayerData.bank_savings == 0 and PlayerData.money == 0, "All funds zeroed")
	
	# -------------------------------------------------------------
	# 2. NEW BANK LOAN OPTIONS: $250,000 AND $500,000
	# -------------------------------------------------------------
	PlayerData.money = 0
	PlayerData.bank_savings = 0
	PlayerData.loan_balance = 0
	
	check(PlayerData.take_bank_loan(250000, 0.12), "Borrowing $250,000 corporate loan succeeded")
	check(PlayerData.loan_balance == 250000, "Loan balance recorded as $250,000")
	check(is_equal_approx(PlayerData.loan_interest_rate, 0.12), "Loan interest rate recorded as 12%")
	check(not PlayerData.take_bank_loan(500000, 0.14), "Cannot borrow second loan while loan is active")
	
	# Repay full loan and test $500,000 tier:
	PlayerData.bank_savings = 300000
	var paid := PlayerData.repay_bank_loan(250000)
	check(paid == 250000, "Repaid $250,000 loan")
	check(PlayerData.loan_balance == 0, "Loan balance is zero")
	
	check(PlayerData.take_bank_loan(500000, 0.14), "Borrowing $500,000 jumbo loan succeeded")
	check(PlayerData.loan_balance == 500000, "Loan balance recorded as $500,000")
	check(is_equal_approx(PlayerData.loan_interest_rate, 0.14), "Loan interest rate recorded as 14%")
	PlayerData.bank_savings = 600000
	PlayerData.repay_bank_loan(500000)
	check(PlayerData.loan_balance == 0, "Cleaned up loan balance")
	
	# -------------------------------------------------------------
	# 3. CREDIT CARD SYSTEM: STRICT APPLICATION APPROVAL/DECLINE
	# -------------------------------------------------------------
	PlayerData.reset_player()
	PlayerData.first_name = "Credit Applicant"
	PlayerData.age = 25
	PlayerData.has_started_game = true
	PlayerData.credit_score = 720
	PlayerData.money = 50000
	PlayerData.bank_savings = 50000
	
	# Case A: Character has active loan -> MUST DECLINE
	PlayerData.loan_balance = 5000
	var check_loan := PlayerData.can_apply_credit_card("Gold")
	check(not bool(check_loan.get("eligible", false)), "Credit card application MUST be declined when player has loan balance")
	PlayerData.loan_balance = 0
	
	# Case B: Character has unpaid taxes -> MUST DECLINE
	PlayerData.tax_debt = 200
	var check_tax := PlayerData.can_apply_credit_card("Gold")
	check(not bool(check_tax.get("eligible", false)), "Credit card application MUST be declined when player has unpaid taxes")
	PlayerData.tax_debt = 0
	
	# Case C: Character has other debt -> MUST DECLINE
	PlayerData.debt = 500
	var check_debt := PlayerData.can_apply_credit_card("Gold")
	check(not bool(check_debt.get("eligible", false)), "Credit card application MUST be declined when player has general debt")
	PlayerData.debt = 0
	
	# Case D: Underage character -> MUST DECLINE
	PlayerData.age = 17
	var check_age := PlayerData.can_apply_credit_card("Silver")
	check(not bool(check_age.get("eligible", false)), "Credit card application MUST be declined for underage player")
	PlayerData.age = 25
	
	# Case E: Insufficient Credit Score -> MUST DECLINE
	PlayerData.credit_score = 550
	var check_score := PlayerData.can_apply_credit_card("Silver")
	check(not bool(check_score.get("eligible", false)), "Credit card application MUST be declined with low credit score (< 600)")
	
	# Case F: Insufficient Net Worth -> MUST DECLINE
	PlayerData.credit_score = 750
	PlayerData.money = 100
	PlayerData.bank_savings = 100
	var check_nw := PlayerData.can_apply_credit_card("Gold")
	check(not bool(check_nw.get("eligible", false)), "Gold card declined when net worth < $30,000")
	
	# Case G: Clean profile, qualifies for Gold card -> MUST APPROVE WITH DYNAMIC LIMIT
	PlayerData.money = 20000
	PlayerData.bank_savings = 25000
	PlayerData.job_salary = 10000 # Contributes $5,000 to limit
	var check_gold := PlayerData.can_apply_credit_card("Gold")
	check(bool(check_gold.get("eligible", false)), "Gold card approved when debt=0, tax=0, net worth and score qualify")
	
	var approve_gold := PlayerData.approve_credit_card("Gold")
	check(approve_gold, "Successfully approved and opened Gold Credit Card")
	check(PlayerData.has_credit_card, "Player now has credit card")
	check(PlayerData.credit_card_tier == "Gold", "Tier is Gold")
	# Base for Gold = 25000 + 5000 (salary) + 4500 (10% of $45k nw) = 34500
	check(PlayerData.credit_card_limit == 34500, "Dynamic limit is $34,500 based on salary and personal net worth (Got: %d)" % PlayerData.credit_card_limit)
	check(PlayerData.credit_card_balance == 0, "Initial balance is 0")
	check(PlayerData.get_credit_card_available() == 34500, "Full dynamic limit available")
	
	# -------------------------------------------------------------
	# 3b. BUSINESS VALUATION EXCLUDED FROM CREDIT CARD LIMIT / ASSETS
	# -------------------------------------------------------------
	PlayerData.owned_businesses.append({
		"name": "MegaCorp",
		"valuation": 5000000,
		"treasury": 1000000,
		"loan_balance": 0,
		"unpaid_taxes": 0,
		"owner_fraction": 1.0
	})
	check(PlayerData.get_net_worth() > 5000000, "Total net worth includes business valuation")
	check(PlayerData.get_personal_net_worth() == 45000, "Personal net worth STRICTLY EXCLUDES business valuation ($45,000)")
	check(PlayerData.calculate_dynamic_credit_limit("Gold") == 34500, "Credit card dynamic limit completely excludes business valuation ($34,500)")
	PlayerData.owned_businesses.clear()

	# -------------------------------------------------------------
	# 3c. PURCHASE ASSETS USING CREDIT CARD
	# -------------------------------------------------------------
	# Player acquires driver's license to purchase a car:
	if not PlayerData.licenses.has("license_car"):
		PlayerData.licenses.append("license_car")
	
	var car_item := AssetCatalog.get_item("car_sedan")
	var car_price: int = int(car_item["price"])
	var car_eval := AssetCatalog.can_purchase_asset(PlayerData, "car_sedan", "credit_card")
	check(bool(car_eval.get("allowed", false)), "Can purchase Volt Sedan ($%d) using credit card" % car_price)
	
	var buy_car_res := AssetCatalog.buy_asset(PlayerData, "car_sedan", "credit_card")
	check(bool(buy_car_res.get("success", false)), "Successfully purchased car with credit card")
	check(PlayerData.credit_card_balance == car_price, "Credit card balance increased by car price ($%d)" % car_price)
	check(PlayerData.get_credit_card_available() == 34500 - car_price, "Available credit decreased to $%d" % (34500 - car_price))
	check(PlayerData.owned_assets.size() == 1, "Car added to player owned assets")
	check(bool(PlayerData.owned_assets[0].get("purchased_with_credit", false)), "Asset marked as purchased with credit")
	
	# Try to buy luxury asset exceeding remaining credit limit:
	var cannot_buy_aircraft := AssetCatalog.can_purchase_asset(PlayerData, "aircraft_cessna", "credit_card")
	check(not bool(cannot_buy_aircraft.get("allowed", false)), "Cannot purchase Cessna ($380,000) that exceeds available credit ($%d)" % (34500 - car_price))

	# -------------------------------------------------------------
	# 3d. MANUAL USAGE REPAYMENTS & 10% MINIMUM LOCK
	# -------------------------------------------------------------
	var min_pay := maxi(1, int(ceil(PlayerData.credit_card_balance * 0.10)))
	var expected_min_pay: int = int(ceil(float(car_price) * 0.10))
	check(min_pay == expected_min_pay, "Minimum payment strictly locked at 10%% of usage ($%d)" % expected_min_pay)

	# Pay 10%:
	var score_before := PlayerData.credit_score
	var paid_10 := PlayerData.repay_credit_card(min_pay)
	check(paid_10 == expected_min_pay, "Paid 10%% minimum payment ($%d)" % expected_min_pay)
	check(PlayerData.credit_card_balance == car_price - expected_min_pay, "Remaining usage is $%d" % (car_price - expected_min_pay))
	check(PlayerData.credit_card_paid_this_year == expected_min_pay, "Annual payment tracker recorded $%d" % expected_min_pay)
	check(PlayerData.credit_score >= score_before, "Credit score maintained or improved on repayment")

	# Pay 20% of new balance:
	var pay_20 := maxi(1, int(ceil(PlayerData.credit_card_balance * 0.20)))
	var paid_20 := PlayerData.repay_credit_card(pay_20)
	check(paid_20 == pay_20, "Paid 20%% payment ($%d)" % pay_20)
	check(PlayerData.credit_card_paid_this_year == expected_min_pay + pay_20, "Annual payment tracker accumulated payments")

	# Custom payoff remaining:
	var remaining := PlayerData.credit_card_balance
	PlayerData.bank_savings = 50000
	var paid_rest := PlayerData.repay_credit_card(remaining)
	check(paid_rest == remaining, "Paid off remaining usage ($%d)" % remaining)
	check(PlayerData.credit_card_balance == 0, "Usage fully paid off to $0")

	# -------------------------------------------------------------
	# 3e. REQUEST HIGHER CREDIT CARD BALANCE LIMIT
	# -------------------------------------------------------------
	# Player now owns a car worth $22,000, has $50,000 savings, and salary of $10,000.
	# Dynamic limit should now recalculate higher from personal assets!
	var limit_increase_res := PlayerData.request_credit_limit_increase()
	check(bool(limit_increase_res.get("success", false)), "Request for higher credit limit approved when balance is $0 and assets grew (%s)" % str(limit_increase_res.get("message", "")))
	check(PlayerData.credit_card_limit > 34500, "Credit card limit increased above previous $34,500 (Now: $%d)" % PlayerData.credit_card_limit)

	# -------------------------------------------------------------
	# 3f. DEBT CONVERSION & CARD DEACTIVATION ON DEFAULT
	# -------------------------------------------------------------
	# Verify cash advance is strictly prohibited (anti-loophole policy)
	var cash_adv_blocked := PlayerData.draw_credit_card_advance(15000)
	check(not cash_adv_blocked, "Converting credit card limit to cash is strictly prohibited")
	# Charge legitimate purchase onto card:
	PlayerData.charge_credit_card(15000)
	check(PlayerData.credit_card_balance == 15000, "Charged $15,000 purchase onto card")
	
	# Character goes broke (unable to pay minimum 10% back to bank):
	PlayerData.money = 0
	PlayerData.bank_savings = 0
	PlayerData.debt = 0
	var def_min := maxi(1, int(ceil(PlayerData.credit_card_balance * 0.10))) # $1,500
	check(PlayerData.get_available_funds() < def_min, "Character has $0 and is unable to service the minimum payment ($1,500)")
	
	var default_res := PlayerData.deactivate_credit_card_on_default()
	check(bool(default_res.get("deactivated", false)), "Credit card deactivated on default")
	check(not PlayerData.has_credit_card, "Card revoked: has_credit_card is false")
	check(PlayerData.credit_card_tier == "None", "Card tier set to None")
	check(PlayerData.credit_card_limit == 0, "Card limit zeroed")
	check(PlayerData.credit_card_balance == 0, "Card usage cleared")
	check(PlayerData.debt == 15000, "Unpaid usage converted directly into collections DEBT ($15,000)")
	check(int(default_res.get("unpaid_usage", 0)) == 15000, "Reported unpaid usage of $15,000")

	# Clean up debt for subsequent tests:
	PlayerData.debt = 0

	# -------------------------------------------------------------
	# 4. CREDIT SCORE SYSTEM & NON-INHERITANCE TO CHILDREN
	# -------------------------------------------------------------
	# Set parent's score to 820 with Platinum card
	PlayerData.credit_score = 820
	check(PlayerData.get_credit_rating() == "Exceptional", "Rating is Exceptional for score 820")
	check(PlayerData.get_credit_score_color() == Color("#10b981"), "Color is green for Exceptional")
	PlayerData.has_credit_card = true
	PlayerData.credit_card_tier = "Platinum"
	PlayerData.credit_card_limit = 100000
	PlayerData.credit_card_balance = 15000
	
	# Child takeover:
	var heir := {"name": "New Generation", "age": 18, "gender": "FEMALE"}
	PlayerData.takeover_as_child(heir, 50000, [])
	
	check(PlayerData.credit_score == 650, "CRITICAL: Child DOES NOT inherit parent's credit score! Starts at default 650 (Current: %d)" % PlayerData.credit_score)
	check(not PlayerData.has_credit_card, "CRITICAL: Child DOES NOT inherit credit card account!")
	check(PlayerData.credit_card_tier == "None", "Child card tier is None")
	check(PlayerData.credit_card_limit == 0, "Child card limit is 0")
	check(PlayerData.credit_card_balance == 0, "Child DOES NOT inherit parent's credit card debt!")
	check(PlayerData.get_credit_rating() == "Fair", "Rating for 650 is Fair")
	
	# -------------------------------------------------------------
	# SUMMARY
	# -------------------------------------------------------------
	for line in log_lines:
		print(line)
		
	if failures == 0:
		print("\n🎉 ALL CREDIT SYSTEM & BANKING TESTS PASSED PERFECTLY!")
	else:
		print("\n❌ SOME TESTS FAILED (%d failures)" % failures)
		assert(failures == 0, "Credit system & banking test had %d failures!" % failures)
	
	get_tree().quit()
