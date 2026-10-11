extends Node

const MainScreenScene = preload("res://scenes/main/main_screen.tscn")
const BirthStoryGenerator = preload("res://scripts/core/birth_story_generator.gd")

func _ready() -> void:
	print("=================================================================")
	print("--- BEGIN LIFE MILESTONES, BIRTH STORY & BLIND BOX TEST SUITE ---")
	print("=================================================================")

	test_birth_story_socioeconomic_and_cancer()
	test_life_milestones_system()
	test_character_profile_milestones_card()
	test_life_log_milestones_sync_to_character_profile()
	test_parental_money_and_anti_spam()
	test_blind_box_no_stat_spoilers()
	test_save_load_milestones_and_birth_fields()

	print("=================================================================")
	print("--- ALL LIFE MILESTONES & BIRTH STORY TESTS PASSED (100%) ---")
	print("=================================================================")
	get_tree().quit(0)


func test_birth_story_socioeconomic_and_cancer() -> void:
	print("1. Testing Birth Story socioeconomic tiers and health conditions...")

	var tiers_seen := {}
	var birthdays_seen := {}
	var cancer_description_verified := false

	# Run multiple profile generations to verify tier distribution & conditions
	for i in range(150):
		var profile = BirthStoryGenerator.generate_profile("Alex", "United States", "FEMALE")
		var tier: String = profile.get("family_wealth", "")
		tiers_seen[tier] = true
		var birth_month: String = str(profile.get("birth_month", ""))
		var birth_day: int = int(profile.get("birth_day", 0))
		var month_index: int = -1
		for month_i in range(BirthStoryGenerator.MONTH_DATA.size()):
			if str(BirthStoryGenerator.MONTH_DATA[month_i]["name"]) == birth_month:
				month_index = month_i
				assert(birth_day >= 1 and birth_day <= int(BirthStoryGenerator.MONTH_DATA[month_i]["days"]), "Generated birthday must be a valid date")
				assert(str(profile.get("zodiac", "")) == BirthStoryGenerator.get_zodiac(month_i + 1, birth_day), "Generated zodiac must match birthday")
		assert(month_index >= 0, "Every new character profile must receive a birthday")
		birthdays_seen["%s %d" % [birth_month, birth_day]] = true

		var desc: String = profile.get("birth_description", "")
		var m_cond: String = profile.get("mother_condition", "")
		var f_cond: String = profile.get("father_condition", "")

		if "cancer" in m_cond.to_lower():
			assert("mother has cancer" in desc.to_lower(), "Description must mention mother has cancer when she has cancer condition!")
			cancer_description_verified = true
		if "cancer" in f_cond.to_lower():
			assert("father has cancer" in desc.to_lower(), "Description must mention father has cancer when he has cancer condition!")
			cancer_description_verified = true

		# Verify education alignment with socioeconomic tier
		var m_edu: String = profile.get("mother_education", "")
		var f_edu: String = profile.get("father_education", "")
		if tier == "poor":
			assert(m_edu in BirthStoryGenerator.POOR_EDU, "Poor mother education should match POOR_EDU")
			assert(f_edu in BirthStoryGenerator.POOR_EDU or f_edu == "N/A", "Poor father education should match POOR_EDU or N/A")
		elif tier == "wealthy":
			assert(m_edu in BirthStoryGenerator.WEALTHY_EDU, "Wealthy mother should have advanced education")
			assert(f_edu in BirthStoryGenerator.WEALTHY_EDU or f_edu == "N/A", "Wealthy father should have advanced education or N/A")

	assert(tiers_seen.has("poor"), "Must generate poor tier")
	assert(tiers_seen.has("middle_class"), "Must generate middle_class tier")
	assert(tiers_seen.has("wealthy"), "Must generate wealthy tier")
	assert(birthdays_seen.size() > 1, "New character profiles should receive randomized birthdays")
	assert(cancer_description_verified, "Cancer condition must appear in birth description across runs")
	print("   ✔ Birth socioeconomic tiers and cancer descriptions verified.")


