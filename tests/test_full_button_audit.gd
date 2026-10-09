extends Node

func _ready():
	var main_scene = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("=== FULL BUTTON VERIFICATION AUDIT ===")
	
	# 1. Activities panel buttons
	print("\n--- 1. ACTIVITIES PANEL BUTTONS ---")
	main_scene.show_tab("activities")
	await get_tree().process_frame
	await get_tree().process_frame
	
	var act_list = main_scene.get_node("ActivitiesPanel/ActMargin/ActContent/ActScroll/ActList")
	var act_btn_count := 0
	var act_uniform_height := -1.0
	var all_act_uniform := true
	var all_act_centered := true
	var all_act_no_desc := true
	
	for child in act_list.get_children():
		if child is Button:
			act_btn_count += 1
			var ref_row = child.get_node_or_null("ReferenceRow")
			assert(ref_row != null, "Button %s must have ReferenceRow" % child.name)
			
			if ref_row.description != null and ref_row.description.visible and not ref_row.description.text.is_empty():
				all_act_no_desc = false
				print("FAIL: Activity button %s has description: '%s'" % [child.name, ref_row.description.text])
				
			if act_uniform_height < 0:
				act_uniform_height = child.size.y
			elif abs(child.size.y - act_uniform_height) > 1.0:
				all_act_uniform = false
				print("FAIL: Activity button %s height %f differs from expected %f" % [child.name, child.size.y, act_uniform_height])
				
			var btn_center = child.size.y / 2.0
			var heading_center = (ref_row.heading.global_position.y - child.global_position.y) + ref_row.heading.size.y / 2.0
			var diff = abs(heading_center - btn_center)
			if diff > 4.0:
				all_act_centered = false
				print("FAIL: Activity button %s heading not centered (diff: %f)" % [child.name, diff])
				
	print("Activities buttons checked: %d" % act_btn_count)
	print("All activity descriptions removed: ", all_act_no_desc)
	print("All activity button heights uniform (%f px): %s" % [act_uniform_height, str(all_act_uniform)])
	print("All activity buttons centered: ", all_act_centered)
	assert(all_act_no_desc, "Activities buttons must have descriptions removed")
	assert(all_act_uniform, "Activities buttons must be uniform in height")
	assert(all_act_centered, "Activities buttons must be centered")
	
	# 2. Event Choice buttons with multi-line text (the user's campout screenshot)
	print("\n--- 2. EVENT POPUP BUTTONS (NO CLIPPING) ---")
	var event_data = {
		"id": "test_campout",
		"title": "BACKYARD FAMILY CAMPOUT",
		"text": "Younger family relatives plead with wide smiles for an outdoor campout in your backyard with lanterns, sleeping bags, and treats.\n\nWhat do you do?",
		"choices": [
			{"text": "Pitch the tent, roast marshmallows, and tell folktales around the campfire"},
			{"text": "Build a gigantic indoor living room pillow fortress"},
			{"text": "Set up yard games and let them play badminton and tag"},
			{"text": "Take everyone to an outdoor retro drive-in movie"}
		]
	}
	main_scene.current_event = event_data
	main_scene.current_event_choices = event_data.choices
	main_scene.show_event_popup()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var choices_container = main_scene.get_node("EventOverlay/EventPanel/EventMargin/EventContent/EventChoices")
	var any_event_clipped := false
	for i in range(choices_container.get_child_count()):
		var btn = choices_container.get_child(i) as Button
		if not btn.visible:
			continue
		var ref_row = btn.get_node_or_null("ReferenceRow")
		assert(ref_row != null, "Event button must have ReferenceRow")
		var overflow = (ref_row.position.y + ref_row.size.y) - btn.size.y
		print("Event Choice %d: height=%f, row_height=%f, overflow=%f, lines=%d" % [
			i, btn.size.y, ref_row.size.y, overflow, ref_row.heading.get_line_count()
		])
		if overflow > 1.0:
			any_event_clipped = true
			print("FAIL: Event choice %d is clipped by %f px!" % [i, overflow])
			
	assert(not any_event_clipped, "Event choice buttons must NOT clip!")
	print("Event choices clipping check: PASSED (Zero clipping)")
	
	# 3. Settings panel buttons (descriptions restored)
	print("\n--- 3. SETTINGS PANEL BUTTONS (DESCRIPTIONS RESTORED) ---")
	main_scene.show_tab("settings")
	await get_tree().process_frame
	await get_tree().process_frame
	
	var overlay = main_scene.settings_overlay
	var has_any_desc := false
	if overlay:
		for c in overlay.find_children("*", "VBoxContainer", true, false):
			if c.has_meta("reference_menu"):
				for mc in c.get_children():
					if mc is Button:
						var ref_row = mc.get_node_or_null("ReferenceRow")
						if ref_row != null and ref_row.description != null and ref_row.description.visible and not ref_row.description.text.is_empty():
							has_any_desc = true
							print("Settings button '%s' has description: '%s'" % [ref_row.heading.text, ref_row.description.text])
	print("Settings buttons have descriptions restored: ", has_any_desc)
	assert(has_any_desc, "Settings buttons must have descriptions restored!")
		
	# 4. BankButton in AssetsContent (standout emerald preserved)
	print("\n--- 4. BANK BUTTON IN ASSETS PANEL ---")
	main_scene.show_tab("assets")
	await get_tree().process_frame
	await get_tree().process_frame
	
	var bank_btn = main_scene.get_node_or_null("AssetsPanel/AssetsMargin/AssetsContent/BankButton") as Button
	if bank_btn != null:
		assert(bank_btn.has_meta("bank_standout"), "BankButton in AssetsContent must have bank_standout meta")
		print("BankButton in AssetsContent correctly has standout styling")
		
	print("\n⭐⭐⭐ ALL AUDIT CHECKS PASSED PERFECTLY! ⭐⭐⭐")
	get_tree().quit(0)
