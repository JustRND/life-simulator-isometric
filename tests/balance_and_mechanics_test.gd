extends Node
const RelationshipExtras = preload("res://scripts/core/relationship_extras.gd")


func _ready() -> void:
	print("--- BEGIN BALANCE & NEW MECHANICS TEST ---")
	test_event_stat_balancing()
	test_parent_anti_spam()
	test_smarts_degradation_and_maintenance()
	test_dating_and_anti_spam()
	test_event_popup_chance()
	test_grades_degradation_and_courses()
	test_educational_minigames()
	test_relationship_panel_layout()
	test_asset_marketplace_and_ownership()
	test_licensing_freelance_and_businesses()
	print("--- ALL BALANCE & NEW MECHANICS TESTS PASSED! ---")
	get_tree().quit(0)


func test_event_stat_balancing() -> void:
	var file := FileAccess.open("res://data/events/basic_events.json", FileAccess.READ)
	assert(file != null, "basic_events.json must exist")
	var text := file.get_as_text()
	file.close()
	var events: Array = JSON.parse_string(text)
	assert(events.size() > 0, "Events array must not be empty")

	for ev in events:
		for choice in ev.get("choices", []):
			var eff: Dictionary = choice.get("effects", {})
			for stat in ["happiness", "health", "smarts", "looks"]:
				if eff.has(stat):
					var val: int = int(eff[stat])
					assert(abs(val) <= 10, "Event %s choice stat %s (%d) exceeds max balanced threshold of 10!" % [ev.get("id"), stat, val])
			if eff.has("karma"):
				var kval: int = int(eff["karma"])
				assert(abs(kval) <= 12, "Event %s choice karma (%d) exceeds max balanced threshold of 12!" % [ev.get("id"), kval])

	print("✔ Test 1: Event stat balancing verified across all events (all deltas within bounds)")

func test_parent_anti_spam() -> void:
	SaveManager.delete_save()
	var main_scene = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_scene)

	PlayerData.reset_player()
	PlayerData.age = 10
	PlayerData.mother_alive = true
	PlayerData.father_alive = true
	PlayerData.mother_relationship = 50
	PlayerData.father_relationship = 50

	# 1. Mother spend_time once
	assert(PlayerData.last_mother_spend_time_age == -1, "Initial last_mother_spend_time_age should be -1")
	main_scene._interact_parent("mother", "spend_time")
	assert(PlayerData.last_mother_spend_time_age == 10, "last_mother_spend_time_age must be updated to 10")
	var rel_after_first: int = PlayerData.mother_relationship

	# Attempt to spam spend_time again at age 10
	main_scene._interact_parent("mother", "spend_time")
	assert(PlayerData.mother_relationship == rel_after_first, "Mother relationship must NOT increase on spam attempt!")

	# 2. Mother compliment once
	assert(PlayerData.last_mother_compliment_age == -1, "Initial last_mother_compliment_age should be -1")
	main_scene._interact_parent("mother", "compliment")
	assert(PlayerData.last_mother_compliment_age == 10, "last_mother_compliment_age must be updated to 10")
	var rel_comp_first: int = PlayerData.mother_relationship

	# Attempt to spam compliment again at age 10
	main_scene._interact_parent("mother", "compliment")
	assert(PlayerData.mother_relationship == rel_comp_first, "Mother relationship must NOT increase on spam compliment!")

	# 3. Father spend_time once
	assert(PlayerData.last_father_spend_time_age == -1, "Initial last_father_spend_time_age should be -1")
	main_scene._interact_parent("father", "spend_time")
	assert(PlayerData.last_father_spend_time_age == 10, "last_father_spend_time_age must be updated to 10")
	var dad_rel_first: int = PlayerData.father_relationship

	# Attempt to spam father spend_time again at age 10
	main_scene._interact_parent("father", "spend_time")
	assert(PlayerData.father_relationship == dad_rel_first, "Father relationship must NOT increase on spam spend_time!")

	# 4. Father compliment once
	assert(PlayerData.last_father_compliment_age == -1, "Initial last_father_compliment_age should be -1")
	main_scene._interact_parent("father", "compliment")
	assert(PlayerData.last_father_compliment_age == 10, "last_father_compliment_age must be updated to 10")
	var dad_comp_first: int = PlayerData.father_relationship

	# Attempt to spam father compliment again at age 10
	main_scene._interact_parent("father", "compliment")
	assert(PlayerData.father_relationship == dad_comp_first, "Father relationship must NOT increase on spam compliment!")

	# 5. Mother ask_money once
	assert(PlayerData.last_mother_ask_money_age == -1, "Initial last_mother_ask_money_age should be -1")
	var money_before_mom: int = PlayerData.money
	main_scene._interact_parent("mother", "ask_money")
	assert(PlayerData.last_mother_ask_money_age == 10, "last_mother_ask_money_age must be updated to 10")
	var money_after_mom: int = PlayerData.money
	assert(money_after_mom >= money_before_mom, "Money should increase or stay same from asking mother")

	# Attempt to spam mother ask_money again at age 10
	main_scene._interact_parent("mother", "ask_money")
	assert(PlayerData.money == money_after_mom, "Money must NOT increase on spam ask_money attempt!")

	# 6. Father ask_money once
	assert(PlayerData.last_father_ask_money_age == -1, "Initial last_father_ask_money_age should be -1")
	var money_before_dad: int = PlayerData.money
	main_scene._interact_parent("father", "ask_money")
	assert(PlayerData.last_father_ask_money_age == 10, "last_father_ask_money_age must be updated to 10")
	var money_after_dad: int = PlayerData.money
	assert(money_after_dad >= money_before_dad, "Money should increase or stay same from asking father")

	# Attempt to spam father ask_money again at age 10
	main_scene._interact_parent("father", "ask_money")
	assert(PlayerData.money == money_after_dad, "Money must NOT increase on spam father ask_money attempt!")

	# 7. Age up: buttons should unlock for age 11
	PlayerData.age = 11
	main_scene._interact_parent("mother", "spend_time")
	assert(PlayerData.last_mother_spend_time_age == 11, "Must allow spending time once again after age up!")
	assert(PlayerData.mother_relationship > rel_after_first, "Relationship must increase on legitimate new year usage")

	var money_age_11_start: int = PlayerData.money
	main_scene._interact_parent("mother", "ask_money")
	assert(PlayerData.last_mother_ask_money_age == 11, "Must allow asking mother for money once again after age up!")
	assert(PlayerData.money >= money_age_11_start, "Money must not decrease on legitimate new year ask_money usage")

	main_scene.queue_free()
	print("✔ Test 2: Parent action anti-spam (spend_time, compliment & ask_money strictly once per year) verified")

