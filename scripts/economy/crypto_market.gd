class_name CryptoMarket
extends RefCounted

const TRADING_FEE_PCT: float = 0.005 # 0.5% exchange fee

const COINS: Array[Dictionary] = [
	{
		"symbol": "BTC",
		"name": "PixelBitcoin",
		"icon": "🪙",
		"base_price": 64000.0,
		"min_price": 12000.0,
		"max_price": 280000.0,
		"volatility": 0.28,
		"description": "The foundational decentralized digital gold and benchmark cryptographic reserve asset."
	},
	{
		"symbol": "ETH",
		"name": "EtherPixel",
		"icon": "💎",
		"base_price": 3450.0,
		"min_price": 600.0,
		"max_price": 18000.0,
		"volatility": 0.35,
		"description": "Global smart-contract computation network powering decentralized finance and dApps."
	},
	{
		"symbol": "SOL",
		"name": "SolanaByte",
		"icon": "⚡",
		"base_price": 145.0,
		"min_price": 15.0,
		"max_price": 1200.0,
		"volatility": 0.45,
		"description": "Ultra-fast parallelized blockchain optimized for high-frequency algorithmic liquidity."
	},
	{
		"symbol": "AIX",
		"name": "CyberAI Token",
		"icon": "🤖",
		"base_price": 24.5,
		"min_price": 1.5,
		"max_price": 350.0,
		"volatility": 0.55,
		"description": "Decentralized GPU computing collective token fueling autonomous neural network clusters."
	},
	{
		"symbol": "DOGE",
		"name": "PixelDoge",
		"icon": "🐕",
		"base_price": 0.16,
		"min_price": 0.01,
		"max_price": 4.50,
		"volatility": 0.70,
		"description": "High-volatility community memecoin driven by viral social media cycles and internet hype."
	}
]


static func get_coin_spec(symbol: String) -> Dictionary:
	for c in COINS:
		if str(c.get("symbol", "")).to_upper() == symbol.to_upper():
			return c
	return {}


static func get_sentiment(player_data: Node = null) -> String:
	if is_instance_valid(player_data) and player_data.get("crypto_wallet") is Dictionary:
		return str(player_data.get("crypto_wallet").get("sentiment", "bull"))
	return "bull"


static func get_sentiment_info(player_data: Node = null) -> Dictionary:
	var s := get_sentiment(player_data)
	match s:
		"bull":
			return {
				"cycle": "bull",
				"label": "🚀 BULL MARKET RUN",
				"color": "#10b981",
				"desc": "High speculative momentum and institutional capital inflow. Altcoins surging."
			}
		"bear":
			return {
				"cycle": "bear",
				"label": "🐻 BEAR MARKET DOWNTURN",
				"color": "#ef4444",
				"desc": "Macro liquidity contraction and severe selling pressure. Prices depressed."
			}
		_:
			return {
				"cycle": "crab",
				"label": "🦀 CRAB CONSOLIDATION",
				"color": "#f59e0b",
				"desc": "Range-bound sideways accumulation. Choppy spot volatility and low volume."
			}


static func get_coins(player_data: Node = null) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for c in COINS:
		var sym: String = str(c["symbol"])
		var price: float = float(c["base_price"])
		var delta_pct: float = 0.0
		var hist: Array = []
		if is_instance_valid(player_data) and player_data.get("crypto_wallet") is Dictionary:
			var wallet: Dictionary = player_data.get("crypto_wallet")
			var m_dict: Dictionary = wallet.get("market", {})
			if m_dict.has(sym):
				var m: Dictionary = m_dict[sym]
				price = float(m.get("price", price))
				delta_pct = float(m.get("delta_pct", 0.0))
				hist = m.get("history", [])

		var spark := " ▂▃▄▅"
		if delta_pct < -5.0:
			spark = "▆▅▃▂ "
		elif delta_pct > 15.0:
			spark = " ▃▅▆█"
		elif delta_pct > 0.0:
			spark = " ▂▃▄▅▆"

		result.append({
			"id": sym.to_lower(),
			"symbol": sym,
			"name": str(c["name"]),
			"icon": str(c["icon"]),
			"price": price,
			"change_pct": delta_pct,
			"sparkline": spark,
			"description": str(c["description"]),
			"history": hist
		})
	return result


