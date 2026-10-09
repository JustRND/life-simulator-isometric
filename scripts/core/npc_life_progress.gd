class_name NpcLifeProgress
extends RefCounted
## Persistent, once-per-age background simulation for NPCs (children & partners).
## Simulates schooling, university degrees with GPA, authentic career ladders,
## take-home savings, entrepreneurial businesses, credit score, and life milestones.

const Careers = preload("res://scripts/economy/career_progression.gd")

const FIELDS = [
	"education_level", "grades", "university_years", "university_name",
	"university_major", "university_major_title", "university_degree",
	"university_tuition", "degrees", "job_id", "job_title", "job_company",
	"job_salary", "career_progress", "money", "bank_savings", "credit_score"
]


static func ensure(person: Dictionary) -> void:
	if person.is_empty() or bool(person.get("_is_ensuring", false)):
		return
	person["_is_ensuring"] = true

	if not person.has("life_progress"):
		var base_smarts: int = clampi(int(person.get("smarts", 70)), 35, 95)
		person.life_progress = {
			"version": 2,
			"last_age": -1,
			"seed": hash(str(person.get("name", "NPC")) + str(person.get("gender", "")) + str(person.get("ethnicity", ""))),
			"education_level": "None",
			"grades": base_smarts,
			"university_years": 0,
			"university_name": "",
			"university_major": "",
			"university_major_title": "",
			"university_degree": "",
			"university_tuition": 12000,
			"degrees": [],
			"job_id": "",
			"job_title": "",
			"job_company": "",
			"job_salary": 0,
			"career_progress": {},
			"money": 0,
			"bank_savings": 0,
			"credit_score": 0,
			"owned_businesses": [],
			"history": []
		}

	var life: Dictionary = person.life_progress
	var target_age := maxi(0, int(person.get("age", 0)))

	for year in range(int(life.get("last_age", -1)) + 1, target_age + 1):
		_step(person, life, year)
		life["last_age"] = year

	# Synchronize summary fields on the person dictionary
	person["education"] = _format_education_display(life).replace("🎓 ", "").replace("Education: ", "")
	if not life.get("job_title", "").is_empty():
		person["occupation"] = str(life["job_title"])
	elif target_age < 5:
		person["occupation"] = "Infant / Toddler"
	elif target_age < 18:
		person["occupation"] = "Student"
	elif target_age < 22 and str(life.get("education_level", "")) == "University Student":
		person["occupation"] = "University Student"
	else:
		person["occupation"] = "Seeking Work"

	if not life.get("owned_businesses", []).is_empty():
		var b_name: String = str(life["owned_businesses"][0].get("name", "Enterprise"))
		var occ_prefix := "Owner of " + b_name
		if not str(life.get("job_title", "")).is_empty():
			person["occupation"] = occ_prefix + " / " + str(life["job_title"])
		else:
			person["occupation"] = occ_prefix

	person.erase("_is_ensuring")


static func _record(life: Dictionary, year: int, text: String) -> void:
	if not life.has("history"):
		life["history"] = []
	life["history"].append({"age": year, "text": text})


