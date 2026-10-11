class_name DailyJobsCatalog
extends RefCounted

# =============================================================================
# DAILY JOBS & GIG CATALOG
# Life.exe Daily-Paying Employment, Part-Time Work, and Gig Work System.
# =============================================================================

# Payment Types
const PAYMENT_TYPE_MONTHLY_SALARY := "MONTHLY_SALARY"
const PAYMENT_TYPE_DAILY_WAGE     := "DAILY_WAGE"
const PAYMENT_TYPE_PER_TASK       := "PER_TASK"
const PAYMENT_TYPE_PER_PROJECT    := "PER_PROJECT"

# Categories
const CATEGORY_ENTRY   := "entry_level"
const CATEGORY_MANUAL  := "manual_labor"
const CATEGORY_GIG     := "gig_work"
const CATEGORY_SKILLED := "skilled_daily"

const CATEGORIES: Array[Dictionary] = [
	{
		"id": CATEGORY_ENTRY,
		"name": "Entry-Level Daily & Part-Time",
		"icon": "☕",
		"desc": "Accessible jobs in customer service, retail, and hospitality. Daily wage payments."
	},
	{
		"id": CATEGORY_MANUAL,
		"name": "Manual Labor & Fieldwork",
		"icon": "🔨",
		"desc": "Physically demanding work with higher daily earnings and stamina requirements."
	},
	{
		"id": CATEGORY_GIG,
		"name": "On-Demand Gigs & Tasks",
		"icon": "⚡",
		"desc": "Flexible short-term assignments. Complete tasks on your own time with instant per-task payout."
	},
	{
		"id": CATEGORY_SKILLED,
		"name": "Higher-Skilled Daily Work",
		"icon": "💼",
		"desc": "Technical trades and specialized freelance roles requiring proven intellect, stamina, or fitness."
	}
]

