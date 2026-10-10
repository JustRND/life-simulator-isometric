extends Node

const NpcLifeProgress = preload("res://scripts/core/npc_life_progress.gd")
const SAVE_PATH := "user://savegame.json"


func capture_data() -> Dictionary:
	return {
		"life_id": PlayerData.life_id,
		"finance_market": PlayerData.finance_market,
		"crypto_wallet": PlayerData.crypto_wallet,
		"learning_activities": PlayerData.learning_activities,
		"first_name": PlayerData.first_name,
		"birthplace": PlayerData.birthplace,
		"gender": PlayerData.gender,
		"ethnicity": PlayerData.ethnicity,
		"portrait_track": PlayerData.portrait_track,
		"portrait_variant": PlayerData.portrait_variant,
		"has_started_game": PlayerData.has_started_game,
		"selected_room_id": PlayerData.selected_room_id,
		"birth_story": PlayerData.birth_story,
		"birth_month": PlayerData.birth_month,
		"birth_day": PlayerData.birth_day,
		"zodiac": PlayerData.zodiac,
		"mother_name": PlayerData.mother_name,
		"mother_job": PlayerData.mother_job,
		"mother_base_age": PlayerData.mother_base_age,
		"mother_relationship": PlayerData.mother_relationship,
		"mother_alive": PlayerData.mother_alive,
		"mother_health": PlayerData.mother_health,
		"mother_education": PlayerData.mother_education,
		"mother_condition": PlayerData.mother_condition,
		"mother_portrait_track": PlayerData.mother_portrait_track,
		"father_name": PlayerData.father_name,
		"father_job": PlayerData.father_job,
		"father_base_age": PlayerData.father_base_age,
		"father_relationship": PlayerData.father_relationship,
		"father_alive": PlayerData.father_alive,
		"father_health": PlayerData.father_health,
		"father_education": PlayerData.father_education,
		"father_condition": PlayerData.father_condition,
		"father_portrait_track": PlayerData.father_portrait_track,

		"family_wealth": PlayerData.family_wealth,
		"life_milestones": PlayerData.life_milestones,
		"age": PlayerData.age,
		"health": PlayerData.health,
		"happiness": PlayerData.happiness,
		"smarts": PlayerData.smarts,
		"looks": PlayerData.looks,
		"mental_state": PlayerData.mental_state,
		"money": PlayerData.money,
		"bank_savings": PlayerData.bank_savings,
		"debt": PlayerData.debt,
		"tax_debt": PlayerData.tax_debt,
		"loan_balance": PlayerData.loan_balance,
		"loan_interest_rate": PlayerData.loan_interest_rate,
		"credit_score": PlayerData.credit_score,
		"has_credit_card": PlayerData.has_credit_card,
		"credit_card_tier": PlayerData.credit_card_tier,
		"credit_card_limit": PlayerData.credit_card_limit,
		"credit_card_balance": PlayerData.credit_card_balance,
		"credit_card_apr": PlayerData.credit_card_apr,
		"credit_card_paid_this_year": PlayerData.credit_card_paid_this_year,
		"owned_assets": PlayerData.owned_assets.duplicate(true),
		"mortgages": PlayerData.mortgages.duplicate(true),
		"rented_property": PlayerData.rented_property.duplicate(true),
		"has_moved_out_from_parents": PlayerData.has_moved_out_from_parents,
		"current_residence_name": PlayerData.current_residence_name,
		"current_residence_type": PlayerData.current_residence_type,
		"siblings": PlayerData.siblings.duplicate(true),
		"health_insurance": PlayerData.health_insurance,
		"asset_insurance": PlayerData.asset_insurance,
		"education_level": PlayerData.education_level,
		"grades": PlayerData.grades,
		"has_scholarship": PlayerData.has_scholarship,
		"university_years": PlayerData.university_years,
		"university_name": PlayerData.university_name,
		"university_major": PlayerData.university_major,
		"university_major_title": PlayerData.university_major_title,
		"university_degree": PlayerData.university_degree,
		"university_tuition": PlayerData.university_tuition,
		"degrees": PlayerData.degrees,
		"licenses": PlayerData.licenses,
		"active_freelance_jobs": PlayerData.active_freelance_jobs,
		"freelance_reputation": PlayerData.freelance_reputation,
		"owned_businesses": PlayerData.owned_businesses,
		"last_freelance_pitch_age": PlayerData.last_freelance_pitch_age,
		"last_school_activity_age": PlayerData.last_school_activity_age,
		"last_scholarship_applied_age": PlayerData.last_scholarship_applied_age,
		"last_ged_attempt_age": PlayerData.last_ged_attempt_age,
		"has_gym_membership": PlayerData.has_gym_membership,
		"gym_membership_annual_fee": PlayerData.gym_membership_annual_fee,
		"last_gym_activity_age": PlayerData.last_gym_activity_age,
		"last_meditation_activity_age": PlayerData.last_meditation_activity_age,
		"last_salon_activity_age": PlayerData.last_salon_activity_age,
		"last_spa_activity_age": PlayerData.last_spa_activity_age,
		"last_dating_app_age": PlayerData.last_dating_app_age,
		"last_pet_adoption_age": PlayerData.last_pet_adoption_age,
		"last_charity_donation_age": PlayerData.last_charity_donation_age,
		"job_id": PlayerData.job_id,
		"job_title": PlayerData.job_title,
		"job_company": PlayerData.job_company,
		"job_salary": PlayerData.job_salary,
		"career_progress": PlayerData.career_progress,
		"underground_progress": PlayerData.underground_progress,
		"illnesses": PlayerData.illnesses,
		"is_dead": PlayerData.is_dead,
		"cause_of_death": PlayerData.cause_of_death,
		"is_in_prison": PlayerData.is_in_prison,
		"prison_sentence_years": PlayerData.prison_sentence_years,
		"is_in_mental_institution": PlayerData.is_in_mental_institution,
		"mental_institution_years_left": PlayerData.mental_institution_years_left,
		"mental_institution_annual_cost": PlayerData.mental_institution_annual_cost,
		"event_history": PlayerData.event_history,
		"event_history_log": PlayerData.event_history_log,
		"life_log": PlayerData.life_log,
		"karma": PlayerData.karma,
		"children": PlayerData.children,
		"pregnancy": PlayerData.pregnancy,
		"active_debuffs": PlayerData.active_debuffs,
		"active_buffs": PlayerData.active_buffs,
		"partner": PlayerData.partner,
		"ex_partners": PlayerData.ex_partners,
		"last_parent_interact_age": PlayerData.last_parent_interact_age,
		"last_mother_spend_time_age": PlayerData.last_mother_spend_time_age,
		"last_mother_compliment_age": PlayerData.last_mother_compliment_age,
		"last_mother_ask_money_age": PlayerData.last_mother_ask_money_age,
		"last_father_spend_time_age": PlayerData.last_father_spend_time_age,
		"last_father_compliment_age": PlayerData.last_father_compliment_age,
		"last_father_ask_money_age": PlayerData.last_father_ask_money_age,
		"last_partner_interact_age": PlayerData.last_partner_interact_age,
		"last_partner_spend_time_age": PlayerData.last_partner_spend_time_age,
		"last_partner_compliment_age": PlayerData.last_partner_compliment_age,
		"last_partner_gift_age": PlayerData.last_partner_gift_age,
		"last_partner_propose_age": PlayerData.last_partner_propose_age,
		"last_breakup_age": PlayerData.last_breakup_age,
		"last_baby_age": PlayerData.last_baby_age,
		"last_mother_pay_meds_age": PlayerData.last_mother_pay_meds_age,
		"last_father_pay_meds_age": PlayerData.last_father_pay_meds_age,
		"last_mother_doctor_checkup_age": PlayerData.last_mother_doctor_checkup_age,
		"last_father_doctor_checkup_age": PlayerData.last_father_doctor_checkup_age,
		"last_mother_vitamin_shot_age": PlayerData.last_mother_vitamin_shot_age,
		"last_father_vitamin_shot_age": PlayerData.last_father_vitamin_shot_age,
		"last_doctor_checkup_age": PlayerData.last_doctor_checkup_age,
		"last_doctor_vitamin_age": PlayerData.last_doctor_vitamin_age,
		"last_plastic_surgery_age": PlayerData.last_plastic_surgery_age,
		"last_chemo_age": PlayerData.last_chemo_age,
		"last_therapy_age": PlayerData.last_therapy_age,
		"last_er_age": PlayerData.last_er_age,
		"last_prison_activity_age": PlayerData.last_prison_activity_age,
		"last_casino_age": PlayerData.last_casino_age,
		"casino_plays_this_year": PlayerData.casino_plays_this_year,
		"last_overtime_age": PlayerData.last_overtime_age,
		"last_childhood_gig_age": PlayerData.last_childhood_gig_age,
		"social_media": PlayerData.social_media,
		"pets": PlayerData.pets,
		"will_recipient": PlayerData.will_recipient
	}

