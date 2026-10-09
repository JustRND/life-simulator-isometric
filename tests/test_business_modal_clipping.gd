extends Node

func _ready() -> void:
	print("=== BEGIN TEST: BUSINESS MODAL CLIPPING AUDIT ===")
	get_window().size = Vector2i(450, 850)
	
	LifeLibrary.data.theme = "dark"
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.age = 35
	PlayerData.money = 0
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
			"unpaid_taxes": 0,
			"loan_balance": 0,
			"branches": 1,
			"facility_tier": 1,
			"employees": 6
		},
		{
			"uid": "biz_2",
			"id": "clean_energy_tech",
			"name": "Hydroelectric Dam & Reservoir Power Station",
			"icon": "⚡",
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
		},
		{
			"uid": "biz_3",
			"id": "clean_energy_tech",
			"name": "Hydroelectric Dam & Reservoir Power Station - Branch 2",
			"icon": "⚡",
			"valuation": 950000,
			"treasury": 1200000,
			"annual_revenue": 750000,
			"annual_opex": 380000,
			"net_profit": 370000,
			"unpaid_taxes": 0,
			"loan_balance": 0,
			"branches": 1,
			"facility_tier": 1,
			"employees": 8
		}
	]
	
	var test_viewports = [Vector2i(450, 850), Vector2i(390, 844)]
	
	for vp_size in test_viewports:
		get_viewport().size = vp_size
		await get_tree().process_frame
		await get_tree().process_frame
		
		var vp_w: float = get_viewport().get_visible_rect().size.x
		print("\n==========================================")
		print("TESTING VIEWPORT SIZE: ", vp_size, " (Visible rect width: ", vp_w, ")")
		print("==========================================")
		
		for tab_name in ["financials", "enterprises", "incorporate"]:
			print("\n--- TESTING TAB: ", tab_name, " ---")
			main_scene._show_business_modal(tab_name, "biz_1")
			await get_tree().process_frame
			await get_tree().process_frame
			
			var overlay = main_scene.business_modal_overlay
			assert(overlay != null and overlay.visible, "Overlay must be visible")
			
			var card = null
			for c in overlay.get_children():
				if c is MarginContainer:
					card = c.get_child(0)
					break
			if card == null:
				card = overlay.find_child("PanelContainer", true, false)
				
			assert(card != null, "Card must exist")
			print("Tab [", tab_name, "] Card size: ", card.size, " min_size: ", card.get_combined_minimum_size(), " global_pos: ", card.global_position)
			
			var min_w = card.get_combined_minimum_size().x
			var actual_w = card.size.x
			var left_x = card.global_position.x
			var right_x = left_x + actual_w
			
			if tab_name == "enterprises":
				print("--- AUDITING ENTERPRISES TAB ELEMENTS ---")
				var minner = card.get_child(0)
				var cvbox = minner.get_child(0)
				for i in range(cvbox.get_child_count()):
					var c = cvbox.get_child(i)
					if c is Control:
						print("VBOX child [%d] %s '%s' min_w=%f" % [i, c.get_class(), c.name, c.get_combined_minimum_size().x])
						if c is ScrollContainer:
							var sm = c.get_child(0)
							var sl = sm.get_child(0)
							for j in range(sl.get_child_count()):
								var sc = sl.get_child(j)
								if sc is Control:
									var t = ""
									if sc is Button or sc is Label:
										t = " text='%s'" % sc.text.substr(0, 30).replace("\n", " ")
									print("  Scroll child [%d] %s '%s'%s min_w=%f" % [j, sc.get_class(), sc.name, t, sc.get_combined_minimum_size().x])
									if sc is PanelContainer:
										var pc_m = sc.get_child(0)
										var pc_v = pc_m.get_child(0)
										for k in range(pc_v.get_child_count()):
											var pce = pc_v.get_child(k)
											if pce is Control:
												var pt = ""
												if pce is Button or pce is Label:
													pt = " text='%s'" % pce.text.substr(0, 30).replace("\n", " ")
												print("    Card item [%d] %s '%s'%s min_w=%f" % [k, pce.get_class(), pce.name, pt, pce.get_combined_minimum_size().x])
												if pce is HBoxContainer:
													for h in pce.get_children():
														if h is Control:
															var ht = ""
															if h is Button or h is Label:
																ht = " text='%s'" % h.text.substr(0, 30).replace("\n", " ")
															print("      HBox item %s '%s'%s min_w=%f" % [h.get_class(), h.name, ht, h.get_combined_minimum_size().x])
			
			# Assertions
			assert(min_w <= vp_w, "Card minimum width %f exceeds viewport width %f!" % [min_w, vp_w])
			assert(left_x >= 0.0, "Card is clipping left! left_x = %f" % left_x)
			assert(right_x <= vp_w + 1.0, "Card is clipping right! right_x = %f, vp_w = %f" % [right_x, vp_w])
			print("✅ TAB [", tab_name, "] PASSED - ZERO CLIPPING ON VIEWPORT ", vp_w)
	
	print("\n🎉 ALL BUSINESS MODAL CLIPPING TESTS PASSED SUCCESSFULLY!")
	get_tree().quit(0)
