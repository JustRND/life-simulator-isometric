class_name FreelanceManager
extends RefCounted

const FREELANCE_JOBS: Array[Dictionary] = [
	{
		"id": "freelance_photographer",
		"title": "Freelance Commercial Photographer",
		"icon": "📷",
		"required_license": "license_photographer",
		"license_title": "Commercial Photographer License",
		"description": "Shoot high-end product campaigns, corporate fashion portfolios, and architectural catalog spreads.",
		"min_pay": 1200,
		"max_pay": 6500,
		"stat_affected": "looks",
		"projects": [
			{"title": "Neo-Tokyo Fashion Magazine Cover", "client": "Vogue Cyber", "scope": "Photograph 3 editorial models in high-fashion neon streetwear."},
			{"title": "Luxury Penthouse Architectural Catalog", "client": "Apex Skyline Realty", "scope": "Capture ultra-wide twilight interior stills of a $15M penthouse."},
			{"title": "Hypercar Studio Commercial Shoot", "client": "Kusanagi Motor Works", "scope": "Produce dynamic studio lighting portraits of a concept hypercar."}
		]
	},
	{
		"id": "freelance_drone_surveyor",
		"title": "Freelance Aerial Drone Surveyor",
		"icon": "🛸",
		"required_license": "license_drone",
		"license_title": "Commercial Remote Drone Pilot License",
		"description": "Deploy thermal LiDAR quadcopters for civil infrastructure inspections, 3D photogrammetry, and film aerials.",
		"min_pay": 1500,
		"max_pay": 8200,
		"stat_affected": "smarts",
		"projects": [
			{"title": "Industrial Solar Farm Thermal Inspection", "client": "Helios Clean Power", "scope": "Scan 4,000 photovoltaic panels for sub-surface heat defects using FLIR sensors."},
			{"title": "Suspension Bridge Structural Photogrammetry", "client": "Metropolitan Dept of Transit", "scope": "Map cable stress points and generate millimeter-accurate 3D digital twins."},
			{"title": "Sci-Fi Film Climax Aerial Tracking", "client": "Pixel Studios", "scope": "Pilot a heavy-lift cinema octocopter during a 90 mph vehicle chase scene."}
		]
	},
	{
		"id": "freelance_pi",
		"title": "Freelance Private Investigator",
		"icon": "🕵️",
		"required_license": "license_pi",
		"license_title": "Private Investigator License",
		"description": "Conduct discreet undercover operations, skip tracing, corporate espionage audits, and background vetting.",
		"min_pay": 2500,
		"max_pay": 14000,
		"stat_affected": "smarts",
		"projects": [
			{"title": "Corporate Patent Leak Surveillance", "client": "OmniCorp Biotech", "scope": "Shadow a suspected rogue research executive and uncover secret syndicate meetings."},
			{"title": "Offshore Asset Hidden Account Trace", "client": "Lexington Legal Partners", "scope": "Track down $2.4M in laundered shell company holdings ahead of divorce litigation."},
			{"title": "High-Profile Kidnapping Skip Trace", "client": "Private Family Trust", "scope": "Locate an abducted tech heiress held in an abandoned underground transit warehouse."}
		]
	},
	{
		"id": "freelance_electrician",
		"title": "Freelance Master Electrician",
		"icon": "⚡",
		"required_license": "license_electrician",
		"license_title": "Certified Journeyman Electrician License",
		"description": "Specialize in 480V three-phase commercial wiring, backup generator interlocks, and residential EV smart panels.",
		"min_pay": 1800,
		"max_pay": 9500,
		"stat_affected": "smarts",
		"projects": [
			{"title": "Data Center Backup Switchgear Installation", "client": "CloudCore Systems", "scope": "Wire automated transfer switches for dual 500kVA emergency diesel generators."},
			{"title": "Luxury Marina Shore-Power Retrofit", "client": "Port Cyber Marina", "scope": "Upgrade 24 wet slip pedestals with 100A smart metering and ground-fault protection."},
			{"title": "High-Voltage Factory Automation Rewire", "client": "Titan Robotics Assembly", "scope": "Terminate high-speed optical encoders and heavy servo bus power lines."}
		]
	},
	{
		"id": "freelance_plumber",
		"title": "Freelance Master Plumber",
		"icon": "🔧",
		"required_license": "license_plumber",
		"license_title": "Master Plumbing & Gasfitter License",
		"description": "Handle high-pressure natural gas lines, municipal backflow certification, and luxury hydronic radiant heating.",
		"min_pay": 1600,
		"max_pay": 8800,
		"stat_affected": "health",
		"projects": [
			{"title": "Commercial Kitchen Grease Interceptor Install", "client": "Gourmet Bistro Chain", "scope": "Install a 1,000-gallon underground hydro-mechanical grease separator."},
			{"title": "High-Rise Hydrostatic Water Main Overhaul", "client": "Apex Tower HOA", "scope": "Replace corroded copper riser pipes across 35 residential penthouse floors."},
			{"title": "Hydronic Heated Driveway Boiler Retrofit", "client": "Executive Estate", "scope": "Design and pressure-test a 250,000 BTU snow-melting radiant closed-loop system."}
		]
	},
	{
		"id": "freelance_appraiser",
		"title": "Freelance Real Estate Appraiser",
		"icon": "🏢",
		"required_license": "license_appraiser",
		"license_title": "Certified Real Estate Appraiser License",
		"description": "Provide unbiased USPAP-compliant valuations for commercial skyscrapers, retail plazas, and probate estates.",
		"min_pay": 2000,
		"max_pay": 11500,
		"stat_affected": "smarts",
		"projects": [
			{"title": "Downtown Cyber Plaza Mortgage Appraisal", "client": "Pixel Union Bank", "scope": "Perform DCF income-approach valuation on a 200,000 sq ft office center ($42M value)."},
			{"title": "Historic Seaside Hotel Probate Appraisal", "client": "Estate Legal Executors", "scope": "Determine fair market asset value of a 40-key beachfront boutique hotel."},
			{"title": "Industrial Logistics Hub Eminent Domain Assessment", "client": "Regional Port Authority", "scope": "Audit replacement costs and land market values for a 20-acre container depot."}
		]
	},
	{
		"id": "freelance_fitness_trainer",
		"title": "Freelance Personal Fitness Trainer",
		"icon": "💪",
		"required_license": "license_fitness",
		"license_title": "Certified Personal Fitness Trainer License",
		"description": "Design high-intensity metabolic conditioning, powerlifting regimens, and VIP celebrity physique transformations.",
		"min_pay": 1100,
		"max_pay": 5800,
		"stat_affected": "health",
		"projects": [
			{"title": "Tech CEO 12-Week Marathon Conditioning", "client": "Chief Executive VIP", "scope": "Program periodized VO2 max sprint intervals and nutritional macro protocols."},
			{"title": "Action Movie Star Fight-Choreography Prep", "client": "Silver Screen Casting", "scope": "Supervise 60-day rapid muscle hypertrophy and acrobatic endurance training."},
			{"title": "Corporate Executive Wellness Workshop", "client": "FinTech Conglomerate", "scope": "Host ergonomic movement clinics and high-energy HIIT workouts for 80 employees."}
		]
	},
	{
		"id": "freelance_tattoo_artist",
		"title": "Freelance Tattoo & Body Artist",
		"icon": "🖋️",
		"required_license": "license_tattoo",
		"license_title": "Professional Tattoo & Body Art License",
		"description": "Craft stunning bespoke dermal ink, intricate Japanese irezumi motifs, and neon UV bioluminescent cyber-tattoos.",
		"min_pay": 1300,
		"max_pay": 7200,
		"stat_affected": "looks",
		"projects": [
			{"title": "Full Neo-Traditional Japanese Dragon Backpiece", "client": "Private Collector", "scope": "Execute a 30-hour multi-session masterpiece with shading, windbars, and cherry blossoms."},
			{"title": "Subdermal UV Glowing Circuit Cyber-Sleeve", "client": "Cyberpunk DJ", "scope": "Implant phosphor-reactive inks along nerve pathways for onstage ultraviolet glow."},
			{"title": "Photorealistic Black & Grey Family Portrait", "client": "Grateful Client", "scope": "Render delicate 3-round liner micro-portraits on upper arm with soft greywash gradients."}
		]
	},
	{
		"id": "freelance_cyber_pentester",
		"title": "Freelance Cyber Security Pen-Tester",
		"icon": "🛡️",
		"required_license": "license_cyber",
		"license_title": "Certified Ethical Hacker & Pen-Tester License",
		"description": "Simulate red-team adversarial cyber attacks, smart contract audits, and zero-day perimeter penetration tests.",
		"min_pay": 3500,
		"max_pay": 22000,
		"stat_affected": "smarts",
		"projects": [
			{"title": "Central Bank Swift Gateway Penetration Test", "client": "Metropolitan Central Bank", "scope": "Discover bypass vectors in encrypted API clusters and exfiltrate mock treasury tokens."},
			{"title": "Decentralized Smart Contract Logic Audit", "client": "EtherSwap Protocol", "scope": "Uncover reentrancy bugs and flash-loan attack surfaces in audited Solidity bytecode."},
			{"title": "Autonomous Vehicle Fleet Telematics Red-Team", "client": "Vector Auto Systems", "scope": "Hijack CAN bus telemetry packets via cellular exploit and demonstrate safe shutdown."}
		]
	},
	{
		"id": "freelance_court_interpreter",
		"title": "Freelance Legal Court Interpreter",
		"icon": "🗣️",
		"required_license": "license_interpreter",
		"license_title": "Certified Legal Court Interpreter License",
		"description": "Provide real-time sworn judicial translation in international arbitration hearings and federal criminal trials.",
		"min_pay": 1400,
		"max_pay": 7000,
		"stat_affected": "smarts",
		"projects": [
			{"title": "Federal Maritime Smuggling Trial Interpretation", "client": "U.S. District Court", "scope": "Provide 5 days of unbroken simultaneous interpretation during jury arguments."},
			{"title": "Multi-Billion Dollar Cross-Border M&A Deposition", "client": "Global Law Syndicate", "scope": "Interpret foreign CEO testimony during 10-hour contentious deposition session."},
			{"title": "High-Level Diplomatic Trade Treaty Arbitration", "client": "International Commerce Tribunal", "scope": "Translate technical tariff definitions and treaty protocols without nuance loss."}
		]
	},
	{
		"id": "freelance_bookkeeper",
		"title": "Freelance Certified Bookkeeper",
		"icon": "📚",
		"required_license": "license_bookkeeper",
		"license_title": "Certified Public Bookkeeper License",
		"description": "Reconcile corporate general ledgers, organize fiscal year-end accounts, and prepare clean audit trails.",
		"min_pay": 1700,
		"max_pay": 9000,
		"stat_affected": "smarts",
		"projects": [
			{"title": "Multi-Entity Restaurant Franchise Year-End Clean", "client": "Urban Dining Group", "scope": "Reconcile 12 months of disorganized point-of-sale logs, inventory invoices, and payroll."},
			{"title": "Pre-Audit Ledger Scrub Ahead of Series A Funding", "client": "HyperDrive Robotics", "scope": "Standardize GAAP accounting charts, depreciation schedules, and equity cap tables."},
			{"title": "Forensic Ledger Cleanup for Divorce Dispute", "client": "Forensic CPA Firm", "scope": "Categorize 15,000 credit card line-items to separate personal expenses from company books."}
		]
	},
	{
		"id": "freelance_mixologist",
		"title": "Freelance Event Mixologist",
		"icon": "🍸",
		"required_license": "license_mixologist",
		"license_title": "Professional Mixologist & Spirits License",
		"description": "Craft signature molecular cocktails, smoked bourbon infusions, and bespoke mobile cocktail bars for elite VIP parties.",
		"min_pay": 1100,
		"max_pay": 5500,
		"stat_affected": "happiness",
		"projects": [
			{"title": "Tech Billionaire Rooftop Yacht Launch Party", "client": "Private Billionaire Client", "scope": "Serve liquid nitrogen martinis and smoked mezcal craft elixirs to 150 VIP guests."},
			{"title": "Film Premiere Red-Carpet Cocktail Lounge", "client": "Cinematic Arts Gala", "scope": "Design 4 signature character-themed cocktails and direct a squad of flair bartenders."},
			{"title": "Underground Cyber Speakeasy Pop-Up Bar", "client": "Neon Syndicate Lounge", "scope": "Curate an exclusive 3-day secret cocktail menu utilizing bioluminescent liqueurs."}
		]
	}
]