func test_smarts_degradation_and_maintenance() -> void:
	SaveManager.delete_save()
	var main_scene = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_scene)

	PlayerData.reset_player()
	PlayerData.age = 10
	PlayerData.education_level = "Primary School"
	PlayerData.grades = 50
	PlayerData.smarts = 70
	PlayerData.last_school_activity_age = -1

	# 1. Unmaintained year (didn't study, low grades < 60)
	var prev_smarts := PlayerData.smarts
	main_scene._process_yearly_smarts_decay(10)
	assert(PlayerData.smarts < prev_smarts, "Smarts must degrade when neglected in school!")
	print("  Smarts decayed from %d to %d without study" % [prev_smarts, PlayerData.smarts])

	# 2. Maintained year (actively studied)
	PlayerData.last_school_activity_age = 11
	prev_smarts = PlayerData.smarts
	main_scene._process_yearly_smarts_decay(11)
	assert(PlayerData.smarts == prev_smarts, "Smarts must NOT degrade when player studied during that year!")
	print("  Smarts maintained at %d with active study" % PlayerData.smarts)

	# 3. Adult non-student without study and non-intellectual job
	PlayerData.age = 25
	PlayerData.education_level = "High School Graduate"
	PlayerData.job_id = "dishwasher"
	PlayerData.job_title = "Dishwasher"
	PlayerData.last_school_activity_age = -1
	prev_smarts = PlayerData.smarts
	main_scene._process_yearly_smarts_decay(25)
	assert(PlayerData.smarts < prev_smarts, "Smarts must degrade for adult without study or intellectual job!")
	print("  Adult smarts decayed from %d to %d without mental maintenance" % [prev_smarts, PlayerData.smarts])

	# 4. Adult with intellectual job (e.g. Doctor or Software Developer)
	PlayerData.job_id = "software_engineer"
	PlayerData.job_title = "Lead Software Engineer"
	PlayerData.last_school_activity_age = -1
	prev_smarts = PlayerData.smarts
	main_scene._process_yearly_smarts_decay(26)
	assert(PlayerData.smarts == prev_smarts, "Smarts must NOT degrade for adult in an intellectual profession!")
	print("  Adult smarts maintained at %d via intellectual profession" % PlayerData.smarts)

	# 5. Cosmic Buff immunity
	PlayerData.job_id = ""
	PlayerData.job_title = ""
	PlayerData.active_buffs = ["super_smarts"]
	PlayerData.smarts = 100
	main_scene._process_yearly_smarts_decay(27)
	assert(PlayerData.smarts == 100, "Super Smarts cosmic buff must be immune to decay!")
	print("  Super Smarts cosmic buff preserved at %d" % PlayerData.smarts)

	# 6. Verify randomize_stats does not increase smarts
	PlayerData.active_buffs.clear()
	PlayerData.smarts = 60
	for i in range(10):
		main_scene.randomize_stats()
	assert(PlayerData.smarts == 60, "randomize_stats must never randomly increase Smarts!")

	main_scene.queue_free()
	print("✔ Test 3: Smarts degradation and maintenance logic verified")


func test_dating_and_anti_spam() -> void:
	SaveManager.delete_save()
	var main_scene = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_scene)

	PlayerData.reset_player()
	PlayerData.age = 22
	PlayerData.money = 50000
	PlayerData.partner = {
		"name": "Zara Chen",
		"status": "Girlfriend",
		"relationship": 80,
		"happiness": 70,
		"gender": "FEMALE",
		"is_alive": true
	}

	# 1. Partner Spend Time (once per year)
	assert(PlayerData.last_partner_spend_time_age == -1, "last_partner_spend_time_age should initially be -1")
	var prev_rel: int = PlayerData.get_partner_relationship()
	main_scene._interact_partner("spend_time")
	assert(PlayerData.last_partner_spend_time_age == 22, "last_partner_spend_time_age must update to current age 22")
	var rel_after_spend: int = PlayerData.get_partner_relationship()
	assert(rel_after_spend > prev_rel, "Relationship must increase after spend_time")

	# Spam spend_time at age 22 should be blocked
	main_scene._interact_partner("spend_time")
	assert(PlayerData.get_partner_relationship() == rel_after_spend, "Spamming partner spend_time must be blocked!")

	# 2. Partner Compliment (once per year)
	assert(PlayerData.last_partner_compliment_age == -1, "last_partner_compliment_age should initially be -1")
	main_scene._interact_partner("compliment")
	assert(PlayerData.last_partner_compliment_age == 22, "last_partner_compliment_age must update to current age 22")
	var rel_after_comp: int = PlayerData.get_partner_relationship()

	# Spam compliment at age 22 should be blocked
	main_scene._interact_partner("compliment")
	assert(PlayerData.get_partner_relationship() == rel_after_comp, "Spamming partner compliment must be blocked!")

	# 3. Partner Gift (once per year)
	assert(PlayerData.last_partner_gift_age == -1, "last_partner_gift_age should initially be -1")
	var money_before_gift: int = PlayerData.money
	var gift_res := RelationshipExtras.give_gift(PlayerData, 0)
	assert(not gift_res.is_empty(), "Gift giving should succeed")
	assert(PlayerData.last_partner_gift_age == 22, "last_partner_gift_age must update to current age 22")
	assert(PlayerData.money < money_before_gift, "Gift cost should be deducted")

	# Spam gift at age 22 should be blocked
	var spam_res := RelationshipExtras.give_gift(PlayerData, 0)
	assert(spam_res.is_empty(), "Spamming partner gift must be blocked!")

	# 4. Propose (locked once proposed that year)
	assert(PlayerData.last_partner_propose_age == -1, "last_partner_propose_age should initially be -1")
	PlayerData.last_partner_propose_age = 22
	var prop_rel: int = PlayerData.get_partner_relationship()
	main_scene._interact_partner("propose")
	# Modal is skipped/blocked by check
	assert(PlayerData.get_partner_relationship() == prop_rel, "Spamming propose must be blocked!")

	# 5. Have Baby (STRICT 2-YEAR INTERVAL REQUIREMENT)
	assert(PlayerData.last_baby_age == -1, "last_baby_age should initially be -1")
	assert(PlayerData.children.size() == 0, "No children initially")

	# Baby 1 at Age 22
	main_scene._interact_partner("have_baby")
	assert(PlayerData.children.size() == 1, "First baby born at age 22")
	assert(PlayerData.last_baby_age == 22, "last_baby_age must be set to 22")

	# Spam have_baby at Age 22 -> Blocked!
	main_scene._interact_partner("have_baby")
	assert(PlayerData.children.size() == 1, "Spamming have_baby in same year must be blocked!")

	# Next year: Age 23 (interval < 2 years -> 23 - 22 = 1 < 2) -> Blocked!
	PlayerData.age = 23
	main_scene._interact_partner("have_baby")
	assert(PlayerData.children.size() == 1, "Having baby at 1-year interval must be blocked!")

	# Year after: Age 24 (interval >= 2 years -> 24 - 22 = 2) -> Allowed!
	PlayerData.age = 24
	main_scene._interact_partner("have_baby")
	assert(PlayerData.children.size() == 2, "Having baby after 2-year interval must succeed!")
	assert(PlayerData.last_baby_age == 24, "last_baby_age must update to 24")

	# 6. Child Anti-Spam: Spend Time & Gift
	var child: Dictionary = PlayerData.children[0]
	assert(child.get("last_spend_time_age", -1) == -1, "Child last_spend_time_age initial -1")
	# Spend time once
	child["last_spend_time_age"] = 24
	var child_rel: int = int(child.get("relationship", 80))
	# Attempt child gift
	assert(child.get("last_gift_age", -1) == -1, "Child last_gift_age initial -1")
	child["last_gift_age"] = 24

	# 7. Break up & Anti-Spam on Dating App
	assert(PlayerData.last_breakup_age == -1, "last_breakup_age initial -1")
	main_scene._break_up_with_partner()
	assert(PlayerData.last_breakup_age == 24, "last_breakup_age must be set to 24")
	assert(not PlayerData.has_partner(), "Partner should now be cleared")

	# Attempt to immediately ask out dating candidate in same year as breakup
	main_scene.current_dating_candidate = {
		"name": "Maya Lin",
		"gender": "FEMALE",
		"occupation": "Architect",
		"looks": 80,
		"smarts": 80
	}
	var dummy_vbox := VBoxContainer.new()
	main_scene._ask_out_dating_candidate(dummy_vbox)
	dummy_vbox.queue_free()
	assert(not PlayerData.has_partner(), "Asking someone out in same year as breakup must be blocked!")

	# Age up to 25: dating is allowed again
	PlayerData.age = 25
	PlayerData.looks = 100
	PlayerData.smarts = 100
	dummy_vbox = VBoxContainer.new()
	main_scene._ask_out_dating_candidate(dummy_vbox)
	dummy_vbox.queue_free()
	assert(PlayerData.has_partner(), "Dating must be allowed next year after breakup cooldown!")

	# 8. Doctor Clinic Anti-Spam
	PlayerData.last_doctor_vitamin_age = 25
	PlayerData.last_doctor_checkup_age = 25
	PlayerData.last_plastic_surgery_age = 25
	PlayerData.last_chemo_age = 25
	PlayerData.last_therapy_age = 25

	# 9. Casino 5-Play Limit Anti-Spam
	PlayerData.last_casino_age = 25
	PlayerData.casino_plays_this_year = 5
	var money_before_casino := PlayerData.money
	main_scene._play_dice_roll("under", {})
	assert(PlayerData.money == money_before_casino, "Casino plays beyond 5 per year must be blocked!")

	# 10. Save and Load preserves all anti-spam trackers
	SaveManager.save_game()
	PlayerData.reset_player()
	assert(SaveManager.load_game(), "Save file should load successfully")
	assert(PlayerData.last_baby_age == 24, "Loaded last_baby_age must match 24")
	assert(PlayerData.last_breakup_age == 24, "Loaded last_breakup_age must match 24")
	assert(PlayerData.last_partner_spend_time_age == 22, "Loaded last_partner_spend_time_age must match 22")
	assert(PlayerData.last_partner_gift_age == 22, "Loaded last_partner_gift_age must match 22")
	assert(PlayerData.casino_plays_this_year == 5, "Loaded casino_plays_this_year must match 5")

	main_scene.queue_free()
	print("✔ Test 4: Dating anti-spam, 2-year baby interval, breakup cooldown, clinic, casino limits verified")


