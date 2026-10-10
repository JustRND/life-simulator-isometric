extends Node

func _ready() -> void:
	print("\n=======================================================")
	print("🧪 RUNNING RANDOM PET EVENT ADOPTION TEST SUITE")
	print("=======================================================\n")

	_test_basic_events_json_specs()
	_test_stray_dog_rescue_event_flow()
	_test_stray_kitten_storm_event_flow()
	_test_pet_assets_panel_rendering()
	_test_annual_adoption_limit_independence()
	_test_pet_interactions()
	_test_pet_rename()
	_test_yearly_aging_and_save_load()

	print("\n=======================================================")
	print("🎉 ALL RANDOM PET EVENT ADOPTION TESTS PASSED! 100% VERIFIED!")
	print("=======================================================\n")
	get_tree().quit(0)


func _test_basic_events_json_specs() -> void:
	print("--- 1. Testing Event JSON specs in basic_events.json ---")
	var file := FileAccess.open("res://data/events/basic_events.json", FileAccess.READ)
	assert(file != null, "basic_events.json should be readable")
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	assert(data is Array, "basic_events.json root should be Array")

	var found_dog_event := false
	var found_cat_event := false

	for ev in data:
		if ev.get("id") == "stray_dog_rescue":
			found_dog_event = true
			var choices: Array = ev.get("choices", [])
			var adopt_choice: Dictionary = choices[0]
			assert(adopt_choice.has("adopt_pet"), "stray_dog_rescue choice 0 must define adopt_pet")
			var p_spec: Dictionary = adopt_choice["adopt_pet"]
			assert(p_spec.get("type") == "dog", "adopt_pet type must be dog")
			assert(p_spec.get("breed") == "Rescued Puppy", "adopt_pet breed must be Rescued Puppy")
			assert(p_spec.get("icon") == "🐶", "adopt_pet icon must be 🐶")
			assert(int(p_spec.get("price", 0)) == 0, "adopt_pet rescue price must be 0")
			print("  ✓ stray_dog_rescue adopt_pet spec verified.")

		elif ev.get("id") == "stray_kitten_in_storm":
			found_cat_event = true
			var choices: Array = ev.get("choices", [])
			var adopt_choice: Dictionary = choices[0]
			assert(adopt_choice.has("adopt_pet"), "stray_kitten_in_storm choice 0 must define adopt_pet")
			var p_spec: Dictionary = adopt_choice["adopt_pet"]
			assert(p_spec.get("type") == "cat", "adopt_pet type must be cat")
			assert(p_spec.get("breed") == "Rescued Kitten", "adopt_pet breed must be Rescued Kitten")
			assert(p_spec.get("icon") == "🐱", "adopt_pet icon must be 🐱")
			assert(int(p_spec.get("price", 0)) == 0, "adopt_pet rescue price must be 0")
			print("  ✓ stray_kitten_in_storm adopt_pet spec verified.")

	assert(found_dog_event, "stray_dog_rescue event must exist in JSON")
	assert(found_cat_event, "stray_kitten_in_storm event must exist in JSON")


func _test_stray_dog_rescue_event_flow() -> void:
	print("\n--- 2. Testing Stray Dog Rescue Event Choice & Adoption ---")
	PlayerData.reset()
	PlayerData.age = 10
	PlayerData.money = 500
	PlayerData.pets.clear()

	var main_screen = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_screen)

	# Simulate the stray_dog_rescue event appearing
	var dog_event: Dictionary = {}
	for ev in EventManager.events:
		if ev.get("id") == "stray_dog_rescue":
			dog_event = ev
			break

	assert(not dog_event.is_empty(), "dog event must be found in EventManager")
	main_screen.current_event = dog_event
	main_screen.current_event_choices = dog_event.get("choices", [])

	# Choice 0: "Bandage the puppy and convince your family to adopt it"
	main_screen.choose_event_option(0)

	# Verify pet was adopted into PlayerData.pets!
	assert(PlayerData.pets.size() == 1, "Player should now own 1 pet after adopting stray puppy")
	var adopted_puppy: Dictionary = PlayerData.pets[0]
	print("  ✓ Adopted pet ID: %s" % adopted_puppy.get("id"))
	print("  ✓ Adopted pet Name: %s" % adopted_puppy.get("name"))
	print("  ✓ Adopted pet Breed: %s" % adopted_puppy.get("breed"))
	assert(adopted_puppy.get("type") == "dog", "Pet type should be dog")
	assert(str(adopted_puppy.get("name", "")).strip_edges() != "", "Pet should have a non-empty name")
	assert(adopted_puppy.get("icon") == "🐶", "Pet icon should be 🐶")
	assert(int(adopted_puppy.get("age", 0)) == 1, "Pet age should start at 1")
	assert(int(adopted_puppy.get("health", 0)) > 0, "Pet health should be positive")
	assert(int(adopted_puppy.get("happiness", 0)) > 0, "Pet happiness should be positive")

	main_screen.queue_free()


