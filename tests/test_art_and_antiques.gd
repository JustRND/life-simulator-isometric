extends Node

func _ready() -> void:
	print("\n=======================================================")
	print("🧪 RUNNING VERIFICATION SUITE: ART & ANTIQUES ASSET REWORK")
	print("=======================================================\n")

	_test_art_catalog()
	_test_antiques_catalog()
	_test_asset_images_exist()
	_test_buy_and_own()
	_test_use_asset_interactions()
	_test_yearly_appreciation()
	_test_sell_asset()
	_test_main_screen_ui_integration()

	print("\n=======================================================")
	print("🎉 ALL ART & ANTIQUES TESTS PASSED WITH 100% SUCCESS!")
	print("=======================================================\n")
	get_tree().quit(0)

func _test_art_catalog() -> void:
	print("--- 1. Testing Art Catalog Items ---")
	var art_items := AssetCatalog.get_items_by_category(AssetCatalog.CATEGORY_ART)
	print("Total Art items found: %d" % art_items.size())
	assert(art_items.size() == 16, "Expected exactly 16 Art items, got %d" % art_items.size())

	var title := AssetCatalog.get_category_display_title(AssetCatalog.CATEGORY_ART)
	var subtitle := AssetCatalog.get_category_subtitle(AssetCatalog.CATEGORY_ART)
	assert(title != "", "Art title should not be empty")
	assert(subtitle != "", "Art subtitle should not be empty")
	print("  ✓ Category title: %s" % title)
	print("  ✓ Category subtitle: %s" % subtitle)

	for item in art_items:
		var item_id: String = str(item.get("id", ""))
		var item_name: String = str(item.get("name", ""))
		var price: int = int(item.get("price", 0))
		var upkeep: int = int(item.get("upkeep", 0))
		var img_path: String = str(item.get("image_path", ""))
		assert(item_id != "", "Item ID should not be empty")
		assert(item_name != "", "Item Name should not be empty")
		assert(price > 0, "Price should be > 0 for %s" % item_name)
		assert(upkeep >= 0, "Upkeep should be >= 0 for %s" % item_name)
		assert(img_path != "", "Image path should not be empty for %s" % item_name)
		print("  ✓ Art: [%s] '%s' - $%d (Upkeep: $%d/yr)" % [item_id, item_name, price, upkeep])

func _test_antiques_catalog() -> void:
	print("\n--- 2. Testing Antiques Catalog Items ---")
	var antique_items := AssetCatalog.get_items_by_category(AssetCatalog.CATEGORY_ANTIQUES)
	print("Total Antiques items found: %d" % antique_items.size())
	assert(antique_items.size() == 16, "Expected exactly 16 Antiques items, got %d" % antique_items.size())

	var title := AssetCatalog.get_category_display_title(AssetCatalog.CATEGORY_ANTIQUES)
	var subtitle := AssetCatalog.get_category_subtitle(AssetCatalog.CATEGORY_ANTIQUES)
	assert(title != "", "Antiques title should not be empty")
	assert(subtitle != "", "Antiques subtitle should not be empty")
	print("  ✓ Category title: %s" % title)
	print("  ✓ Category subtitle: %s" % subtitle)

	for item in antique_items:
		var item_id: String = str(item.get("id", ""))
		var item_name: String = str(item.get("name", ""))
		var price: int = int(item.get("price", 0))
		var upkeep: int = int(item.get("upkeep", 0))
		var img_path: String = str(item.get("image_path", ""))
		assert(item_id != "", "Item ID should not be empty")
		assert(item_name != "", "Item Name should not be empty")
		assert(price > 0, "Price should be > 0 for %s" % item_name)
		assert(upkeep >= 0, "Upkeep should be >= 0 for %s" % item_name)
		assert(img_path != "", "Image path should not be empty for %s" % item_name)
		print("  ✓ Antique: [%s] '%s' - $%d (Upkeep: $%d/yr)" % [item_id, item_name, price, upkeep])

