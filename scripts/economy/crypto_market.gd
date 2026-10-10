class_name CryptoMarket
extends RefCounted

const TRADING_FEE_PCT: float = 0.005 # 0.5% exchange fee

const COINS: Array[Dictionary] = [
	{
		"symbol": "BTC",
		"name": "PixelBitcoin",
		"icon": "🪙",
		"base_price": 64000.0,
		"min_price": 8000.0,
		"max_price": 450000.0,
		"volatility": 0.35,
		"description": "The foundational decentralized digital gold and benchmark cryptographic reserve asset."
	},
	{
		"symbol": "ETH",
		"name": "EtherPixel",
		"icon": "💎",
		"base_price": 3450.0,
		"min_price": 400.0,
		"max_price": 28000.0,
		"volatility": 0.45,
		"description": "Global smart-contract computation network powering decentralized finance and dApps."
	},
	{
		"symbol": "SOL",
		"name": "SolanaByte",
		"icon": "⚡",
		"base_price": 145.0,
		"min_price": 10.0,
		"max_price": 2500.0,
		"volatility": 0.60,
		"description": "Ultra-fast parallelized blockchain optimized for high-frequency algorithmic liquidity."
	},
	{
		"symbol": "AIX",
		"name": "CyberAI Token",
		"icon": "🤖",
		"base_price": 24.5,
		"min_price": 0.5,
		"max_price": 650.0,
		"volatility": 0.75,
		"description": "Decentralized GPU computing collective token fueling autonomous neural network clusters."
	},
	{
		"symbol": "DOGE",
		"name": "PixelDoge",
		"icon": "🐕",
		"base_price": 0.16,
		"min_price": 0.005,
		"max_price": 8.50,
		"volatility": 0.95,
		"description": "High-volatility community memecoin driven by viral social media cycles and internet hype."
	}
]

const REGIMES: Dictionary = {
	"market_crash": {
		"id": "market_crash",
		"label": "💥 BLACK SWAN LIQUIDATION CASCADE",
		"color": "#ef4444",
		"bg_color": "#450a0a",
		"icon": "💥",
		"desc": "Brutal liquidation cascade! Exchanges halting withdrawals and margin calls wiping out leveraged longs."
	},
	"crypto_winter": {
		"id": "crypto_winter",
		"label": "🐻 CRYPTO WINTER (BEAR MARKET)",
		"color": "#f43f5e",
		"bg_color": "#4c0519",
		"icon": "🐻",
		"desc": "Protracted bear market grinding lower. Low retail liquidity, miner capitulation, and regulatory scrutiny."
	},
	"bull_run": {
		"id": "bull_run",
		"label": "🚀 CRYPTO SUPERCYCLE / HALVING MANIA",
		"color": "#10b981",
		"bg_color": "#022c22",
		"icon": "🚀",
		"desc": "Unstoppable institutional ETF inflows, Bitcoin breaking all-time highs, and euphoria gripping global markets!"
	},
	"altseason": {
		"id": "altseason",
		"label": "⚡ ALTSEASON & MEME COIN FRENZY",
		"color": "#06b6d4",
		"bg_color": "#083344",
		"icon": "⚡",
		"desc": "Capital rotating furiously into Ethereum, Solana, AI tokens, and viral memecoins with parabolic multipliers!"
	},
	"relief_rally": {
		"id": "relief_rally",
		"label": "📈 POST-CRASH SHORT SQUEEZE",
		"color": "#3b82f6",
		"bg_color": "#172554",
		"icon": "📈",
		"desc": "Violent relief bounce after extreme oversold panic. Aggressive whale dip-buying and short liquidations."
	},
	"crab_market": {
		"id": "crab_market",
		"label": "🦀 CRAB CONSOLIDATION",
		"color": "#f59e0b",
		"bg_color": "#451a03",
		"icon": "🦀",
		"desc": "Range-bound sideways chop. Low speculative volume and patient institutional cold-storage accumulation."
	}
}

const TRADER_ARCHETYPES: Array[Dictionary] = [
	{"name": "Apex Crypto Fund", "type": "whale", "cash": 25000000.0, "risk": 0.50},
	{"name": "Sovereign Web3 Treasury", "type": "whale", "cash": 40000000.0, "risk": 0.35},
	{"name": "Citadel Arbitrage HFT", "type": "bot", "cash": 15000000.0, "risk": 0.65},
	{"name": "Solana Sniper Bot #44", "type": "bot", "cash": 4500000.0, "risk": 0.85},
	{"name": "Degen Meme Syndicate", "type": "degen", "cash": 2200000.0, "risk": 0.95},
	{"name": "Pantera Digital Capital", "type": "institution", "cash": 30000000.0, "risk": 0.40},
	{"name": "Antarctic Mining Pool", "type": "miner", "cash": 8000000.0, "risk": 0.30},
	{"name": "Ethereum Staking DAO", "type": "institution", "cash": 18000000.0, "risk": 0.45},
	{"name": "Venture Alpha Fund", "type": "whale", "cash": 12000000.0, "risk": 0.60},
	{"name": "Quant Trend Follower", "type": "bot", "cash": 6000000.0, "risk": 0.70},
	{"name": "Diamond Hands Club", "type": "retail", "cash": 1500000.0, "risk": 0.75},
	{"name": "Cyber Neural Trading AI", "type": "bot", "cash": 9500000.0, "risk": 0.80},
	{"name": "Offshore Liquidity Desk", "type": "institution", "cash": 22000000.0, "risk": 0.55},
	{"name": "Moonshot Capital VIP", "type": "degen", "cash": 3500000.0, "risk": 0.90},
	{"name": "Cold Storage Custody", "type": "whale", "cash": 35000000.0, "risk": 0.25},
	{"name": "Retail Momentum Crowd", "type": "retail", "cash": 2800000.0, "risk": 0.70}
]


