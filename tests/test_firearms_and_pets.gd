extends Node

func _ready() -> void:
	print("\n=======================================================")
	print("🧪 RUNNING VERIFICATION SUITE: FIREARMS, PETS & SHOPPING")
	print("=======================================================\n")

	var all_ok := true

	# 1. Test Firearms Catalog and Images
	print("--- 1. Testing Firearms Shop Images ---")
	var firearms: Array[Dictionary] = AssetCatalog.get_items_by_category(AssetCatalog.CATEGORY_FIREARMS)
	if firearms.size() != 7:
		print("  ✗ Expected 7 firearms, got %d" % firearms.size())
		all_ok = false
	else:
		print("  ✓ Found all 7 firearms in AssetCatalog.")

	for f in firearms:
		var img_path: String = str(f.get("image_path", ""))
		if img_path == "" or not ResourceLoader.exists(img_path):
			print("  ✗ Firearm image missing: %s -> %s" % [f.get("name", ""), img_path])
			all_ok = false
		else:
			var tex: Texture2D = load(img_path)
			if tex == null:
				print("  ✗ Failed to load firearm image: %s" % img_path)
				all_ok = false
			else:
				print("  ✓ %s: Image verified (%dx%d) at %s" % [f.get("name", ""), tex.get_width(), tex.get_height(), img_path])

	# 2. Test Dog Breed Images
	print("\n--- 2. Testing Dog Breed Images ---")
	var dog_breeds := PetManager.DOG_BREEDS
	if dog_breeds.size() != 26:
		print("  ✗ Expected 26 dog breeds, got %d" % dog_breeds.size())
		all_ok = false
	else:
		print("  ✓ Found all 26 dog breeds.")

	for b in dog_breeds:
		var img_path: String = str(b.get("image_path", ""))
		if img_path == "" or not ResourceLoader.exists(img_path):
			print("  ✗ Dog image missing: %s -> %s" % [b.get("breed", ""), img_path])
			all_ok = false
		else:
			var tex: Texture2D = load(img_path)
			if tex == null:
				print("  ✗ Failed to load dog image: %s" % img_path)
				all_ok = false
			else:
				print("  ✓ Dog [%s]: Image verified (%dx%d)" % [b.get("breed", ""), tex.get_width(), tex.get_height()])

	# 3. Test Cat Breed Images
	print("\n--- 3. Testing Cat Breed Images ---")
	var cat_breeds := PetManager.CAT_BREEDS
	if cat_breeds.size() != 26:
		print("  ✗ Expected 26 cat breeds, got %d" % cat_breeds.size())
		all_ok = false
	else:
		print("  ✓ Found all 26 cat breeds.")

	for b in cat_breeds:
		var img_path: String = str(b.get("image_path", ""))
		if img_path == "" or not ResourceLoader.exists(img_path):
			print("  ✗ Cat image missing: %s -> %s" % [b.get("breed", ""), img_path])
			all_ok = false
		else:
			var tex: Texture2D = load(img_path)
			if tex == null:
				print("  ✗ Failed to load cat image: %s" % img_path)
				all_ok = false
			else:
				print("  ✓ Cat [%s]: Image verified (%dx%d)" % [b.get("breed", ""), tex.get_width(), tex.get_height()])

	# 4. Test Shelter & Fuzzy Match Image Resolution
	print("\n--- 4. Testing Shelter & Crossbreed Image Resolution ---")
	var shelter_dogs: Array[Dictionary] = PetManager.get_shelter_animals(PetManager.SOURCE_DOG_SHELTER)
	for d in shelter_dogs:
		var img: String = str(d.get("image_path", ""))
		if img == "" or not ResourceLoader.exists(img):
			print("  ✗ Shelter dog image failed: %s -> %s" % [d.get("breed", ""), img])
			all_ok = false
		else:
			print("  ✓ Shelter dog '%s' resolved to: %s" % [d.get("breed", ""), img.get_file()])

	var shelter_cats: Array[Dictionary] = PetManager.get_shelter_animals(PetManager.SOURCE_CAT_SHELTER)
	for c in shelter_cats:
		var img: String = str(c.get("image_path", ""))
		if img == "" or not ResourceLoader.exists(img):
			print("  ✗ Shelter cat image failed: %s -> %s" % [c.get("breed", ""), img])
			all_ok = false
		else:
			print("  ✓ Shelter cat '%s' resolved to: %s" % [c.get("breed", ""), img.get_file()])

	# 5. Test Pet Adoption Retains Image
	print("\n--- 5. Testing Pet Adoption with Image Retention ---")
	PlayerData.money = 50000
	PlayerData.bank_savings = 50000
	PlayerData.age = 25
	PlayerData.pets = []
	PlayerData.last_pet_adoption_age = -1

	var sample_dog: Dictionary = dog_breeds[0]
	var adopt_res := PetManager.adopt_pet(PlayerData, sample_dog, "Buddy", false, false, false)
	if not bool(adopt_res.get("success", false)):
		print("  ✗ Pet adoption failed: %s" % adopt_res.get("message", ""))
		all_ok = false
	else:
		var pet_obj: Dictionary = adopt_res.get("pet", {})
		var pet_img: String = str(pet_obj.get("image_path", ""))
		if pet_img == "" or not ResourceLoader.exists(pet_img):
			print("  ✗ Adopted pet missing image_path: %s" % pet_img)
			all_ok = false
		else:
			print("  ✓ Adopted pet '%s' successfully stored image_path: %s" % [pet_obj.get("name", ""), pet_img])

	print("\n=======================================================")
	if all_ok:
		print("🎉 ALL FIREARMS, PETS & SHOPPING TESTS PASSED 100%!")
	else:
		print("❌ SOME TESTS FAILED!")
	print("=======================================================\n")

	get_tree().quit(0 if all_ok else 1)
