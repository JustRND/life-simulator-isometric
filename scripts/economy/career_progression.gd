extends RefCounted

static var _paths: Dictionary = {}

static func paths() -> Dictionary:
	if _paths.is_empty():
		var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/economy/career_paths.json"))
		if parsed is Dictionary:
			_paths = parsed
			for job_id in _paths:
				var category: String = str(JobManager.get_job_by_id(job_id).get("category", ""))
				for stage in _paths[job_id]:
					stage.salary = preload("res://scripts/economy/balance_rules.gd").salary(int(stage.salary), category)
	return _paths

static func begin(player: Node) -> void:
	player.career_progress = {"job_id": player.job_id, "years": 0, "rank": 0, "last_age": player.age}

static func normalize(player: Node) -> void:
	if player.job_id.is_empty():
		player.career_progress = {}
	elif str(player.career_progress.get("job_id", "")) != player.job_id:
		# No invented seniority for legacy saves without a tenure record.
		begin(player)

static func advance_year(player: Node, spent_year_in_prison: bool = false) -> String:
	normalize(player)
	if player.job_id.is_empty() or player.is_dead:
		return ""
	if int(player.career_progress.get("last_age", player.age)) >= player.age:
		return ""
	player.career_progress["last_age"] = player.age
	if player.is_in_prison or spent_year_in_prison:
		return ""
	player.career_progress["years"] = int(player.career_progress.get("years", 0)) + 1
	var ladder: Array = paths().get(player.job_id, [])
	var rank: int = clampi(int(player.career_progress.get("rank", 0)), 0, ladder.size())
	if rank >= ladder.size():
		return ""
	var next: Dictionary = ladder[rank]
	if int(player.career_progress.years) < int(next.years) or player.age < int(next.min_age):
		return ""
	player.career_progress["rank"] = rank + 1
	player.job_title = str(next.title)
	player.job_salary = maxi(player.job_salary, int(next.salary))
	var m_sal: int = int(round(float(player.job_salary) / 12.0))
	return "PROMOTION: After %d years at %s, you became %s. Your monthly salary is now $%d/mo ($%d/yr), starting with this month's pay." % [int(player.career_progress.years), player.job_company, player.job_title, m_sal, player.job_salary]

static func summary(player: Node) -> String:
	normalize(player)
	if player.job_id.is_empty():
		return ""
	var ladder: Array = paths().get(player.job_id, [])
	var rank: int = clampi(int(player.career_progress.get("rank", 0)), 0, ladder.size())
	var text := "Career rank %d/%d • %d completed years in this job" % [rank + 1, ladder.size() + 1, int(player.career_progress.get("years", 0))]
	if rank < ladder.size():
		var next: Dictionary = ladder[rank]
		var next_m_sal: int = int(round(float(next.salary) / 12.0))
		text += "\nNext: %s • %d years of service • Age %d+ • $%d/mo ($%d/yr)" % [next.title, int(next.years), int(next.min_age), next_m_sal, int(next.salary)]
	else:
		text += "\nHighest position in this career path reached."
	return text
