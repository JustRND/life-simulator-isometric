extends RefCounted

# Game presentation ranges: Infant / Toddler, Child, Teenager, Adult, Elder
const STAGES = ["Infant / Toddler", "Child", "Teenager", "Adult", "Elder"]
const ETHNICITIES: Array[String] = ["black", "asian", "white", "latino"]

const COUNTRY_ETHNICITIES: Dictionary = {
	"Albania": ["white"],
	"Argentina": ["latino", "white"],
	"Australia": ["white", "asian", "black", "latino"],
	"Austria": ["white"],
	"Azerbaijan": ["white", "asian"],
	"Bahrain": ["latino", "white"],
	"Bangladesh": ["latino"],
	"Barbados": ["black", "latino"],
	"Belgium": ["white"],
	"Bosnia and Herzegovina": ["white"],
	"Botswana": ["black"],
	"Brazil": ["latino", "black", "white"],
	"Bulgaria": ["white"],
	"Cambodia": ["asian"],
	"Canada": ["white", "black", "asian", "latino"],
	"Chile": ["latino", "white"],
	"Colombia": ["latino", "white"],
	"Croatia": ["white"],
	"Cuba": ["latino", "black", "white"],
	"Cyprus": ["white"],
	"Czech Republic": ["white"],
	"Denmark": ["white"],
	"DR Congo": ["black"],
	"Egypt": ["latino", "white"],
	"Estonia": ["white"],
	"Finland": ["white"],
	"France": ["white", "black", "latino"],
	"Georgia": ["white"],
	"Germany": ["white"],
	"Ghana": ["black"],
	"Greece": ["white"],
	"Hungary": ["white"],
	"Iceland": ["white"],
	"India": ["latino"],
	"Indonesia": ["asian"],
	"Ireland": ["white"],
	"Italy": ["white"],
	"Japan": ["asian"],
	"Kazakhstan": ["asian", "white"],
	"Kenya": ["black"],
	"Kuwait": ["latino", "white"],
	"Lebanon": ["latino", "white"],
	"Lithuania": ["white"],
	"Madagascar": ["black", "asian"],
	"Malta": ["white"],
	"Mexico": ["latino"],
	"Morocco": ["latino", "white"],
	"Myanmar": ["asian"],
	"Netherlands": ["white"],
	"New Zealand": ["white", "asian", "black", "latino"],
	"Nigeria": ["black"],
	"North Korea": ["asian"],
	"Norway": ["white"],
	"Panama": ["latino", "black", "white"],
	"Philippines": ["asian"],
	"Poland": ["white"],
	"Portugal": ["white", "latino"],
	"Romania": ["white"],
	"Russia": ["white"],
	"Saudi Arabia": ["latino", "white"],
	"Senegal": ["black"],
	"Serbia": ["white"],
	"Singapore": ["asian"],
	"Slovakia": ["white"],
	"South Africa": ["black", "white"],
	"South Korea": ["asian"],
	"Spain": ["white", "latino"],
	"Sri Lanka": ["latino"],
	"Sweden": ["white"],
	"Switzerland": ["white"],
	"Taiwan": ["asian"],
	"Tanzania": ["black"],
	"Thailand": ["asian"],
	"Tunisia": ["latino", "white"],
	"Turkey": ["white", "latino"],
	"Ukraine": ["white"],
	"United Arab Emirates": ["latino", "white"],
	"United Kingdom": ["white", "asian", "black"],
	"United States": ["white", "black", "asian", "latino"],
	"Venezuela": ["latino", "white"],
	"Vietnam": ["asian"],
	"Zimbabwe": ["black"]
}

static var textures: Dictionary = {}

static func stage_index(age: int) -> int:
	if age < 5:
		return 0 # Infant & Toddler (Ages 0-4)
	if age < 13:
		return 1 # Child (Ages 5-12)
	if age < 20:
		return 2 # Teenager (Ages 13-19)
	if age < 65:
		return 3 # Adult (Ages 20-64)
	return 4     # Elder (Ages 65+)

static func get_country_ethnicities(country: String) -> Array[String]:
	for c_name in COUNTRY_ETHNICITIES.keys():
		if c_name.to_lower() == country.to_lower():
			var list: Array = COUNTRY_ETHNICITIES[c_name]
			var typed_list: Array[String] = []
			for e in list:
				typed_list.append(str(e))
			return typed_list
	var fallback: Array[String] = ["white"]
	return fallback

static func random_ethnicity_for_country(country: String) -> String:
	var allowed := get_country_ethnicities(country)
	if allowed.is_empty():
		return "white"
	return allowed.pick_random()

static func get_portrait(age: int, gender: String, track: int = 0, ethnicity: String = "white") -> Texture2D:
	var eth := ethnicity.to_lower().strip_edges()
	if not ETHNICITIES.has(eth):
		eth = "white"
	var t := posmod(track, 4)
	var stage := stage_index(age)
	var g := "female" if gender.to_upper() == "FEMALE" else "male"
	var st_names: Array[String] = ["baby", "child", "teen", "adult", "elder"]
	var st_name: String = st_names[stage]

	var key := "%s_%s_%s_%d" % [eth, g, st_name, t]
	if textures.has(key):
		return textures[key]

	var path := ""
	if stage == 0:
		path = "res://assets/portraits/%s/baby_%d.png" % [eth, t]
	else:
		path = "res://assets/portraits/%s/%s/%s_%d.png" % [eth, g, st_name, t]

	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path)
	elif ResourceLoader.exists("res://assets/portraits/white/baby_0.png"):
		tex = load("res://assets/portraits/white/baby_0.png")

	if tex != null:
		textures[key] = tex
	return tex

static func get_baby_texture(ethnicity: String, track: int) -> Texture2D:
	return get_portrait(0, "MALE", track, ethnicity)

static func get_teen_portrait(gender: String, index: int) -> Texture2D:
	var g := "female" if gender.to_upper() == "FEMALE" else "male"
	var max_count := 32 if g == "female" else 64
	var idx := posmod(index, max_count)
	var key := "teen_%s_%d" % [g, idx]
	if textures.has(key):
		return textures[key]

	var path := "res://assets/portraits/teens/%s/teen_%d.png" % [g, idx]
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path)
	if tex != null:
		textures[key] = tex
	return tex

static func texture(age: int, gender: String, variant: int = 0, ethnicity: String = "") -> Texture2D:
	var eth := ethnicity
	if eth == "":
		var loop := Engine.get_main_loop()
		if loop != null and loop.has_method("get_root"):
			var root: Node = loop.get_root()
			if root != null and root.has_node("PlayerData"):
				var pd: Node = root.get_node("PlayerData")
				if "ethnicity" in pd and str(pd.get("ethnicity")) != "":
					eth = str(pd.get("ethnicity"))
		if eth == "":
			eth = "white"
	return get_portrait(age, gender, variant, eth)

static func cutout_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = "shader_type canvas_item; void fragment(){COLOR=texture(TEXTURE,UV);}"
	var result := ShaderMaterial.new()
	result.shader = shader
	return result
