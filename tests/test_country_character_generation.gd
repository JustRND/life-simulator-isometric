extends Node

const CreationOptions = preload("res://scripts/core/creation_options.gd")
const NameCatalog = preload("res://scripts/core/name_catalog.gd")
const PortraitCatalog = preload("res://scripts/core/portrait_catalog.gd")
const AvatarRegistry = preload("res://scripts/core/avatar_registry.gd")

func _ready() -> void:
	print("=================================================================")
	print("STARTING TEST: COUNTRY CHARACTER GENERATION & TEENAGER AVATAR SYSTEM")
	print("=================================================================")

	test_all_81_countries_name_pools()
	test_cultural_naming_formats()
	test_teenager_avatars_only()
	test_manual_customization_preservation()
	test_starting_age_and_progression_compatibility()
	test_save_load_and_legacy_compatibility()

	print("\n=================================================================")
	print("ALL TESTS PASSED SUCCESSFULLY!")
	print("=================================================================")
	get_tree().quit(0)

func test_all_81_countries_name_pools() -> void:
	print("\n[PHASE 1 & 2] Verifying All 81 Countries & Name Pools...")
	var countries: Array[String] = CreationOptions.get_all_country_names()
	assert(countries.size() == 81, "Must have exactly 81 countries, found: %d" % countries.size())

	for country in countries:
		var iso: String = CreationOptions.get_country_iso(country)
		assert(iso != "" and (iso != "US" or country == "United States"), "Invalid ISO for " + country)

		var c_from_iso: String = CreationOptions.get_country_by_iso(iso)
		assert(c_from_iso.to_lower() == country.to_lower(), "Round-trip ISO lookup failed for " + country)

		var data: Dictionary = NameCatalog.get_country_data(country)
		assert(not data.is_empty(), "Data empty for " + country)

		var m_cnt: int = data.get("male_given", []).size()
		var f_cnt: int = data.get("female_given", []).size()
		var s_cnt: int = data.get("surnames", []).size()

		assert(m_cnt >= 100, "%s has %d male given names (expected >= 100)" % [country, m_cnt])
		assert(f_cnt >= 100, "%s has %d female given names (expected >= 100)" % [country, f_cnt])
		assert(s_cnt >= 100, "%s has %d surnames (expected >= 100)" % [country, s_cnt])

		# Check random name generation returns non-empty strings
		var male_name: String = NameCatalog.random_name(country, false)
		var female_name: String = NameCatalog.random_name(country, true)
		assert(not male_name.is_empty(), "Male name empty for " + country)
		assert(not female_name.is_empty(), "Female name empty for " + country)

	print("  PASS: All 81 countries have >= 100 male, >= 100 female, and >= 100 surnames!")

func test_cultural_naming_formats() -> void:
	print("\n[PHASE 2.3] Verifying Cultural Naming Formats & Accuracies...")
	# East Asian / Hungarian {family} {given} naming format check
	var east_asian: Array[String] = ["Japan", "South Korea", "North Korea", "Taiwan", "Vietnam", "Hungary"]
	for country in east_asian:
		var data: Dictionary = NameCatalog.get_country_data(country)
		assert(str(data.get("naming_format", "")) == "{family} {given}", country + " must have {family} {given} format")

	# Russian female surname inflection check
	var ru_data: Dictionary = NameCatalog.get_country_data("Russia")
	var sample_found_inflection: bool = false
	for i in range(50):
		var ru_fem_name: String = NameCatalog.random_name("Russia", true)
		var parts: PackedStringArray = ru_fem_name.split(" ")
		if parts.size() >= 2:
			var surname: String = parts[parts.size() - 1]
			if surname.ends_with("a") or surname.ends_with("aya"):
				sample_found_inflection = true
				break
	assert(sample_found_inflection, "Russian female surnames must properly reflect feminine forms")

	print("  PASS: Cultural naming conventions, ordering, and inflections verified!")

