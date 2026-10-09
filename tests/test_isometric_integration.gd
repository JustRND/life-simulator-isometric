extends Node

const RoomManager = preload("res://scripts/isometric/room_manager.gd")

func _ready() -> void:
	print("=== BEGIN FULL ISOMETRIC INTEGRATION & REGRESSION TEST ===")
	
	SaveManager.delete_save()
	PlayerData.reset_player()
	PlayerData.first_name = "TestPlayer"
	PlayerData.age = 18
	PlayerData.gender = "MALE"
	PlayerData.ethnicity = "asian"
	PlayerData.money = 500
	PlayerData.health = 90
	PlayerData.happiness = 85
	
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
	
	var feed_panel: PanelContainer = main.get_node("SafeArea/MainColumn/LifeFeedPanel")
	assert(feed_panel != null, "1. LifeFeedPanel must exist in original timeline location")
	var room: Node2D = feed_panel.get_node("RoomViewportContainer/RoomSubViewport/IsometricRoom")
	assert(room != null, "1. IsometricRoom must exist inside LifeFeedPanel SubViewport")
	assert(room.current_room_id == "room_wood", "1. Wood room must be active by default")
	print("✔ CHECK 1: Wood room appears in the timeline's former location.")
	
	# 2. Test the other 4 rooms can be selected and artwork is not distorted
	var room_ids := RoomManager.get_all_room_ids()
	for rid in room_ids:
		room.set_room(rid)
		assert(room.current_room_id == rid, "Room must update to %s" % rid)
		var bg: Sprite2D = room.get_node("RoomBackground")
		assert(bg.texture != null, "Room %s must have valid texture" % rid)
		assert(bg.texture.get_width() == 2048 and bg.texture.get_height() == 2048, "Texture must be 2048x2048 square (undistorted)")
		assert(bg.scale == Vector2.ONE, "Sprite2D scale must be 1:1 (aspect ratio preserved)")
		assert(bg.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Texture filter must be NEAREST")
	print("✔ CHECK 2 & 3: All 5 rooms selectable, aspect ratio 1:1 undistorted, pixel-art sharpness verified.")
	
	# 3. Test character spawn & position
	var ch = room._character_instance
	assert(ch != null, "4. Character must spawn")
	assert(room.is_point_walkable(ch.position), "5. Character feet must be inside floor polygon")
	print("✔ CHECK 4 & 5: Player character spawned correctly on the floor.")
	
	# 4. Test walking behavior
	var prev_pos = ch.position
	ch.target_position = Vector2(50, 220)
	ch.current_state = ch.State.WALKING
	for i in range(10):
		ch._process(0.05)
		assert(room.is_point_walkable(ch.position), "Character must remain inside floor during walking")
	assert(ch.position != prev_pos, "Character position must change when walking")
	print("✔ CHECK 6: Walking behavior works smoothly frame-rate independently.")
	
	# 5. Test event card functionality
	main.current_event = {
		"id": "test_event_choice",
		"title": "NEIGHBORHOOD WALK",
		"description": "You take a stroll through the neighborhood."
	}
	main.current_event_choices = [
		{"text": "Wave to neighbor"},
		{"text": "Ignore and walk past"}
	]
	main.show_event_popup()
	await get_tree().process_frame
	var overlay = main.get_node("EventOverlay")
	assert(overlay.visible == true, "Event overlay must become visible on event popup")
	main._on_event_choice_1_pressed()
	await get_tree().create_timer(0.4).timeout
	assert(overlay.visible == false, "Event overlay must close after choice pressed")
	print("✔ CHECK 7: Event cards, choices, and decisions remain completely functional.")
	
	# 6. Test statistics updating
	var initial_health = PlayerData.health
	PlayerData.health += 5
	main.update_ui()
	assert(main.health_bar.value == initial_health + 5, "Health bar must reflect updated PlayerData")
	print("✔ CHECK 8: Character statistics continue updating accurately.")
	
	# 7. Test save / load functionality with room selection persistence
	PlayerData.selected_room_id = "room_modern"
	var save_res = SaveManager.save_game("user://test_savegame.json")
	assert(save_res == true, "Save game must succeed")
	
	PlayerData.selected_room_id = "room_wood"
	var load_res = SaveManager.load_game("user://test_savegame.json")
	assert(load_res == true, "Load game must succeed")
	assert(PlayerData.selected_room_id == "room_modern", "Loaded data must restore selected_room_id=room_modern")
	main.update_ui()
	assert(room.current_room_id == "room_modern", "Room view must match loaded room_modern")
	print("✔ CHECK 9: Save/load functionality remains fully intact with room persistence.")
	
	# 8. Test runtime room switching via UI button
	var cycle_btn: Button = feed_panel.get_node("RoomControls/RoomCycleButton")
	assert(cycle_btn != null, "RoomCycleButton must exist")
	main._on_room_cycle_button_pressed()
	assert(room.current_room_id == "room_dark", "Cycling from room_modern should select room_dark")
	main._on_room_cycle_button_pressed()
	assert(room.current_room_id == "room_wood", "Cycling from room_dark should wrap to room_wood")
	print("✔ CHECK 10: Room switching works dynamically without crashes.")
	
	# 9. Test UI click pass-through
	var vp_container: SubViewportContainer = feed_panel.get_node("RoomViewportContainer")
	assert(vp_container.mouse_filter == Control.MOUSE_FILTER_IGNORE, "SubViewportContainer must have mouse_filter IGNORE")
	assert(main.action_bar != null, "ActionBar must remain intact")
	print("✔ CHECK 11: Main UI remains fully responsive and input clicks are not intercepted.")
	
	print("=== ALL 11 ISOMETRIC INTEGRATION CHECKS PASSED SUCCESSFULLY ===")
	get_tree().quit()