static func _step(person: Dictionary, life: Dictionary, year: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(life.get("seed", 0)) + year * 7919

	var smarts: int = clampi(int(person.get("smarts", 70)), 35, 100)
	var college_eligible: bool = (posmod(int(life.get("seed", 0)), 100) < 70) and (smarts >= 50)

	# 1. Schooling stages
	var stage: String = {
		5: "Kindergarten",
		6: "Primary School",
		12: "Middle School",
		15: "High School",
		18: "High School Graduate"
	}.get(year, "")

	if not stage.is_empty():
		life["education_level"] = stage
		_record(life, year, "Enrolled in %s." % stage if stage != "High School Graduate" else "Graduated from High School.")

	# 2. College Enrollment at Age 18
	if year == 18 and college_eligible:
		var institutions: Array = EducationCatalog.get_all_institutions()
		var eligible_unis: Array = []
		for inst in institutions:
			if inst is Dictionary:
				var eval := EducationCatalog.can_enroll(inst, int(life.get("grades", smarts)), smarts)
				if bool(eval.get("allowed", false)):
					eligible_unis.append(inst)

		if not eligible_unis.is_empty():
			var chosen: Dictionary = eligible_unis[rng.randi_range(0, eligible_unis.size() - 1)]
			life["education_level"] = "University Student"
			life["university_name"] = str(chosen.get("name", "University of Pixel State"))
			life["university_major"] = str(chosen.get("major", "business"))
			life["university_major_title"] = str(chosen.get("major_title", "Business Management"))
			life["university_degree"] = str(chosen.get("degree_title", "Bachelor of Business"))
			life["university_tuition"] = int(chosen.get("tuition", 12000))
			life["university_years"] = 1
			_record(life, year, "Enrolled at %s majoring in %s." % [life["university_name"], life["university_major_title"]])
		else:
			college_eligible = false

	# 3. University progression (Ages 19-21)
	if college_eligible and year > 18 and year < 22:
		life["university_years"] = year - 18 + 1

	# 4. University graduation at Age 22
	if college_eligible and year == 22 and str(life.get("education_level", "")) == "University Student":
		life["education_level"] = "University Graduate"
		life["university_years"] = 0
		var final_grades: int = clampi(int(life.get("grades", smarts)) + rng.randi_range(-3, 6), 55, 99)
		life["grades"] = final_grades
		var gpa: float = snappedf(float(final_grades) / 25.0, 0.01)
		var honors: String = "Summa Cum Laude" if final_grades >= 92 else ("Magna Cum Laude" if final_grades >= 86 else ("Cum Laude" if final_grades >= 80 else ""))

		var degree_record := {
			"university": life["university_name"],
			"major": life["university_major"],
			"major_title": life["university_major_title"],
			"degree": life["university_degree"],
			"grades": final_grades,
			"year_graduated": year,
			"gpa": gpa,
			"honors": honors
		}
		if not life.has("degrees"):
			life["degrees"] = []
		life["degrees"].append(degree_record)
		var honors_str := " with %s" % honors if not honors.is_empty() else ""
		_record(life, year, "Graduated from %s with a %s (GPA %.2f)%s." % [life["university_name"], life["university_degree"], gpa, honors_str])

	# Before starting employment: high school grads start at 18, university grads start after graduation (23)
	var work_start_age: int = 23 if college_eligible else 18
	if year < work_start_age:
		_update_credit_score(life, year)
		return

	# 5. Job Search & Hiring
	if str(life.get("job_id", "")).is_empty():
		var all_jobs: Array = JobManager.get_all_jobs()
		var eligible_jobs: Array = []
		var major_matched_jobs: Array = []

		var stats := {
			"smarts": smarts,
			"health": int(person.get("health", 85)),
			"looks": int(person.get("looks", 65)),
			"happiness": int(person.get("happiness", 75))
		}
		var education := {
			"grades": int(life.get("grades", smarts)),
			"education_level": str(life.get("education_level", "High School Graduate")),
			"major": str(life.get("university_major", "")),
			"degrees": life.get("degrees", []),
			"licenses": []
		}

		for job in all_jobs:
			if not (job is Dictionary):
				continue
			if str(job.get("category", "")) == "underworld_crime":
				continue
			var eval := JobManager.can_apply(job, year, stats, education)
			if bool(eval.get("allowed", false)):
				eligible_jobs.append(job)
				var req_major: String = str(job.get("requirements", {}).get("required_major", "")).to_lower()
				if not req_major.is_empty() and req_major == str(life.get("university_major", "")).to_lower():
					major_matched_jobs.append(job)

		var pool: Array = major_matched_jobs if not major_matched_jobs.is_empty() else eligible_jobs
		if not pool.is_empty():
			var chosen_job: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
			life["job_id"] = str(chosen_job.get("id", ""))
			life["job_title"] = str(chosen_job.get("title", chosen_job.get("name", "Employee")))
			life["job_company"] = str(chosen_job.get("company", "Apex Global"))
			life["job_salary"] = int(chosen_job.get("salary", 25000))
			life["career_progress"] = {
				"job_id": life["job_id"],
				"years": 0,
				"rank": 0,
				"last_age": year
			}
			_record(life, year, "Started career as %s at %s ($%s/yr)." % [life["job_title"], life["job_company"], _format_number(life["job_salary"])])

	# 6. Career Advancement & Promotions
	elif not life.get("career_progress", {}).is_empty():
		var prog: Dictionary = life["career_progress"]
		prog["years"] = int(prog.get("years", 0)) + 1
		prog["last_age"] = year

		var ladder: Array = Careers.paths().get(life["job_id"], [])
		var rank: int = int(prog.get("rank", 0))
		if rank < ladder.size():
			var next_pos: Dictionary = ladder[rank]
			if year >= int(next_pos.get("min_age", 0)) and int(prog["years"]) >= int(next_pos.get("years", 0)):
				life["job_title"] = str(next_pos.get("title", life["job_title"]))
				life["job_salary"] = int(next_pos.get("salary", life["job_salary"]))
				prog["rank"] = rank + 1
				_record(life, year, "Earned a promotion to %s at %s ($%s/yr)." % [life["job_title"], life["job_company"], _format_number(life["job_salary"])])
		elif posmod(year, 3) == 0:
			# Senior tenure merit increase
			var raise: int = int(life["job_salary"] * 0.035)
			life["job_salary"] += raise

	# 7. Annual Earnings & Savings
	var salary: int = int(life.get("job_salary", 0))
	if salary > 0:
		var save_rate: float = rng.randf_range(0.12, 0.22)
		var annual_saved: int = int(salary * save_rate)
		var cash_share: int = int(annual_saved * 0.15)
		life["money"] = mini(15000, int(life.get("money", 0)) + cash_share)
		life["bank_savings"] = int(life.get("bank_savings", 0)) + (annual_saved - cash_share)
		if int(life["bank_savings"]) > 10000:
			life["bank_savings"] += int(float(life["bank_savings"]) * 0.015)

	# 8. Entrepreneurial Business Founding (Ages 28–52)
	var has_businesses: bool = not life.get("owned_businesses", []).is_empty()
	var entrepreneurial_seed: bool = (posmod(int(life.get("seed", 0)) + 7, 3) == 0)
	var bank_balance: int = int(life.get("bank_savings", 0))

	if year >= 28 and year <= 52 and not has_businesses and entrepreneurial_seed and bank_balance >= 38000:
		var matching_biz: Dictionary = {}
		var major: String = str(life.get("university_major", "")).to_lower()

		for b_def in BusinessManager.BUSINESS_TYPES:
			if str(b_def.get("required_major", "")).to_lower() == major:
				matching_biz = b_def
				break

		# Fallback to accessible popular businesses if no direct major match
		if matching_biz.is_empty():
			for b_id in ["biz_coffee_shop", "biz_graphic_consultancy", "biz_clothing_store"]:
				var candidate := BusinessManager.get_business_type_by_id(b_id)
				if not candidate.is_empty() and int(candidate.get("startup_cost", 50000)) * 0.65 <= bank_balance:
					matching_biz = candidate
					break

		if not matching_biz.is_empty():
			var startup_cost: int = int(matching_biz.get("startup_cost", 35000))
			var invested_capital: int = int(startup_cost * 0.65)
			if bank_balance >= invested_capital:
				life["bank_savings"] -= invested_capital
				var p_name: String = str(person.get("name", "Empire")).split(" ")[0]
				var biz_title: String = str(matching_biz.get("name", "Enterprise"))
				var clean_name: String = "%s's %s" % [p_name, biz_title.split("&")[0].strip_edges()]

				var new_biz: Dictionary = {
					"uid": "biz_npc_%s_%d" % [life["seed"], year],
					"type_id": str(matching_biz.get("id", "biz_coffee_shop")),
					"name": clean_name,
					"icon": str(matching_biz.get("icon", "🏢")),
					"founded_age": year,
					"treasury": 15000,
					"employees": 4,
					"marketing_budget": 5000,
					"annual_revenue": int(matching_biz.get("base_revenue_min", 90000)),
					"annual_opex": int(matching_biz.get("base_opex", 55000)),
					"net_profit": int(matching_biz.get("base_revenue_min", 90000) - matching_biz.get("base_opex", 55000)),
					"cumulative_net_profit": 0,
					"unpaid_taxes": 0,
					"last_tax_paid_year": year,
					"loan_balance": 0,
					"loan_interest_rate": 0.08,
					"valuation": int(startup_cost * 1.3),
					"reputation": 75,
					"owner_fraction": 1.0
				}
				if not life.has("owned_businesses"):
					life["owned_businesses"] = []
				life["owned_businesses"].append(new_biz)
				_record(life, year, "Founded '%s' investing $%s in seed capital." % [clean_name, _format_number(invested_capital)])

	# 9. Existing Business Yearly Operations
	if life.has("owned_businesses"):
		for biz in life["owned_businesses"]:
			if int(biz.get("founded_age", -1)) == year:
				continue
			var b_def := BusinessManager.get_business_type_by_id(str(biz.get("type_id", "")))
			var rev_min: int = int(b_def.get("base_revenue_min", 80000))
			var rev_max: int = int(b_def.get("base_revenue_max", 150000))
			var opex_base: int = int(b_def.get("base_opex", 50000))

			var revenue: int = rng.randi_range(int(rev_min * 0.9), int(rev_max * 1.15))
			var opex: int = int(opex_base * rng.randf_range(0.92, 1.08))
			var profit: int = revenue - opex

			biz["annual_revenue"] = revenue
			biz["annual_opex"] = opex
			biz["net_profit"] = profit
			biz["cumulative_net_profit"] = int(biz.get("cumulative_net_profit", 0)) + profit
			biz["treasury"] = maxi(2500, int(biz.get("treasury", 0)) + profit)
			biz["valuation"] = maxi(int(b_def.get("startup_cost", 35000)), int(biz.get("valuation", 35000)) + int(profit * 0.35))

			if profit > 0:
				var owner_dividend: int = int(profit * 0.25)
				life["bank_savings"] = int(life.get("bank_savings", 0)) + owner_dividend

	# 10. Credit Score calculation
	_update_credit_score(life, year)


static func _update_credit_score(life: Dictionary, year: int) -> void:
	if year < 18:
		life["credit_score"] = 0
		return
	if year == 18:
		life["credit_score"] = 650
		return

	var score: int = 650
	var job_years := int(life.get("career_progress", {}).get("years", 0))
	score += mini(45, job_years * 2)

	var savings := int(life.get("bank_savings", 0))
	if savings >= 60000:
		score += 30
	elif savings >= 25000:
		score += 15

	if not life.get("owned_businesses", []).is_empty():
		score += 20

	life["credit_score"] = clampi(score, 650, 780)


static func get_education_display(person: Dictionary) -> String:
	ensure(person)
	return _format_education_display(person.get("life_progress", {}))


static func _format_education_display(life: Dictionary) -> String:
	var edu_level: String = str(life.get("education_level", "None"))

	if edu_level == "University Graduate":
		var deg_title: String = str(life.get("university_degree", ""))
		if deg_title.is_empty() and not life.get("degrees", []).is_empty():
			deg_title = str(life["degrees"][0].get("degree", ""))
		var gpa: float = float(life.get("grades", 75)) / 25.0
		return "🎓 Education: %s (GPA %.2f)" % [deg_title if not deg_title.is_empty() else "University Graduate", gpa]
	elif edu_level == "University Student":
		var yrs: int = int(life.get("university_years", 1))
		return "🎓 Education: University Student (Year %d • %s)" % [yrs, life.get("university_major_title", "General Studies")]
	elif edu_level == "High School Graduate":
		return "🎓 Education: High School Graduate"
	elif edu_level in ["High School", "Middle School", "Primary School", "Kindergarten"]:
		var grades: int = int(life.get("grades", 75))
		return "🎓 Education: %s (Grades: %d%%)" % [edu_level, grades]
	return "🎓 Education: None (Too young for school)"


static func get_occupation_display(person: Dictionary) -> String:
	ensure(person)
	var life: Dictionary = person.get("life_progress", {})
	var title: String = str(life.get("job_title", ""))
	var comp: String = str(life.get("job_company", ""))
	var sal: int = int(life.get("job_salary", 0))
	var target_age: int = int(person.get("age", 0))
	var biz_list: Array = life.get("owned_businesses", [])

	if not title.is_empty():
		if sal > 0:
			return "💼 Occupation: %s at %s ($%s/yr)" % [title, comp, _format_number(sal)]
		return "💼 Occupation: %s at %s" % [title, comp]
	elif not biz_list.is_empty():
		return "💼 Occupation: Founder & Owner at %s" % str(biz_list[0].get("name", "Enterprise"))
	elif target_age < 5:
		return "💼 Occupation: Infant / Toddler"
	elif target_age < 18:
		return "💼 Occupation: Student"
	elif target_age < 22 and str(life.get("education_level", "")) == "University Student":
		return "💼 Occupation: College Student"
	return "💼 Occupation: Seeking Work"


static func get_business_display(person: Dictionary) -> String:
	ensure(person)
	var life: Dictionary = person.get("life_progress", {})
	var biz_list: Array = life.get("owned_businesses", [])
	if biz_list.is_empty():
		return ""
	var biz: Dictionary = biz_list[0]
	return "%s Business: %s ($%s Valuation)" % [
		str(biz.get("icon", "🏢")),
		str(biz.get("name", "Enterprise")),
		_format_number(int(biz.get("valuation", 0)))
	]


static func get_finances_display(person: Dictionary) -> String:
	ensure(person)
	var life: Dictionary = person.get("life_progress", {})
	var m: int = int(life.get("money", 0))
	var b: int = int(life.get("bank_savings", 0))
	return "💰 Personal Wealth: $%s ($%s Cash • $%s Bank)" % [
		_format_number(m + b),
		_format_number(m),
		_format_number(b)
	]


static func summary(person: Dictionary) -> String:
	ensure(person)
	var life: Dictionary = person.get("life_progress", {})
	var edu := get_education_display(person)
	var occ := get_occupation_display(person)
	var wealth := get_finances_display(person)
	var biz := get_business_display(person)
	var biz_line := (" • " + biz) if not biz.is_empty() else ""
	return "%s\n%s\n%s%s" % [edu, occ, wealth, biz_line]


static func apply_to_player(player: Node, person: Dictionary) -> void:
	ensure(person)
	var life: Dictionary = person.get("life_progress", {})

	# 1. Education
	player.education_level = str(life.get("education_level", "High School Graduate"))
	player.grades = int(life.get("grades", 75))
	player.university_years = int(life.get("university_years", 0))
	player.university_name = str(life.get("university_name", ""))
	player.university_major = str(life.get("university_major", ""))
	player.university_major_title = str(life.get("university_major_title", ""))
	player.university_degree = str(life.get("university_degree", ""))
	player.university_tuition = int(life.get("university_tuition", 12000))
	player.degrees = life.get("degrees", []).duplicate(true)

	# 2. Career
	player.job_id = str(life.get("job_id", ""))
	player.job_title = str(life.get("job_title", ""))
	player.job_company = str(life.get("job_company", ""))
	player.job_salary = int(life.get("job_salary", 0))
	player.career_progress = life.get("career_progress", {}).duplicate(true)

	# 3. Personal finances: Heir retains their personal cash on hand, and heir's personal bank savings are loaded
	player.money = int(life.get("money", 0))
	player.bank_savings += int(life.get("bank_savings", 0))
	player.credit_score = int(life.get("credit_score", 650))

	# 4. Owned Businesses: Heir's businesses are merged into player's owned businesses
	var heir_businesses: Array = life.get("owned_businesses", []).duplicate(true)
	for b in heir_businesses:
		if b is Dictionary:
			player.owned_businesses.append(b)

	# 5. History log: Populate life_log with heir's backstory
	var target_final_age: int = player.age
	for entry in life.get("history", []):
		if entry is Dictionary:
			player.age = int(entry.get("age", target_final_age))
			player.add_life_log_entry(str(entry.get("text", "")), "event")
	player.age = target_final_age


static func _format_number(val: int) -> String:
	var s := str(val)
	var res := ""
	var cnt := 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		cnt += 1
		if cnt % 3 == 0 and i > 0:
			res = "," + res
	return res