static func _resolve_player_data(player_data: Node) -> Node:
	if is_instance_valid(player_data):
		return player_data
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null and tree.root != null and tree.root.has_node("PlayerData"):
		return tree.root.get_node("PlayerData")
	return null


static func get_coin_spec(symbol: String) -> Dictionary:
	for c in COINS:
		if str(c.get("symbol", "")).to_upper() == symbol.to_upper():
			return c
	return {}


static func get_regime(player_data: Node = null) -> String:
	var p := _resolve_player_data(player_data)
	if is_instance_valid(p) and p.get("crypto_wallet") is Dictionary:
		return str(p.get("crypto_wallet").get("regime", "bull_run"))
	return "bull_run"


static func get_sentiment(player_data: Node = null) -> String:
	return get_regime(player_data)


static func get_sentiment_info(player_data: Node = null) -> Dictionary:
	var reg := get_regime(player_data)
	if REGIMES.has(reg):
		return REGIMES[reg]
	return REGIMES["bull_run"]


static func generate_sparkline(history: Array) -> String:
	if history.size() < 2:
		return "▄▄▅"
	var min_val: float = float(history[0])
	var max_val: float = float(history[0])
	for val in history:
		min_val = minf(min_val, float(val))
		max_val = maxf(max_val, float(val))
	var range_val := max_val - min_val
	var chars := [" ", "▂", "▃", "▄", "▅", "▆", "▇", "█"]
	var result := ""
	for val in history:
		if range_val <= 0.000001:
			result += "▄"
		else:
			var idx: int = clampi(int(round(((float(val) - min_val) / range_val) * (chars.size() - 1))), 0, chars.size() - 1)
			result += chars[idx]
	return result


static func get_coins(player_data: Node = null) -> Array[Dictionary]:
	var p := _resolve_player_data(player_data)
	if is_instance_valid(p):
		ensure(p)

	var result: Array[Dictionary] = []
	for c in COINS:
		var sym: String = str(c["symbol"])
		var price: float = float(c["base_price"])
		var delta_pct: float = 0.0
		var hist: Array = []
		var ath: float = price * 1.15
		var atl: float = price * 0.25
		var npc_buys: int = 0
		var npc_sells: int = 0
		var volume_usd: float = 0.0
		var cat_note: String = "Trading actively with normal market volume."

		if is_instance_valid(p) and p.get("crypto_wallet") is Dictionary:
			var wallet: Dictionary = p.get("crypto_wallet")
			var m_dict: Dictionary = wallet.get("market", {})
			if m_dict.has(sym):
				var m: Dictionary = m_dict[sym]
				price = float(m.get("price", price))
				delta_pct = float(m.get("delta_pct", 0.0))
				hist = m.get("history", [])
				ath = float(m.get("all_time_high", price * 1.15))
				atl = float(m.get("all_time_low", price * 0.25))
				npc_buys = int(m.get("npc_buys", 0))
				npc_sells = int(m.get("npc_sells", 0))
				volume_usd = float(m.get("volume_usd", 0.0))
				cat_note = str(m.get("catalyst_note", cat_note))

		var spark: String = generate_sparkline(hist)

		result.append({
			"id": sym.to_lower(),
			"symbol": sym,
			"name": str(c["name"]),
			"icon": str(c["icon"]),
			"price": price,
			"change_pct": delta_pct,
			"sparkline": spark,
			"description": str(c["description"]),
			"history": hist,
			"all_time_high": ath,
			"all_time_low": atl,
			"npc_buys": npc_buys,
			"npc_sells": npc_sells,
			"volume_usd": volume_usd,
			"catalyst_note": cat_note
		})
	return result


static func get_recent_trades(player_data: Node = null) -> Array:
	var p := _resolve_player_data(player_data)
	if is_instance_valid(p) and p.get("crypto_wallet") is Dictionary:
		return p.get("crypto_wallet").get("recent_trades", [])
	return []


static func get_news(player_data: Node = null) -> Array:
	var p := _resolve_player_data(player_data)
	if is_instance_valid(p) and p.get("crypto_wallet") is Dictionary:
		return p.get("crypto_wallet").get("news", [])
	return []


