extends Node

const RoomManager = preload("res://scripts/isometric/room_manager.gd")
const IsometricRoomScript = preload("res://scenes/isometric/isometric_room.gd")

func _ready() -> void:
	print("=== BEGIN ISO ROOM & CHARACTER VERIFICATION ===")
	
	# 1. Test RoomManager
	var room_ids: Array[String] = RoomManager.get_all_room_ids()
	assert(room_ids.size() >= 5, "Must have at least 5 rooms defined")
	print("✔ Rooms registered: ", room_ids.size())
	
	for rid in room_ids:
		var data := RoomManager.get_room_data(rid)
		assert(data.has("texture_path"), "Room %s must have texture path" % rid)
		var tex := RoomManager.get_room_texture(rid)
		assert(tex != null, "Texture for %s must load successfully" % rid)
		
	# 2. Test Room Scene Instantiation
	var room_scene := load("res://scenes/isometric/isometric_room.tscn") as PackedScene
	assert(room_scene != null, "Isometric room scene must load")
	var room := room_scene.instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	
	assert(room.current_room_id == "room_capsule" or room.current_room_id == "room_wood", "Default room must be room_capsule or room_wood")
	print("✔ IsometricRoom instantiated with default room: ", room.current_room_id)
	
	# 3. Test Walkable Area Polygon checks
	# Floor center: (0, 200) should be walkable
	assert(room.is_point_walkable(Vector2(0, 200)), "Floor center (0, 200) must be walkable")
	assert(room.is_point_walkable(Vector2(0, 0)), "Floor center-top (0, 0) must be walkable")
	# Far out points (walls, ceiling, outside) should NOT be walkable
	assert(not room.is_point_walkable(Vector2(0, -500)), "Wall point (0, -500) must NOT be walkable")
	assert(not room.is_point_walkable(Vector2(0, 800)), "Foundation ledge (0, 800) must NOT be walkable")
	assert(not room.is_point_walkable(Vector2(-900, 200)), "Left wall (-900, 200) must NOT be walkable")
	assert(not room.is_point_walkable(Vector2(900, 200)), "Right wall (900, 200) must NOT be walkable")
	print("✔ WalkableArea polygon checks passed")
	
	# 4. Test random points generation
	for i in range(100):
		var pt: Vector2 = room.get_random_walkable_point()
		assert(room.is_point_walkable(pt), "Random point %s must be inside walkable polygon" % pt)
	print("✔ 100/100 random walkable points verified strictly inside floor polygon")
	
	# 5. Test character
	var ch = room._character_instance
	assert(ch != null, "Character instance must exist in room")
	print("✔ Character spawned at: ", ch.position)
	assert(room.is_point_walkable(ch.position), "Spawn position must be walkable")
	
	# Test character step and movement
	ch.target_position = Vector2(100, 250)
	ch.current_state = ch.State.WALKING
	var start_pos = ch.position
	ch._process(0.1) # Simulate 100ms
	assert(ch.position != start_pos, "Character should move when walking")
	print("✔ Character movement step simulated successfully. New pos: ", ch.position)
	
	# 6. Test room switching
	for rid in room_ids:
		room.set_room(rid)
		assert(room.current_room_id == rid, "Room should be %s" % rid)
		assert(room.room_background.texture != null, "Texture must be valid for %s" % rid)
	print("✔ All 5 rooms successfully switched without errors")
	
	# Reset back to capsule
	room.set_room("room_capsule")
	assert(room.current_room_id == "room_capsule", "Reset to room_capsule")
	
	print("=== ALL ISO ROOM & CHARACTER CHECKS PASSED ===")
	get_tree().quit()
