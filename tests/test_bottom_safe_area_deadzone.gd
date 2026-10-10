extends Node

func _ready() -> void:
	print("=== BEGIN BOTTOM SAFE AREA & DEADZONE TESTS ===")

	# 1. Instantiate MainScreen
	var main_res = load("res://scenes/main/main_screen.tscn") as PackedScene
	assert(main_res != null, "main_screen.tscn must load")
	var main = main_res.instantiate()
	add_child(main)
	await get_tree().process_frame

	# 2. Check initial safe area adjustment
	assert(main.has_method("_adjust_safe_area"), "_adjust_safe_area must exist on MainScreen")
	print("✔ 1. MainScreen loaded with _adjust_safe_area method")

	# 3. Simulate mobile / iPhone environment and verify safe area metrics
	# We can test by calling _adjust_safe_area and inspecting values
	main._adjust_safe_area()
	await get_tree().process_frame

	print("Current safe top: ", main.current_safe_top_m, " bottom: ", main.current_safe_bottom_m)
	assert(main.current_safe_bottom_m >= 0.0, "current_safe_bottom_m must be non-negative")

	# Test explicit iPhone bottom safe area:
	# Force mobile & iOS evaluation:
	main.current_safe_bottom_m = 84.0
	main.current_safe_top_m = 40.0
	main._adjust_safe_area()
	await get_tree().process_frame

	# On headless/Windows environment, let's verify that when bottom_m is set, margins apply correctly:
	var act_panel = main.get_node_or_null("ActivitiesPanel")
	assert(act_panel != null, "ActivitiesPanel must exist")
	var act_margin = act_panel.get_node_or_null("ActMargin") as MarginContainer
	assert(act_margin != null, "ActMargin must exist")
	
	var mb = act_margin.get_theme_constant("margin_bottom")
	print("ActivitiesPanel ActMargin margin_bottom: ", mb)
	assert(mb >= 64, "ActMargin margin_bottom must be at least 64px")
	print("✔ 2. ActMargin bottom margin confirmed >= 64px")

	# 4. Verify ActListBottomSpacer exists in ActList
	var act_list = act_panel.get_node_or_null("ActMargin/ActContent/ActScroll/ActList")
	assert(act_list != null, "ActList must exist")
	var spacer = act_list.get_node_or_null("ActListBottomSpacer")
	assert(spacer != null, "ActListBottomSpacer must exist in ActList")
	assert(spacer.custom_minimum_size.y >= 20, "ActListBottomSpacer must have minimum height >= 20")
	print("✔ 3. ActListBottomSpacer confirmed at the bottom of ActList")

	# 5. Verify HouseholdActItem is placed before spacer and elevated
	var household_btn = act_list.get_node_or_null("HouseholdActItem") as Button
	assert(household_btn != null, "HouseholdActItem button must exist")
	var household_idx = household_btn.get_index()
	var spacer_idx = spacer.get_index()
	assert(household_idx < spacer_idx, "HouseholdActItem must be before bottom spacer")
	print("✔ 4. HouseholdActItem verified preceding bottom spacer")

	# 6. Verify RelationshipsPanel RelMargin
	var rel_panel = main.get_node_or_null("RelationshipsPanel")
	assert(rel_panel != null, "RelationshipsPanel must exist")
	var rel_margin = rel_panel.get_node_or_null("RelMargin") as MarginContainer
	assert(rel_margin != null, "RelMargin must exist")
	assert(rel_margin.get_theme_constant("margin_bottom") >= 64, "RelMargin margin_bottom must be >= 64")
	print("✔ 5. RelationshipsPanel RelMargin bottom clearance verified")

	# 7. Verify AssetsPanel AssetsMargin
	var assets_panel = main.get_node_or_null("AssetsPanel")
	assert(assets_panel != null, "AssetsPanel must exist")
	var assets_margin = assets_panel.get_node_or_null("AssetsMargin") as MarginContainer
	assert(assets_margin != null, "AssetsMargin must exist")
	assert(assets_margin.get_theme_constant("margin_bottom") >= 64, "AssetsMargin margin_bottom must be >= 64")
	print("✔ 6. AssetsPanel AssetsMargin bottom clearance verified")

	# 8. Verify BankPanel BankMargin
	var bank_panel = main.get_node_or_null("BankPanel")
	assert(bank_panel != null, "BankPanel must exist")
	var bank_margin = bank_panel.get_node_or_null("BankMargin") as MarginContainer
	assert(bank_margin != null, "BankMargin must exist")
	assert(bank_margin.get_theme_constant("margin_bottom") >= 64, "BankMargin margin_bottom must be >= 64")
	print("✔ 7. BankPanel BankMargin bottom clearance verified")

	# 9. Verify CharacterPanel and InfantPanel margins
	var char_panel = main.get_node_or_null("CharacterPanel")
	assert(char_panel != null, "CharacterPanel must exist")
	var char_margin = char_panel.get_node_or_null("CharacterMargin") as MarginContainer
	assert(char_margin != null, "CharacterMargin must exist")
	assert(char_margin.get_theme_constant("margin_bottom") >= 64, "CharacterMargin margin_bottom >= 64")

	var infant_panel = main.get_node_or_null("InfantPanel")
	assert(infant_panel != null, "InfantPanel must exist")
	var infant_margin = infant_panel.get_node_or_null("InfantMargin") as MarginContainer
	assert(infant_margin != null, "InfantMargin must exist")
	assert(infant_margin.get_theme_constant("margin_bottom") >= 64, "InfantMargin margin_bottom >= 64")
	print("✔ 8. CharacterPanel & InfantPanel margins verified >= 64px")

	# 10. Verify Cyber Modal respects safe area
	main.current_safe_bottom_m = 84.0
	main.current_safe_top_m = 40.0
	var modal_dict = main._create_cyber_modal("TEST MODAL", "Safe Area Test", Color.CYAN)
	var modal_overlay: Control = modal_dict["overlay"]
	assert(modal_overlay != null, "Modal overlay must exist")
	var modal_margin = modal_overlay.get_child(0) as MarginContainer
	assert(modal_margin != null, "Modal outer MarginContainer must exist")
	var modal_bottom_m = modal_margin.get_theme_constant("margin_bottom")
	print("Modal margin_bottom: ", modal_bottom_m)
	assert(modal_bottom_m >= 68, "Modal margin_bottom must respect safe area (>= 68)")
	modal_overlay.queue_free()
	print("✔ 9. Cyber modal safe area bottom margin verified")

	# 11. Test tab switching and bottom deadzone visibility
	main.show_tab("activities")
	await get_tree().process_frame
	assert(act_panel.visible == true, "ActivitiesPanel must be visible")
	if main.bottom_deadzone != null:
		assert(main.bottom_deadzone.visible == false, "bottom_deadzone must be hidden when on activities tab (panel background fills deadzone)")

	main.show_tab("timeline")
	await get_tree().process_frame
	var safe_area = main.get_node_or_null("SafeArea")
	assert(safe_area != null, "SafeArea must exist")
	assert(safe_area.offset_bottom <= 0.0, "SafeArea offset_bottom must lift up or be <= 0.0")
	if main.bottom_deadzone != null and main.current_safe_bottom_m > 0.0:
		assert(main.bottom_deadzone.visible == true, "bottom_deadzone must be visible on timeline when safe area is active")
	print("✔ 10. Tab switching and bottom deadzone coordination verified")

	print("=== ALL BOTTOM SAFE AREA & DEADZONE TESTS PASSED! ===")
	get_tree().quit()
