extends Node

func _ready() -> void:
	print("=== BEGIN BUSINESS CLOSURE AND FADE-IN / PULL-DOWN VERIFICATION ===")
	
	PlayerData.reset_player()
	PlayerData.first_name = "Alex"
	PlayerData.age = 28
	PlayerData.money = 50000
	
	var main_res := load("res://scenes/main/main_screen.tscn") as PackedScene
	assert(main_res != null, "main_screen.tscn must load")
	var main = main_res.instantiate()
	add_child(main)
	
	if main.disclaimer_screen != null:
		main.disclaimer_screen.hide()
	if main.loading_screen != null:
		main.loading_screen.hide()
		
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 1. Setup a failing business
	var fail_biz: Dictionary = {
		"uid": "biz_test_fail",
		"type_id": "biz_coffee_shop",
		"name": "Artisanal Coffee & Roastery",
		"icon": "☕",
		"founded_age": 25,
		"branches": 1,
		"facility_tier": 1,
		"revenue_scale": 1.0,
		"treasury": -150000,
		"employees": 2,
		"marketing_budget": 0,
		"consecutive_losses": 3,
		"loan_balance": 20000,
		"loan_interest_rate": 0.08,
		"valuation": 20000,
		"reputation": 30
	}
	PlayerData.owned_businesses = [fail_biz]
	
	# Verify that BusinessManager.simulate_yearly_businesses() flags it as flop
	var results := BusinessManager.simulate_yearly_businesses()
	assert(results.size() == 1, "Must return 1 result entry")
	var r: Dictionary = results[0]
	assert(r.get("is_closed", false) == true, "Business with depleted deficit must be closed")
	assert(str(r.get("close_reason", "")) != "", "Close reason must be provided")
	print("✔ CHECK 1: Business simulation correctly identifies deficit flop and returns close_reason: %s" % r.get("close_reason"))
	
	# 2. Test _process_yearly_business_operations in main_screen
	PlayerData.age = 28
	var test_biz: Dictionary = {
		"uid": "biz_test_fail_2",
		"type_id": "biz_coffee_shop",
		"name": "Artisanal Coffee & Roastery",
		"icon": "☕",
		"founded_age": 25,
		"branches": 1,
		"facility_tier": 1,
		"revenue_scale": 1.0,
		"treasury": -150000,
		"employees": 2,
		"marketing_budget": 0,
		"consecutive_losses": 3,
		"loan_balance": 20000,
		"loan_interest_rate": 0.08,
		"valuation": 20000,
		"reputation": 30
	}
	PlayerData.owned_businesses = [test_biz]
	main._process_yearly_business_operations()
	
	# Check timeline entry via life_feed parsed text and PlayerData.life_log
	var feed_text: String = main.life_feed.get_parsed_text() if main.life_feed != null else ""
	var log_texts: Array[String] = []
	for entry in PlayerData.life_log:
		log_texts.append(str(entry.get("text", "")))
	var all_logs: String = "\n".join(log_texts)
	print("Feed text sample:\n%s" % feed_text)
	print("Life log sample:\n%s" % all_logs)
	assert("BUSINESS DISSOLVED" in feed_text or "BUSINESS DISSOLVED" in all_logs, "Timeline feed or life log must display business closure event")
	print("✔ CHECK 2: Timeline event logged business closure reason.")
	
	# 3. Check Event Popup content & single button
	assert(main.event_overlay.visible == true, "Event overlay must be visible")
	assert(main.current_event != null, "current_event must be set")
	assert("BUSINESS DISSOLVED" in str(main.current_event.get("title", "")), "Event title must be BUSINESS DISSOLVED")
	
	assert(main.event_choice_1.visible == true, "Choice 1 button must be visible")
	assert(main.event_choice_2.visible == false, "Choice 2 button must be hidden")
	assert(main.event_choice_3.visible == false, "Choice 3 button must be hidden")
	assert(main.event_choice_4.visible == false, "Choice 4 button must be hidden")
	assert("Accept fate and move on" in main.event_choice_1.text, "Button text must contain 'Accept fate and move on'")
	print("✔ CHECK 3: Event panel has exactly ONE button: '%s'." % main.event_choice_1.text)
	
	# 4. Check Fade-In Animation (modulate.a starts at 0 and tweens to 1, panel resting centered)
	var event_panel: Control = main.event_overlay.get_node("EventPanel")
	assert(event_panel != null, "EventPanel must exist")
	# Check that EventPanel is centered and not shoved off bottom
	assert(event_panel.offset_top == -540.0, "EventPanel offset_top must be centered (-540)")
	assert(event_panel.offset_bottom == 540.0, "EventPanel offset_bottom must be centered (540)")
	
	# Wait for fade-in tween to complete
	await get_tree().create_timer(0.3).timeout
	assert(is_equal_approx(main.event_overlay.modulate.a, 1.0), "Event overlay must be fully visible (modulate.a = 1.0)")
	assert(main.event_choice_1.mouse_filter == Control.MOUSE_FILTER_STOP, "Choice 1 must have MOUSE_FILTER_STOP after fade-in completes")
	print("✔ CHECK 4: EventPanel faded in seamlessly at centered position without pull-up across age button.")
	
	# 5. Check Pull-Down Leaving Animation on Button Press
	var initial_offset_top: float = event_panel.offset_top
	# Trigger option choice
	main._on_event_choice_1_pressed()
	
	# During dismiss, panel_close animates offset_top downwards
	await get_tree().process_frame
	await get_tree().process_frame
	print("EventPanel during dismissal: offset_top=%f (initial=%f)" % [event_panel.offset_top, initial_offset_top])
	assert(event_panel.offset_top >= initial_offset_top, "EventPanel offset_top must move downwards during pull-down exit")
	
	# Wait for panel_close duration (CLOSE_SECONDS = 0.22s) + buffer
	await get_tree().create_timer(0.35).timeout
	assert(main.event_overlay.visible == false, "Event overlay must be hidden after pull-down dismiss")
	assert(main.age_button.disabled == false, "Age button must be re-enabled after pull-down dismiss finishes")
	print("✔ CHECK 5: Pull-down exit animation completed and Age button safely re-enabled.")
	
	print("=== ALL BUSINESS CLOSURE & FADE-IN / PULL-DOWN VERIFICATIONS PASSED ===")
	get_tree().quit(0)
