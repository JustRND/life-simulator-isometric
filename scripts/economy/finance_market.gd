class_name FinanceMarket
extends RefCounted

# 24 reusable business archetypes. Every reopening gets a new issuer ID and owner.
const SECTORS = ["Robotics", "Solar", "Logistics", "Coffee", "Software", "Biotech", "Fashion", "Architecture", "Audio", "Accounting", "Dental", "Medicine", "Cloud", "Batteries", "Freight", "Food", "Games", "Genomics", "Textiles", "Housing", "Media", "Analytics", "Wellness", "Diagnostics"]
const PREFIXES = ["Aurora", "Cedar", "Atlas", "Neon", "Lotus", "Orion", "Pixel", "Summit", "Terra", "Nova", "Silver", "Horizon", "Cobalt", "Willow", "Vega", "Maple", "Coral", "Amber", "River", "Lunar", "Pine", "Prism", "Echo", "Bright"]
const TYPE_IDS = ["engineering_workshop", "clean_energy", "wholesaler", "coffee_shop", "software_studio", "biotech_lab", "clothing_store", "architecture_studio", "music_studio", "accounting_firm", "dental_practice", "medical_clinic", "software_studio", "clean_energy", "wholesaler", "coffee_shop", "software_studio", "biotech_lab", "clothing_store", "architecture_studio", "film_studio", "accounting_firm", "medical_clinic", "biotech_lab"]

# Sector volatility categories (high beta tech/speculation vs defensive income)
const HIGH_BETA_SECTORS = ["Robotics", "Biotech", "Software", "Cloud", "Batteries", "Games", "Genomics", "Analytics"]
const DEFENSIVE_SECTORS = ["Accounting", "Dental", "Medicine", "Housing", "Freight", "Textiles", "Food"]

const SHARES := 100000
const FLOAT := 20000
const MAX_ACTIVE := 8
const FEE := 0.01


static func get_sector_volatility(sector_name: String) -> float:
	if sector_name in HIGH_BETA_SECTORS:
		return 0.60
	elif sector_name in DEFENSIVE_SECTORS:
		return 0.22
	return 0.38


static func ensure(p: Node) -> void:
	if p.finance_market.is_empty():
		p.finance_market = {
			"issuers": [],
			"holdings": {},
			"history": [],
			"news": [],
			"traders": [],
			"last_age": p.age,
			"serial": 0,
			"realized": 0,
			"cash_flow": 0,
			"regime": "bull_run",
			"regime_years": 1,
			"avg_change": 14.5
		}
		for i in range(16):
			p.finance_market.traders.append({"cash": 5000000.0, "positions": {}})
	if not p.finance_market.has("regime"):
		p.finance_market["regime"] = "bull_run"
		p.finance_market["regime_years"] = 1
		p.finance_market["avg_change"] = 14.5

	# Self-heal: ensure every holding has an issuer entry and all companies have rich dynamic fields
	for uid in p.finance_market.get("holdings", {}):
		if issuer(p, uid).is_empty():
			var pos: Dictionary = p.finance_market.holdings[uid]
			var fallback_company := {
				"uid": uid, "archetype": -1, "name": str(pos.get("name", "Asset " + uid)),
				"owner": "Public", "country": "United States", "type_id": "", "active": false,
				"price": float(pos.get("price", 10.0)), "previous": float(pos.get("price", 10.0)),
				"available": 0, "npc_buys": 0, "npc_sells": 0, "performance": 0.0,
				"business_uid": "", "opened_age": p.age,
				"volatility": 0.35, "history": [float(pos.get("price", 10.0))],
				"all_time_high": float(pos.get("price", 10.0)), "all_time_low": float(pos.get("price", 10.0)),
				"event_note": "Legacy portfolio holding."
			}
			p.finance_market.issuers.append(fallback_company)

	for c in p.finance_market.get("issuers", []):
		var arch: int = int(c.get("archetype", 0))
		var sec_name: String = SECTORS[arch] if (arch >= 0 and arch < SECTORS.size()) else "General"
		if not c.has("volatility"):
			c["volatility"] = get_sector_volatility(sec_name)
		if not c.has("history") or not (c["history"] is Array) or c["history"].is_empty():
			var p_now: float = float(c.get("price", 25.0))
			c["history"] = [snappedf(p_now * 0.9, 0.01), snappedf(p_now * 0.96, 0.01), p_now]
		if not c.has("all_time_high"):
			c["all_time_high"] = float(c.get("price", 25.0))
		if not c.has("all_time_low"):
			c["all_time_low"] = float(c.get("price", 25.0))
		if not c.has("event_note"):
			c["event_note"] = "Trading actively on the public exchange."

	_fill(p)
	if p.finance_market.history.is_empty():
		record(p)


