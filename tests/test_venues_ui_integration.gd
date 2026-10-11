extends Node

var total_assertions: int = 0
var passed_assertions: int = 0

const MainScreenScene = preload("res://scenes/main/main_screen.tscn")
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
	print("🧪 TESTING SOCIAL VENUES & NIGHTLIFE UI INTEGRATION")
	print("=======================================================")

	PlayerData.reset()
	PlayerData.age = 22
	PlayerData.money = 1500
	PlayerData.bank_savings = 5000
	PlayerData.hunger = 40.0
	PlayerData.thirst = 40.0
	PlayerData.happiness = 60

	var main_screen = MainScreenScene.instantiate()
	add_child(main_screen)
	await get_tree().process_frame

	# 1. Button presence in Activities Panel
	print("\n--- 1. Testing Activities Panel Button ---")
	var act_btn = main_screen.get_node_or_null("ActivitiesPanel/ActMargin/ActContent/ActScroll/ActList/SocialVenuesActItem") as Button
	assert_check(act_btn != null, "SocialVenuesActItem exists in ActList")
	assert_check("Social Venues & Nightlife" in act_btn.text, "Button text contains 'Social Venues & Nightlife'")

	# 2. Triggering the modal
	print("\n--- 2. Opening Social Venues Modal ---")
	main_screen._on_social_venues_item_pressed()
	await get_tree().process_frame
	assert_check(main_screen.social_venues_modal_overlay != null, "social_venues_modal_overlay created")
	assert_check(main_screen.social_venues_modal_overlay.is_visible_in_tree(), "Social venues modal is visible")
	assert_check(GameClock.is_paused, "GameClock paused while browsing venues modal")

	# 3. Switching Categories in Modal
	print("\n--- 3. Category Browser Navigation ---")
	assert_check(main_screen.current_venue_category == "fast_food", "Initial category is fast_food")
	main_screen.current_venue_category = "nightclubs"
	main_screen._show_social_venues_modal()
	await get_tree().process_frame
	assert_check(main_screen.current_venue_category == "nightclubs", "Switched category to nightclubs")

	# 4. Entering Venue
	print("\n--- 4. Entering Venue Detail View ---")
	main_screen.selected_venue_id = "nc_pulse_2088"
	main_screen._show_social_venues_modal()
	await get_tree().process_frame
	assert_check(main_screen.selected_venue_id == "nc_pulse_2088", "Selected venue is Club Pulse 2088")

	# 5. Ordering Drink from Detail View
	print("\n--- 5. Ordering Drink & Checking Needs / Intoxication ---")
	var club_venue: Dictionary = VenueCatalog.get_venue("nc_pulse_2088")
	var cocktail: Dictionary = club_venue.menu[0] # Electric Violet Glow Cocktail ($22, alc: 25)
	var order_res = VenueManager.order_menu_item(PlayerData, club_venue, cocktail, "solo")
	assert_check(order_res.success, "Cocktail ordered successfully")
	assert_check(PlayerData.intoxication_level == 25, "Intoxication is 25")
	assert_check(PlayerData.thirst > 40.0, "Thirst restored")

	# 6. Meeting Patrons & Befriending
	print("\n--- 6. Meeting Patrons & Befriending ---")
	assert_check(PlayerData.friends.is_empty(), "Friends list initially empty")
	var patron = VenueManager.generate_venue_npc(PlayerData, club_venue)
	var befriend_res = VenueManager.socialize_with_npc(PlayerData, patron, "befriend")
	assert_check(befriend_res.success, "Befriended patron")
	assert_check(PlayerData.friends.size() == 1, "Friend added to PlayerData.friends")

	# 7. Updating Relationships Panel with Friends
	print("\n--- 7. Verifying Relationships Panel Friends UI ---")
	main_screen.update_relationships_panel()
	await get_tree().process_frame
	var rel_list = main_screen.get_node_or_null("RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList")
	var hdr = rel_list.get_node_or_null("FriendsHeaderCard")
	var friend_card = rel_list.get_node_or_null("FriendCard_0")
	assert_check(hdr != null, "FriendsHeaderCard exists in Relationships panel")
	assert_check(friend_card != null, "FriendCard_0 rendered for new friend")

	# 8. Closing Modal and Clock Resumption
	print("\n--- 8. Closing Modal & Clock Resumption ---")
	main_screen._close_social_venues_modal()
	await get_tree().process_frame
	assert_check(main_screen.social_venues_modal_overlay == null, "Modal overlay dismissed and cleaned up")
	assert_check(not GameClock.is_paused, "GameClock resumed after closing venues modal")

	main_screen.queue_free()
	await get_tree().process_frame

	print("=======================================================")
	print("🎉 ALL VENUE UI INTEGRATION TESTS PASSED (%d/%d assertions)!" % [passed_assertions, total_assertions])
	print("=======================================================")
	get_tree().quit(0)
