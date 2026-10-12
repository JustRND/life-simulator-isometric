extends Node

const NpcLifeProgress = preload("res://scripts/core/npc_life_progress.gd")
const BirthStoryGeneratorRef = preload("res://scripts/core/birth_story_generator.gd")
const NameCatalog = preload("res://scripts/core/name_catalog.gd")
const NeuralCatalog = preload("res://scripts/economy/neural_catalog.gd")
const GameClockScript = preload("res://scripts/core/game_clock.gd")

const KARMIC_MODIFIERS := {
	# Cosmic Buffs
	"super_smarts": {"title": "Transcendent Genius", "icon": "🧠"},
	"silver_spoon": {"title": "Silver Spoon Legacy", "icon": "💎"},
	"radiant_vitality": {"title": "Radiant Vitality", "icon": "❤️"},
	"divine_looks": {"title": "Divine Radiance", "icon": "✨"},
	"blessed_mind": {"title": "Serene Mind", "icon": "🧘"},
	"golden_pedigree": {"title": "Golden Pedigree", "icon": "👑"},
	# Karmic Debuffs
	"bad_stats": {"title": "Diminished Core Attributes", "icon": "📉"},
	"random_illness": {"title": "Congenital Chronic Illness", "icon": "🩺"},
	"poverty": {"title": "Crushing Generational Poverty", "icon": "💸"},
	"no_parents": {"title": "Orphaned at Birth", "icon": "🏚️"},
	"stuck_happiness": {"title": "Anhedonia (Stuck Happiness)", "icon": "⚡"},
	"health_cap_50": {"title": "Frail Vessel (Health Capped at 50%)", "icon": "💔"},
	"crazy_debt": {"title": "Ancestral Debt Burden", "icon": "⛓️"}
}

static func format_karmic_modifier(modifier_id: String) -> String:
	if KARMIC_MODIFIERS.has(modifier_id):
		var info: Dictionary = KARMIC_MODIFIERS[modifier_id]
		return "%s %s" % [info.get("icon", ""), info.get("title", modifier_id)]
	return modifier_id.capitalize().replace("_", " ")

var age: int = 17
var in_game_day: int = 1
var in_game_month: int = 1
var in_game_year: int = 2026
var is_time_paused: bool = false
var day_accumulator: float = 0.0
var life_id: String = ""
var finance_market: Dictionary = {}
var crypto_wallet: Dictionary = {}
var learning_activities: Dictionary = {}

var health: int = 80
var happiness: int = 75
var smarts: int = 60
var looks: int = 65
var mental_state: int = 80

var active_stat_modifiers: Dictionary = {}

var first_name: String = ""
var birthplace: String = ""
var gender: String = "MALE"
var ethnicity: String = "white"
var portrait_track: int = 0
var portrait_variant: int = 0
var avatar_id: String = ""
var has_started_game: bool = false
var selected_room_id: String = "room_capsule"
var has_moved_out_from_parents: bool = false
var current_residence_name: String = ""
var current_residence_type: String = "parents"

var birth_story: String = ""
var birth_year: int = 2014
var birth_month: String = "January"
var birth_month_idx: int = 1
var birth_day: int = 1
var zodiac: String = "Capricorn"

var mother_name: String = ""
var mother_job: String = ""
var mother_base_age: int = 35
var mother_relationship: int = 80
var mother_alive: bool = true
var mother_health: int = 80
var mother_education: String = "High School"
var mother_condition: String = ""
var mother_portrait_track: int = 0

var father_name: String = ""
var father_job: String = ""
var father_base_age: int = 37
var father_relationship: int = 80
var father_alive: bool = true
var father_health: int = 80
var father_education: String = "High School"
var father_condition: String = ""
var father_portrait_track: int = 0


var family_wealth: String = "middle_class"
var life_milestones: Array = []

var partner: Dictionary = {}
var ex_partners: Array = []
var friends: Array = []
var children: Array = []
var pregnancy: Dictionary = {}
var intoxication_level: int = 0
var has_hangover: bool = false
var venue_history: Array = []
var active_debuffs: Array = []
var active_buffs: Array = []
var total_donated_charity: int = 0
var charity_donations_count: int = 0
var last_parent_interact_age: int = -1
var last_parent_interact_month: int = -1
var last_parent_interact_year: int = -1
var last_mother_spend_time_age: int = -1
var last_mother_spend_time_month: int = -1
var last_mother_spend_time_year: int = -1
var last_mother_compliment_age: int = -1
var last_mother_compliment_month: int = -1
var last_mother_compliment_year: int = -1
var last_mother_ask_money_age: int = -1
var last_mother_ask_money_month: int = -1
var last_mother_ask_money_year: int = -1
var last_father_spend_time_age: int = -1
var last_father_spend_time_month: int = -1
var last_father_spend_time_year: int = -1
var last_father_compliment_age: int = -1
var last_father_compliment_month: int = -1
var last_father_compliment_year: int = -1
var last_father_ask_money_age: int = -1
var last_father_ask_money_month: int = -1
var last_father_ask_money_year: int = -1
var last_partner_interact_age: int = -1
var last_partner_interact_month: int = -1
var last_partner_interact_year: int = -1
var last_partner_spend_time_age: int = -1
var last_partner_spend_time_month: int = -1
var last_partner_spend_time_year: int = -1
var last_partner_compliment_age: int = -1
var last_partner_compliment_month: int = -1
var last_partner_compliment_year: int = -1
var last_partner_gift_age: int = -1
var last_partner_gift_month: int = -1
var last_partner_gift_year: int = -1
var last_partner_propose_age: int = -1
var last_partner_propose_month: int = -1
var last_partner_propose_year: int = -1
var last_breakup_age: int = -1
var last_breakup_month: int = -1
var last_breakup_year: int = -1
var last_baby_age: int = -1

var last_mother_pay_meds_age: int = -1
var last_mother_pay_meds_month: int = -1
var last_mother_pay_meds_year: int = -1
var last_father_pay_meds_age: int = -1
var last_father_pay_meds_month: int = -1
var last_father_pay_meds_year: int = -1
var last_mother_doctor_checkup_age: int = -1
var last_mother_doctor_checkup_month: int = -1
var last_mother_doctor_checkup_year: int = -1
var last_father_doctor_checkup_age: int = -1
var last_father_doctor_checkup_month: int = -1
var last_father_doctor_checkup_year: int = -1
var last_mother_vitamin_shot_age: int = -1
var last_mother_vitamin_shot_month: int = -1
var last_mother_vitamin_shot_year: int = -1
var last_father_vitamin_shot_age: int = -1
var last_father_vitamin_shot_month: int = -1
var last_father_vitamin_shot_year: int = -1

var last_doctor_checkup_age: int = -1
var last_doctor_checkup_month: int = -1
var last_doctor_checkup_year: int = -1
var last_doctor_vitamin_age: int = -1
var last_doctor_vitamin_month: int = -1
var last_doctor_vitamin_year: int = -1
var last_plastic_surgery_age: int = -1
var last_plastic_surgery_month: int = -1
var last_plastic_surgery_year: int = -1
var last_chemo_age: int = -1
var last_chemo_month: int = -1
var last_chemo_year: int = -1
var last_therapy_age: int = -1
var last_therapy_month: int = -1
var last_therapy_year: int = -1
var last_psychologist_age: int = -1
var last_psychologist_month: int = -1
var last_psychologist_year: int = -1
var last_psychiatrist_age: int = -1
var last_psychiatrist_month: int = -1
var last_psychiatrist_year: int = -1
var last_er_age: int = -1
var last_er_month: int = -1
var last_er_year: int = -1

var last_prison_activity_age: int = -1
var last_prison_activity_month: int = -1
var last_prison_activity_year: int = -1
var last_casino_age: int = -1
var casino_plays_this_year: int = 0
var last_overtime_age: int = -1
var last_overtime_month: int = -1
var last_overtime_year: int = -1
var last_childhood_gig_age: int = -1
var last_childhood_gig_month: int = -1
var last_childhood_gig_year: int = -1

var karma: int = 0
var money: int = 0
var bank_savings: int = 0
var pension_account: Dictionary = {}
var savings_account: Dictionary = {}
var debt: int = 0
var tax_debt: int = 0
var capital_gains_this_year: int = 0
var capital_losses_this_year: int = 0
var freelance_earnings_this_year: int = 0
var social_media_earnings_this_year: int = 0
var charity_donations_this_year: int = 0
var taxes_paid_lifetime: int = 0
var taxes_withheld_this_year: int = 0
var cumulative_salary_paid_this_year: int = 0
var monthly_settlement_cursor: Dictionary = {}
var transaction_history: Array[Dictionary] = []
var last_tax_return: Dictionary = {}
var loan_balance: int = 0
var loan_interest_rate: float = 0.08
var credit_score: int = 650
var has_credit_card: bool = false
var credit_card_tier: String = "None"
var credit_card_limit: int = 0
var credit_card_balance: int = 0
var credit_card_apr: float = 0.18
var credit_card_paid_this_year: int = 0
var owned_assets: Array[Dictionary] = []
var mortgages: Array = []
var rented_property: Dictionary = {}
var siblings: Array = []
var health_insurance: String = "none"
var asset_insurance: Dictionary = {
	"vehicle": false,
	"property": false
}

var education_level: String = "High School"
var grades: int = 75
var has_scholarship: bool = false
var university_years: int = 0
var university_name: String = ""
var university_major: String = ""
var university_major_title: String = ""
var university_degree: String = ""
var university_tuition: int = 12000
var degrees: Array = []
var licenses: Array = []
var active_freelance_jobs: Array = []
var freelance_reputation: Dictionary = {}
var owned_businesses: Array = []
var last_freelance_pitch_age: Dictionary = {}
var last_freelance_pitch_month: Dictionary = {}
var last_freelance_pitch_year: Dictionary = {}
var last_school_activity_age: int = -1
var last_school_activity_month: int = -1
var last_school_activity_year: int = -1
var last_scholarship_applied_age: int = -1
var last_scholarship_applied_month: int = -1
var last_scholarship_applied_year: int = -1
var last_ged_attempt_age: int = -1
var last_ged_attempt_month: int = -1
var last_ged_attempt_year: int = -1
var has_gym_membership: bool = false
var gym_membership_annual_fee: int = 300
var last_gym_activity_age: int = -1
var last_gym_activity_month: int = -1
var last_gym_activity_year: int = -1
var last_meditation_activity_age: int = -1
var last_meditation_activity_month: int = -1
var last_meditation_activity_year: int = -1
var last_salon_activity_age: int = -1
var last_salon_activity_month: int = -1
var last_salon_activity_year: int = -1
var last_spa_activity_age: int = -1
var last_spa_activity_month: int = -1
var last_spa_activity_year: int = -1
var last_dating_app_age: int = -1
var last_dating_app_month: int = -1
var last_dating_app_year: int = -1
var last_pet_adoption_age: int = -1
var last_pet_adoption_month: int = -1
var last_pet_adoption_year: int = -1
var last_charity_donation_age: int = -1
var last_charity_donation_month: int = -1
var last_charity_donation_year: int = -1
var neural_implants: Array = []
var last_neural_overclock_age: int = -1
var last_neural_overclock_month: int = -1
var last_neural_overclock_year: int = -1
var last_neural_diagnostics_age: int = -1
var last_neural_diagnostics_month: int = -1
var last_neural_diagnostics_year: int = -1

var job_id: String = ""
var job_title: String = ""
var job_company: String = ""
var job_salary: int = 0
var job_payment_type: String = "MONTHLY_SALARY"
var career_progress: Dictionary = {}
var underground_progress: Dictionary = {}

