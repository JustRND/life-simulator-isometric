extends Node

const JOBS_FILE_PATH := "res://data/economy/jobs.json"

const PAYMENT_TYPE_MONTHLY_SALARY := "MONTHLY_SALARY"
const PAYMENT_TYPE_DAILY_WAGE     := "DAILY_WAGE"
const PAYMENT_TYPE_PER_TASK       := "PER_TASK"
const PAYMENT_TYPE_PER_PROJECT    := "PER_PROJECT"

var categories: Array = []
var jobs: Array = []
var _jobs_by_id: Dictionary = {}


func _ready() -> void:
	load_jobs()


func load_jobs() -> void:
	categories.clear()
	jobs.clear()
	_jobs_by_id.clear()

	var file := FileAccess.open(JOBS_FILE_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open jobs config at %s" % JOBS_FILE_PATH)
		return

	var text := file.get_as_text()
	file.close()

	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Invalid jobs JSON format: root must be a Dictionary")
		return

	categories = data.get("categories", [])
	jobs = data.get("jobs", [])

	for job in jobs:
		if job is Dictionary and job.has("id"):
			job["salary"] = preload("res://scripts/economy/balance_rules.gd").salary(int(job.get("salary", 0)), str(job.get("category", "")))
			if not job.has("payment_type"):
				job["payment_type"] = PAYMENT_TYPE_MONTHLY_SALARY
			if not job.has("job_type"):
				job["job_type"] = "full_time"
			_jobs_by_id[str(job["id"])] = job

	print("Loaded %d jobs across %d categories." % [jobs.size(), categories.size()])


func get_payment_type(job: Dictionary) -> String:
	return str(job.get("payment_type", PAYMENT_TYPE_MONTHLY_SALARY))


func is_daily_wage_job(job: Dictionary) -> bool:
	return get_payment_type(job) == PAYMENT_TYPE_DAILY_WAGE


func is_monthly_salary_job(job: Dictionary) -> bool:
	return get_payment_type(job) == PAYMENT_TYPE_MONTHLY_SALARY



func get_all_jobs() -> Array:
	if jobs.is_empty():
		load_jobs()
	return jobs


func get_categories() -> Array:
	if categories.is_empty():
		load_jobs()
	return categories


func get_job_by_id(job_id: String) -> Dictionary:
	if _jobs_by_id.is_empty():
		load_jobs()
	return _jobs_by_id.get(job_id, {})


func get_jobs_in_category(category_id: String) -> Array:
	var result: Array = []
	for job in jobs:
		if job.get("category", "") == category_id:
			result.append(job)
	return result


func minimum_age(job: Dictionary) -> int:
	return maxi(17, int(job.get("min_age", 16))) if job.get("category", "") == "underworld_crime" else int(job.get("min_age", 16))


func can_apply(job: Dictionary, age: int, stats: Dictionary, education_data: Dictionary = {}) -> Dictionary:
	var min_age: int = minimum_age(job)
	if job.get("category", "") == "underworld_crime":
		var underground = preload("res://scripts/economy/underground_progression.gd")
		var required_rank := int(underground.catalog().job_ranks.get(str(job.get("id", "")), 0))
		if underground.rank_for(int(stats.get("underground_completed", 0))) < required_rank:
			return {"allowed": false, "reason": "Requires underground rank: %s. Complete activities in the Underground panel." % str(underground.catalog().ranks[required_rank].name)}
	if age < min_age:
		return {
			"allowed": false,
			"reason": "Must be at least %d years old (currently %d)." % [min_age, age]
		}

	var reqs: Dictionary = job.get("requirements", {})

	# Education & Grades Check
	var current_grade: int = int(education_data.get("grades", 75))
	if current_grade == 0 and str(job.get("id", "")) not in ["dishwasher", "farmhand", "janitor", "street_sweeper"]:
		return {
			"allowed": false,
			"reason": "Academic credentials expired (0%). You must complete an Academic Refresher Course first."
		}

	if reqs.has("min_grades"):
		var req_grade: int = int(reqs["min_grades"])
		if current_grade < req_grade:
			return {
				"allowed": false,
				"reason": "Requires %d%% academic marks (Your Grade: %d%%)." % [req_grade, current_grade]
			}


	if reqs.has("min_education"):
		var req_edu: String = str(reqs["min_education"])
		var current_edu: String = str(education_data.get("education_level", "None"))
		var degrees_list: Array = education_data.get("degrees", [])
		var has_any_degree: bool = (current_edu == "University Graduate" or degrees_list.size() > 0)
		if req_edu == "University Graduate" and not has_any_degree:
			return {
				"allowed": false,
				"reason": "Requires University Degree (Current: %s)." % current_edu
			}
		elif req_edu == "High School Graduate" and not has_any_degree and current_edu in ["None", "High School Dropout", "Kindergarten", "Primary School", "Middle School", "High School"]:
			return {
				"allowed": false,
				"reason": "Requires High School Diploma (Current: %s)." % current_edu
			}

	# University Major Requirement Check
	if reqs.has("required_major"):
		var req_major: String = str(reqs["required_major"]).to_lower()
		var current_major: String = str(education_data.get("major", "")).to_lower()
		var current_edu: String = str(education_data.get("education_level", "None"))
		var degrees_list: Array = education_data.get("degrees", [])
		var req_name := get_major_display_name(req_major)

		var has_required_major: bool = false
		if current_edu == "University Graduate" and current_major == req_major:
			has_required_major = true
		else:
			for deg in degrees_list:
				if deg is Dictionary and str(deg.get("major", "")).to_lower() == req_major:
					has_required_major = true
					break

		if not has_required_major:
			var current_name := get_major_display_name(current_major) if current_major != "" else "No Major"
			return {
				"allowed": false,
				"reason": "Requires University Degree in %s (Your Major: %s)." % [req_name, current_name]
			}

	# Required Professional License / Certification Check
	if reqs.has("required_license"):
		var req_lic: String = str(reqs["required_license"])
		var has_lic: bool = false
		if education_data.has("licenses") and education_data["licenses"] is Array:
			has_lic = education_data["licenses"].has(req_lic)
		elif Engine.has_singleton("PlayerData") or get_node_or_null("/root/PlayerData") != null:
			has_lic = PlayerData.has_license(req_lic)
		if not has_lic:
			var lic_def: Dictionary = LicenseManager.get_license_by_id(req_lic)
			var lic_name: String = str(lic_def.get("name", req_lic))
			return {
				"allowed": false,
				"reason": "Requires %s (Available in Licensing panel)." % lic_name
			}

	if reqs.has("min_health") and int(stats.get("health", 0)) < int(reqs["min_health"]):
		return {"allowed": false, "reason": "Requires at least %d Health." % int(reqs["min_health"])}
	if reqs.has("min_smarts") and int(stats.get("smarts", 0)) < int(reqs["min_smarts"]):
		return {"allowed": false, "reason": "Requires at least %d Smarts." % int(reqs["min_smarts"])}
	if reqs.has("min_looks") and int(stats.get("looks", 0)) < int(reqs["min_looks"]):
		return {"allowed": false, "reason": "Requires at least %d Looks." % int(reqs["min_looks"])}
	if reqs.has("min_happiness") and int(stats.get("happiness", 0)) < int(reqs["min_happiness"]):
		return {"allowed": false, "reason": "Requires at least %d Happiness." % int(reqs["min_happiness"])}
	if reqs.has("min_karma") and int(stats.get("karma", 0)) < int(reqs["min_karma"]):
		return {"allowed": false, "reason": "Requires a spotless moral and ethical reputation."}
	if reqs.has("max_karma") and int(stats.get("karma", 0)) > int(reqs["max_karma"]):
		return {"allowed": false, "reason": "Requires seasoned underworld credentials and notoriety."}

	return {"allowed": true, "reason": "Qualified"}


func get_category_by_id(category_id: String) -> Dictionary:
	for cat in categories:
		if cat is Dictionary and str(cat.get("id", "")) == category_id:
			return cat
	return {}


func get_major_display_name(major_id: String) -> String:
	match major_id.to_lower():
		"business":
			return "Business Management"
		"it":
			return "Cyber Security & IT"
		"medicine":
			return "Pre-Med & Healthcare Sciences"
		"engineering":
			return "Mechanical & Electrical Engineering"
		"arts":
			return "Digital Arts & Interactive Media"
		"food_science":
			return "Food Science & Culinary Arts"
		"law":
			return "Legal Studies & Jurisprudence"
		"finance":
			return "Finance & Investment Banking"
		"accounting":
			return "Accounting & Forensic Audit"
		"architecture":
			return "Architecture & Urban Planning"
		"film":
			return "Film, Cinematography & Media Production"
		"music":
			return "Sound Engineering & Music Production"
		"graphic_design":
			return "Graphic Design & Visual Communication"
		"fashion":
			return "Fashion & Apparel Design"
		"dentistry":
			return "Dental Surgery & Oral Health"
		"biotech":
			return "Biotechnology & Genetics"
		"environmental":
			return "Environmental & Renewable Energy Science"
		"logistics":
			return "Global Logistics & Supply Chain"
		_:
			return major_id.capitalize()

