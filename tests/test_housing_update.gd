extends Node

func _ready() -> void:
	print("--- Running Test Housing Update ---")
	
	# 1. Test Game Version
	var proj_ver := str(ProjectSettings.get_setting("application/config/version", ""))
	assert(proj_ver == "0.2.0", "Expected version 0.2.0, got %s" % proj_ver)
	var lib_ver := LifeLibrary.get_version_string()
	assert(lib_ver == "0.2.0", "Expected LifeLibrary version 0.2.0, got %s" % lib_ver)
	print("✓ Version check passed: 0.2.0")

	# 2. Test All 24 Properties have Room Definitions and valid textures
	var expected_properties := [
		"prop_capsule", "prop_tenement", "prop_studio", "prop_condo",
		"prop_cottage", "prop_suburban_split", "prop_townhouse", "prop_eco_timber",
		"prop_house", "prop_cabin", "prop_historic_brownstone", "prop_modern_villa",
		"prop_alpine_chalet", "prop_ranch", "prop_desert_estate", "prop_beachfront",
		"prop_harbor_duplex", "prop_penthouse", "prop_cyber_mansion", "prop_chateau",
		"prop_cliffside_compound", "prop_private_island", "prop_megatower_apex", "prop_orbital"
	]
	
	for prop_id in expected_properties:
		var room_id := RoomManager.get_room_id_for_property(prop_id)
		assert(room_id != "", "Missing room for property %s" % prop_id)
		var room_data: Dictionary = RoomManager.get_room_data(room_id)
		assert(not room_data.is_empty(), "Empty room data for %s" % room_id)
		var tex: Texture2D = RoomManager.get_room_texture(room_id)
		assert(tex != null, "Failed to load texture for room %s" % room_id)
		assert(tex.get_width() > 0 and tex.get_height() > 0, "Invalid texture size for %s" % room_id)
	print("✓ All 24 property housing rooms verified with valid loaded textures!")

	# 3. Test Room Resolution Defaults
	var default_room := RoomManager.get_room_id_for_property("")
	assert(default_room == "room_capsule", "Expected default room_capsule, got %s" % default_room)
	
	# 4. Test PlayerData Housing & Room Sync
	PlayerData.reset_player()
	assert(PlayerData.selected_room_id == "room_capsule", "Expected default selected_room_id to be room_capsule")
	assert(PlayerData.get_active_room_id() == "room_capsule", "Expected get_active_room_id to return room_capsule")
	
	# Simulate purchasing a high-tier property (e.g. Penthouse)
	var penthouse_asset := AssetCatalog.create_asset_instance("prop_penthouse", 25)
	PlayerData.owned_assets.append(penthouse_asset)
	PlayerData.set_active_room_from_property("prop_penthouse")
	assert(PlayerData.get_active_room_id() == "room_penthouse", "Expected active room to be room_penthouse")
	assert(PlayerData.sync_room_with_housing() == "room_penthouse", "Expected sync_room_with_housing to return room_penthouse")
	print("✓ Housing ownership and active room synchronization verified!")

	# 5. Verify Main Screen has no RoomCycleButton
	var main_scene := load("res://scenes/main/main_screen.tscn") as PackedScene
	assert(main_scene != null, "Failed to load main_screen.tscn")
	var instance = main_scene.instantiate()
	var room_ctrl = instance.find_child("RoomControls", true, false)
	assert(room_ctrl == null, "RoomControls must be removed from main_screen.tscn")
	var room_btn = instance.find_child("RoomCycleButton", true, false)
	assert(room_btn == null, "RoomCycleButton must be removed from main_screen.tscn")
	var alpha_lbl = instance.find_child("AlphaVersionLabel", true, false) as Label
	assert(alpha_lbl != null, "AlphaVersionLabel should exist")
	assert("v0.2.0" in alpha_lbl.text, "Expected AlphaVersionLabel to show v0.2.0, got: %s" % alpha_lbl.text)
	instance.queue_free()
	print("✓ Main screen UI verified: RoomCycleButton removed, AlphaVersionLabel shows v0.2.0")

	print("\nALL HOUSING UPDATE TESTS PASSED SUCCESSFULLY!")
	get_tree().quit(0)