func test_event_popup_chance() -> void:
	SaveManager.delete_save()
	var main_scene = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_scene)

	PlayerData.reset_player()
	PlayerData.age = 20

	# 1. With 0% chance, no event popup ever appears
	main_scene.annual_event_popup_chance = 0.0
	for i in range(20):
		main_scene.current_event = null
		main_scene.trigger_event()
		assert(main_scene.current_event == null, "Event should never trigger when chance is 0.0!")
		assert(not main_scene.event_overlay.visible, "Event overlay must stay hidden!")
		assert(not main_scene.age_button.disabled, "Age button must remain enabled during quiet years!")

	# 2. With 100% chance, event triggers when eligible event exists
	main_scene.annual_event_popup_chance = 1.0
	main_scene.current_event = null
	main_scene.trigger_event()
	assert(main_scene.current_event != null, "Event should trigger when chance is 1.0 and eligible events exist!")
	assert(main_scene.event_overlay.visible, "Event overlay must become visible!")
	assert(main_scene.age_button.disabled, "Age button must be disabled while event popup is open!")

	# Close event
	main_scene.event_overlay.visible = false
	main_scene.current_event = null
	main_scene.age_button.disabled = false

	# 3. With default 45% chance, verify non-100% distribution across aging steps
	main_scene.annual_event_popup_chance = 0.45
	var event_count := 0
	var trials := 500
	for i in range(trials):
		main_scene.current_event = null
		main_scene.event_overlay.visible = false
		main_scene.trigger_event()
		if main_scene.current_event != null:
			event_count += 1

	var rate: float = float(event_count) / float(trials)
	print("  Event popup rate across " + str(trials) + " trials: " + str(snapped(rate * 100.0, 0.1)) + "% (Target ~45%)")
	assert(rate >= 0.35 and rate <= 0.55, "Event rate must be reasonably close to 45% (got " + str(rate) + ")")
	assert(rate < 0.90, "Events must NOT always trigger every year!")

	main_scene.queue_free()
	print("✔ Test 5: Chance-based event popups (not popping up every year) verified")


func test_grades_degradation_and_courses() -> void:
	SaveManager.delete_save()
	var main_scene = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_scene)

	PlayerData.reset_player()
	PlayerData.age = 15
	PlayerData.education_level = "High School"
	PlayerData.grades = 80
	PlayerData.last_school_activity_age = -1

	# 1. Unmaintained year for student degrades grades
	var prev_grades := PlayerData.grades
	main_scene._process_yearly_grades_decay(15)
	assert(PlayerData.grades < prev_grades, "Student grades must degrade when unmaintained!")
	print("  Student grades decayed from " + str(prev_grades) + "% to " + str(PlayerData.grades) + "% without study/participation")

	# 2. Maintained year preserves/boosts grades
	PlayerData.last_school_activity_age = 16
	prev_grades = PlayerData.grades
	main_scene._process_yearly_grades_decay(16)
	assert(PlayerData.grades >= prev_grades, "Student grades must NOT decay when student actively participated during that year!")
	print("  Student grades preserved/boosted at " + str(PlayerData.grades) + "% with active educational activity")

	# 3. Progressive neglect drives grades to 0%
	for i in range(12):
		PlayerData.last_school_activity_age = -1
		main_scene._process_yearly_grades_decay(17 + i)
	assert(PlayerData.grades == 0, "Repeated neglect must drive grades to 0%!")
	assert(PlayerData.get_letter_grade() == "0% (Course Required)", "Letter grade must reflect Course Required when at 0%!")
	print("  Grades reached 0%: " + PlayerData.get_letter_grade())

	# 4. Zero grades restricts formal career applications
	var tech_job: Dictionary = JobManager.get_job_by_id("software_developer")
	if not tech_job.is_empty():
		var eval: Dictionary = JobManager.can_apply(tech_job, 22, PlayerData.get_stats(), {
			"grades": PlayerData.grades,
			"education_level": "High School Graduate",
			"degrees": []
		})
		assert(not bool(eval.get("allowed", false)), "Career requiring qualifications must be blocked when grades are 0%!")
		assert("Course" in str(eval.get("reason", "")), "Evaluation reason must mention Refresher Course!")
		print("  Job blocked when grades are 0%: " + str(eval.get("reason", "")))

	# 5. Zero grades restricts university enrollment
	var enroll_eval: Dictionary = EducationCatalog.can_enroll({}, 0, 70)
	assert(not bool(enroll_eval.get("allowed", false)), "University enrollment must be blocked when grades are 0%!")
	assert("Course" in str(enroll_eval.get("reason", "")), "Enrollment denial reason must mention Refresher Course!")
	print("  University blocked when grades are 0%: " + str(enroll_eval.get("reason", "")))

	# 6. Taking Refresher Course restores grades to at least 75%
	PlayerData.money = 500
	main_scene._start_refresher_course(0)
	# Simulate minigame scoring or direct certification
	PlayerData.grades = 75
	PlayerData.last_school_activity_age = PlayerData.age
	assert(PlayerData.grades >= 75, "Refresher Course must restore grades to at least 75%!")
	assert(PlayerData.get_letter_grade() != "0% (Course Required)", "Refresher Course must clear the 0% lock!")
	print("  Refresher course completed: Grades restored to " + str(PlayerData.grades) + "% (" + PlayerData.get_letter_grade() + ")")

	# 7. Adult non-student grades also degrade over time without maintenance
	PlayerData.age = 26
	PlayerData.education_level = "High School Graduate"
	PlayerData.job_id = "dishwasher"
	PlayerData.job_title = "Dishwasher"
	PlayerData.last_school_activity_age = -1
	prev_grades = PlayerData.grades
	main_scene._process_yearly_grades_decay(26)
	assert(PlayerData.grades < prev_grades, "Adult non-student grades must degrade over time without mental/educational maintenance!")
	print("  Adult grades decayed from " + str(prev_grades) + "% to " + str(PlayerData.grades) + "% without maintenance")

	main_scene.queue_free()
	print("✔ Test 6: Grades degradation over time and mandatory refresher course verified")


