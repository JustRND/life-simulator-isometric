extends Node

func _ready() -> void:
	print("=== BEGIN ANIMATED ISOMETRIC CHARACTER VERIFICATION ===")
	
	PlayerData.reset_player()
	PlayerData.first_name = "Alex"
	PlayerData.age = 22
	
	# 1. Load Character Scene
	var char_res := load("res://scenes/isometric/isometric_character.tscn") as PackedScene
	assert(char_res != null, "isometric_character.tscn must load successfully")
	var character: Node2D = char_res.instantiate() as Node2D
	add_child(character)
	await get_tree().process_frame
	
	# 2. Verify AnimatedSprite2D and SpriteFrames
	var anim_sprite: AnimatedSprite2D = character.get_node("AnimatedSprite2D")
	assert(anim_sprite != null, "AnimatedSprite2D node must exist")
	assert(anim_sprite.sprite_frames != null, "SpriteFrames resource must exist")
	assert(anim_sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "texture_filter must be NEAREST for pixel-art")
	
	var sf: SpriteFrames = anim_sprite.sprite_frames
	var required_anims := ["walk_se", "walk_sw", "walk_ne", "walk_nw", "idle_se", "idle_sw", "idle_ne", "idle_nw"]
	for a_name in required_anims:
		assert(sf.has_animation(a_name), "SpriteFrames must contain animation: %s" % a_name)
		var fcount := sf.get_frame_count(a_name)
		assert(fcount > 0, "Animation %s must have frames (found %d)" % [a_name, fcount])
		print("✔ Animation %s verified (%d frames, %.1f FPS)" % [a_name, fcount, sf.get_animation_speed(a_name)])
	print("✔ All 8 target directional animations verified in SpriteFrames.")
	
	# 3. Verify Collision and InteractionArea
	var area: Area2D = character.get_node("InteractionArea")
	assert(area != null, "InteractionArea (Area2D) must exist")
	var col_shape: CollisionShape2D = area.get_node("CollisionShape2D")
	assert(col_shape != null, "CollisionShape2D must exist inside InteractionArea")
	print("✔ InteractionArea and CollisionShape2D verified.")
	
	# 4. Verify Directional Mapping
	assert(character.get_direction_facing(Vector2(100, 50)) == "se", "Vector (+x, +y) must map to 'se'")
	assert(character.get_direction_facing(Vector2(-100, 50)) == "sw", "Vector (-x, +y) must map to 'sw'")
	assert(character.get_direction_facing(Vector2(100, -50)) == "ne", "Vector (+x, -y) must map to 'ne'")
	assert(character.get_direction_facing(Vector2(-100, -50)) == "nw", "Vector (-x, -y) must map to 'nw'")
	print("✔ Directional mapping for SE, SW, NE, NW verified.")
	
	# 5. Test Integration in IsometricRoom
	var room_res := load("res://scenes/isometric/isometric_room.tscn") as PackedScene
	var room = room_res.instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var room_char: Node2D = room._character_instance as Node2D
	assert(room_char != null, "Room character must spawn")
	assert(room.is_point_walkable(room_char.position), "Spawn position must be inside floor polygon")
	print("✔ Character spawned inside isometric room at walkable point: ", room_char.position)
	
	# 6. Test Walking, Directional Animation, and Arrival
	var test_dest := Vector2(150, 260) # South-East destination
	room_char.target_position = test_dest
	room_char.current_state = room_char.State.WALKING
	var dir_vec: Vector2 = (test_dest - room_char.position).normalized()
	room_char.current_facing = room_char.get_direction_facing(dir_vec)
	room_char.animated_sprite.play("walk_" + room_char.current_facing)
	assert(room_char.animated_sprite.animation == "walk_se", "Moving south-east must play walk_se")
	print("✔ Animation playing while moving SE: ", room_char.animated_sprite.animation)
	
	# Simulate steps until arrival
	for step_i in range(100):
		if room_char.current_state == room_char.State.IDLE:
			break
		room_char._process(0.05)
		assert(room.is_point_walkable(room_char.position), "Feet must stay within floor polygon at all times")
		
	assert(room_char.current_state == room_char.State.IDLE, "Character must arrive and transition to IDLE")
	assert(room_char.animated_sprite.animation == "idle_se", "Arriving from SE walk must transition to idle_se")
	print("✔ Walking cycle, floor containment, and idle arrival transition verified.")
	
	# 7. Test Reverse Direction (North-West)
	var nw_dest := Vector2(-120, 100) # North-West destination
	room_char.target_position = nw_dest
	room_char.current_state = room_char.State.WALKING
	var nw_vec: Vector2 = (nw_dest - room_char.position).normalized()
	room_char.current_facing = room_char.get_direction_facing(nw_vec)
	room_char.animated_sprite.play("walk_" + room_char.current_facing)
	assert(room_char.animated_sprite.animation == "walk_nw", "Moving north-west must play walk_nw")
	print("✔ Animation playing while moving NW: ", room_char.animated_sprite.animation)
	
	for step_i in range(100):
		if room_char.current_state == room_char.State.IDLE:
			break
		room_char._process(0.05)
		assert(room.is_point_walkable(room_char.position), "Feet must stay within floor polygon moving NW")
		
	assert(room_char.current_state == room_char.State.IDLE, "Character must arrive and transition to IDLE (NW)")
	assert(room_char.animated_sprite.animation == "idle_nw", "Arriving from NW walk must transition to idle_nw")
	print("✔ NW movement and idle_nw verified.")
	
	# 8. Test Main Screen Full Integration
	var main_res := load("res://scenes/main/main_screen.tscn") as PackedScene
	var main = main_res.instantiate()
	add_child(main)
	if main.disclaimer_screen != null:
		main.disclaimer_screen.hide()
	if main.loading_screen != null:
		main.loading_screen.hide()
	await get_tree().process_frame
	await get_tree().process_frame
	
	var main_char = main.get_node("SafeArea/MainColumn/LifeFeedPanel/RoomViewportContainer/RoomSubViewport/IsometricRoom/Characters/IsometricCharacter")
	assert(main_char != null, "Animated character must be active in main gameplay room")
	assert(main_char.animated_sprite != null, "Main character must have AnimatedSprite2D active")
	print("✔ Main game integration: AnimatedSprite2D character active in timeline area.")
	
	print("=== ALL ANIMATED CHARACTER CHECKS PASSED SUCCESSFULLY ===")
	get_tree().quit()