var _save_timer: Timer = null
var _pending_save_path := ""


func _ready() -> void:
	_save_timer = Timer.new()
	_save_timer.one_shot = true
	_save_timer.wait_time = 0.35
	_save_timer.timeout.connect(_on_save_timer_timeout)
	add_child(_save_timer)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_CRASH:
		flush_pending_save()


func flush_pending_save() -> void:
	if _save_timer != null and not _save_timer.is_stopped():
		_save_timer.stop()
		var path := _pending_save_path if not _pending_save_path.is_empty() else SAVE_PATH
		_pending_save_path = ""
		save_game(path)


func save_game_debounced(delay_sec: float = 0.35, path: String = SAVE_PATH) -> void:
	_pending_save_path = path
	if _save_timer == null or not is_inside_tree():
		save_game(path)
		return
	_save_timer.stop()
	_save_timer.wait_time = maxf(0.1, delay_sec)
	_save_timer.start()


func _on_save_timer_timeout() -> void:
	var path := _pending_save_path if not _pending_save_path.is_empty() else SAVE_PATH
	_pending_save_path = ""
	save_game(path)


func save_game(path: String = SAVE_PATH) -> bool:
	if _save_timer != null and not _save_timer.is_stopped():
		_save_timer.stop()
	_pending_save_path = ""
	var save_data := capture_data()
	return write_data(path, save_data)