static func get_all_jobs() -> Array[Dictionary]:
	return FREELANCE_JOBS


static func get_all_freelance_jobs() -> Array[Dictionary]:
	return FREELANCE_JOBS


static func get_job_by_id(id: String) -> Dictionary:
	for job in FREELANCE_JOBS:
		if str(job.get("id", "")) == id:
			return job
	return {}


static func can_register_job(job_id: String) -> Dictionary:
	var job := get_job_by_id(job_id)
	if job.is_empty():
		return {"allowed": false, "reason": "Freelance job not found."}

	var req_lic: String = str(job.get("required_license", ""))
	if not PlayerData.has_license(req_lic):
		var lic_title: String = str(job.get("license_title", "Required License"))
		return {
			"allowed": false,
			"reason": "Requires %s. Take the certification exam in the Licensing Panel first!" % lic_title
		}

	if PlayerData.active_freelance_jobs.has(job_id):
		return {"allowed": false, "reason": "You are already actively taking client gigs for this profession."}

	return {"allowed": true, "reason": "Qualified"}


static func register_job(job_id: String) -> Dictionary:
	var eval := can_register_job(job_id)
	if not bool(eval.get("allowed", false)):
		return eval

	PlayerData.active_freelance_jobs.append(job_id)
	var job := get_job_by_id(job_id)
	var title: String = str(job.get("title", "Freelancer"))

	PlayerData.add_life_log_entry("💼 FREELANCE ROSTER OPENED: You registered as a %s! You can now pitch for client contracts and receive project requests monthly." % title, "milestone")

	return {
		"allowed": true,
		"message": "Registered successfully! Client project requests will now appear periodically.",
		"job": job
	}


