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
	print("==================================================================")
	print("🧪 TESTING GAME-WIDE MONTHLY CADENCE & PARENTS ASK MONEY")
	print("==================================================================")

	test_ask_money_parents_monthly()
	test_doctor_and_mental_health_monthly()
	test_study_and_learning_monthly()
	test_pet_and_asset_interactions_monthly()
	test_overtime_and_childhood_gigs_monthly()
	test_calendar_month_rollover_resets()

	print("==================================================================")
	print("🎉 ALL MONTHLY CADENCE TESTS PASSED (%d/%d assertions)!" % [passed_assertions, total_assertions])
	print("==================================================================")
	get_tree().quit(0)


func test_ask_money_parents_monthly() -> void:
	print("\n--- 1. Testing Asking Parents for Money Monthly ---")
	PlayerData.reset()
	PlayerData.age = 12
	PlayerData.in_game_month = 1
	PlayerData.in_game_year = 2026
	PlayerData.money = 0
	PlayerData.mother_relationship = 80
	PlayerData.father_relationship = 80
	PlayerData.family_wealth = "middle_class"

	# Initially both mother and father have not been asked this month
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_mother_ask_money_month, PlayerData.last_mother_ask_money_year, PlayerData.last_mother_ask_money_age), "Mother can be asked for money initially in Month 1")
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_father_ask_money_month, PlayerData.last_father_ask_money_year, PlayerData.last_father_ask_money_age), "Father can be asked for money initially in Month 1")

	# Ask Mother for money in Month 1
	PlayerData.last_mother_ask_money_month = 1
	PlayerData.last_mother_ask_money_year = 2026
	PlayerData.last_mother_ask_money_age = 12

	# Mother is now locked for Month 1, but Father is still available
	assert_check(PlayerData.is_activity_used_this_month(PlayerData.last_mother_ask_money_month, PlayerData.last_mother_ask_money_year, PlayerData.last_mother_ask_money_age), "Mother is locked for Month 1")
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_father_ask_money_month, PlayerData.last_father_ask_money_year, PlayerData.last_father_ask_money_age), "Father remains available in Month 1")

	# Ask Father for money in Month 1
	PlayerData.last_father_ask_money_month = 1
	PlayerData.last_father_ask_money_year = 2026
	PlayerData.last_father_ask_money_age = 12

	assert_check(PlayerData.is_activity_used_this_month(PlayerData.last_father_ask_money_month, PlayerData.last_father_ask_money_year, PlayerData.last_father_ask_money_age), "Father is locked for Month 1")

	# Advance to Month 2 without changing age!
	PlayerData.in_game_month = 2

	# Both parents should be unlocked for Month 2
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_mother_ask_money_month, PlayerData.last_mother_ask_money_year, PlayerData.last_mother_ask_money_age), "Mother is unlocked in Month 2 without aging up")
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_father_ask_money_month, PlayerData.last_father_ask_money_year, PlayerData.last_father_ask_money_age), "Father is unlocked in Month 2 without aging up")


