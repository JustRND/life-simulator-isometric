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

	# 3. Trigger _adjust_safe_area and verify FIVE CORE BUTTONS position
	main.current_safe_bottom_m = 84.0
	main.current_safe_top_m = 40.0
	main._adjust_safe_area()
	await get_tree().process_frame

	var safe_area = main.get_node_or_null("SafeArea")
	assert(safe_area != null, "SafeArea must exist")
	assert(safe_area.offset_bottom == 0.0, "SafeArea offset_bottom MUST be 0.0 to restore original five core buttons position")

	var action_bar = main.get_node_or_null("SafeArea/MainColumn/ActionBar")
	if action_bar != null:
		assert(action_bar.offset_bottom == 0.0, "ActionBar offset_bottom must be 0.0")

	var age_btn = main.get_node_or_null("SafeArea/MainColumn/ActionBar/AgeContainer/AgeButton")
	if age_btn != null:
		assert(age_btn.offset_bottom == 0.0, "AgeButton offset_bottom must be 0.0")

	assert(main.get_node_or_null("BottomSafeDeadzone") == null, "BottomSafeDeadzone must NOT exist; original home screen position restored")
	print("✔ 2. FIVE CORE BUTTONS original position verified (offset_bottom == 0.0, no deadzone)")

	# 4. Verify ONLY ActivitiesPanel gets the bottom clearance margin
	var act_panel = main.get_node_or_null("ActivitiesPanel")
	assert(act_panel != null, "ActivitiesPanel must exist")
	var act_margin = act_panel.get_node_or_null("ActMargin") as MarginContainer
	assert(act_margin != null, "ActMargin must exist")
	var mb = act_margin.get_theme_constant("margin_bottom")
	print("ActivitiesPanel ActMargin margin_bottom: ", mb)
	assert(mb >= 64, "ActMargin margin_bottom must be at least 64px")
	print("✔ 3. ActMargin bottom margin confirmed >= 64px")

	# 5. Verify ActListBottomSpacer exists in ActList
	var act_list = act_panel.get_node_or_null("ActMargin/ActContent/ActScroll/ActList")
	assert(act_list != null, "ActList must exist")
	var spacer = act_list.get_node_or_null("ActListBottomSpacer")
	assert(spacer != null, "ActListBottomSpacer must exist in ActList")
	assert(spacer.custom_minimum_size.y >= 30, "ActListBottomSpacer must have minimum height >= 30")
	print("✔ 4. ActListBottomSpacer confirmed at the bottom of ActList")

	# 6. Verify HouseholdActItem is placed before spacer
	var household_btn = act_list.get_node_or_null("HouseholdActItem") as Button
	assert(household_btn != null, "HouseholdActItem button must exist")
	var household_idx = household_btn.get_index()
	var spacer_idx = spacer.get_index()
	assert(household_idx < spacer_idx, "HouseholdActItem must be before bottom spacer")
	print("✔ 5. HouseholdActItem verified preceding bottom spacer")

	# 7. Verify other panels keep standard original margin (36px)
	var rel_panel = main.get_node_or_null("RelationshipsPanel")
	assert(rel_panel != null, "RelationshipsPanel must exist")
	var rel_margin = rel_panel.get_node_or_null("RelMargin") as MarginContainer
	assert(rel_margin != null, "RelMargin must exist")
	print("RelMargin theme constant margin_bottom: ", rel_margin.get_theme_constant("margin_bottom"))
	assert(rel_margin.get_theme_constant("margin_bottom") <= 36, "RelMargin margin_bottom must be original")

	var assets_panel = main.get_node_or_null("AssetsPanel")
	assert(assets_panel != null, "AssetsPanel must exist")
	var assets_margin = assets_panel.get_node_or_null("AssetsMargin") as MarginContainer
	assert(assets_margin != null, "AssetsMargin must exist")
	assert(assets_margin.get_theme_constant("margin_bottom") <= 36, "AssetsMargin margin_bottom must be original")

	var bank_panel = main.get_node_or_null("BankPanel")
	assert(bank_panel != null, "BankPanel must exist")
	var bank_margin = bank_panel.get_node_or_null("BankMargin") as MarginContainer
	assert(bank_margin != null, "BankMargin must exist")
	assert(bank_margin.get_theme_constant("margin_bottom") <= 36, "BankMargin margin_bottom must be original")

	var char_panel = main.get_node_or_null("CharacterPanel")
	assert(char_panel != null, "CharacterPanel must exist")
	var char_margin = char_panel.get_node_or_null("CharacterMargin") as MarginContainer
	assert(char_margin != null, "CharacterMargin must exist")
	assert(char_margin.get_theme_constant("margin_bottom") <= 36, "CharacterMargin margin_bottom must be original")

	var infant_panel = main.get_node_or_null("InfantPanel")
	assert(infant_panel != null, "InfantPanel must exist")
	var infant_margin = infant_panel.get_node_or_null("InfantMargin") as MarginContainer
	assert(infant_margin != null, "InfantMargin must exist")
	assert(infant_margin.get_theme_constant("margin_bottom") <= 36, "InfantMargin margin_bottom must be original")
	print("✔ 6. Other panels confirmed at original non-elevated margin (only ActivitiesPanel is elevated)")

	print("=== ALL BOTTOM SAFE AREA & DEADZONE TESTS PASSED! ===")
	get_tree().quit()
