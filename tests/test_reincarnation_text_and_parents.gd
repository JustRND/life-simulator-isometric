extends Node

func _ready() -> void:
	print("=== BEGIN REINCARNATION TEXT & PARENTS DESCRIPTION TEST ===")

	PlayerData.reset_player()

	# 1. Instantiate Main Screen
	var main_res := load("res://scenes/main/main_screen.tscn") as PackedScene
	assert(main_res != null, "main_screen.tscn must load")
	var main = main_res.instantiate()
	add_child(main)

	if main.disclaimer_screen != null:
		main.disclaimer_screen.hide()
	if main.loading_screen != null:
		main.loading_screen.hide()

	await get_tree().process_frame
	await get_tree().process_frame

	# 2. Test Blessed Rebirth (Good Karma)
	var blessed_id := {
		"first_name": "Aoi Sato",
		"gender": "FEMALE",
		"birthplace": "Japan",
		"ethnicity": "asian",
		"portrait_track": 1,
		"portrait_variant": 2
	}
	var buffs := ["divine_looks", "silver_spoon", "golden_pedigree"]
	PlayerData.start_reincarnated_life(blessed_id, [], buffs)

	# Trigger main screen afterlife rebirth completion callback to rebuild timeline & panels
	main._on_afterlife_rebirth_complete()

	await get_tree().process_frame

	# Check timeline text for reincarnation decree
	var life_log = PlayerData.life_log
	assert(life_log.size() >= 2, "Life log must have at least 2 entries (judgment decree + birth/parents story)")

	var decree_text: String = str(life_log[0].get("text", ""))
	print("Reincarnation Decree Text:\n%s\n" % decree_text)

	# Must NOT have raw snake_case keys
	assert(not "divine_looks" in decree_text, "Must NOT contain raw code key divine_looks")
	assert(not "silver_spoon" in decree_text, "Must NOT contain raw code key silver_spoon")
	assert(not "golden_pedigree" in decree_text, "Must NOT contain raw code key golden_pedigree")

	# MUST have formatted human-readable titles with icons
	assert("Divine Radiance" in decree_text, "Must contain 'Divine Radiance'")
	assert("Silver Spoon Legacy" in decree_text, "Must contain 'Silver Spoon Legacy'")
	assert("Golden Pedigree" in decree_text, "Must contain 'Golden Pedigree'")
	assert("✨" in decree_text and "💎" in decree_text and "👑" in decree_text, "Must contain modifier emojis")
	print("✔ CHECK 1: Reincarnation judgment decree formatted with clean titles and emojis.")

	# Check parents description in timeline (Entry 2)
	var story_text: String = str(life_log[1].get("text", ""))
	print("Birth & Parents Story Text:\n%s\n" % story_text)

	assert(story_text.contains("My mother is"), "Timeline entry must contain mother description")
	assert(story_text.contains("My father is"), "Timeline entry must contain father description")
	assert(PlayerData.birth_story != "", "PlayerData.birth_story must be populated")
	assert(PlayerData.birth_story.contains("My mother is"), "birth_story must contain mother description")
	assert(PlayerData.birth_story.contains("My father is"), "birth_story must contain father description")
	print("✔ CHECK 2: Timeline STILL provides the character's parents description after reincarnating.")

	# Check Relationships Panel data integrity
	assert(PlayerData.mother_name != "" and PlayerData.mother_name != "Elena", "Mother name should be randomized for country: %s" % PlayerData.mother_name)
	assert(PlayerData.father_name != "" and PlayerData.father_name != "Marcus", "Father name should be randomized for country: %s" % PlayerData.father_name)
	assert(PlayerData.mother_base_age >= 20, "Mother base age must be realistic (>=20): %d" % PlayerData.mother_base_age)
	assert(PlayerData.father_base_age >= 20, "Father base age must be realistic (>=20): %d" % PlayerData.father_base_age)
	assert(PlayerData.mother_education != "", "Mother education must be specified: %s" % PlayerData.mother_education)
	assert(PlayerData.father_education != "", "Father education must be specified: %s" % PlayerData.father_education)
	assert(PlayerData.mother_relationship == 100, "Golden pedigree grants 100 relationship")
	assert(PlayerData.father_relationship == 100, "Golden pedigree grants 100 relationship")
	print("✔ CHECK 3: Parents data (names, realistic ages, occupations, education) properly initialized for relationships panel.")

	# Check Character Panel story text
	assert(main.character_story != null and is_instance_valid(main.character_story), "character_story label must exist")
	assert(main.character_story.text.contains("My mother is"), "Character panel story must include parents description: %s" % main.character_story.text)
	print("✔ CHECK 4: Character Panel profile displays parents description.")

	# 3. Test Condemned Rebirth (Bad Karma with Debuffs)
	var condemned_id := {
		"first_name": "Hans Gruber",
		"gender": "MALE",
		"birthplace": "Germany",
		"ethnicity": "white",
		"portrait_track": 0,
		"portrait_variant": 1
	}
	var debuffs := ["bad_stats", "no_parents", "poverty"]
	PlayerData.start_reincarnated_life(condemned_id, debuffs, [])
	main._on_afterlife_rebirth_complete()
	await get_tree().process_frame

	var condemned_decree: String = str(PlayerData.life_log[0].get("text", ""))
	print("Condemned Decree Text:\n%s\n" % condemned_decree)

	assert(not "bad_stats" in condemned_decree and not "no_parents" in condemned_decree and not "poverty" in condemned_decree, "No raw keys in condemned decree")
	assert("Diminished Core Attributes" in condemned_decree, "Must contain 'Diminished Core Attributes'")
	assert("Orphaned at Birth" in condemned_decree, "Must contain 'Orphaned at Birth'")
	assert("Crushing Generational Poverty" in condemned_decree, "Must contain 'Crushing Generational Poverty'")
	assert("📉" in condemned_decree and "🏚️" in condemned_decree and "💸" in condemned_decree, "Must contain debuff emojis")

	var condemned_story: String = str(PlayerData.life_log[1].get("text", ""))
	print("Orphan Story Text:\n%s\n" % condemned_story)
	assert(condemned_story.contains("orphan") or condemned_story.contains("foster care"), "Orphaned rebirth must describe absent/deceased parents")
	print("✔ CHECK 5: Condemned rebirth formatted properly with orphaned parents description.")

	print("\n⭐⭐⭐ ALL REINCARNATION TEXT AND PARENTS DESCRIPTION TESTS PASSED! ⭐⭐⭐\n")
	var fa := FileAccess.open("res://test_reincarnation_result.txt", FileAccess.WRITE)
	if fa != null:
		fa.store_string("SUCCESS: ALL 5 REINCARNATION CHECKS PASSED!")
		fa.close()
	get_tree().quit(0)