const JOBS: Dictionary = {
	# -------------------------------------------------------------------------
	# 1. ENTRY-LEVEL EMPLOYMENT
	# -------------------------------------------------------------------------
	"cafe_assistant": {
		"id": "cafe_assistant",
		"title": "Café Assistant",
		"category": CATEGORY_ENTRY,
		"job_type": "part_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 85,
		"hourly_rate": 17,
		"hours_per_shift": 5,
		"workdays": [1, 2, 3, 4, 5], # Mon-Fri
		"min_age": 14,
		"requirements": {
			"min_health": 25,
			"min_happiness": 15
		},
		"stat_effects": {
			"happiness_delta": 1,
			"mental_state_delta": 0,
			"health_delta": -1,
			"smarts_gain": 1
		},
		"company_pool": ["Cyber Roasters", "Bean & Brew Espresso", "Neon Cup Café", "Velvet Steam Café"],
		"description": "Brew artisan coffee, restock pastry counters, and serve urban commuters during morning rushes."
	},
	"restaurant_server": {
		"id": "restaurant_server",
		"title": "Restaurant Server",
		"category": CATEGORY_ENTRY,
		"job_type": "part_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 100,
		"hourly_rate": 20,
		"hours_per_shift": 5,
		"workdays": [1, 2, 3, 4, 5],
		"min_age": 16,
		"requirements": {
			"min_health": 30,
			"min_looks": 25
		},
		"stat_effects": {
			"happiness_delta": 1,
			"mental_state_delta": -1,
			"health_delta": -2,
			"smarts_gain": 1
		},
		"company_pool": ["Metro Bistro", "Golden Dragon Diner", "The Downtown Grill", "Trattoria Milano"],
		"description": "Take guest orders, carry dining trays, and provide attentive table hospitality for tips and daily wages."
	},
	"retail_assistant": {
		"id": "retail_assistant",
		"title": "Retail Assistant",
		"category": CATEGORY_ENTRY,
		"job_type": "part_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 90,
		"hourly_rate": 18,
		"hours_per_shift": 5,
		"workdays": [1, 2, 3, 4, 5],
		"min_age": 14,
		"requirements": {
			"min_health": 25,
			"min_smarts": 20
		},
		"stat_effects": {
			"happiness_delta": 0,
			"mental_state_delta": 0,
			"health_delta": -1,
			"smarts_gain": 1
		},
		"company_pool": ["SmartMart Supercenter", "Apex Department Store", "City Outfitters", "TechNexus Electronics"],
		"description": "Assist shoppers, organize fashion shelves, operate cash registers, and manage apparel stock."
	},
	"cleaner": {
		"id": "cleaner",
		"title": "Cleaner",
		"category": CATEGORY_ENTRY,
		"job_type": "part_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 75,
		"hourly_rate": 15,
		"hours_per_shift": 5,
		"workdays": [1, 2, 3, 4, 5],
		"min_age": 14,
		"requirements": {
			"min_health": 25
		},
		"stat_effects": {
			"happiness_delta": -1,
			"mental_state_delta": 0,
			"health_delta": -2,
			"smarts_gain": 0
		},
		"company_pool": ["SparkleClean Facilities", "Metro Janitorial Co.", "CleanPro Services", "Pristine Spaces"],
		"description": "Sanitize office corridors, vacuum corporate floors, and empty recycling receptacles after business hours."
	},
	"car_washer": {
		"id": "car_washer",
		"title": "Car Washer",
		"category": CATEGORY_ENTRY,
		"job_type": "part_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 70,
		"hourly_rate": 14,
		"hours_per_shift": 5,
		"workdays": [6, 7], # Weekend shifts
		"min_age": 12, # Lawful light work for early teens
		"requirements": {
			"min_health": 20
		},
		"stat_effects": {
			"happiness_delta": 1,
			"mental_state_delta": 0,
			"health_delta": 1,
			"smarts_gain": 0
		},
		"company_pool": ["QuickShine Auto Detailing", "Speedy Wash Depot", "Neighborhood Hand Wash", "Crystal Glaze"],
		"description": "Rinse exterior chassis, sponge soapy foam, and buff luxury rims on sunny weekend afternoons."
	},
	"grocery_assistant": {
		"id": "grocery_assistant",
		"title": "Grocery Store Assistant",
		"category": CATEGORY_ENTRY,
		"job_type": "part_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 85,
		"hourly_rate": 17,
		"hours_per_shift": 5,
		"workdays": [1, 2, 3, 4, 5],
		"min_age": 14,
		"requirements": {
			"min_health": 25
		},
		"stat_effects": {
			"happiness_delta": 0,
			"mental_state_delta": 0,
			"health_delta": -1,
			"smarts_gain": 1
		},
		"company_pool": ["FreshMarket Grocery", "ValueFoods Mart", "GreenBounty Organic", "City Grocers"],
		"description": "Stack fresh agricultural produce, replenish milk refrigeration units, and bag customer purchases."
	},

	# -------------------------------------------------------------------------
	# 2. MANUAL LABOR
	# -------------------------------------------------------------------------
	"warehouse_worker": {
		"id": "warehouse_worker",
		"title": "Warehouse Worker",
		"category": CATEGORY_MANUAL,
		"job_type": "full_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 140,
		"hourly_rate": 17.5,
		"hours_per_shift": 8,
		"workdays": [1, 2, 3, 4, 5],
		"min_age": 18, # Hazardous machinery / heavy pallets
		"requirements": {
			"min_health": 45
		},
		"stat_effects": {
			"happiness_delta": -2,
			"mental_state_delta": -1,
			"health_delta": -3,
			"smarts_gain": 0
		},
		"company_pool": ["OmniLogistics Hub", "Apex Freight Systems", "TransGlobal Depots", "PrimeCargo Logistics"],
		"description": "Operate pallet jacks, load freight shipping containers, and organize high-density industrial storage."
	},
	"construction_helper": {
		"id": "construction_helper",
		"title": "Construction Helper",
		"category": CATEGORY_MANUAL,
		"job_type": "full_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 155,
		"hourly_rate": 19.3,
		"hours_per_shift": 8,
		"workdays": [1, 2, 3, 4, 5],
		"min_age": 18, # Hazardous construction site
		"requirements": {
			"min_health": 50
		},
		"stat_effects": {
			"happiness_delta": -2,
			"mental_state_delta": -1,
			"health_delta": -4,
			"smarts_gain": 1
		},
		"company_pool": ["Keystone Builders", "Titan Infrastructure", "Urban Foundation Co.", "Skyline Contractors"],
		"description": "Mix concrete mortar, haul scaffolding beams, and clear hazardous construction rubble on high-rise builds."
	},
	"farm_worker": {
		"id": "farm_worker",
		"title": "Farm Worker",
		"category": CATEGORY_MANUAL,
		"job_type": "full_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 120,
		"hourly_rate": 15,
		"hours_per_shift": 8,
		"workdays": [1, 2, 3, 4, 5],
		"min_age": 16,
		"requirements": {
			"min_health": 40
		},
		"stat_effects": {
			"happiness_delta": 1,
			"mental_state_delta": 1,
			"health_delta": -2,
			"smarts_gain": 0
		},
		"company_pool": ["Green Valley Farms", "Sunridge Orchards", "Prairie Harvest Co.", "Heritage Agritech"],
		"description": "Harvest organic crops, tend irrigation canals, and care for livestock pastures in the open air."
	},
	"landscaping_assistant": {
		"id": "landscaping_assistant",
		"title": "Landscaping Assistant",
		"category": CATEGORY_MANUAL,
		"job_type": "full_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 125,
		"hourly_rate": 15.6,
		"hours_per_shift": 8,
		"workdays": [1, 2, 3, 4, 5],
		"min_age": 16,
		"requirements": {
			"min_health": 35
		},
		"stat_effects": {
			"happiness_delta": 2,
			"mental_state_delta": 1,
			"health_delta": -2,
			"smarts_gain": 0
		},
		"company_pool": ["Evergreen Gardens", "Terra Design Landscaping", "Botanical Care Co.", "GreenHorizon Lawns"],
		"description": "Trim residential ornamental hedges, plant decorative shrubs, and lay fresh sod across suburban estates."
	},
	"moving_assistant": {
		"id": "moving_assistant",
		"title": "Moving Assistant",
		"category": CATEGORY_MANUAL,
		"job_type": "part_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 135,
		"hourly_rate": 22.5,
		"hours_per_shift": 6,
		"workdays": [1, 3, 5, 6],
		"min_age": 16,
		"requirements": {
			"min_health": 45
		},
		"stat_effects": {
			"happiness_delta": 0,
			"mental_state_delta": -1,
			"health_delta": -3,
			"smarts_gain": 0
		},
		"company_pool": ["SwiftRelocate Movers", "HeavyLift Logistics", "CityMove Express", "Apex Van Lines"],
		"description": "Navigate steep stairwells carrying solid oak furniture, wrap delicate antiques, and strap freight trucks."
	},

	# -------------------------------------------------------------------------
	# 3. GIG EMPLOYMENT (PER-TASK ON-DEMAND ASSIGNMENTS)
	# -------------------------------------------------------------------------
	"food_delivery_rider": {
		"id": "food_delivery_rider",
		"title": "Food Delivery Rider",
		"category": CATEGORY_GIG,
		"job_type": "gig",
		"payment_type": PAYMENT_TYPE_PER_TASK,
		"daily_wage": 40, # Typical payout per gig
		"hourly_rate": 20,
		"hours_per_shift": 2,
		"workdays": [1, 2, 3, 4, 5, 6, 7],
		"min_age": 18, # Motorized vehicle / street traffic delivery
		"requirements": {
			"min_health": 30
		},
		"stat_effects": {
			"happiness_delta": 0,
			"mental_state_delta": -1,
			"health_delta": -1,
			"smarts_gain": 0
		},
		"company_pool": ["QuickBite Delivery", "DashNow Urban Eats", "StreetFeast Express", "Pulse Couriers"],
		"description": "Accept on-demand meal deliveries from busy restaurants and speed through traffic directly to customer doors."
	},
	"package_courier": {
		"id": "package_courier",
		"title": "Package Courier",
		"category": CATEGORY_GIG,
		"job_type": "gig",
		"payment_type": PAYMENT_TYPE_PER_TASK,
		"daily_wage": 35,
		"hourly_rate": 18,
		"hours_per_shift": 2,
		"workdays": [1, 2, 3, 4, 5, 6, 7],
		"min_age": 16, # Bicycle / foot courier
		"requirements": {
			"min_health": 30
		},
		"stat_effects": {
			"happiness_delta": 0,
			"mental_state_delta": 0,
			"health_delta": -1,
			"smarts_gain": 0
		},
		"company_pool": ["DropFast Parcel Network", "CityPouch Dispatch", "Apex Express Couriers", "FlashDrop Co."],
		"description": "Transport legal contracts, confidential envelopes, and compact priority parcels across metropolitan districts."
	},
	"freelance_graphic_designer": {
		"id": "freelance_graphic_designer",
		"title": "Freelance Graphic Designer",
		"category": CATEGORY_GIG,
		"job_type": "gig",
		"payment_type": PAYMENT_TYPE_PER_TASK,
		"daily_wage": 95,
		"hourly_rate": 30,
		"hours_per_shift": 3,
		"workdays": [1, 2, 3, 4, 5, 6, 7],
		"min_age": 14, # Digital creative work
		"requirements": {
			"min_smarts": 35
		},
		"stat_effects": {
			"happiness_delta": 2,
			"mental_state_delta": 0,
			"health_delta": 0,
			"smarts_gain": 1
		},
		"company_pool": ["PixelForge Creatives", "DesignCrowd Gigs", "BrandStream Agency", "VectorBloom Studios"],
		"description": "Craft stylish vector logos, brand typography packages, and promotional social banners for indie clients."
	},
	"freelance_writer": {
		"id": "freelance_writer",
		"title": "Freelance Writer",
		"category": CATEGORY_GIG,
		"job_type": "gig",
		"payment_type": PAYMENT_TYPE_PER_TASK,
		"daily_wage": 75,
		"hourly_rate": 25,
		"hours_per_shift": 3,
		"workdays": [1, 2, 3, 4, 5, 6, 7],
		"min_age": 14,
		"requirements": {
			"min_smarts": 35
		},
		"stat_effects": {
			"happiness_delta": 1,
			"mental_state_delta": 0,
			"health_delta": 0,
			"smarts_gain": 2
		},
		"company_pool": ["InkWell Copywriting", "TechPulse Gazette", "ContentCrafters Online", "UrbanChronicle Press"],
		"description": "Research tech topics, draft search-engine optimized articles, and polish corporate promotional newsletters."
	},
	"private_tutor": {
		"id": "private_tutor",
		"title": "Private Tutor",
		"category": CATEGORY_GIG,
		"job_type": "gig",
		"payment_type": PAYMENT_TYPE_PER_TASK,
		"daily_wage": 55,
		"hourly_rate": 27.5,
		"hours_per_shift": 2,
		"workdays": [1, 2, 3, 4, 5, 6, 7],
		"min_age": 12, # Peer tutoring for math/sciences
		"requirements": {
			"min_smarts": 45
		},
		"stat_effects": {
			"happiness_delta": 2,
			"mental_state_delta": 1,
			"health_delta": 0,
			"smarts_gain": 2
		},
		"company_pool": ["BrightMinds Tutoring", "PeerTutor Alliance", "Scholastic Mentors", "AcademiaPrep Hub"],
		"description": "Help younger students understand algebra, chemistry formulas, and literature essay construction."
	},
	"pet_sitter": {
		"id": "pet_sitter",
		"title": "Pet Sitter",
		"category": CATEGORY_GIG,
		"job_type": "gig",
		"payment_type": PAYMENT_TYPE_PER_TASK,
		"daily_wage": 45,
		"hourly_rate": 22.5,
		"hours_per_shift": 2,
		"workdays": [1, 2, 3, 4, 5, 6, 7],
		"min_age": 12, # Lawful light work for early teens
		"requirements": {
			"min_health": 20,
			"min_happiness": 20
		},
		"stat_effects": {
			"happiness_delta": 4,
			"mental_state_delta": 2,
			"health_delta": 1,
			"smarts_gain": 0
		},
		"company_pool": ["RoverPaws Petcare", "Neighborhood Dog Walking", "CozyPet Sitters", "HappyTails Agency"],
		"description": "Walk energetic retrievers through neighborhood parks, feed playful felines, and provide pet companionship."
	},
	"photographer": {
		"id": "photographer",
		"title": "Photographer",
		"category": CATEGORY_GIG,
		"job_type": "gig",
		"payment_type": PAYMENT_TYPE_PER_TASK,
		"daily_wage": 85,
		"hourly_rate": 28,
		"hours_per_shift": 3,
		"workdays": [1, 2, 3, 4, 5, 6, 7],
		"min_age": 14,
		"requirements": {
			"min_smarts": 25,
			"min_looks": 20
		},
		"stat_effects": {
			"happiness_delta": 2,
			"mental_state_delta": 1,
			"health_delta": 0,
			"smarts_gain": 1
		},
		"company_pool": ["ShutterSnap Studios", "CityLens Photography", "Freelance Photo Hub", "Prism Portraits"],
		"description": "Capture commercial lifestyle photos, headshots, and scenic cityscape portfolios for local business clients."
	},

	# -------------------------------------------------------------------------
	# 4. HIGHER-SKILLED DAILY WORK
	# -------------------------------------------------------------------------
	"freelance_programmer": {
		"id": "freelance_programmer",
		"title": "Freelance Programmer",
		"category": CATEGORY_SKILLED,
		"job_type": "part_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 260,
		"hourly_rate": 43.3,
		"hours_per_shift": 6,
		"workdays": [1, 2, 3, 4, 5],
		"min_age": 16,
		"requirements": {
			"min_smarts": 55
		},
		"stat_effects": {
			"happiness_delta": 1,
			"mental_state_delta": -1,
			"health_delta": -1,
			"smarts_gain": 3
		},
		"company_pool": ["CyberCore Systems", "AlgoTech Labs", "Nexus Digital Solutions", "BitForge Engineering"],
		"description": "Architect scalable backend endpoints, squash distributed software bugs, and write unit test pipelines."
	},
	"electrician": {
		"id": "electrician",
		"title": "Electrician",
		"category": CATEGORY_SKILLED,
		"job_type": "full_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 230,
		"hourly_rate": 28.7,
		"hours_per_shift": 8,
		"workdays": [1, 2, 3, 4, 5],
		"min_age": 18, # High-voltage electrical safety
		"requirements": {
			"min_smarts": 45,
			"min_health": 40
		},
		"stat_effects": {
			"happiness_delta": 0,
			"mental_state_delta": -1,
			"health_delta": -1,
			"smarts_gain": 2
		},
		"company_pool": ["VoltMaster Electric", "CircuitPro Services", "Metro Grid Systems", "Apex Power & Light"],
		"description": "Diagnose commercial circuit breakers, pull heavy copper wiring conduits, and test high-voltage transformers."
	},
	"plumber": {
		"id": "plumber",
		"title": "Plumber",
		"category": CATEGORY_SKILLED,
		"job_type": "full_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 220,
		"hourly_rate": 27.5,
		"hours_per_shift": 8,
		"workdays": [1, 2, 3, 4, 5],
		"min_age": 18, # Heavy industrial plumbing & fixtures
		"requirements": {
			"min_smarts": 35,
			"min_health": 45
		},
		"stat_effects": {
			"happiness_delta": -1,
			"mental_state_delta": 0,
			"health_delta": -2,
			"smarts_gain": 1
		},
		"company_pool": ["AquaFlow Plumbing", "Reliable Pipeworks", "Apex Sanitation Co.", "HydroFix Contractors"],
		"description": "Unclog main sewer drainage lines, solder copper water piping, and install residential hot water boilers."
	},
	"personal_trainer": {
		"id": "personal_trainer",
		"title": "Personal Trainer",
		"category": CATEGORY_SKILLED,
		"job_type": "part_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 175,
		"hourly_rate": 35,
		"hours_per_shift": 5,
		"workdays": [1, 2, 3, 4, 5],
		"min_age": 18, # Adult fitness instruction
		"requirements": {
			"min_health": 60,
			"min_looks": 35
		},
		"stat_effects": {
			"happiness_delta": 3,
			"mental_state_delta": 1,
			"health_delta": 2,
			"smarts_gain": 0
		},
		"company_pool": ["Titan Fitness Club", "IronBody Athletic Center", "Pulse Conditioning", "PeakPhysique Gym"],
		"description": "Coach private clients through resistance training circuits, evaluate nutritional macros, and boost athletic morale."
	},
	"event_photographer": {
		"id": "event_photographer",
		"title": "Event Photographer",
		"category": CATEGORY_SKILLED,
		"job_type": "part_time",
		"payment_type": PAYMENT_TYPE_DAILY_WAGE,
		"daily_wage": 200,
		"hourly_rate": 40,
		"hours_per_shift": 5,
		"workdays": [5, 6, 7], # Fri-Sun event shifts
		"min_age": 16,
		"requirements": {
			"min_smarts": 40,
			"min_looks": 30
		},
		"stat_effects": {
			"happiness_delta": 3,
			"mental_state_delta": 1,
			"health_delta": 0,
			"smarts_gain": 1
		},
		"company_pool": ["VividMoments Media", "Starlight Events", "Grand Gala Productions", "Opulent Lens Agency"],
		"description": "Photograph lavish corporate banquets, high-society galas, and festive weddings with professional lighting."
	}
}


