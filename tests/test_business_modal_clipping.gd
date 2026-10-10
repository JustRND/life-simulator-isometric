extends Node

func _ready() -> void:
	print("=== BEGIN TEST: BUSINESS MODAL CLIPPING & DEDICATED TREASURY AUDIT ===")
	get_window().size = Vector2i(450, 850)
	
	LifeLibrary.data.theme = "dark"
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.age = 35
	PlayerData.money = 250000
	PlayerData.bank_savings = 10526111
	
	var main_scene_res = load("res://scenes/main/main_screen.tscn")
	var main_scene = main_scene_res.instantiate()
	add_child(main_scene)
	
	if main_scene.disclaimer_screen != null:
		main_scene.disclaimer_screen.hide()
	if main_scene.loading_screen != null:
		main_scene.loading_screen.hide()
	if main_scene.new_game_panel != null:
		main_scene.new_game_panel.hide()
		
	await get_tree().process_frame
	await get_tree().process_frame
	
	PlayerData.owned_businesses = [
		{
			"uid": "biz_1",
			"id": "clean_energy_tech",
			"name": "Renewable Energy & Solar Grid Services",
			"icon": "⚡",
			"valuation": 820016,
			"treasury": 3169644,
			"annual_revenue": 720598,
			"annual_opex": 350000,
			"net_profit": 370598,
			"unpaid_taxes": 45000,
			"loan_balance": 150000,
			"branches": 1,
			"facility_tier": 1,
			"employees": 6
		},
		{
			"uid": "biz_2",
			"id": "clean_energy_tech",
			"name": "Hydroelectric Dam & Reservoir Power Station",
			"icon": "🌊",
			"valuation": 950000,
			"treasury": 1500000,
			"annual_revenue": 800000,
			"annual_opex": 400000,
			"net_profit": 400000,
			"unpaid_taxes": 0,
			"loan_balance": 0,
			"branches": 1,
			"facility_tier": 1,
			"employees": 8
		}
	]
	
	# ---------------------------------------------------------
	# 1. TASK 1: VERIFY REMOVAL OF FINANCIALS TAB (STRICTLY 2 TABS)
	# ---------------------------------------------------------
	print("\n--- AUDITING TOP TAB BAR (TASK 1) ---")
	main_scene._show_business_modal("enterprises")
	await get_tree().process_frame
	await get_tree().process_frame
	
	var overlay = main_scene.business_modal_overlay
	assert(overlay != null and overlay.visible, "Overlay must be visible")
	var initial_overlay_instance = overlay
	
	var card = null
	for c in overlay.get_children():
		if c is MarginContainer:
			card = c.get_child(0)
			break
	assert(card != null, "Card must exist")
	var cvbox = card.get_child(0).get_child(0)
	var tab_bar = cvbox.get_child(2)
	assert(tab_bar is HBoxContainer, "Child 2 must be tab bar")
	
	var tab_buttons: Array = []
	for child in tab_bar.get_children():
		if child is Button:
			tab_buttons.append(child.text)
	
	print("Discovered top tab buttons: ", tab_buttons)
	assert(tab_buttons.size() == 2, "Top tab bar must contain strictly 2 tabs! Got: %d" % tab_buttons.size())
	assert("Enterprises" in tab_buttons[0], "First tab must be Enterprises")
	assert("Incorporate" in tab_buttons[1], "Second tab must be Incorporate")
	for t_text in tab_buttons:
		assert(not "Financial" in t_text and not "Loans" in t_text, "Old Financials & Loans tab must be completely removed!")
	print("✅ TASK 1 PASSED: Strict 2-tab bar confirmed without global Financials tab.")
	
	# ---------------------------------------------------------
	# 2. TASK 2 & 3: DEDICATED TREASURY & FINANCIALS PANEL
	# ---------------------------------------------------------
	print("\n--- AUDITING DEDICATED TREASURY NAVIGATION (TASKS 2 & 3) ---")
	# Navigate to treasury for biz_1
	main_scene._show_business_modal("treasury", "biz_1")
	await get_tree().process_frame
	await get_tree().process_frame
	
	assert(main_scene.business_modal_overlay == initial_overlay_instance, "Overlay instance must be preserved (no recreation)!")
	
	# Verify header
	var nav_bar = cvbox.get_child(2)
	assert(nav_bar is HBoxContainer, "Child 2 in treasury mode must be nav_bar")
	var back_btn = nav_bar.get_child(0)
	assert(back_btn is Button and "Back to My Enterprises" in back_btn.text, "Must have Back to My Enterprises button")
	
	# Check dedicated treasury cards in the scroll view
	var scroll = cvbox.get_child(3)
	assert(scroll is ScrollContainer, "Child 3 must be scroll container")
	var t_list = scroll.get_child(0).get_child(0)
	
	var found_sep = false
	var found_balance = false
	var found_tax = false
	var found_loans = false
	var found_equity = false
	var found_expansion = false
	
	for i in range(t_list.get_child_count()):
		var tc = t_list.get_child(i)
		if tc is PanelContainer:
			var txt = ""
			for desc_child in tc.find_children("", "Label", true, false):
				txt += desc_child.text + " "
			if "STRICT CORPORATE ENTITY SEPARATION" in txt:
				found_sep = true
			if "CORPORATE BALANCE SHEET" in txt:
				found_balance = true
			if "TAX COMPLIANCE" in txt:
				found_tax = true
			if "COMMERCIAL LOANS" in txt:
				found_loans = true
			if "CAPITAL TRANSFERS" in txt:
				found_equity = true
			if "TREASURY REINVESTMENT & EXPANSION" in txt:
				found_expansion = true
	
	assert(found_sep, "Dedicated treasury must have Entity Separation banner")
	assert(found_balance, "Dedicated treasury must have Corporate Balance Sheet")
	assert(found_tax, "Dedicated treasury must have Tax Compliance section")
	assert(found_loans, "Dedicated treasury must have Commercial Loans facility")
	assert(found_equity, "Dedicated treasury must have Capital Transfers / Dividends")
	assert(found_expansion, "Dedicated treasury must have Expansion & Reinvestment")
	print("✅ TASK 2 & 3 PASSED: All 6 dedicated corporate treasury modules verified for Enterprise biz_1.")
	
	# Test biz_2 dedicated treasury
	main_scene._show_business_modal("treasury", "biz_2")
	await get_tree().process_frame
	await get_tree().process_frame
	assert(main_scene.business_modal_overlay == initial_overlay_instance, "Overlay instance must remain identical!")
	print("✅ Dedicated treasury for biz_2 opened seamlessly.")
	
	# ---------------------------------------------------------
	# 3. TASK 4: ZERO PULL-UP REPLAY & CONTENT REFRESH WHILE STILL
	# ---------------------------------------------------------
	print("\n--- AUDITING ZERO PULL-UP REPLAY & SCROLL PRESERVATION (TASK 4) ---")
	var prev_overlay_id = main_scene.business_modal_overlay.get_instance_id()
	
	# Perform an action with preserve_scroll (e.g. paying tax or transfer)
	main_scene._show_business_modal("treasury", "biz_1", true)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var new_overlay_id = main_scene.business_modal_overlay.get_instance_id()
	assert(prev_overlay_id == new_overlay_id, "Overlay was recreated! Pull-up animation must not replay!")
	
	# Test back button returns to enterprises without destroying overlay
	var cur_nav_bar = cvbox.get_child(2)
	var cur_back_btn = cur_nav_bar.get_child(0)
	cur_back_btn.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	assert(main_scene.business_modal_overlay.get_instance_id() == prev_overlay_id, "Back button must reuse overlay instance!")
	print("✅ TASK 4 PASSED: Pull-up animation does NOT replay; overlay is strictly reused and stays still.")
	
	# ---------------------------------------------------------
	# 4. TASK 5: ZERO CLIPPING ON VIEWPORTS
	# ---------------------------------------------------------
	print("\n--- AUDITING ZERO CLIPPING ON MOBILE (TASK 5) ---")
	var test_viewports = [Vector2i(450, 850), Vector2i(390, 844)]
	
	for vp_size in test_viewports:
		get_viewport().size = vp_size
		await get_tree().process_frame
		await get_tree().process_frame
		
		var vp_w: float = get_viewport().get_visible_rect().size.x
		print("\nViewport: ", vp_size, " (Visible width: ", vp_w, ")")
		
		for tab_name in ["enterprises", "incorporate", "treasury"]:
			main_scene._show_business_modal(tab_name, "biz_1")
			await get_tree().process_frame
			await get_tree().process_frame
			
			var cur_overlay = main_scene.business_modal_overlay
			assert(cur_overlay != null and cur_overlay.has_meta("modal_view"), "Modal view must exist")
			var card_elem: Control = cur_overlay.get_meta("modal_view").card
			assert(card_elem != null, "Card must exist")
			var min_w = card_elem.get_combined_minimum_size().x
			var actual_w = card_elem.size.x
			var left_x = card_elem.global_position.x
			var right_x = left_x + actual_w
			
			print("Tab [%s] min_w=%f, actual_w=%f, left_x=%f, right_x=%f" % [tab_name, min_w, actual_w, left_x, right_x])
			assert(min_w <= 350.0, "Card min width (%f) must be <= 350.0 for mobile compatibility!" % min_w)
			assert(min_w <= vp_w, "Card min width exceeds viewport width!")
			assert(left_x >= 0.0, "Card is clipping left!")
			assert(right_x <= vp_w + 1.0, "Card is clipping right!")
			print("  ✓ Zero clipping on tab [%s]" % tab_name)
	
	print("\n🎉 ALL 5 TASKS AUDITED AND VERIFIED SUCCESSFULLY WITH ZERO ERRORS!")
	get_tree().quit(0)