static func active(p: Node) -> Array:
	var result: Array = []
	for company in p.finance_market.get("issuers", []):
		if bool(company.get("active", false)):
			result.append(company)
	return result


static func issuer(p: Node, uid: String) -> Dictionary:
	for company in p.finance_market.get("issuers", []):
		if company.uid == uid:
			return company
	return {}


static func _fill(p: Node) -> void:
	while active(p).size() < MAX_ACTIVE:
		var available: Array = range(24)
		for company in active(p):
			available.erase(int(company.get("archetype", -1)))
		_open(p, available.pick_random())


static func _open(p: Node, archetype: int) -> Dictionary:
	p.finance_market.serial = int(p.finance_market.serial) + 1
	var def: Dictionary = BusinessManager.get_business_type_by_id("biz_" + str(TYPE_IDS[archetype]))
	var country: String = preload("res://scripts/core/creation_options.gd").COUNTRIES.pick_random()[0]
	var price := snappedf(randf_range(8.0, 65.0), 0.01)
	var sec_name: String = str(SECTORS[archetype])
	var vol: float = get_sector_volatility(sec_name)
	var company := {
		"uid": "market_%d" % int(p.finance_market.serial),
		"archetype": archetype,
		"sector": sec_name,
		"name": "%s %s %s" % [PREFIXES.pick_random(), sec_name, ["Group", "Works", "Industries", "Partners", "Holdings"].pick_random()],
		"owner": preload("res://scripts/core/name_catalog.gd").random_name(country, randf() < 0.5),
		"country": country,
		"type_id": str(def.id),
		"active": true,
		"price": price,
		"previous": price,
		"available": FLOAT,
		"npc_buys": 0,
		"npc_sells": 0,
		"performance": 0.0,
		"business_uid": "",
		"opened_age": p.age,
		"volatility": vol,
		"history": [snappedf(price * randf_range(0.86, 1.14), 0.01), snappedf(price * randf_range(0.92, 1.08), 0.01), price],
		"all_time_high": price,
		"all_time_low": price,
		"event_note": "Initial Public Offering (IPO) successfully launched."
	}
	p.finance_market.issuers.append(company)
	# Seed real NPC positions so both buying and selling occur from the first year.
	for trader in p.finance_market.traders:
		var initial := mini(400, maxi(0, int(float(trader.cash) / price)))
		trader.positions[company.uid] = initial
		trader.cash = float(trader.cash) - initial * price
		company.available = int(company.available) - initial
	return company


static func portfolio_value(p: Node) -> int:
	var total := 0.0
	for uid in p.finance_market.get("holdings", {}):
		var company := issuer(p, uid)
		var price: float = float(company.get("price", 0.0)) if not company.is_empty() else float(p.finance_market.holdings[uid].get("price", 0.0))
		total += int(p.finance_market.holdings[uid].get("quantity", 0)) * price
	return int(total)


static func record(p: Node) -> void:
	var history: Array = p.finance_market.history
	var point := {"age": p.age, "value": portfolio_value(p), "invested": int(p.finance_market.cash_flow)}
	if not history.is_empty() and int(history[-1].age) == p.age:
		history[-1] = point
	else:
		history.append(point)
	while history.size() > 80:
		history.pop_front()


static func _eligible(p: Node) -> bool:
	return p.has_started_game and p.age >= 18 and not p.is_dead and not p.is_in_prison


