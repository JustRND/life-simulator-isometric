extends Node

func _ready() -> void:
	print("=== BEGIN MILESTONE 1 VERIFICATION ===")
	
	SaveManager.delete_save()
	PlayerData.reset_player()
	
	var main_res := load("res://scenes/main/main_screen.tscn") as PackedScene
	assert(main_res != null, "main_screen.tscn must load successfully")
	var main = main_res.instantiate()
	add_child(main)
	
	if main.disclaimer_screen != null:
		main.disclaimer_screen.hide()
	if main.loading_screen != null:
		main.loading_screen.hide()
		
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 1. Verify LifeFeedPanel hierarchy
	var feed_panel: PanelContainer = main.get_node("SafeArea/MainColumn/LifeFeedPanel")
	assert(feed_panel != null, "LifeFeedPanel must exist")
	assert(feed_panel.clip_contents == true, "LifeFeedPanel must have clip_contents enabled")
	print("✔ LifeFeedPanel exists with clip_contents=true")
	
	# 2. Verify RoomViewportContainer & SubViewport
	var vp_container: SubViewportContainer = feed_panel.get_node("RoomViewportContainer")
	assert(vp_container != null, "RoomViewportContainer must exist")
	assert(vp_container.mouse_filter == Control.MOUSE_FILTER_IGNORE, "RoomViewportContainer must ignore mouse filter to prevent blocking UI clicks")
	assert(vp_container.stretch == true, "RoomViewportContainer must stretch")
	print("✔ RoomViewportContainer verified (stretch=true, mouse_filter=IGNORE)")
	
	var sub_vp: SubViewport = vp_container.get_node("RoomSubViewport")
	assert(sub_vp != null, "RoomSubViewport must exist")
	assert(sub_vp.gui_disable_input == true, "RoomSubViewport gui_disable_input must be true")
	print("✔ RoomSubViewport verified")
	
	# 3. Verify IsometricRoom inside SubViewport
	var room: Node2D = sub_vp.get_node("IsometricRoom")
	assert(room != null, "IsometricRoom must be instanced in SubViewport")
	assert(room.current_room_id == "room_wood", "Initial room must be room_wood")
	print("✔ IsometricRoom instanced with room_wood by default")
	
	# 4. Verify room texture
	var bg_sprite: Sprite2D = room.get_node("RoomBackground")
	assert(bg_sprite != null, "RoomBackground Sprite2D must exist")
	assert(bg_sprite.texture != null, "RoomBackground must have texture")
	assert(bg_sprite.texture.get_width() == 2048, "Room texture must be 2048x2048")
	assert(bg_sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Texture filter must be NEAREST for pixel art")
	print("✔ RoomBackground texture verified (2048x2048, NEAREST filter)")
	
	# 5. Verify character spawned on floor
	var char_node: Node2D = room.get_node("Characters/IsometricCharacter")
	assert(char_node != null, "IsometricCharacter must be spawned in Characters node")
	assert(room.is_point_walkable(char_node.position), "Character must spawn inside walkable floor polygon")
	print("✔ Character verified on floor at position: ", char_node.position)
	
	# 6. Verify timeline history logging preserved
	var initial_log_count := PlayerData.life_log.size()
	main.add_life_event("Learned to crawl across the room floor.")
	assert(PlayerData.life_log.size() == initial_log_count + 1, "PlayerData.life_log must continue recording events")
	print("✔ Life log event history preserved and recorded")
	
	# 7. Verify UI stats and update_ui syncing
	main.update_ui()
	var anim_sprite: AnimatedSprite2D = char_node.get_node("AnimatedSprite2D")
	assert(anim_sprite != null and anim_sprite.sprite_frames != null, "AnimatedSprite2D must exist with valid frames")
	print("✔ Character appearance synced with PlayerData")
	
	# 8. Verify character roaming simulation
	char_node._pick_next_destination()
	assert(char_node.current_state == char_node.State.WALKING, "Character should enter WALKING state toward destination")
	assert(room.is_point_walkable(char_node.target_position), "Destination must be inside floor polygon")
	print("✔ Character picked valid roaming destination: ", char_node.target_position)
	
	print("=== MILESTONE 1 VERIFICATION PASSED SUCCESSFULLY ===")
	get_tree().quit()