# Daily Wage & Gig Employment System
var part_time_job: Dictionary = {}
var daily_wage_last_paid: Dictionary = {"year": 0, "month": 0, "day": 0}
var daily_wage_earnings_this_year: int = 0
var taxable_daily_wages_this_year: int = 0
var daily_job_health_loss_fraction: float = 0.0
var daily_job_mental_loss_fraction: float = 0.0
var gig_earnings_this_year: int = 0
# Shared allowance for all on-demand gig assignments. Four gigs are available
# per calendar month, regardless of the player's other employment.
var gigs_completed_this_month: int = 0
var last_gig_month: Dictionary = {"year": 0, "month": 0}
var gigs_completed_today: int = 0
var last_gig_date: Dictionary = {"year": 0, "month": 0, "day": 0}
var gig_reputation: Dictionary = {}
var gig_history: Array = []
var daily_earnings_log: Array = []

var illnesses: Array = []
var is_dead: bool = false
var cause_of_death: String = ""

var is_in_prison: bool = false
var prison_sentence_years: int = 0

var is_in_mental_institution: bool = false
var mental_institution_years_left: int = 0
var mental_institution_annual_cost: int = 15000

var event_history: Array = []
var event_history_log: Dictionary = {}
var life_log: Array = []

var social_media: Dictionary = {}
var pets: Array = []
var will_recipient: String = "CHILDREN"


func reset() -> void:
	reset_player()


func reset_player() -> void:
	finance_market = {}
	crypto_wallet = {}
	learning_activities = {}
	life_id = Crypto.new().generate_random_bytes(16).hex_encode()
	first_name = ""
	birthplace = ""
	gender = "MALE"
	ethnicity = "white"
	portrait_track = 0
	portrait_variant = 0
	avatar_id = ""
	has_started_game = false
	selected_room_id = "room_capsule"
	has_moved_out_from_parents = false
	current_residence_name = ""
	current_residence_type = "parents"

	birth_story = ""
	birth_year = 2014
	birth_month = "January"
	birth_month_idx = 1
	birth_day = 1
	zodiac = "Capricorn"

	mother_name = ""
	mother_job = ""
	mother_base_age = 35
	mother_relationship = 80
	mother_alive = true
	mother_health = 80
	mother_education = "High School"
	mother_condition = ""
	mother_portrait_track = randi() % 4

	father_name = ""
	father_job = ""
	father_base_age = 37
	father_relationship = 80
	father_alive = true
	father_health = 80
	father_education = "High School"
	father_condition = ""
	father_portrait_track = randi() % 4


	family_wealth = "middle_class"
	life_milestones.clear()

	partner = {}
	ex_partners = []
	friends = []
	intoxication_level = 0
	has_hangover = false
	venue_history = []
	last_parent_interact_age = -1
	last_parent_interact_month = -1
	last_parent_interact_year = -1
	last_mother_spend_time_age = -1
	last_mother_spend_time_month = -1
	last_mother_spend_time_year = -1
	last_mother_compliment_age = -1
	last_mother_compliment_month = -1
	last_mother_compliment_year = -1
	last_mother_ask_money_age = -1
	last_mother_ask_money_month = -1
	last_mother_ask_money_year = -1
	last_father_spend_time_age = -1
	last_father_spend_time_month = -1
	last_father_spend_time_year = -1
	last_father_compliment_age = -1
	last_father_compliment_month = -1
	last_father_compliment_year = -1
	last_father_ask_money_age = -1
	last_father_ask_money_month = -1
	last_father_ask_money_year = -1
	last_partner_interact_age = -1
	last_partner_interact_month = -1
	last_partner_interact_year = -1
	last_partner_spend_time_age = -1
	last_partner_spend_time_month = -1
	last_partner_spend_time_year = -1
	last_partner_compliment_age = -1
	last_partner_compliment_month = -1
	last_partner_compliment_year = -1
	last_partner_gift_age = -1
	last_partner_gift_month = -1
	last_partner_gift_year = -1
	last_partner_propose_age = -1
	last_partner_propose_month = -1
	last_partner_propose_year = -1
	last_breakup_age = -1
	last_breakup_month = -1
	last_breakup_year = -1
	last_baby_age = -1

	last_mother_pay_meds_age = -1
	last_mother_pay_meds_month = -1
	last_mother_pay_meds_year = -1
	last_father_pay_meds_age = -1
	last_father_pay_meds_month = -1
	last_father_pay_meds_year = -1
	last_mother_doctor_checkup_age = -1
	last_mother_doctor_checkup_month = -1
	last_mother_doctor_checkup_year = -1
	last_father_doctor_checkup_age = -1
	last_father_doctor_checkup_month = -1
	last_father_doctor_checkup_year = -1
	last_mother_vitamin_shot_age = -1
	last_mother_vitamin_shot_month = -1
	last_mother_vitamin_shot_year = -1
	last_father_vitamin_shot_age = -1
	last_father_vitamin_shot_month = -1
	last_father_vitamin_shot_year = -1

	last_doctor_checkup_age = -1
	last_doctor_checkup_month = -1
	last_doctor_checkup_year = -1
	last_doctor_vitamin_age = -1
	last_doctor_vitamin_month = -1
	last_doctor_vitamin_year = -1
	last_plastic_surgery_age = -1
	last_plastic_surgery_month = -1
	last_plastic_surgery_year = -1
	last_chemo_age = -1
	last_chemo_month = -1
	last_chemo_year = -1
	last_therapy_age = -1
	last_therapy_month = -1
	last_therapy_year = -1
	last_psychologist_age = -1
	last_psychologist_month = -1
	last_psychologist_year = -1
	last_psychiatrist_age = -1
	last_psychiatrist_month = -1
	last_psychiatrist_year = -1
	last_er_age = -1
	last_er_month = -1
	last_er_year = -1

	last_prison_activity_age = -1
	last_prison_activity_month = -1
	last_prison_activity_year = -1
	last_casino_age = -1
	casino_plays_this_year = 0
	last_overtime_age = -1
	last_overtime_month = -1
	last_overtime_year = -1
	last_childhood_gig_age = -1
	last_childhood_gig_month = -1
	last_childhood_gig_year = -1

	neural_implants.clear()
	last_neural_overclock_age = -1
	last_neural_overclock_month = -1
	last_neural_overclock_year = -1
	last_neural_diagnostics_age = -1
	last_neural_diagnostics_month = -1
	last_neural_diagnostics_year = -1

	age = 17
	in_game_day = 1
	in_game_month = 1
	in_game_year = 2026
	is_time_paused = false
	day_accumulator = 0.0

	health = 80
	happiness = 75
	smarts = 60
	looks = 65
	mental_state = 80

	karma = 0
	money = 0
	bank_savings = 0
	pension_account = {}
	savings_account = {}
	preload("res://scripts/economy/pension_and_savings_manager.gd").ensure(self)
	debt = 0
	tax_debt = 0
	capital_gains_this_year = 0
	capital_losses_this_year = 0
	freelance_earnings_this_year = 0
	social_media_earnings_this_year = 0
	charity_donations_this_year = 0
	taxes_paid_lifetime = 0
	taxes_withheld_this_year = 0
	cumulative_salary_paid_this_year = 0
	monthly_settlement_cursor.clear()
	transaction_history.clear()
	last_tax_return.clear()
	active_stat_modifiers.clear()
	loan_balance = 0
	loan_interest_rate = 0.08
	credit_score = 650
	has_credit_card = false
	credit_card_tier = "None"
	credit_card_limit = 0
	credit_card_balance = 0
	credit_card_apr = 0.18
	credit_card_paid_this_year = 0
	owned_assets.clear()
	mortgages.clear()
	rented_property.clear()
	siblings.clear()
	grant_starting_assets()
	health_insurance = "none"
	asset_insurance = { "vehicle": false, "property": false }

	education_level = "High School"
	grades = 75
	has_scholarship = false
	university_years = 0
	university_name = ""
	university_major = ""
	university_major_title = ""
	university_degree = ""
	university_tuition = 12000
	last_school_activity_age = -1
	last_school_activity_month = -1
	last_school_activity_year = -1
	last_scholarship_applied_age = -1
	last_scholarship_applied_month = -1
	last_scholarship_applied_year = -1
	last_ged_attempt_age = -1
	last_ged_attempt_month = -1
	last_ged_attempt_year = -1
	has_gym_membership = false
	gym_membership_annual_fee = 300
	last_gym_activity_age = -1
	last_gym_activity_month = -1
	last_gym_activity_year = -1
	last_meditation_activity_age = -1
	last_meditation_activity_month = -1
	last_meditation_activity_year = -1
	last_salon_activity_age = -1
	last_salon_activity_month = -1
	last_salon_activity_year = -1
	last_spa_activity_age = -1
	last_spa_activity_month = -1
	last_spa_activity_year = -1
	last_dating_app_age = -1
	last_dating_app_month = -1
	last_dating_app_year = -1
	last_pet_adoption_age = -1
	last_pet_adoption_month = -1
	last_pet_adoption_year = -1
	last_charity_donation_age = -1
	last_charity_donation_month = -1
	last_charity_donation_year = -1

	job_id = ""
	job_title = ""
	job_company = ""
	job_salary = 0
	job_payment_type = "MONTHLY_SALARY"
	career_progress = {}
	underground_progress = {}
	part_time_job = {}
	daily_wage_last_paid = {"year": 0, "month": 0, "day": 0}
	daily_wage_earnings_this_year = 0
	taxable_daily_wages_this_year = 0
	daily_job_health_loss_fraction = 0.0
	daily_job_mental_loss_fraction = 0.0
	gig_earnings_this_year = 0
	gigs_completed_this_month = 0
	last_gig_month = {"year": 0, "month": 0}
	gigs_completed_today = 0
	last_gig_date = {"year": 0, "month": 0, "day": 0}
	gig_reputation = {}
	gig_history.clear()
	daily_earnings_log.clear()

	illnesses.clear()
	is_dead = false
	cause_of_death = ""

	is_in_prison = false
	prison_sentence_years = 0

	is_in_mental_institution = false
	mental_institution_years_left = 0
	mental_institution_annual_cost = 15000

	event_history.clear()
	event_history_log.clear()
	life_log.clear()
	degrees.clear()
	licenses.clear()
	active_freelance_jobs.clear()
	freelance_reputation.clear()
	owned_businesses.clear()
	last_freelance_pitch_age.clear()
	last_freelance_pitch_month.clear()
	last_freelance_pitch_year.clear()
	children.clear()
	pregnancy = {}
	active_debuffs.clear()
	active_buffs.clear()
	total_donated_charity = 0
	charity_donations_count = 0
	social_media.clear()
	pets.clear()
	will_recipient = "CHILDREN"


func _extract_leading_emoji(text: String) -> Dictionary:
	var t := text.strip_edges()
	var emojis := [
		"🚀", "📜", "🎓", "👶", "🍼", "💼", "🎖️", "🎖", "💍", "🏡", "✈️", "✈",
		"🧸", "🎒", "🏫", "📘", "🎾", "🦮", "🩺", "🌈", "📱", "☑️", "⚠️", "📈",
		"💬", "🗑️", "🏛️", "🏦", "💰", "💵", "⚖️", "✨", "🌟", "🏢", "🏆"
	]
	for e in emojis:
		if t.begins_with(e):
			var rem := t.substr(e.length()).strip_edges()
			return {"emoji": e, "text": rem}
	return {"emoji": "", "text": t}


