class_name LicenseManager
extends RefCounted

const CATEGORIES: Array[Dictionary] = [
	{
		"id": "fnb",
		"name": "F&B LICENSE",
		"icon": "🍸",
		"color": "#f59e0b",
		"description": "Hospitality certifications, spirits craft mixology, and commercial culinary standards."
	},
	{
		"id": "vehicle",
		"name": "VEHICLE LICENSE",
		"icon": "🚗",
		"color": "#38bdf8",
		"description": "State driver qualification, motorcycle operation, coastal yachting, and aviation pilot credentials."
	},
	{
		"id": "firearm",
		"name": "FIREARM LICENSE",
		"icon": "🎯",
		"color": "#ef4444",
		"description": "Concealed carry permits, tactical defense qualifications, and licensed investigative credentials."
	},
	{
		"id": "services",
		"name": "SERVICES LICENSE",
		"icon": "🛠️",
		"color": "#10b981",
		"description": "State trade boards, certified contracting, freelance media, appraisal, and forensic accounting credentials."
	}
]

const LICENSES: Array[Dictionary] = [
	# --- VEHICLE LICENSES ---
	{
		"id": "license_motorcycle",
		"name": "Motorcycle Operator License (Class M)",
		"icon": "🏍️",
		"category": "vehicle",
		"fee": 1800,
		"min_age": 16,
		"unlocked_feature": "Motorcycle Riding",
		"description": "Standard state road qualification permitting the legal operation of motorcycles, scooters, and high-powered sportbikes."
	},
	{
		"id": "license_car",
		"name": "Driver's License (Class C)",
		"icon": "🚗",
		"category": "vehicle",
		"fee": 2500,
		"min_age": 16,
		"unlocked_feature": "Car Driving",
		"description": "Certified driver's license permitting the legal operation of motor automobiles, coupes, and utility pickup trucks."
	},
	{
		"id": "flight_school",
		"name": "Flight School",
		"icon": "✈️",
		"category": "vehicle",
		"fee": 45000,
		"min_age": 18,
		"is_course": true,
		"unlocked_feature": "Eligibility for the Pilot License Exam",
		"description": "Complete ground school and supervised flight training. This course awards a completion certificate; you must then earn a separate pilot license before operating aircraft."
	},
	{
		"id": "license_pilot",
		"name": "Private Pilot & Rotorcraft License",
		"icon": "✈️",
		"category": "vehicle",
		"fee": 35000,
		"requires_license": "flight_school",
		"min_age": 18,
		"unlocked_feature": "Airplane & Helicopter Piloting",
		"description": "Federal aviation authority flight license permitting the legal operation of private propeller aircraft, business jets, and turbine helicopters."
	},
	{
		"id": "license_boating",
		"name": "Master Coastal Boater & Yachting License",
		"icon": "🛥️",
		"category": "vehicle",
		"fee": 12000,
		"min_age": 18,
		"unlocked_feature": "Yacht & Marine Vessel Piloting",
		"description": "Maritime safety qualification permitting the legal navigation and commanding of power speedboats, cruisers, and luxury ocean yachts."
	},
	{
		"id": "license_commercial_cdl",
		"name": "Commercial Driver License (Class A CDL)",
		"icon": "🚛",
		"category": "vehicle",
		"fee": 8500,
		"min_age": 21,
		"unlocked_feature": "Heavy Freight & Intermodal Transport Operation",
		"description": "Commercial trucking endorsement authorizing legal operation of heavy articulated freight trucks, tankers, and intermodal haulers."
	},
	{
		"id": "license_helicopter_commercial",
		"name": "Commercial Rotorcraft & Helicopter Flight License",
		"icon": "🚁",
		"category": "vehicle",
		"fee": 42000,
		"requires_license": "flight_school",
		"min_age": 21,
		"unlocked_feature": "Commercial Air Charter & Medevac Piloting",
		"description": "FAA commercial rotorcraft credential certifying turbine helicopter navigation, mountain flight rescue, and offshore aviation."
	},

	# --- F&B LICENSES ---
	{
		"id": "license_mixologist",
		"name": "Professional Mixologist & Spirits License",
		"icon": "🍸",
		"category": "fnb",
		"fee": 5500,
		"min_age": 21,
		"unlocked_feature": "Freelance Event Mixologist",
		"job_id": "freelance_mixologist",
		"description": "Beverage control commission certification allowing high-end cocktail craft, mixology catering, and private event bar service."
	},
	{
		"id": "license_food_safety",
		"name": "Commercial Food Safety & Kitchen Manager License",
		"icon": "🍽️",
		"category": "fnb",
		"fee": 24000,
		"min_age": 18,
		"unlocked_feature": "Commercial Kitchen & Catering Operations",
		"description": "Department of Public Health certification for food safety standards, culinary sanitation, and commercial kitchen leadership."
	},
	{
		"id": "license_distillery_master",
		"name": "Master Distiller & Spirits Artisan License",
		"icon": "🥃",
		"category": "fnb",
		"fee": 18000,
		"min_age": 21,
		"unlocked_feature": "Commercial Craft Spirits & Distillery Operations",
		"job_id": "job_craft_distiller",
		"description": "Alcohol & Tobacco Tax and Trade Bureau license permitting the distillation, oak barrel aging, and distribution of distilled spirits."
	},
	{
		"id": "license_commercial_baking",
		"name": "Master Artisan Baker & Confectioner License",
		"icon": "🥐",
		"category": "fnb",
		"fee": 12000,
		"min_age": 18,
		"unlocked_feature": "Commercial Patisserie & Baking Leadership",
		"job_id": "job_head_patissier",
		"description": "Culinary arts commission credential verifying master artisan pastry baking, industrial sourdough fermentation, and confectionery safety."
	},

	# --- FIREARM LICENSES ---
	{
		"id": "license_firearm",
		"name": "Concealed Carry & Tactical Firearms License",
		"icon": "🎯",
		"category": "firearm",
		"fee": 4500,
		"min_age": 21,
		"unlocked_feature": "Legal Concealed Carry & Tactical Defense",
		"description": "State qualification certifying firearms safety, tactical range proficiency, and legal concealed carry authorization."
	},
	{
		"id": "license_pi",
		"name": "Private Investigator License",
		"icon": "🕵️",
		"category": "firearm",
		"fee": 18000,
		"min_age": 21,
		"unlocked_feature": "Freelance Private Investigator",
		"job_id": "freelance_pi",
		"description": "Department of Licensing detective credential permitting covert surveillance, missing person skips, and corporate counter-espionage."
	},
	{
		"id": "license_tactical_security",
		"name": "Armed Tactical Security Officer License",
		"icon": "🛡️",
		"category": "firearm",
		"fee": 8000,
		"requires_license": "license_firearm",
		"min_age": 21,
		"unlocked_feature": "Armed Executive Protection & Vault Escort",
		"job_id": "job_armed_tactical_marshal",
		"description": "State board credential authorizing armed guard duties, high-threat executive escort, cash-in-transit armored vaults, and crisis security."
	},
	{
		"id": "license_armorer",
		"name": "Certified Tactical Armorer & Weapons Specialist License",
		"icon": "🧰",
		"category": "firearm",
		"fee": 16000,
		"min_age": 21,
		"unlocked_feature": "Tactical Armory & Firearm Customization",
		"job_id": "job_syndicate_armorer",
		"description": "Certified armorer credential permitting tactical firearm precision maintenance, machining customizations, and ballistic diagnostics."
	},

	# --- SERVICES LICENSES ---
	{
		"id": "license_photographer",
		"name": "Commercial Photographer License",
		"icon": "📷",
		"category": "services",
		"fee": 12500,
		"min_age": 18,
		"unlocked_feature": "Freelance Commercial Photographer",
		"job_id": "freelance_photographer",
		"description": "State commercial photography permit granting legal rights for client portraiture, commercial sets, and editorial publishing."
	},
	{
		"id": "license_drone",
		"name": "Commercial Remote Drone Pilot License",
		"icon": "🛸",
		"category": "services",
		"fee": 15000,
		"min_age": 18,
		"unlocked_feature": "Freelance Aerial Drone Surveyor",
		"job_id": "freelance_drone_surveyor",
		"description": "Civil aviation authority certification for high-resolution aerial mapping, infrastructure inspection, and cinema drone piloting."
	},
	{
		"id": "license_electrician",
		"name": "Certified Journeyman Electrician License",
		"icon": "⚡",
		"category": "services",
		"fee": 25000,
		"min_age": 18,
		"unlocked_feature": "Freelance Master Electrician",
		"job_id": "freelance_electrician",
		"description": "Board-certified electrical contractor license authorizing residential and industrial high-voltage wiring and solar microgrids."
	},
	{
		"id": "license_plumber",
		"name": "Master Plumbing & Gasfitter License",
		"icon": "🔧",
		"category": "services",
		"fee": 22000,
		"min_age": 18,
		"unlocked_feature": "Freelance Master Plumber",
		"job_id": "freelance_plumber",
		"description": "Licensed tradesman certification authorizing commercial piping, high-pressure gas lines, and municipal sewer retrofits."
	},
	{
		"id": "license_appraiser",
		"name": "Certified Real Estate Appraiser License",
		"icon": "🏢",
		"category": "services",
		"fee": 28000,
		"min_age": 18,
		"unlocked_feature": "Freelance Real Estate Appraiser",
		"job_id": "freelance_appraiser",
		"description": "National appraisal foundation credential authorizing legal property valuation, commercial lease audits, and mortgage appraisals."
	},
	{
		"id": "license_fitness",
		"name": "Certified Personal Fitness Trainer License",
		"icon": "💪",
		"category": "services",
		"fee": 6800,
		"min_age": 18,
		"unlocked_feature": "Freelance Personal Fitness Trainer",
		"job_id": "freelance_fitness_trainer",
		"description": "Accredited athletic training certification authorizing one-on-one conditioning, strength programming, and corporate wellness coaching."
	},
	{
		"id": "license_tattoo",
		"name": "Professional Tattoo & Body Art License",
		"icon": "🖋️",
		"category": "services",
		"fee": 9500,
		"min_age": 18,
		"unlocked_feature": "Freelance Tattoo & Body Artist",
		"job_id": "freelance_tattoo_artist",
		"description": "Department of Health certification for sterile dermal needlework, custom cyber-ink tattoo artistry, and body modification."
	},
	{
		"id": "license_cyber",
		"name": "Certified Ethical Hacker & Pen-Tester License",
		"icon": "🛡️",
		"category": "services",
		"fee": 45000,
		"min_age": 18,
		"unlocked_feature": "Freelance Cyber Security Pen-Tester",
		"job_id": "freelance_cyber_pentester",
		"description": "Accredited cyber security certification permitting defensive white-hat network penetration tests and security vulnerability audits."
	},
	{
		"id": "license_interpreter",
		"name": "Certified Legal Court Interpreter License",
		"icon": "🗣️",
		"category": "services",
		"fee": 8500,
		"min_age": 18,
		"unlocked_feature": "Freelance Legal Court Interpreter",
		"job_id": "freelance_court_interpreter",
		"description": "Judicial qualification allowing sworn simultaneous translation and testimony interpretation in civil and federal courtrooms."
	},
	{
		"id": "license_bookkeeper",
		"name": "Certified Public Bookkeeper License",
		"icon": "📚",
		"category": "services",
		"fee": 32000,
		"min_age": 18,
		"unlocked_feature": "Freelance Certified Bookkeeper",
		"job_id": "freelance_bookkeeper",
		"description": "National accounting board certification for corporate ledger balancing, accounts payable reconciliation, and tax documentation."
	},
	{
		"id": "license_general_contractor",
		"name": "State Licensed General Building Contractor",
		"icon": "🏗️",
		"category": "services",
		"fee": 38000,
		"min_age": 21,
		"unlocked_feature": "Heavy Infrastructure & Commercial Construction",
		"job_id": "job_commercial_general_contractor",
		"description": "State construction licensing board certification authorizing commercial mega-structure general contracting, structural steel framing, and civic engineering."
	},
	{
		"id": "license_veterinary",
		"name": "Licensed Doctor of Veterinary Medicine (DVM)",
		"icon": "🐾",
		"category": "services",
		"fee": 48000,
		"min_age": 24,
		"unlocked_feature": "Veterinary Clinical Practice & Surgery",
		"job_id": "job_veterinarian_doctor",
		"description": "State veterinary medical board license permitting clinical animal diagnosis, orthopedic surgeries, pharmacology dispensation, and emergency veterinary hospital leadership."
	},
	{
		"id": "license_clinical_pharmacist",
		"name": "Registered Board-Certified Pharmacist (PharmD)",
		"icon": "💊",
		"category": "services",
		"fee": 45000,
		"min_age": 24,
		"unlocked_feature": "Specialty Pharmaceutical Dispensation & Compounding",
		"job_id": "job_compounding_pharmacist",
		"description": "Board of Pharmacy certification authorizing precision compounding, controlled narcotic dispensation, pharmacokinetic consultations, and clinical pharmacy operations."
	},
	{
		"id": "license_finra_series7",
		"name": "FINRA Series 7 & 66 Securities License",
		"icon": "📈",
		"category": "services",
		"fee": 28000,
		"min_age": 21,
		"unlocked_feature": "Securities Underwriting & Wealth Advisory",
		"job_id": "job_venture_capital_associate",
		"description": "Financial Industry Regulatory Authority credentials permitting registered general securities representation, equity underwriting, and discretionary wealth advisory."
	},
	{
		"id": "license_patent_bar",
		"name": "Registered USPTO Patent Attorney Bar License",
		"icon": "📜",
		"category": "services",
		"fee": 34000,
		"min_age": 23,
		"unlocked_feature": "Patent Prosecution & Intellectual Property Litigation",
		"job_id": "job_patent_attorney",
		"description": "United States Patent and Trademark Office bar registration authorizing patent claims prosecution, intellectual property litigation, and trade-secret legal arbitration."
	},
	{
		"id": "license_nuclear_operator",
		"name": "NRC Certified Senior Nuclear Reactor Operator License",
		"icon": "☢️",
		"category": "services",
		"fee": 65000,
		"min_age": 25,
		"unlocked_feature": "Nuclear Reactor Utility Operation & SMR Management",
		"job_id": "job_nuclear_reactor_technician",
		"description": "Nuclear Regulatory Commission senior operator license certifying nuclear reactor core control room command, reactivity management, and emergency meltdown safety."
	},
	{
		"id": "license_physical_therapist",
		"name": "Licensed Physical Therapy Practitioner (DPT)",
		"icon": "🏃",
		"category": "services",
		"fee": 36000,
		"min_age": 23,
		"unlocked_feature": "Physical Rehabilitation & Sports Therapy",
		"job_id": "job_physical_therapist_lead",
		"description": "State physical therapy licensing board credential authorizing orthopedic rehabilitation, neuromuscular re-education, athletic injury conditioning, and sports therapy."
	}
]


