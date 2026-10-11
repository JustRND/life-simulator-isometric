extends Node

var total_assertions: int = 0
var passed_assertions: int = 0

const VenueCatalog = preload("res://scripts/venues/venue_catalog.gd")
const VenueManager = preload("res://scripts/venues/venue_manager.gd")

func assert_check(condition: bool, msg: String) -> void:
	total_assertions += 1
	if not condition:
		push_error("❌ ASSERTION FAILED: " + msg)
		print("  ❌ FAILED: " + msg)
		get_tree().quit(1)
		assert(false, msg)
	else:
		passed_assertions += 1
		print("  ✓ " + msg)


func _ready() -> void:
	print("=======================================================")
	print("🧪 TESTING MODULAR SOCIAL VENUES & NIGHTLIFE SYSTEM")
	print("=======================================================")

	test_venue_catalog_integrity()
	test_venue_entry_and_age_restrictions()
	test_menu_purchases_and_transaction_integrity()
	test_companion_dining_and_dates()
	test_intoxication_and_hangover_mechanics()
	test_npc_generation_and_minor_safety()
	test_social_interactions_and_befriending()
	test_save_load_persistence()

	print("=======================================================")
	print("🎉 ALL SOCIAL VENUE TESTS PASSED (%d/%d assertions)!" % [passed_assertions, total_assertions])
	print("=======================================================")
	get_tree().quit(0)


func test_venue_catalog_integrity() -> void:
	print("\n--- 1. Testing VenueCatalog Integrity (8 Categories) ---")
	var categories: Array = VenueCatalog.get_all_categories()
	assert_check(categories.size() == 8, "Exactly 8 venue categories defined")

	var required_cats := [
		"fast_food", "casual_dining", "fine_dining", "cafes",
		"bars_pubs", "nightclubs", "lounges", "entertainment"
	]
	for cat_id in required_cats:
		assert_check(VenueCatalog.CATEGORIES.has(cat_id), "Category '%s' exists in catalog" % cat_id)

	var venues: Array = VenueCatalog.get_all_venues()
	assert_check(venues.size() >= 8, "At least 8 distinct venues defined")

	for v in venues:
		assert_check(v.has("name") and v.has("category") and v.has("min_age"), "Venue '%s' has required headers" % v.get("name", ""))
		assert_check(v.has("menu") and v.menu.size() > 0, "Venue '%s' has non-empty menu" % v.get("name", ""))
		assert_check(v.has("activities") and v.activities.size() > 0, "Venue '%s' has activities" % v.get("name", ""))


func test_venue_entry_and_age_restrictions() -> void:
	print("\n--- 2. Testing Entry Requirements & Age Gates ---")
	PlayerData.reset()
	PlayerData.age = 15 # Minor
	PlayerData.money = 1000

	var bar_venue: Dictionary = VenueCatalog.get_venue("bp_rusty_tap")
	var club_venue: Dictionary = VenueCatalog.get_venue("nc_pulse_2088")
	var burger_venue: Dictionary = VenueCatalog.get_venue("ff_neon_burger")
	var fine_venue: Dictionary = VenueCatalog.get_venue("fd_letoile")

	# Minors blocked from adult venues
	var bar_entry = VenueManager.can_enter_venue(PlayerData, bar_venue)
	assert_check(not bar_entry.allowed, "15yo minor blocked from Bar & Pub")
	assert_check(bar_entry.reason == "age", "Rejection reason is 'age'")

	var club_entry = VenueManager.can_enter_venue(PlayerData, club_venue)
	assert_check(not club_entry.allowed, "15yo minor blocked from Nightclub")

	# Minors allowed in all-ages venues
	var burger_entry = VenueManager.can_enter_venue(PlayerData, burger_venue)
	assert_check(burger_entry.allowed, "15yo minor allowed into Fast-Food")

	# Adult allowed in adult venues
	PlayerData.age = 22
	var adult_bar_entry = VenueManager.can_enter_venue(PlayerData, bar_venue)
	assert_check(adult_bar_entry.allowed, "22yo adult allowed into Bar & Pub")

	var adult_club_entry = VenueManager.can_enter_venue(PlayerData, club_venue)
	assert_check(adult_club_entry.allowed, "22yo adult allowed into Nightclub")

	# Cover charge affordability check
	PlayerData.money = 0
	PlayerData.bank_savings = 0
	var poor_club_entry = VenueManager.can_enter_venue(PlayerData, club_venue)
	assert_check(not poor_club_entry.allowed, "Player cannot enter venue if unable to afford cover charge")
	assert_check(poor_club_entry.reason == "funds", "Rejection reason is 'funds'")