func _detect_milestone_icon(text: String) -> String:
	var l := text.to_lower()
	if "flight school" in l or "pilot" in l or "aviation" in l or "flight" in l:
		return "✈️"
	if "enterprise" in l or "founded" in l or "incorporated" in l or "business" in l:
		return "🏢"
	if "graduated" in l or "degree" in l or "diploma" in l or "scholarship" in l:
		return "🎓"
	if "kindergarten" in l:
		return "🧸"
	if "primary school" in l or "middle school" in l or "high school" in l or "school" in l:
		return "🎒"
	if "born" in l or "baby" in l or "child" in l:
		return "🍼"
	if "married" in l or "wedding" in l:
		return "💍"
	if "promoted" in l or "promotion" in l:
		return "🎖️"
	if "started career" in l or "started working" in l or "freelance" in l or "job" in l:
		return "💼"
	if "real estate" in l or "house" in l or "apartment" in l or "property" in l:
		return "🏡"
	if "license" in l:
		return "📜"
	if "passed away" in l:
		return "🌈"
	if "will" in l or "beneficiary" in l:
		return "⚖️"
	if "social media" in l or "verified" in l:
		return "📱"
	if "pet" in l:
		return "🦮"
	return "🏆"


func is_life_milestone(entry: Dictionary) -> bool:
	if str(entry.get("kind", "")) == "milestone":
		return true

	var txt := str(entry.get("text", "")).to_lower()
	if "born" in txt and ("world" in txt or "parents" in txt or "hospital" in txt or "birth" in txt or "born in" in txt):
		return true
	if "enrolled in kindergarten" in txt or "enrolled in primary" in txt:
		return true
	if "entered primary school" in txt or "entered middle school" in txt or "entered high school" in txt:
		return true
	if "graduated from high school" in txt or "graduated from university" in txt or "graduated from" in txt:
		return true
	if "diploma earned" in txt or "degree:" in txt:
		return true
	if "enrolled at" in txt or "enrolled in university" in txt:
		return true
	if "started working as" in txt or "started career as" in txt:
		return true
	if "promoted to" in txt:
		return true
	if "enterprise incorporated" in txt or "founded enterprise" in txt or "founded '" in txt or "business sold" in txt:
		return true
	if "flight school" in txt or "license exam passed" in txt or ("earned your" in txt and "license" in txt):
		return true
	if "freelance roster" in txt:
		return true
	if "verified creator" in txt:
		return true
	if "married" in txt or "wedding" in txt or "welcomed baby" in txt or "gave birth" in txt:
		return true
	if "purchased real estate" in txt:
		return true
	if "passed away" in txt:
		return true
	if "scholarship awarded" in txt:
		return true
	if "released from prison" in txt:
		return true
	if "diagnosed with" in txt:
		return true
	if "cured of" in txt:
		return true
	if "notarized will" in txt:
		return true

	return false


func add_milestone(m_text: String, milestone_age: int = -1, icon: String = "🏆") -> void:
	var raw_text := m_text.strip_edges()
	if raw_text == "":
		return

	var a: int = age if milestone_age < 0 else milestone_age
	var extracted := _extract_leading_emoji(raw_text)
	var final_icon := icon
	var clean_text := str(extracted.get("text", raw_text))

	if str(extracted.get("emoji", "")) != "":
		final_icon = str(extracted.get("emoji"))
	elif final_icon == "" or final_icon == "🏆":
		final_icon = _detect_milestone_icon(clean_text)

	var c_lower := clean_text.to_lower()
	for m in life_milestones:
		if not (m is Dictionary):
			continue
		var existing_age: int = int(m.get("age", -1))
		if existing_age == a:
			var existing_text: String = str(m.get("text", "")).strip_edges()
			if existing_text == clean_text or existing_text == raw_text:
				return
			var e_lower := existing_text.to_lower()
			if e_lower == c_lower:
				return
			if ("flight school" in e_lower and "flight school" in c_lower) or \
			   ("kindergarten" in e_lower and "kindergarten" in c_lower) or \
			   ("high school" in e_lower and "high school" in c_lower and "graduated" in e_lower and "graduated" in c_lower):
				return
			if "enterprise incorporated" in c_lower and "founded" in e_lower:
				m["text"] = clean_text
				m["icon"] = final_icon
				return
			if "founded" in c_lower and "enterprise incorporated" in e_lower:
				return

	life_milestones.append({
		"text": clean_text,
		"age": a,
		"icon": final_icon
	})

	life_milestones.sort_custom(func(x, y):
		return int(x.get("age", 0)) < int(y.get("age", 0))
	)


func sync_milestones_from_log() -> void:
	for entry in life_log:
		if entry is Dictionary and is_life_milestone(entry):
			var entry_text: String = str(entry.get("text", "")).strip_edges()
			var entry_age: int = int(entry.get("age", 0))
			if entry_text != "":
				add_milestone(entry_text, entry_age)


func has_license(license_id: String) -> bool:
	return licenses.has(license_id)


func grant_license(license_id: String) -> void:
	if not licenses.has(license_id):
		licenses.append(license_id)


func add_license(license_id: String) -> void:
	grant_license(license_id)


func has_degree(major_or_title: String) -> bool:
	var target := major_or_title.to_lower()
	if education_level == "University Graduate":
		if university_major.to_lower() == target or university_major_title.to_lower().contains(target):
			return true
	for d in degrees:
		if d is Dictionary:
			var d_major: String = str(d.get("major", "")).to_lower()
			var d_title: String = str(d.get("major_title", "")).to_lower()
			if d_major == target or d_major.contains(target) or d_title.contains(target):
				return true
	return false


func is_doctor() -> bool:
	var j_id := job_id.to_lower()
	var j_title := job_title.to_lower()
	return "doctor" in j_id or "doctor" in j_title or "surgeon" in j_id or "surgeon" in j_title or "physician" in j_title


func get_letter_grade() -> String:
	if grades >= 93:
		return "A+"
	elif grades >= 85:
		return "A"
	elif grades >= 75:
		return "B"
	elif grades >= 65:
		return "C"
	elif grades >= 55:
		return "D"
	elif grades > 0:
		return "F (Failing)"
	else:
		return "0% (Course Required)"


func get_gpa() -> float:
	return snappedf(clampf(float(grades) / 25.0, 0.0, 4.0), 0.01)


func get_grades_gain_multiplier() -> float:
	# Direct scaling based on smartness:
	# Lower smartness = harder grades gain (e.g. 0-25 smarts -> 0.35x-0.675x multiplier)
	# Baseline smartness (50 smarts) = 1.00x standard multiplier
	# Higher smartness = easier grades gain (e.g. 75-100 smarts -> 1.325x-1.65x multiplier)
	var s_clamped: float = clampf(float(smarts), 0.0, 100.0)
	return 0.35 + 1.30 * (s_clamped / 100.0)


func calculate_grades_gain(base_gain: int) -> int:
	if base_gain <= 0:
		return 0
	var mult: float = get_grades_gain_multiplier()
	return maxi(1, int(round(float(base_gain) * mult)))



func get_education_display_string() -> String:
	match education_level:
		"None":
			return "None (Early Childhood)" if age < 3 else "No Formal Education"
		"Kindergarten":
			return "Kindergarten"
		"Primary School":
			return "Primary School (Elementary)"
		"Middle School":
			return "Middle School (Junior High)"
		"High School":
			return "High School"
		"High School Dropout":
			return "High School Dropout (No Diploma)"
		"High School Graduate":
			return "High School Graduate (Diploma)"
		"University Student":
			var yr_str := "Year %d of 4" % maxi(1, university_years + 1)
			if university_name != "" and university_major_title != "":
				return "University Student (%s - %s @ %s)" % [yr_str, university_major_title, university_name]
			elif university_name != "":
				return "University Student (%s @ %s)" % [yr_str, university_name]
			else:
				return "University Student (%s)" % yr_str
		"University Graduate":
			if university_degree != "" and university_name != "":
				return "%s (%s)" % [university_degree, university_name]
			elif university_major_title != "":
				return "Bachelor's Degree in %s" % university_major_title
			else:
				return "University Graduate (Bachelor's Degree)"
		"University Dropout":
			if degrees.size() > 0:
				var last_deg: Dictionary = degrees[-1] if degrees[-1] is Dictionary else {}
				var d_title: String = str(last_deg.get("degree", "Degree"))
				var m_title: String = str(last_deg.get("major_title", "Major"))
				return "%s in %s (University Dropout)" % [d_title, m_title]
			return "University Dropout (College Leaver)"
		_:
			return education_level


func has_major(major_id: String) -> bool:
	var m := major_id.to_lower()
	if university_major.to_lower() == m:
		return true
	for deg in degrees:
		if deg is Dictionary and str(deg.get("major", "")).to_lower() == m:
			return true
	return false


func has_completed_degree() -> bool:
	return education_level == "University Graduate" or degrees.size() > 0


func get_total_asset_value() -> int:
	var total: int = 0
	for item in owned_assets:
		total += int(item.get("current_value", item.get("purchase_price", 0)))
	return total


func can_afford(cost: int) -> bool:
	return cost >= 0 and get_available_funds() >= cost


func get_available_funds() -> int:
	return money + bank_savings


func deposit_cash(amount: int) -> int:
	var moved := mini(maxi(0, amount), money)
	money -= moved
	bank_savings += moved
	return moved


func withdraw_cash(amount: int) -> int:
	var moved := mini(maxi(0, amount), bank_savings)
	bank_savings -= moved
	money += moved
	return moved


func receive_salary(amount: int) -> void:
	bank_savings += maxi(0, amount)


func debit_funds(cost: int) -> bool:
	if not can_afford(cost):
		return false
	if bank_savings >= cost:
		bank_savings -= cost
	else:
		var rem: int = cost - bank_savings
		bank_savings = 0
		money -= rem
	return true


func debit_funds_with_debt_fallback(amount: int) -> Dictionary:
	if amount <= 0:
		return {"paid": 0, "shortfall": 0}
	var total_avail: int = money + bank_savings
	if total_avail >= amount:
		debit_funds(amount)
		return {"paid": amount, "shortfall": 0}
	else:
		var paid: int = total_avail
		var shortfall: int = amount - paid
		money = 0
		bank_savings = 0
		debt += shortfall
		return {"paid": paid, "shortfall": shortfall}


func record_transaction(category: String, amount: int, description: String, date_str: String = "") -> void:
	if date_str == "":
		date_str = get_date_string()
	var entry := {
		"date": date_str,
		"age": age,
		"category": category,
		"amount": amount,
		"type": "income" if amount > 0 else "expense",
		"description": description,
		"balance_after": get_available_funds(),
		"debt_after": get_total_debt()
	}
	transaction_history.append(entry)
	if transaction_history.size() > 500:
		transaction_history.pop_front()


func get_transaction_history() -> Array[Dictionary]:
	return transaction_history


func get_insurance_discount() -> float:
	match health_insurance:
		"bronze":
			return 0.05
		"gold":
			return 0.10
		"platinum":
			return 0.25
		_:
			return 0.0


func get_insurance_tier_name() -> String:
	match health_insurance:
		"bronze":
			return "Bronze"
		"gold":
			return "Gold"
		"platinum":
			return "Platinum"
		_:
			return "None"


func get_net_worth() -> int:
	var business_value := 0
	for business in owned_businesses:
		business_value += int(maxi(0, int(business.get("valuation", 0)) + int(business.get("treasury", 0)) - int(business.get("loan_balance", 0)) - int(business.get("unpaid_taxes", 0))) * float(business.get("owner_fraction", 1.0)))
	var crypto_val: int = preload("res://scripts/economy/crypto_market.gd").portfolio_value(self)
	var pension_val: int = int(pension_account.get("balance", 0))
	var savings_val: int = int(savings_account.get("balance", 0))
	return money + bank_savings + savings_val + pension_val + get_total_asset_value() + business_value + preload("res://scripts/economy/finance_market.gd").portfolio_value(self) + crypto_val - get_total_debt()


