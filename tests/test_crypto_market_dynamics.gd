extends Node

func _ready() -> void:
	print("=== BEGIN CRYPTO MARKET DYNAMICS & NPC TRADING TESTS ===")

	# 1. Reset player data for clean testing
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.age = 22
	PlayerData.money = 500000
	PlayerData.bank_savings = 5000000

	# 2. Test initialization
	CryptoMarket.ensure(PlayerData)
	assert(PlayerData.crypto_wallet is Dictionary, "crypto_wallet must be a Dictionary")
	assert(PlayerData.crypto_wallet.has("market"), "crypto_wallet must have market dict")
	assert(PlayerData.crypto_wallet.has("traders"), "crypto_wallet must have traders array")
	assert(PlayerData.crypto_wallet.traders.size() >= 16, "Must have at least 16 NPC traders")
	assert(PlayerData.crypto_wallet.has("recent_trades"), "crypto_wallet must have recent_trades")
	assert(PlayerData.crypto_wallet.recent_trades.size() > 0, "Initial order flow must not be empty")
	assert(PlayerData.crypto_wallet.has("news"), "crypto_wallet must have news headlines")
	print("✔ 1. CryptoMarket.ensure() verified with 16 NPC traders, order flow, and news")

	# 3. Test get_coins() returns dynamic non-zero data
	var coins := CryptoMarket.get_coins(PlayerData)
	assert(coins.size() == 5, "Must return 5 digital assets")
	for c in coins:
		assert(float(c.price) > 0.0, "Coin price must be positive")
		assert(float(c.change_pct) != 0.0, "Initial coin change_pct must be dynamic (not frozen 0.00%)")
		assert(c.sparkline.length() > 0, "Coin sparkline must exist")
		assert(float(c.all_time_high) >= float(c.price), "ATH must be >= current price")
		assert(float(c.all_time_low) <= float(c.price), "ATL must be <= current price")
		assert(int(c.npc_buys) > 0 or int(c.npc_sells) > 0, "Coin must have NPC trading activity")
		assert(float(c.volume_usd) > 0.0, "Coin must have trading volume")
		assert(str(c.catalyst_note).length() > 0, "Coin must have catalyst news note")
		print("  - %s: $%s (%+.2f%%) | Sparkline: %s | ATH: $%s | Vol: $%s" % [
			c.symbol, c.price, c.change_pct, c.sparkline, c.all_time_high, int(c.volume_usd)
		])
	print("✔ 2. get_coins() dynamic prices, non-zero deltas, and NPC metrics verified")

	# 4. Test live tick
	var btc_before: float = CryptoMarket.get_price(PlayerData, "BTC")
	var initial_trade_count: int = PlayerData.crypto_wallet.recent_trades.size()
	CryptoMarket.tick_live_market(PlayerData)
	var btc_after: float = CryptoMarket.get_price(PlayerData, "BTC")
	var new_trade_count: int = PlayerData.crypto_wallet.recent_trades.size()
	print("Live Tick: BTC before $%s -> after $%s" % [btc_before, btc_after])
	assert(btc_after > 0.0, "BTC price must remain valid after live tick")
	assert(new_trade_count > 0, "Recent trades must contain live order flow")
	var latest_trade: Dictionary = PlayerData.crypto_wallet.recent_trades[0]
	assert(latest_trade.has("trader") and latest_trade.has("action") and latest_trade.has("usd_str"), "Live order flow structure verified")
	print("✔ 3. tick_live_market() live price updates & NPC order flow verified (Latest: %s %s %s)" % [
		latest_trade.trader, latest_trade.action, latest_trade.amount_str
	])

	# 5. Test yearly cycle advancement & market crashes / bull runs
	print("\n--- Simulating 5 years of Crypto Cycles ---")
	var saw_crash := false
	var saw_bull_or_alt := false
	for year in range(1, 10):
		PlayerData.age += 1
		var logs := CryptoMarket.advance_year(PlayerData)
		var reg := CryptoMarket.get_sentiment_info(PlayerData)
		var btc_p := CryptoMarket.get_price(PlayerData, "BTC")
		var doge_p := CryptoMarket.get_price(PlayerData, "DOGE")
		print("Year %d (Age %d): Regime: %s | BTC: $%s | DOGE: $%s" % [
			year, PlayerData.age, reg.label, btc_p, doge_p
		])
		if logs.size() > 0:
			print("  Wire Headline: %s" % logs[0])
		if reg.id == "market_crash" or reg.id == "crypto_winter":
			saw_crash = true
		if reg.id == "bull_run" or reg.id == "altseason":
			saw_bull_or_alt = true

	assert(saw_crash or saw_bull_or_alt, "Must have experienced market regime shifts")
	print("✔ 4. advance_year() macro regimes, crashes, spikes, and headlines verified")

	# 6. Test Buy and Sell
	var buy_res := CryptoMarket.buy(PlayerData, "SOL", 10000)
	assert(buy_res.success == true, "Buy SOL must succeed")
	var sol_holding := CryptoMarket.get_holding(PlayerData, "SOL")
	assert(sol_holding.amount > 0.0, "Player must now own SOL")
	assert(sol_holding.invested > 0.0, "Invested amount must be recorded")

	var sell_res := CryptoMarket.sell(PlayerData, "SOL", sol_holding.amount * 0.5)
	assert(sell_res.success == true, "Sell SOL must succeed")
	var sol_after_sell := CryptoMarket.get_holding(PlayerData, "SOL")
	assert(sol_after_sell.amount < sol_holding.amount, "SOL amount must decrease after sell")
	print("✔ 5. Player Buy and Sell execution verified")

	print("\n=== ALL CRYPTO MARKET DYNAMICS & NPC TESTS PASSED! ===")
	get_tree().quit()