func test_menu_purchases_and_transaction_integrity() -> void:
	print("\n--- 3. Testing Menu Purchases, Funds Debit & Needs Restoration ---")
	PlayerData.reset()
	PlayerData.age = 22
	PlayerData.money = 200
	PlayerData.bank_savings = 0
	PlayerData.hunger = 30.0
	PlayerData.thirst = 30.0
	PlayerData.health = 70
	PlayerData.happiness = 50

	var bar_venue: Dictionary = VenueCatalog.get_venue("bp_rusty_tap")
	var ipa_item: Dictionary = bar_venue.menu[0] # Craft IPA ($9, alc: 15)

	# 1. Successful purchase
	var init_trans_count: int = PlayerData.transaction_history.size()
	var res = VenueManager.order_menu_item(PlayerData, bar_venue, ipa_item, "solo")
	assert_check(res.success, "Successfully purchased Craft IPA")
	assert_check(PlayerData.money == 191, "Player money decreased from $200 to $191")
	assert_check(PlayerData.hunger > 30.0, "Hunger increased after order")
	assert_check(PlayerData.thirst > 30.0, "Thirst increased after drink")
	assert_check(PlayerData.happiness > 50, "Happiness increased after drink")
	assert_check(PlayerData.intoxication_level == 15, "Intoxication level increased by 15")
	assert_check(PlayerData.transaction_history.size() == init_trans_count + 1, "Transaction recorded in history")

	# 2. Underage alcohol attempt
	PlayerData.age = 16
	var underage_res = VenueManager.order_menu_item(PlayerData, bar_venue, ipa_item, "solo")
	assert_check(not underage_res.success, "Underage character denied alcohol purchase")
	assert_check(PlayerData.money == 191, "Money unaffected after denied transaction")

	# 3. Non-alcoholic drinks allowed for minors
	var virgin_item: Dictionary = bar_venue.menu[2] # Virgin Mojito ($8, alc: 0)
	var virgin_res = VenueManager.order_menu_item(PlayerData, bar_venue, virgin_item, "solo")
	assert_check(virgin_res.success, "Minor allowed to buy non-alcoholic refreshment")
	assert_check(PlayerData.money == 183, "Money deducted for non-alcoholic drink")

	# 4. Failed purchase when broke does NOT grant free stats
	PlayerData.money = 2
	PlayerData.bank_savings = 0
	var expensive_wagyu: Dictionary = VenueCatalog.get_venue("fd_letoile").menu[0] # $280
	var cur_hunger: float = PlayerData.hunger
	var broke_res = VenueManager.order_menu_item(PlayerData, VenueCatalog.get_venue("fd_letoile"), expensive_wagyu, "solo")
	assert_check(not broke_res.success, "Purchase rejected due to insufficient funds")
	assert_check(PlayerData.hunger == cur_hunger, "No free hunger restoration when purchase fails")
	assert_check(PlayerData.money == 2, "Funds unchanged on transaction failure")


