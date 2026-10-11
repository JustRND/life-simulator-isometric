extends Node

var total_assertions: int = 0
var passed_assertions: int = 0

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
	print("🧪 TESTING MONTHLY ACTIVITIES ACCESS & COOLDOWNS")
	print("=======================================================")

	test_monthly_cooldown_helper()
	test_social_media_monthly_cycle()
	test_charity_monthly_cycle()
	test_pet_monthly_cycle()
	test_gym_and_wellness_monthly_cycle()
	test_doctor_monthly_cycle()
	test_save_load_monthly_timestamps()

	print("=======================================================")
	print("🎉 ALL MONTHLY ACTIVITY TESTS PASSED (%d/%d assertions)!" % [passed_assertions, total_assertions])
	print("=======================================================")
	get_tree().quit(0)


func test_monthly_cooldown_helper() -> void:
	print("\n--- 1. Testing PlayerData.is_activity_used_this_month() ---")
	PlayerData.reset()
	PlayerData.in_game_month = 3
	PlayerData.in_game_year = 2026
	PlayerData.age = 15

	# Unused activity
	assert_check(not PlayerData.is_activity_used_this_month(-1, -1, -1), "Unused activity (-1) reports not used")

	# Used this month
	assert_check(PlayerData.is_activity_used_this_month(3, 2026, 15), "Used in Month 3, Year 2026, Age 15 reports used")

	# Used previous month (Month 2, 2026)
	assert_check(not PlayerData.is_activity_used_this_month(2, 2026, 15), "Used in Month 2 reports NOT used this month")

	# Used previous year (Month 3, 2025)
	assert_check(not PlayerData.is_activity_used_this_month(3, 2025, 14), "Used in Month 3 of previous year reports NOT used this month")

	# Unset month or legacy save (-1) should not lock activity for the year
	assert_check(not PlayerData.is_activity_used_this_month(-1, -1, 15), "Unset month (-1) does not lock activity for current age")
	assert_check(not PlayerData.is_activity_used_this_month(-1, -1, 14), "Unset month (-1) reports not used")


func test_social_media_monthly_cycle() -> void:
	print("\n--- 2. Testing Social Media Monthly Posting & Campaigns ---")
	PlayerData.reset()
	PlayerData.age = 16
	PlayerData.in_game_month = 1
	PlayerData.in_game_year = 2026

	var res_acc := SocialMediaManager.create_account(PlayerData, "x")
	assert_check(res_acc["success"], "X account created")

	# First post in month 1
	var post_1 := SocialMediaManager.create_post(PlayerData, "x")
	assert_check(post_1["success"], "Post 1 created in Month 1")

	# Second post in month 1 -> should fail due to monthly post limit
	var post_2 := SocialMediaManager.create_post(PlayerData, "x")
	assert_check(not post_2["success"], "Post 2 rejected in same month 1")
	assert_check("Post Limit" in post_2["message"], "Post 2 message mentions Post Limit")

	# Advance to month 2 in the same year (no age advance!)
	PlayerData.in_game_month = 2
	var post_month_2 := SocialMediaManager.create_post(PlayerData, "x")
	assert_check(post_month_2["success"], "Post in Month 2 succeeds without needing to age up (+1 Year)")

	# Buy followers in month 2
	PlayerData.money = 1000
	var ad_1 := SocialMediaManager.buy_followers(PlayerData, "x", 0)
	assert_check(ad_1["success"], "Ad campaign runs in Month 2")

	var ad_2 := SocialMediaManager.buy_followers(PlayerData, "x", 0)
	assert_check(not ad_2["success"], "Second ad campaign blocked in Month 2")

	# Advance to month 3
	PlayerData.in_game_month = 3
	var ad_month_3 := SocialMediaManager.buy_followers(PlayerData, "x", 0)
	assert_check(ad_month_3["success"], "Ad campaign runs in Month 3 without needing to age up")