static func get_all_licenses() -> Array[Dictionary]:
	return LICENSES


static func get_categories() -> Array[Dictionary]:
	return CATEGORIES


static func get_category_by_id(id: String) -> Dictionary:
	for cat in CATEGORIES:
		if str(cat.get("id", "")) == id:
			return cat
	return {}


static func get_licenses_in_category(category_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for lic in LICENSES:
		if str(lic.get("category", "")) == category_id:
			result.append(lic)
	return result


static func get_license_by_id(id: String) -> Dictionary:
	for lic in LICENSES:
		if str(lic.get("id", "")) == id:
			return lic
	return {}


static func can_take_license(license_id: String) -> Dictionary:
	var lic := get_license_by_id(license_id)
	if lic.is_empty():
		return {"allowed": false, "reason": "License not found."}

	if PlayerData.has_license(license_id):
		return {"allowed": false, "reason": "You already hold this certified license!"}

	var min_age: int = int(lic.get("min_age", 18))
	if PlayerData.age < min_age:
		return {"allowed": false, "reason": "Age Restricted: Must be at least Age %d (Current Age: %d)." % [min_age, PlayerData.age]}

	var prerequisite: String = str(lic.get("requires_license", ""))
	if not prerequisite.is_empty() and not PlayerData.has_license(prerequisite):
		return {"allowed": false, "reason": "Complete Flight School before taking the pilot license exam."}

	var fee: int = int(lic.get("fee", 0))
	var total_funds: int = PlayerData.money + PlayerData.bank_savings
	if total_funds < fee:
		return {"allowed": false, "reason": "Insufficient funds: Required fee is $%d (Available: $%d)." % [fee, total_funds]}

	return {"allowed": true, "reason": "Eligible to certify."}


static func take_license(license_id: String) -> Dictionary:
	var eval := can_take_license(license_id)
	if not bool(eval.get("allowed", false)):
		return eval

	var lic := get_license_by_id(license_id)
	var fee: int = int(lic.get("fee", 0))

	# Deduct fee: pocket cash first, then bank savings
	PlayerData.debit_funds(fee)

	PlayerData.grant_license(license_id)
	var lic_name: String = str(lic.get("name", "License"))
	var unlocked: String = str(lic.get("unlocked_feature", ""))
	if bool(lic.get("is_course", false)):
		var message := "You completed Flight School for $%d! You can now take the separate pilot license exam." % fee
		return {"allowed": true, "message": message, "license": lic}

	var success_msg := "📜 LICENSE EXAM PASSED: You paid the $%d exam fee and officially earned your %s! Unlocked: %s." % [
		fee,
		lic_name,
		unlocked
	]
	return {
		"allowed": true,
		"message": success_msg,
		"license": lic
	}
