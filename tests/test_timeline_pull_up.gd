extends Node

func _ready() -> void:
	print("=== BEGIN TIMELINE PULL-UP PANEL VERIFICATION ===")
	
	PlayerData.reset_player()
	PlayerData.first_name = "Jordan"
	PlayerData.age = 0
	
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
	
	# 1. Verify TimelinePullUpButton existence and position
	var pull_btn: Button = main.get_node_or_null("SafeArea/MainColumn/TimelinePullUpButton")
	assert(pull_btn != null, "1. TimelinePullUpButton must exist in SafeArea/MainColumn")
	assert(pull_btn.icon != null, "1. TimelinePullUpButton must have double chevron icon")
	assert("timeline_pullup_icon" in pull_btn.icon.resource_path, "1. Button must start with pull-up icon")
	
	var stats_panel: Control = main.get_node("SafeArea/MainColumn/StatsPanel")
	await get_tree().process_frame
	print("pull_btn offset_bottom: %f, stats_panel offset_top: %f" % [pull_btn.offset_bottom, stats_panel.offset_top])
	assert(abs(pull_btn.offset_bottom - stats_panel.offset_top) <= 4.0, "1. Button bottom edge must be right above or flush with StatsPanel top")
	print("✔ CHECK 1: TimelinePullUpButton verified right above StatsPanel with pull-up chevron icon.")

	
	# 2. Verify initial closed state
	var drawer: Control = main.get_node_or_null("SafeArea/MainColumn/TimelinePanel")
	assert(drawer != null, "2. TimelinePanel must exist in SafeArea/MainColumn")
	assert(drawer.visible == false, "2. TimelinePanel must be closed by default")
	assert(main._is_timeline_open == false, "2. _is_timeline_open must be false initially")
	print("✔ CHECK 2: TimelinePanel is closed by default.")
	
	# 3. Verify translucent background style
	var style: StyleBox = drawer.get_theme_stylebox("panel")
	assert(style is StyleBoxFlat, "3. Translucent stylebox must be a StyleBoxFlat")
	var flat: StyleBoxFlat = style as StyleBoxFlat
	assert(flat.bg_color.a > 0.5 and flat.bg_color.a < 0.95, "3. Background must be translucent so room is visible underneath (alpha = %.2f)" % flat.bg_color.a)
	print("✔ CHECK 3: Translucent background verified (alpha = %.2f, room visible underneath)." % flat.bg_color.a)
	
	# 4. Verify pulling up the panel
	pull_btn.emit_signal("pressed")
	await get_tree().process_frame
	assert(main._is_timeline_open == true, "4. _is_timeline_open must be true after clicking pull-up button")
	assert(drawer.visible == true, "4. TimelinePanel must become visible")
	assert("timeline_pulldown_icon" in pull_btn.icon.resource_path, "4. Button icon must flip to pulldown chevron")
	print("✔ CHECK 4: Clicking button smoothly pulls up TimelinePanel with down chevron icon.")
	
	# 5. Verify LifeFeed contents and scrolling
	assert(main.life_feed != null, "5. life_feed reference must be valid")
	assert(main.life_feed.is_inside_tree(), "5. life_feed must be inside tree")
	assert(main.life_feed.text.length() > 0, "5. life_feed must contain initial life log")
	print("✔ CHECK 5: LifeFeed is active inside TimelinePanel with text: %s" % main.life_feed.text.substr(0, 40).strip_edges())
	
	# 6. Verify closing via Close button
	var close_btn: Button = drawer.get_node("TimelineContent/TimelineHeaderRow/CloseTimelineButton")
	assert(close_btn != null, "6. CloseTimelineButton must exist")
	close_btn.emit_signal("pressed")
	await get_tree().process_frame
	assert(main._is_timeline_open == false, "6. _is_timeline_open must be false after close button clicked")
	assert("timeline_pullup_icon" in pull_btn.icon.resource_path, "6. Button icon must revert to pullup chevron")
	print("✔ CHECK 6: CloseTimelineButton cleanly closes the drawer and reverts icon.")
	
	# 7. Verify tab switching hides and restores pull-up button
	main.show_tab("activities")
	await get_tree().process_frame
	assert(pull_btn.visible == false, "7. Pull up button must be hidden on activities tab")
	main.show_tab("timeline")
	await get_tree().process_frame
	assert(pull_btn.visible == true, "7. Pull up button must be visible when returning to home timeline")
	print("✔ CHECK 7: Tab navigation correctly hides and restores pull up button.")
	
	print("=== TIMELINE PULL-UP PANEL VERIFICATION PASSED SUCCESSFULLY ===")
	get_tree().quit()
