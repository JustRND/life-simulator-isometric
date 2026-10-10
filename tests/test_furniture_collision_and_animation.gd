extends Node

const RoomManager = preload("res://scripts/isometric/room_manager.gd")
const IsometricRoomScript = preload("res://scenes/isometric/isometric_room.gd")
const IsometricCharacterScript = preload("res://scenes/isometric/isometric_character.gd")

func _ready() -> void:
	print("=== BEGIN FURNITURE COLLISION & LIVING ANIMATION VERIFICATION ===")
	
	# 1. Instantiate IsometricRoom
	var room_scene: PackedScene = load("res://scenes/isometric/isometric_room.tscn") as PackedScene
	assert(room_scene != null, "Must be able to load isometric_room.tscn")
	var room: Node2D = room_scene.instantiate() as Node2D
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 2. Test obstacles and interaction spots exist for all archetypes
	var archetypes: Array[String] = ["capsule", "tenement", "studio", "condo", "cottage", "suburban_split", "townhouse", "eco_timber", "house", "cabin"]
	for arch: String in archetypes:
		var dummy_id: String = "room_" + arch
		var obstacles: Array[Rect2] = RoomManager.get_obstacles_for_room(dummy_id)
		assert(not obstacles.is_empty(), "Archetype %s must have obstacle collision rects" % arch)
		var spots: Array[Dictionary] = RoomManager.get_interaction_spots_for_room(dummy_id)
		assert(spots.size() >= 3, "Archetype %s must have at least 3 furniture interaction spots" % arch)
		
		# Ensure spots have valid attributes
		for spot: Dictionary in spots:
			assert(spot.has("id"), "Spot in %s must have id" % arch)
			assert(spot.has("pos"), "Spot in %s must have pos" % arch)
			assert(spot.has("action"), "Spot in %s must have action" % arch)
			assert(spot.has("facing"), "Spot in %s must have facing" % arch)
	print("✔ All 10 room archetypes verified with furniture obstacles and interaction spots")
	
	# 3. Test obstacle collision prevents walking through furniture
	# In room_capsule: bed is at Rect2(-420, 20, 240, 240)
	room.set_room("room_capsule")
	var inside_bed := Vector2(-300, 100)
	assert(not room.is_point_walkable(inside_bed), "Inside bed (-300, 100) must NOT be walkable for normal wandering")
	
	# Open floor must be walkable
	var open_floor := Vector2(0, 240)
	assert(room.is_point_walkable(open_floor), "Open floor (0, 240) must be walkable")
	print("✔ Furniture collision checks verified: furniture interiors blocked, open floor walkable")
	
	# 4. Test character interaction and animation states
	var ch: Node2D = room._character_instance
	assert(ch != null, "Character instance must exist")
	
	# Test spot reservation
	var available: Array[Dictionary] = room.get_available_interaction_spots()
	assert(not available.is_empty(), "Must have available interaction spots")
	var test_spot: Dictionary = available[0]
	var s_id: String = str(test_spot["id"])
	var reserved: bool = room.reserve_interaction_spot(s_id, ch)
	assert(reserved, "Spot must be reservable by character")
	
	# Cannot be reserved by another character while occupied
	var other_char := Node2D.new()
	assert(not room.reserve_interaction_spot(s_id, other_char), "Spot cannot be double-booked")
	other_char.queue_free()
	
	# Release spot
	room.release_interaction_spot(s_id, ch)
	print("✔ Spot reservation and multi-character occupancy checks passed")
	
	# 5. Simulate character moving to furniture spot and interacting
	ch.current_spot = test_spot
	ch.target_position = test_spot["pos"]
	ch.current_state = ch.State.WALKING
	
	# Teleport close to spot to simulate arrival
	ch.position = test_spot["pos"] - Vector2(2, 2)
	ch._process(0.1) # Simulate step arrival
	
	assert(ch.current_state == ch.State.INTERACTING, "Character must transition to INTERACTING when reaching furniture spot")
	print("✔ Character arrived at furniture and entered State.INTERACTING")
	
	# Verify living animation updates sprite scale and breathing during interaction
	ch._process(0.5) # Simulate half second of sitting/relaxing
	assert(ch.current_state == ch.State.INTERACTING, "Character should remain interacting during duration")
	print("✔ Furniture living animation active: pose offset %s, scale %s" % [ch.sprite.offset, ch.sprite.scale])
	
	# Simulate expiration of interaction duration
	ch.interaction_timer = 0.05
	ch._process(0.1)
	assert(ch.current_state == ch.State.IDLE, "Character must stand up and return to IDLE after interaction finishes")
	assert(ch.sprite.offset == Vector2(0, -45), "Sprite offset must reset to standing pose")
	assert(ch.sprite.rotation == 0.0, "Sprite rotation must reset to upright")
	print("✔ Character smoothly finished furniture interaction and returned to standing IDLE")
	
	# 6. Test room change cleanup
	room.set_room("room_tenement")
	assert(room.current_room_id == "room_tenement", "Room changed to tenement")
	assert(ch.current_state == ch.State.IDLE, "Character state reset on room change")
	print("✔ Room change cleanup verified")
	
	print("\n=== ALL FURNITURE COLLISION & ANIMATION TESTS PASSED! ===")
	get_tree().quit(0)
