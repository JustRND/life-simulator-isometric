class_name EducationCatalog
extends RefCounted

const INSTITUTIONS_FILE := "res://data/education/institutions.json"

static var _institutions: Array = []
static var _institutions_by_id: Dictionary = {}
static var _institutions_by_major: Dictionary = {}
static var _loaded: bool = false


static func reload() -> void:
	_loaded = false
	_ensure_loaded()


static func _ensure_loaded() -> void:
	if _loaded and not _institutions.is_empty():
		return

	_institutions.clear()
	_institutions_by_id.clear()
	_institutions_by_major.clear()

	var file := FileAccess.open(INSTITUTIONS_FILE, FileAccess.READ)
	if file == null:
		push_error("Could not open institutions file at %s" % INSTITUTIONS_FILE)
		return

	var text := file.get_as_text()
	file.close()

	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_ARRAY:
		push_error("Invalid institutions data: expected Array")
		return

	_institutions = data
	for inst in _institutions:
		if inst is Dictionary:
			var id: String = str(inst.get("id", ""))
			var major: String = str(inst.get("major", "")).to_lower()
			if id != "":
				_institutions_by_id[id] = inst
			if major != "":
				_institutions_by_major[major] = inst

	_loaded = true


static func get_all_institutions() -> Array:
	_ensure_loaded()
	return _institutions


static func get_institution_by_id(id: String) -> Dictionary:
	_ensure_loaded()
	return _institutions_by_id.get(id, {})


static func get_institution_by_major(major: String) -> Dictionary:
	_ensure_loaded()
	return _institutions_by_major.get(major.to_lower(), {})


static func get_major_display_name(major_id: String) -> String:
	_ensure_loaded()
	var inst: Dictionary = get_institution_by_major(major_id)
	if not inst.is_empty() and inst.has("major_title"):
		return str(inst["major_title"])

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
		"veterinary":
			return "Veterinary Medicine & Surgery"
		"pharmacy":
			return "Pharmaceutical Chemistry & Pharmacology"
		"civil_engineering":
			return "Civil & Infrastructure Engineering"
		"game_design":
			return "Interactive Game Design & VR Simulation"
		"nuclear_physics":
			return "Nuclear Physics & Reactor Engineering"
		"kinesiology":
			return "Kinesiology & Physical Rehabilitation"
		_:
			return major_id.capitalize()


static func can_enroll(inst: Dictionary, grades: int, smarts: int) -> Dictionary:
	var req_grades: int = int(inst.get("min_grades", 60))
	var req_smarts: int = int(inst.get("min_smarts", 50))

	if grades == 0:
		return {
			"allowed": false,
			"reason": "Academic credentials expired (0%). You must complete an Academic Refresher Course before enrolling."
		}

	if grades < req_grades:
		return {
			"allowed": false,
			"reason": "Minimum High School GPA of %d%% required (Your Grade: %d%%)." % [req_grades, grades]
		}


	if smarts < req_smarts:
		return {
			"allowed": false,
			"reason": "Requires at least %d Smarts (Your Smarts: %d)." % [req_smarts, smarts]
		}

	return {
		"allowed": true,
		"reason": "Qualified"
	}
