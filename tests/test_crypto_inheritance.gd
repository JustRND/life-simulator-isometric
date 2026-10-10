extends Node

func _ready() -> void:
	print("=== BEGIN CRYPTOCURRENCY INHERITANCE TEST ===")

	# 1. Setup Parent Character
	PlayerData.reset_player()
	PlayerData.first_name = "Alexander Cross"
	PlayerData.age = 55
	PlayerData.money = 250000
	PlayerData.bank_savings = 500000
	PlayerData.has_started_game = true

	# 2. Buy Cryptocurrencies
	CryptoMarket.ensure(PlayerData)
	var buy_btc := CryptoMarket.buy(PlayerData, "BTC", 50000)
	var buy_eth := CryptoMarket.buy(PlayerData, "ETH", 30000)
	var buy_sol := CryptoMarket.buy(PlayerData, "SOL", 10000)
	var buy_doge := CryptoMarket.buy(PlayerData, "DOGE", 5000)

	assert(buy_btc.success, "BTC purchase must succeed")
	assert(buy_eth.success, "ETH purchase must succeed")
	assert(buy_sol.success, "SOL purchase must succeed")
	assert(buy_doge.success, "DOGE purchase must succeed")

	var btc_amt_parent: float = CryptoMarket.get_holding(PlayerData, "BTC").amount
	var eth_amt_parent: float = CryptoMarket.get_holding(PlayerData, "ETH").amount
	var sol_amt_parent: float = CryptoMarket.get_holding(PlayerData, "SOL").amount
	var doge_amt_parent: float = CryptoMarket.get_holding(PlayerData, "DOGE").amount

	assert(btc_amt_parent > 0.0, "Parent must own BTC")
	assert(eth_amt_parent > 0.0, "Parent must own ETH")
	assert(sol_amt_parent > 0.0, "Parent must own SOL")
	assert(doge_amt_parent > 0.0, "Parent must own DOGE")

	var parent_crypto_val: int = CryptoMarket.portfolio_value(PlayerData)
	print("Parent Alexander Cross (Age 55) Portfolio Value: $%d" % parent_crypto_val)
	assert(parent_crypto_val >= 90000, "Portfolio value must reflect purchases minus fees")

	# 3. Simulate Parent Aging to 56
	PlayerData.age = 56
	var parent_year_logs := CryptoMarket.advance_year(PlayerData)
	assert(int(PlayerData.crypto_wallet.get("last_age", 0)) == 56, "Crypto wallet last_age must be 56 for parent")
	print("✔ 1. Parent portfolio setup and yearly advancement verified")

	# 4. Prepare Heir
	var heir := {
		"name": "Maya Cross",
		"gender": "FEMALE",
		"age": 20,
		"ethnicity": "white",
		"relationship": 95,
		"health": 90,
		"happiness": 85,
		"smarts": 80,
		"looks": 75,
		"portrait_track": 1,
		"portrait_variant": 2
	}

	# 5. Execute Inheritance Takeover
	var inherited_cash := 200000
	PlayerData.takeover_as_heir(heir, inherited_cash, PlayerData.owned_assets, "child")

	# 6. Verify Heir State
	assert(PlayerData.first_name == "Maya Cross", "Active player must now be heir Maya Cross")
	assert(PlayerData.age == 20, "Heir age must be 20")
	assert(PlayerData.bank_savings >= inherited_cash, "Bank savings must receive inherited cash")

	# Check crypto wallet state
	assert(PlayerData.crypto_wallet is Dictionary, "Heir must possess crypto_wallet")
	assert(int(PlayerData.crypto_wallet.get("last_age", 0)) == 20, "CRITICAL: crypto_wallet last_age must be reset to heir's age 20 (was 56)!")

	var btc_amt_heir: float = CryptoMarket.get_holding(PlayerData, "BTC").amount
	var eth_amt_heir: float = CryptoMarket.get_holding(PlayerData, "ETH").amount
	var sol_amt_heir: float = CryptoMarket.get_holding(PlayerData, "SOL").amount
	var doge_amt_heir: float = CryptoMarket.get_holding(PlayerData, "DOGE").amount

	assert(is_equal_approx(btc_amt_heir, btc_amt_parent), "Heir must inherit exact BTC balance")
	assert(is_equal_approx(eth_amt_heir, eth_amt_parent), "Heir must inherit exact ETH balance")
	assert(is_equal_approx(sol_amt_heir, sol_amt_parent), "Heir must inherit exact SOL balance")
	assert(is_equal_approx(doge_amt_heir, doge_amt_parent), "Heir must inherit exact DOGE balance")

	var heir_crypto_val: int = CryptoMarket.portfolio_value(PlayerData)
	print("Heir Maya Cross (Age 20) Inherited Portfolio Value: $%d" % heir_crypto_val)
	assert(heir_crypto_val > 0, "Inherited portfolio value must be positive")
	assert(PlayerData.get_net_worth() >= heir_crypto_val + inherited_cash, "Net worth must include crypto holdings")

	# Verify legacy timeline log
	var found_crypto_in_log := false
	for entry in PlayerData.life_log:
		var text: String = str(entry.get("text", ""))
		if "cryptocurrency asset" in text:
			found_crypto_in_log = true
			print("Found legacy log: %s" % text)
			break
	assert(found_crypto_in_log, "Legacy log entry must explicitly mention inherited cryptocurrency assets")

	# Verify succession news in crypto market
	var found_succession_news := false
	for news_item in PlayerData.crypto_wallet.get("news", []):
		if "SUCCESSION" in str(news_item) and "Maya Cross" in str(news_item):
			found_succession_news = true
			print("Found crypto news: %s" % news_item)
			break
	assert(found_succession_news, "Crypto news feed must announce succession transfer")
	print("✔ 2. Heir succession, wallet retention, legacy log, and news verified")

	# 7. Test Aging Up as Heir (Ensuring Market Is NOT Frozen!)
	print("\n--- Aging Up Heir from 20 to 21 ---")
	PlayerData.age = 21
	var heir_logs_21 := CryptoMarket.advance_year(PlayerData)
	assert(int(PlayerData.crypto_wallet.get("last_age", 0)) == 21, "Crypto wallet last_age must advance to 21")
	assert(heir_logs_21.size() > 0, "advance_year() must execute dynamically and return market logs for heir!")
	for l in heir_logs_21:
		print("  Log (Age 21): %s" % l)

	print("\n--- Aging Up Heir from 21 to 22 ---")
	PlayerData.age = 22
	var heir_logs_22 := CryptoMarket.advance_year(PlayerData)
	assert(int(PlayerData.crypto_wallet.get("last_age", 0)) == 22, "Crypto wallet last_age must advance to 22")
	assert(heir_logs_22.size() > 0, "advance_year() must continue running for age 22")
	for l in heir_logs_22:
		print("  Log (Age 22): %s" % l)
	print("✔ 3. Dynamic crypto cycles and market advancement continue smoothly across generations")

	# 8. Test Heir Trading on Inherited Assets
	var doge_before: float = CryptoMarket.get_holding(PlayerData, "DOGE").amount
	var sell_half := doge_before * 0.5
	var cash_before := PlayerData.money
	var sell_res := CryptoMarket.sell(PlayerData, "DOGE", sell_half)
	assert(sell_res.success, "Heir must be able to sell inherited coins")
	assert(PlayerData.money > cash_before, "Cash must increase after selling inherited crypto")
	var doge_after: float = CryptoMarket.get_holding(PlayerData, "DOGE").amount
	assert(is_equal_approx(doge_after, doge_before - sell_half), "DOGE balance must be halved")

	var buy_aix := CryptoMarket.buy(PlayerData, "AIX", 2000)
	assert(buy_aix.success, "Heir must be able to buy new tokens")
	assert(CryptoMarket.get_holding(PlayerData, "AIX").amount > 0.0, "Heir must own AIX after buying")
	print("✔ 4. Heir buy and sell transactions on inherited crypto wallet verified")

	print("\n=== ALL CRYPTOCURRENCY INHERITANCE TESTS PASSED SUCCESSFULLY! ===")
	get_tree().quit(0)
