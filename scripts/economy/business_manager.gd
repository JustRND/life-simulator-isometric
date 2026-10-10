class_name BusinessManager
extends RefCounted

const CORPORATE_TAX_RATE: float = 0.30
const BUSINESS_LOAN_INTEREST_RATE: float = 0.085


## Progressive corporate tax rate scaling with portfolio scale and net profit
static func get_corporate_tax_rate(total_businesses: int, net_profit: int = 0) -> float:
	# Base corporate tax starts at 30%
	# Each additional business owned increases corporate tax rate by +5%
	# (1 biz: 30%, 2 biz: 35%, 3 biz: 40%, 4 biz: 45%, 5 biz: 50%, 6+ biz: 55%+)
	var rate: float = 0.30 + (maxi(0, total_businesses - 1) * 0.05)
	if net_profit > 1000000:
		rate += 0.12
	elif net_profit > 500000:
		rate += 0.08
	elif net_profit > 250000:
		rate += 0.04
	return clampf(rate, 0.30, 0.65)

const CATEGORIES: Array[Dictionary] = [
	{
		"id": "fnb",
		"name": "F&B BUSINESS",
		"icon": "☕",
		"color": "#f59e0b",
		"description": "Artisan coffee roasteries, cafes, and gourmet food & beverage dining."
	},
	{
		"id": "logistics",
		"name": "LOGISTICS BUSINESS",
		"icon": "📦",
		"color": "#0284c7",
		"description": "Wholesale freight hubs, automated supply chain distribution & container transport."
	},
	{
		"id": "tech_media",
		"name": "TECH & MEDIA BUSINESS",
		"icon": "💻",
		"color": "#38bdf8",
		"description": "Full-stack AI software, creative digital design, audio recording, and film networks."
	},
	{
		"id": "health_science",
		"name": "HEALTHCARE & SCIENCE BUSINESS",
		"icon": "🩺",
		"color": "#10b981",
		"description": "Private urgent care clinics, modern dental surgery, and biotech genomics laboratories."
	},
	{
		"id": "finance_legal",
		"name": "FINANCE & LEGAL BUSINESS",
		"icon": "⚖️",
		"color": "#eab308",
		"description": "Corporate defense law firms, forensic accounting audits, and algorithmic hedge funds."
	},
	{
		"id": "retail_services",
		"name": "RETAIL & SERVICES BUSINESS",
		"icon": "🏢",
		"color": "#8b5cf6",
		"description": "Haute couture boutiques, modernist architectural planning, and robotics engineering workshops."
	},
	{
		"id": "energy",
		"name": "ENERGY & INFRASTRUCTURE BUSINESS",
		"icon": "⚡",
		"color": "#14b8a6",
		"description": "Renewable solar microgrids and megawatt battery storage utility contracts."
	}
]

