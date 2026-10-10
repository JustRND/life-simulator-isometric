extends Node

func _ready() -> void:
	print("=== BEGIN HOUSEHOLD INTERACTIONS & MOVE OUT TESTS ===")

	# 1. Instantiate MainScreen first so its _ready() / SaveManager.load_game doesn't overwrite test state
	var main_res = load("res://scenes/main/main_screen.tscn") as PackedScene
	assert(main_res != null, "main_screen.tscn must load")
	var main = main_res.instantiate()
	add_child(main)
	await get_tree().process_frame

	# 2. Reset PlayerData default state and methods
	PlayerData.reset_player()
	assert(PlayerData.has_moved_out_from_parents == false, "Player should start living with parents")
	assert(PlayerData.current_residence_name == "", "Default residence name is empty")
	assert(PlayerData.has_independent_residence() == false, "Default should not have independent residence")
	assert("Parents" in PlayerData.get_current_residence_title(), "Residence title should reflect parents")
	print("✔ 1. PlayerData initial state verified")

	# 3. Setup character and parents
	PlayerData.first_name = "Alex"
	PlayerData.age = 17
	PlayerData.gender = "MALE"
	PlayerData.ethnicity = "asian"
	PlayerData.mother_name = "Elena"
	PlayerData.mother_alive = true
	PlayerData.father_name = "Marcus"
	PlayerData.father_alive = true

	# 4. Instantiate IsometricRoom and verify parents are present
	var room_res = load("res://scenes/isometric/isometric_room.tscn") as PackedScene
	assert(room_res != null, "isometric_room.tscn must load")
	var room = room_res.instantiate()
	add_child(room)
	await get_tree().process_frame

	var chars = room.get_node("Characters")
	assert(chars.get_node_or_null("IsometricCharacter") != null, "Player character must exist")
	assert(chars.get_node_or_null("MotherCharacter") != null, "Mother must exist in room before move out")
	assert(chars.get_node_or_null("FatherCharacter") != null, "Father must exist in room before move out")
	print("✔ 2. Parents verified present in isometric room prior to moving out")

	# 5. Verify HouseholdActItem button in Activities
	var act_list = main.get_node_or_null("ActivitiesPanel/ActMargin/ActContent/ActScroll/ActList")
	assert(act_list != null, "ActList must exist")
	var household_btn = act_list.get_node_or_null("HouseholdActItem") as Button
	assert(household_btn != null, "HouseholdActItem button must exist in Activities")
	print("✔ 3. HouseholdActItem button confirmed in Activities panel")

	# 6. Test minor age check (Age 17: button should be disabled for moving out)
	PlayerData.age = 17
	main._show_household_interactions_modal()
	await get_tree().process_frame

	var hh_overlay = main.household_modal_overlay
	assert(hh_overlay != null and is_instance_valid(hh_overlay), "Household modal overlay must open")

	# Find the MOVE OUT button inside the modal
	var move_out_btn := _find_button_with_text(hh_overlay, "MOVE OUT FROM PARENTS HOUSE")
	assert(move_out_btn != null, "MOVE OUT button must exist in Household Interactions panel")
	assert(move_out_btn.disabled == true, "MOVE OUT button must be disabled for minor (age 17)")
	print("✔ 4. Underage restriction verified: MOVE OUT button is disabled when player is < 18")
	hh_overlay.queue_free()
	await get_tree().process_frame

	# 6. Test adult age check (Age 18+: button becomes enabled)
	PlayerData.age = 18
	main._show_household_interactions_modal()
	await get_tree().process_frame

	hh_overlay = main.household_modal_overlay
	assert(hh_overlay != null and is_instance_valid(hh_overlay), "Household modal overlay must open at age 18")

	move_out_btn = _find_button_with_text(hh_overlay, "MOVE OUT FROM PARENTS HOUSE")
	assert(move_out_btn != null, "MOVE OUT button must exist at age 18")
	assert(move_out_btn.disabled == false, "MOVE OUT button must be enabled for adult age 18+")
	print("✔ 5. Adulthood verified: MOVE OUT button is enabled when player is 18+")

	# 7. Test prompt opening on click
	move_out_btn.pressed.emit()
	await get_tree().process_frame

	# Verify prompt modal opened with Buy and Rent options
	var prompt_found := false
	for child in main.get_children():
		if child is ColorRect and child != hh_overlay and child.visible:
			var found_lbl := _find_label_with_text(child, "MOVE OUT FROM PARENTS")
			if found_lbl != null:
				prompt_found = true
				break
	assert(prompt_found, "Move out choice prompt modal must be displayed")
	print("✔ 6. Move Out choice prompt successfully opens upon clicking button")

	# 8. Test execution of moving out (e.g. moving into rented or bought home)
	# Add a partner and child to verify they REMAIN in the house, while parents are cleared!
	PlayerData.partner = {
		"name": "Chloe",
		"status": "Wife",
		"gender": "FEMALE",
		"age": 20,
		"is_alive": true,
		"portrait_track": 1,
		"ethnicity": "asian"
	}
	var kid = PlayerData.add_player_child("Tommy", "MALE", 1)

	# Execute move out to "Suburban 1-Bedroom Flat"
	main._execute_move_out("rented", "Suburban 1-Bedroom Flat")
	await get_tree().process_frame

	assert(PlayerData.has_moved_out_from_parents == true, "PlayerData.has_moved_out_from_parents must be true")
	assert(PlayerData.current_residence_name == "Suburban 1-Bedroom Flat", "Residence name should be updated")

	# Update room character avatars
	room.update_character()
	await get_tree().process_frame

	# Check room avatars:
	assert(chars.get_node_or_null("IsometricCharacter") != null, "Player must remain in isometric room")
	assert(chars.get_node_or_null("MotherCharacter") == null, "Mother avatar MUST BE REMOVED from the house")
	assert(chars.get_node_or_null("FatherCharacter") == null, "Father avatar MUST BE REMOVED from the house")
	assert(chars.get_node_or_null("PartnerCharacter") != null, "Partner MUST REMAIN in the house")
	assert(chars.get_node_or_null("ChildCharacter_0") != null, "Child MUST REMAIN in the house")
	print("✔ 7. Verified: Mother and Father avatars REMOVED from room; Partner and Child REMAIN in house")

	# 9. Verify Parents REMAIN in Relationships Panel
	assert(PlayerData.mother_alive == true, "Mother must still be alive in PlayerData relationships")
	assert(PlayerData.father_alive == true, "Father must still be alive in PlayerData relationships")
	assert(PlayerData.mother_name == "Elena", "Mother name preserved in relationships")
	assert(PlayerData.father_name == "Marcus", "Father name preserved in relationships")
	print("✔ 8. Verified: Parents STILL EXIST in Relationships (not deleted from relationship data)")

	# 10. Verify MOVE OUT button is now permanently GRAYED OUT for this character
	main._show_household_interactions_modal()
	await get_tree().process_frame

	hh_overlay = main.household_modal_overlay
	assert(hh_overlay != null and is_instance_valid(hh_overlay), "Household modal opens after move out")

	move_out_btn = _find_button_with_text(hh_overlay, "MOVE OUT FROM PARENTS HOUSE")
	assert(move_out_btn != null, "MOVE OUT button exists in panel")
	assert(move_out_btn.disabled == true, "MOVE OUT button MUST BE GRAYED OUT once moved out")
	print("✔ 9. Verified: MOVE OUT button is permanently grayed out/disabled after moving out")
	hh_overlay.queue_free()

	# 11. Verify Save and Load persistence
	SaveManager.save_game()
	var save_data = SaveManager.capture_data()
	assert(save_data.has("has_moved_out_from_parents"), "Save data must include has_moved_out_from_parents")
	assert(save_data["has_moved_out_from_parents"] == true, "Saved has_moved_out_from_parents must be true")
	assert(save_data["current_residence_name"] == "Suburban 1-Bedroom Flat", "Saved residence name matches")

	# Reset and reload
	PlayerData.reset_player()
	assert(PlayerData.has_moved_out_from_parents == false, "Reset resets moved out status for next timeline")
	SaveManager.load_game()
	assert(PlayerData.has_moved_out_from_parents == true, "Loaded moved out status restored correctly")
	assert(PlayerData.current_residence_name == "Suburban 1-Bedroom Flat", "Loaded residence name restored")
	print("✔ 10. Verified: Save and Load persistence of household move out state")

	# 12. Verify Next Generation / Reset timeline resets for new character
	PlayerData.reset_player()
	PlayerData.mother_name = "Sarah"
	PlayerData.mother_alive = true
	assert(PlayerData.has_moved_out_from_parents == false, "New character timeline starts living with parents again")
	room.update_character()
	await get_tree().process_frame
	assert(chars.get_node_or_null("MotherCharacter") != null, "New character timeline spawns parents again")
	print("✔ 11. Verified: Reset / Next character timeline starts fresh living with parents")

	print("=== ALL HOUSEHOLD INTERACTIONS & MOVE OUT TESTS PASSED! ===")
	get_tree().quit()


func _find_button_with_text(node: Node, text_to_find: String) -> Button:
	if node is Button and text_to_find in node.text:
		return node
	for child in node.get_children():
		var found = _find_button_with_text(child, text_to_find)
		if found != null:
			return found
	return null


func _find_label_with_text(node: Node, text_to_find: String) -> Label:
	if node is Label and text_to_find in node.text:
		return node
	for child in node.get_children():
		var found = _find_label_with_text(child, text_to_find)
		if found != null:
			return found
	return null
