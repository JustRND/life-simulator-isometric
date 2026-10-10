extends Node

func _ready() -> void:
	print("=== BEGIN ALPHA VERSION BADGE VERIFICATION ===")
	
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
	
	# 1. Verify existence of Alpha Version Badge
	var top_bar: PanelContainer = main.get_node_or_null("TopBar")
	assert(top_bar != null, "TopBar must exist")
	
	var badge_margin: MarginContainer = top_bar.get_node_or_null("Row/AlphaVersionMargin")
	assert(badge_margin != null, "1. AlphaVersionMargin must exist in TopBar/Row")
	
	var badge: PanelContainer = badge_margin.get_node_or_null("AlphaBadge")
	assert(badge != null, "1. AlphaBadge must exist")
	
	var label: Label = badge.get_node_or_null("AlphaBadgeMargin/AlphaVersionLabel")
	assert(label != null, "1. AlphaVersionLabel must exist")
	
	print("Found version label text: '%s'" % label.text)
	assert(label.text.begins_with("ALPHA "), "1. Label text must begin with 'ALPHA '")
	assert("0.1.2" in label.text, "1. Label text must include version number (0.1.2)")
	print("✔ CHECK 1: Alpha version label verified with text '%s'" % label.text)
	
	# 2. Verify badge is located on the top right section
	await get_tree().process_frame
	var brand: Label = top_bar.get_node_or_null("Row/Brand")
	assert(brand != null, "Brand label must exist")
	print("Brand global position x: %f, Badge global position x: %f" % [brand.global_position.x, badge.global_position.x])
	assert(badge.global_position.x > brand.global_position.x, "2. Badge must be located to the right of Brand")
	assert(badge.global_position.x > 500.0, "2. Badge must be in the right section of the screen")
	print("✔ CHECK 2: Badge is correctly positioned in the top-right section of the screen.")
	
	# 3. Verify styling: rounded corners and shadow
	var badge_style = badge.get_theme_stylebox("panel")
	assert(badge_style is StyleBoxFlat, "3. Badge stylebox must be StyleBoxFlat")
	var flat: StyleBoxFlat = badge_style as StyleBoxFlat
	assert(flat.corner_radius_top_left == 8 and flat.corner_radius_bottom_right == 8,
		"3. Badge must have rounded corners (8px)")
	assert(flat.border_width_left >= 1 and flat.border_width_top >= 1,
		"3. Badge must have borders")
	assert(flat.shadow_size >= 2, "3. Badge must have subtle shadow")
	print("✔ CHECK 3: Badge styling verified with rounded corners and subtle shadow.")
	
	# 4. Verify Light theme adaptability
	LifeLibrary.data.theme = "light"
	if main.has_node("ThemeController"):
		main.get_node("ThemeController").apply_theme()
	if main.has_method("_configure_ui"):
		main._configure_ui()
	await get_tree().process_frame
	await get_tree().process_frame
	
	var light_style = badge.get_theme_stylebox("panel")
	assert(light_style is StyleBoxFlat, "4. Light theme badge stylebox must be StyleBoxFlat")
	assert(label.text.begins_with("ALPHA "), "4. Text persists in light mode")
	print("✔ CHECK 4: Light theme adaptability verified.")
	
	print("=== ALPHA VERSION BADGE VERIFICATION PASSED SUCCESSFULLY ===")
	get_tree().quit(0)