static func trade(p: Node, uid: String, quantity: int, buying: bool) -> String:
	ensure(p)
	var c := issuer(p, uid)
	if c.is_empty():
		var pos: Dictionary = p.finance_market.holdings.get(uid, {})
		if not pos.is_empty() and not buying:
			c = {"uid": uid, "name": str(pos.get("name", "Holding " + uid)), "price": float(pos.get("price", 10.0)), "active": false, "available": 0}
	if not _eligible(p) or c.is_empty() or quantity < 1 or (buying and not bool(c.get("active", false))) or (buying and quantity > 10000) or (not buying and quantity > FLOAT):
		return "Trade unavailable. Adults outside prison may trade 1–10,000 shares."
	if not str(c.get("business_uid", "")).is_empty():
		return "Your controlling stake is managed through My Businesses."
	var gross := int(ceil(float(c.price) * quantity)) if buying else int(floor(float(c.price) * quantity))
	var fee := maxi(1, int(ceil(gross * FEE)))
	var holdings: Dictionary = p.finance_market.holdings
	var position: Dictionary = holdings.get(uid, {"quantity": 0, "cost": 0, "name": str(c.name), "price": float(c.price)})
	if buying:
		if quantity > int(c.available):
			return "Exceeds floating shares available on the market."
		if p.bank_savings < gross + fee:
			return "Insufficient bank balance. Shares purchases must be made using bank balance (cash cannot be used)."
		p.bank_savings -= gross + fee
		position.quantity = int(position.quantity) + quantity
		position.cost = int(position.cost) + gross + fee
		position.name = str(c.name)
		position.price = float(c.price)
		c.available = int(c.available) - quantity
		p.finance_market.cash_flow = int(p.finance_market.cash_flow) + gross + fee
	else:
		if quantity > int(position.quantity) or gross <= fee:
			return "Not enough shares, or proceeds would not cover the fee."
		var basis := int(round(float(position.cost) * quantity / int(position.quantity)))
		position.cost = int(position.cost) - basis
		position.quantity = int(position.quantity) - quantity
		p.bank_savings += gross - fee
		c.available = int(c.available) + quantity
		p.finance_market.realized = int(p.finance_market.realized) + gross - fee - basis
		p.finance_market.cash_flow = int(p.finance_market.cash_flow) - (gross - fee)
	if int(position.quantity) == 0:
		holdings.erase(uid)
	else:
		holdings[uid] = position
	record(p)
	var message := "%s %d shares of %s for $%d; fee $%d." % ["Bought" if buying else "Sold", quantity, c.name, gross, fee]
	p.add_life_log_entry(message, "finance")
	return message


static func acquisition_price(p: Node, c: Dictionary) -> int:
	var owned := int(p.finance_market.holdings.get(c.uid, {}).get("quantity", 0))
	return int(ceil(float(c.price) * (SHARES * 1.25 - owned)))


static func acquire(p: Node, uid: String) -> String:
	ensure(p)
	var c := issuer(p, uid)
	if not _eligible(p) or c.is_empty() or not c.active or not str(c.business_uid).is_empty():
		return "This business is unavailable for acquisition."
	var price := acquisition_price(p, c)
	if p.bank_savings < price:
		return "Insufficient bank balance for the acquisition. Corporate acquisitions require bank balance."
	p.bank_savings -= price
	var def := BusinessManager.get_business_type_by_id(str(c.type_id))
	var baseline := float(def.base_revenue_min + def.base_revenue_max) * 0.75
	var valuation := int(float(c.price) * SHARES)
	var business := {"uid": "acquired_" + uid, "type_id": c.type_id, "name": c.name, "icon": def.icon,
		"founded_age": p.age, "acquired_from": c.owner, "treasury": 0, "employees": 4, "marketing_budget": 5000,
		"annual_revenue": 0, "annual_opex": 0, "net_profit": 0, "cumulative_net_profit": 0,
		"unpaid_taxes": 0, "loan_balance": 0, "valuation": valuation, "reputation": 70,
		"revenue_scale": maxf(1.0, valuation / baseline), "owner_fraction": 1.0}
	p.owned_businesses.append(business)
	var old: Dictionary = p.finance_market.holdings.get(uid, {})
	p.finance_market.cash_flow = int(p.finance_market.cash_flow) - int(old.get("quantity", 0)) * float(c.price)
	p.finance_market.holdings.erase(uid)
	c.active = false
	for trader in p.finance_market.traders:
		trader.cash = float(trader.cash) + int(trader.positions.get(uid, 0)) * float(c.price)
	_retire_positions(p, uid)
	_fill(p)
	record(p)
	var message := "Acquired %s from %s for $%d. It is now in your business assets." % [c.name, c.owner, price]
	p.add_life_log_entry(message, "milestone")
	return message