func get_personal_net_worth() -> int:
	# Strictly personal net worth: Business valuation DOES NOT count as a player asset or personal net worth for credit cards
	var crypto_val: int = preload("res://scripts/economy/crypto_market.gd").portfolio_value(self)
	var pension_val: int = int(pension_account.get("balance", 0))
	var savings_val: int = int(savings_account.get("balance", 0))
	return money + bank_savings + savings_val + pension_val + get_total_asset_value() + preload("res://scripts/economy/finance_market.gd").portfolio_value(self) + crypto_val - get_total_debt()


func grant_starting_assets() -> void:
	for asset in owned_assets:
		if str(asset.get("category", "")) == "properties":
			return
	var starter: Dictionary = AssetCatalog.create_asset_instance("prop_capsule", age)
	if not starter.is_empty():
		owned_assets.append(starter)


func get_owned_assets_by_category(category: String) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for item in owned_assets:
		if item.get("category", "") == category:
			list.append(item)
	return list


func modify_health(delta: int) -> void:
	health = clampi(health + delta, 0, 100)
	enforce_buffs_and_debuffs()


func modify_happiness(delta: int) -> void:
	happiness = clampi(happiness + delta, 0, 100)
	enforce_buffs_and_debuffs()


func apply_intoxication(delta: int) -> int:
	intoxication_level = clampi(intoxication_level + delta, 0, 100)
	return intoxication_level


func clear_intoxication() -> void:
	intoxication_level = 0


func record_venue_visit(venue_id: String, activity_id: String = "", spent: int = 0) -> void:
	var entry := {
		"venue_id": venue_id,
		"activity_id": activity_id,
		"spent": spent,
		"age": age,
		"month": in_game_month,
		"year": in_game_year,
		"day": in_game_day
	}
	venue_history.append(entry)
	if venue_history.size() > 50:
		venue_history.pop_front()


func process_daily_venues_and_intoxication() -> Dictionary:
	var hangover_triggered: bool = false
	var hangover_cleared: bool = false

	if has_hangover:
		has_hangover = false
		hangover_cleared = true

	if intoxication_level >= 50:
		has_hangover = true
		hangover_triggered = true
		intoxication_level = 0
		modify_health(-10)
		modify_happiness(-15)
	else:
		intoxication_level = 0

	return {
		"hangover_triggered": hangover_triggered,
		"hangover_cleared": hangover_cleared,
		"current_intoxication": intoxication_level,
		"has_hangover": has_hangover
	}


func has_firearm() -> bool:
	for item in owned_assets:
		if str(item.get("category", "")) == "firearms":
			return true
	return false


func get_owned_firearms() -> Array[Dictionary]:
	return get_owned_assets_by_category("firearms")


func has_asset_insurance(category: String) -> bool:
	return bool(asset_insurance.get(category, false))


func set_asset_insurance(category: String, active: bool) -> void:
	asset_insurance[category] = active


func has_illness(illness_id: String) -> bool:
	for ill in illnesses:
		if ill is Dictionary and ill.get("id", "") == illness_id:
			return true
	return false


func get_illness(illness_id: String) -> Dictionary:
	for ill in illnesses:
		if ill is Dictionary and ill.get("id", "") == illness_id:
			return ill
	return {}


func add_illness(illness_id: String, illness_name: String, stage: int = 1) -> void:
	if has_illness(illness_id):
		return
	illnesses.append({
		"id": illness_id,
		"name": illness_name,
		"stage": stage
	})


func cure_illness(illness_id: String) -> bool:
	for i in range(illnesses.size() - 1, -1, -1):
		var ill: Dictionary = illnesses[i]
		if ill.get("id", "") == illness_id:
			illnesses.remove_at(i)
			return true
	return false


func get_total_debt() -> int:
	var mortgage_debt := 0
	for m in mortgages:
		if m is Dictionary:
			mortgage_debt += int(m.get("remaining_principal", 0))
	return debt + tax_debt + loan_balance + credit_card_balance + mortgage_debt


func has_active_mortgage() -> bool:
	return mortgages.size() > 0


func get_mortgage_for_asset(instance_id: String) -> Dictionary:
	for m in mortgages:
		if m is Dictionary and str(m.get("instance_id", "")) == instance_id:
			return m
	return {}


func has_rented_property() -> bool:
	return not rented_property.is_empty() and str(rented_property.get("id", "")) != ""


func take_bank_loan(amount: int, interest_rate: float) -> bool:
	if loan_balance > 0 or amount <= 0 or interest_rate < 0.0 or not is_finite(interest_rate):
		return false
	money += amount
	loan_balance = amount
	loan_interest_rate = interest_rate
	return true


func repay_bank_loan(amount: int) -> int:
	if amount <= 0 or loan_balance <= 0 or get_available_funds() <= 0:
		return 0
	var paid := mini(amount, mini(get_available_funds(), loan_balance))
	debit_funds(paid)
	loan_balance -= paid
	if loan_balance == 0:
		modify_credit_score(20)
	else:
		modify_credit_score(5)
	return paid


func pay_outstanding_tax(amount: int = -1) -> int:
	if tax_debt <= 0 or not can_afford(1):
		return 0
	var to_pay := tax_debt if (amount <= 0 or amount > tax_debt) else amount
	to_pay = mini(to_pay, get_available_funds())
	if to_pay <= 0:
		return 0
	debit_funds(to_pay)
	tax_debt -= to_pay
	taxes_paid_lifetime += to_pay
	if tax_debt == 0:
		modify_credit_score(25)
	else:
		modify_credit_score(10)
	return to_pay


func modify_credit_score(delta: int) -> void:
	credit_score = clampi(credit_score + delta, 300, 850)


func get_credit_rating() -> String:
	if credit_score >= 800:
		return "Exceptional"
	elif credit_score >= 740:
		return "Very Good"
	elif credit_score >= 670:
		return "Good"
	elif credit_score >= 580:
		return "Fair"
	else:
		return "Poor"


func get_credit_score_color() -> Color:
	var is_light: bool = false
	var lib = Engine.get_singleton("LifeLibrary") if Engine.has_singleton("LifeLibrary") else null
	if lib != null and lib.data != null:
		is_light = lib.data.get("theme", "dark") == "light"
	elif has_node("/root/LifeLibrary"):
		is_light = get_node("/root/LifeLibrary").data.get("theme", "dark") == "light"

	if credit_score >= 800:
		return Color("#15803d") if is_light else Color("#10b981")
	elif credit_score >= 740:
		return Color("#16a34a") if is_light else Color("#22c55e")
	elif credit_score >= 670:
		return Color("#0284c7") if is_light else Color("#38bdf8")
	elif credit_score >= 580:
		return Color("#b45309") if is_light else Color("#f59e0b")
	else:
		return Color("#dc2626") if is_light else Color("#ef4444")


func get_credit_card_available() -> int:
	if not has_credit_card:
		return 0
	return maxi(0, credit_card_limit - credit_card_balance)


func can_apply_credit_card(tier: String) -> Dictionary:
	if age < 18:
		return {"eligible": false, "reason": "Declined: You must be at least 18 years old to apply for a credit card."}
	
	# Strict debt checks: character must have zero debt, zero unpaid taxes, zero active loans, zero credit card debt
	if debt > 0 or tax_debt > 0 or loan_balance > 0 or credit_card_balance > 0:
		return {"eligible": false, "reason": "Declined: Application rejected due to outstanding debt, unpaid taxes, or active loans. All liabilities must be $0."}
	
	var nw: int = get_personal_net_worth()
	match tier.to_lower():
		"silver":
			if credit_score < 600:
				return {"eligible": false, "reason": "Declined: Silver card requires minimum 600 credit score (Your score: %d)." % credit_score}
			if nw < 5000:
				return {"eligible": false, "reason": "Declined: Silver card requires minimum $5,000 personal net worth (Your personal net worth: $%d)." % nw}
			return {"eligible": true, "reason": "Approved for Silver Card"}
		"gold":
			if credit_score < 700:
				return {"eligible": false, "reason": "Declined: Gold card requires minimum 700 credit score (Your score: %d)." % credit_score}
			if nw < 30000:
				return {"eligible": false, "reason": "Declined: Gold card requires minimum $30,000 personal net worth (Your personal net worth: $%d)." % nw}
			return {"eligible": true, "reason": "Approved for Gold Card"}
		"platinum":
			if credit_score < 780:
				return {"eligible": false, "reason": "Declined: Platinum card requires minimum 780 credit score (Your score: %d)." % credit_score}
			if nw < 150000:
				return {"eligible": false, "reason": "Declined: Platinum card requires minimum $150,000 personal net worth (Your personal net worth: $%d)." % nw}
			return {"eligible": true, "reason": "Approved for Platinum Card"}
		_:
			return {"eligible": false, "reason": "Declined: Unknown credit card tier."}


func calculate_dynamic_credit_limit(tier: String = "") -> int:
	var t: String = tier.to_lower()
	if t.is_empty():
		t = credit_card_tier.to_lower() if has_credit_card and credit_card_tier != "" and credit_card_tier != "None" else "silver"

	var base_limit: int = 5000
	var max_limit: int = 35000
	match t:
		"gold":
			base_limit = 25000
			max_limit = 150000
		"platinum":
			base_limit = 100000
			max_limit = 1000000
		_: # silver
			base_limit = 5000
			max_limit = 35000

	# Dynamic calculation from allowance (salary), personal assets, and personal net worth (excluding business valuation)
	var allowance_contrib: int = int(maxi(0, job_salary) * 0.50)
	var assets_contrib: int = int(maxi(0, get_total_asset_value()) * 0.15)
	var nw_contrib: int = int(maxi(0, get_personal_net_worth()) * 0.10)
	var tax_penalty: int = tax_debt * 2

	var calculated: int = base_limit + allowance_contrib + assets_contrib + nw_contrib - tax_penalty
	var rounded: int = int(round(float(calculated) / 500.0) * 500)
	return clampi(rounded, base_limit, max_limit)


func approve_credit_card(tier: String) -> bool:
	var check := can_apply_credit_card(tier)
	if not bool(check.get("eligible", false)):
		return false
	
	has_credit_card = true
	match tier.to_lower():
		"silver":
			credit_card_tier = "Silver"
			credit_card_apr = 0.18
		"gold":
			credit_card_tier = "Gold"
			credit_card_apr = 0.15
		"platinum":
			credit_card_tier = "Platinum"
			credit_card_apr = 0.12
		_:
			return false
	
	credit_card_limit = calculate_dynamic_credit_limit(tier)
	credit_card_balance = 0
	credit_card_paid_this_year = 0
	modify_credit_score(10)
	return true


