@tool
extends SceneTree

const CreationOptions = preload("res://scripts/core/creation_options.gd")
const NameCatalog = preload("res://scripts/core/name_catalog.gd")

func _init() -> void:
	print("--- TESTING NAME CATALOG (81 COUNTRIES) ---")
	var countries := CreationOptions.get_all_country_names()
	print("CreationOptions country count: %d" % countries.size())
	assert(countries.size() == 81, "Must have exactly 81 countries")

	var format_check_countries := ["Japan", "South Korea", "North Korea", "Taiwan", "Vietnam", "Hungary"]

	for country in countries:
		var iso := CreationOptions.get_country_iso(country)
		assert(iso != "", "Country must have ISO code: " + country)

		var male_name := NameCatalog.random_name(country, false)
		var female_name := NameCatalog.random_name(country, true)
		var first_name := NameCatalog.random_first_name(country, false)
		var surname := NameCatalog.random_surname(country)

		assert(male_name != "", "Male name must not be empty for " + country)
		assert(female_name != "", "Female name must not be empty for " + country)
		assert(first_name != "", "First name must not be empty for " + country)
		assert(surname != "", "Surname must not be empty for " + country)

		var data := NameCatalog.get_country_data(country)
		assert(not data.is_empty(), "Country data must exist for " + country)
		var m_cnt: int = data.get("male_given", []).size()
		var f_cnt: int = data.get("female_given", []).size()
		var s_cnt: int = data.get("surnames", []).size()

		if m_cnt < 100 or f_cnt < 100 or s_cnt < 100:
			print("FAIL: %s has counts: m=%d, f=%d, s=%d" % [country, m_cnt, f_cnt, s_cnt])
			quit(1)
			return

		# Check POOLS backward compatibility
		assert(NameCatalog.POOLS.has(country), "POOLS must have " + country)
		var tuple: Array = NameCatalog.POOLS[country]
		assert(tuple.size() == 3, "POOLS entry must have 3 elements")
		assert(tuple[0].size() >= 100, "Male pool in tuple must be >= 100")
		assert(tuple[1].size() >= 100, "Female pool in tuple must be >= 100")
		assert(tuple[2].size() >= 100, "Surname pool in tuple must be >= 100")

	print("Sampling generated names:")
	for c in ["Indonesia", "Japan", "South Korea", "Nigeria", "Ghana", "United States", "United Kingdom", "India", "China" if false else "Taiwan", "Brazil"]:
		print("  %s -> Male: '%s', Female: '%s'" % [c, NameCatalog.random_name(c, false), NameCatalog.random_name(c, true)])

	print("ALL 81 COUNTRIES PASSED NAME CATALOG TEST!")
	quit(0)