static func ensure(player_data: Node) -> void:
	if not is_instance_valid(player_data):
		return
	if not player_data.get("crypto_wallet") is Dictionary:
		player_data.set("crypto_wallet", {})

	var wallet: Dictionary = player_data.get("crypto_wallet")
	if not wallet.has("coins") or not wallet["coins"] is Dictionary:
		wallet["coins"] = {}
	if not wallet.has("market") or not wallet["market"] is Dictionary:
		wallet["market"] = {}
	if not wallet.has("traders") or not (wallet["traders"] is Array) or wallet["traders"].is_empty():
		wallet["traders"] = TRADER_ARCHETYPES.duplicate(true)
	if not wallet.has("recent_trades") or not (wallet["recent_trades"] is Array):
		wallet["recent_trades"] = []
	if not wallet.has("news") or not (wallet["news"] is Array):
		wallet["news"] = []
	if not wallet.has("regime"):
		wallet["regime"] = "bull_run"
	if not wallet.has("regime_years"):
		wallet["regime_years"] = 1
	if not wallet.has("last_age"):
		wallet["last_age"] = player_data.age

	var coins_dict: Dictionary = wallet["coins"]
	var market_dict: Dictionary = wallet["market"]

	# Default initial believable price points and sparkline variations so market is never static 0.00%
	var initial_presets := {
		"BTC": {"price": 67840.0, "delta": 6.0, "hist": [52000.0, 56400.0, 61200.0, 59800.0, 64000.0, 67840.0], "ath": 73750.0, "atl": 15476.0, "note": "🚀 Spot ETF inflows and sovereign reserves driving premium."},
		"ETH": {"price": 3622.5, "delta": 5.0, "hist": [2800.0, 3100.0, 3350.0, 3200.0, 3450.0, 3622.5], "ath": 4891.0, "atl": 881.0, "note": "💎 Layer-2 network activity and fee burn accelerating."},
		"SOL": {"price": 162.4, "delta": 12.0, "hist": [98.0, 115.0, 132.0, 128.0, 145.0, 162.4], "ath": 259.0, "atl": 8.14, "note": "⚡ High-throughput DEX trading volume outperforming peers."},
		"AIX": {"price": 28.91, "delta": 18.0, "hist": [14.2, 17.5, 21.0, 19.8, 24.5, 28.91], "ath": 42.0, "atl": 1.20, "note": "🤖 Decentralized GPU computing cluster demand surging."},
		"DOGE": {"price": 0.1824, "delta": 14.0, "hist": [0.095, 0.118, 0.135, 0.128, 0.160, 0.1824], "ath": 0.737, "atl": 0.002, "note": "🐕 Viral social media momentum and community accumulation."}
	}

	for c in COINS:
		var sym: String = str(c["symbol"])
		if not coins_dict.has(sym):
			coins_dict[sym] = {
				"amount": 0.0,
				"cost_basis": 0.0,
				"total_invested": 0.0
			}

		var preset: Dictionary = initial_presets.get(sym, {})
		var default_p: float = float(preset.get("price", c["base_price"]))
		var default_d: float = float(preset.get("delta", 5.0))
		var default_h: Array = preset.get("hist", [default_p * 0.9, default_p])

		if not market_dict.has(sym):
			market_dict[sym] = {
				"price": default_p,
				"delta_pct": default_d,
				"history": default_h,
				"all_time_high": float(preset.get("ath", default_p * 1.15)),
				"all_time_low": float(preset.get("atl", default_p * 0.25)),
				"npc_buys": randi_range(250, 1200),
				"npc_sells": randi_range(150, 800),
				"volume_usd": default_p * randf_range(500.0, 3500.0),
				"catalyst_note": str(preset.get("note", "Trading actively on spot exchange."))
			}
		else:
			var m: Dictionary = market_dict[sym]
			if not m.has("all_time_high"):
				m["all_time_high"] = float(preset.get("ath", float(m.get("price", default_p)) * 1.15))
			if not m.has("all_time_low"):
				m["all_time_low"] = float(preset.get("atl", float(m.get("price", default_p)) * 0.25))
			if not m.has("npc_buys"):
				m["npc_buys"] = randi_range(250, 1200)
			if not m.has("npc_sells"):
				m["npc_sells"] = randi_range(150, 800)
			if not m.has("volume_usd"):
				m["volume_usd"] = float(m.get("price", default_p)) * randf_range(500.0, 3500.0)
			if not m.has("catalyst_note"):
				m["catalyst_note"] = str(preset.get("note", "Trading actively on spot exchange."))
			if float(m.get("delta_pct", 0.0)) == 0.0 and m.get("history", []).size() <= 3:
				m["price"] = default_p
				m["delta_pct"] = default_d
				m["history"] = default_h

	if wallet["recent_trades"].is_empty():
		wallet["recent_trades"] = [
			{"trader": "Apex Crypto Fund", "action": "BUY", "amount_str": "14.2 BTC", "usd_str": "$963,328", "symbol": "BTC", "icon": "🪙", "timestamp_str": "Just now"},
			{"trader": "Degen Meme Syndicate", "action": "BUY", "amount_str": "450,000 DOGE", "usd_str": "$82,080", "symbol": "DOGE", "icon": "🐕", "timestamp_str": "1m ago"},
			{"trader": "Citadel Arbitrage HFT", "action": "SELL", "amount_str": "650 SOL", "usd_str": "$105,560", "symbol": "SOL", "icon": "⚡", "timestamp_str": "2m ago"},
			{"trader": "Cyber Neural Trading AI", "action": "BUY", "amount_str": "8,500 AIX", "usd_str": "$245,735", "symbol": "AIX", "icon": "🤖", "timestamp_str": "4m ago"},
			{"trader": "Pantera Digital Capital", "action": "BUY", "amount_str": "320 ETH", "usd_str": "$1,159,200", "symbol": "ETH", "icon": "💎", "timestamp_str": "5m ago"}
		]

	if wallet["news"].is_empty():
		wallet["news"] = [
			"🚀 CRYPTO SUPERCYCLE: Institutional ETF accumulation fuels broad market momentum as Bitcoin crosses $67,000!"
		]


