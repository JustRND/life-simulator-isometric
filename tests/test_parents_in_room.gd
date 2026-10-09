extends Node

const PortraitCatalog = preload("res://scripts/core/portrait_catalog.gd")

func _ready() -> void:
	print("=== BEGIN PARENTS & CHILDREN IN ROOM VERIFICATION ===")
	
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
	var player_tex = player.get_node("SpriteAnchor/Sprite2D").texture
	assert(player_tex != null, "Player must have portrait texture")
	assert("baby" in player_tex.resource_path.to_lower(), "Player at age 0 must have baby portrait")
	print("✔ Player bobbly head verified in room (baby portrait confirmed: %s)" % player_tex.resource_path)
	
	var mother = chars.get_node_or_null("MotherCharacter")
	assert(mother != null, "Mother character must exist")
	assert(mother.is_npc == true, "Mother must be marked as NPC")
	var mother_tex = mother.get_node("SpriteAnchor/Sprite2D").texture
	assert(mother_tex != null, "Mother must have portrait texture")
	assert(not "baby" in mother_tex.resource_path.to_lower(), "Mother must NOT have a baby portrait")
	assert(room.is_point_walkable(mother.position), "Mother position must be walkable")
	print("✔ Mother bobbly head verified in room (adult portrait: %s)" % mother_tex.resource_path)
	
	var expected_mom_tex = PortraitCatalog.get_portrait(PlayerData.mother_base_age + PlayerData.age, "FEMALE", PlayerData.mother_portrait_track, PlayerData.ethnicity)
	assert(mother_tex == expected_mom_tex, "Mother avatar in room must match mother portrait track")
	print("✔ Mother avatar in room matches Relationships Panel avatar (%s)" % mother_tex.resource_path)
	
	var father = chars.get_node_or_null("FatherCharacter")
	assert(father != null, "Father character must exist")
	assert(father.is_npc == true, "Father must be marked as NPC")
	var father_tex = father.get_node("SpriteAnchor/Sprite2D").texture
	assert(father_tex != null, "Father must have portrait texture")
	assert(not "baby" in father_tex.resource_path.to_lower(), "Father must NOT have a baby portrait")
	assert(room.is_point_walkable(father.position), "Father position must be walkable")
	print("✔ Father bobbly head verified in room (adult portrait: %s)" % father_tex.resource_path)
	var expected_dad_tex = PortraitCatalog.get_portrait(PlayerData.father_base_age + PlayerData.age, "MALE", PlayerData.father_portrait_track, PlayerData.ethnicity)
	assert(father_tex == expected_dad_tex, "Father avatar in room must match father portrait track")
	print("✔ Father avatar in room matches Relationships Panel avatar (%s)" % father_tex.resource_path)
	
	# Verify track change sync (e.g. tracks 1, 2, 3)
	for t in range(4):
		PlayerData.mother_portrait_track = t
		PlayerData.father_portrait_track = (t + 1) % 4
		room.update_character()
		await get_tree().process_frame
		var m_synced_tex = chars.get_node("MotherCharacter/SpriteAnchor/Sprite2D").texture
		var f_synced_tex = chars.get_node("FatherCharacter/SpriteAnchor/Sprite2D").texture
		assert(m_synced_tex == PortraitCatalog.get_portrait(PlayerData.mother_base_age + PlayerData.age, "FEMALE", t, PlayerData.ethnicity), "Mother track %d synced" % t)
		assert(f_synced_tex == PortraitCatalog.get_portrait(PlayerData.father_base_age + PlayerData.age, "MALE", (t + 1) % 4, PlayerData.ethnicity), "Father track %d synced" % ((t + 1) % 4))
	print("✔ Parents track sync dynamically verified across all 4 tracks")
	
	# Simulate steps for both parents
	for i in range(10):
		mother._process(0.05)
		father._process(0.05)
		
	# Test unknown father bug fix (single parent birth where father is "Unknown")
	PlayerData.father_name = "Unknown"
	room.update_character()
	await get_tree().process_frame
	assert(chars.get_node_or_null("FatherCharacter") == null, "Unknown father must NOT spawn a character/baby")
	print("✔ Unknown father correctly omitted (preventing duplicate baby bug)")
	
	# Test parent removal when deceased
	PlayerData.mother_alive = false
	room.update_character()
	await get_tree().process_frame
	assert(chars.get_node_or_null("MotherCharacter") == null, "Mother node should be freed when deceased")
	print("✔ Deceased parent gracefully removed from room")
	
	# Test children spawning
	print("Testing children spawning...")
	var kid1 = PlayerData.add_player_child("Tommy", "MALE", 2)
	room.update_character()
	await get_tree().process_frame
	
	var kid_node1 = chars.get_node_or_null("ChildCharacter_0")
	assert(kid_node1 != null, "Child 0 character must exist in room")
	assert(kid_node1.is_npc == true, "Child must be marked as NPC")
	var kid_tex1 = kid_node1.get_node("SpriteAnchor/Sprite2D").texture
	assert(kid_tex1 != null, "Child must have portrait texture")
	assert(room.is_point_walkable(kid_node1.position), "Child position must be walkable")
	print("✔ Child 0 (Tommy, age 2) verified in room at position: %s with texture: %s" % [kid_node1.position, kid_tex1.resource_path])
	
	# Add second child
	var kid2 = PlayerData.add_player_child("Sarah", "FEMALE", 7)
	room.update_character()
	await get_tree().process_frame
	
	var kid_node2 = chars.get_node_or_null("ChildCharacter_1")
	assert(kid_node2 != null, "Child 1 character must exist in room")
	print("✔ Child 1 (Sarah, age 7) verified in room")
	
	# Simulate steps for children
	for i in range(10):
		kid_node1._process(0.05)
		kid_node2._process(0.05)
		
	# Test child removal when child is removed / deceased
	PlayerData.children.pop_back()
	room.update_character()
	await get_tree().process_frame
	assert(chars.get_node_or_null("ChildCharacter_1") == null, "Removed child must be cleaned up from room")
	assert(chars.get_node_or_null("ChildCharacter_0") != null, "Remaining child must persist in room")
	print("✔ Child cleanup verified when child is removed")
	
	print("=== PARENTS & CHILDREN IN ROOM VERIFICATION PASSED SUCCESSFULLY ===")
	get_tree().quit()

