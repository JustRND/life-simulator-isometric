extends Node

func _ready() -> void:
	print("--- Starting Panel First Open Verification Test ---")
	get_window().size = Vector2i(450, 850)
	var main_scene = load("res://scenes/main/main_screen.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	PlayerData.age = 22
	PlayerData.money = 25000
	PlayerData.bank_savings = 50000
	PlayerData.has_started_game = true
	
	# Verify pre-population on startup
	print("Testing pre-population on startup...")
	assert(main.bank_button != null, "BankButton must exist")
	assert(main.assets_list.get_child_count() > 0, "AssetsList must be pre-populated on startup")
	assert(main.bank_list.get_child_count() > 0, "BankList must be pre-populated on startup")
	
	# 1. Test opening AssetsPanel for the first time
	print("Testing AssetsPanel first open...")
	main.show_tab("assets")
	assert(main.assets_panel.visible, "AssetsPanel must be visible")
	var bank_row = main.bank_button.get_node_or_null("ReferenceRow")
	assert(bank_row != null, "BankButton must have ReferenceRow presenter")
	assert(bank_row.heading != null and bank_row.heading.text == "BANKING", "BankButton ReferenceRow heading must be 'BANKING'")
	assert(bank_row.description != null and "First National Pixel Bank" in bank_row.description.text, "BankButton description must contain bank name")
	assert(bank_row.heading.is_visible_in_tree(), "BankButton heading must be visible immediately on first open")
	
	# Wait for animation to finish
	await get_tree().create_timer(0.4).timeout
	assert(is_equal_approx(main.assets_panel.offset_top, 0.0), "AssetsPanel offset_top must rest at 0.0")
	assert(is_equal_approx(main.assets_panel.offset_bottom, 0.0), "AssetsPanel offset_bottom must rest at 0.0")
	
	# 2. Test opening ActivitiesPanel for the first time
	print("Testing ActivitiesPanel first open...")
	main.show_tab("activities")
	assert(main.activities_panel.visible, "ActivitiesPanel must be visible")
	var act_list = main.activities_panel.find_child("ActList", true, false)
	assert(act_list != null and act_list.get_child_count() > 0, "ActList must have buttons")
	
	var tested_buttons := 0
	for child in act_list.get_children():
		if child is Button:
			var r = child.get_node_or_null("ReferenceRow")
			assert(r != null, "Activity button '%s' must have ReferenceRow" % child.name)
			assert(r.heading != null and not r.heading.text.is_empty(), "Activity button '%s' heading must not be empty" % child.name)
			assert(r.is_visible_in_tree(), "Activity button '%s' ReferenceRow must be visible on first open" % child.name)
			tested_buttons += 1
	assert(tested_buttons >= 10, "Must have verified at least 10 activity buttons")
	
	await get_tree().create_timer(0.4).timeout
	assert(is_equal_approx(main.activities_panel.offset_top, 0.0), "ActivitiesPanel offset_top must rest at 0.0")
	var edu := act_list.get_node("EducationActItem") as Button
	assert(edu.custom_minimum_size.y <= 140.0, "EducationActItem custom_minimum_size.y (%f) must not exceed 140px on first open" % edu.custom_minimum_size.y)
	assert(edu.size.y <= 140.0, "EducationActItem size.y (%f) must not exceed 140px on first open" % edu.size.y)
	
	# Close and open again
	main._on_close_panel_button_pressed()
	await get_tree().create_timer(0.4).timeout
	main.show_tab("activities")
	await get_tree().create_timer(0.4).timeout
	assert(edu.custom_minimum_size.y <= 140.0, "EducationActItem custom_minimum_size.y must remain compact on second open")
	assert(edu.size.y <= 140.0, "EducationActItem size.y must remain compact on second open")
	
	# 3. Test opening RelationshipsPanel for the first time
	print("Testing RelationshipsPanel first open...")
	main.show_tab("relationships")
	assert(main.relationships_panel.visible, "RelationshipsPanel must be visible")
	assert(main.mother_name_label.is_visible_in_tree(), "MotherNameLabel must be visible on first open")
	await get_tree().create_timer(0.4).timeout
	assert(is_equal_approx(main.relationships_panel.offset_top, 0.0), "RelationshipsPanel offset_top must rest at 0.0")
	
	# 4. Test opening BankPanel for the first time
	print("Testing BankPanel first open...")
	main.show_tab("bank")
	assert(main.bank_panel.visible, "BankPanel must be visible")
	assert(main.bank_checking_label.is_visible_in_tree(), "BankCheckingLabel must be visible on first open")
	assert(main.bank_list.get_child_count() > 1, "BankList must have cards populated")
	await get_tree().create_timer(0.4).timeout
	assert(is_equal_approx(main.bank_panel.offset_top, 0.0), "BankPanel offset_top must rest at 0.0")
	
	# 5. Test opening CharacterPanel for the first time
	print("Testing CharacterPanel first open...")
	main.show_tab("character")
	assert(main.character_panel.visible, "CharacterPanel must be visible")
	assert(main.character_name.is_visible_in_tree(), "CharacterName must be visible on first open")
	await get_tree().create_timer(0.4).timeout
	assert(is_equal_approx(main.character_panel.offset_top, 0.0), "CharacterPanel offset_top must rest at 0.0")
	
	# 6. Test opening InfantPanel for the first time
	print("Testing InfantPanel first open...")
	main.show_tab("infant")
	assert(main.infant_panel.visible, "InfantPanel must be visible")
	assert(main.current_stage_label.is_visible_in_tree(), "CurrentStageLabel must be visible on first open")
	await get_tree().create_timer(0.4).timeout
	assert(is_equal_approx(main.infant_panel.offset_top, 0.0), "InfantPanel offset_top must rest at 0.0")
	
	# 8. Test Activities button at age 0
	print("Testing Activities button at age 0...")
	PlayerData.age = 0
	main._on_activities_button_pressed()
	await get_tree().create_timer(0.4).timeout
	assert(main.activities_panel.visible, "ActivitiesPanel must be opened by Activities button even at age 0")
	main._on_close_panel_button_pressed()
	await get_tree().create_timer(0.4).timeout
	assert(main.timeline_panel.visible, "Closing activities panel restores timeline")
	
	print("--- ALL PANEL FIRST OPEN TESTS PASSED SUCCESSFULLY! ---")
	get_tree().quit(0)