func test_companion_dining_and_dates() -> void:
	print("\n--- 4. Testing Companion Dining with Friends and Dates ---")
	PlayerData.reset()
	PlayerData.age = 24
	PlayerData.money = 500
	PlayerData.partner = {
		"name": "Aria Thorne",
		"status": "Girlfriend",
		"relationship": 70,
		"happiness": 60,
		"is_alive": true
	}

	var diner_venue: Dictionary = VenueCatalog.get_venue("cr_ramen_house")
	var ramen_item: Dictionary = diner_venue.menu[0] # Tonkotsu Ramen ($22)

	# Date Dining
	var date_res = VenueManager.order_menu_item(PlayerData, diner_venue, ramen_item, "date")
	assert_check(date_res.success, "Date dining succeeded")
	assert_check(date_res.total_price == 44, "Date dining charges for two ($22 x 2 = $44)")
	assert_check(PlayerData.money == 456, "Funds debited $44")
	assert_check(PlayerData.get_partner_relationship() > 70, "Partner relationship increased on dinner date")
	assert_check(PlayerData.partner.happiness > 60, "Partner happiness increased on dinner date")

	# Friend Dining
	var test_friend: Dictionary = {
		"id": "f_123",
		"name": "Kai Mercer",
		"relationship": 50,
		"happiness": 50,
		"is_alive": true
	}
	PlayerData.add_friend(test_friend)
	var friend_res = VenueManager.order_menu_item(PlayerData, diner_venue, ramen_item, "friend", test_friend)
	assert_check(friend_res.success, "Dining with friend succeeded")
	assert_check(friend_res.total_price == 44, "Friend dining treats companion ($44 total)")
	assert_check(PlayerData.get_friend("f_123").relationship > 50, "Friend relationship increased after meal")


func test_intoxication_and_hangover_mechanics() -> void:
	print("\n--- 5. Testing Intoxication Decay & Next-Day Hangover ---")
	PlayerData.reset()
	PlayerData.age = 25
	PlayerData.health = 80
	PlayerData.happiness = 75
	PlayerData.thirst = 90.0

	# Moderate drinking (< 50 intoxication)
	PlayerData.apply_intoxication(30)
	assert_check(PlayerData.intoxication_level == 30, "Intoxication applied to 30")
	var day_1_step = PlayerData.process_daily_venues_and_intoxication()
	assert_check(not day_1_step.hangover_triggered, "No hangover from moderate drinking (<50)")
	assert_check(PlayerData.intoxication_level == 0, "Intoxication sobered up by next day")
	assert_check(not PlayerData.has_hangover, "has_hangover remains false")

	# Heavy drinking (>= 50 intoxication)
	PlayerData.apply_intoxication(65)
	assert_check(PlayerData.intoxication_level == 65, "Heavy intoxication applied")
	var day_2_step = PlayerData.process_daily_venues_and_intoxication()
	assert_check(day_2_step.hangover_triggered, "Hangover triggered next day from heavy drinking (>=50)")
	assert_check(PlayerData.has_hangover, "PlayerData.has_hangover is true")
	assert_check(PlayerData.health < 80, "Health reduced by hangover headache")
	assert_check(PlayerData.happiness < 75, "Happiness reduced by hangover")
	assert_check(PlayerData.thirst < 90.0, "Thirst reduced (dehydration)")

	# Hangover clears on subsequent day
	var day_3_step = PlayerData.process_daily_venues_and_intoxication()
	assert_check(day_3_step.hangover_cleared, "Hangover cleared on the following day")
	assert_check(not PlayerData.has_hangover, "PlayerData.has_hangover is now false")


func test_npc_generation_and_minor_safety() -> void:
	print("\n--- 6. Testing NPC Profile Generation & Minor Protections ---")
	# 1. Minor Player
	PlayerData.reset()
	PlayerData.age = 14
	var cafe_venue: Dictionary = VenueCatalog.get_venue("cf_daily_grind")
	var minor_patron = VenueManager.generate_venue_npc(PlayerData, cafe_venue)

	assert_check(not minor_patron.name.is_empty(), "Generated patron has a name: %s" % minor_patron.name)
	assert_check(minor_patron.age >= 11 and minor_patron.age <= 17, "Patron generated for 14yo minor is a peer youth (Age: %d)" % minor_patron.age)
	assert_check(minor_patron.has("personality"), "Patron has personality: %s" % minor_patron.personality)
	assert_check(minor_patron.has("interests") and minor_patron.interests.size() >= 2, "Patron has defined interests")

	# 2. Romantic Dating Safety Check for Minors
	var date_attempt = VenueManager.socialize_with_npc(PlayerData, minor_patron, "ask_date")
	assert_check(not date_attempt.success, "Minors strictly prohibited from adult romantic dating")
	assert_check("Protection" in date_attempt.message or "minors" in date_attempt.message.to_lower(), "Minor protection message returned")

	# 3. Adult Player
	PlayerData.age = 26
	var adult_patron = VenueManager.generate_venue_npc(PlayerData, cafe_venue)
	assert_check(adult_patron.age >= 18, "Patron generated for adult is an adult (Age: %d)" % adult_patron.age)