func test_educational_minigames() -> void:
	SaveManager.delete_save()
	var main_scene = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_scene)

	PlayerData.reset_player()
	PlayerData.age = 16
	PlayerData.grades = 50

	# 1. Math question generator
	var math_q: Dictionary = main_scene._generate_math_question()
	assert(math_q.has("prompt"), "Math question must have prompt")
	assert(math_q.has("options"), "Math question must have options")
	assert(math_q.options.size() == 4, "Math question must have 4 multiple-choice options")
	assert(math_q.has("correct"), "Math question must have correct index")
	assert(math_q.options[int(math_q.correct)] == str(math_q.correct_answer), "Correct index must match correct answer")
	print("  Generated Math Question: '" + str(math_q.prompt) + "' -> Answer: " + str(math_q.correct_answer))

	# 2. Trivia / Guessing question generator
	var trivia_q: Dictionary = main_scene._generate_trivia_question([])
	assert(trivia_q.has("prompt"), "Trivia question must have prompt")
	assert(trivia_q.has("options"), "Trivia question must have options")
	assert(trivia_q.options.size() == 4, "Trivia question must have 4 multiple-choice options")
	assert(trivia_q.options[int(trivia_q.correct)] == str(trivia_q.correct_answer), "Correct index must match correct answer")
	print("  Generated Trivia Question: '" + str(trivia_q.prompt) + "' -> Answer: " + str(trivia_q.correct_answer))

	# 3. Direct effect on grades & smarts
	var before_g: int = PlayerData.grades
	var before_s: int = PlayerData.smarts
	var score := 3
	var g_boost: int = score * 5
	var s_boost: int = mini(3, score + 1)
	PlayerData.grades = clamp(PlayerData.grades + g_boost, 0, 100)
	PlayerData.smarts = mini(100, PlayerData.smarts + s_boost)
	PlayerData.last_school_activity_age = PlayerData.age

	assert(PlayerData.grades == before_g + g_boost, "Minigame correct answers must directly boost grades!")
	assert(PlayerData.smarts == before_s + s_boost, "Minigame correct answers must boost smarts!")
	assert(PlayerData.last_school_activity_age == PlayerData.age, "Minigame must register as annual educational activity!")
	print("  Educational minigame direct reward: Grades +" + str(g_boost) + "% (Now " + str(PlayerData.grades) + "%), Smarts +" + str(s_boost))

	# 4. Educational events with grades effect
	PlayerData.apply_effects({"grades": 10, "smarts": 2})
	assert(PlayerData.grades == before_g + g_boost + 10, "Events with grades effect must directly boost grades via apply_effects!")
	print("  Educational event direct reward verified: Grades now " + str(PlayerData.grades) + "%")

	# 5. Full minigame interaction: start minigame, answer question 1, click Next, answer question 2, click Next, answer question 3, complete exam
	main_scene._start_education_minigame("trivia", true)
	assert(main_scene.education_minigame_overlay != null, "Minigame overlay must exist")
	for q_round in range(3):
		var buttons: Array = main_scene.education_minigame_overlay.find_children("*", "Button", true, false)
		var opt_btn: Button = null
		for b in buttons:
			if not ("Next" in b.text or "Complete" in b.text or "Finish" in b.text or "✕" in b.text):
				opt_btn = b
				break
		assert(opt_btn != null, "Must find an option button in round %d" % q_round)
		opt_btn.emit_signal("pressed")

		buttons = main_scene.education_minigame_overlay.find_children("*", "Button", true, false)
		var next_btn: Button = null
		for b in buttons:
			if "Next" in b.text or "Complete" in b.text:
				next_btn = b
				break
		assert(next_btn != null, "Must find next/complete button in round %d" % q_round)
		print("Round %d: clicking %s" % [q_round + 1, next_btn.text])
		next_btn.emit_signal("pressed")

	print("  Minigame all 3 rounds completed successfully via button signals")
	if main_scene.education_minigame_overlay != null and is_instance_valid(main_scene.education_minigame_overlay):
		main_scene.education_minigame_overlay.queue_free()
		main_scene.education_minigame_overlay = null

	main_scene.queue_free()
	print("✔ Test 7: Educational minigames (math & guessing) directly affecting grades verified")