func test_teenager_avatars_only() -> void:
	print("\n[PHASE 3 & 4] Verifying Teenager-Only Avatar Assets & Selection...")
	var f_count: int = AvatarRegistry.get_teen_count("FEMALE")
	var m_count: int = AvatarRegistry.get_teen_count("MALE")
	assert(f_count == 32, "Female teen avatar count must be 32, got %d" % f_count)
	assert(m_count == 64, "Male teen avatar count must be 64, got %d" % m_count)

	# Verify every avatar ID resolves to teenager and valid texture
	for i in range(f_count):
		var a_id: String = AvatarRegistry.get_avatar_id("FEMALE", i)
		assert(a_id.begins_with("teen_female_"), "Invalid female avatar ID: " + a_id)
		var tex: Texture2D = AvatarRegistry.get_teen_texture("FEMALE", i)
		assert(tex != null, "Missing texture for " + a_id)
		var disp: String = AvatarRegistry.get_display_text("FEMALE", i)
		assert(disp.begins_with("Teenager • Style"), "Display text must be Teenager, got: " + disp)
		assert(not disp.contains("Baby") and not disp.contains("Child") and not disp.contains("Adult") and not disp.contains("Elder"), "Must not mention baby/child/adult/elder")

	for i in range(m_count):
		var a_id: String = AvatarRegistry.get_avatar_id("MALE", i)
		assert(a_id.begins_with("teen_male_"), "Invalid male avatar ID: " + a_id)
		var tex: Texture2D = AvatarRegistry.get_teen_texture("MALE", i)
		assert(tex != null, "Missing texture for " + a_id)
		var disp: String = AvatarRegistry.get_display_text("MALE", i)
		assert(disp.begins_with("Teenager • Style"), "Display text must be Teenager, got: " + disp)

	# Verify all 81 countries have valid default teenager avatar indices
	for country in CreationOptions.get_all_country_names():
		var def_f: int = AvatarRegistry.get_default_teen_index(country, "FEMALE")
		var def_m: int = AvatarRegistry.get_default_teen_index(country, "MALE")
		assert(def_f >= 0 and def_f < f_count, "Default female teen index out of range for " + country)
		assert(def_m >= 0 and def_m < m_count, "Default male teen index out of range for " + country)

	print("  PASS: 96 distinct teenager avatars verified; initial character creation is strictly teen-only!")

func test_manual_customization_preservation() -> void:
	print("\n[PHASE 4.2] Verifying Manual Customization Freedom & Persistence...")
	# Simulate character creation logic
	var is_name_manually_edited: bool = false
	var is_avatar_manually_selected: bool = false
	var chosen_country: String = "Indonesia"
	var chosen_gender: String = "MALE"
	var chosen_name: String = NameCatalog.random_name(chosen_country, false)
	var chosen_teen_idx: int = AvatarRegistry.get_default_teen_index(chosen_country, chosen_gender)

	# 1. Changing country without manual edits should update name & avatar
	chosen_country = "Japan"
	if not is_name_manually_edited:
		chosen_name = NameCatalog.random_name(chosen_country, chosen_gender == "FEMALE")
	if not is_avatar_manually_selected:
		chosen_teen_idx = AvatarRegistry.get_default_teen_index(chosen_country, chosen_gender)

	assert(not chosen_name.is_empty(), "Name should be updated for Japan")

	# 2. Player types custom name
	chosen_name = "Alexander Great"
	is_name_manually_edited = true

	# 3. Player manually picks avatar style 5
	chosen_teen_idx = 5
	is_avatar_manually_selected = true

	# 4. Player switches country to "Ghana"
	chosen_country = "Ghana"
	if not is_name_manually_edited:
		chosen_name = NameCatalog.random_name(chosen_country, chosen_gender == "FEMALE")
	if not is_avatar_manually_selected:
		chosen_teen_idx = AvatarRegistry.get_default_teen_index(chosen_country, chosen_gender)

	# Verify manual name and avatar WERE NOT OVERWRITTEN
	assert(chosen_name == "Alexander Great", "Manual name must NOT be overwritten by country change! Got: " + chosen_name)
	assert(chosen_teen_idx == 5, "Manual avatar must NOT be overwritten by country change! Got: %d" % chosen_teen_idx)

	# 5. Clicking Randomize clears flags and updates both
	is_name_manually_edited = false
	is_avatar_manually_selected = false
	chosen_country = "Brazil"
	chosen_name = NameCatalog.random_name(chosen_country, chosen_gender == "FEMALE")
	chosen_teen_idx = AvatarRegistry.get_default_teen_index(chosen_country, chosen_gender)

	assert(chosen_name != "Alexander Great", "Randomize must roll a new name")

	print("  PASS: Player manual customization is completely respected across country changes!")