static func tick_live_market(player_data: Node) -> void:
	var p := _resolve_player_data(player_data)
	if not is_instance_valid(p):
		return
	ensure(p)

	var wallet: Dictionary = p.get("crypto_wallet")
	var market_dict: Dictionary = wallet.get("market", {})
	var traders: Array = wallet.get("traders", [])

	for c in COINS:
		var sym: String = str(c["symbol"])
		if not market_dict.has(sym):
			continue
		var m: Dictionary = market_dict[sym]
		var cur_p: float = float(m.get("price", c["base_price"]))
		var vol: float = float(c["volatility"])

		# Micro live tick between -3.0% and +3.5%
		var micro_move: float = randf_range(-0.025, 0.030) * (vol / 0.35)
		var new_p := snapp(cur_p * (1.0 + micro_move), 2 if cur_p > 1.0 else 4)
		new_p = clampf(new_p, float(c["min_price"]), float(c["max_price"]))
		m["price"] = new_p

		var ath: float = float(m.get("all_time_high", new_p))
		var atl: float = float(m.get("all_time_low", new_p))
		m["all_time_high"] = maxf(ath, new_p)
		m["all_time_low"] = minf(atl, new_p)

		var hist: Array = m.get("history", [])
		if not hist.is_empty():
			hist[-1] = new_p
			var first_p := float(hist[0])
			if first_p > 0:
				m["delta_pct"] = snapp(((new_p - first_p) / first_p) * 100.0, 2)
		m["history"] = hist

	# Execute 1-3 live NPC micro orders to show in order flow
	var recent_trades: Array = wallet.get("recent_trades", [])
	var num_trades := randi_range(1, 3)
	for i in range(num_trades):
		var coin_pick: Dictionary = COINS.pick_random()
		var sym: String = str(coin_pick["symbol"])
		var m: Dictionary = market_dict.get(sym, {})
		var p_val: float = float(m.get("price", coin_pick["base_price"]))

		var trader_name := "Whale #%02d" % randi_range(1, 16)
		if not traders.is_empty():
			var t_info: Dictionary = traders.pick_random()
			trader_name = str(t_info.get("name", trader_name))

		var is_buy := randf() < 0.55
		var usd_amt := randf_range(15000.0, 380000.0)
		var coin_qty := usd_amt / maxf(0.001, p_val)
		var qty_str := "%.4f %s" % [coin_qty, sym] if coin_qty < 10.0 else "%s %s" % [_format_num(int(round(coin_qty))), sym]

		recent_trades.push_front({
			"trader": trader_name,
			"action": "BUY" if is_buy else "SELL",
			"amount_str": qty_str,
			"usd_str": "$%s" % _format_num(int(round(usd_amt))),
			"symbol": sym,
			"icon": str(coin_pick["icon"]),
			"timestamp_str": "Just now"
		})
		while recent_trades.size() > 8:
			recent_trades.pop_back()

		if is_buy:
			m["npc_buys"] = int(m.get("npc_buys", 0)) + int(maxi(1, int(round(coin_qty))))
		else:
			m["npc_sells"] = int(m.get("npc_sells", 0)) + int(maxi(1, int(round(coin_qty))))
		m["volume_usd"] = float(m.get("volume_usd", 0.0)) + usd_amt