func write_data(path: String, data: Dictionary) -> bool:
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)

	if file == null:
		push_error("Could not open save file.")
		return false

	var json_str := JSON.stringify(data)
	file.store_string(json_str)
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(path + ".tmp"), ProjectSettings.globalize_path(path)) == OK


func load_game(path: String = SAVE_PATH) -> bool:
	if not FileAccess.file_exists(path):
		return false

	var file := FileAccess.open(
		path,
		FileAccess.READ
	)

	if file == null:
		push_error("Could not open save file.")
		return false

	var json_text: String = file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_text)

	if typeof(data) != TYPE_DICTIONARY:
		push_error("Save file is invalid.")
		return false
	if not valid_data(data):
		return false
	return apply_data(data)


func apply_data(data: Dictionary) -> bool:
	if not valid_data(data):
		return false

	PlayerData.first_name = str(data.get("first_name", ""))
	PlayerData.finance_market = Dictionary(data.get("finance_market", {}))
	PlayerData.crypto_wallet = Dictionary(data.get("crypto_wallet", {}))
	preload("res://scripts/economy/crypto_market.gd").ensure(PlayerData)
	PlayerData.learning_activities = Dictionary(data.get("learning_activities", {}))
	PlayerData.life_id = str(data.get("life_id", ""))
	if PlayerData.life_id.is_empty():
		PlayerData.life_id = (PlayerData.first_name + str(data.get("birth_story", ""))).sha256_text().left(32)
	PlayerData.birthplace = str(data.get("birthplace", ""))
	PlayerData.gender = str(data.get("gender", "MALE"))
	PlayerData.ethnicity = str(data.get("ethnicity", "white"))
	PlayerData.portrait_track = int(data.get("portrait_track", int(data.get("portrait_variant", 0)) % 4))
	PlayerData.portrait_variant = int(data.get("portrait_variant", PlayerData.portrait_track))
	PlayerData.has_started_game = bool(data.get("has_started_game", false))
	PlayerData.selected_room_id = str(data.get("selected_room_id", "room_wood"))

	PlayerData.birth_story = str(data.get("birth_story", ""))
	PlayerData.birth_month = str(data.get("birth_month", "January"))
	PlayerData.birth_day = int(data.get("birth_day", 1))
	PlayerData.zodiac = str(data.get("zodiac", "Capricorn"))

	PlayerData.mother_name = str(data.get("mother_name", ""))
	PlayerData.mother_job = str(data.get("mother_job", ""))
	PlayerData.mother_base_age = int(data.get("mother_base_age", 35))
	PlayerData.mother_relationship = int(data.get("mother_relationship", 80))
	PlayerData.mother_alive = bool(data.get("mother_alive", true))
	PlayerData.mother_health = int(data.get("mother_health", 80))
	PlayerData.mother_education = str(data.get("mother_education", "High School"))
	PlayerData.mother_condition = str(data.get("mother_condition", ""))
	PlayerData.mother_portrait_track = int(data.get("mother_portrait_track", 0))

	PlayerData.father_name = str(data.get("father_name", ""))
	PlayerData.father_job = str(data.get("father_job", ""))
	PlayerData.father_base_age = int(data.get("father_base_age", 37))
	PlayerData.father_relationship = int(data.get("father_relationship", 80))
	PlayerData.father_alive = bool(data.get("father_alive", true))
	PlayerData.father_health = int(data.get("father_health", 80))
	PlayerData.father_education = str(data.get("father_education", "High School"))
	PlayerData.father_condition = str(data.get("father_condition", ""))
	PlayerData.father_portrait_track = int(data.get("father_portrait_track", 0))


	PlayerData.family_wealth = str(data.get("family_wealth", "middle_class"))
	PlayerData.life_milestones = Array(data.get("life_milestones", []))

	PlayerData.age = int(data.get("age", 0))
	PlayerData.health = int(data.get("health", 80))
	PlayerData.happiness = int(data.get("happiness", 75))
	PlayerData.smarts = int(data.get("smarts", 60))
	PlayerData.looks = int(data.get("looks", 65))
	PlayerData.mental_state = int(data.get("mental_state", 80))
	PlayerData.money = int(data.get("money", 0))
	PlayerData.bank_savings = int(data.get("bank_savings", 0))
	PlayerData.debt = int(data.get("debt", 0))
	# Legacy mixed debt stays in general debt; do not invent an unpaid tax amount.
	PlayerData.tax_debt = maxi(0, int(data.get("tax_debt", 0)))
	PlayerData.loan_balance = int(data.get("loan_balance", 0))
	PlayerData.loan_interest_rate = float(data.get("loan_interest_rate", 0.08))
	PlayerData.credit_score = int(data.get("credit_score", 650))
	PlayerData.has_credit_card = bool(data.get("has_credit_card", false))
	PlayerData.credit_card_tier = str(data.get("credit_card_tier", "None"))
	PlayerData.credit_card_limit = int(data.get("credit_card_limit", 0))
	PlayerData.credit_card_balance = int(data.get("credit_card_balance", 0))
	PlayerData.credit_card_apr = float(data.get("credit_card_apr", 0.18))
	PlayerData.credit_card_paid_this_year = int(data.get("credit_card_paid_this_year", 0))
	PlayerData.education_level = str(data.get("education_level", "None"))
	PlayerData.grades = int(data.get("grades", 75))
	PlayerData.has_scholarship = bool(data.get("has_scholarship", false))
	PlayerData.university_years = int(data.get("university_years", 0))
	PlayerData.university_name = str(data.get("university_name", ""))
	PlayerData.university_major = str(data.get("university_major", ""))
	PlayerData.university_major_title = str(data.get("university_major_title", ""))
	PlayerData.university_degree = str(data.get("university_degree", ""))
	PlayerData.university_tuition = int(data.get("university_tuition", 12000))
	PlayerData.degrees = Array(data.get("degrees", []))
	PlayerData.licenses = Array(data.get("licenses", []))
	PlayerData.active_freelance_jobs = Array(data.get("active_freelance_jobs", []))
	PlayerData.freelance_reputation = Dictionary(data.get("freelance_reputation", {}))
	PlayerData.owned_businesses = Array(data.get("owned_businesses", []))
	PlayerData.last_freelance_pitch_age = Dictionary(data.get("last_freelance_pitch_age", {}))
	PlayerData.last_school_activity_age = int(data.get("last_school_activity_age", -1))
	PlayerData.last_scholarship_applied_age = int(data.get("last_scholarship_applied_age", -1))
	PlayerData.last_ged_attempt_age = int(data.get("last_ged_attempt_age", -1))
	PlayerData.has_gym_membership = bool(data.get("has_gym_membership", false))
	PlayerData.gym_membership_annual_fee = int(data.get("gym_membership_annual_fee", 300))
	PlayerData.last_gym_activity_age = int(data.get("last_gym_activity_age", -1))
	PlayerData.last_meditation_activity_age = int(data.get("last_meditation_activity_age", -1))
	PlayerData.last_salon_activity_age = int(data.get("last_salon_activity_age", -1))
	PlayerData.last_spa_activity_age = int(data.get("last_spa_activity_age", -1))
	PlayerData.last_dating_app_age = int(data.get("last_dating_app_age", -1))
	PlayerData.last_pet_adoption_age = int(data.get("last_pet_adoption_age", -1))
	var raw_c_age = data.get("last_charity_donation_age", -1)
	if raw_c_age is Dictionary:
		var max_age: int = -1
		for v in raw_c_age.values():
			max_age = maxi(max_age, int(v))
		PlayerData.last_charity_donation_age = max_age
	else:
		PlayerData.last_charity_donation_age = int(raw_c_age)
	PlayerData.karma = int(data.get("karma", 0))
	PlayerData.children = Array(data.get("children", []))
	PlayerData.pregnancy = Dictionary(data.get("pregnancy", {}))
	PlayerData.active_debuffs = Array(data.get("active_debuffs", []))
	PlayerData.active_buffs = Array(data.get("active_buffs", []))
	for b_id in ["buff_philanthropist_heart", "buff_animal_guardian", "buff_youth_mentor", "buff_lifesavers_blessing", "buff_eco_guardian", "buff_grand_benefactor"]:
		PlayerData.active_buffs.erase(b_id)
	PlayerData.owned_assets.clear()
	PlayerData.mortgages = Array(data.get("mortgages", [])).duplicate(true)
	PlayerData.rented_property = Dictionary(data.get("rented_property", {})).duplicate(true)
	PlayerData.siblings = Array(data.get("siblings", [])).duplicate(true)
	for s in PlayerData.siblings:
		if s is Dictionary:
			NpcLifeProgress.ensure(s)
	PlayerData.health_insurance = str(data.get("health_insurance", "none"))
	PlayerData.asset_insurance = Dictionary(data.get("asset_insurance", { "vehicle": false, "property": false }))
	var saved_assets = data.get("owned_assets", [])
	if saved_assets is Array:
		for a in saved_assets:
			if a is Dictionary:
				if a.get("item_id", "") == "prop_capsule":
					a["name"] = "Cozy Starter Home"
					a["image_path"] = "res://assets/items/properties/prop_starter_home.jpg"
				PlayerData.owned_assets.append(a)
	if PlayerData.owned_assets.is_empty() and PlayerData.age == 0:
		PlayerData.grant_starting_assets()
	PlayerData.enforce_buffs_and_debuffs()

	PlayerData.partner = Dictionary(data.get("partner", {}))
	preload("res://scripts/core/romance_rules.gd").normalize(PlayerData)
	if PlayerData.has_partner():
		NpcLifeProgress.ensure(PlayerData.partner)
	for c in PlayerData.children:
		if c is Dictionary:
			NpcLifeProgress.ensure(c)
	PlayerData.ex_partners = Array(data.get("ex_partners", []))
	PlayerData.has_moved_out_from_parents = bool(data.get("has_moved_out_from_parents", false))
	PlayerData.current_residence_name = str(data.get("current_residence_name", ""))
	PlayerData.current_residence_type = str(data.get("current_residence_type", "parents"))
	PlayerData.last_parent_interact_age = int(data.get("last_parent_interact_age", -1))
	PlayerData.last_mother_spend_time_age = int(data.get("last_mother_spend_time_age", -1))
	PlayerData.last_mother_compliment_age = int(data.get("last_mother_compliment_age", -1))
	PlayerData.last_mother_ask_money_age = int(data.get("last_mother_ask_money_age", -1))
	PlayerData.last_father_spend_time_age = int(data.get("last_father_spend_time_age", -1))
	PlayerData.last_father_compliment_age = int(data.get("last_father_compliment_age", -1))
	PlayerData.last_father_ask_money_age = int(data.get("last_father_ask_money_age", -1))
	PlayerData.last_partner_interact_age = int(data.get("last_partner_interact_age", -1))
	PlayerData.last_partner_spend_time_age = int(data.get("last_partner_spend_time_age", -1))
	PlayerData.last_partner_compliment_age = int(data.get("last_partner_compliment_age", -1))
	PlayerData.last_partner_gift_age = int(data.get("last_partner_gift_age", -1))
	PlayerData.last_partner_propose_age = int(data.get("last_partner_propose_age", -1))
	PlayerData.last_breakup_age = int(data.get("last_breakup_age", -1))
	PlayerData.last_baby_age = int(data.get("last_baby_age", -1))
	PlayerData.last_mother_pay_meds_age = int(data.get("last_mother_pay_meds_age", -1))
	PlayerData.last_father_pay_meds_age = int(data.get("last_father_pay_meds_age", -1))
	PlayerData.last_mother_doctor_checkup_age = int(data.get("last_mother_doctor_checkup_age", -1))
	PlayerData.last_father_doctor_checkup_age = int(data.get("last_father_doctor_checkup_age", -1))
	PlayerData.last_mother_vitamin_shot_age = int(data.get("last_mother_vitamin_shot_age", -1))
	PlayerData.last_father_vitamin_shot_age = int(data.get("last_father_vitamin_shot_age", -1))
	PlayerData.last_doctor_checkup_age = int(data.get("last_doctor_checkup_age", -1))
	PlayerData.last_doctor_vitamin_age = int(data.get("last_doctor_vitamin_age", -1))
	PlayerData.last_plastic_surgery_age = int(data.get("last_plastic_surgery_age", -1))
	PlayerData.last_chemo_age = int(data.get("last_chemo_age", -1))
	PlayerData.last_therapy_age = int(data.get("last_therapy_age", -1))
	PlayerData.last_er_age = int(data.get("last_er_age", -1))
	PlayerData.last_prison_activity_age = int(data.get("last_prison_activity_age", -1))
	PlayerData.last_casino_age = int(data.get("last_casino_age", -1))
	PlayerData.casino_plays_this_year = int(data.get("casino_plays_this_year", 0))
	PlayerData.last_overtime_age = int(data.get("last_overtime_age", -1))
	PlayerData.last_childhood_gig_age = int(data.get("last_childhood_gig_age", -1))

	PlayerData.job_id = str(data.get("job_id", ""))
	PlayerData.job_title = str(data.get("job_title", ""))
	PlayerData.job_company = str(data.get("job_company", ""))
	PlayerData.job_salary = int(data.get("job_salary", 0))
	PlayerData.career_progress = Dictionary(data.get("career_progress", {}))
	PlayerData.underground_progress = Dictionary(data.get("underground_progress", {}))
	preload("res://scripts/economy/career_progression.gd").normalize(PlayerData)
	preload("res://scripts/economy/underground_progression.gd").normalize(PlayerData)

	PlayerData.illnesses = data.get("illnesses", [])
	PlayerData.is_dead = bool(data.get("is_dead", false))
	PlayerData.cause_of_death = str(data.get("cause_of_death", ""))

	PlayerData.is_in_prison = bool(data.get("is_in_prison", false))
	PlayerData.prison_sentence_years = int(data.get("prison_sentence_years", 0))

	PlayerData.is_in_mental_institution = bool(data.get("is_in_mental_institution", false))
	PlayerData.mental_institution_years_left = int(data.get("mental_institution_years_left", 0))
	PlayerData.mental_institution_annual_cost = int(data.get("mental_institution_annual_cost", 15000))

	PlayerData.event_history = data.get("event_history", [])
	PlayerData.event_history_log = Dictionary(data.get("event_history_log", {}))
	PlayerData.life_log = data.get("life_log", [])
	PlayerData.social_media = Dictionary(data.get("social_media", {}))
	PlayerData.pets = Array(data.get("pets", []))
	PlayerData.will_recipient = str(data.get("will_recipient", "CHILDREN"))

	PlayerData.sync_milestones_from_log()

	print("Game loaded.")
	return true


func valid_data(data: Dictionary) -> bool:
	if not data.has("first_name") or not data.has("age") or not data.has("has_started_game"):
		return false
	var sample := capture_data()
	for key in sample:
		if not data.has(key):
			continue # Older saves may omit newly added fields.
		var expected := typeof(sample[key])
		var actual := typeof(data[key])
		if expected in [TYPE_INT, TYPE_FLOAT] and actual in [TYPE_INT, TYPE_FLOAT]:
			continue
		if expected != actual:
			return false
	return int(data.age) >= 0


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var error: Error = DirAccess.remove_absolute(
			ProjectSettings.globalize_path(SAVE_PATH)
		)

		if error != OK:
			push_error("Could not delete save file. Error code: %d" % error)
			return

	print("Save deleted.")