func test_life_milestones_system() -> void:
	print("2. Testing Life Milestones recording...")

	PlayerData.reset_player()
	PlayerData.age = 18
	PlayerData.grades = 92
	PlayerData.university_name = "Stanford University"
	PlayerData.university_major = "computer_science"
	PlayerData.university_major_title = "Computer Science"
	PlayerData.university_degree = "Bachelor of Science"

	# Test milestone addition and duplicate avoidance
	PlayerData.add_milestone("Born in Tokyo, Japan.", 0, "👶")
	PlayerData.add_milestone("Born in Tokyo, Japan.", 0, "👶") # duplicate
	assert(PlayerData.life_milestones.size() == 1, "Duplicate milestones must not be added")

	# University graduation milestone with honors & GPA
	var gpa: float = clampf((float(PlayerData.grades) / 100.0) * 4.0, 1.0, 4.0)
	var honors := "as a summa cum laude" if gpa >= 3.90 else "as a magna cum laude"
	var uni_milestone := "You graduated from Stanford University %s with a GPA of %.2f." % [honors, gpa]
	PlayerData.add_milestone(uni_milestone, 22, "🎓")

	assert(PlayerData.life_milestones.size() == 2, "Should have 2 milestones")
	assert("Stanford University" in PlayerData.life_milestones[1]["text"], "Milestone must contain university name")
	assert("GPA" in PlayerData.life_milestones[1]["text"], "Milestone must contain GPA")
	assert("cum laude" in PlayerData.life_milestones[1]["text"], "Milestone must contain Latin honors")

	# Career milestones
	PlayerData.add_milestone("Started career as Junior Engineer at Cyberdyne.", 22, "💼")
	PlayerData.add_milestone("Promoted to Lead Architect at Cyberdyne.", 25, "🎖️")
	assert(PlayerData.life_milestones.size() == 4, "Should have 4 milestones")

	# Business and Real Estate milestones
	PlayerData.add_milestone("Founded enterprise 'AeroTech Dynamics'.", 28, "🏢")
	PlayerData.add_milestone("Purchased real estate: Modern Suburban House.", 30, "🏡")
	assert(PlayerData.life_milestones.size() == 6, "Should have 6 milestones")
	print("   ✔ Life milestones added with proper metadata, honors, and GPA formatting.")


func test_character_profile_milestones_card() -> void:
	print("3. Testing Character Profile Milestones card placement...")

	var screen = MainScreenScene.instantiate()
	add_child(screen)

	PlayerData.reset_player()
	PlayerData.age = 25
	PlayerData.add_milestone("Born in London, United Kingdom.", 0, "👶")
	PlayerData.add_milestone("You graduated from Oxford University as a magna cum laude with a GPA of 3.80.", 22, "🎓")

	screen.update_character_panel()

	assert(screen.character_milestones_list != null, "character_milestones_list node must be present")
	var profile_cards = screen.get_node("CharacterPanel/CharacterMargin/CharacterContent/CharacterScroll/ProfileCards")
	var f_card = screen.get_node("CharacterPanel/CharacterMargin/CharacterContent/CharacterScroll/ProfileCards/FinancesCard")
	var m_card = screen.get_node("CharacterPanel/CharacterMargin/CharacterContent/CharacterScroll/ProfileCards/MilestonesCard")

	assert(profile_cards != null, "MilestonesCard must have a parent container")
	assert(f_card != null, "FinancesCard must exist in ProfileCards")
	assert(m_card != null, "MilestonesCard must exist in ProfileCards")
	assert(m_card.get_index() > f_card.get_index(), "MilestonesCard must be placed BELOW FinancesCard!")

	# Verify milestones entries rendered in list
	var entries = screen.character_milestones_list.get_children()
	assert(entries.size() == 2, "Character milestones list must render both milestones")

	screen.queue_free()
	print("   ✔ Character Profile MilestonesCard successfully verified below Finances & Net Worth.")