static func advance_year(player_data: Node) -> Array[String]:
	var p := _resolve_player_data(player_data)
	if not is_instance_valid(p):
		return []
	ensure(p)

	var wallet: Dictionary = p.get("crypto_wallet")
	var last_age: int = int(wallet.get("last_age", p.age))
	if last_age >= p.age:
		return []

	wallet["last_age"] = p.age
	var market_dict: Dictionary = wallet["market"]
	var traders: Array = wallet.get("traders", [])

	# 1. Macro Regime Transitions (Just like real life crypto cycles!)
	var cur_regime: String = str(wallet.get("regime", "bull_run"))
	var years_in_regime: int = int(wallet.get("regime_years", 1))
	var new_regime := cur_regime
	var roll := randf()

	match cur_regime:
		"market_crash":
			# Crashes are brutal and swift (1 year). 60% post-crash relief rally, 40% slides into crypto winter.
			new_regime = "relief_rally" if roll < 0.60 else "crypto_winter"
		"bull_run":
			# Bull runs peak after 1-2 years. 25% blow-off crash, 40% altseason, 35% crab consolidation.
			if years_in_regime >= 2 and roll < 0.65:
				if roll < 0.25:
					new_regime = "market_crash"
				elif roll < 0.50:
					new_regime = "altseason"
				else:
					new_regime = "crab_market"
		"altseason":
			# Altseasons are explosive and fast (1 year). Euphoria usually pops into crash or winter.
			if roll < 0.45:
				new_regime = "market_crash"
			elif roll < 0.72:
				new_regime = "crypto_winter"
			else:
				new_regime = "crab_market"
		"crypto_winter":
			# Bear markets bleed. After 2 years, accumulation or relief breakout.
			if years_in_regime >= 2 and roll < 0.55:
				new_regime = "relief_rally" if roll < 0.50 else "crab_market"
		"relief_rally":
			# Bounces either ignite a fresh bull run or consolidate into crab.
			new_regime = "bull_run" if roll < 0.55 else "crab_market"
		_: # crab_market
			if roll < 0.50:
				if roll < 0.30:
					new_regime = "bull_run"
				elif roll < 0.42:
					new_regime = "altseason"
				else:
					new_regime = "crypto_winter"

	if new_regime != cur_regime:
		wallet["regime"] = new_regime
		wallet["regime_years"] = 1
	else:
		wallet["regime_years"] = years_in_regime + 1

	var reg_info: Dictionary = REGIMES.get(str(wallet["regime"]), REGIMES["bull_run"])

	# 2. Economy Macro Baseline Return per Regime
	var macro_bias := 0.0
	match str(wallet["regime"]):
		"market_crash":
			macro_bias = randf_range(-0.62, -0.42)
		"crypto_winter":
			macro_bias = randf_range(-0.38, -0.18)
		"bull_run":
			macro_bias = randf_range(0.55, 1.25)
		"altseason":
			macro_bias = randf_range(0.40, 0.90)
		"relief_rally":
			macro_bias = randf_range(0.28, 0.65)
		_: # crab_market
			macro_bias = randf_range(-0.08, 0.12)

	var logs: Array[String] = []
	var total_portfolio_before := portfolio_value(p)
	var total_pct_moves := 0.0
	var top_gainer := ""
	var top_gainer_pct := -999.0
	var top_loser := ""
	var top_loser_pct := 999.0

	var catalyst_news_pool := {
		"BTC": [
			"🚀 Institutional spot ETF inflows hit record $2.4B in a single week; sovereign reserves accumulate!",
			"💥 Major offshore exchange halts customer withdrawals amidst liquidity crisis; Bitcoin dumps.",
			"⚡ Lightning Network payment volume sets all-time high as global merchant adoption accelerates.",
			"🐻 Mining difficulty spike triggers unprofitable miner capitulation and heavy spot selloff."
		],
		"ETH": [
			"💎 Layer-2 smart contract networks burn 85,000 ETH in fees; network supply enters deflationary regime!",
			"💥 Severe cross-chain bridge exploit drains $150M from leading DeFi protocols.",
			"🚀 Global financial institution settles multi-billion bond issuance directly on EtherPixel mainnet.",
			"🐻 Staking yield contraction and competitor migration cool Ethereum validator inflows."
		],
		"SOL": [
			"⚡ Solana DEX trading volume surges 400%, temporarily flipping traditional finance payment rails!",
			"💥 Network congestion during viral memecoin launch causes temporary transaction drops.",
			"🚀 Major smartphone manufacturer integrates native SolanaByte hardware wallet.",
			"🐻 High-frequency liquidation cascade triggers sudden -45% spot crash."
		],
		"AIX": [
			"🤖 Decentralized GPU computing network signs multi-million compute cluster training contract!",
			"💥 Open-source foundation warns of compute oversupply; GPU token valuations reprice downward.",
			"🚀 Autonomous AI agent swarm achieves profitable on-chain treasury management via AIX.",
			"🐻 Tech sector regulatory inquiries cool speculative artificial intelligence tokens."
		],
		"DOGE": [
			"🐕 Viral celebrity post and space mission sponsorship trigger a frenzied 5x trading volume spike!",
			"💥 Memecoin hype cycle exhausts liquidity; retail speculators dump holdings.",
			"🚀 Major social platform announces native tips and payments in PixelDoge!",
			"🐻 Speculative degen capital rotates out of memecoins into Bitcoin and stablecoins."
		]
	}

	# 3. Simulate Coin Price Movements & Background NPC Trading Activity
	for c in COINS:
		var sym: String = str(c["symbol"])
		var m_data: Dictionary = market_dict.get(sym, {})
		var cur_price: float = float(m_data.get("price", c["base_price"]))
		var vol: float = float(c["volatility"])

		# Sector / Altcoin beta multiplier
		var beta := 1.0
		if str(wallet["regime"]) == "altseason":
			match sym:
				"BTC": beta = 0.35
				"ETH": beta = 1.25
				"SOL": beta = 1.70
				"AIX": beta = 2.10
				"DOGE": beta = 2.60
		elif str(wallet["regime"]) == "market_crash":
			match sym:
				"BTC": beta = 1.0
				"ETH": beta = 1.15
				"SOL": beta = 1.30
				"AIX": beta = 1.45
				"DOGE": beta = 1.60

		# Background NPC Trading Activity
		var npc_buys := 0
		var npc_sells := 0
		var volume_usd := 0.0

		for trader in traders:
			var risk: float = float(trader.get("risk", 0.5))
			var demand: float = clampf(0.5 + macro_bias * 0.7 + (risk - 0.5) * 0.3 + randf_range(-0.15, 0.15), 0.05, 0.95)
			var trade_usd: float = randf_range(25000.0, 750000.0) * risk
			var trade_qty: float = trade_usd / maxf(0.001, cur_price)

			if randf() < demand:
				npc_buys += int(maxi(1, int(round(trade_qty))))
				volume_usd += trade_usd
				if randf() < 0.10:
					wallet["recent_trades"].push_front({
						"trader": str(trader.get("name", "Whale")),
						"action": "BUY",
						"amount_str": "%.4f %s" % [trade_qty, sym] if trade_qty < 10.0 else "%s %s" % [_format_num(int(round(trade_qty))), sym],
						"usd_str": "$%s" % _format_num(int(round(trade_usd))),
						"symbol": sym,
						"icon": str(c["icon"]),
						"timestamp_str": "Age %d" % p.age
					})
			else:
				npc_sells += int(maxi(1, int(round(trade_qty))))
				volume_usd += trade_usd
				if randf() < 0.10:
					wallet["recent_trades"].push_front({
						"trader": str(trader.get("name", "Whale")),
						"action": "SELL",
						"amount_str": "%.4f %s" % [trade_qty, sym] if trade_qty < 10.0 else "%s %s" % [_format_num(int(round(trade_qty))), sym],
						"usd_str": "$%s" % _format_num(int(round(trade_usd))),
						"symbol": sym,
						"icon": str(c["icon"]),
						"timestamp_str": "Age %d" % p.age
					})

		while wallet["recent_trades"].size() > 8:
			wallet["recent_trades"].pop_back()

		# Order flow pressure
		var total_flow := maxi(1, npc_buys + npc_sells)
		var order_pressure: float = float(npc_buys - npc_sells) / float(total_flow)

		# Catalyst Note
		var cat_note: String = "Trading actively with normal market volume."
		var cat_move := 0.0
		if randf() < 0.35 and catalyst_news_pool.has(sym):
			var pool: Array = catalyst_news_pool[sym]
			cat_note = pool.pick_random()
			cat_move = randf_range(0.20, 0.60) * (vol / 0.35) if cat_note.begins_with("🚀") or cat_note.begins_with("⚡") or cat_note.begins_with("💎") or cat_note.begins_with("🐕") else -randf_range(0.20, 0.50) * (vol / 0.35)

		# Final price movement computation
		var move: float = macro_bias * beta + order_pressure * 0.20 + cat_move + randf_range(-0.08, 0.08)
		# Realistic crypto bounds: crashes down to -88%, rallies up to +550%
		move = clampf(move, -0.88, 5.50)

		var new_price := snapp(cur_price * (1.0 + move), 2 if cur_price > 1.0 else 4)
		new_price = clampf(new_price, float(c["min_price"]), float(c["max_price"]))
		var actual_delta_pct: float = ((new_price - cur_price) / maxf(0.0001, cur_price)) * 100.0

		var hist: Array = m_data.get("history", [])
		hist.append(new_price)
		while hist.size() > 8:
			hist.pop_front()

		var ath: float = maxf(float(m_data.get("all_time_high", new_price)), new_price)
		var atl: float = minf(float(m_data.get("all_time_low", new_price)), new_price)

		market_dict[sym] = {
			"price": new_price,
			"delta_pct": snapp(actual_delta_pct, 2),
			"history": hist,
			"all_time_high": ath,
			"all_time_low": atl,
			"npc_buys": npc_buys,
			"npc_sells": npc_sells,
			"volume_usd": volume_usd,
			"catalyst_note": cat_note
		}

		total_pct_moves += actual_delta_pct
		if actual_delta_pct > top_gainer_pct:
			top_gainer_pct = actual_delta_pct
			top_gainer = str(c["name"])
		if actual_delta_pct < top_loser_pct:
			top_loser_pct = actual_delta_pct
			top_loser = str(c["name"])

	# 4. Generate Crypto Wire Headlines
	var avg_crypto_move := total_pct_moves / maxf(1.0, float(COINS.size()))
	var headline := ""
	match str(wallet["regime"]):
		"market_crash":
			headline = "💥 BLACK SWAN CRASH: Cascading liquidations across decentralized exchanges triggered a brutal -%.1f%% collapse in digital assets!" % absf(avg_crypto_move)
		"crypto_winter":
			headline = "🐻 CRYPTO WINTER: Depressed retail liquidity and aggressive global regulatory scrutiny drove digital assets down -%.1f%%." % absf(avg_crypto_move)
		"bull_run":
			headline = "🚀 CRYPTO SUPERCYCLE: Spot ETF frenzy and supply halving drove the crypto market up +%.1f%% to record all-time highs!" % avg_crypto_move
		"altseason":
			headline = "⚡ ALTSEASON EXPLOSION: Speculative capital rotated aggressively into Solana, AI tokens, and meme coins (+%.1f%% average surge)!" % avg_crypto_move
		"relief_rally":
			headline = "📈 CRYPTO RELIEF RALLY: High-volume short squeezes and aggressive whale accumulation sparked a +%.1f%% bounce across the market!" % avg_crypto_move
		_:
			headline = "🦀 CRAB CONSOLIDATION: Cryptocurrency markets moved sideways range-bound (%+.1f%%) in low-volatility accumulation." % avg_crypto_move

	wallet["news"].clear()
	wallet["news"].append(headline)
	logs.append(headline)

	if top_gainer_pct > 25.0:
		var g_msg := "🏆 TOP CRYPTO GAINER: %s skyrocketed +%.1f%% this year!" % [top_gainer, top_gainer_pct]
		wallet["news"].append(g_msg)
	if top_loser_pct < -25.0:
		var l_msg := "⚠️ BIGGEST DIP: %s tumbled %.1f%% amid market deleveraging!" % [top_loser, top_loser_pct]
		wallet["news"].append(l_msg)

	# 5. Portfolio performance log for player
	var total_portfolio_after := portfolio_value(p)
	if total_portfolio_before > 0:
		var diff := total_portfolio_after - total_portfolio_before
		var pct := (float(diff) / float(total_portfolio_before)) * 100.0
		if diff > 1000:
			logs.append("🪙 CRYPTO WALLET: Your cryptocurrency holdings gained +$%s (+%.1f%%) during the %s!" % [
				_format_num(diff), pct, reg_info.get("label", "market cycle")
			])
		elif diff < -1000:
			logs.append("🪙 CRYPTO WALLET: Holdings contracted by -$%s (%.1f%%) amid market downturn." % [
				_format_num(abs(diff)), pct
			])

	return logs