func test_social_interactions_and_befriending() -> void:
	print("\n--- 7. Testing Talking, Treating & Befriending NPCs ---")
	PlayerData.reset()
	PlayerData.age = 21
	PlayerData.money = 100
	var pub_venue: Dictionary = VenueCatalog.get_venue("bp_rusty_tap")
	var npc = VenueManager.generate_venue_npc(PlayerData, pub_venue)
	var initial_rel: int = int(npc.relationship)

	# Chat
	var chat_res = VenueManager.socialize_with_npc(PlayerData, npc, "chat")
	assert_check(chat_res.success, "Chat interaction succeeded")
	assert_check(int(npc.relationship) > initial_rel, "Relationship improved after chatting")

	# Buy Drink
	var drink_res = VenueManager.socialize_with_npc(PlayerData, npc, "buy_drink")
	assert_check(drink_res.success, "Treated NPC to refreshment")
	assert_check(PlayerData.money == 88, "Funds deducted ($100 - $12 = $88)")

	# Befriend
	assert_check(not PlayerData.has_friends(), "Friends list initially empty")
	var friend_res = VenueManager.socialize_with_npc(PlayerData, npc, "befriend")
	assert_check(friend_res.success, "Befriend interaction succeeded")
	assert_check(PlayerData.has_friends(), "Player now has friends")
	assert_check(PlayerData.get_friends().size() == 1, "Friends count is 1")
	assert_check(PlayerData.get_friend(npc.id).name == npc.name, "Friend profile stored persistently")


func test_save_load_persistence() -> void:
	print("\n--- 8. Testing Save & Load Persistence for Venues & Friends ---")
	PlayerData.reset()
	PlayerData.first_name = "Alex Vance"
	PlayerData.age = 28
	PlayerData.intoxication_level = 35
	PlayerData.has_hangover = true
	PlayerData.record_venue_visit("bp_rusty_tap", "act_pub_trivia", 10)

	var friend_data := {
		"id": "persisted_friend_1",
		"name": "Elena Rostova",
		"gender": "FEMALE",
		"age": 27,
		"relationship": 75,
		"occupation": "Cyberneticist",
		"is_alive": true
	}
	PlayerData.add_friend(friend_data)

	# Save
	var captured: Dictionary = SaveManager.capture_data()
	assert_check(captured.has("friends") and captured.friends.size() == 1, "Save data captures friends")
	assert_check(captured.intoxication_level == 35, "Save data captures intoxication level")
	assert_check(captured.has_hangover == true, "Save data captures has_hangover")
	assert_check(captured.venue_history.size() == 1, "Save data captures venue history")

	# Reset and Apply
	PlayerData.reset()
	assert_check(PlayerData.friends.is_empty(), "Reset clears friends")
	assert_check(PlayerData.intoxication_level == 0, "Reset clears intoxication")
	assert_check(PlayerData.has_hangover == false, "Reset clears hangover")

	SaveManager.apply_data(captured)
	assert_check(PlayerData.friends.size() == 1, "Restored friends array")
	assert_check(PlayerData.get_friend("persisted_friend_1").name == "Elena Rostova", "Restored friend name")
	assert_check(PlayerData.intoxication_level == 35, "Restored intoxication level")
	assert_check(PlayerData.has_hangover == true, "Restored hangover state")
	assert_check(PlayerData.venue_history.size() == 1, "Restored venue history")