func test_life_log_milestones_sync_to_character_profile() -> void:
	print("3b. Testing Life Overview milestones synchronization into Character Profile...")

	var screen = MainScreenScene.instantiate()
	add_child(screen)

	PlayerData.reset_player()
	PlayerData.first_name = "Kai Vance"
	PlayerData.age = 22
	PlayerData.birthplace = ""
	PlayerData.life_milestones.clear()

	# Populate life_log with entries like the user's Kai Vance screenshot:
	PlayerData.life_log.append({
		"age": 19,
		"text": "🚀 ENTERPRISE INCORPORATED: You invested $85000 to officially launch 'Vance & Associates Legal'! Business treasury initialized with $10,000 working capital.",
		"kind": "milestone"
	})
	PlayerData.life_log.append({
		"age": 20,
		"text": "You completed Flight School for $6000! You can now take the separate pilot license exam.",
		"kind": "milestone"
	})
	# Duplicate Flight School entry
	PlayerData.life_log.append({
		"age": 20,
		"text": "You completed Flight School for $6000! You can now take the separate pilot license exam.",
		"kind": "milestone"
	})

	# Call update_character_panel()
	screen.update_character_panel()

	# 1. Verify PlayerData.life_milestones was synchronized and duplicate was avoided
	assert(PlayerData.life_milestones.size() == 2, "Milestones must sync from life_log and deduplicate; expected 2, got %d" % PlayerData.life_milestones.size())

	# 2. Check content of synced milestones
	assert(PlayerData.life_milestones[0]["age"] == 19, "First milestone must be at age 19")
	assert(PlayerData.life_milestones[0]["icon"] == "🚀", "First milestone icon must be 🚀")
	assert("Vance & Associates Legal" in PlayerData.life_milestones[0]["text"], "First milestone must contain enterprise name")

	assert(PlayerData.life_milestones[1]["age"] == 20, "Second milestone must be at age 20")
	assert(PlayerData.life_milestones[1]["icon"] == "✈️", "Second milestone icon must be ✈️")
	assert("Flight School" in PlayerData.life_milestones[1]["text"], "Second milestone must contain Flight School")

	# 3. Check character profile rendered list
	var items = screen.character_milestones_list.get_children()
	assert(items.size() == 2, "Rendered list must contain 2 milestone labels")
	assert("🚀 Age 19:" in items[0].text, "Rendered item 0 must show 🚀 Age 19:")
	assert("✈️ Age 20:" in items[1].text, "Rendered item 1 must show ✈️ Age 20:")

	# 4. Check empty birthplace fallback
	assert(screen.character_birthplace.text == "Born in: United States", "Empty birthplace must fallback cleanly")

	# 5. Verify live addition via add_life_log_entry
	PlayerData.age = 23
	PlayerData.add_life_log_entry("📜 LICENSE EXAM PASSED: You paid the $4500 exam fee and officially earned your Commercial Pilot License! Unlocked: Commercial Pilot careers.", "milestone")
	screen.update_character_panel()
	assert(PlayerData.life_milestones.size() == 3, "New log entry with kind 'milestone' must automatically update life_milestones")
	assert(screen.character_milestones_list.get_children().size() == 3, "Profile must now show 3 milestones")

	# 6. Verify Life Overview history panel deduplication
	screen.overview_history_filter = "milestones"
	screen.update_history_panel()
	var history_cards = screen.history_list.get_children()
	assert(history_cards.size() == 3, "Overview history panel must deduplicate consecutive identical entries")

	screen.queue_free()
	print("   ✔ Life Overview milestones synchronization and deduplication into Character Profile verified.")


func test_parental_money_and_anti_spam() -> void:
	print("4. Testing Parental money mechanics and anti-spam...")

	var screen = MainScreenScene.instantiate()
	add_child(screen)

	# 1. Infant age 0-4: Parents NEVER gift money upon aging up, regardless of wealth!
	PlayerData.reset_player()
	PlayerData.age = 0
	PlayerData.money = 0
	PlayerData.family_wealth = "wealthy"
	PlayerData.mother_relationship = 100
	PlayerData.father_relationship = 100

	for i in range(4):
		PlayerData.age = i
		screen._process_relationships_aging()
		assert(PlayerData.money == 0, "Parents must NEVER give money to infants under age 5 upon aging up!")

	# 2. Poor parents test: NEVER give annual money upon aging up
	PlayerData.age = 10
	PlayerData.family_wealth = "poor"
	PlayerData.money = 10
	for i in range(10):
		screen._process_relationships_aging()
	assert(PlayerData.money == 10, "Poor parents must never give annual money upon aging up!")

	# 3. Poor parents ask_money: small amount ($2-$12) and high decline rate (75%)
	var declined_count := 0
	var accepted_count := 0
	for trial in range(30):
		PlayerData.money = 0
		PlayerData.last_mother_ask_money_age = -1
		screen._interact_parent("mother", "ask_money")
		if PlayerData.money == 0:
			declined_count += 1
		else:
			accepted_count += 1
			assert(PlayerData.money >= 2 and PlayerData.money <= 12, "Poor parents should give small amount ($2-$12), got: %d" % PlayerData.money)

	assert(declined_count > accepted_count, "Poor parents should have high decline rate (~75%)")

	# 4. Wealthy parents ask_money: generous amount ($50-$150) and low decline rate (15%)
	PlayerData.family_wealth = "wealthy"
	var wealthy_accepts := 0
	for trial in range(30):
		PlayerData.money = 0
		PlayerData.last_mother_ask_money_age = -1
		screen._interact_parent("mother", "ask_money")
		if PlayerData.money > 0:
			wealthy_accepts += 1
			assert(PlayerData.money >= 50 and PlayerData.money <= 150, "Wealthy parents should give generous amount ($50-$150), got: %d" % PlayerData.money)

	assert(wealthy_accepts > 20, "Wealthy parents should have low decline rate (~15%)")

	screen.queue_free()
	print("   ✔ Parental money rebalancing, anti-spam, and socioeconomic tiers verified.")


