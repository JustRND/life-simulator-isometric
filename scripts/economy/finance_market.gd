class_name FinanceMarket
extends RefCounted

# 24 reusable business archetypes. Every reopening gets a new issuer ID and owner.
const SECTORS = ["Robotics", "Solar", "Logistics", "Coffee", "Software", "Biotech", "Fashion", "Architecture", "Audio", "Accounting", "Dental", "Medicine", "Cloud", "Batteries", "Freight", "Food", "Games", "Genomics", "Textiles", "Housing", "Media", "Analytics", "Wellness", "Diagnostics"]
const PREFIXES = ["Aurora", "Cedar", "Atlas", "Neon", "Lotus", "Orion", "Pixel", "Summit", "Terra", "Nova", "Silver", "Horizon", "Cobalt", "Willow", "Vega", "Maple", "Coral", "Amber", "River", "Lunar", "Pine", "Prism", "Echo", "Bright"]
const TYPE_IDS = ["engineering_workshop", "clean_energy", "wholesaler", "coffee_shop", "software_studio", "biotech_lab", "clothing_store", "architecture_studio", "music_studio", "accounting_firm", "dental_practice", "medical_clinic", "software_studio", "clean_energy", "wholesaler", "coffee_shop", "software_studio", "biotech_lab", "clothing_store", "architecture_studio", "film_studio", "accounting_firm", "medical_clinic", "biotech_lab"]
const SHARES := 100000
const FLOAT := 20000
const MAX_ACTIVE := 8
const FEE := 0.01


static func ensure(p: Node) -> void:
	if p.finance_market.is_empty():
		p.finance_market = {"issuers": [], "holdings": {}, "history": [], "news": [], "traders": [], "last_age": p.age, "serial": 0, "realized": 0, "cash_flow": 0}
		for i in range(16):
			p.finance_market.traders.append({"cash": 5000000.0, "positions": {}})
	# Self-heal: ensure every holding has an issuer entry so it is never orphaned
	for uid in p.finance_market.get("holdings", {}):
		if issuer(p, uid).is_empty():
			var pos: Dictionary = p.finance_market.holdings[uid]
			var fallback_company := {
				"uid": uid, "archetype": -1, "name": str(pos.get("name", "Asset " + uid)),
				"owner": "Public", "country": "United States", "type_id": "", "active": false,
				"price": float(pos.get("price", 10.0)), "previous": float(pos.get("price", 10.0)),
				"available": 0, "npc_buys": 0, "npc_sells": 0, "performance": 0.0,
				"business_uid": "", "opened_age": p.age
			}
			p.finance_market.issuers.append(fallback_company)
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
	var def: Dictionary = BusinessManager.get_business_type_by_id("biz_" + TYPE_IDS[archetype])
	var country: String = preload("res://scripts/core/creation_options.gd").COUNTRIES.pick_random()[0]
	var price := snappedf(randf_range(6.0, 55.0), 0.01)
	var company := {"uid": "market_%d" % int(p.finance_market.serial), "archetype": archetype,
		"name": "%s %s %s" % [PREFIXES.pick_random(), SECTORS[archetype], ["Group", "Works", "Industries", "Partners"].pick_random()],
		"owner": preload("res://scripts/core/name_catalog.gd").random_name(country, randf() < 0.5), "country": country,
		"type_id": str(def.id), "active": true, "price": price, "previous": price, "available": FLOAT,
		"npc_buys": 0, "npc_sells": 0, "performance": 0.0, "business_uid": "", "opened_age": p.age}
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


static func advance_year(p: Node) -> void:
	ensure(p)
	if int(p.finance_market.last_age) >= p.age:
		return
	p.finance_market.last_age = p.age
	p.finance_market.news.clear()
	var economy := randf_range(-0.08, 0.08)
	for c in active(p):
		c.previous = c.price
		c.npc_buys = 0
		c.npc_sells = 0
		var performance := randf_range(-0.12, 0.15)
		for business in p.owned_businesses:
			if business.uid == c.business_uid:
				performance = clampf(float(business.get("net_profit", 0)) / maxf(1.0, float(business.get("annual_revenue", 1))), -0.2, 0.2)
		c.performance = performance
		for trader in p.finance_market.traders:
			trader.cash = maxf(float(trader.cash), float(c.price) * 50.0)
			var held := int(trader.positions.get(c.uid, 0))
			var demand := clampf(0.5 + performance + economy, 0.15, 0.85)
			if randf() < demand:
				var max_affordable := int(float(trader.cash) / maxf(0.01, float(c.price)))
				var quantity := mini(randi_range(50, 600), mini(int(c.available), max_affordable))
				trader.cash = float(trader.cash) - quantity * float(c.price)
				trader.positions[c.uid] = held + quantity
				c.available = int(c.available) - quantity
				c.npc_buys = int(c.npc_buys) + quantity
			else:
				var quantity := mini(held, randi_range(50, 600))
				trader.cash = float(trader.cash) + quantity * float(c.price)
				trader.positions[c.uid] = held - quantity
				c.available = int(c.available) + quantity
				c.npc_sells = int(c.npc_sells) + quantity
		var pressure := float(int(c.npc_buys) - int(c.npc_sells)) / FLOAT
		var move := clampf(economy + performance * 0.5 + pressure * 0.4 + randf_range(-0.12, 0.12), -0.45, 0.45)
		# Uncapped business valuations: stock price has no upper limit, scaling freely past $10B into hundreds of billions
		c.price = snappedf(maxf(0.1, float(c.price) * (1.0 + move)), 0.01)
		if str(c.business_uid).is_empty() and p.age > int(c.opened_age) + 1 and randf() < 0.08:
			_close(p, c)
		else:
			for business in p.owned_businesses:
				if business.uid == c.business_uid:
					business.valuation = int(float(c.price) * SHARES)
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