func _test_stray_kitten_storm_event_flow() -> void:
	print("\n--- 3. Testing Stray Kitten Storm Event Choice & Adoption ---")
	# Keep existing puppy and add kitten
	var initial_pet_count = PlayerData.pets.size()
	PlayerData.age = 16
	PlayerData.money = 1000

	var main_screen = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_screen)

	var kitten_event: Dictionary = {}
	for ev in EventManager.events:
		if ev.get("id") == "stray_kitten_in_storm":
			kitten_event = ev
			break

	assert(not kitten_event.is_empty(), "kitten event must be found")
	main_screen.current_event = kitten_event
	main_screen.current_event_choices = kitten_event.get("choices", [])

	# Choice 0: "Bring it inside, feed it, and adopt it"
	main_screen.choose_event_option(0)

	assert(PlayerData.pets.size() == initial_pet_count + 1, "Player should now have +1 pet (total %d)" % (initial_pet_count + 1))
	var adopted_kitten: Dictionary = PlayerData.pets.back()
	print("  ✓ Adopted kitten Name: %s" % adopted_kitten.get("name"))
	print("  ✓ Adopted kitten Breed: %s" % adopted_kitten.get("breed"))
	assert(adopted_kitten.get("type") == "cat", "Pet type should be cat")
	assert(str(adopted_kitten.get("name", "")).strip_edges() != "", "Kitten must have a name")
	assert(adopted_kitten.get("icon") == "🐱", "Kitten icon should be 🐱")

	main_screen.queue_free()


func _test_pet_assets_panel_rendering() -> void:
	print("\n--- 4. Testing Pet Rendering in Assets Panel ---")
	assert(PlayerData.pets.size() >= 2, "Expected at least 2 pets for Assets rendering test")

	var main_screen = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_screen)

	main_screen.update_assets_panel()

	var assets_list = main_screen.assets_list
	assert(assets_list != null, "assets_list node must exist")

	var found_pets_section := false
	var found_pet_names: Array[String] = []

	for child in assets_list.get_children():
		var labels = child.find_children("*", "Label", true, false)
		for lbl in labels:
			var text: String = (lbl as Label).text
			if "OWNED PETS & COMPANIONS" in text:
				found_pets_section = true
			for p in PlayerData.pets:
				if p.get("name") in text and p.get("breed") in text:
					found_pet_names.append(p.get("name"))

	assert(found_pets_section, "Assets panel must render OWNED PETS & COMPANIONS section card")
	print("  ✓ Found OWNED PETS & COMPANIONS section in Assets panel.")
	print("  ✓ Rendered pets in panel: %s" % str(found_pet_names))
	assert(found_pet_names.size() >= 2, "Both adopted pets must be rendered in Assets panel")

	main_screen.queue_free()