# =============================================================================
# HELPER & QUERY METHODS
# =============================================================================

static func get_all_jobs() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for k in JOBS.keys():
		result.append(JOBS[k])
	return result


static func get_job_by_id(job_id: String) -> Dictionary:
	return JOBS.get(job_id, {})


static func get_jobs_by_category(cat_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for k in JOBS.keys():
		var j: Dictionary = JOBS[k]
		if j.get("category", "") == cat_id:
			result.append(j)
	return result


static func get_categories() -> Array[Dictionary]:
	return CATEGORIES


static func get_gigs() -> Array[Dictionary]:
	return get_jobs_by_category(CATEGORY_GIG)


## Deterministic ISO Day of Week calculation (1 = Monday, 7 = Sunday).
## Uses Tomohiko Sakamoto's algorithm for the Gregorian calendar.
static func calculate_day_of_week(y: int, m: int, d: int) -> int:
	var t: Array[int] = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
	var y_adj: int = y - (1 if m < 3 else 0)
	var w: int = (y_adj + int(floor(float(y_adj) / 4.0)) - int(floor(float(y_adj) / 100.0)) + int(floor(float(y_adj) / 400.0)) + t[m - 1] + d) % 7
	return 7 if w == 0 else w


static func get_day_name(day_of_week: int) -> String:
	match day_of_week:
		1: return "Monday"
		2: return "Tuesday"
		3: return "Wednesday"
		4: return "Thursday"
		5: return "Friday"
		6: return "Saturday"
		7: return "Sunday"
		_: return "Day"


static func is_workday(job: Dictionary, y: int, m: int, d: int) -> bool:
	var workdays: Array = job.get("workdays", [1, 2, 3, 4, 5])
	var dow := calculate_day_of_week(y, m, d)
	return workdays.has(dow)


static func format_schedule(job: Dictionary) -> String:
	var workdays: Array = job.get("workdays", [])
	var hours: int = int(job.get("hours_per_shift", 8))
	if workdays.size() == 7:
		return "Flexible (7 days/wk, %d hrs/shift)" % hours
	elif workdays == [1, 2, 3, 4, 5]:
		return "Mon – Fri (%d hrs/shift)" % hours
	elif workdays == [6, 7]:
		return "Sat – Sun (%d hrs/shift)" % hours
	elif workdays == [5, 6, 7]:
		return "Fri – Sun (%d hrs/shift)" % hours
	else:
		var day_abbrs := []
		var abbr_map := {1: "Mon", 2: "Tue", 3: "Wed", 4: "Thu", 5: "Fri", 6: "Sat", 7: "Sun"}
		for wd in workdays:
			if abbr_map.has(wd):
				day_abbrs.append(abbr_map[wd])
		return "%s (%d hrs/shift)" % [", ".join(day_abbrs), hours]


static func estimate_monthly_earnings(job: Dictionary) -> int:
	var payment_type: String = str(job.get("payment_type", PAYMENT_TYPE_DAILY_WAGE))
	if payment_type == PAYMENT_TYPE_MONTHLY_SALARY:
		return int(round(float(job.get("salary", 0)) / 12.0))
	var daily_pay: int = int(job.get("daily_wage", 0))
	var workdays: Array = job.get("workdays", [])
	var shifts_per_week: int = workdays.size() if not workdays.is_empty() else 5
	# Approx 4.33 weeks per month
	return int(round(float(daily_pay * shifts_per_week) * 4.33))


## Evaluates whether the player meets all requirements for a daily wage or part-time job.
static func can_apply(job: Dictionary, player_data: Node) -> Dictionary:
	if player_data == null or bool(player_data.get("is_dead")):
		return {"allowed": false, "reason": "Character unavailable."}

	if bool(player_data.get("is_in_prison")):
		return {"allowed": false, "reason": "Cannot work while incarcerated in state prison."}

	if bool(player_data.get("is_in_mental_institution")):
		return {"allowed": false, "reason": "Cannot work while under inpatient psychiatric care."}

	var age: int = int(player_data.get("age")) if player_data.get("age") != null else 17
	var min_age: int = int(job.get("min_age", 16))
	if age < min_age:
		return {
			"allowed": false,
			"reason": "Must be at least %d years old (currently %d). Age-restricted under child labor laws." % [min_age, age]
		}

	var reqs: Dictionary = job.get("requirements", {})
	var health: int = int(player_data.get("health")) if player_data.get("health") != null else 100
	var smarts: int = int(player_data.get("smarts")) if player_data.get("smarts") != null else 50
	var looks: int = int(player_data.get("looks")) if player_data.get("looks") != null else 50
	var happiness: int = int(player_data.get("happiness")) if player_data.get("happiness") != null else 50

	if reqs.has("min_health") and health < int(reqs["min_health"]):
		return {"allowed": false, "reason": "Requires at least %d Health (Current: %d)." % [int(reqs["min_health"]), health]}
	if reqs.has("min_smarts") and smarts < int(reqs["min_smarts"]):
		return {"allowed": false, "reason": "Requires at least %d Smarts (Current: %d)." % [int(reqs["min_smarts"]), smarts]}
	if reqs.has("min_looks") and looks < int(reqs["min_looks"]):
		return {"allowed": false, "reason": "Requires at least %d Looks (Current: %d)." % [int(reqs["min_looks"]), looks]}
	if reqs.has("min_happiness") and happiness < int(reqs["min_happiness"]):
		return {"allowed": false, "reason": "Requires at least %d Happiness (Current: %d)." % [int(reqs["min_happiness"]), happiness]}

	# Employment compatibility check
	var is_applying_full_time: bool = (job.get("job_type", "part_time") == "full_time")
	var has_primary_full_time: bool = (str(player_data.get("job_title")) != "")

	if is_applying_full_time and has_primary_full_time:
		return {
			"allowed": false,
			"reason": "You already hold a full-time position (%s). You must resign before taking another full-time role." % str(player_data.get("job_title"))
		}

	# Check if player already holds this exact job
	if str(player_data.get("job_id")) == str(job.get("id", "")):
		return {"allowed": false, "reason": "You are already employed in this position."}

	if "part_time_job" in player_data and player_data.part_time_job is Dictionary:
		if str(player_data.part_time_job.get("id", "")) == str(job.get("id", "")):
			return {"allowed": false, "reason": "You are already working this part-time job."}

	return {"allowed": true, "reason": "Qualified"}