static func ensure(player_data: Node) -> void:
	if not player_data.get("crypto_wallet") is Dictionary:
		player_data.set("crypto_wallet", {})

	var wallet: Dictionary = player_data.get("crypto_wallet")
	if not wallet.has("coins") or not wallet["coins"] is Dictionary:
		wallet["coins"] = {}
	if not wallet.has("market") or not wallet["market"] is Dictionary:
		wallet["market"] = {}

	var coins_dict: Dictionary = wallet["coins"]
	var market_dict: Dictionary = wallet["market"]

	for c in COINS:
		var sym: String = str(c["symbol"])
		if not coins_dict.has(sym):
			coins_dict[sym] = {
				"amount": 0.0,
				"cost_basis": 0.0,
				"total_invested": 0.0
			}
		if not market_dict.has(sym):
			var b_price: float = float(c["base_price"])
			market_dict[sym] = {
				"price": b_price,
				"delta_pct": 0.0,
				"history": [b_price * 0.9, b_price * 0.95, b_price]
			}

	if not wallet.has("last_age"):
		wallet["last_age"] = player_data.age
	if not wallet.has("sentiment"):
		wallet["sentiment"] = "bull"


static func advance_year(player_data: Node) -> Array[String]:
	ensure(player_data)
	var wallet: Dictionary = player_data.get("crypto_wallet")
	var last_age: int = int(wallet.get("last_age", player_data.age))
	if last_age >= player_data.age:
		return []

	wallet["last_age"] = player_data.age
	var market_dict: Dictionary = wallet["market"]
	var coins_dict: Dictionary = wallet["coins"]

	# Sentiment cycle roll (60% chance to flip/continue sentiment)
	var sentiments := ["bull", "bear", "crab"]
	var cur_sent: String = str(wallet.get("sentiment", "bull"))
	if randf() < 0.45:
		sentiments.erase(cur_sent)
		cur_sent = sentiments.pick_random()
		wallet["sentiment"] = cur_sent

	var logs: Array[String] = []
	var total_portfolio_before := portfolio_value(player_data)

	for c in COINS:
		var sym: String = str(c["symbol"])
		var m_data: Dictionary = market_dict.get(sym, {})
		var cur_price: float = float(m_data.get("price", c["base_price"]))
		var vol: float = float(c["volatility"])

		var trend_bias: float = 0.0
		match cur_sent:
			"bull":
				trend_bias = randf_range(0.10, 0.45)
			"bear":
				trend_bias = randf_range(-0.40, -0.10)
			"crab":
				trend_bias = randf_range(-0.08, 0.08)

		var noise: float = randf_range(-vol, vol)
		var delta_ratio: float = trend_bias + noise
		# Limit single-year swing between -75% and +250%
		delta_ratio = clampf(delta_ratio, -0.75, 2.50)

		var new_price: float = cur_price * (1.0 + delta_ratio)
		new_price = clampf(new_price, float(c["min_price"]), float(c["max_price"]))
		var actual_delta_pct: float = ((new_price - cur_price) / cur_price) * 100.0

		var hist: Array = m_data.get("history", [])
		hist.append(snapp(new_price, 2))
		if hist.size() > 8:
			hist.pop_front()

		market_dict[sym] = {
			"price": snapp(new_price, 2 if new_price > 1.0 else 4),
			"delta_pct": snapp(actual_delta_pct, 1),
			"history": hist
		}

	var total_portfolio_after := portfolio_value(player_data)
	if total_portfolio_before > 0:
		var diff := total_portfolio_after - total_portfolio_before
		var pct := (float(diff) / float(total_portfolio_before)) * 100.0
		if diff > 1000:
			logs.append("🪙 CRYPTO MARKET: Your cryptocurrency holdings gained +$%s (+%.1f%%) in this year's %s cycle!" % [
				_format_num(diff), pct, cur_sent.to_upper()
			])
		elif diff < -1000:
			logs.append("🪙 CRYPTO MARKET: Cryptocurrency holdings contracted by -$%s (%.1f%%) amid market downturn." % [
				_format_num(abs(diff)), pct
			])

	return logs


