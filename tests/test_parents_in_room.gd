extends Node

func _ready() -> void:
	print("=== BEGIN PARENTS IN ROOM VERIFICATION ===")
	
	PlayerData.reset_player()
	PlayerData.first_name = "Alex"
	PlayerData.age = 0
	PlayerData.gender = "MALE"
	PlayerData.ethnicity = "asian"
	PlayerData.mother_name = "Elena"
	PlayerData.mother_alive = true
	PlayerData.father_name = "Marcus"
	PlayerData.father_alive = true
	
	var room_res = load("res://scenes/isometric/isometric_room.tscn") as PackedScene
	assert(room_res != null, "isometric_room.tscn must load")
	var room = room_res.instantiate()
	add_child(room)
	
	await get_tree().process_frame
	
	var chars = room.get_node("Characters")
	assert(chars != null, "Characters node must exist")
	
	var player = chars.get_node_or_null("IsometricCharacter")
	assert(player != null, "Player character must exist")
	assert(player.is_npc == false, "Player is not an NPC")
	assert(player.get_node("SpriteAnchor/Sprite2D").texture != null, "Player must have portrait texture")
	print("✔ Player bobbly head verified in room")
	
	var mother = chars.get_node_or_null("MotherCharacter")
	assert(mother != null, "Mother character must exist")
	assert(mother.is_npc == true, "Mother must be marked as NPC")
	assert(mother.get_node("SpriteAnchor/Sprite2D").texture != null, "Mother must have portrait texture")
	assert(room.is_point_walkable(mother.position), "Mother position must be walkable")
	print("✔ Mother bobbly head verified in room with valid portrait and position: ", mother.position)
	
	var father = chars.get_node_or_null("FatherCharacter")
	assert(father != null, "Father character must exist")
	assert(father.is_npc == true, "Father must be marked as NPC")
	assert(father.get_node("SpriteAnchor/Sprite2D").texture != null, "Father must have portrait texture")
	assert(room.is_point_walkable(father.position), "Father position must be walkable")
	print("✔ Father bobbly head verified in room with valid portrait and position: ", father.position)
	
	# Simulate steps for both parents
	for i in range(10):
		mother._process(0.05)
		father._process(0.05)
		
	# Test parent removal when deceased
	PlayerData.mother_alive = false
	room.update_character()
	await get_tree().process_frame
	assert(chars.get_node_or_null("MotherCharacter") == null, "Mother node should be freed when deceased")
	print("✔ Deceased parent gracefully removed from room")
	
	print("=== PARENTS IN ROOM VERIFICATION PASSED SUCCESSFULLY ===")
	get_tree().quit()
