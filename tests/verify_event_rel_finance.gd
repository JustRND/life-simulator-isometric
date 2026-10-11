extends Node

const MainScreenScene = preload("res://scenes/main/main_screen.tscn")

func capture_screenshot(path: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		if img != null and not img.is_empty():
			img.save_png(path)
			print("Saved %s" % path)

func _ready() -> void:
	print("=== BEGIN VERIFICATION: EVENT POPUP, RELATIONSHIPS, FINANCE MARKET ===")
	
	# Force light mode first
	LifeLibrary.data.theme = "light"
	PlayerData.reset_player()
	PlayerData.age = 22
	PlayerData.money = 50000
	PlayerData.bank_savings = 10000
	PlayerData.partner = {
		"name": "Elena Rostova",
		"first_name": "Elena",
		"last_name": "Rostova",
		"age": 23,
		"relationship": 85,
		"gender": "Female",
		"occupation": "Graphic Designer",
		"status": "Girlfriend",
		"is_alive": true
	}
	
	var main_scene = MainScreenScene.instantiate()
	add_child(main_scene)
	if main_scene.disclaimer_screen != null:
		main_scene.disclaimer_screen.hide()
	if main_scene.loading_screen != null:
		main_scene.loading_screen.hide()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	# ----------------------------------------------------
	# 1. VERIFY EVENT POPUP MARGIN
	# ----------------------------------------------------
	print("\n--- 1. Testing Event Popup Margin ---")
	main_scene.current_event = {
		"id": "test_bully_event",
		"title": "THE SCHOOL BULLY",
		"description": "A notorious troublemaker knocks your textbooks onto the floor and mocks you."
	}
	main_scene.current_event_choices = [
		{"text": "Hand over your lunch money quietly"},
		{"text": "Punch the bully squarely in the jaw"},
		{"text": "Report the incident to the vice principal"},
		{"text": "Outsmart them with sharp verbal wit"}
	]
	main_scene.show_event_popup()
	await get_tree().process_frame
	await get_tree().process_frame
	
	var event_overlay: Control = main_scene.event_overlay
	assert(event_overlay.visible, "Event overlay must be visible")
	var desc: RichTextLabel = main_scene.event_description
	assert(desc.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART, "EventDescription must wrap by words")
	assert(desc.custom_minimum_size.x > 0.0, "EventDescription must retain a width request")
	assert(desc.size.x > 200.0, "EventDescription must receive readable horizontal space")
	
	await capture_screenshot("res://tests/verify_1_event_popup.png")
	
	event_overlay.visible = false
	
	# ----------------------------------------------------
	# 2. VERIFY RELATIONSHIPS PANEL AVATAR ALIGNMENT & MARGIN
	# ----------------------------------------------------
	print("\n--- 2. Testing Relationships Panel Avatar Alignment ---")
	main_scene.show_tab("relationships")
	await get_tree().process_frame
	await get_tree().process_frame
	
	var mom_margin: MarginContainer = main_scene.mother_card.get_node("Margin")
	var dad_margin: MarginContainer = main_scene.father_card.get_node("Margin")
	print("MotherCard Margin: left=%d, right=%d, top=%d, bottom=%d" % [
		mom_margin.get_theme_constant("margin_left"),
		mom_margin.get_theme_constant("margin_right"),
		mom_margin.get_theme_constant("margin_top"),
		mom_margin.get_theme_constant("margin_bottom")
	])
	assert(mom_margin.get_theme_constant("margin_left") == 48, "MotherCard margin_left must be 48")
	assert(dad_margin.get_theme_constant("margin_left") == 48, "FatherCard margin_left must be 48")
	
	var mom_icon: TextureRect = main_scene.mother_card.find_child("MotherIcon", true, false) as TextureRect
	assert(mom_icon != null, "MotherIcon must exist")
	assert(mom_icon.size_flags_vertical == Control.SIZE_SHRINK_BEGIN, "MotherIcon must be top-aligned with SIZE_SHRINK_BEGIN")
	
	var rel_list = main_scene.get_node("RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList")
	var single_card = rel_list.get_node_or_null("SinglePromptCard")
	assert(single_card != null, "SinglePromptCard must exist when single")
	
	await capture_screenshot("res://tests/verify_2_relationships.png")
	
	# Test with partner active
	PlayerData.partner = {
		"name": "Elena Rostova",
		"first_name": "Elena",
		"last_name": "Rostova",
		"age": 23,
		"relationship": 88,
		"gender": "Female",
		"occupation": "Graphic Designer",
		"status": "Girlfriend",
		"is_alive": true
	}
	main_scene.update_relationships_panel()
	await get_tree().process_frame
	await get_tree().process_frame
	
	var partner_card = rel_list.get_node_or_null("PartnerCard")
	assert(partner_card != null, "PartnerCard must exist when partner is active")
	var p_margin: MarginContainer = partner_card.get_node("Margin") as MarginContainer
	assert(p_margin != null and p_margin.get_theme_constant("margin_left") == 48, "PartnerCard margin_left must be 48")
	var p_icon: TextureRect = partner_card.find_child("HBox", true, false).get_child(0) as TextureRect
	assert(p_icon != null and p_icon.size_flags_vertical == Control.SIZE_SHRINK_BEGIN, "Partner icon must be SIZE_SHRINK_BEGIN")
	
	await capture_screenshot("res://tests/verify_2b_relationships_partner.png")
	
	# ----------------------------------------------------
	# 3. VERIFY FINANCE MARKET PANEL BUTTONS & CARDS
	# ----------------------------------------------------
	print("\n--- 3. Testing Finance Market Panel Buttons & Cards ---")
	var finance_panel = main_scene.get_node("FinancePanel")
	assert(finance_panel != null, "FinancePanel must exist")
	finance_panel.open()
	await get_tree().process_frame
	await get_tree().process_frame
	
	var f_overlay: Control = finance_panel.overlay
	assert(f_overlay != null and f_overlay.visible, "Finance market overlay must be visible")
	
	# Find market buttons in the finance panel
	var market_buttons := []
	for node in f_overlay.find_children("*", "Button", true, false):
		var btn := node as Button
		if btn.has_meta("market_button"):
			market_buttons.append(btn)
	
	print("Found %d market buttons in Finance Panel" % market_buttons.size())
	assert(market_buttons.size() >= 3, "Expected at least 3 market buttons (tabs, buy, sell, etc.)")
	
	# Check styling of first market button
	var test_btn: Button = market_buttons[0]
	var btn_normal: StyleBoxFlat = test_btn.get_theme_stylebox("normal") as StyleBoxFlat
	assert(btn_normal != null, "Market button must have StyleBoxFlat normal style")
	print("Market Button Style: border_w=%d, corner_r=%d, shadow_size=%d, shadow_offset=%s" % [
		btn_normal.border_width_left,
		btn_normal.corner_radius_top_left,
		btn_normal.shadow_size,
		str(btn_normal.shadow_offset)
	])
	assert(btn_normal.border_width_left >= 2, "Market button must have visible border >= 2px")
	assert(btn_normal.corner_radius_top_left >= 8, "Market button must have rounded corners >= 8px")
	assert(btn_normal.shadow_size >= 3, "Market button must have shadow backdrop >= 3px")
	
	await capture_screenshot("res://tests/verify_3_finance_market.png")
	
	# ----------------------------------------------------
	# 4. VERIFY CUSTOM SHARES TRADING MODAL (BUY & SELL)
	# ----------------------------------------------------
	print("\n--- 4. Testing Custom Shares Trading Modal ---")
	var sample_company := {
		"uid": "test_corp_1",
		"name": "Terra Medicine Works",
		"price": 37.35,
		"previous": 34.50,
		"available": 6400,
		"owner": "Maria Pereira"
	}
	
	# Test Buy Modal
	print("Testing Buy Shares Modal...")
	finance_panel._open_trade_modal(sample_company, true)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var trade_overlay: Control = finance_panel.trade_dialog_overlay
	assert(trade_overlay != null and trade_overlay.visible, "Trade dialog overlay must be visible")
	
	var line_edit: LineEdit = trade_overlay.find_child("ShareQuantityInput", true, false) as LineEdit
	assert(line_edit != null, "ShareQuantityInput LineEdit must exist in trade dialog")
	assert(line_edit.text == "10", "Initial quantity should default to 10")
	
	# Change quantity to 150
	line_edit.text = "150"
	line_edit.text_changed.emit("150")
	await get_tree().process_frame
	
	var calc_summary: Label = trade_overlay.find_child("CalcSummary", true, false) as Label
	var calc_total: Label = trade_overlay.find_child("CalcTotal", true, false) as Label
	print("Trade Modal Calc: summary='%s', total='%s'" % [calc_summary.text, calc_total.text])
	assert("150" in calc_summary.text, "Calc summary must show 150 shares")
	
	await capture_screenshot("res://tests/verify_4_buy_shares_modal.png")
	
	# Close buy modal
	trade_overlay.queue_free()
	await get_tree().process_frame
	
	# Test Sell Modal
	print("Testing Sell Shares Modal...")
	if not PlayerData.finance_market.has("holdings"):
		PlayerData.finance_market["holdings"] = {}
	PlayerData.finance_market["holdings"][sample_company.uid] = {
		"quantity": 100,
		"cost": 3000
	}
	finance_panel._open_trade_modal(sample_company, false)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var sell_trade_overlay: Control = finance_panel.trade_dialog_overlay
	assert(sell_trade_overlay != null and sell_trade_overlay.visible, "Sell trade dialog overlay must be visible")
	var sell_input: LineEdit = sell_trade_overlay.find_child("ShareQuantityInput", true, false) as LineEdit
	assert(sell_input != null, "Sell ShareQuantityInput must exist")
	
	await capture_screenshot("res://tests/verify_5_sell_shares_modal.png")
	
	sell_trade_overlay.queue_free()
	
	print("\n=== ALL VERIFICATIONS PASSED SUCCESSFULLY! ===")
	get_tree().quit(0)