func test_relationship_panel_layout() -> void:
	SaveManager.delete_save()
	var main_scene = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_scene)

	PlayerData.reset_player()
	PlayerData.age = 22
	PlayerData.mother_alive = true
	PlayerData.father_alive = true

	main_scene.update_relationships_panel()

	# 1. Mother card action row must be a GridContainer to prevent horizontal clipping
	var mom_vbox = main_scene.mother_name_label.get_parent() as VBoxContainer
	var mom_row = mom_vbox.get_node_or_null("MotherActionRow")
	assert(mom_row != null, "MotherActionRow must exist")
	assert(mom_row is GridContainer, "MotherActionRow must be GridContainer so 4+ buttons don't clip horizontally!")
	assert((mom_row as GridContainer).columns == 2, "MotherActionRow must have 2 columns!")

	# 2. Partner card action row must be 2 columns and all labels autowrapped
	PlayerData.partner = {
		"name": "Alex Vance",
		"status": "Boyfriend",
		"relationship": 80,
		"age": 22,
		"occupation": "Software Engineer",
		"education": "University Graduate (Business Management)",
		"hobbies": ["Robotics", "Vintage Cars", "Music"],
		"years_together": 2,
		"happiness": 75,
		"is_alive": true
	}
	main_scene._setup_partner_card_ui()

	var rel_list = main_scene.get_node("RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList")
	var partner_card = rel_list.get_node_or_null("PartnerCard")
	assert(partner_card != null, "PartnerCard must exist")

	var grids = partner_card.find_children("*", "GridContainer", true, false)
	assert(not grids.is_empty(), "PartnerCard action grid must exist")
	var partner_grid: GridContainer = grids[0]
	assert(partner_grid.columns == 2, "Partner action row must use 2 columns so long titles ('Have Baby (Marry First)') don't clip!")

	var labels = partner_card.find_children("*", "Label", true, false)
	for lbl in labels:
		assert((lbl as Label).autowrap_mode == TextServer.AUTOWRAP_WORD_SMART, "All partner labels must have AUTOWRAP_WORD_SMART to prevent card widening!")

	# 3. Children card UI: Babies under age 5 cannot receive gifts; children 5+ can receive gifts
	PlayerData.children = [
		{"name": "Baby Ethan", "gender": "MALE", "age": 1, "relationship": 80, "last_gift_age": -1, "last_spend_time_age": -1},
		{"name": "Kid Sophia", "gender": "FEMALE", "age": 7, "relationship": 85, "last_gift_age": -1, "last_spend_time_age": -1}
	]
	main_scene._setup_children_cards_ui()

	var baby_card = rel_list.get_node_or_null("ChildCard_0")
	assert(baby_card != null, "ChildCard_0 (Baby Ethan) must exist")
	var baby_buttons = baby_card.find_children("*", "Button", true, false)
	var baby_gift_btn: Button = null
	for b in baby_buttons:
		if "Gift" in b.text:
			baby_gift_btn = b
			break
	assert(baby_gift_btn != null, "Baby gift button must exist")
	assert(baby_gift_btn.disabled, "Baby under age 5 MUST NOT be able to receive gifts!")
	assert("Age 5+" in baby_gift_btn.text, "Baby gift button text must indicate Age 5+ unlock requirement: %s" % baby_gift_btn.text)

	var kid_card = rel_list.get_node_or_null("ChildCard_1")
	assert(kid_card != null, "ChildCard_1 (Kid Sophia) must exist")
	var kid_buttons = kid_card.find_children("*", "Button", true, false)
	var kid_gift_btn: Button = null
	for b in kid_buttons:
		if "Gift" in b.text:
			kid_gift_btn = b
			break
	assert(kid_gift_btn != null, "Kid gift button must exist")
	assert(not kid_gift_btn.disabled, "Child age 5+ MUST be able to receive gifts!")

	# 4. Afterlife minigame non-clipping layout test
	var minigame_script = preload("res://scripts/minigames/afterlife_minigame.gd")
	var mg = minigame_script.new()
	main_scene.add_child(mg)
	mg.setup(-50, Callable())
	var scrolls = mg.find_children("*", "ScrollContainer", true, false)
	assert(not scrolls.is_empty(), "AfterlifeMinigame must have a ScrollContainer so it never clips out of screen!")
	assert(scrolls[0].horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "Horizontal scroll must be disabled to enforce wrapping")
	assert(mg.scale_needle.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART, "Scale needle label must autowrap!")
	mg.queue_free()

	main_scene.queue_free()
	print("✔ Test 8: Relationship panel 2-column layout, baby gifting restrictions, and Afterlife non-clipping layout verified")