func test_blind_box_no_stat_spoilers() -> void:
	print("5. Testing Blind Box design (no stat modifiers in choices, buttons, or activities)...")

	var screen = MainScreenScene.instantiate()
	add_child(screen)

	PlayerData.reset_player()
	PlayerData.age = 22
	PlayerData.money = 50000

	# Test Clinic modal buttons
	screen._show_doctor_modal()
	assert(screen.doctor_modal_overlay != null, "Doctor modal should open")
	var doc_btns = screen.doctor_modal_overlay.find_children("*", "Button", true, false)
	for b in doc_btns:
		var txt := (b as Button).text
		assert(not "[+" in txt and not "Health]" in txt, "Clinic button must not have stat modifier previews like [+8 Health]: '%s'" % txt)
		assert(not "Looks]" in txt and not "Happy]" in txt, "Clinic button must not have stat modifier previews: '%s'" % txt)
	screen.doctor_modal_overlay.queue_free()

	# Test Salon modal buttons
	screen._show_salon_modal()
	assert(screen.salon_modal_overlay != null, "Salon modal should open")
	var salon_btns = screen.salon_modal_overlay.find_children("*", "Button", true, false)
	for b in salon_btns:
		var txt := (b as Button).text
		assert(not "+% Looks" in txt and not "+% Happiness" in txt and not "+%d%%" in txt, "Salon button must not leak stat boosts: '%s'" % txt)
	screen.salon_modal_overlay.queue_free()

	# Test Spa modal buttons
	screen._show_spa_modal()
	assert(screen.spa_modal_overlay != null, "Spa modal should open")
	var spa_btns = screen.spa_modal_overlay.find_children("*", "Button", true, false)
	for b in spa_btns:
		var txt := (b as Button).text
		assert(not "+% Health" in txt and not "+% Happiness" in txt and not "+% Looks" in txt, "Spa button must not leak stat boosts: '%s'" % txt)
	screen.spa_modal_overlay.queue_free()

	screen.queue_free()
	print("   ✔ Blind Box verified: zero stat spoiler previews found in clinic, salon, or spa.")


func test_save_load_milestones_and_birth_fields() -> void:
	print("6. Testing persistence of milestones and birth fields in SaveManager...")

	SaveManager.delete_save()
	PlayerData.reset_player()
	PlayerData.first_name = "Morgan"
	PlayerData.family_wealth = "wealthy"
	PlayerData.mother_education = "Doctorate (Ph.D.)"
	PlayerData.mother_condition = "Stage 2 Lymphoma Cancer"
	PlayerData.father_education = "Master's Degree"
	PlayerData.father_condition = "Hypertension"
	PlayerData.add_milestone("Born in Toronto, Canada.", 0, "👶")
	PlayerData.add_milestone("You graduated from University of Toronto as a cum laude with a GPA of 3.65.", 22, "🎓")

	SaveManager.save_game()

	# Reset player data
	PlayerData.reset_player()
	assert(PlayerData.life_milestones.is_empty(), "Milestones should be empty after reset")
	assert(PlayerData.mother_education != "Doctorate (Ph.D.)", "Mother education should be reset")

	# Restore save
	SaveManager.load_game()
	assert(PlayerData.family_wealth == "wealthy", "family_wealth must persist")
	assert(PlayerData.mother_education == "Doctorate (Ph.D.)", "mother_education must persist")
	assert(PlayerData.mother_condition == "Stage 2 Lymphoma Cancer", "mother_condition must persist")
	assert(PlayerData.father_education == "Master's Degree", "father_education must persist")
	assert(PlayerData.father_condition == "Hypertension", "father_condition must persist")
	assert(PlayerData.life_milestones.size() == 2, "Both life_milestones must persist")
	assert("University of Toronto" in PlayerData.life_milestones[1]["text"], "Milestone content must be preserved")

	SaveManager.delete_save()
	print("   ✔ Persistence of milestones and birth fields successfully verified.")
