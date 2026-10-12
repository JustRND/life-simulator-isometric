extends Node

func _ready() -> void:
	LifeLibrary.profile_path = "user://stats_hud_test_profile.json"
	var main = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main)
	await get_tree().create_timer(3.5).timeout
	main.new_game_panel.hide()
	main.loading_screen.hide()
	main.disclaimer_screen.hide()
	main.show_tab("timeline")
	var column = main.get_node("SafeArea/MainColumn")
	var feed: Control = column.get_node("LifeFeedPanel")
	var stats: Control = column.get_node("StatsPanel")
	var nav: Control = column.get_node("ActionBar")
	for mode in ["dark", "light"]:
		LifeLibrary.data.theme = mode
		main.get_node("ThemeController").apply_theme()
		for window_size in [Vector2i(540, 960), Vector2i(540, 800)]:
			get_window().size = window_size
			await get_tree().create_timer(0.4).timeout
			assert(feed.get_global_rect().end.y + 15 <= stats.get_global_rect().position.y)
			assert(stats.get_global_rect().end.y + 15 <= nav.get_global_rect().position.y)
			for stat in ["Health", "Happiness", "Smarts", "Looks", "MentalState"]:
				var label: Label = stats.find_child(stat + "Label", true, false)
				assert(label != null)
				assert(label.size.y < 60)
			assert(stats.find_child("HungerLabel", true, false) == null)
			assert(stats.find_child("ThirstLabel", true, false) == null)
	if FileAccess.file_exists(LifeLibrary.profile_path):
		DirAccess.remove_absolute(LifeLibrary.profile_path)
	print("STATS_HUD_TEST_PASSED")
	get_tree().quit()