static func get_price(player_data: Node, symbol: String) -> float:
	var p := _resolve_player_data(player_data)
	if is_instance_valid(p):
		ensure(p)
		var sym := symbol.to_upper()
		var wallet: Dictionary = p.get("crypto_wallet")
		var m: Dictionary = wallet.get("market", {})
		if m.has(sym):
			return float(m[sym].get("price", 0.0))
	var spec := get_coin_spec(symbol)
	return float(spec.get("base_price", 0.0))


static func get_holding(player_data: Node, symbol: String) -> Dictionary:
	var p := _resolve_player_data(player_data)
	if not is_instance_valid(p):
		return {"amount": 0.0, "cost_basis": 0.0, "invested": 0.0, "total_invested": 0.0}
	ensure(p)
	var sym := symbol.to_upper()
	var wallet: Dictionary = p.get("crypto_wallet")
	var coins: Dictionary = wallet.get("coins", {})
	var h: Dictionary = coins.get(sym, {"amount": 0.0, "cost_basis": 0.0, "total_invested": 0.0})
	return {
		"amount": float(h.get("amount", 0.0)),
		"cost_basis": float(h.get("cost_basis", 0.0)),
		"invested": float(h.get("total_invested", 0.0)),
		"total_invested": float(h.get("total_invested", 0.0))
	}