func test_charity_monthly_cycle() -> void:
	print("\n--- 3. Testing Charity Monthly Donations ---")
	PlayerData.reset()
	PlayerData.age = 20
	PlayerData.money = 5000
	PlayerData.in_game_month = 5
	PlayerData.in_game_year = 2026

	var c_list: Array = CharityManager.CHARITIES
	var c_id: String = str(c_list[0]["id"])

	# Donate in Month 5
	var d1 := CharityManager.donate(PlayerData, c_id)
	assert_check(d1["success"], "Charity donation succeeds in Month 5")

	# Second donation in Month 5 is blocked
	var d2 := CharityManager.donate(PlayerData, c_id)
	assert_check(not bool(d2.get("allowed", false)), "Second charity donation blocked in Month 5")

	# Advance to Month 6 (same year 2026, same age 20)
	PlayerData.in_game_month = 6
	var d_m6 := CharityManager.donate(PlayerData, c_id)
	assert_check(d_m6["success"], "Charity donation succeeds in Month 6 without advancing age")


func test_pet_monthly_cycle() -> void:
	print("\n--- 4. Testing Pet Adoption & Monthly Interactions ---")
	PlayerData.reset()
	PlayerData.age = 25
	PlayerData.money = 10000
	PlayerData.in_game_month = 4
	PlayerData.in_game_year = 2026

	var dog_shelter_animals: Array = PetManager.get_shelter_animals(PetManager.SOURCE_DOG_SHELTER)
	var pet_spec: Dictionary = dog_shelter_animals[0]

	# Adopt pet in Month 4
	var adopt1 := PetManager.adopt_pet(PlayerData, pet_spec, "Buddy", true)
	assert_check(adopt1["success"], "Adopted Buddy in Month 4")
	assert_check(PlayerData.pets.size() == 1, "Household has 1 pet")

	# Second adoption in Month 4 should be blocked
	var adopt2 := PetManager.adopt_pet(PlayerData, pet_spec, "Max", true)
	assert_check(not adopt2["success"], "Second adoption blocked in Month 4")

	# Interact with pet in Month 4
	var pet_id: String = str(PlayerData.pets[0]["id"])
	var play1 := PetManager.interact_pet(PlayerData, pet_id, "play")
	assert_check(play1["success"], "Played with Buddy in Month 4")

	var play2 := PetManager.interact_pet(PlayerData, pet_id, "play")
	assert_check(not play2["success"], "Second play session with Buddy blocked in Month 4")

	# Advance to Month 5 (same year 2026, age 25)
	PlayerData.in_game_month = 5

	var play_m5 := PetManager.interact_pet(PlayerData, pet_id, "play")
	assert_check(play_m5["success"], "Played with Buddy in Month 5 without needing to age up")

	var adopt_m5 := PetManager.adopt_pet(PlayerData, pet_spec, "Luna", true)
	assert_check(adopt_m5["success"], "Adopted Luna in Month 5 without needing to age up")
	assert_check(PlayerData.pets.size() == 2, "Household has 2 pets")


func test_gym_and_wellness_monthly_cycle() -> void:
	print("\n--- 5. Testing Gym & Wellness Monthly Timestamps ---")
	PlayerData.reset()
	PlayerData.age = 22
	PlayerData.in_game_month = 7
	PlayerData.in_game_year = 2026

	# Simulate Gym workout in Month 7
	PlayerData.last_gym_activity_month = PlayerData.in_game_month
	PlayerData.last_gym_activity_year = PlayerData.in_game_year
	PlayerData.last_gym_activity_age = PlayerData.age

	assert_check(PlayerData.is_activity_used_this_month(PlayerData.last_gym_activity_month, PlayerData.last_gym_activity_year, PlayerData.last_gym_activity_age), "Gym workout locked for Month 7")

	# Advance to Month 8
	PlayerData.in_game_month = 8
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_gym_activity_month, PlayerData.last_gym_activity_year, PlayerData.last_gym_activity_age), "Gym workout unlocked in Month 8")

	# Simulate Salon Makeover in Month 8
	PlayerData.last_salon_activity_month = PlayerData.in_game_month
	PlayerData.last_salon_activity_year = PlayerData.in_game_year
	PlayerData.last_salon_activity_age = PlayerData.age

	assert_check(PlayerData.is_activity_used_this_month(PlayerData.last_salon_activity_month, PlayerData.last_salon_activity_year, PlayerData.last_salon_activity_age), "Salon visit locked for Month 8")

	# Advance to Month 9
	PlayerData.in_game_month = 9
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_salon_activity_month, PlayerData.last_salon_activity_year, PlayerData.last_salon_activity_age), "Salon visit unlocked in Month 9")