func request_credit_limit_increase() -> Dictionary:
	if not has_credit_card:
		return {"success": false, "message": "You do not have an active credit card account."}
	if credit_card_balance > 0:
		return {"success": false, "message": "Cannot request limit increase while carrying unpaid usage. Pay off card balance first."}
	if tax_debt > 0 or debt > 0:
		return {"success": false, "message": "Limit increase rejected due to outstanding debt or unpaid taxes."}
	
	var new_limit := calculate_dynamic_credit_limit(credit_card_tier)
	if new_limit > credit_card_limit:
		var old_limit := credit_card_limit
		credit_card_limit = new_limit
		modify_credit_score(10)
		return {
			"success": true,
			"old_limit": old_limit,
			"new_limit": new_limit,
			"message": "Limit increase approved! Raised from $%d to $%d based on your updated allowance, assets, and personal net worth." % [old_limit, new_limit]
		}
	else:
		return {
			"success": false,
			"message": "Limit increase request reviewed. Your current limit of $%d already matches or exceeds the allowable ceiling based on your current monthly allowance ($%d/mo) and personal assets ($%d)." % [credit_card_limit, int(round(float(job_salary) / 12.0)), get_total_asset_value()]
		}


func deactivate_credit_card_on_default() -> Dictionary:
	if not has_credit_card:
		return {"deactivated": false, "unpaid_usage": 0}
	var unpaid := credit_card_balance
	debt += unpaid
	credit_card_balance = 0
	has_credit_card = false
	credit_card_tier = "None"
	credit_card_limit = 0
	credit_card_paid_this_year = 0
	modify_credit_score(-75)
	return {
		"deactivated": true,
		"unpaid_usage": unpaid
	}


func draw_credit_card_advance(_amount: int) -> bool:
	# STRICT POLICY: Converting credit card limit into cash or liquid savings is prohibited
	return false


func charge_credit_card(amount: int) -> bool:
	if not has_credit_card or amount <= 0 or amount > get_credit_card_available():
		return false
	credit_card_balance += amount
	if float(credit_card_balance) / float(maxi(1, credit_card_limit)) > 0.8:
		modify_credit_score(-5)
	return true


func repay_credit_card(amount: int) -> int:
	if not has_credit_card or amount <= 0 or credit_card_balance <= 0 or get_available_funds() <= 0:
		return 0
	var paid := mini(amount, mini(get_available_funds(), credit_card_balance))
	debit_funds(paid)
	credit_card_balance -= paid
	credit_card_paid_this_year += paid
	if credit_card_balance == 0:
		modify_credit_score(15)
	else:
		modify_credit_score(mini(10, maxi(3, int(paid / 1000))))
	return paid


func cancel_credit_card() -> bool:
	if not has_credit_card or credit_card_balance > 0:
		return false
	has_credit_card = false
	credit_card_tier = "None"
	credit_card_limit = 0
	credit_card_apr = 0.18
	credit_card_paid_this_year = 0
	return true


func get_stage_name() -> String:
	if age == 0:
		return "Infant"
	elif age <= 4:
		return "Toddler"
	elif age <= 12:
		return "Child"
	elif age <= 19:
		return "Teenager"
	elif age <= 64:
		return "Adult"
	else:
		return "Elder"


func get_stage_icon() -> String:
	if age == 0:
		return "🍼"
	elif age <= 4:
		return "🧸"
	elif age <= 12:
		return "🎒"
	elif age <= 19:
		return "🎧"
	elif age <= 64:
		return "💼"
	else:
		return "👓"


func get_stats() -> Dictionary:
	return {
		"health": health,
		"happiness": happiness,
		"smarts": smarts,
		"looks": looks,
		"mental_state": mental_state,
		"karma": karma,
		"underground_completed": int(underground_progress.get("completed", 0)),
		"has_firearm": has_firearm()
	}


func apply_effects(effects: Dictionary) -> void:
	health += int(effects.get("health", 0))
	happiness += int(effects.get("happiness", 0))
	smarts += int(effects.get("smarts", 0))
	looks += int(effects.get("looks", 0))
	if effects.has("mental_state"):
		mental_state += int(effects.get("mental_state", 0))
	karma += int(effects.get("karma", 0))

	if effects.has("grades"):
		var raw_grade: int = int(effects.get("grades", 0))
		if raw_grade > 0:
			grades = clamp(grades + calculate_grades_gain(raw_grade), 0, 100)
		else:
			grades = clamp(grades + raw_grade, 0, 100)
		last_school_activity_age = age

	if effects.has("bank_savings"):
		bank_savings = maxi(0, bank_savings + int(effects.get("bank_savings", 0)))

	var delta_money: int = int(effects.get("money", 0))
	if delta_money >= 0:
		money += delta_money
	else:
		if money + delta_money >= 0:
			money += delta_money
		else:
			var deficit: int = -(money + delta_money)
			money = 0
			if bank_savings >= deficit:
				bank_savings -= deficit
			else:
				var unpaid: int = deficit - bank_savings
				bank_savings = 0
				debt += unpaid

	health = clamp(health, 0, 100)
	happiness = clamp(happiness, 0, 100)
	smarts = clamp(smarts, 0, 100)
	looks = clamp(looks, 0, 100)
	mental_state = clamp(mental_state, 0, 100)
	karma = clamp(karma, -100, 100)
	grades = clamp(grades, 0, 100)

	enforce_buffs_and_debuffs()



static func sanitize_stat_spoilers(text: String) -> String:
	var s := text
	# Remove parenthetical stat deltas, e.g. "(Health -12%, Happiness -8%)", "(Happiness +8)"
	var reg_paren := RegEx.new()
	reg_paren.compile("\\s*\\(\\s*(?:Health|Happiness|Smarts|Looks|Grades|Relationship|Partner happiness|Pet Health|Academic Marks|Academic sharpness)\\s*[:+-]\\s*\\d+%?(?:\\s*[,•&]\\s*(?:Health|Happiness|Smarts|Looks|Grades|Relationship|Partner happiness|Pet Health|Academic Marks|Academic sharpness)\\s*[:+-]?\\s*\\d*%?)*\\s*\\)")
	s = reg_paren.sub(s, "", true)

	# Remove unparenthesized stat delta phrases, e.g. "Smarts +2, Happiness +2."
	var reg_stat := RegEx.new()
	reg_stat.compile("\\b(?:Health|Happiness|Smarts|Looks|Grades|Relationship|Partner happiness|Pet Health)\\s*[:+-]\\s*\\d+%?")
	s = reg_stat.sub(s, "", true)

	# Clean up leftover comma-chains, dangling punctuation, or trailing exclamation/dots
	var reg_cleanup := RegEx.new()
	reg_cleanup.compile("[,;]\\s*[,;]+")
	s = reg_cleanup.sub(s, ",", true)
	reg_cleanup.compile("\\s*[,;]\\s*(\\.|!|\\?)")
	s = reg_cleanup.sub(s, "$1", true)
	reg_cleanup.compile("\\(\\s*\\)")
	s = reg_cleanup.sub(s, "", true)
	reg_cleanup.compile("\\s{2,}")
	s = reg_cleanup.sub(s, " ", true)
	return s.strip_edges()


func add_life_log_entry(text: String, kind: String = "event") -> void:
	var clean_text := sanitize_stat_spoilers(text).strip_edges()
	if clean_text == "":
		return

	if not life_log.is_empty():
		var last_entry: Dictionary = life_log.back()
		if int(last_entry.get("age", -1)) == age and str(last_entry.get("text", "")).strip_edges() == clean_text:
			return

	var entry := {
		"age": age,
		"text": clean_text,
		"kind": kind
	}
	life_log.append(entry)

	if is_life_milestone(entry):
		add_milestone(clean_text, age)


func has_seen_event(event_id: String) -> bool:
	return event_history.has(event_id)


func record_event(event_id: String, event_age: int = -1) -> void:
	if event_id == "":
		return

	if not event_history.has(event_id):
		event_history.append(event_id)
	var rec_age: int = event_age if event_age >= 0 else age
	event_history_log[event_id] = rec_age


func calculate_mental_state_drift() -> int:
	# 1. Base equilibrium: Average of the 4 core attributes
	var avg_stats: float = (float(health) + float(happiness) + float(smarts) + float(looks)) / 4.0

	# 2. Deficit drag penalties: severe deficiencies cause chronic psychological distress
	# Example: High smarts & happiness, but severely low looks (< 40) causes persistent insecurity and mental deterioration
	var drag: float = 0.0
	if health < 50:
		drag += (50.0 - float(health)) * 0.35
	if looks < 50:
		drag += (50.0 - float(looks)) * 0.40 # appearance distress / insecurity
	if smarts < 40:
		drag += (40.0 - float(smarts)) * 0.30
	if happiness < 45:
		drag += (45.0 - float(happiness)) * 0.45

	# Real-world chronic external stressors
	if get_total_debt() > 20000:
		drag += minf(15.0, float(get_total_debt() - 20000) / 6000.0)
	if is_in_prison:
		drag += 12.0
	if not illnesses.is_empty():
		drag += minf(16.0, float(illnesses.size()) * 5.0)

	var target_equilibrium: float = clampf(avg_stats - drag, 5.0, 100.0)

	# 3. Drift smoothly towards target equilibrium (approx 15% of gap per year)
	var diff: float = target_equilibrium - float(mental_state)
	var shift: int = int(round(diff * 0.15))
	if shift == 0 and abs(diff) > 2.5:
		shift = 1 if diff > 0 else -1
	return shift


func has_partner() -> bool:
	return partner != null and not partner.is_empty() and bool(partner.get("is_alive", false))


func get_partner_name() -> String:
	return str(partner.get("name", ""))


func get_partner_status() -> String:
	return str(partner.get("status", "Partner"))


func get_partner_relationship() -> int:
	return int(partner.get("relationship", 0))


func set_partner_relationship(val: int) -> void:
	if has_partner():
		partner["relationship"] = clampi(val, 0, 100)


func get_friends() -> Array:
	return friends


func has_friends() -> bool:
	return not friends.is_empty()


func add_friend(friend_data: Dictionary) -> bool:
	if friend_data.is_empty():
		return false
	var friend_id: String = str(friend_data.get("id", ""))
	if friend_id == "":
		friend_id = "friend_%d_%d" % [Time.get_ticks_msec(), randi() % 10000]
		friend_data["id"] = friend_id
	for f in friends:
		if f is Dictionary and str(f.get("id", "")) == friend_id:
			return false
	if not friend_data.has("relationship"):
		friend_data["relationship"] = 50
	if not friend_data.has("last_spend_time_month"):
		friend_data["last_spend_time_month"] = -1
		friend_data["last_spend_time_year"] = -1
		friend_data["last_spend_time_age"] = -1
	if not friend_data.has("last_compliment_month"):
		friend_data["last_compliment_month"] = -1
		friend_data["last_compliment_year"] = -1
		friend_data["last_compliment_age"] = -1
	if not friend_data.has("last_interact_month"):
		friend_data["last_interact_month"] = -1
		friend_data["last_interact_year"] = -1
		friend_data["last_interact_age"] = -1
	NpcLifeProgress.ensure(friend_data)
	friends.append(friend_data)
	return true


func remove_friend(friend_id: String) -> bool:
	for i in range(friends.size() - 1, -1, -1):
		var f = friends[i]
		if f is Dictionary and str(f.get("id", "")) == friend_id:
			friends.remove_at(i)
			return true
	return false


func get_friend(friend_id: String) -> Dictionary:
	for f in friends:
		if f is Dictionary and str(f.get("id", "")) == friend_id:
			return f
	return {}


func modify_friend_relationship(friend_id: String, delta: int) -> int:
	for f in friends:
		if f is Dictionary and str(f.get("id", "")) == friend_id:
			var cur: int = int(f.get("relationship", 50))
			var new_rel: int = clampi(cur + delta, 0, 100)
			f["relationship"] = new_rel
			return new_rel
	return -1


func can_interact_friend_hangout(friend_id: String) -> bool:
	var f := get_friend(friend_id)
	if f.is_empty():
		return false
	var m: int = int(f.get("last_spend_time_month", -1))
	var y: int = int(f.get("last_spend_time_year", -1))
	var a: int = int(f.get("last_spend_time_age", -1))
	return not is_activity_used_this_month(m, y, a)