static func request_ipo(p: Node, business: Dictionary) -> String:
	ensure(p)
	if not _eligible(p) or not p.owned_businesses.has(business):
		return "Business unavailable."
	if business.has("listing_uid"):
		return "This business is already listed."
	if int(business.get("cumulative_net_profit", 0)) <= 1000000:
		return "IPO requires more than $1,000,000 cumulative after-tax net profit."
	if int(business.get("unpaid_taxes", 0)) > 0 or int(business.get("treasury", 0)) < 0:
		return "Settle outstanding business taxes and restore the treasury before requesting an IPO."
	var candidates: Array = []
	for c in active(p):
		if str(c.business_uid).is_empty() and not p.finance_market.holdings.has(c.uid):
			candidates.append(c)
	if candidates.is_empty():
		return "No listing slot available. Sell a holding to free an NPC listing slot."
	var retired: Dictionary = candidates.pick_random()
	retired.active = false
	for trader in p.finance_market.traders:
		trader.cash = float(trader.cash) + int(trader.positions.get(retired.uid, 0)) * float(retired.price)
	_retire_positions(p, retired.uid)
	p.finance_market.serial = int(p.finance_market.serial) + 1
	var price := snappedf(maxf(1.0, float(business.get("valuation", 100000)) / SHARES), 0.01)
	var uid := "ipo_%d" % int(p.finance_market.serial)
	var raised := int(price * FLOAT * 0.95) # 5% underwriting fee; 20% sold to the exchange's liquidity provider.
	p.finance_market.issuers.append({"uid": uid, "archetype": -1, "name": business.name, "owner": p.first_name,
		"country": p.birthplace, "type_id": business.type_id, "active": true, "price": price, "previous": price,
		"available": FLOAT, "npc_buys": 0, "npc_sells": 0, "performance": 0.0, "business_uid": business.uid, "opened_age": p.age})
	business.listing_uid = uid
	business.owner_fraction = 0.8
	business.treasury = int(business.treasury) + raised
	var message := "IPO approved: %s raised $%d in its treasury. You retain 80%% ownership; NPCs can trade the public 20%%." % [business.name, raised]
	p.add_life_log_entry(message, "milestone")
	return message


static func release_business(p: Node, business: Dictionary) -> void:
	var c := issuer(p, str(business.get("listing_uid", "")))
	if not c.is_empty():
		c.business_uid = ""
		c.owner = preload("res://scripts/core/name_catalog.gd").random_name("United States", randf() < 0.5)


static func distribute_dividend(p: Node, business: Dictionary, amount: int) -> void:
	var uid: String = str(business.get("listing_uid", ""))
	if uid.is_empty():
		return
	for trader in p.finance_market.get("traders", []):
		trader.cash = float(trader.cash) + float(amount) * int(trader.positions.get(uid, 0)) / SHARES


static func _retire_positions(p: Node, uid: String) -> void:
	for trader in p.finance_market.traders:
		trader.positions.erase(uid)


static func get_regime_info(p: Node) -> Dictionary:
	ensure(p)
	var regime: String = str(p.finance_market.get("regime", "bull_run"))
	match regime:
		"market_crash":
			return {
				"id": "market_crash",
				"title": "💥 SYSTEMIC MARKET CRASH",
				"color": Color("#ef4444"),
				"bg_color": Color("#450a0a"),
				"desc": "Panic selling cascade and circuit breakers triggered! Equities plunging across all sectors.",
				"icon": "💥"
			}
		"bear_recession":
			return {
				"id": "bear_recession",
				"title": "🐻 BEAR MARKET RECESSION",
				"color": Color("#f43f5e"),
				"bg_color": Color("#4c0519"),
				"desc": "Elevated debt costs, tighter monetary policy, and declining consumer spending push equities down.",
				"icon": "🐻"
			}
		"bull_run":
			return {
				"id": "bull_run",
				"title": "🚀 HISTORIC BULL RUN",
				"color": Color("#10b981"),
				"bg_color": Color("#022c22"),
				"desc": "Unprecedented corporate profits, record retail participation, and explosive market-wide capital growth!",
				"icon": "🚀"
			}
		"sector_boom":
			return {
				"id": "sector_boom",
				"title": "⚡ TECH & HIGH-GROWTH RALLY",
				"color": Color("#06b6d4"),
				"bg_color": Color("#083344"),
				"desc": "Automation, biotechnology, and artificial intelligence breakthroughs trigger massive speculative rallies!",
				"icon": "⚡"
			}
		"recovery":
			return {
				"id": "recovery",
				"title": "📈 POST-CRASH ECONOMIC RECOVERY",
				"color": Color("#3b82f6"),
				"bg_color": Color("#172554"),
				"desc": "Monetary stimulus and institutional accumulation fuel a strong technical rebound across discounted stocks.",
				"icon": "📈"
			}
		_:
			return {
				"id": "stagnant",
				"title": "📊 RANGE-BOUND CONSOLIDATION",
				"color": Color("#f59e0b"),
				"bg_color": Color("#451a03"),
				"desc": "Sideways market with selective sector rotation. Investors cautiously awaiting economic data.",
				"icon": "📊"
			}


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
		if range_val <= 0.001:
			result += "▄"
		else:
			var idx: int = clampi(int(round(((float(val) - min_val) / range_val) * (chars.size() - 1))), 0, chars.size() - 1)
			result += chars[idx]
	return result


