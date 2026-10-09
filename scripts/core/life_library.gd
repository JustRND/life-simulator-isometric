extends Node

signal achievement_unlocked(title: String, description: String)
const ACHIEVEMENTS = [
	["first_life", "Hello, World!", "Begin your first life."],
	["adult", "Coming of Age", "Reach age 18."],
	["elder", "Golden Years", "Reach age 65."],
	["job", "First Paycheck", "Get a job."],
	["savings", "Nest Egg", "Hold $10,000 in cash and savings."],
	["license", "Certified", "Earn your first license."],
	["pilot", "Cleared for Takeoff", "Earn a pilot license."],
	["love", "A New Connection", "Establish a relationship."],
	["married", "Together Forever", "Get married."],
	["parent", "Next Generation", "Become a parent."],
	["asset", "Proud Owner", "Own your first asset."],
	["graduate", "Cap and Gown", "Earn a degree."]
]
const GAME_VERSION: String = "0.1.0"
var profile_path := "user://life_library.json"
var slots_path := "user://lives"
var resume_path := SaveManager.SAVE_PATH
var data: Dictionary = {"cities": [], "people": [], "achievements": {}, "theme": "dark", "active_slot": "", "muted": false, "language": "en", "currency": "USD", "haptics_enabled": true}

func get_version_string() -> String:
	var ver: String = str(ProjectSettings.get_setting("application/config/version", GAME_VERSION)).strip_edges()
	if ver.is_empty():
		ver = GAME_VERSION
	return ver


func _ready() -> void:
	if FileAccess.file_exists(profile_path):
		var saved = JSON.parse_string(FileAccess.get_file_as_string(profile_path))
		if saved is Dictionary:
			for key in data:
				if saved.has(key) and typeof(saved[key]) == typeof(data[key]):
					data[key] = saved[key]


func persist() -> bool:
	return SaveManager.write_data(profile_path, data)


func slots() -> Array:
	var result: Array = []
	if not DirAccess.dir_exists_absolute(slots_path):
		return result
	for filename in DirAccess.get_files_at(slots_path):
		if not filename.ends_with(".json"):
			continue
		var saved = JSON.parse_string(FileAccess.get_file_as_string(slots_path.path_join(filename)))
		if saved is Dictionary and SaveManager.valid_data(saved):
			result.append({"id": filename.get_basename(), "life_id": str(saved.get("life_id", "")), "name": str(saved.first_name), "age": int(saved.age), "date": str(saved.get("_saved_at", ""))})
	result.sort_custom(func(a, b): return a.date > b.date)
	return result


func slot_path(id: String) -> String:
	# IDs never come from character names or arbitrary paths.
	if id.is_empty() or not id.is_valid_hex_number(false):
		return ""
	return slots_path.path_join(id + ".json")


func save_slot(overwrite: bool = false) -> bool:
	if not PlayerData.has_started_game:
		return false
	if DirAccess.make_dir_recursive_absolute(slots_path) != OK:
		return false
	var id: String = current_slot() if overwrite else Crypto.new().generate_random_bytes(16).hex_encode()
	var path := slot_path(id)
	if path.is_empty() or (overwrite and not FileAccess.file_exists(path)):
		return false
	var snapshot := SaveManager.capture_data()
	snapshot["_saved_at"] = Time.get_datetime_string_from_system(false, true)
	if not SaveManager.write_data(path, snapshot):
		return false
	data.active_slot = id
	persist()
	return true


func current_slot() -> String:
	var matching: Array = []
	for entry in slots():
		if entry.life_id == PlayerData.life_id and not PlayerData.life_id.is_empty():
			if entry.id == data.active_slot:
				return entry.id
			matching.append(entry.id)
	return "" if matching.is_empty() else str(matching[0])


func load_slot(id: String) -> bool:
	var path := slot_path(id)
	if path.is_empty() or not FileAccess.file_exists(path):
		return false
	var saved = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not saved is Dictionary or not SaveManager.valid_data(saved):
		return false
	# Validate and update the resume file before replacing the live character.
	if not SaveManager.write_data(resume_path, saved):
		return false
	if not SaveManager.load_game(path):
		return false
	data.active_slot = id
	persist()
	return true


func add_city(city: String, country: String) -> String:
	if not _valid_country(country):
		return "Choose a nationality from the country list."
	city = city.strip_edges()
	if city.length() < 2 or city.length() > 48:
		return "Use a city name between 2 and 48 characters."
	var pattern := RegEx.new()
	pattern.compile("^[\\p{L}][\\p{L} .'-]*$")
	if pattern.search(city) == null:
		return "Use letters, spaces, apostrophes, periods or hyphens."
	for entry in data.cities:
		if str(entry.name).to_lower() == city.to_lower() and entry.country == country:
			return "This city is already in your library."
	data.cities.append({"name": city, "country": country})
	if not persist():
		data.cities.pop_back()
		return "Could not save the city on this device."
	return ""


func birth_location(country: String) -> String:
	var cities: Array = []
	for entry in data.cities:
		if entry.country == country:
			cities.append(str(entry.name))
	return country if cities.is_empty() else "%s, %s" % [cities.pick_random(), country]


func add_person(person: Dictionary) -> String:
	var options = preload("res://scripts/core/creation_options.gd")
	var normalized: String = options.normalize_name(str(person.get("name", "")))
	if not options.valid_name(normalized):
		return "Enter a name with 2–40 letters and spaces."
	if not _valid_country(str(person.get("country", ""))):
		return "Choose a nationality from the country list."
	if not str(person.get("gender", "")) in ["MALE", "FEMALE"] or not str(person.get("ethnicity", "")) in preload("res://scripts/core/portrait_catalog.gd").ETHNICITIES or int(person.get("portrait_track", -1)) not in range(4):
		return "Choose a gender and avatar."
	for entry in data.people:
		if entry.name == normalized and entry.country == person.country:
			return "This person is already in your library."
	person = person.duplicate(true)
	person.name = normalized
	person.id = Crypto.new().generate_random_bytes(12).hex_encode()
	data.people.append(person)
	if not persist():
		data.people.pop_back()
		return "Could not save the person on this device."
	return ""


func custom_candidate(gender: String) -> Dictionary:
	var eligible: Array = []
	for person in data.people:
		if person.gender == gender:
			eligible.append(person)
	return {} if eligible.is_empty() else eligible.pick_random().duplicate(true)


func _valid_country(country: String) -> bool:
	for entry in preload("res://scripts/core/creation_options.gd").COUNTRIES:
		if entry[0] == country:
			return true
	return false


func check_achievements() -> void:
	if not PlayerData.has_started_game:
		return
	var earned := [true, PlayerData.age >= 18, PlayerData.age >= 65,
		not PlayerData.job_id.is_empty(), PlayerData.money + PlayerData.bank_savings >= 10000,
		PlayerData.licenses.any(func(id): return str(id).begins_with("license_")), PlayerData.has_license("license_pilot"),
		not PlayerData.partner.is_empty(), str(PlayerData.partner.get("status", "")) in ["Wife", "Husband"],
		not PlayerData.children.is_empty(), not PlayerData.owned_assets.is_empty(), not PlayerData.degrees.is_empty()]
	for i in ACHIEVEMENTS.size():
		var achievement: Array = ACHIEVEMENTS[i]
		if earned[i] and not data.achievements.has(achievement[0]):
			data.achievements[achievement[0]] = Time.get_datetime_string_from_system()
			if persist():
				achievement_unlocked.emit(achievement[1], achievement[2])
			else:
				data.achievements.erase(achievement[0])
