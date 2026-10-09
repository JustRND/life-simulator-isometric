extends Node

const PortraitCatalog = preload("res://scripts/core/portrait_catalog.gd")

func _ready() -> void:
	print("=== BEGIN MARRIED PARTNER IN ROOM VERIFICATION ===")
	
	PlayerData.reset_player()
	PlayerData.first_name = "Jordan"
	PlayerData.age = 25
	PlayerData.gender = "MALE"
	PlayerData.ethnicity = "white"
	PlayerData.mother_name = "Sarah"
	PlayerData.mother_alive = true
	PlayerData.father_name = "David"
	PlayerData.father_alive = true
	PlayerData.partner = {}
	
	var room_res = load("res://scenes/isometric/isometric_room.tscn") as PackedScene
	assert(room_res != null, "isometric_room.tscn must load")
	var room = room_res.instantiate()
	add_child(room)
	
	await get_tree().process_frame
	
	var chars = room.get_node("Characters")
	assert(chars != null, "Characters node must exist")
	
	# Case 1: Unmarried / Single -> PartnerCharacter must NOT exist
	var partner_node = chars.get_node_or_null("PartnerCharacter")
	assert(partner_node == null, "Partner must NOT exist when player is single")
	print("✔ Single player verified: No partner in room")
	
	# Case 2: In relationship (Girlfriend) -> PartnerCharacter must NOT exist yet (only when married)
	PlayerData.partner = {
		"name": "Chloe",
		"status": "Girlfriend",
		"gender": "FEMALE",
		"age": 24,
		"ethnicity": "asian",
		"portrait_track": 1,
		"relationship": 85,
		"is_alive": true
	}
	room.update_character()
	await get_tree().process_frame
	partner_node = chars.get_node_or_null("PartnerCharacter")
	assert(partner_node == null, "Dating partner (Girlfriend) must NOT appear in the isometric house")
	print("✔ Dating status verified: Girlfriend does not appear until married")
	
	# Case 3: Engaged (Fiancée) -> PartnerCharacter must NOT exist yet
	PlayerData.partner["status"] = "Fiancée"
	room.update_character()
	await get_tree().process_frame
	partner_node = chars.get_node_or_null("PartnerCharacter")
	assert(partner_node == null, "Engaged partner (Fiancée) must NOT appear in the isometric house yet")
	print("✔ Engaged status verified: Fiancée does not appear until married")
	
	# Case 4: Married (Wife) -> PartnerCharacter MUST appear!
	PlayerData.partner["status"] = "Wife"
	room.update_character()
	await get_tree().process_frame
	partner_node = chars.get_node_or_null("PartnerCharacter")
	assert(partner_node != null, "Married partner (Wife) MUST appear in the isometric house")
	assert(partner_node.is_npc == true, "Partner must be configured as an NPC")
	assert(room.is_point_walkable(partner_node.position), "Partner position must be in walkable floor area")
	
	var partner_sprite = partner_node.get_node("SpriteAnchor/Sprite2D")
	assert(partner_sprite != null, "Partner sprite must exist")
	var wife_tex = partner_sprite.texture
	assert(wife_tex != null, "Partner must have a portrait texture assigned")
	
	var expected_wife_tex = PortraitCatalog.get_portrait(24, "FEMALE", 1, "asian")
	assert(wife_tex == expected_wife_tex, "Partner avatar in room must match partner's catalog portrait")
	print("✔ Married partner (Wife: Chloe) verified in isometric house (%s) at position %s" % [wife_tex.resource_path, partner_node.position])
	
	# Case 5: Partner animation / process simulation
	for i in range(10):
		partner_node._process(0.05)
	print("✔ Partner autonomous process and movement simulated successfully")
	
	# Case 6: Aging up to Elder
	PlayerData.partner["age"] = 68
	room.update_character()
	await get_tree().process_frame
	var elder_tex = partner_node.get_node("SpriteAnchor/Sprite2D").texture
	var expected_elder_tex = PortraitCatalog.get_portrait(68, "FEMALE", 1, "asian")
	assert(elder_tex == expected_elder_tex, "Partner portrait must age up to elder")
	assert("elder" in elder_tex.resource_path.to_lower(), "Texture path should contain elder")
	print("✔ Partner age progression to Elder verified: %s" % elder_tex.resource_path)
	
	# Case 7: Divorce / Breakup -> Partner node must be removed
	PlayerData.ex_partners.append(PlayerData.partner)
	PlayerData.partner = {}
	room.update_character()
	await get_tree().process_frame
	partner_node = chars.get_node_or_null("PartnerCharacter")
	assert(partner_node == null, "Divorce must remove partner from the isometric house")
	print("✔ Divorce verified: Partner successfully removed from isometric house")
	
	# Case 8: Remarried to a Husband
	PlayerData.partner = {
		"name": "Alexander",
		"status": "Husband",
		"gender": "MALE",
		"age": 32,
		"ethnicity": "black",
		"portrait_track": 2,
		"relationship": 90,
		"is_alive": true
	}
	room.update_character()
	await get_tree().process_frame
	partner_node = chars.get_node_or_null("PartnerCharacter")
	assert(partner_node != null, "Remarried partner (Husband) must appear in the isometric house")
	var husband_tex = partner_node.get_node("SpriteAnchor/Sprite2D").texture
	var expected_husband_tex = PortraitCatalog.get_portrait(32, "MALE", 2, "black")
	assert(husband_tex == expected_husband_tex, "Husband avatar must match PortraitCatalog portrait")
	print("✔ Remarried partner (Husband: Alexander) verified: %s" % husband_tex.resource_path)
	
	# Case 9: Partner passes away (is_alive = false)
	PlayerData.partner["is_alive"] = false
	room.update_character()
	await get_tree().process_frame
	partner_node = chars.get_node_or_null("PartnerCharacter")
	assert(partner_node == null, "Deceased partner must not appear in the isometric house")
	print("✔ Deceased partner verified: Removed from house")
	
	print("=== MARRIED PARTNER IN ROOM VERIFICATION PASSED SUCCESSFULLY ===")
	get_tree().quit(0)