func test_doctor_monthly_cycle() -> void:
	print("\n--- 6. Testing Doctor Checkup Monthly Timestamps ---")
	PlayerData.reset()
	PlayerData.age = 30
	PlayerData.in_game_month = 10
	PlayerData.in_game_year = 2026

	# Doctor checkup in Month 10
	PlayerData.last_doctor_checkup_month = PlayerData.in_game_month
	PlayerData.last_doctor_checkup_year = PlayerData.in_game_year
	PlayerData.last_doctor_checkup_age = PlayerData.age

	assert_check(PlayerData.is_activity_used_this_month(PlayerData.last_doctor_checkup_month, PlayerData.last_doctor_checkup_year, PlayerData.last_doctor_checkup_age), "Doctor checkup locked in Month 10")

	# Advance to Month 11
	PlayerData.in_game_month = 11
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_doctor_checkup_month, PlayerData.last_doctor_checkup_year, PlayerData.last_doctor_checkup_age), "Doctor checkup unlocked in Month 11")


func test_save_load_monthly_timestamps() -> void:
	print("\n--- 7. Testing Save & Load Persistence for Monthly Activity Timestamps ---")
	PlayerData.reset()
	PlayerData.first_name = "MonthlyTester"
	PlayerData.age = 28
	PlayerData.in_game_month = 9
	PlayerData.in_game_year = 2026
	PlayerData.last_school_activity_month = 9
	PlayerData.last_school_activity_year = 2026
	PlayerData.last_school_activity_age = 28
	PlayerData.last_gym_activity_month = 9
	PlayerData.last_gym_activity_year = 2026
	PlayerData.last_gym_activity_age = 28
	PlayerData.last_pet_adoption_month = 9
	PlayerData.last_pet_adoption_year = 2026
	PlayerData.last_pet_adoption_age = 28
	PlayerData.last_freelance_pitch_month["client_123"] = 9
	PlayerData.last_freelance_pitch_year["client_123"] = 2026

	# Save game
	SaveManager.save_game()

	# Wipe state
	PlayerData.reset()
	assert_check(PlayerData.last_school_activity_month == -1, "Reset cleared school month timestamp")
	assert_check(PlayerData.last_gym_activity_month == -1, "Reset cleared gym month timestamp")

	# Load game
	SaveManager.load_game()
	assert_check(PlayerData.first_name == "MonthlyTester", "Character first name restored")
	assert_check(PlayerData.last_school_activity_month == 9, "Restored last_school_activity_month = 9")
	assert_check(PlayerData.last_school_activity_year == 2026, "Restored last_school_activity_year = 2026")
	assert_check(PlayerData.last_gym_activity_month == 9, "Restored last_gym_activity_month = 9")
	assert_check(PlayerData.last_gym_activity_year == 2026, "Restored last_gym_activity_year = 2026")
	assert_check(PlayerData.last_pet_adoption_month == 9, "Restored last_pet_adoption_month = 9")
	assert_check(PlayerData.last_freelance_pitch_month.get("client_123") == 9, "Restored freelance pitch month = 9")