func test_doctor_and_mental_health_monthly() -> void:
	print("\n--- 2. Testing Doctor & Mental Health Monthly Cadence ---")
	PlayerData.reset()
	PlayerData.age = 20
	PlayerData.in_game_month = 4
	PlayerData.in_game_year = 2026

	# Doctor procedures: Checkup, Vitamin, Surgery, Chemo, Therapy, ER
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_doctor_checkup_month, PlayerData.last_doctor_checkup_year, PlayerData.last_doctor_checkup_age), "Checkup available Month 4")
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_doctor_vitamin_month, PlayerData.last_doctor_vitamin_year, PlayerData.last_doctor_vitamin_age), "Vitamin shot available Month 4")
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_psychologist_month, PlayerData.last_psychologist_year, PlayerData.last_psychologist_age), "Psychologist available Month 4")
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_psychiatrist_month, PlayerData.last_psychiatrist_year, PlayerData.last_psychiatrist_age), "Psychiatrist available Month 4")

	# Use checkup & psychologist in Month 4
	PlayerData.last_doctor_checkup_month = 4
	PlayerData.last_doctor_checkup_year = 2026
	PlayerData.last_doctor_checkup_age = 20

	PlayerData.last_psychologist_month = 4
	PlayerData.last_psychologist_year = 2026
	PlayerData.last_psychologist_age = 20

	assert_check(PlayerData.is_activity_used_this_month(PlayerData.last_doctor_checkup_month, PlayerData.last_doctor_checkup_year, PlayerData.last_doctor_checkup_age), "Checkup locked for Month 4")
	assert_check(PlayerData.is_activity_used_this_month(PlayerData.last_psychologist_month, PlayerData.last_psychologist_year, PlayerData.last_psychologist_age), "Psychologist locked for Month 4")

	# Advance to Month 5
	PlayerData.in_game_month = 5
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_doctor_checkup_month, PlayerData.last_doctor_checkup_year, PlayerData.last_doctor_checkup_age), "Checkup unlocked in Month 5")
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_psychologist_month, PlayerData.last_psychologist_year, PlayerData.last_psychologist_age), "Psychologist unlocked in Month 5")


func test_study_and_learning_monthly() -> void:
	print("\n--- 3. Testing Study & Learning Monthly Cadence ---")
	PlayerData.reset()
	PlayerData.age = 15
	PlayerData.in_game_month = 8
	PlayerData.in_game_year = 2026
	PlayerData.money = 500

	# School study activity
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_school_activity_month, PlayerData.last_school_activity_year, PlayerData.last_school_activity_age), "School study available Month 8")

	PlayerData.last_school_activity_month = 8
	PlayerData.last_school_activity_year = 2026
	PlayerData.last_school_activity_age = 15

	assert_check(PlayerData.is_activity_used_this_month(PlayerData.last_school_activity_month, PlayerData.last_school_activity_year, PlayerData.last_school_activity_age), "School study locked for Month 8")

	# BalanceRules learning activities
	assert_check(not BalanceRules.is_learning_activity_used_this_month(PlayerData, "reading"), "Library reading available in Month 8")
	var l_res := BalanceRules.learn(PlayerData, "reading")
	assert_check("completed" in l_res, "Library reading successfully executed")
	assert_check(BalanceRules.is_learning_activity_used_this_month(PlayerData, "reading"), "Library reading locked for Month 8")

	# Advance to Month 9
	PlayerData.in_game_month = 9
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_school_activity_month, PlayerData.last_school_activity_year, PlayerData.last_school_activity_age), "School study unlocked in Month 9")
	assert_check(not BalanceRules.is_learning_activity_used_this_month(PlayerData, "reading"), "Library reading unlocked in Month 9")


func test_pet_and_asset_interactions_monthly() -> void:
	print("\n--- 4. Testing Pet & Asset Interactions Monthly Cadence ---")
	PlayerData.reset()
	PlayerData.age = 24
	PlayerData.in_game_month = 6
	PlayerData.in_game_year = 2026
	PlayerData.money = 50000

	# 1. Pet
	var dog_shelter_animals: Array = PetManager.get_shelter_animals(PetManager.SOURCE_DOG_SHELTER)
	var pet_spec: Dictionary = dog_shelter_animals[0]
	PetManager.adopt_pet(PlayerData, pet_spec, "Milo", false)
	assert_check(PlayerData.pets.size() == 1, "Milo adopted")
	var pet_id: String = str(PlayerData.pets[0]["id"])

	# Play with Milo
	var p_res1 := PetManager.interact_pet(PlayerData, pet_id, "play")
	assert_check(p_res1["success"], "Played with Milo in Month 6")

	var p_res2 := PetManager.interact_pet(PlayerData, pet_id, "play")
	assert_check(not p_res2["success"], "Second play session with Milo blocked in Month 6")

	# 2. Asset
	var car := {
		"instance_id": "car_001",
		"name": "Apex GT",
		"category": AssetCatalog.CATEGORY_CARS,
		"current_value": 45000,
		"happiness_bonus": 10,
		"last_used_month": -1,
		"last_used_year": -1,
		"last_used_age": -1
	}
	PlayerData.owned_assets.append(car)

	var use_res1 := AssetCatalog.use_asset(PlayerData, "car_001")
	assert_check(use_res1["success"], "Enjoyed joyride in Apex GT in Month 6")

	var use_res2 := AssetCatalog.use_asset(PlayerData, "car_001")
	assert_check(not use_res2["success"], "Second joyride blocked in Month 6")

	# Advance to Month 7
	PlayerData.in_game_month = 7

	var p_res7 := PetManager.interact_pet(PlayerData, pet_id, "play")
	assert_check(p_res7["success"], "Played with Milo in Month 7 without age up")

	var use_res7 := AssetCatalog.use_asset(PlayerData, "car_001")
	assert_check(use_res7["success"], "Joyride in Apex GT succeeds in Month 7 without age up")


