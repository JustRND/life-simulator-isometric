extends SceneTree

const PlayerDataScript = preload("res://scripts/player/player_data.gd")

func _init() -> void:
	print("--- Running Test Starting Asset & Cozy Starter Home ---")
	test_starting_asset()
	quit()

func test_starting_asset() -> void:
	var player_data = PlayerDataScript.new()
	root.add_child(player_data)

	# 1. Reset player data and check starting assets
	player_data.reset_player()
	assert(player_data.owned_assets.size() >= 1, "Player should start with at least 1 owned asset!")
	
	var starter: Dictionary = player_data.owned_assets[0]
	print("Starting asset found: ", starter.get("name"), " [", starter.get("item_id"), "]")
	assert(starter.get("item_id") == "prop_capsule", "Starter item_id should be prop_capsule")
	assert(starter.get("name") == "Cozy Starter Home", "Starter name should be Cozy Starter Home")
	assert(starter.get("category") == "properties", "Starter category should be properties")
	assert(starter.get("image_path") == "res://assets/items/properties/prop_starter_home.jpg", "Starter image path should point to prop_starter_home.jpg")
	assert(starter.get("condition") == 100, "Starter condition should be 100")
	assert(int(starter.get("current_value")) == 220000, "Starter value should be 220000")
	print("  PASS: Starter asset correctly granted on reset_player()")

	# 2. Check catalog definition
	var cat_item := AssetCatalog.get_item("prop_capsule")
	assert(cat_item.get("name") == "Cozy Starter Home", "Catalog prop_capsule name should be Cozy Starter Home")
	assert(cat_item.get("image_path") == "res://assets/items/properties/prop_starter_home.jpg", "Catalog image path should be prop_starter_home.jpg")
	
	var alias_item := AssetCatalog.get_item("prop_starter_home")
	assert(alias_item.get("name") == "Cozy Starter Home", "Alias prop_starter_home should return Cozy Starter Home")
	print("  PASS: AssetCatalog catalog item and alias verified")

	# 3. Check minor maintenance upkeep exemption (ages 0-17)
	player_data.age = 0
	player_data.money = 0
	player_data.bank_savings = 0
	starter["condition"] = 100
	var logs_age0 = AssetCatalog.process_yearly_assets(player_data)
	assert(starter.get("condition") == 100, "Condition should NOT degrade for minor player (< 18)")
	assert(logs_age0.size() == 0, "No neglect warning should be logged for minor player")
	
	player_data.age = 10
	var logs_age10 = AssetCatalog.process_yearly_assets(player_data)
	assert(starter.get("condition") == 100, "Condition should remain 100 at age 10")
	assert(logs_age10.size() == 0, "No neglect warning logged at age 10")
	print("  PASS: Upkeep waived for minors (ages 0-17)")

	# 4. Check adult maintenance upkeep at age 18
	player_data.age = 18
	player_data.money = 0
	player_data.bank_savings = 0
	var logs_age18 = AssetCatalog.process_yearly_assets(player_data)
	assert(starter.get("condition") < 100, "Condition should degrade for adult player with $0 funds")
	assert(logs_age18.size() > 0, "Maintenance neglect warning should be logged for adult player")
	print("  PASS: Adult maintenance upkeep enforced at age 18+")

	# 5. Check minor cannot sell real estate
	player_data.age = 16
	var sell_attempt = AssetCatalog.sell_asset(player_data, starter.get("instance_id"))
	assert(not sell_attempt.get("success"), "Minor should not be allowed to sell real estate")
	assert(player_data.owned_assets.size() >= 1, "Asset should still be in owned_assets")
	print("  PASS: Minor prevented from selling real estate")

	# 6. Check use_asset for minor vs adult
	player_data.age = 10
	starter["last_used_age"] = -1
	var use_child = AssetCatalog.use_asset(player_data, starter.get("instance_id"))
	assert(use_child.get("success"), "use_asset should succeed")
	assert("relaxing with your family" in use_child.get("message"), "Child relax message should mention family")
	print("  PASS: Child use_asset message verified: ", use_child.get("message"))

	# 7. Check net worth includes starting property
	player_data.money = 500
	player_data.bank_savings = 1000
	starter["current_value"] = 220000
	var nw = player_data.get_net_worth()
	assert(nw >= 220000 + 1500, "Net worth should include starter home value")
	print("  PASS: Net worth calculation verified: $", nw)

	print("--- ALL STARTING ASSET TESTS PASSED! ---")