func _test_annual_adoption_limit_independence() -> void:
	print("\n--- 5. Testing Annual Adoption Cooldown Independence ---")
	PlayerData.reset()
	PlayerData.age = 18
	PlayerData.money = 2000
	PlayerData.last_pet_adoption_age = -1
	PlayerData.pets.clear()

	# Adopt via random event
	var dog_spec := {
		"type": "dog",
		"species": "Rescued Stray Puppy",
		"breed": "Rescued Puppy",
		"source": "Street Rescue",
		"age": 1,
		"price": 0,
		"upkeep": 140,
		"icon": "🐶"
	}
	var res := PetManager.adopt_pet(PlayerData, dog_spec, "Lucky", false, false, false)
	assert(bool(res.get("success", false)), "Event adoption must succeed")
	assert(PlayerData.pets.size() == 1, "Pet added to PlayerData.pets")
	assert(PlayerData.last_pet_adoption_age == -1, "Event adoption should not burn the annual adoption limit")

	# Player can still adopt from shelter in the same year!
	var shelter_spec := {
		"type": "cat",
		"species": "Domestic Shorthair",
		"breed": "Domestic Shorthair",
		"source": "Cat Shelter",
		"age": 2,
		"price": 0,
		"upkeep": 160,
		"icon": "🐈"
	}
	var shelter_res := PetManager.adopt_pet(PlayerData, shelter_spec, "Mochi", true, true, true)
	assert(bool(shelter_res.get("success", false)), "Shelter adoption should succeed in the same year")
	assert(PlayerData.pets.size() == 2, "Player now has 2 pets")
	assert(PlayerData.last_pet_adoption_age == 18, "Shelter adoption sets annual adoption limit")

	# Second shelter adoption in the same year should be blocked
	var second_shelter_res := PetManager.adopt_pet(PlayerData, shelter_spec, "Mittens", true, true, true)
	assert(not bool(second_shelter_res.get("success", false)), "Second shelter adoption must be blocked by annual limit")
	print("  ✓ Verified: Event adoption does not block subsequent shelter adoption.")


func _test_pet_interactions() -> void:
	print("\n--- 6. Testing Pet Interactions (Play, Walk, Treat, Vet) ---")
	var puppy: Dictionary = PlayerData.pets[0]
	var pet_id: String = str(puppy.get("id"))

	# 1. Play
	var play_res := PetManager.interact_pet(PlayerData, pet_id, "play")
	assert(bool(play_res.get("success", false)), "Play interaction must succeed")
	assert(int(puppy.get("last_play_age")) == PlayerData.age, "last_play_age recorded")

	# Play again in same year should fail
	var play_again := PetManager.interact_pet(PlayerData, pet_id, "play")
	assert(not bool(play_again.get("success", false)), "Play again in same year must fail")

	# 2. Walk
	var walk_res := PetManager.interact_pet(PlayerData, pet_id, "walk")
	assert(bool(walk_res.get("success", false)), "Walk interaction must succeed")

	# 3. Treat
	var treat_res := PetManager.interact_pet(PlayerData, pet_id, "treat")
	assert(bool(treat_res.get("success", false)), "Treat interaction must succeed")

	# 4. Vet
	var vet_res := PetManager.interact_pet(PlayerData, pet_id, "vet")
	assert(bool(vet_res.get("success", false)), "Vet interaction must succeed")

	print("  ✓ All 4 pet interactions (Play, Walk, Treat, Vet) verified.")


func _test_pet_rename() -> void:
	print("\n--- 7. Testing Pet Rename ---")
	var puppy: Dictionary = PlayerData.pets[0]
	var pet_id: String = str(puppy.get("id"))

	var rename_res := PetManager.rename_pet(PlayerData, pet_id, "Sparky")
	assert(bool(rename_res.get("success", false)), "Rename must succeed")
	assert(puppy.get("name") == "Sparky", "Pet name should now be Sparky")
	print("  ✓ Pet successfully renamed to: %s" % puppy.get("name"))

	var empty_rename := PetManager.rename_pet(PlayerData, pet_id, "   ")
	assert(not bool(empty_rename.get("success", false)), "Empty name rename must fail")


func _test_yearly_aging_and_save_load() -> void:
	print("\n--- 8. Testing Yearly Aging Simulation & Save/Load Persistence ---")
	var initial_age: int = int(PlayerData.pets[0].get("age"))

	# Process yearly pets
	var logs := PetManager.process_yearly_pets(PlayerData)
	assert(int(PlayerData.pets[0].get("age")) == initial_age + 1, "Pet age should increment by 1 year")
	print("  ✓ Pet aged successfully from %d to %d" % [initial_age, int(PlayerData.pets[0].get("age"))])

	# Test Save & Load
	SaveManager.save_game()

	var saved_pet_count = PlayerData.pets.size()
	PlayerData.pets.clear()
	assert(PlayerData.pets.is_empty(), "Pets cleared for load test")

	SaveManager.load_game()
	assert(PlayerData.pets.size() == saved_pet_count, "Loaded game should restore all %d pets" % saved_pet_count)
	assert(PlayerData.pets[0].get("name") == "Sparky", "Loaded pet must retain its custom name 'Sparky'")
	print("  ✓ Save and reload verified: Pet persisted across game sessions.")