static func portfolio_value(player_data: Node) -> int:
	var p := _resolve_player_data(player_data)
	if not is_instance_valid(p):
		return 0
	ensure(p)
	var wallet: Dictionary = p.get("crypto_wallet")
	var coins: Dictionary = wallet.get("coins", {})
	var total: float = 0.0

	for sym in coins:
		var holding: Dictionary = coins[sym]
		var amt: float = float(holding.get("amount", 0.0))
		if amt > 0.0:
			var price := get_price(p, sym)
			total += amt * price

	return int(round(total))


static func portfolio_pnl(player_data: Node) -> Dictionary:
	var p := _resolve_player_data(player_data)
	if not is_instance_valid(p):
		return {
			"current_value": 0, "current": 0.0, "total_cost": 0,
			"invested": 0.0, "net_gain": 0, "pnl": 0.0, "gain_pct": 0.0, "pnl_pct": 0.0
		}
	ensure(p)
	var wallet: Dictionary = p.get("crypto_wallet")
	var coins: Dictionary = wallet.get("coins", {})
	var total_cost: float = 0.0
	var total_current: float = 0.0

	for sym in coins:
		var h: Dictionary = coins[sym]
		var amt: float = float(h.get("amount", 0.0))
		if amt > 0.0:
			total_cost += float(h.get("total_invested", 0.0))
			total_current += amt * get_price(p, sym)

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
	var p := _resolve_player_data(player_data)
	if not is_instance_valid(p):
		return {"success": false, "message": "Player unavailable."}
	ensure(p)
	var sym := symbol.to_upper()
	var raw_usd: float = float(usd_amount)
	var usd_int: int = int(round(raw_usd))

	if p.age < 18:
		return {"success": false, "message": "Crypto Exchange Regulations: You must be at least 18 years old to trade digital assets."}
	if p.is_in_prison or p.is_dead:
		return {"success": false, "message": "Cannot trade while incarcerated or deceased."}
	if usd_int <= 0:
		return {"success": false, "message": "Enter a valid dollar amount to invest."}

	var avail: int = p.money + p.bank_savings
	if avail < usd_int:
		return {"success": false, "message": "Insufficient funds: You have $%s available (Requested: $%s)." % [_format_num(avail), _format_num(usd_int)]}

	var price := get_price(p, sym)
	if price <= 0.0:
		return {"success": false, "message": "Market unavailable."}

	var fee: float = raw_usd * TRADING_FEE_PCT
	var net_invested: float = raw_usd - fee
	var coins_bought: float = net_invested / price

	p.debit_funds(usd_int)

	var wallet: Dictionary = p.get("crypto_wallet")
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

	# Record in live order book
	var recent_trades: Array = wallet.get("recent_trades", [])
	recent_trades.push_front({
		"trader": "%s (Player)" % str(p.first_name),
		"action": "BUY",
		"amount_str": "%.4f %s" % [coins_bought, sym] if coins_bought < 10.0 else "%s %s" % [_format_num(int(round(coins_bought))), sym],
		"usd_str": "$%s" % _format_num(usd_int),
		"symbol": sym,
		"icon": "🟢",
		"timestamp_str": "Just now"
	})
	while recent_trades.size() > 8:
		recent_trades.pop_back()

	var spec := get_coin_spec(sym)
	var coin_icon: String = str(spec.get("icon", "🪙"))

	var amt_str: String = "%.4f" % coins_bought if coins_bought < 10.0 else "%.2f" % coins_bought
	var msg := "%s BOUGHT: Purchased %s %s for $%s ($%s network fee included)." % [
		coin_icon, amt_str, sym, _format_num(usd_int), _format_num(int(round(fee)))
	]
	p.add_life_log_entry(msg, "finance")

	return {
		"success": true,
		"message": msg,
		"coins_bought": coins_bought
	}


