extends Node

func _ready() -> void:
	print("--- TEST CREATION SCREEN DISPLAY ---")
	var main_res = load("res://scenes/main/main_screen.tscn") as PackedScene
	var main = main_res.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var card = main.get_node_or_null("NewGamePanel/CenterContainer/CreationCard") as Control
	var vp_size = main.get_viewport_rect().size
	var target_w: float = minf(880.0, vp_size.x - 32.0)
	var target_h: float = minf(1600.0, maxf(600.0, vp_size.y * 0.90))
	card.custom_minimum_size = Vector2(target_w, target_h)

	main.show_new_game_screen()
	await get_tree().process_frame
	await get_tree().process_frame

	print("Card size after setting height: ", card.size)
	print("Card custom_minimum_size: ", card.custom_minimum_size)
	var scroll = card.get_node_or_null("CreationScroll") as ScrollContainer
	if scroll:
		print("Scroll size: ", scroll.size)
		var content = scroll.get_node_or_null("NewGameContent") as Control
		if content:
			print("Content size: ", content.size)
			print("Content combined min size: ", content.get_combined_minimum_size())

	get_tree().quit(0)
