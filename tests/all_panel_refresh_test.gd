extends Node

const PullUp = preload("res://scripts/ui/panel_pull_up.gd")

func _ready() -> void:
	assert("all-panel-refresh" in OS.get_user_data_dir(), "Run with isolated APPDATA in work/all-panel-refresh")
	var main = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	main.new_game_panel.hide()
	main.disclaimer_screen.hide()
	PlayerData.has_started_game = true
	PlayerData.age = 30
	PlayerData.money = 10000000
	PlayerData.bank_savings = 10000000
	PlayerData.is_dead = false
	PlayerData.is_in_prison = false
	var cases := [
		["_show_dating_app_modal", "dating_app_modal_overlay"],
		["_show_jobs_modal", "jobs_modal_overlay"],
		["_show_licensing_modal", "licensing_modal_overlay"],
		["_show_freelance_modal", "freelance_modal_overlay"],
		["_show_business_modal", "business_modal_overlay"],
		["_show_education_modal", "education_modal_overlay"],
		["_show_university_modal", "university_modal_overlay"],
		["_show_gym_modal", "gym_modal_overlay"],
		["_show_meditation_modal", "meditation_modal_overlay"],
		["_show_mind_and_body_modal", "mind_body_modal_overlay"],
		["_show_salon_modal", "salon_modal_overlay"],
		["_show_spa_modal", "spa_modal_overlay"],
		["_show_mental_institution_hub_modal", "mental_institution_modal_overlay"],
		["_show_psychologist_modal", "mental_institution_modal_overlay"],
		["_show_psychiatrist_modal", "mental_institution_modal_overlay"],
		["_show_asylum_commitment_modal", "mental_institution_modal_overlay"],
		["_show_shopping_modal", "shopping_modal_overlay"],
		["_show_social_media_modal", "social_media_modal_overlay"],
		["_show_pet_adoption_modal", "pet_adoption_modal_overlay"],
		["_show_pet_store_modal", "pet_adoption_modal_overlay"],
		["_show_pet_ranch_modal", "pet_adoption_modal_overlay"],
		["_show_will_modal", "will_modal_overlay"],
		["_show_charity_modal", "charity_modal_overlay"],
		["_show_doctor_modal", "doctor_modal_overlay"],
		["_show_crime_modal", "crime_modal_overlay"],
		["_show_casino_modal", "casino_modal_overlay"],
	]
	for theme in ["dark", "light"]:
		LifeLibrary.data.theme = theme
		main.on_theme_changed()
		for entry in cases:
			main.call(entry[0])
			var overlay: Control = main.get(entry[1])
			assert(is_instance_valid(overlay), entry[0])
			var view: Dictionary = overlay.get_meta("modal_view")
			var surface: Control = view.card.get_parent()
			assert(surface.offset_top > 0, "New window should animate: " + entry[0])
			var entrance: Tween = surface.get_meta("pull_up_controller")._tween
			main.call(entry[0])
			assert(main.get(entry[1]) == overlay, "Rapid refresh recreated " + entry[0])
			assert(surface.get_meta("pull_up_controller")._tween == entrance)
			PullUp.finish_all_active()
			var children: int = view.vbox.get_child_count()
			for repeat in range(2):
				main.call(entry[0])
				assert(main.get(entry[1]) == overlay, "Refresh recreated " + entry[0])
				assert(is_zero_approx(surface.offset_top), "Refresh animated " + entry[0])
				assert(view.vbox.get_child_count() == children, "Duplicated pinned controls")
				await get_tree().process_frame
			overlay.queue_free()
			await get_tree().process_frame
		for tab in ["assets", "relationships", "activities", "character", "bank", "settings", "infant"]:
			main.show_tab("timeline")
			main.show_tab(tab)
			var entrance: Tween = main.panel_pull_up._tween
			main.show_tab(tab)
			assert(main.panel_pull_up._tween == entrance, "Same-tab click restarted animation")
			PullUp.finish_all_active()
			main.panel_pull_up.finish_immediately()
			main.show_tab(tab)
			assert(main.panel_pull_up._panel == null, "Same-tab refresh animated")
		main.show_tab("timeline")
	# Category pages and multi-step exams keep their own window throughout refreshes.
	for entry in [["_show_job_category_modal", "job_category_modal_overlay", str(JobManager.get_categories()[0].id)], ["_show_license_category_modal", "license_category_modal_overlay", "vehicle"], ["_show_business_category_modal", "business_category_modal_overlay", "fnb"], ["_show_pet_shelter_modal", "pet_adoption_modal_overlay", "dog_shelter"], ["_show_pet_breeder_modal", "pet_adoption_modal_overlay", "dog_breeder"]]:
		main.call(entry[0], entry[2])
		var overlay: Control = main.get(entry[1])
		PullUp.finish_all_active()
		main.call(entry[0], entry[2])
		assert(main.get(entry[1]) == overlay)
		assert(is_zero_approx(overlay.get_meta("modal_view").card.get_parent().offset_top))
		overlay.queue_free()
		await get_tree().process_frame
	var exam := {"license_id": "drivers_license", "category_id": "vehicle", "questions": main.ROAD_SIGN_QUIZ.slice(0, 3), "q_index": 0, "score": 0}
	main._render_driving_exam_step(exam)
	var exam_overlay: Control = main.driving_exam_modal_overlay
	PullUp.finish_all_active()
	exam.q_index = 1
	main._render_driving_exam_step(exam)
	assert(main.driving_exam_modal_overlay == exam_overlay)
	assert(is_zero_approx(exam_overlay.get_meta("modal_view").card.get_parent().offset_top))
	assert("QUESTION 2" in str(exam_overlay.get_meta("modal_view").title.text))
	exam.q_index = 3
	main._render_driving_exam_step(exam)
	assert(main.driving_exam_modal_overlay == exam_overlay)
	assert(is_zero_approx(exam_overlay.get_meta("modal_view").card.get_parent().offset_top))
	exam_overlay.queue_free()
	await get_tree().process_frame
	# A real gameplay callback must refresh in place and keep its action working.
	main._show_will_modal()
	var will: Control = main.will_modal_overlay
	PullUp.finish_all_active()
	for button in will.find_children("*", "Button", true, false):
		if "Donate Entire Estate" in button.text and not button.disabled:
			button.pressed.emit()
			break
	assert(main.will_modal_overlay == will)
	assert(PlayerData.will_recipient == "CHARITY")
	assert(is_zero_approx(will.get_meta("modal_view").card.get_parent().offset_top))
	var options = main.get_node("OptionsMenu")
	for entry in [["_cities", "cities_overlay"], ["_people", "people_overlay"], ["_themes", "themes_overlay"]]:
		options.call(entry[0])
		var overlay: Control = options.get(entry[1])
		PullUp.finish_all_active()
		options.call(entry[0])
		assert(options.get(entry[1]) == overlay)
		assert(is_zero_approx(overlay.get_meta("modal_view").card.get_parent().offset_top))
		overlay.queue_free()
		await get_tree().process_frame
	print("ALL_PANEL_REFRESH_TEST_PASSED: %d activity windows, both themes, main tabs and Options" % cases.size())
	get_tree().quit()