static func unregister_job(job_id: String) -> Dictionary:
	if not PlayerData.active_freelance_jobs.has(job_id):
		return {"allowed": false, "reason": "Job is not active."}

	PlayerData.active_freelance_jobs.erase(job_id)
	var job := get_job_by_id(job_id)
	var title: String = str(job.get("title", "Freelancer"))

	PlayerData.add_life_log_entry("You paused your active client roster as a %s." % title, "event")
	return {"allowed": true, "message": "Client roster paused."}


static func generate_project_for_job(job_id: String) -> Dictionary:
	var job := get_job_by_id(job_id)
	if job.is_empty():
		return {}

	var projects: Array = job.get("projects", [])
	var chosen: Dictionary = projects.pick_random() if not projects.is_empty() else {}
	var min_pay: int = int(job.get("min_pay", 1000))
	var max_pay: int = int(job.get("max_pay", 5000))

	# Player reputation / smarts bonus (up to +40% pay bonus)
	var bonus_pct: float = float(PlayerData.smarts) / 250.0
	var base_pay: int = randi_range(min_pay, max_pay)
	var final_pay: int = int(float(base_pay) * (1.0 + bonus_pct))

	return {
		"job_id": job_id,
		"job_title": str(job.get("title", "Freelancer")),
		"icon": str(job.get("icon", "💼")),
		"title": str(chosen.get("title", "Contract Project")),
		"client": str(chosen.get("client", "Commercial Client")),
		"scope": str(chosen.get("scope", "Deliver client specifications within project milestones.")),
		"pay": final_pay,
		"stat_affected": str(job.get("stat_affected", "smarts"))
	}


