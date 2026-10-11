extends RefCounted

const PortraitCatalog = preload("res://scripts/core/portrait_catalog.gd")

# Total teenager avatars available in assets
const FEMALE_TEEN_COUNT: int = 32
const MALE_TEEN_COUNT: int = 64

# Ethnicity track mappings to canonical teen asset indices
const ETHNICITY_TEEN_INDICES: Dictionary = {
	"black": {
		"female": [7, 15, 23, 31],
		"male": [16, 18, 20, 22]
	},
	"asian": {
		"female": [2, 9, 19, 27],
		"male": [2, 10, 36, 60]
	},
	"white": {
		"female": [3, 11, 18, 26],
		"male": [0, 1, 3, 4]
	},
	"latino": {
		"female": [1, 13, 17, 29],
		"male": [17, 26, 34, 42]
	}
}

static var _cached_textures: Dictionary = {}

static func get_teen_count(gender: String) -> int:
	var g: String = gender.to_upper().strip_edges()
	return FEMALE_TEEN_COUNT if g == "FEMALE" else MALE_TEEN_COUNT

static func get_avatar_id(gender: String, index: int) -> String:
	var g: String = "female" if gender.to_upper() == "FEMALE" else "male"
	var count: int = get_teen_count(gender)
	var idx: int = posmod(index, count)
	return "teen_%s_%d" % [g, idx]

static func parse_avatar_id(avatar_id: String) -> Dictionary:
	var id: String = avatar_id.strip_edges()
	if id.begins_with("teen_female_"):
		var idx_str: String = id.substr("teen_female_".length())
		if idx_str.is_valid_int():
			return {"gender": "FEMALE", "index": int(idx_str), "valid": true}
	elif id.begins_with("teen_male_"):
		var idx_str: String = id.substr("teen_male_".length())
		if idx_str.is_valid_int():
			return {"gender": "MALE", "index": int(idx_str), "valid": true}
	return {"gender": "MALE", "index": 0, "valid": false}

static func get_teen_texture(gender: String, index: int) -> Texture2D:
	return PortraitCatalog.get_teen_portrait(gender, index)

static func get_texture_by_id(avatar_id: String, fallback_age: int = 17, fallback_gender: String = "MALE", fallback_track: int = 0, fallback_ethnicity: String = "white") -> Texture2D:
	var parsed: Dictionary = parse_avatar_id(avatar_id)
	if bool(parsed.get("valid", false)):
		var g: String = str(parsed.get("gender", "MALE"))
		var idx: int = int(parsed.get("index", 0))
		var tex: Texture2D = get_teen_texture(g, idx)
		if tex != null:
			return tex
	return PortraitCatalog.get_portrait(fallback_age, fallback_gender, fallback_track, fallback_ethnicity)

static func get_default_teen_index(country: String, gender: String) -> int:
	var g: String = "female" if gender.to_upper() == "FEMALE" else "male"
	var eth_list: Array[String] = PortraitCatalog.get_country_ethnicities(country)
	var eth: String = str(eth_list.pick_random()) if not eth_list.is_empty() else "white"

	var indices: Array = ETHNICITY_TEEN_INDICES.get(eth, {}).get(g, [0])
	if indices.is_empty():
		return 0
	return int(indices.pick_random())

static func get_ethnicity_for_teen_index(gender: String, index: int) -> String:
	var g: String = "female" if gender.to_upper() == "FEMALE" else "male"
	for eth_var: Variant in ETHNICITY_TEEN_INDICES.keys():
		var eth: String = str(eth_var)
		var list: Array = ETHNICITY_TEEN_INDICES[eth].get(g, [])
		if list.has(index):
			return eth
	return "white"

static func get_track_for_teen_index(gender: String, index: int) -> int:
	var g: String = "female" if gender.to_upper() == "FEMALE" else "male"
	for eth_var: Variant in ETHNICITY_TEEN_INDICES.keys():
		var eth: String = str(eth_var)
		var list: Array = ETHNICITY_TEEN_INDICES[eth].get(g, [])
		var found_track: int = list.find(index)
		if found_track != -1:
			return found_track
	return index % 4

static func get_display_text(gender: String, index: int) -> String:
	var total: int = get_teen_count(gender)
	var idx: int = posmod(index, total)
	return "Teenager • Style %d of %d" % [idx + 1, total]

static func get_all_teen_avatars(gender: String = "") -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var genders: Array[String] = ["female", "male"]
	if gender.to_upper() == "FEMALE":
		genders = ["female"]
	elif gender.to_upper() == "MALE":
		genders = ["male"]

	for g in genders:
		var count: int = FEMALE_TEEN_COUNT if g == "female" else MALE_TEEN_COUNT
		for i in range(count):
			var a_id: String = "teen_%s_%d" % [g, i]
			var path: String = "res://assets/portraits/teens/%s/teen_%d.png" % [g, i]
			results.append({
				"id": a_id,
				"gender": g.to_upper(),
				"index": i,
				"age_category": "teenager",
				"path": path,
				"ethnicity": get_ethnicity_for_teen_index(g, i),
				"track": get_track_for_teen_index(g, i)
			})
	return results
