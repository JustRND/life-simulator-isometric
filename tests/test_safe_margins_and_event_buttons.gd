extends Node

var total_assertions: int = 0
var passed_assertions: int = 0

func assert_check(condition: bool, msg: String) -> void:
	total_assertions += 1
	if not condition:
		push_error("❌ ASSERTION FAILED: " + msg)
		print("  ❌ FAILED: " + msg)
		get_tree().quit(1)
		assert(false, msg)
	else:
		passed_assertions += 1
		print("  ✓ " + msg)

func _ready() -> void:
	print("=======================================================")
	print("🧪 TESTING SAFE MARGINS & EVENT BUTTON ANTI-CLIPPING")
	print("=======================================================")

	var main_scene_res = load("res://scenes/main/main_screen.tscn")
	assert_check(main_scene_res != null, "main_screen.tscn loaded successfully")

	var main_scene = main_scene_res.instantiate()
	add_child(main_scene)
	await get_tree().process_frame
	await get_tree().process_frame

	# 1. Test Initial Safe Margins on All Full Screen Panels
	var panels_to_test: Dictionary = {
		"AssetsMargin": main_scene.find_child("AssetsMargin", true, false),
		"BankMargin": main_scene.find_child("BankMargin", true, false),
		"ActMargin": main_scene.find_child("ActMargin", true, false),
		"RelMargin": main_scene.find_child("RelMargin", true, false),
		"CharacterMargin": main_scene.find_child("CharacterMargin", true, false),
		"InfantMargin": main_scene.find_child("InfantMargin", true, false),
		"SettingsMargin": main_scene.find_child("SettingsMargin", true, false)
	}

	for m_name in panels_to_test:
		var m_node: MarginContainer = panels_to_test[m_name]
		assert_check(m_node != null, "%s exists in tree" % m_name)
		var ml: int = m_node.get_theme_constant("margin_left")
		var mr: int = m_node.get_theme_constant("margin_right")
		var mt: int = m_node.get_theme_constant("margin_top")
		var mb: int = m_node.get_theme_constant("margin_bottom")
		assert_check(ml >= 36, "%s margin_left is >= 36 (actual: %d)" % [m_name, ml])
		assert_check(mr >= 36, "%s margin_right is >= 36 (actual: %d)" % [m_name, mr])
		assert_check(mt >= 64, "%s margin_top is >= 64 (actual: %d)" % [m_name, mt])
		assert_check(mb <= 36 and mb >= 20, "%s margin_bottom is compact and safe <= 36 (actual: %d)" % [m_name, mb])

	# 2. Test Safe Margins After show_tab("assets") and ThemeController execution
	main_scene.show_tab("assets")
	await get_tree().process_frame
	var assets_m: MarginContainer = panels_to_test["AssetsMargin"]
	assert_check(assets_m.get_theme_constant("margin_left") >= 36, "AssetsMargin keeps margin_left >= 36 after show_tab")
	assert_check(assets_m.get_theme_constant("margin_right") >= 36, "AssetsMargin keeps margin_right >= 36 after show_tab")
	assert_check(assets_m.get_theme_constant("margin_top") >= 64, "AssetsMargin keeps margin_top >= 64 after show_tab")
	assert_check(assets_m.get_theme_constant("margin_bottom") <= 36 and assets_m.get_theme_constant("margin_bottom") >= 20, "AssetsMargin keeps compact margin_bottom <= 36 after show_tab")

	# 3. Test Safe Margins and Header Styling (X button size & visible title) After show_tab
	var header_checks: Dictionary = {
		"activities": {
			"header": "ActivitiesPanel/ActMargin/ActContent/ActHeaderRow",
			"title": "ActTitle",
			"close": "CloseActButton",
			"expected_title": "Activities"
		},
		"relationships": {
			"header": "RelationshipsPanel/RelMargin/RelContent/RelHeaderRow",
			"title": "RelTitle",
			"close": "CloseRelButton",
			"expected_title": "Relationships"
		},
		"assets": {
			"header": "AssetsPanel/AssetsMargin/AssetsContent/AssetsHeaderRow",
			"title": "AssetsTitle",
			"close": "CloseAssetsButton",
			"expected_title": "Assets & Finances"
		},
		"character": {
			"header": "CharacterPanel/CharacterMargin/CharacterContent/CharacterHeaderRow",
			"title": "CharacterTitle",
			"close": "CloseCharacterButton",
			"expected_title": "Character Profile"
		}
	}

	for tab in ["bank", "activities", "relationships", "character", "assets"]:
		main_scene.show_tab(tab)
		await get_tree().process_frame
		await get_tree().process_frame
		if header_checks.has(tab):
			var info: Dictionary = header_checks[tab]
			var h_node: Node = main_scene.get_node_or_null(info["header"])
			assert_check(h_node != null, "%s header exists" % tab)
			if h_node != null:
				var title_node: Label = h_node.get_node_or_null(info["title"])
				var close_node: Button = h_node.get_node_or_null(info["close"])
				assert_check(close_node != null, "%s close button exists" % tab)
				if close_node != null:
					assert_check(close_node.custom_minimum_size == Vector2(56, 56), "%s close button minimum size is (56, 56)" % tab)
					assert_check(close_node.size_flags_horizontal == Control.SIZE_SHRINK_BEGIN, "%s close button does not expand horizontally" % tab)
				assert_check(title_node != null, "%s title label exists" % tab)
				if title_node != null:
					assert_check(title_node.visible, "%s title label is visible" % tab)
					assert_check(title_node.text == info["expected_title"], "%s title text is '%s' (actual: '%s')" % [tab, info["expected_title"], title_node.text])
					assert_check(title_node.size_flags_vertical == Control.SIZE_EXPAND_FILL, "%s title label expands vertically to fill header bar" % tab)
					assert_check(title_node.size_flags_horizontal == Control.SIZE_EXPAND_FILL, "%s title label expands horizontally" % tab)

	# 4. Test Event Button Dynamic Sizing & Text Anti-Clipping
	var test_event: Dictionary = {
		"id": "test_science_fair",
		"title": "SCIENCE FAIR",
		"description": "It's the annual school science fair! You've had three weeks to prepare. What do you do?",
		"choices": [
			{"text": "Run away", "effects": {}},
			{"text": "Bring a working papier-mâché volcano", "effects": {}},
			{"text": "Forgot about it; fake sick to avoid judging", "effects": {}},
			{"text": "Volunteer to organize the entire science fair committee and manage all judging schedules", "effects": {}}
		]
	}

	main_scene.current_event = test_event
	main_scene.current_event_choices = test_event["choices"]
	main_scene.show_event_popup()
	await get_tree().process_frame
	await get_tree().process_frame

	var choice1: Button = main_scene.find_child("EventChoice1", true, false)
	var choice2: Button = main_scene.find_child("EventChoice2", true, false)
	var choice3: Button = main_scene.find_child("EventChoice3", true, false)
	var choice4: Button = main_scene.find_child("EventChoice4", true, false)

	assert_check(choice1 != null and choice1.visible, "EventChoice1 is visible")
	assert_check(choice2 != null and choice2.visible, "EventChoice2 is visible")
	assert_check(choice3 != null and choice3.visible, "EventChoice3 is visible")
	assert_check(choice4 != null and choice4.visible, "EventChoice4 is visible")

	var ref1: MarginContainer = choice1.get_node_or_null("ReferenceRow")
	if ref1 != null:
		print("  choice1 text: '", choice1.text, "'")
		print("  ref1 heading text: '", ref1.heading.text, "'")
		print("  ref1 heading line_count: ", ref1.heading.get_line_count())
		print("  choice1 size: ", choice1.size)

	assert_check(choice1.custom_minimum_size.y == 96.0, "Choice 1 (single line) minimum height is 96.0px")
	assert_check(choice2.custom_minimum_size.y >= 132.0, "Choice 2 (volcano - 2 lines) minimum height expanded to >= 132.0px")
	assert_check(choice3.custom_minimum_size.y >= 132.0, "Choice 3 (fake sick - 2 lines) minimum height expanded to >= 132.0px")
	assert_check(choice4.custom_minimum_size.y >= 172.0, "Choice 4 (long - 3 lines) minimum height expanded to >= 172.0px")

	var ref2: MarginContainer = choice2.get_node_or_null("ReferenceRow")
	assert_check(ref2 != null, "Choice 2 has ReferenceRow presenter")
	if ref2 != null:
		var heading: Label = ref2.get("heading")
		assert_check(heading != null, "ReferenceRow has heading Label")
		if heading != null:
			var fs: int = heading.get_theme_font_size("font_size")
			assert_check(fs == 22, "Heading font_size is set to 22px (actual: %d)" % fs)
		var mt: int = ref2.get_theme_constant("margin_top")
		var mb: int = ref2.get_theme_constant("margin_bottom")
		assert_check(mt <= 8 and mb <= 8, "ReferenceRow vertical padding is compact (mt=%d, mb=%d)" % [mt, mb])

	print("=======================================================")
	print("✅ ALL TESTS PASSED: %d/%d assertions" % [passed_assertions, total_assertions])
	print("=======================================================")
	get_tree().quit(0)