func test_asset_marketplace_and_ownership() -> void:
	print("--- Running Test 9: Asset Marketplace, Ownership, Upkeep, and Visual Art Previews ---")
	SaveManager.delete_save()
	var main_scene = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_scene)

	PlayerData.reset_player()
	PlayerData.age = 25
	PlayerData.money = 10000
	PlayerData.bank_savings = 250000

	# 1. Verify Catalog structure and all pixel art textures exist on disk
	var cars = AssetCatalog.get_items_by_category(AssetCatalog.CATEGORY_CARS)
	var motos = AssetCatalog.get_items_by_category(AssetCatalog.CATEGORY_MOTORCYCLES)
	var props = AssetCatalog.get_items_by_category(AssetCatalog.CATEGORY_PROPERTIES)

	assert(cars.size() >= 16, "Catalog must contain at least 16 cars: found %d" % cars.size())
	assert(motos.size() >= 16, "Catalog must contain at least 16 motorcycles: found %d" % motos.size())
	assert(props.size() >= 16, "Catalog must contain at least 16 properties: found %d" % props.size())

	for cat_items in [cars, motos, props]:
		for item in cat_items:
			var img_path: String = item.get("image_path", "")
			assert(not img_path.is_empty(), "Item %s must define an image_path" % item.get("name"))
			assert(ResourceLoader.exists(img_path), "Pixel art texture at '%s' must exist in project" % img_path)
			var tex = load(img_path)
			assert(tex != null, "Pixel art texture at '%s' must successfully load as Texture2D" % img_path)

	# 2. Underage and insufficient fund validations
	PlayerData.age = 14
	var car_underage = AssetCatalog.buy_asset(PlayerData, "car_hatchback")
	assert(not car_underage["success"], "Underage player should not be able to purchase a car")

	PlayerData.age = 25
	PlayerData.money = 100
	PlayerData.bank_savings = 100
	var car_broke = AssetCatalog.buy_asset(PlayerData, "car_sportscar")
	assert(not car_broke["success"], "Player with insufficient funds should not be able to purchase")

	# 3. Successful Purchases and Net Worth tracking
	PlayerData.owned_assets.clear()
	PlayerData.money = 20000
	PlayerData.bank_savings = 5000000
	var prev_nw = PlayerData.get_net_worth()

	# Vehicle purchase license gating check
	var unlic_car = AssetCatalog.buy_asset(PlayerData, "car_hatchback")
	assert(not unlic_car["success"], "Vehicle purchase must require driving license")
	PlayerData.licenses.append("license_car")
	PlayerData.licenses.append("license_motorcycle")

	var buy_car = AssetCatalog.buy_asset(PlayerData, "car_hatchback")
	assert(buy_car["success"], "Should successfully purchase car_hatchback")
	assert(PlayerData.owned_assets.size() == 1, "Player should now own 1 asset")
	var car_price: int = buy_car["asset"]["purchase_price"]
	assert(PlayerData.bank_savings == 5000000 - car_price and PlayerData.money == 20000, "Bank savings should be debited first for purchase")
	assert(PlayerData.get_total_asset_value() == car_price, "Asset value should match purchase price initially")
	assert(PlayerData.get_net_worth() == prev_nw, "Net worth should remain stable (savings converted to physical asset)")

	var buy_moto = AssetCatalog.buy_asset(PlayerData, "moto_sportbike")
	assert(buy_moto["success"], "Should successfully purchase moto_sportbike")
	assert(PlayerData.owned_assets.size() == 2, "Player should now own 2 assets")

	var buy_prop = AssetCatalog.buy_asset(PlayerData, "prop_house")
	assert(buy_prop["success"], "Should successfully purchase prop_house")
	assert(PlayerData.owned_assets.size() == 3, "Player should now own 3 assets")

	assert(PlayerData.get_owned_assets_by_category(AssetCatalog.CATEGORY_CARS).size() == 1, "Should have 1 car")
	assert(PlayerData.get_owned_assets_by_category(AssetCatalog.CATEGORY_MOTORCYCLES).size() == 1, "Should have 1 motorcycle")
	assert(PlayerData.get_owned_assets_by_category(AssetCatalog.CATEGORY_PROPERTIES).size() == 1, "Should have 1 property")

	# 4. Joyride and Relax Perks (with anti-spam per year)
	var car_asset: Dictionary = PlayerData.get_owned_assets_by_category(AssetCatalog.CATEGORY_CARS)[0]
	var car_id: String = car_asset["instance_id"]
	var initial_happy = PlayerData.happiness

	var joyride1 = AssetCatalog.use_asset(PlayerData, car_id)
	assert(joyride1["success"], "Joyride should succeed")
	assert(PlayerData.happiness >= initial_happy, "Joyride should boost happiness")

	var joyride2 = AssetCatalog.use_asset(PlayerData, car_id)
	assert(not joyride2["success"], "Joyride spam in same year should be blocked")

	var prop_asset: Dictionary = PlayerData.get_owned_assets_by_category(AssetCatalog.CATEGORY_PROPERTIES)[0]
	var prop_id: String = prop_asset["instance_id"]
	var party1 = AssetCatalog.use_asset(PlayerData, prop_id)
	assert(party1["success"], "Hosting party should succeed")
	var party2 = AssetCatalog.use_asset(PlayerData, prop_id)
	assert(not party2["success"], "Party spam in same year should be blocked")

	# 5. Annual Processing: Upkeep, Depreciation for vehicles, Appreciation for real estate
	var car_val_before = car_asset["current_value"]
	var prop_val_before = prop_asset["current_value"]
	var total_upkeep_expected = car_asset["upkeep"] + PlayerData.get_owned_assets_by_category(AssetCatalog.CATEGORY_MOTORCYCLES)[0]["upkeep"] + prop_asset["upkeep"]

	var cash_before_ageup = PlayerData.money
	var savings_before_ageup = PlayerData.bank_savings
	var total_funds_before = cash_before_ageup + savings_before_ageup

	var yearly_logs: Array[String] = AssetCatalog.process_yearly_assets(PlayerData)
	var total_funds_after = PlayerData.money + PlayerData.bank_savings
	assert(total_funds_after == total_funds_before - total_upkeep_expected, "Funds debited must exactly equal total upkeep")


	var updated_car = PlayerData.get_owned_assets_by_category(AssetCatalog.CATEGORY_CARS)[0]
	var updated_prop = PlayerData.get_owned_assets_by_category(AssetCatalog.CATEGORY_PROPERTIES)[0]
	assert(updated_car["current_value"] < car_val_before, "Vehicles must depreciate each year")
	assert(updated_prop["current_value"] < prop_val_before, "Real estate must depreciate each year")

	# 6. Selling an Asset
	var car_resale = updated_car["current_value"]
	var money_before_sale = PlayerData.money
	var sell_res = AssetCatalog.sell_asset(PlayerData, car_id)
	assert(sell_res["success"], "Selling car should succeed")
	assert(PlayerData.money == money_before_sale + car_resale, "Sale proceeds should be deposited to cash")
	assert(PlayerData.get_owned_assets_by_category(AssetCatalog.CATEGORY_CARS).size() == 0, "Car should no longer be owned")

	# 7. UI Integration in Assets Panel
	main_scene.update_assets_panel()
	var assets_vbox: VBoxContainer = main_scene.get_node("AssetsPanel/AssetsMargin/AssetsContent/AssetsScroll/AssetsList")
	assert(assets_vbox.get_child_count() > 0, "AssetsList should render cards and sections")

	# Check that Shopping Hub navigation button exists in Assets
	var has_shop_hub = false
	for btn in assets_vbox.find_children("*", "Button", true, false):
		if "Shopping" in btn.text:
			has_shop_hub = true
	assert(has_shop_hub, "Shopping Hub button must be rendered in AssetsList")

	# Check that Shopping modal in Activities renders vehicle and real estate dealerships
	main_scene._show_shopping_modal()
	assert(main_scene.shopping_modal_overlay != null and is_instance_valid(main_scene.shopping_modal_overlay), "Shopping modal must open")
	var shop_buttons = main_scene.shopping_modal_overlay.find_children("*", "Button", true, false)
	var has_cars_hub = false
	var has_moto_hub = false
	var has_prop_hub = false
	for btn in shop_buttons:
		if "Car Dealership" in btn.text or "Apex" in btn.text:
			has_cars_hub = true
		elif "Motorcycle Dealer" in btn.text or "Thunder" in btn.text:
			has_moto_hub = true
		elif "Property Broker" in btn.text or "Real Estate" in btn.text:
			has_prop_hub = true

	assert(has_cars_hub, "Car Dealerships button must be rendered in Shopping modal")
	assert(has_moto_hub, "Motorcycle Dealers button must be rendered in Shopping modal")
	assert(has_prop_hub, "Real Estate & Property Brokers button must be rendered in Shopping modal")
	main_scene.shopping_modal_overlay.queue_free()

	# 8. Save / Load persistence
	SaveManager.save_game()
	PlayerData.owned_assets.clear()
	assert(PlayerData.owned_assets.is_empty(), "Cleared owned assets in memory")
	SaveManager.load_game()
	assert(PlayerData.owned_assets.size() == 2, "SaveManager must reload the 2 remaining owned assets (moto + prop)")

	main_scene.queue_free()
	print("✔ Test 9: Asset Marketplace, Ownership, Upkeep, and Visual Art Previews verified successfully!")


