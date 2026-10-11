extends RefCounted

# Backward-compatible POOLS dictionary holding [male_names, female_names, surnames]
# Initialized with core defaults, then populated dynamically with all 81 countries from res://data/names/
static var POOLS: Dictionary = {}
static var _country_data: Dictionary = {}
static var _is_initialized: bool = false

static func _ensure_initialized() -> void:
	if _is_initialized and not POOLS.is_empty():
		return
	_is_initialized = true
	_load_database()

static func _load_database() -> void:
	var path := "res://data/names/all_countries.json"
	if not FileAccess.file_exists(path):
		_populate_fallback_pools()
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_populate_fallback_pools()
		return

	var json_text := file.get_as_text()
	file.close()

	var test_json_conv := JSON.new()
	var error := test_json_conv.parse(json_text)
	if error != OK:
		_populate_fallback_pools()
		return

	var data = test_json_conv.get_data()
	if not data is Dictionary:
		_populate_fallback_pools()
		return

	for iso_key in data.keys():
		var entry: Dictionary = data[iso_key]
		var c_name: String = str(entry.get("country_name", ""))
		var m_list: Array = entry.get("male_given", [])
		var f_list: Array = entry.get("female_given", [])
		var s_list: Array = entry.get("surnames", [])
		var n_fmt: String = str(entry.get("naming_format", "{given} {family}"))

		var legacy_tuple: Array = [m_list, f_list, s_list]

		# Index by country name and ISO
		POOLS[c_name] = legacy_tuple
		POOLS[iso_key] = legacy_tuple

		var structured := {
			"country_name": c_name,
			"iso": iso_key,
			"naming_format": n_fmt,
			"male_given": m_list,
			"female_given": f_list,
			"surnames": s_list
		}
		_country_data[c_name.to_lower()] = structured
		_country_data[iso_key.to_lower()] = structured

static func get_country_data(country_or_iso: String) -> Dictionary:
	_ensure_initialized()
	var key := country_or_iso.strip_edges().to_lower()
	if _country_data.has(key):
		return _country_data[key]
	# Fallback to United States
	if _country_data.has("united states"):
		return _country_data["united states"]
	if _country_data.has("us"):
		return _country_data["us"]
	return {}

static func random_name(country: String, female: bool) -> String:
	_ensure_initialized()
	var data := get_country_data(country)
	if data.is_empty():
		return _fallback_random_name(country, female)

	var given_pool: Array = data.get("female_given" if female else "male_given", [])
	var family_pool: Array = data.get("surnames", [])
	var n_fmt: String = str(data.get("naming_format", "{given} {family}"))
	var iso: String = str(data.get("iso", ""))

	var given := str(given_pool.pick_random()) if not given_pool.is_empty() else ("Jane" if female else "John")
	var family := str(family_pool.pick_random()) if not family_pool.is_empty() else "Smith"

	# Slavic patronymic / feminine ending adjustments
	if (iso == "RU" or iso == "UA" or country.to_lower() == "russia" or country.to_lower() == "ukraine") and female:
		if not family.ends_with("a") and not family.ends_with("aya") and not family.ends_with("o") and not family.ends_with("ko") and not family.ends_with("uk") and not family.ends_with("ych"):
			family += "a"

	if n_fmt == "{family} {given}":
		return family + " " + given
	return given + " " + family

static func random_first_name(country: String, female: bool) -> String:
	_ensure_initialized()
	var data := get_country_data(country)
	if data.is_empty():
		var pool: Array = POOLS.get(country, POOLS.get("United States", [["John"], ["Jane"], ["Smith"]]))
		return str(pool[1 if female else 0].pick_random())

	var given_pool: Array = data.get("female_given" if female else "male_given", [])
	if given_pool.is_empty():
		return "Jane" if female else "John"
	return str(given_pool.pick_random())

static func random_surname(country: String) -> String:
	_ensure_initialized()
	var data := get_country_data(country)
	if data.is_empty():
		var pool: Array = POOLS.get(country, POOLS.get("United States", [["John"], ["Jane"], ["Smith"]]))
		return str(pool[2].pick_random())

	var family_pool: Array = data.get("surnames", [])
	if family_pool.is_empty():
		return "Smith"
	return str(family_pool.pick_random())

static func _fallback_random_name(country: String, female: bool) -> String:
	var pool: Array = POOLS.get(country, POOLS.get("United States", [["John"], ["Jane"], ["Smith"]]))
	var given: String = str(pool[1 if female else 0].pick_random())
	var family: String = str(pool[2].pick_random())
	if country == "Russia" and female:
		family += "a"
	return given + " " + family

static func _populate_fallback_pools() -> void:
	POOLS["United States"] = [
		["James", "John", "Robert", "Michael", "William", "David", "Richard", "Joseph", "Thomas", "Charles"],
		["Mary", "Patricia", "Jennifer", "Linda", "Elizabeth", "Barbara", "Susan", "Jessica", "Sarah", "Karen"],
		["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez"]
	]
	POOLS["US"] = POOLS["United States"]