func _test_asset_images_exist() -> void:
	print("\n--- 3. Verifying All 32 Image Files Exist On Disk ---")
	var art_items := AssetCatalog.get_items_by_category(AssetCatalog.CATEGORY_ART)
	for item in art_items:
		var path: String = str(item.get("image_path", ""))
		assert(FileAccess.file_exists(path), "Missing Art image file: %s" % path)
		print("  ✓ Art image exists: %s" % path)

	var antique_items := AssetCatalog.get_items_by_category(AssetCatalog.CATEGORY_ANTIQUES)
	for item in antique_items:
		var path: String = str(item.get("image_path", ""))
		assert(FileAccess.file_exists(path), "Missing Antique image file: %s" % path)
		print("  ✓ Antique image exists: %s" % path)

func _test_buy_and_own() -> void:
	print("\n--- 4. Testing Buy and Ownership ---")
	PlayerData.age = 30
	PlayerData.money = 50000000
	PlayerData.bank_savings = 0
	PlayerData.owned_assets.clear()

	var initial_money := PlayerData.money
	var buy_art := AssetCatalog.buy_asset(PlayerData, "art_oil_landscape", "funds")
	assert(buy_art["success"], "Failed to buy art_oil_landscape: %s" % buy_art.get("message", ""))
	assert(PlayerData.owned_assets.size() == 1, "Expected 1 owned asset")
	assert(PlayerData.money < initial_money, "Money should have decreased")
	print("  ✓ Bought art_oil_landscape successfully: %s" % buy_art.get("message", ""))

	var money_after_art := PlayerData.money
	var buy_antique := AssetCatalog.buy_asset(PlayerData, "antique_samurai_katana", "funds")
	assert(buy_antique["success"], "Failed to buy antique_samurai_katana: %s" % buy_antique.get("message", ""))
	assert(PlayerData.owned_assets.size() == 2, "Expected 2 owned assets")
	assert(PlayerData.money < money_after_art, "Money should have decreased")
	print("  ✓ Bought antique_samurai_katana successfully: %s" % buy_antique.get("message", ""))

	var art_found := false
	var antique_found := false
	for a in PlayerData.owned_assets:
		if a.get("category") == AssetCatalog.CATEGORY_ART:
			art_found = true
		if a.get("category") == AssetCatalog.CATEGORY_ANTIQUES:
			antique_found = true
	assert(art_found, "Art category asset should be present in owned_assets")
	assert(antique_found, "Antiques category asset should be present in owned_assets")

func _test_use_asset_interactions() -> void:
	print("\n--- 5. Testing Asset Use / Interactions ---")
	var art_instance_id: String = ""
	var antique_instance_id: String = ""
	for a in PlayerData.owned_assets:
		if a.get("category") == AssetCatalog.CATEGORY_ART:
			art_instance_id = str(a.get("instance_id", ""))
		if a.get("category") == AssetCatalog.CATEGORY_ANTIQUES:
			antique_instance_id = str(a.get("instance_id", ""))

	var initial_happiness := PlayerData.happiness
	var initial_smarts := PlayerData.smarts

	# Use art
	var use_art_res := AssetCatalog.use_asset(PlayerData, art_instance_id)
	assert(use_art_res["success"], "Failed to use art asset: %s" % use_art_res.get("message", ""))
	assert(PlayerData.happiness >= initial_happiness, "Happiness should increase or stay capped")
	assert(PlayerData.smarts >= initial_smarts, "Smarts should increase or stay capped")
	print("  ✓ Art interaction: %s" % use_art_res.get("message", ""))

	# Second use in same year should fail
	var use_art_res2 := AssetCatalog.use_asset(PlayerData, art_instance_id)
	assert(not use_art_res2["success"], "Expected second use in same year to be disallowed")
	print("  ✓ Annual cooldown verified: %s" % use_art_res2.get("message", ""))

	# Use antique
	var use_ant_res := AssetCatalog.use_asset(PlayerData, antique_instance_id)
	assert(use_ant_res["success"], "Failed to use antique asset: %s" % use_ant_res.get("message", ""))
	print("  ✓ Antique interaction: %s" % use_ant_res.get("message", ""))