func can_interact_friend_compliment(friend_id: String) -> bool:
	var f := get_friend(friend_id)
	if f.is_empty():
		return false
	var m: int = int(f.get("last_compliment_month", -1))
	var y: int = int(f.get("last_compliment_year", -1))
	var a: int = int(f.get("last_compliment_age", -1))
	return not is_activity_used_this_month(m, y, a)


func record_friend_hangout(friend_id: String) -> void:
	for f in friends:
		if f is Dictionary and str(f.get("id", "")) == friend_id:
			f["last_spend_time_age"] = age
			f["last_spend_time_month"] = in_game_month
			f["last_spend_time_year"] = in_game_year
			f["last_interact_age"] = age
			f["last_interact_month"] = in_game_month
			f["last_interact_year"] = in_game_year
			break


func record_friend_compliment(friend_id: String) -> void:
	for f in friends:
		if f is Dictionary and str(f.get("id", "")) == friend_id:
			f["last_compliment_age"] = age
			f["last_compliment_month"] = in_game_month
			f["last_compliment_year"] = in_game_year
			f["last_interact_age"] = age
			f["last_interact_month"] = in_game_month
			f["last_interact_year"] = in_game_year
			break


func get_family_name() -> String:
	var tokens: PackedStringArray = first_name.strip_edges().split(" ", false)
	if tokens.size() > 1:
		return str(tokens[tokens.size() - 1])
	if not father_name.is_empty():
		var f_tokens: PackedStringArray = father_name.strip_edges().split(" ", false)
		if f_tokens.size() > 1:
			return str(f_tokens[f_tokens.size() - 1])
	if not mother_name.is_empty():
		var m_tokens: PackedStringArray = mother_name.strip_edges().split(" ", false)
		if m_tokens.size() > 1:
			return str(m_tokens[m_tokens.size() - 1])
	if tokens.size() == 1:
		return str(tokens[0])
	return "Rivera"


func is_married() -> bool:
	if not has_partner():
		return false
	return get_partner_status() in ["Wife", "Husband", "Spouse"] or partner.has("married_age")


func update_partner_family_name_on_marriage() -> String:
	if not has_partner():
		return ""
	var fam_name := get_family_name()
	if fam_name.is_empty():
		return get_partner_name()
	var cur_name := get_partner_name().strip_edges()
	var tokens := cur_name.split(" ", false)
	if tokens.is_empty():
		var fallback_name := "Partner %s" % fam_name
		partner["name"] = fallback_name
		return fallback_name
	if tokens.size() == 1:
		var new_name := "%s %s" % [tokens[0], fam_name]
		partner["name"] = new_name
		return new_name
	if tokens[tokens.size() - 1] == fam_name:
		return cur_name
	tokens[tokens.size() - 1] = fam_name
	var new_name := " ".join(tokens)
	partner["name"] = new_name
	return new_name


func enforce_buffs_and_debuffs() -> void:
	if "health_cap_50" in active_debuffs:
		health = clampi(health, 0, 50)
	if "stuck_happiness" in active_debuffs:
		happiness = clampi(happiness, 0, 15)
	if "super_smarts" in active_buffs:
		smarts = maxi(smarts, 100)
	if "radiant_vitality" in active_buffs:
		health = maxi(health, 85)
	if "divine_looks" in active_buffs:
		looks = maxi(looks, 90)
	if "blessed_mind" in active_buffs:
		happiness = maxi(happiness, 80)
	# Purge any legacy charity permanent buffs if present
	for b_id in ["buff_philanthropist_heart", "buff_animal_guardian", "buff_youth_mentor", "buff_lifesavers_blessing", "buff_eco_guardian", "buff_grand_benefactor"]:
		active_buffs.erase(b_id)


func add_buff(buff_id: String) -> void:
	if not buff_id in active_buffs:
		active_buffs.append(buff_id)
		enforce_buffs_and_debuffs()


func has_buff(buff_id: String) -> bool:
	return buff_id in active_buffs


func has_debuff(debuff_id: String) -> bool:
	return debuff_id in active_debuffs


func has_living_children() -> bool:
	for c in children:
		if c is Dictionary and bool(c.get("is_alive", true)):
			return true
	return false


func get_living_children() -> Array:
	var living: Array = []
	for c in children:
		if c is Dictionary and bool(c.get("is_alive", true)):
			living.append(c)
	return living


func add_player_child(c_name: String, c_gender: String, c_age: int = 0) -> Dictionary:
	var final_name := c_name.strip_edges()
	if is_married():
		var fam_name := get_family_name()
		if not fam_name.is_empty():
			var tokens := final_name.split(" ", false)
			if tokens.is_empty():
				final_name = "Baby %s" % fam_name
			elif tokens.size() == 1:
				final_name = "%s %s" % [tokens[0], fam_name]
			elif tokens[tokens.size() - 1] != fam_name:
				tokens[tokens.size() - 1] = fam_name
				final_name = " ".join(tokens)
	var child_data := {
		"name": final_name,
		"gender": c_gender,
		"age": c_age,
		"ethnicity": ethnicity,
		"portrait_track": randi() % 2,
		"portrait_variant": randi() % 5,
		"relationship": 85,
		"health": 90,
		"happiness": 80,
		"smarts": randi_range(50, 85),
		"looks": randi_range(50, 85),
		"is_alive": true
	}
	NpcLifeProgress.ensure(child_data)
	children.append(child_data)
	return child_data


func has_siblings() -> bool:
	return siblings.size() > 0


func has_living_siblings() -> bool:
	for s in siblings:
		if s is Dictionary and bool(s.get("is_alive", true)):
			return true
	return false


func get_living_siblings() -> Array:
	var living: Array = []
	for s in siblings:
		if s is Dictionary and bool(s.get("is_alive", true)):
			living.append(s)
	return living


func add_sibling_entry(sib_data: Dictionary) -> Dictionary:
	if not sib_data.is_empty():
		NpcLifeProgress.ensure(sib_data)
		siblings.append(sib_data)
	return sib_data


func generate_initial_siblings(force_count: int = -1) -> void:
	siblings.clear()
	var count: int = 0
	if force_count >= 0:
		count = force_count
	else:
		var roll := randf()
		if roll < 0.35:
			count = 0
		elif roll < 0.75:
			count = 1
		elif roll < 0.93:
			count = 2
		else:
			count = 3

	if count <= 0:
		return

	var fam_name := get_family_name()
	var country := birthplace if not birthplace.is_empty() else "United States"

	for i in range(count):
		var is_female := randf() < 0.50
		var s_gender := "FEMALE" if is_female else "MALE"
		var s_first := NameCatalog.random_first_name(country, is_female)
		var s_name := s_first + " " + fam_name

		var age_diff := randi_range(1, 5)
		if randf() < 0.10 and i == 0:
			age_diff = 0
		var s_age := age + age_diff

		var s_relation := ""
		if age_diff == 0:
			s_relation = "Twin Sister" if is_female else "Twin Brother"
		elif age_diff > 0:
			s_relation = "Older Sister" if is_female else "Older Brother"
		else:
			s_relation = "Younger Sister" if is_female else "Younger Brother"

		var sibling := {
			"id": "sib_%d_%d_%d" % [age, i, randi() % 10000],
			"name": s_name,
			"first_name": s_first,
			"family_name": fam_name,
			"gender": s_gender,
			"relation": s_relation,
			"age": s_age,
			"base_age_diff": age_diff,
			"smarts": randi_range(45, 95),
			"looks": randi_range(40, 95),
			"health": randi_range(80, 98),
			"happiness": randi_range(70, 90),
			"relationship": randi_range(70, 90),
			"portrait_track": randi() % 4,
			"portrait_variant": randi() % 4,
			"ethnicity": ethnicity,
			"is_alive": true,
			"last_spend_time_age": -1,
			"last_compliment_age": -1,
			"last_gift_age": -1
		}
		NpcLifeProgress.ensure(sibling)
		siblings.append(sibling)


func start_reincarnated_life(identity: Dictionary, debuffs: Array, buffs: Array) -> void:
	reset_player()
	active_debuffs = debuffs.duplicate()
	active_buffs = buffs.duplicate()

	first_name = str(identity.get("first_name", "Reborn Soul"))
	gender = str(identity.get("gender", "MALE"))
	ethnicity = str(identity.get("ethnicity", "white"))
	birthplace = str(identity.get("birthplace", "New York"))
	portrait_track = int(identity.get("portrait_track", 0))
	portrait_variant = int(identity.get("portrait_variant", 0))
	avatar_id = str(identity.get("avatar_id", ""))
	has_started_game = true

	# Generate rich reincarnation profile with full character & parents description
	var profile: Dictionary = BirthStoryGeneratorRef.generate_reincarnation_profile(
		first_name,
		birthplace,
		gender,
		active_buffs,
		active_debuffs
	)

	birth_story = str(profile.get("story", ""))
	birth_month = str(profile.get("birth_month", "January"))
	birth_day = int(profile.get("birth_day", 1))
	zodiac = str(profile.get("zodiac", "Capricorn"))
	family_wealth = str(profile.get("family_wealth", "middle_class"))

	mother_name = str(profile.get("mother_name", "Elena"))
	mother_job = str(profile.get("mother_job", "Retail Associate"))
	mother_base_age = int(profile.get("mother_age", 35))
	mother_education = str(profile.get("mother_education", "High School"))
	mother_condition = str(profile.get("mother_condition", ""))
	mother_health = int(profile.get("mother_health", 80))
	mother_portrait_track = int(profile.get("mother_portrait_track", randi() % 4))
	mother_alive = bool(profile.get("mother_alive", true))
	mother_relationship = 100 if "golden_pedigree" in active_buffs else (0 if not mother_alive else 80)

	father_name = str(profile.get("father_name", "Marcus"))
	father_job = str(profile.get("father_job", "Mechanic"))
	father_base_age = int(profile.get("father_age", 37))
	father_education = str(profile.get("father_education", "High School"))
	father_condition = str(profile.get("father_condition", ""))
	father_health = int(profile.get("father_health", 80))
	father_portrait_track = int(profile.get("father_portrait_track", randi() % 4))
	father_alive = bool(profile.get("father_alive", true))
	father_relationship = 100 if "golden_pedigree" in active_buffs else (0 if not father_alive else 80)

	# Base stats
	if "bad_stats" in active_debuffs:
		health = randi_range(15, 25)
		happiness = randi_range(10, 20)
		smarts = randi_range(15, 25)
		looks = randi_range(15, 25)
	else:
		health = 80
		happiness = 75
		smarts = 60
		looks = 65

	# Illnesses
	if "random_illness" in active_debuffs:
		var illness_pool := [
			{"id": "chronic_asthma", "name": "Chronic Severe Asthma"},
			{"id": "heart_murmur", "name": "Congenital Heart Defect"},
			{"id": "migraines", "name": "Chronic Migraine Syndrome"}
		]
		var chosen_ill: Dictionary = illness_pool[randi() % illness_pool.size()]
		add_illness(str(chosen_ill["id"]), str(chosen_ill["name"]), 1)

	# Finances
	if "crazy_debt" in active_debuffs:
		debt = randi_range(60000, 100000)
		money = 0
	elif "poverty" in active_debuffs:
		money = 0
		bank_savings = 0
	elif "silver_spoon" in active_buffs:
		money = 0
		bank_savings = randi_range(100000, 150000)
	else:
		money = 0

	karma = 0
	enforce_buffs_and_debuffs()

	# 1. Timeline Reincarnation Judgment event with human-readable titles and icons
	var desc_karmic := "⚖️ REINCARNATION: You were judged by the Cosmic Arbiter."
	var gift_names: Array[String] = []
	for b in active_buffs:
		gift_names.append(format_karmic_modifier(str(b)))

	var penalty_names: Array[String] = []
	for d in active_debuffs:
		penalty_names.append(format_karmic_modifier(str(d)))

	if gift_names.size() > 0 and penalty_names.size() > 0:
		desc_karmic += " Blessed with cosmic gifts: %s. Bound by karmic penalties: %s." % [", ".join(gift_names), ", ".join(penalty_names)]
	elif gift_names.size() > 0:
		desc_karmic += " Blessed with cosmic gifts: %s." % ", ".join(gift_names)
	elif penalty_names.size() > 0:
		desc_karmic += " Bound by karmic penalties: %s." % ", ".join(penalty_names)
	else:
		desc_karmic += " Reborn into a balanced mortal vessel."

	add_life_log_entry(desc_karmic, "event")

	# 2. Timeline Character & Parents description
	if birth_story != "":
		add_life_log_entry(birth_story, "milestone")
	add_milestone("Reborn in %s." % birthplace, 0, "🍼")
	generate_initial_siblings()

	if has_node("/root/GameClock"):
		var clock = get_node("/root/GameClock")
		if clock != null:
			var b_idx: int = clock.month_name_to_index(birth_month)
			clock.setup_new_game(b_idx, birth_day, 2026, 1, 1, 17)