static func sell(player_data: Node, symbol: String, coins_to_sell: Variant) -> Dictionary:
	var p := _resolve_player_data(player_data)
	if not is_instance_valid(p):
		return {"success": false, "message": "Player unavailable."}
	ensure(p)
	var sym := symbol.to_upper()
	var sell_amt: float = float(coins_to_sell)

	if p.age < 18:
		return {"success": false, "message": "You must be at least 18 years old to trade."}
	if sell_amt <= 0.000001:
		return {"success": false, "message": "Specify a valid quantity to liquidate."}

	var wallet: Dictionary = p.get("crypto_wallet")
	var coins: Dictionary = wallet.get("coins", {})
	var h: Dictionary = coins.get(sym, {"amount": 0.0, "cost_basis": 0.0, "total_invested": 0.0})
	var cur_amt: float = float(h.get("amount", 0.0))

	if cur_amt < sell_amt:
		return {"success": false, "message": "Insufficient balance: You hold %.4f %s." % [cur_amt, sym]}

	var price := get_price(p, sym)
	var gross_proceeds: float = sell_amt * price
	var fee: float = gross_proceeds * TRADING_FEE_PCT
	var net_cash: int = int(round(gross_proceeds - fee))

	p.money += net_cash

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

	# Record in live order book
	var recent_trades: Array = wallet.get("recent_trades", [])
	recent_trades.push_front({
		"trader": "%s (Player)" % str(p.first_name),
		"action": "SELL",
		"amount_str": "%.4f %s" % [sell_amt, sym] if sell_amt < 10.0 else "%s %s" % [_format_num(int(round(sell_amt))), sym],
		"usd_str": "$%s" % _format_num(net_cash),
		"symbol": sym,
		"icon": "🔴",
		"timestamp_str": "Just now"
	})
	while recent_trades.size() > 8:
		recent_trades.pop_back()

	var spec := get_coin_spec(sym)
	var coin_icon: String = str(spec.get("icon", "🪙"))
	var amt_str: String = "%.4f" % sell_amt if sell_amt < 10.0 else "%.2f" % sell_amt

	var msg := "%s SOLD: Liquidated %s %s for $%s cash ($%s fee deducted)." % [
		coin_icon, amt_str, sym, _format_num(net_cash), _format_num(int(round(fee)))
	]
	p.add_life_log_entry(msg, "finance")

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