static func tick_live_market(p: Node) -> void:
	ensure(p)
	for c in active(p):
		var vol: float = float(c.get("volatility", 0.35))
		var micro_move := randf_range(-0.025, 0.025) * (vol / 0.35)
		var new_p := snappedf(maxf(0.10, float(c.price) * (1.0 + micro_move)), 0.01)
		c.price = new_p
		c.all_time_high = maxf(float(c.get("all_time_high", c.price)), float(c.price))
		c.all_time_low = minf(float(c.get("all_time_low", c.price)), float(c.price))
		if p.finance_market.holdings.has(c.uid):
			p.finance_market.holdings[c.uid]["price"] = new_p


static func advance_year(p: Node) -> void:
	ensure(p)
	if int(p.finance_market.last_age) >= p.age:
		return
	p.finance_market.last_age = p.age
	p.finance_market.news.clear()

	# 1. Roll Macro Market Regime Transition
	var cur_regime: String = str(p.finance_market.get("regime", "bull_run"))
	var years_in_regime: int = int(p.finance_market.get("regime_years", 1))
	var new_regime := cur_regime

	var roll := randf()
	match cur_regime:
		"market_crash":
			# Crashes are swift and sharp (1 year). Rebound or slide into recession.
			new_regime = "recovery" if roll < 0.65 else "bear_recession"
		"bull_run":
			if years_in_regime >= 2 and roll < 0.55:
				if roll < 0.18:
					new_regime = "market_crash"
				elif roll < 0.38:
					new_regime = "stagnant"
				else:
					new_regime = "sector_boom"
		"bear_recession":
			if years_in_regime >= 2 and roll < 0.60:
				new_regime = "recovery" if roll < 0.40 else "stagnant"
		"recovery":
			new_regime = "bull_run" if roll < 0.65 else "stagnant"
		"sector_boom":
			if roll < 0.45:
				new_regime = "bull_run" if roll < 0.25 else "market_crash"
		_:
			if roll < 0.50:
				if roll < 0.25:
					new_regime = "bull_run"
				elif roll < 0.40:
					new_regime = "bear_recession"
				else:
					new_regime = "market_crash"

	if new_regime != cur_regime:
		p.finance_market.regime = new_regime
		p.finance_market.regime_years = 1
	else:
		p.finance_market.regime_years = years_in_regime + 1

	var reg_info := get_regime_info(p)

	# 2. Economy macro baseline per regime
	var economy := 0.0
	match str(p.finance_market.regime):
		"market_crash":
			economy = randf_range(-0.52, -0.28)
		"bear_recession":
			economy = randf_range(-0.28, -0.12)
		"bull_run":
			economy = randf_range(0.22, 0.56)
		"sector_boom":
			economy = randf_range(0.18, 0.42)
		"recovery":
			economy = randf_range(0.12, 0.32)
		_:
			economy = randf_range(-0.06, 0.08)

	var top_gainer: Dictionary = {}
	var top_gainer_pct := -999.0
	var top_loser: Dictionary = {}
	var top_loser_pct := 999.0
	var total_pct_moves := 0.0

	var active_issuers := active(p)
	for c in active_issuers:
		c.previous = c.price
		c.npc_buys = 0
		c.npc_sells = 0

		var arch: int = int(c.get("archetype", 0))
		var sec_name: String = str(c.get("sector", SECTORS[arch] if (arch >= 0 and arch < SECTORS.size()) else "General"))
		var vol: float = float(c.get("volatility", get_sector_volatility(sec_name)))

		# Individual company fundamental performance
		var performance := randf_range(-vol * 0.4, vol * 0.4)
		for business in p.owned_businesses:
			if business.uid == c.business_uid:
				performance = clampf(float(business.get("net_profit", 0)) / maxf(1.0, float(business.get("annual_revenue", 1))), -0.35, 0.35)
		c.performance = performance

		# Sector boom bonus
		var sector_bonus := 0.0
		if str(p.finance_market.regime) == "sector_boom" and (sec_name in HIGH_BETA_SECTORS):
			sector_bonus = randf_range(0.25, 0.55)

		# Idiosyncratic catalyst event roll (15% chance)
		var catalyst_move := 0.0
		var event_note := "Trading steady with normal market volume."
		var cat_roll := randf()
		if str(p.finance_market.regime) == "market_crash":
			catalyst_move = randf_range(-0.15, -0.05) * (vol / 0.3)
			event_note = "💥 Liquidity squeeze and institutional margin liquidation cascade."
		elif cat_roll < 0.12:
			catalyst_move = randf_range(0.30, 0.75) * (vol / 0.35)
			event_note = ["🚀 Surprise earnings blowout; profit surged +85%!", "🚀 Transformative patent granted; revenue forecast raised!", "🚀 Multi-billion defense government contract signed!"][randi() % 3]
		elif cat_roll < 0.24:
			catalyst_move = -randf_range(0.25, 0.55) * (vol / 0.35)
			event_note = ["💥 Regulatory audit and severe product recall!", "💥 Earnings missed expectations by 45%; CEO ousted.", "💥 Supply chain breakdown halts commercial delivery!"][randi() % 3]
		elif str(p.finance_market.regime) == "bull_run":
			event_note = "▲ Strong institutional accumulation and retail demand."
		elif str(p.finance_market.regime) == "recovery":
			event_note = "▲ Technical bounce from oversold valuation lows."
		elif str(p.finance_market.regime) == "bear_recession":
			event_note = "▼ Lower consumer spending and margin compression."

		c["event_note"] = event_note

		# NPC Trader activity driven by demand
		for trader in p.finance_market.traders:
			trader.cash = maxf(float(trader.cash), float(c.price) * 50.0)
			var held := int(trader.positions.get(c.uid, 0))
			var demand := clampf(0.5 + performance + economy * 0.8 + sector_bonus * 0.5 + catalyst_move * 0.5, 0.10, 0.90)
			if randf() < demand:
				var max_affordable := int(float(trader.cash) / maxf(0.01, float(c.price)))
				var quantity := mini(randi_range(60, 800), mini(int(c.available), max_affordable))
				trader.cash = float(trader.cash) - quantity * float(c.price)
				trader.positions[c.uid] = held + quantity
				c.available = int(c.available) - quantity
				c.npc_buys = int(c.npc_buys) + quantity
			else:
				var quantity := mini(held, randi_range(60, 800))
				trader.cash = float(trader.cash) + quantity * float(c.price)
				trader.positions[c.uid] = held - quantity
				c.available = int(c.available) + quantity
				c.npc_sells = int(c.npc_sells) + quantity

		var pressure := float(int(c.npc_buys) - int(c.npc_sells)) / FLOAT
		var move := economy + performance * 0.4 + sector_bonus + catalyst_move + pressure * 0.35 + randf_range(-0.06, 0.06)
		# Volatility limits: allow crashes down to -75% and rallies up to +220%
		move = clampf(move, -0.75, 2.20)

		var new_price := snappedf(maxf(0.10, float(c.price) * (1.0 + move)), 0.01)
		c.price = new_price
		c.all_time_high = maxf(float(c.get("all_time_high", new_price)), new_price)
		c.all_time_low = minf(float(c.get("all_time_low", new_price)), new_price)

		var pct_change := (new_price / maxf(0.01, float(c.previous)) - 1.0) * 100.0
		c["yearly_change_pct"] = pct_change
		total_pct_moves += pct_change

		if pct_change > top_gainer_pct:
			top_gainer_pct = pct_change
			top_gainer = c
		if pct_change < top_loser_pct:
			top_loser_pct = pct_change
			top_loser = c

		# Update price history array (keep up to 8 data points)
		var h: Array = c.get("history", [])
		h.append(new_price)
		while h.size() > 8:
			h.pop_front()
		c["history"] = h

		# Update player's holding quote if held
		if p.finance_market.holdings.has(c.uid):
			p.finance_market.holdings[c.uid]["price"] = new_price

		if str(c.business_uid).is_empty() and p.age > int(c.opened_age) + 1 and randf() < 0.07:
			_close(p, c)
		else:
			for business in p.owned_businesses:
				if business.uid == c.business_uid:
					business.valuation = int(float(c.price) * SHARES)

	var avg_market_move := (total_pct_moves / maxf(1.0, float(active_issuers.size())))
	p.finance_market["avg_change"] = avg_market_move

	# Generate Dynamic Market Headlines
	var headline := ""
	match str(p.finance_market.regime):
		"market_crash":
			headline = "💥 BLACK SWAN MARKET CRASH: Panic selling triggered circuit breakers as equities collapsed an average of %.1f%%!" % absf(avg_market_move)
		"bear_recession":
			headline = "📉 BEAR MARKET CONTRACTION: Macro recession and debt costs sent corporate stocks down %.1f%% on average." % absf(avg_market_move)
		"bull_run":
			headline = "🚀 HISTORIC BULL RUN: Stock exchange surged +%.1f%% to record all-time highs amidst stellar corporate profits!" % avg_market_move
		"sector_boom":
			headline = "⚡ HIGH-GROWTH TECH FRENZY: Tech & automation equities skyrocketed +%.1f%% on breakthrough innovation!" % avg_market_move
		"recovery":
			headline = "📈 ECONOMIC RECOVERY: Markets bounced back +%.1f%% as monetary liquidity and buyer confidence returned." % avg_market_move
		_:
			headline = "📊 SIDEWAYS MARKET: Stocks consolidated range-bound (%+.1f%%) amidst mixed corporate earnings." % avg_market_move

	p.finance_market.news.append(headline)
	p.add_life_log_entry(headline, "finance")

	if not top_gainer.is_empty() and top_gainer_pct > 20.0:
		var g_msg := "🏆 TOP GAINER: %s surged +%.1f%% to $%s!" % [top_gainer.name, top_gainer_pct, snappedf(top_gainer.price, 0.01)]
		p.finance_market.news.append(g_msg)
	if not top_loser.is_empty() and top_loser_pct < -20.0:
		var l_msg := "⚠️ BIGGEST DROP: %s plunged %.1f%% down to $%s!" % [top_loser.name, top_loser_pct, snappedf(top_loser.price, 0.01)]
		p.finance_market.news.append(l_msg)

	_fill(p)
	record(p)

	# Retain active issuers as well as any unlisted issuers held by the player
	var kept_issuers: Array = []
	for company in p.finance_market.get("issuers", []):
		if bool(company.get("active", false)) or p.finance_market.holdings.has(company.uid):
			kept_issuers.append(company)
	p.finance_market.issuers = kept_issuers


static func _close(p: Node, c: Dictionary) -> void:
	c.active = false
	var held: Dictionary = p.finance_market.holdings.get(c.uid, {})
	var has_player_holding := not held.is_empty() and int(held.get("quantity", 0)) > 0
	
	for trader in p.finance_market.traders:
		var held_npc := int(trader.positions.get(c.uid, 0))
		if held_npc > 0:
			trader.cash = float(trader.cash) + held_npc * float(c.price)
	_retire_positions(p, c.uid)
	
	var message: String = ""
	if has_player_holding:
		# Player retains all purchased shares in their portfolio
		held.price = float(c.price)
		held.name = str(c.name)
		message = "%s rotated off active exchange listings. Your %d shares remain in your portfolio and can be sold anytime." % [c.name, int(held.quantity)]
	else:
		message = "%s delisted from the active exchange to make room for new listings." % c.name
	p.finance_market.news.append(message)
	p.add_life_log_entry(message, "finance")
