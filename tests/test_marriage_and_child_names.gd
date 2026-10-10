extends Node

const RomanceRules = preload("res://scripts/core/romance_rules.gd")
const RelationshipExtras = preload("res://scripts/core/relationship_extras.gd")

func _ready() -> void:
	print("--- Running Test: Marriage Surnames & Married Child Names ---")

	# Test 1: Family Name Extraction
	PlayerData.reset_player()
	PlayerData.first_name = "Alex Rivera"
	assert(PlayerData.get_family_name() == "Rivera", "Family name should be Rivera")

	# Test 1b: Single name fallback to parents
	PlayerData.first_name = "Alex"
	PlayerData.father_name = "Marcus Vance"
	assert(PlayerData.get_family_name() == "Vance", "Family name fallback to father surname Vance")

	PlayerData.father_name = ""
	PlayerData.mother_name = "Sarah Connor"
	assert(PlayerData.get_family_name() == "Connor", "Family name fallback to mother surname Connor")

	PlayerData.first_name = "Lucas Rivera"
	PlayerData.father_name = "Marcus Rivera"

	# Test 2: Marriage Changes Partner's Surname to Character's Family Name
	PlayerData.age = 22
	PlayerData.money = 50000
	PlayerData.partner = {
		"name": "Emma Watson",
		"gender": "FEMALE",
		"age": 22,
		"relationship": 90,
		"happiness": 70,
		"status": "Fiancée",
		"engaged_age": 21,
		"is_alive": true
	}

	assert(PlayerData.is_married() == false, "Partner is not married yet")
	assert(RomanceRules.can_marry(PlayerData), "Should be eligible to marry")

	var marry_result: String = RomanceRules.marry(PlayerData, 1000, "City Hall Ceremony")
	assert(not marry_result.is_empty(), "Marriage should succeed")
	assert(PlayerData.is_married() == true, "Player should now be married")
	assert(PlayerData.partner["status"] == "Wife", "Status should be Wife")
	assert(PlayerData.get_partner_name() == "Emma Rivera", "Partner's surname must change to Rivera upon marriage! Actual: %s" % PlayerData.get_partner_name())
	print("✔ Test 2 passed: Partner surname changed upon marriage -> %s" % PlayerData.get_partner_name())

	# Test 2b: Multi-token partner name (Mary Jane Watson -> Mary Jane Rivera)
	PlayerData.partner["name"] = "Mary Jane Watson"
	PlayerData.update_partner_family_name_on_marriage()
	assert(PlayerData.get_partner_name() == "Mary Jane Rivera", "Multi-token partner back name should change to Rivera! Actual: %s" % PlayerData.get_partner_name())
	print("✔ Test 2b passed: Multi-token partner name changed -> %s" % PlayerData.get_partner_name())

	# Test 2c: Single name partner before marriage gets family name appended
	PlayerData.partner["name"] = "Chloe"
	PlayerData.update_partner_family_name_on_marriage()
	assert(PlayerData.get_partner_name() == "Chloe Rivera", "Single name partner should get family name appended")
	print("✔ Test 2c passed: Single name partner updated -> %s" % PlayerData.get_partner_name())

	# Test 2d: Partner already having character family name doesn't duplicate
	PlayerData.partner["name"] = "Chloe Rivera"
	PlayerData.update_partner_family_name_on_marriage()
	assert(PlayerData.get_partner_name() == "Chloe Rivera", "Existing surname must not duplicate")
	print("✔ Test 2d passed: Existing surname verified -> %s" % PlayerData.get_partner_name())

	# Test 3: Kids Born While Married Generate With Character's Family Name
	# Case 3a: Single name passed
	var child1: Dictionary = PlayerData.add_player_child("Liam", "MALE", 0)
	assert(child1["name"] == "Liam Rivera", "Married child name must include family name Rivera! Actual: %s" % child1["name"])
	assert(" " in child1["name"], "Child name must never be a single name when married!")
	print("✔ Test 3a passed: Single name child input receives family name -> %s" % child1["name"])

	# Case 3b: Random catalog name with other surname passed (e.g. "Lucas Smith" -> "Lucas Rivera")
	var child2: Dictionary = PlayerData.add_player_child("Lucas Smith", "MALE", 0)
	assert(child2["name"] == "Lucas Rivera", "Child with random surname must have family name replaced! Actual: %s" % child2["name"])
	print("✔ Test 3b passed: Random catalog surname replaced with character family name -> %s" % child2["name"])

	# Case 3c: Existing character family name passed ("Mary Rivera" -> stays "Mary Rivera")
	var child3: Dictionary = PlayerData.add_player_child("Mary Rivera", "FEMALE", 0)
	assert(child3["name"] == "Mary Rivera", "Child with existing family name should stay Mary Rivera! Actual: %s" % child3["name"])
	print("✔ Test 3c passed: Existing character family name preserved -> %s" % child3["name"])

	# Test 4: Pregnancy Delivery while Married Gives Newborn Character's Family Name
	PlayerData.pregnancy = {
		"mother": "Chloe Rivera",
		"other_parent": "Lucas Rivera",
		"due_age": PlayerData.age
	}
	var delivery_result: String = RelationshipExtras.deliver_due_baby(PlayerData, "Sophia", "FEMALE")
	assert(not delivery_result.is_empty(), "Delivery should succeed")
	assert("Sophia Rivera" in delivery_result, "Delivery notification must mention full baby name Sophia Rivera! Actual: %s" % delivery_result)
	var latest_child: Dictionary = PlayerData.children[PlayerData.children.size() - 1]
	assert(latest_child["name"] == "Sophia Rivera", "Delivered baby must have family name Rivera! Actual: %s" % latest_child["name"])
	print("✔ Test 4 passed: Delivered pregnancy baby has family name -> %s" % latest_child["name"])

	# Test 5: Unmarried Child does not force married family name
	PlayerData.partner = {}
	var unmarried_child: Dictionary = PlayerData.add_player_child("Jordan", "MALE", 0)
	assert(unmarried_child["name"] == "Jordan", "Unmarried child name without marriage should remain as provided")
	print("✔ Test 5 passed: Unmarried child remains unaffected -> %s" % unmarried_child["name"])

	print("🎉 ALL MARRIAGE & CHILD NAME TESTS PASSED! 🎉")
	get_tree().quit(0)