func takeover_as_child(child: Dictionary, inherited_money: int, inherited_assets: Array = []) -> void:
	takeover_as_heir(child, inherited_money, inherited_assets, "child")


func takeover_as_heir(heir: Dictionary, inherited_money: int, inherited_assets: Array = [], relation_type: String = "child") -> void:
	NpcLifeProgress.ensure(heir)
	var inherited_businesses := owned_businesses.duplicate(true)
	var inherited_market := finance_market.duplicate(true)
	var inherited_crypto := crypto_wallet.duplicate(true)
	var inherited_savings := savings_account.duplicate(true)
	var late_pension_balance := int(pension_account.get("balance", 0))
	var prev_parent_name: String = first_name
	var prev_gender: String = gender
	var prev_parent_edu: String = education_level
	var assets_copy: Array = inherited_assets.duplicate(true)
	var preserved_children: Array = children.duplicate(true) if relation_type == "partner" else []

	var preserved_siblings: Array = []
	var prev_mother_data := {
		"name": mother_name,
		"job": mother_job,
		"base_age": mother_base_age,
		"education": mother_education,
		"condition": mother_condition,
		"health": mother_health,
		"portrait_track": mother_portrait_track,
		"alive": mother_alive
	}
	var prev_father_data := {
		"name": father_name,
		"job": father_job,
		"base_age": father_base_age,
		"education": father_education,
		"condition": father_condition,
		"health": father_health,
		"portrait_track": father_portrait_track,
		"alive": father_alive
	}

	if relation_type == "sibling":
		var heir_id: String = str(heir.get("id", ""))
		for s in siblings:
			if s is Dictionary and str(s.get("id", "")) != heir_id:
				preserved_siblings.append(s.duplicate(true))
	elif relation_type == "child":
		var heir_name: String = str(heir.get("name", ""))
		for c in children:
			if c is Dictionary and str(c.get("name", "")) != heir_name and bool(c.get("is_alive", true)):
				var c_copy: Dictionary = c.duplicate(true)
				var c_gender: String = str(c_copy.get("gender", "MALE"))
				c_copy["relation"] = "Sister" if c_gender == "FEMALE" else "Brother"
				preserved_siblings.append(c_copy)

	reset_player()
	owned_businesses = inherited_businesses
	finance_market = inherited_market
	crypto_wallet = inherited_crypto
	if relation_type == "partner":
		children = preserved_children
	elif relation_type == "sibling":
		siblings = preserved_siblings
		mother_name = str(prev_mother_data["name"])
		mother_job = str(prev_mother_data["job"])
		mother_base_age = int(prev_mother_data["base_age"])
		mother_education = str(prev_mother_data["education"])
		mother_condition = str(prev_mother_data["condition"])
		mother_health = int(prev_mother_data["health"])
		mother_portrait_track = int(prev_mother_data["portrait_track"])
		mother_alive = bool(prev_mother_data["alive"])
		father_name = str(prev_father_data["name"])
		father_job = str(prev_father_data["job"])
		father_base_age = int(prev_father_data["base_age"])
		father_education = str(prev_father_data["education"])
		father_condition = str(prev_father_data["condition"])
		father_health = int(prev_father_data["health"])
		father_portrait_track = int(prev_father_data["portrait_track"])
		father_alive = bool(prev_father_data["alive"])
	elif relation_type == "child":
		siblings = preserved_siblings

	first_name = str(heir.get("name", "Heir"))
	gender = str(heir.get("gender", "MALE"))
	ethnicity = str(heir.get("ethnicity", "white"))
	portrait_track = int(heir.get("portrait_track", 0))
	portrait_variant = int(heir.get("portrait_variant", 0))
	avatar_id = str(heir.get("avatar_id", ""))
	age = int(heir.get("age", 18))
	if not finance_market.is_empty():
		finance_market.last_age = age
		finance_market.history = []
		for company in finance_market.get("issuers", []):
			company.opened_age = age
			if not str(company.get("business_uid", "")).is_empty():
				company.owner = first_name
	if not crypto_wallet.is_empty():
		crypto_wallet.last_age = age
	var CryptoMarketRef = preload("res://scripts/economy/crypto_market.gd")
	CryptoMarketRef.ensure(self)
	has_started_game = true
	is_dead = false
	active_stat_modifiers.clear()

	if has_node("/root/GameClock"):
		var clock = get_node("/root/GameClock")
		if clock != null:
			clock.current_age = age
			clock.birth_year = clock.derive_birth_year(clock.year, clock.month, clock.day, birth_month_idx, birth_day, age)
			clock.is_paused = false
			clock.pause_reasons.erase("death")
			clock._sync_to_player_data()

	health = int(heir.get("health", 85))
	happiness = int(heir.get("happiness", 75))
	smarts = int(heir.get("smarts", 65))
	looks = int(heir.get("looks", 65))
	money = 0
	bank_savings = 0
	debt = 0
	tax_debt = 0
	loan_balance = 0
	has_credit_card = false
	credit_card_tier = "None"
	credit_card_limit = 0
	credit_card_balance = 0
	credit_card_apr = 0.18
	credit_card_paid_this_year = 0
	karma = 0
	asset_insurance = { "vehicle": false, "property": false }

	owned_assets.clear()
	mortgages.clear()
	rented_property.clear()
	for a in assets_copy:
		if a is Dictionary:
			owned_assets.append(a.duplicate(true))
	if owned_assets.is_empty():
		grant_starting_assets()

	if relation_type == "partner":
		partner = {}
	elif relation_type == "sibling":
		pass
	else:
		if prev_gender == "FEMALE":
			mother_name = prev_parent_name
			mother_education = prev_parent_edu if prev_parent_edu != "" else "High School"
			mother_alive = false
			mother_health = 0
		else:
			father_name = prev_parent_name
			father_education = prev_parent_edu if prev_parent_edu != "" else "High School"
			father_alive = false
			father_health = 0

	# Apply heir's life background: education, university degrees, jobs, promotions, personal savings, businesses, history
	NpcLifeProgress.apply_to_player(self, heir)

	# Bank savings adds the inherited money to the heir's personal savings:
	bank_savings = maxi(0, bank_savings + inherited_money)

	# Inherit savings account directly:
	var inherited_savings_balance: int = int(inherited_savings.get("balance", 0))
	savings_account = inherited_savings.duplicate(true)
	savings_account["balance"] = inherited_savings_balance

	# PENSION ACCOUNT CANNOT BE INHERITED (forfeited upon death/succession):
	pension_account = {
		"balance": 0,
		"total_contributed": 0,
		"contribution_pct": 0.05,
		"employer_match_pct": 0.03,
		"interest_rate": 0.065,
		"is_annuity_active": false,
		"total_annuity_paid": 0,
		"last_year_interest": 0,
		"is_enrolled": false
	}

	var crypto_val: int = CryptoMarketRef.portfolio_value(self)
	var crypto_holdings_count: int = 0
	if crypto_wallet.has("coins") and crypto_wallet["coins"] is Dictionary:
		for sym in crypto_wallet["coins"]:
			var h: Dictionary = crypto_wallet["coins"][sym]
			if float(h.get("amount", 0.0)) > 0.000001:
				crypto_holdings_count += 1

	if crypto_holdings_count > 0:
		if crypto_wallet.has("news") and crypto_wallet["news"] is Array:
			var rel_label := "partner" if relation_type == "partner" else ("sibling" if relation_type == "sibling" else "parent")
			crypto_wallet["news"].push_front("👑 SUCCESSION: %s inherited late %s %s's cryptocurrency wallet (%d digital asset holdings, ~$ %s)." % [
				first_name, rel_label, prev_parent_name, crypto_holdings_count, CryptoMarketRef._format_num(crypto_val)
			])

	if late_pension_balance > 0:
		add_life_log_entry("🔒 NON-TRANSFERABLE PENSION: Late %s's Pension Account ($%s) could not be inherited and was forfeited to the pension trust upon death." % [
			prev_parent_name, preload("res://scripts/economy/pension_and_savings_manager.gd")._format_num(late_pension_balance)
		], "finance")

	if inherited_savings_balance > 0:
		add_life_log_entry("💰 GENERATIONAL SAVINGS INHERITED: You inherited late %s's High-Yield Savings Account ($%s) intact as generational family wealth." % [
			prev_parent_name, preload("res://scripts/economy/pension_and_savings_manager.gd")._format_num(inherited_savings_balance)
		], "finance")

	var extra_items: Array[String] = []
	if owned_assets.size() > 0:
		extra_items.append("%d property/vehicle asset%s" % [owned_assets.size(), "s" if owned_assets.size() > 1 else ""])
	if inherited_savings_balance > 0:
		extra_items.append("High-Yield Savings ($%s)" % preload("res://scripts/economy/pension_and_savings_manager.gd")._format_num(inherited_savings_balance))
	if crypto_holdings_count > 0:
		extra_items.append("%d cryptocurrency asset%s (~$%s)" % [crypto_holdings_count, "s" if crypto_holdings_count > 1 else "", CryptoMarketRef._format_num(crypto_val)])
	if owned_businesses.size() > 0:
		extra_items.append("%d business%s" % [owned_businesses.size(), "es" if owned_businesses.size() > 1 else ""])

	var asset_text := ""
	if not extra_items.is_empty():
		asset_text = " and " + ", ".join(extra_items)

	if relation_type == "partner":
		add_life_log_entry("📜 LEGACY: You inherited your late partner %s's estate ($%d deposited into your Bank Balance%s) and continue their legacy at age %d." % [prev_parent_name, inherited_money, asset_text, age], "event")
	elif relation_type == "sibling":
		add_life_log_entry("📜 LEGACY: You inherited your late sibling %s's estate ($%d deposited into your Bank Balance%s) and carry forward the %s family legacy at age %d." % [prev_parent_name, inherited_money, asset_text, get_family_name(), age], "event")
	else:
		add_life_log_entry("📜 LEGACY: You inherited your late parent %s's estate ($%d deposited into your Bank Balance%s) and continue the family bloodline at age %d." % [prev_parent_name, inherited_money, asset_text, age], "event")