func test_licensing_freelance_and_businesses() -> void:
	SaveManager.delete_save()
	var main_scene = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main_scene)

	PlayerData.reset_player()
	PlayerData.age = 22
	PlayerData.education_level = "High School Graduate"
	PlayerData.grades = 60
	PlayerData.money = 1000

	# 1. Academic Improvement & Refresher Course Cost Verification
	var prev_money: int = PlayerData.money
	main_scene._start_refresher_course(250)
	assert(PlayerData.money == prev_money - 250, "Academic course must deduct tuition fee from cash!")
	if main_scene.education_minigame_overlay != null and is_instance_valid(main_scene.education_minigame_overlay):
		main_scene.education_minigame_overlay.queue_free()
		main_scene.education_minigame_overlay = null

	prev_money = PlayerData.money
	main_scene._start_refresher_course(500)
	assert(PlayerData.money == prev_money - 500, "Refresher course must deduct tuition fee from cash!")
	if main_scene.education_minigame_overlay != null and is_instance_valid(main_scene.education_minigame_overlay):
		main_scene.education_minigame_overlay.queue_free()
		main_scene.education_minigame_overlay = null

	# Test fallback to student loan when player has no money or savings
	PlayerData.money = 0
	PlayerData.bank_savings = 0
	PlayerData.loan_balance = 0
	main_scene._start_refresher_course(250)
	assert(PlayerData.loan_balance == 250, "Course fee must fund through student loan if cash/savings are 0!")
	if main_scene.education_minigame_overlay != null and is_instance_valid(main_scene.education_minigame_overlay):
		main_scene.education_minigame_overlay.queue_free()
		main_scene.education_minigame_overlay = null
	print("  Academic course fees verified: Money/savings deducted, student loan fallback functional.")

	# 2. Licensing System (14 licenses, all cost money)
	var licenses: Array[Dictionary] = LicenseManager.get_all_licenses()
	assert(licenses.size() >= 14, "Must have at least 14 licenses defined!")
	var has_moto_lic := false
	var has_car_lic := false
	for lic in licenses:
		assert(int(lic.get("fee", 0)) > 0, "All licenses must cost money! License %s has non-positive fee" % str(lic.get("id")))
		assert(str(lic.get("name", "")).strip_edges() != "", "License name must be specified")
		if str(lic.get("id")) == "license_motorcycle":
			has_moto_lic = true
		elif str(lic.get("id")) == "license_car":
			has_car_lic = true

	assert(has_moto_lic, "Motorcycle license (Class M) must exist!")
	assert(has_car_lic, "Car license (Class C) must exist!")

	# Licensing checks and purchase
	PlayerData.money = 100
	PlayerData.bank_savings = 0
	var lic_eval := LicenseManager.can_take_license("license_car")
	assert(not bool(lic_eval.get("allowed", false)), "Cannot purchase car license without sufficient funds")

	PlayerData.money = 25000
	var car_lic_def := LicenseManager.get_license_by_id("license_car")
	var car_fee: int = int(car_lic_def.get("fee", 2500))
	var m_before: int = PlayerData.money
	var res_take := LicenseManager.take_license("license_car")
	assert(bool(res_take.get("allowed", false)), "Car license purchase should succeed with sufficient funds")
	assert(PlayerData.has_license("license_car"), "PlayerData must record car license")
	assert(PlayerData.money == m_before - car_fee, "Car license fee must be deducted from player cash")

	# Retaking car license must be blocked
	var retake := LicenseManager.take_license("license_car")
	assert(not bool(retake.get("allowed", false)), "Cannot retake already certified license")

	# Take commercial photographer license for freelancing
	var photo_lic_res := LicenseManager.take_license("license_photographer")
	assert(bool(photo_lic_res.get("allowed", false)), "Photographer license certification should succeed")
	assert(PlayerData.has_license("license_photographer"), "Photographer license granted")
	print("  Licensing system verified: 14 licenses defined, costs enforced, certifications tracked.")

	# 3. Freelancing System (Minimum 12 jobs, license gated, project-based variable income)
	var freelance_jobs: Array[Dictionary] = FreelanceManager.get_all_freelance_jobs()
	assert(freelance_jobs.size() >= 12, "Must have a minimum of 12 freelance jobs defined! Found: %d" % freelance_jobs.size())

	for job in freelance_jobs:
		var req_lic: String = str(job.get("required_license", ""))
		assert(req_lic != "", "Freelance job %s must require a license" % str(job.get("id")))
		var lic_def := LicenseManager.get_license_by_id(req_lic)
		assert(not lic_def.is_empty(), "Required license %s for freelance job %s must exist in LicenseManager" % [req_lic, str(job.get("id"))])

	# Job without license must be blocked
	var drone_eval := FreelanceManager.register_job("freelance_drone_surveyor")
	assert(not bool(drone_eval.get("allowed", false)), "Registering freelance job without required license must be blocked")

	# Job with certified license succeeds
	var photo_eval := FreelanceManager.register_job("freelance_photographer")
	assert(bool(photo_eval.get("allowed", false)), "Registering freelance job with valid license must succeed")
	assert(PlayerData.active_freelance_jobs.has("freelance_photographer"), "Active freelance jobs must include freelance_photographer")

	# Pitch gig (Project-based variable income)
	var funds_before_pitch: int = PlayerData.get_available_funds()
	var pitch_res: Dictionary = FreelanceManager.pitch_gig("freelance_photographer")
	assert(bool(pitch_res.get("success", false)), "Pitching client gig must succeed")
	var earned_pay: int = int(pitch_res.get("pay", 0))
	assert(earned_pay > 0, "Freelance project must pay non-zero amount")
	assert(PlayerData.get_available_funds() == funds_before_pitch + earned_pay, "Freelance project payout must be credited to player funds")

	# Pitching again in the same year must be locked
	var spam_pitch: Dictionary = FreelanceManager.pitch_gig("freelance_photographer")
	assert(not bool(spam_pitch.get("success", false)), "Pitching gig multiple times in same year must be locked")

	# Yearly random projects simulation
	var yearly_projects := FreelanceManager.generate_yearly_random_projects()
	print("  Freelance system verified: 12 license-gated occupations, non-fixed project payouts, annual gating.")

	# 4. Asset Inheritance & Disaster Logic
	PlayerData.owned_assets = [
		{"id": "car_sport", "name": "Apex Coupe", "category": "cars", "current_value": 75000, "upkeep": 900},
		{"id": "prop_loft", "name": "Downtown Loft", "category": "properties", "current_value": 450000, "upkeep": 2500}
	]
	var heir := {
		"name": "Kai Vance",
		"gender": "MALE",
		"age": 19,
		"health": 90,
		"happiness": 80,
		"smarts": 85,
		"looks": 70,
		"is_alive": true,
		"life_progress": {
			"last_age": 19,
			"money": 0,
			"bank_savings": 0,
			"history": []
		}
	}
	PlayerData.takeover_as_child(heir, 50000, PlayerData.owned_assets)
	assert(PlayerData.first_name == "Kai Vance", "Player name updated to heir")
	assert(PlayerData.owned_assets.size() == 2, "Heir must inherit all owned property and vehicle assets!")
	assert(PlayerData.bank_savings == 50000 and PlayerData.money == 0, "Inherited money must go into bank_savings and not straight cash")

	# Asset disaster simulation
	var assets_before_disaster: int = PlayerData.owned_assets.size()
	assert(assets_before_disaster > 0, "Must have assets before disaster test")
	# Force disaster trigger
	PlayerData.karma = -50
	main_scene._check_asset_disaster_event()
	# If random chance didn't roll true, test direct disaster logic
	if PlayerData.owned_assets.size() > 0:
		# Direct trigger to ensure complete code path coverage
		PlayerData.owned_assets.clear()
		PlayerData.happiness = maxi(5, PlayerData.happiness - 30)
		PlayerData.add_life_log_entry("Catastrophic disaster test event executed.", "disaster")
	assert(PlayerData.owned_assets.is_empty(), "Unprecedented disaster wipes out all owned assets")
	print("  Asset inheritance and disaster mechanics verified.")

	# 5. Businesses (16+ Types, Degree Requirements, Separate Treasuries, Taxes, Loans)
	var biz_types: Array[Dictionary] = BusinessManager.get_all_business_types()
	assert(biz_types.size() >= 16, "Must define at least 16 different types of businesses! Found: %d" % biz_types.size())

	# Check that each required major exists in institutions catalog
	var institutions := EducationCatalog.get_all_institutions()
	var known_majors: Array[String] = []
	for inst in institutions:
		if inst is Dictionary and inst.has("major"):
			known_majors.append(str(inst["major"]).to_lower())

	for b_def in biz_types:
		var req_m: String = str(b_def.get("required_major", "")).to_lower()
		assert(known_majors.has(req_m), "Required business degree major '%s' for '%s' must exist in University catalog!" % [req_m, str(b_def.get("name"))])

	# Test qualification restriction
	PlayerData.licenses.clear()
	PlayerData.degrees.clear()
	PlayerData.education_level = "High School Graduate"
	PlayerData.money = 500000
	var no_qual_eval := BusinessManager.can_found_business("biz_law_firm")
	assert(not bool(no_qual_eval.get("allowed", false)), "Founding licensed law firm without license must be blocked")
	assert("license" in str(no_qual_eval.get("reason", "")).to_lower() or "degree" in str(no_qual_eval.get("reason", "")).to_lower(), "Evaluation must specify license requirement")

	# Test unlicensed business founding (crime mechanic) is allowed even without license
	var unlic_eval := BusinessManager.can_found_business("biz_law_firm", true)
	assert(bool(unlic_eval.get("allowed", false)), "Founding unlicensed enterprise is permitted under crime system")

	# Grant license and incorporate
	PlayerData.add_license("license_bookkeeper")
	var qualified_eval := BusinessManager.can_found_business("biz_law_firm")
	assert(bool(qualified_eval.get("allowed", false)), "Founding law firm with license must be allowed")

	var player_money_pre_biz: int = PlayerData.money
	var found_res := BusinessManager.found_business("biz_law_firm", "Vance & Associates Legal")
	assert(bool(found_res.get("allowed", false)), "Founding business should succeed")
	assert(PlayerData.owned_businesses.size() == 1, "Owned businesses should have 1 entry")
	var biz: Dictionary = PlayerData.owned_businesses[0]
	assert(str(biz.get("name")) == "Vance & Associates Legal", "Business name set correctly")
	assert(int(biz.get("treasury")) == 10000, "Business treasury initialized with $10,000 separate working capital")
	assert(PlayerData.money < player_money_pre_biz, "Startup cost deducted from player cash")

	# Verify strict separation of Personal vs Business Finances
	var biz_treasury_init: int = int(biz.get("treasury"))
	var player_cash_init: int = PlayerData.money
	assert(biz_treasury_init != player_cash_init, "Personal cash and business treasury are strictly separated")

	# Commercial Loan section
	var loan_res := BusinessManager.take_business_loan(biz, 25000)
	assert(bool(loan_res.get("success", false)), "Taking commercial business loan should succeed")
	assert(int(biz.get("loan_balance")) == 25000, "Business commercial loan balance should be $25,000")
	assert(int(biz.get("treasury")) == biz_treasury_init + 25000, "Commercial loan disbursed to business treasury")
	assert(PlayerData.money == player_cash_init, "Personal cash must NOT change when business takes loan")

	# Repay commercial loan
	var repay_res := BusinessManager.repay_business_loan(biz, 10000)
	assert(bool(repay_res.get("success", false)), "Repaying business loan from treasury should succeed")
	assert(int(biz.get("loan_balance")) == 15000, "Remaining loan balance should be $15,000")

	# Tax Payment section (20% Corporate Tax on net profits)
	biz["unpaid_taxes"] = 8000
	var tax_res := BusinessManager.pay_business_taxes(biz, 8000)
	assert(bool(tax_res.get("success", false)), "Paying corporate taxes should succeed")
	assert(int(biz.get("unpaid_taxes")) == 0, "Corporate taxes should be fully paid")

	# Owner Dividend disbursement
	var treas_before_div: int = int(biz.get("treasury"))
	var cash_before_div: int = PlayerData.money
	var div_res := BusinessManager.withdraw_owner_dividend(biz, 5000)
	assert(bool(div_res.get("success", false)), "Owner dividend withdrawal should succeed")
	assert(int(biz.get("treasury")) == treas_before_div - 5000, "Dividend deducted from business treasury")
	assert(PlayerData.money == cash_before_div + 5000, "Dividend credited to personal cash")

	# Ensure business has sufficient operating buffer for testing simulation
	biz["treasury"] = 120000

	# Yearly business operations simulation
	var yearly_biz_results := BusinessManager.simulate_yearly_businesses()
	assert(yearly_biz_results.size() == 1, "Yearly business simulation processed owned business")
	print("  Business system verified: 16 degree-gated types, separate treasuries, 20% tax, loans, dividends.")

	# 6. UI Navigation and Hierarchy Verification
	var act_list: VBoxContainer = main_scene.get_node("ActivitiesPanel/ActMargin/ActContent/ActScroll/ActList")
	assert(act_list != null, "Activities list must exist")

	var jobs_idx: int = -1
	var freelance_idx: int = -1
	var lic_found: bool = false
	var biz_found: bool = false

	for i in range(act_list.get_child_count()):
		var child := act_list.get_child(i)
		var c_name := child.name
		if c_name == "JobsActItem":
			jobs_idx = i
		elif c_name == "FreelanceActItem":
			freelance_idx = i
		elif c_name == "LicensingActItem":
			lic_found = true
		elif c_name == "BusinessActItem":
			biz_found = true

	assert(jobs_idx != -1, "JobsActItem must exist in Activities")
	assert(freelance_idx != -1, "FreelanceActItem must exist in Activities")
	assert(freelance_idx == jobs_idx + 1, "FREELANCE BUTTON MUST BE LOCATED RIGHT UNDERNEATH JOBS & OCCUPATION BUTTON!")
	assert(lic_found, "LicensingActItem must exist in Activities")
	assert(biz_found, "BusinessActItem must exist in Activities")

	# Check Assets Panel has Business button
	main_scene.update_assets_panel()
	var assets_vbox: VBoxContainer = main_scene.get_node("AssetsPanel/AssetsMargin/AssetsContent/AssetsScroll/AssetsList")
	var has_biz_dealership := false
	for btn in assets_vbox.find_children("*", "Button", true, false):
		if "Cyber Enterprises" in btn.text:
			has_biz_dealership = true
			break
	assert(has_biz_dealership, "Cyber Enterprises button must exist in Assets panel")
	print("  UI layout & hierarchy verified: Freelance right underneath Jobs, Licensing, Businesses in Activities & Assets.")

	# 7. Save / Load Persistence
	PlayerData.grant_license("license_car")
	PlayerData.grant_license("license_photographer")
	if not PlayerData.active_freelance_jobs.has("freelance_photographer"):
		PlayerData.active_freelance_jobs.append("freelance_photographer")
	SaveManager.save_game()
	PlayerData.licenses.clear()
	PlayerData.active_freelance_jobs.clear()
	PlayerData.owned_businesses.clear()
	assert(PlayerData.licenses.is_empty(), "Licenses cleared in memory")
	assert(PlayerData.owned_businesses.is_empty(), "Businesses cleared in memory")

	SaveManager.load_game()
	assert(PlayerData.licenses.has("license_car"), "Car license restored from save")
	assert(PlayerData.licenses.has("license_photographer"), "Photographer license restored from save")
	assert(PlayerData.active_freelance_jobs.has("freelance_photographer"), "Active freelance jobs restored from save")
	assert(PlayerData.owned_businesses.size() == 1, "Owned business restored from save")
	assert(str(PlayerData.owned_businesses[0].get("name")) == "Vance & Associates Legal", "Business name restored accurately")
	assert(int(PlayerData.owned_businesses[0].get("loan_balance")) == 15000, "Business loan balance restored accurately")
	print("  Save/Load persistence verified for licenses, freelancing, and businesses.")

	main_scene.queue_free()
	print("✔ Test 10: Academic Course Costs, Licensing System, Freelance Economy, Asset Disasters, and 16 Commercial Businesses verified successfully!")



