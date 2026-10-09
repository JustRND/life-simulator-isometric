extends Node

const CharacterAppearanceScript = preload("res://scripts/isometric/character_appearance.gd")
const IsometricCharacterScript = preload("res://scenes/isometric/isometric_character.gd")

func _ready() -> void:
	print("=== BEGIN MODULAR CHARACTER CUSTOMIZATION ARCHITECTURE VERIFICATION ===")
	
	SaveManager.delete_save()
	PlayerData.reset_player()
	
	# --------------------------------------------------------------------------
	# 1. TEST CHARACTER APPEARANCE DATA MODEL
	# --------------------------------------------------------------------------
	var app = CharacterAppearanceScript.new()
	assert(app != null, "CharacterAppearance resource should be instantiable")
	assert(app.body_id == "default", "Default body_id should be 'default'")
	assert(app.age_group == CharacterAppearanceScript.AGE_ADULT, "Default age_group should be 'adult'")
	
	# Test slot manipulation
	app.set_slot("hair", "fade_undercut_brown")
	app.set_slot("top", "leather_jacket_black")
	app.set_slot("bottom", "cargo_pants_khaki")
	app.set_slot("shoes", "high_top_sneakers_red")
	app.set_slot("accessory", "aviator_sunglasses")
	app.set_slot("hat", "fedora_gray") # Custom slot test
	
	assert(app.get_slot("hair") == "fade_undercut_brown", "Hair slot must store barber shop hairstyle ID")
	assert(app.get_slot("top") == "leather_jacket_black", "Top slot must store clothing store top ID")
	assert(app.get_slot("bottom") == "cargo_pants_khaki", "Bottom slot must store clothing store pants ID")
	assert(app.get_slot("shoes") == "high_top_sneakers_red", "Shoes slot must store footwear store shoes ID")
	assert(app.get_slot("accessory") == "aviator_sunglasses", "Accessory slot must store accessory ID")
	assert(app.get_slot("hat") == "fedora_gray", "Custom extensible slot must store item ID")
	assert(app.has_slot_item("top") == true, "has_slot_item must return true for populated slot")
	
	# Test serialization & deserialization
	var dict_data: Dictionary = app.to_dict()
	assert(dict_data.get("hair_id") == "fade_undercut_brown", "to_dict must serialize hair_id")
	assert(dict_data.get("top_id") == "leather_jacket_black", "to_dict must serialize top_id")
	assert(dict_data.get("bottom_id") == "cargo_pants_khaki", "to_dict must serialize bottom_id")
	assert(dict_data.get("shoes_id") == "high_top_sneakers_red", "to_dict must serialize shoes_id")
	assert(dict_data.get("accessory_id") == "aviator_sunglasses", "to_dict must serialize accessory_id")
	assert(dict_data.get("custom_slots", {}).get("hat") == "fedora_gray", "to_dict must serialize custom_slots")
	
	var app_restored = CharacterAppearanceScript.create_from_dict(dict_data)
	assert(app_restored.hair_id == "fade_undercut_brown", "create_from_dict must restore hair_id")
	assert(app_restored.top_id == "leather_jacket_black", "create_from_dict must restore top_id")
	assert(app_restored.bottom_id == "cargo_pants_khaki", "create_from_dict must restore bottom_id")
	assert(app_restored.shoes_id == "high_top_sneakers_red", "create_from_dict must restore shoes_id")
	assert(app_restored.accessory_id == "aviator_sunglasses", "create_from_dict must restore accessory_id")
	assert(app_restored.get_slot("hat") == "fedora_gray", "create_from_dict must restore custom_slots")
	print("✔ CHECK 1: CharacterAppearance data model and serialization verified.")
	
	# --------------------------------------------------------------------------
	# 2. TEST AGE GROUP MAPPING ACROSS LIFE STAGES
	# --------------------------------------------------------------------------
	assert(CharacterAppearanceScript.get_age_group_from_years(0) == CharacterAppearanceScript.AGE_INFANT, "Age 0 must map to infant")
	assert(CharacterAppearanceScript.get_age_group_from_years(2) == CharacterAppearanceScript.AGE_INFANT, "Age 2 must map to infant")
	assert(CharacterAppearanceScript.get_age_group_from_years(6) == CharacterAppearanceScript.AGE_CHILD, "Age 6 must map to child")
	assert(CharacterAppearanceScript.get_age_group_from_years(15) == CharacterAppearanceScript.AGE_TEEN, "Age 15 must map to teen")
	assert(CharacterAppearanceScript.get_age_group_from_years(35) == CharacterAppearanceScript.AGE_ADULT, "Age 35 must map to adult")
	assert(CharacterAppearanceScript.get_age_group_from_years(75) == CharacterAppearanceScript.AGE_ELDER, "Age 75 must map to elder")
	print("✔ CHECK 2: Age group progression across 5 life stages verified.")
	
	# --------------------------------------------------------------------------
	# 3. TEST ISOMETRIC CHARACTER SCENE & VISUAL LAYERS ARCHITECTURE
	# --------------------------------------------------------------------------
	var char_scene := load("res://scenes/isometric/isometric_character.tscn") as PackedScene
	assert(char_scene != null, "isometric_character.tscn must load")
	var character: IsometricCharacter = char_scene.instantiate() as IsometricCharacter
	add_child(character)
	await get_tree().process_frame
	
	# Verify node hierarchy
	assert(character.animated_sprite != null, "Base animated_sprite must exist")
	assert(character.visual_layers_container != null, "VisualLayers container node must exist")
	assert(character.shadow != null, "Shadow Polygon2D must exist")
	assert(character.interaction_area != null, "InteractionArea must exist")
	assert(character.has_visual_layer("body"), "Base body layer must be registered in visual layers")
	print("✔ CHECK 3: Character visual hierarchy and VisualLayers container verified.")
	
	# --------------------------------------------------------------------------
	# 4. TEST DYNAMIC LAYER REGISTRATION & Z-ORDERING
	# --------------------------------------------------------------------------
	# Create mock modular SpriteFrames (e.g. hair and top layers using base frames for testing)
	var hair_frames: SpriteFrames = character.animated_sprite.sprite_frames.duplicate()
	var top_frames: SpriteFrames = character.animated_sprite.sprite_frames.duplicate()
	var shoes_frames: SpriteFrames = character.animated_sprite.sprite_frames.duplicate()
	
	var hair_layer: AnimatedSprite2D = character.add_visual_layer("hair", hair_frames)
	var top_layer: AnimatedSprite2D = character.add_visual_layer("top", top_frames)
	var shoes_layer: AnimatedSprite2D = character.add_visual_layer("shoes", shoes_frames)
	
	assert(character.has_visual_layer("hair"), "Hair visual layer must exist after addition")
	assert(character.has_visual_layer("top"), "Top visual layer must exist after addition")
	assert(character.has_visual_layer("shoes"), "Shoes visual layer must exist after addition")
	
	# Verify Z-index layering: body (0) < shoes (20) < top (30) < hair (40)
	assert(character.animated_sprite.z_index < shoes_layer.z_index, "Shoes must render above base body")
	assert(shoes_layer.z_index < top_layer.z_index, "Top clothing must render above shoes")
	assert(top_layer.z_index < hair_layer.z_index, "Hair must render above top clothing")
	
	# Verify offset and texture filtering consistency
	assert(hair_layer.offset == character.animated_sprite.offset, "Modular layer must align feet baseline offset")
	assert(hair_layer.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Modular layer must maintain pixel-art nearest filter")
	print("✔ CHECK 4: Modular visual layers registered with correct Z-ordering and feet alignment.")
	
	# --------------------------------------------------------------------------
	# 5. TEST SYNCHRONIZED DIRECTION & ANIMATION PLAYBACK ACROSS ALL LAYERS
	# --------------------------------------------------------------------------
	# Test South-East walk synchronization
	character.play_animation("walk_se")
	assert(character.animated_sprite.animation == "walk_se", "Base body must play walk_se")
	assert(hair_layer.animation == "walk_se", "Hair layer must synchronize to walk_se")
	assert(top_layer.animation == "walk_se", "Top layer must synchronize to walk_se")
	assert(shoes_layer.animation == "walk_se", "Shoes layer must synchronize to walk_se")
	
	# Test North-West walk synchronization
	character.play_animation("walk_nw")
	assert(character.animated_sprite.animation == "walk_nw", "Base body must play walk_nw")
	assert(hair_layer.animation == "walk_nw", "Hair layer must synchronize to walk_nw")
	assert(top_layer.animation == "walk_nw", "Top layer must synchronize to walk_nw")
	assert(shoes_layer.animation == "walk_nw", "Shoes layer must synchronize to walk_nw")
	
	# Test Idle South-West synchronization
	character.play_animation("idle_sw")
	assert(character.animated_sprite.animation == "idle_sw", "Base body must play idle_sw")
	assert(hair_layer.animation == "idle_sw", "Hair layer must synchronize to idle_sw")
	assert(top_layer.animation == "idle_sw", "Top layer must synchronize to idle_sw")
	assert(shoes_layer.animation == "idle_sw", "Shoes layer must synchronize to idle_sw")
	print("✔ CHECK 5: Multi-layer directional animation synchronized across all active layers.")
	
	# --------------------------------------------------------------------------
	# 6. TEST FRAME-ACCURATE LOCKSTEP SYNCHRONIZATION
	# --------------------------------------------------------------------------
	character.animated_sprite.play("walk_se")
	character.animated_sprite.frame = 2
	character.animated_sprite.frame_progress = 0.5
	character._on_master_frame_changed()
	
	assert(hair_layer.frame == 2, "Hair layer frame must lockstep match master body frame")
	assert(top_layer.frame == 2, "Top layer frame must lockstep match master body frame")
	assert(shoes_layer.frame == 2, "Shoes layer frame must lockstep match master body frame")
	
	character.animated_sprite.frame = 3
	character._on_master_frame_changed()
	assert(hair_layer.frame == 3, "Hair layer frame must advance synchronously to frame 3")
	assert(top_layer.frame == 3, "Top layer frame must advance synchronously to frame 3")
	assert(shoes_layer.frame == 3, "Shoes layer frame must advance synchronously to frame 3")
	print("✔ CHECK 6: Lockstep frame timing synchronization verified between master and modular layers.")
	
	# --------------------------------------------------------------------------
	# 7. TEST LAYER REMOVAL CLEANUP
	# --------------------------------------------------------------------------
	character.remove_visual_layer("hair")
	assert(not character.has_visual_layer("hair"), "Hair layer should be removed from active layers")
	assert(character.has_visual_layer("top"), "Top layer must remain active after removing hair")
	assert(character.has_visual_layer("body"), "Base body layer must remain active")
	print("✔ CHECK 7: Visual layer removal and cleanup verified.")
	
	# --------------------------------------------------------------------------
	# 8. TEST INTEGRATION WITH PLAYER DATA & SAVE SYSTEM PERSISTENCE
	# --------------------------------------------------------------------------
	PlayerData.character_appearance = {
		"age_group": "adult",
		"gender": "neutral",
		"body_id": "default",
		"hair_id": "buzzcut_black",
		"top_id": "hoodie_gray",
		"bottom_id": "denim_jeans",
		"shoes_id": "running_shoes",
		"accessory_id": "silver_watch"
	}
	
	var save_ok = SaveManager.save_game("user://test_mod_char_save.json")
	assert(save_ok, "Saving game with character_appearance must succeed")
	
	PlayerData.character_appearance = {}
	var load_ok = SaveManager.load_game("user://test_mod_char_save.json")
	assert(load_ok, "Loading game with character_appearance must succeed")
	assert(PlayerData.character_appearance.get("hair_id") == "buzzcut_black", "Loaded data must restore hair_id")
	assert(PlayerData.character_appearance.get("top_id") == "hoodie_gray", "Loaded data must restore top_id")
	assert(PlayerData.character_appearance.get("bottom_id") == "denim_jeans", "Loaded data must restore bottom_id")
	assert(PlayerData.character_appearance.get("shoes_id") == "running_shoes", "Loaded data must restore shoes_id")
	assert(PlayerData.character_appearance.get("accessory_id") == "silver_watch", "Loaded data must restore accessory_id")
	print("✔ CHECK 8: PlayerData and SaveManager appearance persistence verified.")
	
	# --------------------------------------------------------------------------
	# 9. TEST WALKING SIMULATION WITH MODULAR LAYERS ACTIVE
	# --------------------------------------------------------------------------
	character.position = Vector2(0, 0)
	character.target_position = Vector2(100, 100)
	character.current_state = character.State.WALKING
	character.current_facing = "se"
	character.play_animation("walk_se")
	
	for step in range(5):
		character._process(0.05)
		assert(top_layer.animation == "walk_se", "Modular top layer must stay in walk_se during roaming")
		assert(shoes_layer.animation == "walk_se", "Modular shoes layer must stay in walk_se during roaming")
		
	print("✔ CHECK 9: Character roaming works seamlessly with modular visual layers attached.")
	
	print("=== ALL MODULAR CHARACTER CUSTOMIZATION CHECKS PASSED SUCCESSFULLY ===")
	get_tree().quit()