func test_overtime_and_childhood_gigs_monthly() -> void:
	print("\n--- 5. Testing Overtime & Childhood Gigs Monthly Cadence ---")
	PlayerData.reset()
	PlayerData.age = 25
	PlayerData.in_game_month = 2
	PlayerData.in_game_year = 2026

	# Overtime in Month 2
	PlayerData.last_overtime_month = 2
	PlayerData.last_overtime_year = 2026
	PlayerData.last_overtime_age = 25

	assert_check(PlayerData.is_activity_used_this_month(PlayerData.last_overtime_month, PlayerData.last_overtime_year, PlayerData.last_overtime_age), "Overtime locked Month 2")

	# Childhood gig in Month 2
	PlayerData.last_childhood_gig_month = 2
	PlayerData.last_childhood_gig_year = 2026
	PlayerData.last_childhood_gig_age = 25

	assert_check(PlayerData.is_activity_used_this_month(PlayerData.last_childhood_gig_month, PlayerData.last_childhood_gig_year, PlayerData.last_childhood_gig_age), "Childhood gig locked Month 2")

	# Advance to Month 3
	PlayerData.in_game_month = 3
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_overtime_month, PlayerData.last_overtime_year, PlayerData.last_overtime_age), "Overtime unlocked Month 3")
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_childhood_gig_month, PlayerData.last_childhood_gig_year, PlayerData.last_childhood_gig_age), "Childhood gig unlocked Month 3")


func test_calendar_month_rollover_resets() -> void:
	print("\n--- 6. Testing Year Rollover (Month 12 -> Month 1) Resets ---")
	PlayerData.reset()
	PlayerData.age = 30
	PlayerData.in_game_month = 12
	PlayerData.in_game_year = 2026

	# Do activities in December 2026
	PlayerData.last_mother_ask_money_month = 12
	PlayerData.last_mother_ask_money_year = 2026
	PlayerData.last_mother_ask_money_age = 30

	PlayerData.last_doctor_checkup_month = 12
	PlayerData.last_doctor_checkup_year = 2026
	PlayerData.last_doctor_checkup_age = 30

	assert_check(PlayerData.is_activity_used_this_month(PlayerData.last_mother_ask_money_month, PlayerData.last_mother_ask_money_year, PlayerData.last_mother_ask_money_age), "Mother ask money locked in Dec 2026")
	assert_check(PlayerData.is_activity_used_this_month(PlayerData.last_doctor_checkup_month, PlayerData.last_doctor_checkup_year, PlayerData.last_doctor_checkup_age), "Doctor checkup locked in Dec 2026")

	# Advance to January 2027
	PlayerData.in_game_month = 1
	PlayerData.in_game_year = 2027

	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_mother_ask_money_month, PlayerData.last_mother_ask_money_year, PlayerData.last_mother_ask_money_age), "Mother ask money unlocked in Jan 2027")
	assert_check(not PlayerData.is_activity_used_this_month(PlayerData.last_doctor_checkup_month, PlayerData.last_doctor_checkup_year, PlayerData.last_doctor_checkup_age), "Doctor checkup unlocked in Jan 2027")