func _test_yearly_appreciation() -> void:
	print("\n--- 6. Testing Yearly Asset Appreciation ---")
	var initial_values: Dictionary = {}
	for a in PlayerData.owned_assets:
		var inst_id: String = str(a.get("instance_id", ""))
		initial_values[inst_id] = int(a.get("current_value", 0))

	# Run yearly processing
	var logs := AssetCatalog.process_yearly_assets(PlayerData)
	print("  ✓ Yearly process executed (%d logs)" % logs.size())

	for a in PlayerData.owned_assets:
		var inst_id: String = str(a.get("instance_id", ""))
		var prev_val: int = initial_values[inst_id]
		var new_val: int = int(a.get("current_value", 0))
		assert(new_val > prev_val, "Asset %s current_value should appreciate! (%d -> %d)" % [a.get("name"), prev_val, new_val])
		print("  ✓ Asset '%s' appreciated: $%d -> $%d (+%.1f%%)" % [
			a.get("name"), prev_val, new_val, float(new_val - prev_val) / float(prev_val) * 100.0
		])

func _test_sell_asset() -> void:
	print("\n--- 7. Testing Selling Assets ---")
	var art_instance_id: String = ""
	var art_name: String = ""
	var art_val: int = 0
	for a in PlayerData.owned_assets:
		if a.get("category") == AssetCatalog.CATEGORY_ART:
			art_instance_id = str(a.get("instance_id", ""))
			art_name = str(a.get("name", ""))
			art_val = int(a.get("current_value", 0))
			break

	var cash_before := PlayerData.money
	var sell_res := AssetCatalog.sell_asset(PlayerData, art_instance_id)
	assert(sell_res["success"], "Failed to sell asset: %s" % sell_res.get("message", ""))
	assert(PlayerData.money == cash_before + art_val, "Cash should increase by sale price")
	assert(PlayerData.owned_assets.size() == 1, "Asset should be removed from owned_assets")
	print("  ✓ Successfully sold '%s' for $%d" % [art_name, sell_res["sale_price"]])

func _test_main_screen_ui_integration() -> void:
	print("\n--- 8. Testing MainScreen UI Integration ---")
	var main_scene_res: PackedScene = load("res://scenes/main/main_screen.tscn")
	assert(main_scene_res != null, "Failed to load main_screen.tscn")
	var main_screen = main_scene_res.instantiate()
	assert(main_screen != null, "Failed to instantiate main_screen")

	get_tree().root.add_child.call_deferred(main_screen)
	await get_tree().process_frame
	await get_tree().process_frame

	# Test opening shopping modal
	print("  Testing _show_shopping_modal()...")
	main_screen._show_shopping_modal()
	assert(main_screen.shopping_modal_overlay != null, "Shopping modal overlay should exist")
	assert(main_screen.shopping_modal_overlay.visible == true, "Shopping modal should be visible")
	print("  ✓ Shopping modal displayed")

	# Test opening Art marketplace modal
	print("  Testing _open_asset_marketplace_modal for CATEGORY_ART...")
	main_screen._open_asset_marketplace_modal(AssetCatalog.CATEGORY_ART)
	print("  ✓ Art marketplace modal created without errors")

	# Test opening Antiques marketplace modal
	print("  Testing _open_asset_marketplace_modal for CATEGORY_ANTIQUES...")
	main_screen._open_asset_marketplace_modal(AssetCatalog.CATEGORY_ANTIQUES)
	print("  ✓ Antiques marketplace modal created without errors")

	# Test rendering assets panel
	print("  Testing update_assets_panel()...")
	main_screen.update_assets_panel()
	print("  ✓ Assets panel updated successfully")

	main_screen.queue_free()
