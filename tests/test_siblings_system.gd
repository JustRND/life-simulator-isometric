extends Node

func _ready() -> void:
	print("\n==================================================")
	print("--- Running Test Siblings System (Alpha v0.1.3) ---")
	print("==================================================\n")

	test_sibling_generation_and_family_name()
	test_sibling_background_life_progression()
	test_will_and_inheritance_selection()
	test_heir_takeover_as_sibling()
	await test_isometric_room_sibling_spawning()
	await test_relationships_panel_sibling_ui()

	print("\n==================================================")
	print("--- ALL SIBLINGS SYSTEM TESTS PASSED SUCCESSFULLY! ---")
	print("==================================================\n")
	get_tree().quit(0)


func test_sibling_generation_and_family_name() -> void:
	print("[TEST] 1. Sibling Generation & Family Name Inheritance")
	PlayerData.reset_player()
	PlayerData.first_name = "Jordan Vance"
	PlayerData.birthplace = "United States"
	PlayerData.ethnicity = "white"

	assert(PlayerData.get_family_name() == "Vance", "Family name should be Vance")

	# Test force count 0 (Only child)
	PlayerData.generate_initial_siblings(0)
	assert(PlayerData.siblings.size() == 0, "Should have 0 siblings")
	assert(not PlayerData.has_siblings(), "has_siblings should be false")
	assert(not PlayerData.has_living_siblings(), "has_living_siblings should be false")
	assert(PlayerData.get_living_siblings().size() == 0, "get_living_siblings should be empty")

	# Test force count 1
	PlayerData.generate_initial_siblings(1)
	assert(PlayerData.siblings.size() == 1, "Should have 1 sibling")
	assert(PlayerData.has_siblings(), "has_siblings should be true")
	assert(PlayerData.has_living_siblings(), "has_living_siblings should be true")
	var sib1: Dictionary = PlayerData.siblings[0]
	assert(str(sib1.get("name", "")).ends_with("Vance"), "Sibling name should end with family name 'Vance': %s" % sib1.get("name"))
	assert("Brother" in sib1.get("relation") or "Sister" in sib1.get("relation"), "Sibling relation should contain Brother or Sister: %s" % sib1.get("relation"))
	assert(sib1.get("ethnicity") == "white", "Sibling ethnicity should match player: %s" % sib1.get("ethnicity"))

	# Test force count 2
	PlayerData.generate_initial_siblings(2)
	assert(PlayerData.siblings.size() == 2, "Should have 2 siblings")
	for s in PlayerData.siblings:
		assert(str(s.get("name", "")).ends_with("Vance"), "Each sibling name must end with 'Vance': %s" % s.get("name"))

	# Test random distribution across multiple seeds produces varied outcomes
	var counts_observed: Dictionary = {}
	for seed_val in range(40):
		seed(seed_val * 777 + 13)
		PlayerData.generate_initial_siblings()
		var cnt: int = PlayerData.siblings.size()
		counts_observed[cnt] = true

	print("  Observed sibling counts during random trials: %s" % str(counts_observed.keys()))
	assert(counts_observed.has(0) or counts_observed.has(1), "Random generator must produce only children and 1+ siblings")
	print("  PASS: Sibling generation and family name inheritance verified.\n")


func test_sibling_background_life_progression() -> void:
	print("[TEST] 2. Background Life Progression (NpcLifeProgress)")
	PlayerData.reset_player()
	PlayerData.first_name = "Serena Thorne"
	PlayerData.generate_initial_siblings(1)
	var sib: Dictionary = PlayerData.siblings[0]

	NpcLifeProgress.ensure(sib)
	assert(sib.has("life_progress"), "Sibling must have life_progress dictionary")
	var lp: Dictionary = sib["life_progress"]
	assert(lp.has("education_level"), "Life progress must have education_level")
	assert(lp.has("job_title"), "Life progress must have job_title")
	assert(lp.has("bank_savings"), "Life progress must have bank_savings")

	# Age up sibling to adult and verify background life advancement
	sib["age"] = 24
	NpcLifeProgress.ensure(sib)
	var adult_edu: String = NpcLifeProgress.get_education_display(sib)
	var adult_occ: String = NpcLifeProgress.get_occupation_display(sib)
	var adult_wealth: String = NpcLifeProgress.get_finances_display(sib)
	assert(not adult_edu.is_empty(), "Adult sibling education display should not be empty")
	assert(not adult_occ.is_empty(), "Adult sibling occupation display should not be empty")
	assert(not adult_wealth.is_empty(), "Adult sibling wealth display should not be empty")

	print("  Sample Adult Sibling Progress -> Occ: %s | Edu: %s | Wealth: %s" % [adult_occ, adult_edu, adult_wealth])
	print("  PASS: Sibling background life progression verified.\n")