static func get_price(player_data: Node, symbol: String) -> float:
	ensure(player_data)
	var sym := symbol.to_upper()
	var wallet: Dictionary = player_data.get("crypto_wallet")
	var m: Dictionary = wallet.get("market", {})
	if m.has(sym):
		return float(m[sym].get("price", 0.0))
	var spec := get_coin_spec(sym)
	return float(spec.get("base_price", 0.0))


static func get_holding(player_data: Node, symbol: String) -> Dictionary:
	ensure(player_data)
	var sym := symbol.to_upper()
	var wallet: Dictionary = player_data.get("crypto_wallet")
	var coins: Dictionary = wallet.get("coins", {})
	var h: Dictionary = coins.get(sym, {"amount": 0.0, "cost_basis": 0.0, "total_invested": 0.0})
	return {
		"amount": float(h.get("amount", 0.0)),
		"cost_basis": float(h.get("cost_basis", 0.0)),
		"invested": float(h.get("total_invested", 0.0)),
		"total_invested": float(h.get("total_invested", 0.0))
	}


static func portfolio_value(player_data: Node) -> int:
	if not is_instance_valid(player_data):
		return 0
	ensure(player_data)
	var wallet: Dictionary = player_data.get("crypto_wallet")
	var coins: Dictionary = wallet.get("coins", {})
	var total: float = 0.0

	for sym in coins:
		var holding: Dictionary = coins[sym]
		var amt: float = float(holding.get("amount", 0.0))
		if amt > 0.0:
			var price := get_price(player_data, sym)
			total += amt * price

	return int(round(total))


static func portfolio_pnl(player_data: Node) -> Dictionary:
	ensure(player_data)
	var wallet: Dictionary = player_data.get("crypto_wallet")
	var coins: Dictionary = wallet.get("coins", {})
	var total_cost: float = 0.0
	var total_current: float = 0.0

	for sym in coins:
		var h: Dictionary = coins[sym]
		var amt: float = float(h.get("amount", 0.0))
		if amt > 0.0:
			total_cost += float(h.get("total_invested", 0.0))
			total_current += amt * get_price(player_data, sym)

	var net_gain := total_current - total_cost
	var pct := 0.0
	if total_cost > 0.0:
		pct = (net_gain / total_cost) * 100.0

	return {
		"current_value": int(round(total_current)),
		"current": total_current,
		"total_cost": int(round(total_cost)),
		"invested": total_cost,
		"net_gain": int(round(net_gain)),
		"pnl": net_gain,
		"gain_pct": snapp(pct, 1),
		"pnl_pct": snapp(pct, 2)
	}


