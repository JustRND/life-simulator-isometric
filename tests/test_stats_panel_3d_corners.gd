extends Node

func _ready() -> void:
	print("=== BEGIN STATS PANEL 3D CORNERS & SHADOW VERIFICATION ===")
	
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
	
	var stats_panel: PanelContainer = main.get_node_or_null("SafeArea/MainColumn/StatsPanel")
	assert(stats_panel != null, "StatsPanel must exist in SafeArea/MainColumn")
	
	# Verify Dark Theme (default)
	var style: StyleBox = stats_panel.get_theme_stylebox("panel")
	assert(style is StyleBoxFlat, "StatsPanel style must be StyleBoxFlat")
	var flat: StyleBoxFlat = style as StyleBoxFlat
	
	print("Dark theme StatsPanel corners: tl=%d, tr=%d, br=%d, bl=%d" % [
		flat.corner_radius_top_left, flat.corner_radius_top_right,
		flat.corner_radius_bottom_right, flat.corner_radius_bottom_left
	])
	assert(flat.corner_radius_top_left >= 12 and flat.corner_radius_top_right >= 12 and
		flat.corner_radius_bottom_right >= 12 and flat.corner_radius_bottom_left >= 12,
		"StatsPanel must have rounded corners on all 4 corners (>= 12px)")
	
	print("Dark theme StatsPanel borders: l=%d, t=%d, r=%d, b=%d" % [
		flat.border_width_left, flat.border_width_top,
		flat.border_width_right, flat.border_width_bottom
	])
	assert(flat.border_width_left >= 2 and flat.border_width_top >= 2 and
		flat.border_width_right >= 2 and flat.border_width_bottom >= 2,
		"StatsPanel must have full perimeter border (>= 2px)")
		
	print("Dark theme StatsPanel shadow: size=%d, offset=%s, color=%s" % [
		flat.shadow_size, str(flat.shadow_offset), str(flat.shadow_color)
	])
	assert(flat.shadow_size >= 14, "StatsPanel must have shadow_size >= 14 for 3D illusion")
	assert(flat.shadow_offset.y >= 4, "StatsPanel must have downward shadow_offset (y >= 4)")
	assert(flat.shadow_color.a > 0.2, "StatsPanel shadow must be visible (alpha > 0.2)")
	print("✔ CHECK 1: Dark theme StatsPanel has rounded corners and 3D floating shadow.")
	
	# Verify ProgressBars
	var health_bar: ProgressBar = stats_panel.get_node("StatsMargin/StatsContainer/HealthBar")
	assert(health_bar != null, "HealthBar must exist")
	var track_style = health_bar.get_theme_stylebox("background")
	assert(track_style is StyleBoxFlat, "ProgressBar background must be StyleBoxFlat")
	var track_flat: StyleBoxFlat = track_style as StyleBoxFlat
	assert(track_flat.corner_radius_top_left >= 6, "Track must have rounded corners (>= 6px)")
	
	var fill_style = health_bar.get_theme_stylebox("fill")
	assert(fill_style is StyleBoxFlat, "ProgressBar fill must be StyleBoxFlat")
	var fill_flat: StyleBoxFlat = fill_style as StyleBoxFlat
	assert(fill_flat.corner_radius_top_left >= 6, "Fill must have rounded corners (>= 6px)")
	print("✔ CHECK 2: Progress bar tracks and fills have matching rounded corners.")
	
	# Verify Light Theme
	LifeLibrary.data.theme = "light"
	if main.has_node("ThemeController"):
		main.get_node("ThemeController").apply_theme()
	if main.has_method("_configure_stat_bars"):
		main._configure_stat_bars()
	await get_tree().process_frame
	await get_tree().process_frame
	
	var light_style: StyleBox = stats_panel.get_theme_stylebox("panel")
	assert(light_style is StyleBoxFlat, "Light theme StatsPanel style must be StyleBoxFlat")
	var light_flat: StyleBoxFlat = light_style as StyleBoxFlat
	assert(light_flat.corner_radius_top_left >= 12 and light_flat.corner_radius_bottom_right >= 12,
		"Light theme StatsPanel must retain rounded corners")
	assert(light_flat.border_width_left >= 2 and light_flat.border_width_bottom >= 2,
		"Light theme StatsPanel must retain full perimeter border")
	assert(light_flat.shadow_size >= 14 and light_flat.shadow_offset.y >= 4,
		"Light theme StatsPanel must retain 3D floating shadow")
	print("✔ CHECK 3: Light theme StatsPanel retains rounded corners and subtle 3D shadow.")
	
	print("=== STATS PANEL 3D CORNERS & SHADOW VERIFICATION PASSED SUCCESSFULLY ===")
	get_tree().quit(0)
