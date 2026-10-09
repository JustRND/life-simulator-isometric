extends Node

func _ready() -> void:
	print("=== BEGIN UNIFORM BUTTONS, AGE COUNTER & UI VERIFICATION TEST ===")
	
	var main_scene = load("res://scenes/main/main_screen.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	# -------------------------------------------------------------
	# 1. VERIFY AGE COUNTER POSITION & VALUE
	# -------------------------------------------------------------
	print("\n--- Testing Age Counter Position & Dynamics ---")
	var name_and_phase = main.get_node_or_null("ProfileStrip/ProfileMargin/ProfileRow/NameAndPhase")
	assert(name_and_phase != null, "NameAndPhase VBoxContainer must exist")
	assert(name_and_phase.get_child_count() >= 3, "NameAndPhase must have at least 3 children (Name, Age, Phase)")
	
	var c0 = name_and_phase.get_child(0)
	var c1 = name_and_phase.get_child(1)
	var c2 = name_and_phase.get_child(2)
	
	assert(c0.name == "NameLabel", "First child must be NameLabel")
	assert(c1.name == "AgeLabel", "Second child (RIGHT BETWEEN) must be AgeLabel")
	assert(c2.name == "PhaseLabel", "Third child must be PhaseLabel")
	
	assert(main.age_label != null, "main.age_label must be assigned")
	assert(main.age_label == c1, "main.age_label must reference the AgeLabel child")
	
	PlayerData.age = 0
	main.update_ui()
	assert(main.age_label.text == "Age: 0", "AgeLabel must display 'Age: 0' at age 0, got: %s" % main.age_label.text)
	
	PlayerData.age = 18
	main.update_ui()
	assert(main.age_label.text == "Age: 18", "AgeLabel must display 'Age: 18' at age 18, got: %s" % main.age_label.text)
	
	PlayerData.age = 42
	main.update_ui()
	assert(main.age_label.text == "Age: 42", "AgeLabel must display 'Age: 42' at age 42, got: %s" % main.age_label.text)
	print("✔ CHECK 1: Age Counter correctly placed right between Name and Age Phase and accurately updates.")
	
	# -------------------------------------------------------------
	# 2. VERIFY NO LITTLE DESCRIPTION TEXTS & UNIFORM BUTTONS IN ACTIVITIES
	# -------------------------------------------------------------
	print("\n--- Testing Button Uniformity in Activities Panel ---")
	main.show_tab("activities")
	await get_tree().process_frame
	
	var act_list = main.activities_panel.find_child("ActList", true, false)
	assert(act_list != null, "ActList must exist")
	
	var tested_act_buttons := 0
	var first_btn_height := -1.0
	for child in act_list.get_children():
		if child is Button:
			var r = child.get_node_or_null("ReferenceRow")
			assert(r != null, "Button '%s' in Activities must have ReferenceRow" % child.name)
			assert(r.description != null, "ReferenceRow must have description label reference")
			assert(r.description.text.is_empty() or not r.description.visible, 
				"Button '%s' must NOT display description text, but got: '%s'" % [child.name, r.description.text])
			assert(r.heading != null and not r.heading.text.is_empty(), 
				"Button '%s' must have heading title" % child.name)
			
			# Height check - should be compact and uniform (approx 74px, <= 90px)
			assert(child.custom_minimum_size.y <= 90.0, 
				"Button '%s' height (%f) must be compact and not ridiculously huge" % [child.name, child.custom_minimum_size.y])
			assert(child.custom_minimum_size.y >= 70.0,
				"Button '%s' height (%f) must be at least 70px" % [child.name, child.custom_minimum_size.y])
			
			if first_btn_height < 0:
				first_btn_height = child.custom_minimum_size.y
			else:
				assert(abs(child.custom_minimum_size.y - first_btn_height) <= 8.0,
					"Button '%s' height (%f) must be uniform with others (%f)" % [child.name, child.custom_minimum_size.y, first_btn_height])
			
			# Check that BankActItem in Activities is NOT bank_standout
			if child.name == "BankActItem":
				assert(not child.has_meta("bank_standout"), 
					"BankActItem inside Activities MUST REMAIN UNIFORM and NOT have bank_standout meta")
			
			tested_act_buttons += 1
			
	assert(tested_act_buttons >= 12, "Must have verified at least 12 activity buttons (tested %d)" % tested_act_buttons)
	print("✔ CHECK 2: All %d Activity buttons have description texts removed and are uniform in height." % tested_act_buttons)
	
	# -------------------------------------------------------------
	# 3. VERIFY BANK BUTTON IN ASSETS PANEL (STANDOUT COLORIZATION)
	# -------------------------------------------------------------
	print("\n--- Testing Bank Button Standout Colorization in Assets Panel ---")
	main.show_tab("assets")
	await get_tree().process_frame
	
	var bank_btn: Button = main.bank_button
	assert(bank_btn != null, "BankButton must exist in AssetsPanel")
	assert(bank_btn.has_meta("bank_standout"), "BankButton in AssetsPanel MUST have bank_standout meta")
	assert(bank_btn.custom_minimum_size.y <= 90.0, 
		"BankButton height (%f) must be compact, not the old 150px" % bank_btn.custom_minimum_size.y)
	
	var bank_row = bank_btn.get_node_or_null("ReferenceRow")
	assert(bank_row != null, "BankButton must have ReferenceRow")
	assert(bank_row.heading != null and bank_row.heading.text == "BANKING", 
		"BankButton heading must be 'BANKING'")
	assert(bank_row.description.text.is_empty() or not bank_row.description.visible,
		"BankButton must NOT display description text")
	
	var normal_sb = bank_btn.get_theme_stylebox("normal")
	assert(normal_sb is StyleBoxFlat, "BankButton normal stylebox must be StyleBoxFlat")
	var flat: StyleBoxFlat = normal_sb as StyleBoxFlat
	print("BankButton dark stylebox bg_color: %s, border_color: %s" % [flat.bg_color, flat.border_color])
	# Verify distinct emerald / standout styling (border color has green/teal component)
	assert(flat.border_color.g > 0.5, "BankButton border color must have emerald/teal accent in dark theme")
	print("✔ CHECK 3: BankButton inside AssetsPanel stands out with emerald colorization and uniform height.")
	
	# -------------------------------------------------------------
	# 4. VERIFY LIGHT THEME COMPATIBILITY & CONTRAST
	# -------------------------------------------------------------
	print("\n--- Testing Light Theme Compatibility & Contrast ---")
	LifeLibrary.data.theme = "light"
	if main.has_node("ThemeController"):
		main.get_node("ThemeController").apply_theme()
	await get_tree().process_frame
	
	# Recheck BankButton in light mode
	var lt_normal = bank_btn.get_theme_stylebox("normal") as StyleBoxFlat
	assert(lt_normal != null, "BankButton must have normal stylebox in light mode")
	print("BankButton light stylebox bg_color: %s, border_color: %s" % [lt_normal.bg_color, lt_normal.border_color])
	assert(lt_normal.border_color.g > 0.35, "BankButton in light mode must maintain emerald border accent")
	
	# Recheck age label in light mode
	var age_col = main.age_label.get_theme_color("font_color")
	print("AgeLabel light mode font_color: %s, luminance: %f" % [age_col, age_col.get_luminance()])
	assert(age_col.get_luminance() <= 0.55, "AgeLabel in light mode must be dark enough for high contrast")
	
	# Restore dark theme
	LifeLibrary.data.theme = "dark"
	if main.has_node("ThemeController"):
		main.get_node("ThemeController").apply_theme()
	await get_tree().process_frame
	print("✔ CHECK 4: Light theme styling and contrast verified.")
	
	# -------------------------------------------------------------
	# 5. VERIFY NO CLIPPING ON MOBILE VIEWPORTS
	# -------------------------------------------------------------
	print("\n--- Testing Mobile Viewport Layout & Absence of Clipping ---")
	var mobile_viewports = [Vector2i(1080, 1920), Vector2i(1080, 2340), Vector2i(1080, 2400)]
	for vp in mobile_viewports:
		get_window().size = vp
		await get_tree().process_frame
		
		# Profile strip within window bounds
		assert(main.profile_strip.position.y >= 0, "ProfileStrip y must be >= 0")
		assert(main.name_label.size.x > 0, "NameLabel must have valid positive size")
		assert(main.age_label.size.x > 0, "AgeLabel must have valid positive size")
		assert(main.phase_label.size.x > 0, "PhaseLabel must have valid positive size")
		
		for i in range(name_and_phase.get_child_count()):
			var ch = name_and_phase.get_child(i)
			print("Child %s min_size: %s, size: %s, font_size: %s" % [ch.name, ch.get_combined_minimum_size(), ch.size, ch.get_theme_font_size("font_size")])
		var combined_h = name_and_phase.get_combined_minimum_size().y
		print("Combined height: %f, ProfileStrip size: %s" % [combined_h, main.profile_strip.size])
		assert(combined_h <= 180.0, "NameAndPhase combined height (%f) valid" % combined_h)
	print("✔ CHECK 5: Verified no clipping across multiple mobile viewports.")
	
	print("\n⭐⭐⭐ ALL UNIFORM BUTTONS, AGE COUNTER & UI CHECKS PASSED! ⭐⭐⭐\n")
	get_tree().quit(0)