func get_owned_properties() -> Array[Dictionary]:
	var props: Array[Dictionary] = []
	for a in owned_assets:
		if a is Dictionary and str(a.get("category", "")) == "properties":
			props.append(a)
	return props


func get_current_residence_title() -> String:
	if not has_moved_out_from_parents:
		return "Family Home (Parents' Household)"
	if current_residence_name != "":
		return current_residence_name
	if not rented_property.is_empty() and str(rented_property.get("name", "")) != "":
		return str(rented_property.get("name", "Rented Residence"))
	var owned_p := get_owned_properties()
	if not owned_p.is_empty():
		return str(owned_p[0].get("name", "Owned Residence"))
	return "Independent Residence"


func has_independent_residence() -> bool:
	return has_moved_out_from_parents


func get_active_room_id() -> String:
	# If player has a specific valid room selected for an owned property
	var owned_p := get_owned_properties()
	if not owned_p.is_empty():
		# Verify if current selected_room_id belongs to an owned property
		for p in owned_p:
			var pid: String = str(p.get("item_id", p.get("id", "")))
			var rid: String = RoomManager.get_room_id_for_property(pid)
			if selected_room_id == rid or selected_room_id == pid:
				return rid
		# Default to first owned property's room
		var first_prop_id: String = str(owned_p[0].get("item_id", owned_p[0].get("id", "prop_capsule")))
		var resolved: String = RoomManager.get_room_id_for_property(first_prop_id)
		selected_room_id = resolved
		return resolved
	# Starter / unhoused / parents household
	if selected_room_id != "" and selected_room_id != "room_wood":
		return selected_room_id
	return "room_capsule"


func set_active_room_from_property(property_id: String) -> void:
	selected_room_id = RoomManager.get_room_id_for_property(property_id)


func sync_room_with_housing() -> String:
	var rid := get_active_room_id()
	selected_room_id = rid
	return rid


# --- NEURAL SPECIALIST & BRAIN CHIPS ---

func has_neural_implant(mod_id: String) -> bool:
	for imp in neural_implants:
		if imp is Dictionary and imp.get("id", "") == mod_id:
			return true
	return false


func get_neural_implant(mod_id: String) -> Dictionary:
	for imp in neural_implants:
		if imp is Dictionary and imp.get("id", "") == mod_id:
			return imp
	return {}


func get_implant_in_slot(slot: String) -> Dictionary:
	for imp in neural_implants:
		if imp is Dictionary and imp.get("slot", "") == slot:
			return imp
	return {}


func get_total_neural_maintenance() -> int:
	var total: int = 0
	for imp in neural_implants:
		if imp is Dictionary:
			total += int(imp.get("annual_maintenance", 0))
	return total


func install_neural_implant(mod_id: String) -> Dictionary:
	var mod_data := NeuralCatalog.get_modification(mod_id)
	if mod_data.is_empty():
		return {"success": false, "reason": "Unknown modification profile."}
	if age < int(mod_data.get("min_age", 18)):
		return {"success": false, "reason": "Patient is under minimum age (18 required)."}
	var price: int = int(mod_data.get("price", 0))
	if not can_afford(price):
		return {"success": false, "reason": "Insufficient funds."}

	var slot: String = str(mod_data.get("slot", "cortex"))
	var old_imp: Dictionary = get_implant_in_slot(slot)
	var salvage_refund: int = 0
	if not old_imp.is_empty():
		salvage_refund = int(int(old_imp.get("purchase_price", 0)) * 0.25)
		remove_neural_implant(str(old_imp.get("id", "")), false)

	debit_funds(price)
	if salvage_refund > 0:
		bank_savings += salvage_refund

	var new_imp: Dictionary = {
		"id": mod_data.get("id", ""),
		"name": mod_data.get("name", ""),
		"slot": slot,
		"category": mod_data.get("category", ""),
		"purchase_price": price,
		"annual_maintenance": int(mod_data.get("annual_maintenance", 0)),
		"install_age": age,
		"condition": 100,
		"is_active": true,
		"maintenance_paid_this_year": true,
		"overclocked_this_year": false
	}
	neural_implants.append(new_imp)

	# Apply stat boosts
	var boosts: Dictionary = mod_data.get("stat_boosts", {})
	if boosts.has("smarts"):
		smarts = mini(100, smarts + int(boosts["smarts"]))
	if boosts.has("mental_state"):
		mental_state = mini(100, mental_state + int(boosts["mental_state"]))
	if boosts.has("happiness"):
		happiness = mini(100, happiness + int(boosts["happiness"]))
	if boosts.has("health"):
		health = mini(100, health + int(boosts["health"]))
	if boosts.has("looks"):
		looks = mini(100, looks + int(boosts["looks"]))

	if mod_data.get("locks_max_smarts", false):
		smarts = 100
	if mod_data.get("locks_max_mental_state", false):
		mental_state = 100

	add_milestone("Attached %s neural modification." % str(mod_data.get("name", "AI Chip")), age, "🧠")
	return {
		"success": true,
		"salvage_refund": salvage_refund,
		"implant": new_imp,
		"replaced_name": str(old_imp.get("name", ""))
	}


func remove_neural_implant(mod_id: String, grant_refund: bool = true) -> Dictionary:
	for i in range(neural_implants.size()):
		var imp: Dictionary = neural_implants[i]
		if imp.get("id", "") == mod_id:
			var refund: int = int(int(imp.get("purchase_price", 0)) * 0.25) if grant_refund else 0
			if refund > 0:
				bank_savings += refund
			var removed_name: String = str(imp.get("name", "Implant"))
			neural_implants.remove_at(i)
			return {"success": true, "refund": refund, "name": removed_name}
	return {"success": false, "reason": "Implant not found."}


func service_all_neural_implants() -> Dictionary:
	var overdue_count: int = 0
	var overdue_cost: int = 0
	for imp in neural_implants:
		if imp is Dictionary and (not bool(imp.get("is_active", true)) or int(imp.get("condition", 100)) < 100):
			overdue_count += 1
			var annual_m: int = int(imp.get("annual_maintenance", 0))
			overdue_cost += maxi(1, int(round(float(annual_m) / 12.0)))

	if overdue_count == 0:
		return {"success": false, "reason": "All neural implants are already fully operational and calibrated."}

	if not can_afford(overdue_cost):
		return {"success": false, "reason": "Insufficient funds to service overdue maintenance ($%d required)." % overdue_cost}

	debit_funds(overdue_cost)
	for imp in neural_implants:
		if imp is Dictionary:
			imp["is_active"] = true
			imp["condition"] = 100
			imp["maintenance_paid_this_month"] = true
			imp["maintenance_paid_this_year"] = true

	mental_state = mini(100, mental_state + 10)
	happiness = mini(100, happiness + 5)
	return {"success": true, "cost": overdue_cost, "count": overdue_count}


func process_yearly_neural_implants() -> Array[String]:
	var logs: Array[String] = []
	if neural_implants.is_empty():
		return logs

	# Maintenance is debited monthly via process_monthly_neural_implants()
	# Reset annual overclock status and apply yearly active perks
	for imp in neural_implants:
		if imp is Dictionary:
			imp["overclocked_this_year"] = false

	# Apply yearly active perks
	for imp in neural_implants:
		if not imp is Dictionary or not bool(imp.get("is_active", true)):
			continue
		var mod_id: String = str(imp.get("id", ""))
		var mod_data := NeuralCatalog.get_modification(mod_id)
		if mod_data.get("locks_max_smarts", false):
			smarts = 100
		if mod_data.get("locks_max_mental_state", false):
			mental_state = 100
		if mod_data.has("min_happiness_floor"):
			happiness = maxi(int(mod_data["min_happiness_floor"]), happiness)
		if mod_data.has("yearly_health_regen"):
			health = mini(100, health + int(mod_data["yearly_health_regen"]))
		if mod_data.get("stress_immunity", false):
			mental_state = mini(100, mental_state + 3)

	return logs


func get_date_string() -> String:
	return "%s %d, %d" % [GameClockScript.get_month_name(in_game_month), in_game_day, in_game_year]


func get_calculated_age() -> int:
	return GameClockScript.calculate_age(in_game_year, in_game_month, in_game_day, birth_year, birth_month_idx, birth_day)


func get_monthly_neural_maintenance() -> int:
	var total_maint: int = get_total_neural_maintenance()
	return maxi(1, int(round(float(total_maint) / 12.0))) if total_maint > 0 else 0


func process_monthly_neural_implants() -> Array[String]:
	var logs: Array[String] = []
	if neural_implants.is_empty():
		return logs

	var monthly_maint: int = get_monthly_neural_maintenance()
	if monthly_maint > 0:
		if can_afford(monthly_maint):
			debit_funds(monthly_maint)
			for imp in neural_implants:
				if imp is Dictionary:
					imp["is_active"] = true
					imp["condition"] = 100
					imp["maintenance_paid_this_month"] = true
			logs.append("🧠 NEURAL SPECIALIST: $%s debited for monthly maintenance & quantum nanite upkeep across %d implants." % [
				String.num(monthly_maint),
				neural_implants.size()
			])
		else:
			for imp in neural_implants:
				if imp is Dictionary:
					imp["is_active"] = false
					imp["condition"] = maxi(20, int(imp.get("condition", 100)) - 10)
					imp["maintenance_paid_this_month"] = false
			happiness = maxi(5, happiness - 3)
			mental_state = maxi(5, mental_state - 3)
			logs.append("⚠️ NEURAL IMPLANT FAILURE: Insufficient funds ($%s required) for monthly neural maintenance! Implants entered offline mode (-3 Happiness, -3 Mental State)." % String.num(monthly_maint))

	# Apply active perks
	for imp in neural_implants:
		if not imp is Dictionary or not bool(imp.get("is_active", true)):
			continue
		var mod_id: String = str(imp.get("id", ""))
		var mod_data := NeuralCatalog.get_modification(mod_id)
		if mod_data.get("locks_max_smarts", false):
			smarts = 100
		if mod_data.get("locks_max_mental_state", false):
			mental_state = 100
		if mod_data.has("min_happiness_floor"):
			happiness = maxi(int(mod_data["min_happiness_floor"]), happiness)
		if mod_data.has("yearly_health_regen"):
			health = mini(100, health + maxi(1, int(round(float(mod_data["yearly_health_regen"]) / 12.0))))
		if mod_data.get("stress_immunity", false):
			mental_state = mini(100, mental_state + 1)

	return logs


func is_activity_used_this_month(action_month: int, action_year: int, _action_age: int = -1) -> bool:
	if action_month > 0 and action_year > 0:
		return action_month == in_game_month and action_year == in_game_year
	return false


# -----------------------------------------------------------------------------
# DAILY WAGE & PART-TIME EMPLOYMENT HELPERS
# -----------------------------------------------------------------------------

func has_part_time_job() -> bool:
	return not part_time_job.is_empty()


func get_part_time_job() -> Dictionary:
	return part_time_job


func assign_part_time_job(job_def: Dictionary, company_name: String = "") -> bool:
	if job_def.is_empty():
		return false
	var job_copy := job_def.duplicate(true)
	if company_name != "":
		job_copy["company"] = company_name
	part_time_job = job_copy
	return true


func quit_part_time_job() -> void:
	part_time_job.clear()


func process_daily_employment_tick(y: int, m: int, d: int) -> Dictionary:
	var dw_manager = preload("res://scripts/economy/daily_wage_manager.gd")
	return dw_manager.process_daily_wages(self, y, m, d)