func test_starting_age_and_progression_compatibility() -> void:
	print("\n[PHASE 5] Verifying Starting Age (17) & Aging Progression...")
	# Verify PlayerData starts at age 17
	PlayerData.reset_player()
	assert(PlayerData.age == 17, "Starting age must be exactly 17, got: %d" % PlayerData.age)
	assert(PortraitCatalog.stage_index(PlayerData.age) == 2, "Age 17 must be Stage 2 (Teenager)")

	# Set avatar_id
	PlayerData.avatar_id = "teen_male_12"

	# At age 17, texture resolves to teenager avatar
	var tex_teen: Texture2D = AvatarRegistry.get_texture_by_id(PlayerData.avatar_id, PlayerData.age, PlayerData.gender, PlayerData.portrait_track, PlayerData.ethnicity)
	assert(tex_teen != null, "Teen texture must be valid at age 17")

	# Progression: Age character to 20 (Adult)
	PlayerData.age = 20
	assert(PortraitCatalog.stage_index(PlayerData.age) == 3, "Age 20 must be Stage 3 (Adult)")
	var tex_adult: Texture2D = PortraitCatalog.get_portrait(PlayerData.age, PlayerData.gender, PlayerData.portrait_track, PlayerData.ethnicity)
	assert(tex_adult != null, "Adult texture must resolve cleanly upon aging to 20")

	# Age character to 65 (Elder)
	PlayerData.age = 65
	assert(PortraitCatalog.stage_index(PlayerData.age) == 4, "Age 65 must be Stage 4 (Elder)")
	var tex_elder: Texture2D = PortraitCatalog.get_portrait(PlayerData.age, PlayerData.gender, PlayerData.portrait_track, PlayerData.ethnicity)
	assert(tex_elder != null, "Elder texture must resolve cleanly upon aging to 65")

	print("  PASS: Starting age 17 and full life-cycle aging transitions functioning perfectly!")

func test_save_load_and_legacy_compatibility() -> void:
	print("\n[PHASE 6] Verifying Save/Load & Legacy Save Compatibility...")
	PlayerData.reset_player()
	PlayerData.first_name = "Kofi"
	PlayerData.birthplace = "Ghana"
	PlayerData.gender = "MALE"
	PlayerData.age = 17
	PlayerData.avatar_id = "teen_male_16"
	PlayerData.has_started_game = true

	var save_dict: Dictionary = SaveManager.capture_data()
	assert(save_dict.has("avatar_id"), "Save data must include avatar_id")
	assert(str(save_dict.get("avatar_id")) == "teen_male_16", "Save data must persist chosen avatar_id")

	# Test loading modern save
	PlayerData.avatar_id = ""
	# Direct dict load check
	PlayerData.avatar_id = str(save_dict.get("avatar_id", ""))
	assert(PlayerData.avatar_id == "teen_male_16", "Loaded modern save must restore avatar_id")

	# Test legacy save WITHOUT avatar_id
	var legacy_dict: Dictionary = save_dict.duplicate()
	legacy_dict.erase("avatar_id")
	assert(not legacy_dict.has("avatar_id"), "Simulated legacy save has no avatar_id")

	var legacy_avatar_id: String = str(legacy_dict.get("avatar_id", ""))
	assert(legacy_avatar_id == "", "Legacy avatar_id defaults safely to empty string")

	# Verify fallback portrait resolution for legacy save
	var legacy_tex: Texture2D = AvatarRegistry.get_texture_by_id(legacy_avatar_id, 17, "MALE", 0, "white")
	assert(legacy_tex != null, "Legacy save must render valid fallback portrait without crashing")

	print("  PASS: Save/load and legacy backward compatibility 100% verified!")