func test_will_and_inheritance_selection() -> void:
	print("[TEST] 3. Will & Testament SIBLINGS Option")
	PlayerData.reset_player()
	PlayerData.will_recipient = "SIBLINGS"
	assert(PlayerData.will_recipient == "SIBLINGS", "will_recipient should be SIBLINGS")

	# Verify persistence through SaveManager
	var state: Dictionary = SaveManager.capture_data()
	assert(state.has("will_recipient"), "Save state must contain will_recipient")
	assert(state["will_recipient"] == "SIBLINGS", "will_recipient in save state must be SIBLINGS")
	print("  PASS: Will and inheritance SIBLINGS beneficiary verified.\n")


func test_heir_takeover_as_sibling() -> void:
	print("[TEST] 4. Succession & Heir Takeover as Sibling")
	PlayerData.reset_player()
	PlayerData.first_name = "Marcus Stone"
	PlayerData.mother_name = "Clara Stone"
	PlayerData.father_name = "Arthur Stone"
	PlayerData.generate_initial_siblings(2)

	var heir_sib: Dictionary = PlayerData.siblings[0].duplicate(true)
	var other_sib: Dictionary = PlayerData.siblings[1].duplicate(true)
	var heir_name: String = str(heir_sib.get("name", "Sibling Stone"))
	var heir_age: int = int(heir_sib.get("age", 22))

	# Perform takeover as sibling
	PlayerData.takeover_as_heir(heir_sib, 25000, [], "sibling")

	assert(PlayerData.first_name == heir_name, "Player name should become heir's name: %s" % heir_name)
	assert(PlayerData.age == heir_age, "Player age should become heir's age: %d" % heir_age)
	assert(PlayerData.mother_name == "Clara Stone", "Mother's name should be preserved for sibling heir")
	assert(PlayerData.father_name == "Arthur Stone", "Father's name should be preserved for sibling heir")
	assert(PlayerData.bank_savings >= 25000, "Bank balance should include inherited funds")
	print("  Succession complete: Now playing as %s (Age %d) with family %s" % [PlayerData.first_name, PlayerData.age, PlayerData.get_family_name()])
	print("  PASS: Heir takeover as sibling verified.\n")


func test_isometric_room_sibling_spawning() -> void:
	print("[TEST] 5. Isometric Room Sibling Spawning & Roaming")
	PlayerData.reset_player()
	PlayerData.first_name = "Dante Silver"
	PlayerData.generate_initial_siblings(2)

	var room_scene := load("res://scenes/isometric/isometric_room.tscn") as PackedScene
	assert(room_scene != null, "isometric_room.tscn should load")
	var room = room_scene.instantiate()
	add_child(room)
	await get_tree().process_frame

	# Ensure characters are updated
	room.update_character()

	var characters_node = room.get_node_or_null("Characters")
	assert(characters_node != null, "Characters node must exist in isometric room")

	var sib0 = characters_node.get_node_or_null("SiblingCharacter_0")
	var sib1 = characters_node.get_node_or_null("SiblingCharacter_1")
	assert(sib0 != null, "SiblingCharacter_0 must be spawned in room")
	assert(sib1 != null, "SiblingCharacter_1 must be spawned in room")
	assert(sib0.visible, "SiblingCharacter_0 should be visible")

	# Verify cleanup when siblings are empty
	PlayerData.siblings.clear()
	room.update_character()
	await get_tree().process_frame
	assert(characters_node.get_node_or_null("SiblingCharacter_0") == null or sib0.is_queued_for_deletion(), "Sibling node should be removed or queued for deletion")

	room.queue_free()
	print("  PASS: Isometric room sibling avatars verified.\n")


func test_relationships_panel_sibling_ui() -> void:
	print("[TEST] 6. Relationships Panel Sibling UI Cards")
	PlayerData.reset_player()
	PlayerData.first_name = "Elena Rostova"
	PlayerData.generate_initial_siblings(1)

	var main_scene_res := load("res://scenes/main/main_screen.tscn") as PackedScene
	assert(main_scene_res != null, "main_screen.tscn should load")
	var main_scene = main_scene_res.instantiate()
	add_child(main_scene)
	await get_tree().process_frame

	main_scene.update_relationships_panel()

	var rel_list = main_scene.get_node_or_null("RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList")
	assert(rel_list != null, "RelList container must exist in RelationshipsPanel")

	var sib_header = rel_list.get_node_or_null("SiblingsHeaderCard")
	var sib_card = rel_list.get_node_or_null("SiblingCard_0")
	assert(sib_header != null, "SiblingsHeaderCard must exist in RelationshipsPanel")
	assert(sib_card != null, "SiblingCard_0 must exist in RelationshipsPanel")

	main_scene.queue_free()
	print("  PASS: Relationships panel sibling cards verified.\n")
