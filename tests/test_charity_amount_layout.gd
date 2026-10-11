extends Node

const MainScreenScene = preload("res://scenes/main/main_screen.tscn")

func _ready() -> void:
	PlayerData.has_started_game = true
	PlayerData.age = 35
	PlayerData.money = 250000
	PlayerData.bank_savings = 500000
	var main = MainScreenScene.instantiate()
	add_child(main)
	if main.disclaimer_screen != null:
		main.disclaimer_screen.hide()
	if main.loading_screen != null:
		main.loading_screen.hide()
	await get_tree().process_frame
	await get_tree().process_frame

	main._show_charity_modal()
	await get_tree().process_frame
	var queue: Array[Node] = [main.charity_modal_overlay]
	var amount_count := 0
	while not queue.is_empty():
		var node: Node = queue.pop_front()
		if node is Label and node.name == "CharityAmount":
			amount_count += 1
			assert(node.autowrap_mode == TextServer.AUTOWRAP_OFF, "Charity amount must remain horizontal: %s" % node.text)
			assert(node.custom_minimum_size.x >= 180.0, "Charity amount must reserve horizontal width: %s" % node.text)
		for child in node.get_children():
			queue.append(child)
	assert(amount_count >= 6, "Every charity option must show a horizontal amount")
	print("PASS: %d charity amount labels stay horizontal." % amount_count)
	get_tree().quit()
