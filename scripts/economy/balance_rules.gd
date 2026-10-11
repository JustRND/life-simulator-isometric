class_name BalanceRules
extends RefCounted

const LEARNING = [
	{"id": "reading", "name": "Library Reading", "cost": 0, "smarts": 3, "happiness": 1, "age": 5},
	{"id": "puzzles", "name": "Logic Puzzles", "cost": 0, "smarts": 2, "happiness": 2, "age": 5},
	{"id": "chess", "name": "Chess Club", "cost": 30, "smarts": 3, "happiness": 3, "age": 8},
	{"id": "museum", "name": "Museum Visit", "cost": 25, "smarts": 2, "happiness": 3, "age": 5},
	{"id": "language", "name": "Language Course", "cost": 180, "smarts": 5, "happiness": 1, "age": 12},
	{"id": "workshop", "name": "Practical Workshop", "cost": 120, "smarts": 4, "happiness": 2, "age": 16}
]

static func is_learning_activity_used_this_month(p: Node, id: String) -> bool:
	var record = p.learning_activities.get(id, null)
	if record == null:
		return false
	if record is Dictionary:
		var m: int = int(record.get("month", -1))
		var y: int = int(record.get("year", -1))
		var cur_m: int = int(p.get("in_game_month")) if p.get("in_game_month") != null else 1
		var cur_y: int = int(p.get("in_game_year")) if p.get("in_game_year") != null else 2026
		return m > 0 and y > 0 and m == cur_m and y == cur_y
	return false

static func learn(p: Node, id: String) -> String:
	for activity in LEARNING:
		if activity.id != id:
			continue
		if p.is_dead or p.is_in_prison or p.age < int(activity.age):
			return "This learning activity is unavailable."
		if is_learning_activity_used_this_month(p, id):
			return "Already completed this month."
		if p.get_available_funds() < int(activity.cost):
			return "Insufficient funds."
		p.debit_funds(int(activity.cost))
		p.learning_activities[id] = {
			"month": int(p.get("in_game_month")) if p.get("in_game_month") != null else 1,
			"year": int(p.get("in_game_year")) if p.get("in_game_year") != null else 2026,
			"age": p.age
		}
		# Gradual improvement near the cap, while any activity prevents decay.
		var gain := int(activity.smarts) if p.smarts < 85 else maxi(1, int(float(activity.smarts) / 2.0))
		p.smarts = mini(100, p.smarts + gain)
		p.happiness = mini(100, p.happiness + int(activity.happiness))
		p.last_school_activity_age = p.age
		p.last_school_activity_month = int(p.get("in_game_month")) if p.get("in_game_month") != null else 1
		p.last_school_activity_year = int(p.get("in_game_year")) if p.get("in_game_year") != null else 2026
		var message := "%s completed! Mental maintenance secured for this month." % activity.name
		p.add_life_log_entry(message, "education")
		return message
	return "Activity not found."


static func event_effects(effects: Dictionary, age: int) -> Dictionary:
	var result := effects.duplicate(true)
	for stat in ["health", "happiness", "smarts", "looks"]:
		if result.has(stat):
			if stat == "health" and int(result[stat]) <= -100:
				continue
			# Preserve meaningful choices while limiting extreme generic event swings.
			result[stat] = clampi(int(result[stat]), -12, 10)
	if result.has("money"):
		var cap := 150 if age < 13 else (1000 if age < 18 else 12000)
		result.money = clampi(int(result.money), -cap, cap)
	return result


static func salary(base: int, category: String) -> int:
	var factor := 1.0
	if category in ["retail", "fast_food", "entry_odd_jobs"]:
		factor = 1.12
	elif category == "underworld_crime":
		factor = 0.8
	elif base > 150000:
		factor = 0.92
	return int(round(base * factor / 100.0)) * 100


static func normalize_salary(p: Node) -> void:
	if int(p.finance_market.get("balance_version", 0)) >= 1:
		return
	p.finance_market.balance_version = 1
	var job: Dictionary = JobManager.get_job_by_id(p.job_id)
	if job.is_empty():
		return
	var rank := int(p.career_progress.get("rank", 0))
	var ladder: Array = load("res://scripts/economy/career_progression.gd").paths().get(p.job_id, [])
	p.job_salary = int(ladder[rank - 1].salary) if rank > 0 and rank <= ladder.size() else int(job.salary)


static func maintained_parent(p: Node, parent: String) -> bool:
	for activity in ["spend_time", "compliment", "pay_meds", "doctor_checkup", "vitamin_shot"]:
		if int(p.get("last_%s_%s_age" % [parent, activity])) >= p.age - 1:
			return true
	return false