static func execute_project(proj: Dictionary) -> Dictionary:
	var pay: int = int(proj.get("pay", 1000))
	PlayerData.receive_salary(pay)

	var stat: String = str(proj.get("stat_affected", "smarts"))
	match stat:
		"smarts":
			PlayerData.smarts = mini(100, PlayerData.smarts + 2)
		"looks":
			PlayerData.looks = mini(100, PlayerData.looks + 2)
		"health":
			PlayerData.health = mini(100, PlayerData.health + 2)
		"happiness":
			PlayerData.happiness = mini(100, PlayerData.happiness + 4)

	PlayerData.happiness = mini(100, PlayerData.happiness + 2)

	var log_str := "%s FREELANCE CONTRACT DELIVERED: Completed '%s' for %s. Earned $%d!" % [
		str(proj.get("icon", "💼")),
		str(proj.get("title", "Project")),
		str(proj.get("client", "Client")),
		pay
	]
	PlayerData.add_life_log_entry(log_str, "finance")

	return {
		"success": true,
		"message": "Project delivered! $%d credited to your funds." % pay,
		"pay": pay
	}


static func pitch_gig(job_id: String) -> Dictionary:
	var job := get_job_by_id(job_id)
	if job.is_empty():
		return {"success": false, "message": "Job not found."}

	if not PlayerData.active_freelance_jobs.has(job_id):
		return {"success": false, "message": "Register this freelance job first!"}

	var cur_age: int = PlayerData.age
	var cur_m: int = PlayerData.in_game_month
	var cur_y: int = PlayerData.in_game_year
	var last_pitch_m: int = int(PlayerData.last_freelance_pitch_month.get(job_id, -1))
	var last_pitch_y: int = int(PlayerData.last_freelance_pitch_year.get(job_id, -1))
	var last_pitch_a: int = int(PlayerData.last_freelance_pitch_age.get(job_id, -1))

	if (last_pitch_m == cur_m and last_pitch_y == cur_y and last_pitch_a == cur_age) or (last_pitch_m < 0 and last_pitch_a == cur_age):
		return {"success": false, "message": "You have already pitched client contracts for this profession this month. Available again next month!"}

	PlayerData.last_freelance_pitch_age[job_id] = cur_age
	PlayerData.last_freelance_pitch_month[job_id] = cur_m
	PlayerData.last_freelance_pitch_year[job_id] = cur_y
	var proj := generate_project_for_job(job_id)
	var res := execute_project(proj)
	res["project"] = proj
	return res


static func generate_yearly_random_projects() -> Array[Dictionary]:
	var completed_projects: Array[Dictionary] = []
	for job_id in PlayerData.active_freelance_jobs:
		# 75% chance per active freelance job to land a client project during yearly cycle
		if randf() < 0.75:
			var proj := generate_project_for_job(job_id)
			var res := execute_project(proj)
			completed_projects.append({
				"project": proj,
				"result": res
			})
	return completed_projects