const BUSINESS_TYPES: Array[Dictionary] = [
	{
		"id": "biz_coffee_shop",
		"name": "Artisan Coffee Roastery & Cyber Cafe",
		"icon": "☕",
		"category": "fnb",
		"required_license": "license_food_safety",
		"required_license_title": "Commercial Food Safety License",
		"required_major": "food_science",
		"required_degree_title": "Food Science & Culinary Arts",
		"startup_cost": 75000,
		"base_revenue_min": 65000,
		"base_revenue_max": 105000,
		"base_opex": 58000,
		"description": "Roast single-origin espresso and serve synthetic cyber energy infusions in a bustling downtown tech district."
	},
	{
		"id": "biz_wholesaler",
		"name": "Wholesale Freight Distribution & Logistics",
		"icon": "📦",
		"category": "logistics",
		"required_license": "license_car",
		"required_license_title": "Driver's License (Commercial Logistics)",
		"required_major": "logistics",
		"required_degree_title": "Global Logistics & Supply Chain",
		"startup_cost": 250000,
		"base_revenue_min": 240000,
		"base_revenue_max": 420000,
		"base_opex": 235000,
		"description": "Coordinate automated container freight, bulk warehouse depots, and regional supply chain transport fleets."
	},
	{
		"id": "biz_clothing_store",
		"name": "Haute Couture & Streetwear Boutique",
		"icon": "👗",
		"category": "retail_services",
		"required_license": "license_appraiser",
		"required_license_title": "Certified Commercial Appraiser License",
		"required_major": "fashion",
		"required_degree_title": "Fashion & Apparel Design",
		"startup_cost": 135000,
		"base_revenue_min": 120000,
		"base_revenue_max": 210000,
		"base_opex": 115000,
		"description": "Curate runway collections, bespoke tailor-fitted suits, and avant-garde luminescent streetwear."
	},
	{
		"id": "biz_law_firm",
		"name": "Corporate & Criminal Defense Law Firm",
		"icon": "⚖️",
		"category": "finance_legal",
		"required_license": "license_bookkeeper",
		"required_license_title": "Certified Public Bookkeeper & Compliance License",
		"required_major": "law",
		"required_degree_title": "Legal Studies & Jurisprudence",
		"startup_cost": 220000,
		"base_revenue_min": 210000,
		"base_revenue_max": 390000,
		"base_opex": 195000,
		"description": "Represent elite corporate executives, high-stakes patent arbitrations, and high-profile criminal litigation."
	},
	{
		"id": "biz_graphic_consultancy",
		"name": "Graphic Design & Branding Consultancy",
		"icon": "🎨",
		"category": "tech_media",
		"required_license": "license_photographer",
		"required_license_title": "Commercial Visual Media License",
		"required_major": "graphic_design",
		"required_degree_title": "Graphic Design & Visual Communication",
		"startup_cost": 65000,
		"base_revenue_min": 70000,
		"base_revenue_max": 135000,
		"base_opex": 65000,
		"description": "Design dynamic corporate identities, 3D vector graphics, futuristic web UI/UX, and viral media campaigns."
	},
	{
		"id": "biz_medical_clinic",
		"name": "Private Urgent Care & Medical Clinic",
		"icon": "🩺",
		"category": "health_science",
		"required_license": "license_food_safety",
		"required_license_title": "Commercial Healthcare Sanitation & Safety License",
		"required_major": "medicine",
		"required_degree_title": "Pre-Med & Healthcare Sciences",
		"startup_cost": 550000,
		"base_revenue_min": 500000,
		"base_revenue_max": 900000,
		"base_opex": 480000,
		"description": "Deliver cutting-edge outpatient medical care, surgical recovery suites, and advanced diagnostic imaging."
	},
	{
		"id": "biz_software_studio",
		"name": "Full-Stack Software & AI Development Studio",
		"icon": "💻",
		"category": "tech_media",
		"required_license": "license_cyber",
		"required_license_title": "Certified Cyber Security & Pen-Tester License",
		"required_major": "it",
		"required_degree_title": "Cyber Security & IT",
		"startup_cost": 185000,
		"base_revenue_min": 180000,
		"base_revenue_max": 360000,
		"base_opex": 175000,
		"description": "Engineer enterprise cloud microservices, predictive neural models, cyber security shields, and mobile apps."
	},
	{
		"id": "biz_accounting_firm",
		"name": "Certified Public Accounting & Audit Firm",
		"icon": "📊",
		"category": "finance_legal",
		"required_license": "license_bookkeeper",
		"required_license_title": "Certified Public Bookkeeper License",
		"required_major": "accounting",
		"required_degree_title": "Accounting & Forensic Audit",
		"startup_cost": 120000,
		"base_revenue_min": 125000,
		"base_revenue_max": 230000,
		"base_opex": 120000,
		"description": "Manage corporate tax compliance, forensic accounting audits, capital allocation, and executive ledgers."
	},
	{
		"id": "biz_architecture_studio",
		"name": "Architectural & Urban Planning Studio",
		"icon": "📐",
		"category": "retail_services",
		"required_license": "license_electrician",
		"required_license_title": "Certified Building & Electrical Code License",
		"required_major": "architecture",
		"required_degree_title": "Architecture & Urban Planning",
		"startup_cost": 225000,
		"base_revenue_min": 200000,
		"base_revenue_max": 390000,
		"base_opex": 190000,
		"description": "Draft skyline mega-towers, eco-sustainable civic developments, and luxurious modernist villas."
	},
	{
		"id": "biz_engineering_workshop",
		"name": "Automotive & Robotics Engineering Workshop",
		"icon": "⚙️",
		"category": "retail_services",
		"required_license": "license_electrician",
		"required_license_title": "Certified Industrial Electrical & Machine License",
		"required_major": "engineering",
		"required_degree_title": "Mechanical & Electrical Engineering",
		"startup_cost": 240000,
		"base_revenue_min": 210000,
		"base_revenue_max": 380000,
		"base_opex": 200000,
		"description": "Fabricate custom vehicle powertrains, CNC robotic chassis components, and industrial automation assemblies."
	},
	{
		"id": "biz_biotech_lab",
		"name": "Biotech Synthesis & Genomics Laboratory",
		"icon": "🧬",
		"category": "health_science",
		"required_license": "license_cyber",
		"required_license_title": "Certified Bio-Systems & Lab Safety License",
		"required_major": "biotech",
		"required_degree_title": "Biotechnology & Genetics",
		"startup_cost": 750000,
		"base_revenue_min": 600000,
		"base_revenue_max": 1200000,
		"base_opex": 590000,
		"description": "Pioneer synthetic drug formulas, genetic bioreactors, and proprietary cellular longevity treatments."
	},
	{
		"id": "biz_hedge_fund",
		"name": "Hedge Fund & Wealth Asset Management",
		"icon": "📈",
		"category": "finance_legal",
		"required_license": "license_bookkeeper",
		"required_license_title": "Certified Financial Bookkeeper License",
		"required_major": "finance",
		"required_degree_title": "Finance & Investment Banking",
		"startup_cost": 700000,
		"base_revenue_min": 580000,
		"base_revenue_max": 1150000,
		"base_opex": 550000,
		"description": "Deploy algorithmic high-frequency trading models, venture funds, and private equity investments."
	},
	{
		"id": "biz_music_studio",
		"name": "Audio Recording & Music Production Studio",
		"icon": "🎙️",
		"category": "tech_media",
		"required_license": "license_photographer",
		"required_license_title": "Commercial Audio/Visual Media License",
		"required_major": "music",
		"required_degree_title": "Sound Engineering & Music Production",
		"startup_cost": 110000,
		"base_revenue_min": 90000,
		"base_revenue_max": 180000,
		"base_opex": 90000,
		"description": "Mix platinum studio records, master film soundtracks, and produce commercial voice audio."
	},
	{
		"id": "biz_clean_energy",
		"name": "Renewable Energy & Solar Grid Services",
		"icon": "⚡",
		"category": "energy",
		"required_license": "license_electrician",
		"required_license_title": "Certified Journeyman Electrician License",
		"required_major": "environmental",
		"required_degree_title": "Environmental & Renewable Energy Science",
		"startup_cost": 320000,
		"base_revenue_min": 260000,
		"base_revenue_max": 510000,
		"base_opex": 250000,
		"description": "Contract large-scale commercial solar photovoltaic arrays, megawatt battery storage, and micro-grid controls."
	},
	{
		"id": "biz_dental_practice",
		"name": "Modern Dental Surgery & Orthodontics",
		"icon": "🦷",
		"category": "health_science",
		"required_license": "license_food_safety",
		"required_license_title": "Commercial Clinic Sanitation License",
		"required_major": "dentistry",
		"required_degree_title": "Dental Surgery & Oral Health",
		"startup_cost": 460000,
		"base_revenue_min": 400000,
		"base_revenue_max": 750000,
		"base_opex": 390000,
		"description": "Provide cosmetic veneer procedures, dental implants, laser periodontal surgery, and orthodontics."
	},
	{
		"id": "biz_film_studio",
		"name": "Film Studio & Multimedia Broadcast Network",
		"icon": "🎬",
		"category": "tech_media",
		"required_license": "license_drone",
		"required_license_title": "Commercial Aerial Drone & Film Operator License",
		"required_major": "film",
		"required_degree_title": "Film, Cinematography & Media Production",
		"startup_cost": 360000,
		"base_revenue_min": 310000,
		"base_revenue_max": 620000,
		"base_opex": 300000,
		"description": "Produce festival feature films, streaming docuseries, 8K commercial cinema, and multimedia broadcasts."
	},
	{
		"id": "biz_artisan_bakery",
		"name": "Artisan Sourdough Bakery & Patisserie",
		"icon": "🥐",
		"category": "fnb",
		"required_license": "license_food_safety",
		"required_license_title": "Commercial Food Safety License",
		"required_major": "food_science",
		"required_degree_title": "Food Science & Culinary Arts",
		"startup_cost": 95000,
		"base_revenue_min": 90000,
		"base_revenue_max": 160000,
		"base_opex": 88000,
		"description": "Bake small-batch wild-fermented sourdough, delicate French pastries, and specialty confectionery for morning crowds."
	},
	{
		"id": "biz_fine_dining_bistro",
		"name": "Michelin-Caliber Fine Dining & Gourmet Bistro",
		"icon": "🍽️",
		"category": "fnb",
		"required_license": "license_food_safety",
		"required_license_title": "Commercial Food Safety & Kitchen Manager License",
		"required_major": "food_science",
		"required_degree_title": "Food Science & Culinary Arts",
		"startup_cost": 290000,
		"base_revenue_min": 260000,
		"base_revenue_max": 510000,
		"base_opex": 250000,
		"description": "Craft multi-course seasonal tasting menus paired with vintage cellars and high-end molecular gastronomy."
	},
	{
		"id": "biz_craft_brewery",
		"name": "Craft Microbrewery & Gastropub",
		"icon": "🍺",
		"category": "fnb",
		"required_license": "license_mixologist",
		"required_license_title": "Professional Mixologist & Spirits License",
		"required_major": "food_science",
		"required_degree_title": "Food Science & Culinary Arts",
		"startup_cost": 185000,
		"base_revenue_min": 170000,
		"base_revenue_max": 340000,
		"base_opex": 165000,
		"description": "Brew experimental IPAs, barrel-aged stouts, and wood-fired artisanal comfort fare in an industrial taproom."
	},
	{
		"id": "biz_cargo_shipment",
		"name": "Trans-Oceanic Cargo & Container Shipment Lines",
		"icon": "🚢",
		"category": "logistics",
		"required_license": "license_boating",
		"required_license_title": "Master Coastal Boater & Marine Captain License",
		"required_major": "logistics",
		"required_degree_title": "Global Logistics & Supply Chain",
		"startup_cost": 600000,
		"base_revenue_min": 560000,
		"base_revenue_max": 1100000,
		"base_opex": 540000,
		"description": "Operate intermodal maritime container shipping, deep-water port docks, and international customs freight lanes."
	},
	{
		"id": "biz_courier_dispatch",
		"name": "Autonomous Courier & Last-Mile Drone Fleet",
		"icon": "🚁",
		"category": "logistics",
		"required_license": "license_drone",
		"required_license_title": "Commercial Drone Operator License",
		"required_major": "logistics",
		"required_degree_title": "Global Logistics & Supply Chain",
		"startup_cost": 145000,
		"base_revenue_min": 135000,
		"base_revenue_max": 270000,
		"base_opex": 130000,
		"description": "Deploy automated rooftop drone docks and electric ground van fleets for guaranteed 30-minute urban deliveries."
	},
	{
		"id": "biz_cold_chain_storage",
		"name": "Cold-Chain Cryogenic & Pharmaceutical Warehousing",
		"icon": "❄️",
		"category": "logistics",
		"required_license": "license_car",
		"required_license_title": "Commercial Freight Driver's License",
		"required_major": "logistics",
		"required_degree_title": "Global Logistics & Supply Chain",
		"startup_cost": 350000,
		"base_revenue_min": 300000,
		"base_revenue_max": 600000,
		"base_opex": 290000,
		"description": "Maintain ultra-low temperature cryogenic storage depots and refrigerated freight for biomedical goods and perishable cargo."
	},
	{
		"id": "biz_offshore_wind",
		"name": "Offshore Wind Turbine & Tidal Energy Array",
		"icon": "💨",
		"category": "energy",
		"required_license": "license_electrician",
		"required_license_title": "Certified High-Voltage Electrician License",
		"required_major": "environmental",
		"required_degree_title": "Environmental & Renewable Energy Science",
		"startup_cost": 700000,
		"base_revenue_min": 580000,
		"base_revenue_max": 1200000,
		"base_opex": 560000,
		"description": "Harness high-seas deep-water wind currents and marine tidal turbines feeding multi-gigawatt power to coastal cities."
	},
	{
		"id": "biz_hydroelectric_plant",
		"name": "Hydroelectric Dam & Reservoir Power Station",
		"icon": "🌊",
		"category": "energy",
		"required_license": "license_electrician",
		"required_license_title": "Certified Industrial Electrician License",
		"required_major": "environmental",
		"required_degree_title": "Environmental & Renewable Energy Science",
		"startup_cost": 950000,
		"base_revenue_min": 800000,
		"base_revenue_max": 1650000,
		"base_opex": 780000,
		"description": "Direct run-of-the-river hydraulic turbine vaults providing baseload hydroelectric generation and flood control."
	},
	{
		"id": "biz_grid_battery_storage",
		"name": "Grid-Scale Megawatt Battery Storage Reserve",
		"icon": "🔋",
		"category": "energy",
		"required_license": "license_electrician",
		"required_license_title": "Certified Grid Electrician License",
		"required_major": "environmental",
		"required_degree_title": "Environmental & Renewable Energy Science",
		"startup_cost": 490000,
		"base_revenue_min": 410000,
		"base_revenue_max": 850000,
		"base_opex": 400000,
		"description": "Stabilize regional transmission grids with containerized lithium iron phosphate battery banks during peak demand."
	}
]