static func buy(player_data: Node, symbol: String, usd_amount: Variant) -> Dictionary:
	ensure(player_data)
	var sym := symbol.to_upper()
	var raw_usd: float = float(usd_amount)
	var usd_int: int = int(round(raw_usd))

	if player_data.age < 18:
		return {"success": false, "message": "Crypto Exchange Regulations: You must be at least 18 years old to trade digital assets."}
	if player_data.is_in_prison or player_data.is_dead:
		return {"success": false, "message": "Cannot trade while incarcerated or deceased."}
	if usd_int <= 0:
		return {"success": false, "message": "Enter a valid dollar amount to invest."}

	var avail: int = player_data.money + player_data.bank_savings
	if avail < usd_int:
		return {"success": false, "message": "Insufficient funds: You have $%s available (Requested: $%s)." % [_format_num(avail), _format_num(usd_int)]}

	var price := get_price(player_data, sym)
	if price <= 0.0:
		return {"success": false, "message": "Market unavailable."}

	var fee: float = raw_usd * TRADING_FEE_PCT
	var net_invested: float = raw_usd - fee
	var coins_bought: float = net_invested / price

	player_data.debit_funds(usd_int)

	var wallet: Dictionary = player_data.get("crypto_wallet")
	var coins: Dictionary = wallet.get("coins", {})
	var h: Dictionary = coins.get(sym, {"amount": 0.0, "cost_basis": 0.0, "total_invested": 0.0})

	var old_amt: float = float(h.get("amount", 0.0))
	var old_invested: float = float(h.get("total_invested", 0.0))

	var new_amt: float = old_amt + coins_bought
	var new_invested: float = old_invested + raw_usd
	var new_basis: float = new_invested / new_amt if new_amt > 0.0 else price

	coins[sym] = {
		"amount": new_amt,
		"cost_basis": new_basis,
		"total_invested": new_invested
	}

	var spec := get_coin_spec(sym)
	var coin_name: String = str(spec.get("name", sym))
	var coin_icon: String = str(spec.get("icon", "🪙"))

	var amt_str: String = "%.4f" % coins_bought if coins_bought < 10.0 else "%.2f" % coins_bought
	var msg := "%s BOUGHT: Purchased %s %s for $%s ($%s network fee included)." % [
		coin_icon, amt_str, sym, _format_num(usd_int), _format_num(int(round(fee)))
	]
	player_data.add_life_log_entry(msg, "finance")

	return {
		"success": true,
		"message": msg,
		"coins_bought": coins_bought
	}


static func sell(player_data: Node, symbol: String, coins_to_sell: Variant) -> Dictionary:
	ensure(player_data)
	var sym := symbol.to_upper()
	var sell_amt: float = float(coins_to_sell)

	if player_data.age < 18:
		return {"success": false, "message": "You must be at least 18 years old to trade."}
	if sell_amt <= 0.000001:
		return {"success": false, "message": "Specify a valid quantity to liquidate."}

	var wallet: Dictionary = player_data.get("crypto_wallet")
	var coins: Dictionary = wallet.get("coins", {})
	var h: Dictionary = coins.get(sym, {"amount": 0.0, "cost_basis": 0.0, "total_invested": 0.0})
	var cur_amt: float = float(h.get("amount", 0.0))

	if cur_amt < sell_amt:
		return {"success": false, "message": "Insufficient balance: You hold %.4f %s." % [cur_amt, sym]}

	var price := get_price(player_data, sym)
	var gross_proceeds: float = sell_amt * price
	var fee: float = gross_proceeds * TRADING_FEE_PCT
	var net_cash: int = int(round(gross_proceeds - fee))

	player_data.money += net_cash

	var rem_amt: float = maxf(0.0, cur_amt - sell_amt)
	var old_invested: float = float(h.get("total_invested", 0.0))
	var portion_sold: float = (sell_amt / cur_amt) if cur_amt > 0.0 else 1.0
	var new_invested: float = maxf(0.0, old_invested * (1.0 - portion_sold))
	var basis: float = (new_invested / rem_amt) if rem_amt > 0.000001 else 0.0

	coins[sym] = {
		"amount": rem_amt if rem_amt > 0.000001 else 0.0,
		"cost_basis": basis,
		"total_invested": new_invested if rem_amt > 0.000001 else 0.0
	}

	var spec := get_coin_spec(sym)
	var coin_icon: String = str(spec.get("icon", "🪙"))
	var amt_str: String = "%.4f" % sell_amt if sell_amt < 10.0 else "%.2f" % sell_amt

	var msg := "%s SOLD: Liquidated %s %s for $%s cash ($%s fee deducted)." % [
		coin_icon, amt_str, sym, _format_num(net_cash), _format_num(int(round(fee)))
	]
	player_data.add_life_log_entry(msg, "finance")

	return {
		"success": true,
		"message": msg,
		"net_cash": net_cash
	}


static func snapp(val: float, decimals: int) -> float:
	var factor := pow(10.0, decimals)
	return round(val * factor) / factor


static func _format_num(val: int) -> String:
	var s := str(val)
	var res := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		count += 1
		if count % 3 == 0 and i > 0:
			res = "," + res
	return res
