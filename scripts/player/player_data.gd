extends Node

const NpcLifeProgress = preload("res://scripts/core/npc_life_progress.gd")
const BirthStoryGeneratorRef = preload("res://scripts/core/birth_story_generator.gd")
const NameCatalog = preload("res://scripts/core/name_catalog.gd")

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

var age: int = 0
var life_id: String = ""
var finance_market: Dictionary = {}
var crypto_wallet: Dictionary = {}
var learning_activities: Dictionary = {}

var health: int = 80
var happiness: int = 75
var smarts: int = 60
var looks: int = 65
var mental_state: int = 80

var first_name: String = ""
var birthplace: String = ""
var gender: String = "MALE"
var ethnicity: String = "white"
var portrait_track: int = 0
var portrait_variant: int = 0
var has_started_game: bool = false
var selected_room_id: String = "room_wood"

var birth_story: String = ""
var birth_month: String = "January"
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
var children: Array = []
var pregnancy: Dictionary = {}
var active_debuffs: Array = []
var active_buffs: Array = []
var total_donated_charity: int = 0
var charity_donations_count: int = 0
var last_parent_interact_age: int = -1
var last_mother_spend_time_age: int = -1
var last_mother_compliment_age: int = -1
var last_mother_ask_money_age: int = -1
var last_father_spend_time_age: int = -1
var last_father_compliment_age: int = -1
var last_father_ask_money_age: int = -1
var last_partner_interact_age: int = -1
var last_partner_spend_time_age: int = -1
var last_partner_compliment_age: int = -1
var last_partner_gift_age: int = -1
var last_partner_propose_age: int = -1
var last_breakup_age: int = -1
var last_baby_age: int = -1

var last_mother_pay_meds_age: int = -1
var last_father_pay_meds_age: int = -1
var last_mother_doctor_checkup_age: int = -1
var last_father_doctor_checkup_age: int = -1
var last_mother_vitamin_shot_age: int = -1
var last_father_vitamin_shot_age: int = -1

var last_doctor_checkup_age: int = -1
var last_doctor_vitamin_age: int = -1
var last_plastic_surgery_age: int = -1
var last_chemo_age: int = -1
var last_therapy_age: int = -1
var last_er_age: int = -1

var last_prison_activity_age: int = -1
var last_casino_age: int = -1
var casino_plays_this_year: int = 0
var last_overtime_age: int = -1
var last_childhood_gig_age: int = -1

var karma: int = 0
var money: int = 0
var bank_savings: int = 0
var debt: int = 0
var tax_debt: int = 0
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

var education_level: String = "None"
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
var last_school_activity_age: int = -1
var last_scholarship_applied_age: int = -1
var last_ged_attempt_age: int = -1
var has_gym_membership: bool = false
var gym_membership_annual_fee: int = 300
var last_gym_activity_age: int = -1
var last_meditation_activity_age: int = -1
var last_salon_activity_age: int = -1
var last_spa_activity_age: int = -1
var last_dating_app_age: int = -1
var last_pet_adoption_age: int = -1
var last_charity_donation_age: int = -1