static func get_all_business_types() -> Array[Dictionary]:
	return BUSINESS_TYPES


static func get_categories() -> Array[Dictionary]:
	return CATEGORIES


static func get_category_by_id(cat_id: String) -> Dictionary:
	for cat in CATEGORIES:
		if str(cat.get("id", "")) == cat_id:
			return cat
	return {}


static func get_businesses_in_category(cat_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for b in BUSINESS_TYPES:
		if str(b.get("category", "")) == cat_id:
			result.append(b)
	return result


static func get_business_type_by_id(id: String) -> Dictionary:
	for b in BUSINESS_TYPES:
		if str(b.get("id", "")) == id:
			return b
	return {}


static func player_has_required_degree(req_major: String) -> bool:
	var req_m := req_major.to_lower()

	# Check currently active university major if graduated
	if PlayerData.education_level == "University Graduate":
		if PlayerData.university_major.to_lower() == req_m:
			return true
		if PlayerData.university_major_title.to_lower().contains(req_m):
			return true

	# Check all completed degrees in PlayerData.degrees
	for d in PlayerData.degrees:
		if d is Dictionary:
			var d_major: String = str(d.get("major", "")).to_lower()
			var d_title: String = str(d.get("major_title", "")).to_lower()
			if d_major == req_m or d_major.contains(req_m) or d_title.contains(req_m):
				return true

	return false


static func can_found_business(biz_id: String, is_unlicensed: bool = false) -> Dictionary:
	var def := get_business_type_by_id(biz_id)
	if def.is_empty():
		return {"allowed": false, "reason": "Business enterprise definition not found."}

	if PlayerData.age < 18:
		return {"allowed": false, "reason": "Age Restricted: Must be at least 18 years old to incorporate an enterprise."}

	if not is_unlicensed:
		var req_lic: String = str(def.get("required_license", ""))
		var lic_title: String = str(def.get("required_license_title", "Commercial License"))
		var req_major: String = str(def.get("required_major", ""))
		# Check license; degree serves as an educational waiver fallback
		var has_qual: bool = PlayerData.has_license(req_lic)
		if not has_qual and req_major != "":
			has_qual = player_has_required_degree(req_major)

		if not has_qual:
			return {
				"allowed": false,
				"reason": "Requires %s. Obtain your license in the Licensing Panel first!" % lic_title
			}

	var cost: int = int(def.get("startup_cost", 50000))
	var total_player_funds: int = PlayerData.money + PlayerData.bank_savings
	if total_player_funds < cost:
		return {
			"allowed": false,
			"reason": "Insufficient capital: Startup incorporation cost is $%d (Available Funds: $%d)." % [cost, total_player_funds]
		}

	return {"allowed": true, "reason": "Qualified to incorporate."}


static func found_business(biz_id: String, business_name: String = "", is_unlicensed: bool = false) -> Dictionary:
	var eval := can_found_business(biz_id, is_unlicensed)
	if not bool(eval.get("allowed", false)):
		return eval

	var def := get_business_type_by_id(biz_id)
	var cost: int = int(def.get("startup_cost", 50000))

	# Deduct startup cost from player funds
	if not PlayerData.debit_funds(cost):
		return {"allowed": false, "message": "Insufficient funds."}

	var default_name: String = business_name if business_name.strip_edges() != "" else str(def.get("name", "Enterprise"))

	var new_biz: Dictionary = {
		"uid": "biz_%d_%d" % [PlayerData.age, randi() % 10000],
		"type_id": biz_id,
		"name": default_name,
		"icon": str(def.get("icon", "🏢")),
		"founded_age": PlayerData.age,
		"is_unlicensed": is_unlicensed,
		"branches": 1,
		"facility_tier": 1,
		"revenue_scale": 1.0,
		"treasury": maxi(25000, int(cost * 0.25)), # Initial seed working capital inside business bank account
		"employees": maxi(2, mini(4, int(cost / 75000))),
		"marketing_budget": 5000,
		"annual_revenue": 0,
		"annual_opex": 0,
		"net_profit": 0,
		"unpaid_taxes": 0,
		"last_tax_paid_year": -1,
		"loan_balance": 0,
		"loan_interest_rate": BUSINESS_LOAN_INTEREST_RATE,
		"valuation": int(cost * 1.15),
		"reputation": 45 if is_unlicensed else 75
	}

	PlayerData.owned_businesses.append(new_biz)

	if is_unlicensed:
		PlayerData.add_life_log_entry("⚠️ ILLICIT ENTERPRISE LAUNCHED: You invested $%d to operate '%s' WITHOUT a commercial license! Operating without a license is a crime and risks audits, lawsuits, closures, and imprisonment." % [cost, default_name], "crime")
		PlayerData.add_milestone("Operated unlicensed '%s'." % default_name, PlayerData.age, "⚠️")
	else:
		PlayerData.add_life_log_entry("🚀 ENTERPRISE INCORPORATED: You invested $%d to officially launch '%s'! Business treasury initialized with $10,000 working capital." % [cost, default_name], "milestone")
		PlayerData.add_milestone("Founded '%s'." % default_name, PlayerData.age, "🏢")

	return {
		"allowed": true,
		"message": "Congratulations! Your enterprise '%s' has been initialized." % default_name,
		"business": new_biz
	}


static func rename_business(biz_uid: String, new_name: String) -> Dictionary:
	var clean_name := new_name.strip_edges()
	if clean_name.is_empty():
		return {"success": false, "message": "Business name cannot be empty."}

	for b in PlayerData.owned_businesses:
		if str(b.get("uid", "")) == biz_uid:
			var old_name: String = str(b.get("name", "Business"))
			b["name"] = clean_name
			PlayerData.add_life_log_entry("✏️ BUSINESS REBRAND: '%s' has officially rebranded and changed its trade name to '%s'." % [old_name, clean_name], "activity")
			return {"success": true, "message": "Successfully renamed enterprise to '%s'." % clean_name}

	return {"success": false, "message": "Enterprise not found."}


# =============================================================================
# CORPORATE TREASURY USAGE & EXPANSION
# =============================================================================

static func get_branch_expansion_cost(b: Dictionary) -> int:
	var type_id: String = str(b.get("type_id", ""))
	var def := get_business_type_by_id(type_id)
	var startup: int = int(def.get("startup_cost", 100000))
	var branches: int = int(b.get("branches", 1))
	var total_owned: int = PlayerData.owned_businesses.size()
	# Substantial capital outlay: 150% of startup cost + compounding branch scale surcharge ($60,000 per branch) + portfolio scale overhead ($25,000 per owned business)
	return int(startup * 1.50) + (branches * 60000) + (maxi(0, total_owned - 1) * 25000)


static func open_business_branch(b: Dictionary, branch_name: String = "") -> Dictionary:
	var branch_cost: int = get_branch_expansion_cost(b)
	var treasury: int = int(b.get("treasury", 0))

	if treasury < branch_cost:
		return {
			"success": false,
			"message": "Insufficient corporate treasury! Opening Branch #%d requires $%d in corporate treasury funds (Current Treasury: $%d)." % [
				int(b.get("branches", 1)) + 1,
				branch_cost,
				treasury
			]
		}

	# 1. Deduct cost from parent business treasury
	b["treasury"] = treasury - branch_cost
	b["branches"] = int(b.get("branches", 1)) + 1
	b["valuation"] = int(b.get("valuation", 50000)) + int(branch_cost * 0.85)
	b["reputation"] = mini(100, int(b.get("reputation", 75)) + 3)

	var next_branch_num := int(b.get("branches", 1))
	var parent_name := str(b.get("name", "Enterprise"))
	var clean_branch_name := branch_name.strip_edges()
	if clean_branch_name.is_empty():
		clean_branch_name = "%s - Branch %d" % [parent_name, next_branch_num]

	var type_id: String = str(b.get("type_id", ""))
	var def := get_business_type_by_id(type_id)

	# 2. Instantiate expanded business into PlayerData.owned_businesses with independent operations & micromanagement
	var new_branch: Dictionary = {
		"uid": "biz_exp_%d_%d" % [PlayerData.age, randi() % 1000000],
		"type_id": type_id,
		"name": clean_branch_name,
		"icon": str(b.get("icon", def.get("icon", "🏢"))),
		"founded_age": PlayerData.age,
		"is_unlicensed": bool(b.get("is_unlicensed", false)),
		"is_branch": true,
		"parent_uid": str(b.get("uid", "")),
		"branches": 1,
		"facility_tier": 1,
		"revenue_scale": 1.0,
		"treasury": 15000, # Seed working capital deployed from parent expansion funds
		"employees": 4,
		"marketing_budget": 5000,
		"annual_revenue": 0,
		"annual_opex": 0,
		"net_profit": 0,
		"unpaid_taxes": 0,
		"last_tax_paid_year": -1,
		"loan_balance": 0,
		"loan_interest_rate": BUSINESS_LOAN_INTEREST_RATE,
		"valuation": int(branch_cost * 0.80),
		"reputation": int(b.get("reputation", 75)),
		"consecutive_losses": 0
	}

	PlayerData.owned_businesses.append(new_branch)

	PlayerData.add_life_log_entry("🏢 ENTERPRISE EXPANSION: %s deployed $%d corporate treasury to open branch '%s'! It is now live in your Owned Businesses portfolio with its own micromanagement." % [
		parent_name,
		branch_cost,
		clean_branch_name
	], "finance")
	PlayerData.add_milestone("Expanded '%s' with Branch '%s'." % [parent_name, clean_branch_name], PlayerData.age, "🏢")

	return {
		"success": true,
		"message": "Branch '%s' successfully established using $%d corporate treasury funds!\n\nIt is now active in your Owned Businesses tab with its own operations, staff, and finances." % [clean_branch_name, branch_cost],
		"branch": new_branch
	}


static func upgrade_business_facilities(b: Dictionary) -> Dictionary:
	var tier: int = int(b.get("facility_tier", 1))
	if tier >= 5:
		return {"success": false, "message": "Enterprise facilities already upgraded to maximum Grade 5 technology."}

	var cost: int = 25000 * tier
	var treasury: int = int(b.get("treasury", 0))

	if treasury < cost:
		return {
			"success": false,
			"message": "Insufficient corporate treasury! Upgrading to Facility Tier %d requires $%d (Current Treasury: $%d)." % [
				tier + 1,
				cost,
				treasury
			]
		}

	b["treasury"] = treasury - cost
	b["facility_tier"] = tier + 1
	b["valuation"] = int(b.get("valuation", 50000)) + int(cost * 1.30)
	b["reputation"] = mini(100, int(b.get("reputation", 75)) + 5)

	var b_name: String = str(b.get("name", "Enterprise"))
	PlayerData.add_life_log_entry("⚙️ FACILITY UPGRADE: %s invested $%d from corporate treasury to upgrade facilities & automation to Grade %d!" % [
		b_name,
		cost,
		tier + 1
	], "finance")

	return {
		"success": true,
		"message": "Facility upgraded to Grade %d using $%d corporate treasury funds!" % [tier + 1, cost]
	}


static func launch_treasury_marketing_blitz(b: Dictionary, budget: int = 15000) -> Dictionary:
	var treasury: int = int(b.get("treasury", 0))
	if treasury < budget:
		return {"success": false, "message": "Insufficient treasury ($%d) to fund a $%d advertising blitz." % [treasury, budget]}

	b["treasury"] = treasury - budget
	b["marketing_budget"] = int(b.get("marketing_budget", 5000)) + budget
	b["reputation"] = mini(100, int(b.get("reputation", 75)) + 8)

	var b_name: String = str(b.get("name", "Enterprise"))
	PlayerData.add_life_log_entry("📢 ADVERTISING CAMPAIGN: %s funded a $%d nationwide promotional blitz using corporate treasury!" % [
		b_name,
		budget
	], "finance")

	return {
		"success": true,
		"message": "Launched $%d advertising blitz funded by corporate treasury." % budget
	}


static func get_total_business_valuation() -> int:
	var total: int = 0
	for b in PlayerData.owned_businesses:
		total += int(maxi(0, int(b.get("valuation", 0)) + int(b.get("treasury", 0)) - int(b.get("loan_balance", 0)) - int(b.get("unpaid_taxes", 0))) * float(b.get("owner_fraction", 1.0)))
	return total


# Yearly financial simulation across all owned businesses
static func simulate_yearly_businesses() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var total_businesses: int = PlayerData.owned_businesses.size()

	for b in PlayerData.owned_businesses:
		var type_id: String = str(b.get("type_id", ""))
		var def := get_business_type_by_id(type_id)
		if def.is_empty():
			continue

		var b_name: String = str(b.get("name", "Enterprise"))
		var min_rev: int = int(def.get("base_revenue_min", 60000))
		var max_rev: int = int(def.get("base_revenue_max", 120000))
		var base_opex: int = int(def.get("base_opex", 45000))

		var emp_count: int = int(b.get("employees", 4))
		var mkt: int = int(b.get("marketing_budget", 5000))
		var branches: int = int(b.get("branches", 1))
		var facility_tier: int = int(b.get("facility_tier", 1))
		var rep: int = int(b.get("reputation", 75))

		# Macro-economic climate roll (Boom 15%, Stable 45%, Soft 25%, Recession 15%)
		var econ_roll := randi_range(1, 100)
		var market_mult: float = 1.0
		var market_label := "Normal"
		if econ_roll <= 15:
			market_mult = randf_range(1.15, 1.30)
			market_label = "Economic Boom"
		elif econ_roll <= 60:
			market_mult = randf_range(0.88, 1.08)
			market_label = "Stable"
		elif econ_roll <= 85:
			market_mult = randf_range(0.58, 0.78)
			market_label = "Market Slump"
		else:
			market_mult = randf_range(0.35, 0.52)
			market_label = "Industry Recession"

		# Revenue modifiers
		var mkt_mult: float = 0.85 + (float(mkt) / 35000.0) # $0 marketing causes -15% demand
		var emp_mult: float = 0.75 + (float(emp_count) * 0.05)
		var rep_mult: float = clampf(float(rep) / 75.0, 0.50, 1.25)

		var generated_revenue: int = int(float(randi_range(min_rev, max_rev)) * mkt_mult * emp_mult * market_mult * rep_mult)
		var scale: float = float(b.get("revenue_scale", 1.0))
		generated_revenue = int(generated_revenue * scale)

		# Operating Expenses:
		# Base operational expenses include foundational facility overhead and core staff (2 employees)
		var baseline_staff: int = 2
		var extra_staff: int = maxi(0, emp_count - baseline_staff)
		var extra_payroll: int = extra_staff * 28000
		var loan_bal: int = int(b.get("loan_balance", 0))
		var loan_interest: int = int(float(loan_bal) * float(b.get("loan_interest_rate", BUSINESS_LOAN_INTEREST_RATE)))
		var extra_facility: int = maxi(0, facility_tier - 1) * 14000
		var total_opex: int = int((base_opex + extra_payroll + extra_facility) * scale) + mkt + loan_interest

		var net_profit: int = generated_revenue - total_opex

		# Progressive Conglomerate & Portfolio Tax Calculation (the more businesses you have the more tax you pay)
		var tax_rate := get_corporate_tax_rate(total_businesses, net_profit)
		var tax_accrued: int = 0
		var player_payout: int = 0
		if net_profit > 0:
			tax_accrued = int(float(net_profit) * tax_rate)
			# 20% of the business net profit is automatically transferred to the character's bank account
			var owner_frac: float = float(b.get("owner_fraction", 1.0))
			player_payout = int(float(net_profit) * 0.20 * owner_frac)
			if player_payout > 0:
				PlayerData.bank_savings += player_payout
				PlayerData.add_life_log_entry("💰 %s PROFIT DISTRIBUTION: 20%% of net profit ($%d) was automatically transferred to your bank account!" % [b_name, player_payout], "finance")
			
			# Remaining after-tax profit (after 20% owner transfer) enters corporate treasury
			var after_tax_profit := net_profit - tax_accrued
			var retained_earnings := maxi(0, after_tax_profit - player_payout)
			b["treasury"] = int(b.get("treasury", 0)) + retained_earnings
			b["consecutive_losses"] = 0
		else:
			# Loss burns corporate treasury reserves directly
			b["treasury"] = int(b.get("treasury", 0)) + net_profit
			b["consecutive_losses"] = int(b.get("consecutive_losses", 0)) + 1

		b["annual_revenue"] = generated_revenue
		b["annual_opex"] = total_opex
		b["net_profit"] = net_profit
		b["cumulative_net_profit"] = int(b.get("cumulative_net_profit", 0)) + net_profit - tax_accrued

		# Valuation updates (uncapped: scales dynamically past $10B without ceiling)
		if not b.has("listing_uid") or str(b.get("listing_uid", "")).is_empty():
			var treasury_equity: int = int(maxi(0, int(b.get("treasury", 0))) * 0.40)
			var base_val: int = int(generated_revenue * 0.65) + maxi(0, int(net_profit * 1.50)) + (branches * 35000) + treasury_equity
			var prev_val: int = int(b.get("valuation", 15000))
			b["valuation"] = maxi(15000, maxi(prev_val + int(net_profit * 0.35), base_val))

		b_name = str(b.get("name", "Enterprise"))
		var profit_str: String = ("+$%d" % net_profit) if net_profit >= 0 else ("-$%d" % abs(net_profit))

		PlayerData.add_life_log_entry("🏢 %s Report [%s]: Revenue: $%d | OpEx: $%d | Net: %s | Corp Tax (%d%%): $%d | Treasury: $%d" % [
			b_name,
			market_label,
			generated_revenue,
			total_opex,
			profit_str,
			int(tax_rate * 100),
			tax_accrued,
			int(b.get("treasury", 0))
		], "finance")

		# Check for Business Flop & Bankruptcy
		var is_flop := false
		var cur_treasury: int = int(b.get("treasury", 0))
		var cons_losses: int = int(b.get("consecutive_losses", 0))
		var biz_age: int = PlayerData.age - int(b.get("founded_age", PlayerData.age))
		var startup_cost: int = int(def.get("startup_cost", 75000))
		var max_deficit: int = maxi(80000, int(startup_cost * 0.75))

		if cur_treasury < -max_deficit:
			is_flop = true
		elif biz_age > 2:
			# Established businesses failing over 3+ consecutive years
			if cons_losses >= 3 and cur_treasury < -maxi(30000, int(startup_cost * 0.25)):
				is_flop = true
			elif cons_losses >= 4 and cur_treasury <= 0:
				is_flop = true

		var close_reason: String = ""
		var personal_liability: int = 0
		if is_flop:
			b["is_closed"] = true
			PlayerData.happiness = maxi(0, PlayerData.happiness - 15)
			PlayerData.credit_score = maxi(350, PlayerData.credit_score - 30)
			close_reason = "Operating losses over consecutive fiscal years depleted corporate treasury reserves (Deficit: -$%d) during a %s. Creditors called in liabilities and liquidated commercial assets." % [absi(cur_treasury), market_label]
			b["close_reason"] = close_reason
			PlayerData.add_life_log_entry("💥 BUSINESS FLOPPED & DISSOLVED: '%s' suffered catastrophic deficits during a %s and has flopped! Creditors liquidated remaining assets and shuttered operations permanently." % [b_name, market_label], "finance")
			PlayerData.add_milestone("Enterprise '%s' flopped and closed." % b_name, PlayerData.age, "📉")
			if loan_bal > 0:
				personal_liability = mini(35000, loan_bal / 2)
				PlayerData.debt += personal_liability
				PlayerData.add_life_log_entry("⚠️ Creditors assigned $%d in liquidated loan guarantee obligations to your personal debt." % personal_liability, "finance")

		# Illicit Unlicensed Business Audit / Crime / Lawsuits / Prison check
		if not bool(b.get("is_closed", false)) and bool(b.get("is_unlicensed", false)):
			var audit_chance: float = clampf(0.35 + (float(branches) * 0.06) + (float(emp_count) * 0.02), 0.35, 0.85)
			if randf() < audit_chance:
				var raid_roll := randi_range(1, 100)
				if raid_roll <= 45:
					# Fine & civil lawsuits
					var fine: int = randi_range(30000, 85000) + int(generated_revenue * 0.20)
					var b_treasury: int = int(b.get("treasury", 0))
					if b_treasury >= fine:
						b["treasury"] = b_treasury - fine
					else:
						var rem_fine: int = fine - b_treasury
						b["treasury"] = 0
						var paid_pers: int = mini(PlayerData.get_available_funds(), rem_fine)
						PlayerData.debit_funds(paid_pers)
						PlayerData.debt += rem_fine - paid_pers
					b["reputation"] = maxi(5, int(b.get("reputation", 75)) - 25)
					PlayerData.add_life_log_entry("⚖️ UNLICENSED AUDIT & LAWSUIT: Regulatory marshals raided %s for operating without a commercial license! Slapped with $%d in fines and civil lawsuits." % [b_name, fine], "crime")
				elif raid_roll <= 75:
					# Padlocked & dissolved
					b["is_closed"] = true
					close_reason = "Regulatory marshals and municipal licensing inspectors padlocked and seized the premises for conducting commercial operations without required state licenses."
					b["close_reason"] = close_reason
					PlayerData.add_life_log_entry("🚨 FORCED CLOSURE & SEIZURE: Court injunction padlocked and forcefully shuttered '%s' for illicit unlicensed operation! Operations permanently dissolved." % b_name, "crime")
				else:
					# Prison Sentence & shutdown
					b["is_closed"] = true
					var sentence: int = randi_range(1, 3)
					PlayerData.is_in_prison = true
					PlayerData.prison_sentence_years = sentence
					PlayerData.job_id = ""
					PlayerData.job_title = ""
					PlayerData.job_company = ""
					PlayerData.job_salary = 0
					PlayerData.happiness = maxi(0, PlayerData.happiness - 35)
					close_reason = "Federal authorities shuttered and confiscated the enterprise following a criminal conviction and %d-year prison sentence for running an unlicensed enterprise." % sentence
					b["close_reason"] = close_reason
					PlayerData.add_life_log_entry("⛓️ CRIMINAL CONVICTION & PRISON: You were arrested by federal agents and sentenced to %d years in prison for running an illegal unlicensed enterprise ('%s')! Enterprise confiscated." % [sentence, b_name], "crime")

		results.append({
			"name": b_name,
			"revenue": generated_revenue,
			"opex": total_opex,
			"net_profit": net_profit,
			"player_payout": player_payout,
			"tax_accrued": tax_accrued,
			"treasury": int(b.get("treasury", 0)),
			"is_closed": bool(b.get("is_closed", false)),
			"close_reason": str(b.get("close_reason", close_reason)),
			"personal_liability": personal_liability,
			"market_label": market_label
		})

	# Clean up any closed/flopped/raided businesses
	for i in range(PlayerData.owned_businesses.size() - 1, -1, -1):
		if bool(PlayerData.owned_businesses[i].get("is_closed", false)):
			load("res://scripts/economy/finance_market.gd").release_business(PlayerData, PlayerData.owned_businesses[i])
			PlayerData.owned_businesses.remove_at(i)

	return results


# Financial Operations
static func pay_business_taxes(b: Dictionary, amount: int = -1) -> Dictionary:
	var unpaid: int = int(b.get("unpaid_taxes", 0))
	if unpaid <= 0:
		return {"success": false, "message": "No corporate taxes currently due."}

	var to_pay: int = unpaid if (amount <= 0 or amount > unpaid) else amount
	var treasury: int = int(b.get("treasury", 0))

	if treasury >= to_pay:
		b["treasury"] = treasury - to_pay
		b["unpaid_taxes"] = unpaid - to_pay
	else:
		# Can draw from owner personal cash if treasury is insufficient
		var rem: int = to_pay - treasury
		if PlayerData.get_available_funds() >= rem:
			b["treasury"] = 0
			PlayerData.debit_funds(rem)
			b["unpaid_taxes"] = unpaid - to_pay
		else:
			return {"success": false, "message": "Insufficient funds in treasury ($%d) and personal funds to pay $%d taxes." % [treasury, to_pay]}

	b["last_tax_paid_year"] = PlayerData.age
	PlayerData.add_life_log_entry("🏛️ CORPORATE TAXES PAID: %s paid $%d in state corporate taxes. Unpaid balance: $%d." % [
		str(b.get("name", "Business")),
		to_pay,
		int(b.get("unpaid_taxes", 0))
	], "finance")

	return {"success": true, "message": "Successfully paid $%d in corporate taxes." % to_pay}


static func take_business_loan(b: Dictionary, principal: int) -> Dictionary:
	if principal <= 0:
		return {"success": false, "message": "Invalid loan amount."}

	var cur_loan: int = int(b.get("loan_balance", 0))
	var val: int = int(b.get("valuation", 50000))
	var max_credit_limit: int = maxi(100000, val * 2)

	if cur_loan + principal > max_credit_limit:
		return {"success": false, "message": "Commercial credit limit exceeded! Max borrowing limit is $%d (Current Loan: $%d)." % [max_credit_limit, cur_loan]}

	b["loan_balance"] = cur_loan + principal
	b["treasury"] = int(b.get("treasury", 0)) + principal

	PlayerData.add_life_log_entry("🏦 COMMERCIAL LOAN APPROVED: %s secured a $%d bank loan at 7.5%% APR. Disbursed into business treasury." % [
		str(b.get("name", "Business")),
		principal
	], "finance")

	return {"success": true, "message": "Loan of $%d disbursed to business treasury." % principal}


static func repay_business_loan(b: Dictionary, amount: int) -> Dictionary:
	var cur_loan: int = int(b.get("loan_balance", 0))
	if cur_loan <= 0:
		return {"success": false, "message": "No active commercial loan to repay."}

	var to_repay: int = mini(cur_loan, amount)
	var treasury: int = int(b.get("treasury", 0))

	if treasury >= to_repay:
		b["treasury"] = treasury - to_repay
		b["loan_balance"] = cur_loan - to_repay
	else:
		var rem: int = to_repay - treasury
		if PlayerData.get_available_funds() >= rem:
			b["treasury"] = 0
			PlayerData.debit_funds(rem)
			b["loan_balance"] = cur_loan - to_repay
		else:
			return {"success": false, "message": "Insufficient funds in treasury ($%d) and personal funds to repay $%d." % [treasury, to_repay]}

	PlayerData.add_life_log_entry("🏦 LOAN PRINCIPAL REPAID: %s repaid $%d towards its commercial loan balance. Remaining: $%d." % [
		str(b.get("name", "Business")),
		to_repay,
		int(b.get("loan_balance", 0))
	], "finance")

	return {"success": true, "message": "Repaid $%d towards commercial loan." % to_repay}


static func withdraw_owner_dividend(b: Dictionary, amount: int) -> Dictionary:
	var treasury: int = int(b.get("treasury", 0))
	if amount <= 0:
		return {"success": false, "message": "Invalid dividend amount."}
	if treasury - int(b.get("unpaid_taxes", 0)) < amount:
		return {"success": false, "message": "Insufficient funds in business treasury (Current: $%d)." % treasury}

	b["treasury"] = treasury - amount
	# Listed businesses distribute the public 20% to outside shareholders.
	var owner_amount := int(amount * float(b.get("owner_fraction", 1.0)))
	PlayerData.money += owner_amount
	load("res://scripts/economy/finance_market.gd").distribute_dividend(PlayerData, b, amount)

	PlayerData.add_life_log_entry("💰 OWNER DIVIDEND: You withdrew $%d from %s into your personal pocket cash." % [
		owner_amount,
		str(b.get("name", "Business"))
	], "finance")

	return {"success": true, "message": "Distributed $%d; your ownership share paid $%d to personal cash." % [amount, owner_amount]}


static func deposit_owner_capital(b: Dictionary, amount: int) -> Dictionary:
	if amount <= 0:
		return {"success": false, "message": "Invalid capital amount."}
	if PlayerData.get_available_funds() < amount:
		return {"success": false, "message": "Insufficient personal funds to inject capital."}

	PlayerData.debit_funds(amount)
	b["treasury"] = int(b.get("treasury", 0)) + amount

	PlayerData.add_life_log_entry("💵 CAPITAL INJECTION: You contributed $%d personal funds into %s treasury." % [
		amount,
		str(b.get("name", "Business"))
	], "finance")

	return {"success": true, "message": "Injected $%d capital into business treasury." % amount}


static func adjust_staff(b: Dictionary, delta: int) -> Dictionary:
	var cur: int = int(b.get("employees", 4))
	var new_count: int = cur + delta
	if new_count < 1:
		return {"success": false, "message": "A business must maintain at least 1 employee to operate."}
	if new_count > 50:
		return {"success": false, "message": "Maximum facility employee headcount reached."}

	b["employees"] = new_count
	var act_str: String = "hired %d additional staff" % delta if delta > 0 else "laid off %d staff" % abs(delta)
	return {"success": true, "message": "Headcount adjusted: %s. Total staff: %d." % [act_str, new_count]}


static func liquidate_business(biz_uid: String) -> Dictionary:
	var found_idx: int = -1
	for i in range(PlayerData.owned_businesses.size()):
		if str(PlayerData.owned_businesses[i].get("uid", "")) == biz_uid:
			found_idx = i
			break

	if found_idx == -1:
		return {"success": false, "message": "Enterprise not found."}

	var b: Dictionary = PlayerData.owned_businesses[found_idx]
	var val: int = int(b.get("valuation", 20000))
	var treasury: int = int(b.get("treasury", 0))
	var loan: int = int(b.get("loan_balance", 0))
	var unpaid_tax: int = int(b.get("unpaid_taxes", 0))

	# Net liquidation proceeds: 75% Valuation (broker/liquidation fees) + Treasury - Loan - Unpaid taxes
	var net_proceeds: int = int(((int(val * 0.75) + treasury) - (loan + unpaid_tax)) * float(b.get("owner_fraction", 1.0)))
	load("res://scripts/economy/finance_market.gd").release_business(PlayerData, b)
	if net_proceeds > 0:
		PlayerData.money += net_proceeds
	else:
		var liability := -net_proceeds
		var paid := mini(PlayerData.get_available_funds(), liability)
		PlayerData.debit_funds(paid)
		PlayerData.debt += liability - paid

	var b_name: String = str(b.get("name", "Enterprise"))
	PlayerData.owned_businesses.remove_at(found_idx)

	PlayerData.add_life_log_entry("💼 BUSINESS SOLD: You liquidated '%s' for net cash proceeds of $%d." % [b_name, net_proceeds], "milestone")

	return {"success": true, "message": "Successfully liquidated '%s' for $%d net proceeds." % [b_name, net_proceeds]}

