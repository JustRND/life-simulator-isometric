extends Node

const NpcLifeProgress = preload("res://scripts/core/npc_life_progress.gd")

func _ready() -> void:
	print("=== BEGIN PARENTS & CHILDREN PROGRESSION VERIFICATION ===")

	var main_res := load("res://scenes/main/main_screen.tscn") as PackedScene
	assert(main_res != null, "main_screen.tscn must load")
	var main = main_res.instantiate()
	add_child(main)

	if main.disclaimer_screen != null:
		main.disclaimer_screen.hide()
	if main.loading_screen != null:
		main.loading_screen.hide()

	await get_tree().process_frame
	await get_tree().process_frame

	PlayerData.reset_player()
	PlayerData.first_name = "Lucas"
	PlayerData.age = 25
	PlayerData.mother_name = "Martha"
	PlayerData.mother_alive = true
	PlayerData.mother_job = "Professor"
	PlayerData.mother_education = "Ph.D. in Literature"
	PlayerData.father_name = "Thomas"
	PlayerData.father_alive = true
	PlayerData.father_job = "Architect"
	PlayerData.father_education = "Master of Architecture"

	main.show_tab("relationships")
	main.update_relationships_panel()
	await get_tree().process_frame

	# 1. VERIFY PARENTS EDUCATION DISPLAY (ALIVE)
	assert(main.mother_edu_label != null, "MotherEduLabel must exist")
	assert(main.mother_edu_label.text == "Education: Ph.D. in Literature", "Mother education must show final education: Ph.D. in Literature (Got: %s)" % main.mother_edu_label.text)
	assert(main.father_edu_label != null, "FatherEduLabel must exist")
	assert(main.father_edu_label.text == "Education: Master of Architecture", "Father education must show final education: Master of Architecture (Got: %s)" % main.father_edu_label.text)
	print("✔ CHECK 1: Parents final education level accurately displayed in Relationships panel while alive.")

	# 2. VERIFY PARENTS EDUCATION DISPLAY (DECEASED)
	PlayerData.mother_alive = false
	PlayerData.father_alive = false
	main.update_relationships_panel()
	await get_tree().process_frame

	assert(main.mother_name_label.text.contains("Deceased"), "Mother marked as deceased")
	assert(main.mother_edu_label.text == "Education: Ph.D. in Literature", "Deceased mother must still display final education level: Ph.D. in Literature (Got: %s)" % main.mother_edu_label.text)
	assert(main.father_name_label.text.contains("Deceased"), "Father marked as deceased")
	assert(main.father_edu_label.text == "Education: Master of Architecture", "Deceased father must still display final education level: Master of Architecture (Got: %s)" % main.father_edu_label.text)
	print("✔ CHECK 2: Deceased parents retain and display final education level alongside In Memoriam status.")

	# 3. VERIFY CHILDREN'S BACKGROUND PROGRESSION ACROSS DIFFERENT LIFE STAGES
	PlayerData.children.clear()

	# Child 0: Infant / Toddler (Age 2)
	var infant = PlayerData.add_player_child("Baby Mia", "FEMALE", 2)
	# Child 1: School Child (Age 10)
	var school_kid = PlayerData.add_player_child("Leo", "MALE", 10)
	# Child 2: University Student (Age 20)
	var college_kid = PlayerData.add_player_child("Chloe", "FEMALE", 20)
	# Child 3: Adult with career and business (Age 32)
	var adult_kid = PlayerData.add_player_child("Alexander", "MALE", 32)

	main.update_relationships_panel()
	await get_tree().process_frame

	var rel_list = main.get_node_or_null("RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList")
	assert(rel_list != null, "Relationships scroll list exists")

	# Check Child 0: Infant
	var card_0 = rel_list.get_node_or_null("ChildCard_0")
	assert(card_0 != null, "ChildCard_0 exists")
	var occ_0_str = NpcLifeProgress.get_occupation_display(infant)
	var edu_0_str = NpcLifeProgress.get_education_display(infant)
	assert(occ_0_str.contains("Infant / Toddler"), "Infant occupation must state Infant / Toddler (Got: %s)" % occ_0_str)
	assert(edu_0_str.contains("None (Too young for school)"), "Infant education must state Too young for school (Got: %s)" % edu_0_str)
	print("✔ CHECK 3: Infant/Toddler education ('%s') and occupation ('%s') correctly displayed." % [edu_0_str, occ_0_str])

	# Check Child 1: Primary school student
	var occ_1_str = NpcLifeProgress.get_occupation_display(school_kid)
	var edu_1_str = NpcLifeProgress.get_education_display(school_kid)
	assert(occ_1_str.contains("Student"), "Age 10 child occupation must state Student (Got: %s)" % occ_1_str)
	assert(edu_1_str.contains("Primary School") and edu_1_str.contains("Grades:"), "Age 10 education must state Primary School with grades (Got: %s)" % edu_1_str)
	print("✔ CHECK 4: Primary student education ('%s') and occupation ('%s') correctly displayed." % [edu_1_str, occ_1_str])

	# Check Child 2: University student
	var occ_2_str = NpcLifeProgress.get_occupation_display(college_kid)
	var edu_2_str = NpcLifeProgress.get_education_display(college_kid)
	assert(occ_2_str.contains("College Student") or occ_2_str.contains("Student"), "College student occupation formatted (Got: %s)" % occ_2_str)
	assert(edu_2_str.contains("University Student") and edu_2_str.contains("Year"), "College student education must format university year and major (Got: %s)" % edu_2_str)
	print("✔ CHECK 5: University student education ('%s') and occupation ('%s') correctly displayed." % [edu_2_str, occ_2_str])

	# Check Child 3: Working adult
	var occ_3_str = NpcLifeProgress.get_occupation_display(adult_kid)
	var edu_3_str = NpcLifeProgress.get_education_display(adult_kid)
	var fin_3_str = NpcLifeProgress.get_finances_display(adult_kid)
	assert(occ_3_str.contains("$") and occ_3_str.contains("/yr"), "Adult child occupation formatted with salary (Got: %s)" % occ_3_str)
	assert(edu_3_str.begins_with("🎓 Education:"), "Adult child education formatted (Got: %s)" % edu_3_str)
	assert(fin_3_str.contains("Personal Wealth: $"), "Adult child personal finances formatted (Got: %s)" % fin_3_str)
	print("✔ CHECK 6: Adult child progression details correctly displayed:\n   %s\n   %s\n   %s" % [occ_3_str, edu_3_str, fin_3_str])

	# 4. VERIFY PROGRESSION DETAILS MODAL OPENS AND RENDERS
	main._show_child_progression_modal(3)
	await get_tree().process_frame
	assert(main.romance_action_modal_overlay != null and is_instance_valid(main.romance_action_modal_overlay), "Progression details modal overlay must be created")
	print("✔ CHECK 7: '📜 Details' progression modal opened successfully with background journey and history.")
	main.romance_action_modal_overlay.queue_free()

	print("\n🎉 ALL PARENTS & CHILDREN PROGRESSION TESTS PASSED PERFECTLY!")
	get_tree().quit()