var job_id: String = ""
var job_title: String = ""
var job_company: String = ""
var job_salary: int = 0
var career_progress: Dictionary = {}
var underground_progress: Dictionary = {}

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
	has_started_game = false
	selected_room_id = "room_wood"

	birth_story = ""
	birth_month = "January"
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
	last_parent_interact_age = -1
	last_mother_spend_time_age = -1
	last_mother_compliment_age = -1
	last_mother_ask_money_age = -1
	last_father_spend_time_age = -1
	last_father_compliment_age = -1
	last_father_ask_money_age = -1
	last_partner_interact_age = -1
	last_partner_spend_time_age = -1
	last_partner_compliment_age = -1
	last_partner_gift_age = -1
	last_partner_propose_age = -1
	last_breakup_age = -1
	last_baby_age = -1

	last_mother_pay_meds_age = -1
	last_father_pay_meds_age = -1
	last_mother_doctor_checkup_age = -1
	last_father_doctor_checkup_age = -1
	last_mother_vitamin_shot_age = -1
	last_father_vitamin_shot_age = -1

	last_doctor_checkup_age = -1
	last_doctor_vitamin_age = -1
	last_plastic_surgery_age = -1
	last_chemo_age = -1
	last_therapy_age = -1
	last_er_age = -1

	last_prison_activity_age = -1
	last_casino_age = -1
	casino_plays_this_year = 0
	last_overtime_age = -1
	last_childhood_gig_age = -1

	age = 0

	health = 80
	happiness = 75
	smarts = 60
	looks = 65
	mental_state = 80

	karma = 0
	money = 0
	bank_savings = 0
	debt = 0
	tax_debt = 0
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

	education_level = "None"
	grades = 75
	has_scholarship = false
	university_years = 0
	university_name = ""
	university_major = ""
	university_major_title = ""
	university_degree = ""
	university_tuition = 12000
	last_school_activity_age = -1
	last_scholarship_applied_age = -1
	last_ged_attempt_age = -1
	has_gym_membership = false
	gym_membership_annual_fee = 300
	last_gym_activity_age = -1
	last_meditation_activity_age = -1
	last_salon_activity_age = -1
	last_spa_activity_age = -1
	last_dating_app_age = -1
	last_pet_adoption_age = -1
	last_charity_donation_age = -1

	job_id = ""
	job_title = ""
	job_company = ""
	job_salary = 0
	career_progress = {}
	underground_progress = {}

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
	return money + bank_savings + get_total_asset_value() + business_value + preload("res://scripts/economy/finance_market.gd").portfolio_value(self) + crypto_val - get_total_debt()


func get_personal_net_worth() -> int:
	# Strictly personal net worth: Business valuation DOES NOT count as a player asset or personal net worth for credit cards
	var crypto_val: int = preload("res://scripts/economy/crypto_market.gd").portfolio_value(self)
	return money + bank_savings + get_total_asset_value() + preload("res://scripts/economy/finance_market.gd").portfolio_value(self) + crypto_val - get_total_debt()


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


func pay_outstanding_tax() -> int:
	if tax_debt <= 0 or not can_afford(tax_debt):
		return 0
	var paid := tax_debt
	debit_funds(paid)
	tax_debt = 0
	modify_credit_score(15)
	return paid


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
			"message": "Limit increase request reviewed. Your current limit of $%d already matches or exceeds the allowable ceiling based on your current allowance ($%d/yr) and personal assets ($%d)." % [credit_card_limit, job_salary, get_total_asset_value()]
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

	# 3. Drift smoothly towards target equilibrium (approx 28% of gap per year)
	var diff: float = target_equilibrium - float(mental_state)
	var shift: int = int(round(diff * 0.28))
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


func takeover_as_child(child: Dictionary, inherited_money: int, inherited_assets: Array = []) -> void:
	takeover_as_heir(child, inherited_money, inherited_assets, "child")


func takeover_as_heir(heir: Dictionary, inherited_money: int, inherited_assets: Array = [], relation_type: String = "child") -> void:
	NpcLifeProgress.ensure(heir)
	var inherited_businesses := owned_businesses.duplicate(true)
	var inherited_market := finance_market.duplicate(true)
	var inherited_crypto := crypto_wallet.duplicate(true)
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
	age = int(heir.get("age", 18))
	if not finance_market.is_empty():
		finance_market.last_age = age
		finance_market.history = []
		for company in finance_market.get("issuers", []):
			company.opened_age = age
			if not str(company.get("business_uid", "")).is_empty():
				company.owner = first_name
	has_started_game = true

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

	var asset_text := " and %d property/vehicle assets" % owned_assets.size() if owned_assets.size() > 0 else ""
	if relation_type == "partner":
		add_life_log_entry("📜 LEGACY: You inherited your late partner %s's estate ($%d deposited into your Bank Balance%s) and continue their legacy at age %d." % [prev_parent_name, inherited_money, asset_text, age], "event")
	elif relation_type == "sibling":
		add_life_log_entry("📜 LEGACY: You inherited your late sibling %s's estate ($%d deposited into your Bank Balance%s) and carry forward the %s family legacy at age %d." % [prev_parent_name, inherited_money, asset_text, get_family_name(), age], "event")
	else:
		add_life_log_entry("📜 LEGACY: You inherited your late parent %s's estate ($%d deposited into your Bank Balance%s) and continue the family bloodline at age %d." % [prev_parent_name, inherited_money, asset_text, age], "event")
