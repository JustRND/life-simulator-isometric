class_name BirthStoryGenerator
extends RefCounted

const NameCatalog = preload("res://scripts/core/name_catalog.gd")

const POOR_JOBS := [
	"dishwasher", "day laborer", "cleaner", "janitor", "fast food crew",
	"street vendor", "farmhand", "warehouse packer", "laundromat worker",
	"security guard", "cashier", "scrap collector", "cook"
]

const MIDDLE_JOBS := [
	"elementary school teacher", "nurse", "accountant", "carpenter", "electrician",
	"police officer", "librarian", "journalist", "mechanic", "bus driver",
	"paralegal", "postal worker", "baker", "florist", "graphic designer",
	"grocer", "realtor", "plumber"
]

const WEALTHY_JOBS := [
	"software engineer", "dentist", "architect", "pharmacist", "veterinarian",
	"corporate executive", "neurosurgeon", "investment banker", "commercial pilot",
	"corporate attorney", "hedge fund manager", "biotech director", "venture capitalist"
]

const POOR_EDU := [
	"Middle School", "Middle School", "High School Dropout", "High School"
]

const MIDDLE_EDU := [
	"High School", "Vocational Diploma", "Associate's Degree", "Bachelor's Degree"
]

const WEALTHY_EDU := [
	"Bachelor's Degree", "Master's Degree", "Doctorate (Ph.D.)", "Medical Degree (M.D.)",
	"Master of Business Administration (MBA)", "Law Degree (J.D.)"
]

const CANCER_CONDITIONS := [
	"Breast Cancer", "Leukemia", "Lung Cancer", "Colon Cancer", "Lymphoma", "Skin Cancer", "Ovarian Cancer"
]

const OTHER_CONDITIONS := [
	"Chronic Asthma", "Hypertension", "Type 2 Diabetes", "Rheumatoid Arthritis", "Heart Arrhythmia"
]

const MONTH_DATA := [
	{"name": "January", "days": 31},
	{"name": "February", "days": 28},
	{"name": "March", "days": 31},
	{"name": "April", "days": 30},
	{"name": "May", "days": 31},
	{"name": "June", "days": 30},
	{"name": "July", "days": 31},
	{"name": "August", "days": 31},
	{"name": "September", "days": 30},
	{"name": "October", "days": 31},
	{"name": "November", "days": 30},
	{"name": "December", "days": 31}
]

const CONCEPTION_STORIES := [
	"I was an unexpected miracle after my parents spent five years trying and had nearly given up hope.",
	"My mother gave birth to me in a bathtub while soothing classical music was playing on the stereo.",
	"I was conceived on a spontaneous weekend road trip that my parents still smile about whenever it's mentioned.",
	"I came into the world through artificial insemination at a fertility clinic with the help of an anonymous donor.",
	"I was born in the passenger seat of an old station wagon on the way to the emergency room.",
	"My parents met at a summer music festival, and nine months later I made my loud entrance into the world.",
	"I was delivered by an exhausted resident doctor in the middle of a bustling hospital overnight shift.",
	"I was born during a massive citywide thunderstorm that knocked out the power right as I arrived.",
	"My parents were high school sweethearts who planned every single detail of my arrival for years.",
	"I arrived three weeks ahead of schedule, catching my parents completely by surprise in the middle of dinner.",
	"My mother went into labor while shopping at a supermarket, causing complete pandemonium in aisle three.",
	"I was born with a thick mop of dark hair that had every nurse in the maternity ward coming over to look.",
	"I was conceived on a turbulent ocean cruise during a stormy voyage my mother swears she'll never repeat.",
	"My mother was determined to have a peaceful home birth surrounded by family, tea, and aromatic candles.",
	"I was born in an elevator that temporarily stalled between the fourth and fifth floors of the hospital.",
	"My father fainted in the delivery room the moment I appeared, so the nurses had two patients to take care of.",
	"I was born during the coldest blizzard in the city's recorded history, wrapped in three hand-knitted blankets.",
	"My parents conceived me on a remote camping trip under the stars after getting lost in a national park.",
	"I was welcomed into the world by two loving parents who had painted my nursery three months in advance.",
	"I was born on a quiet Sunday morning while church bells were ringing across the neighborhood.",
	"My mother claims I kicked to the rhythm of her favorite jazz records throughout the entire third trimester.",
	"I was born in a university teaching hospital with half a dozen fascinated medical students observing.",
	"My arrival was an absolute surprise—my parents thought they were just adopting a second dog that month.",
	"I was born peacefully at sunrise, greeted by a room full of tearful grandparents and aunts."
]


static func get_zodiac(month: int, day: int) -> String:
	match month:
		1: return "Capricorn" if day <= 19 else "Aquarius"
		2: return "Aquarius" if day <= 18 else "Pisces"
		3: return "Pisces" if day <= 20 else "Aries"
		4: return "Aries" if day <= 19 else "Taurus"
		5: return "Taurus" if day <= 20 else "Gemini"
		6: return "Gemini" if day <= 20 else "Cancer"
		7: return "Cancer" if day <= 22 else "Leo"
		8: return "Leo" if day <= 22 else "Virgo"
		9: return "Virgo" if day <= 22 else "Libra"
		10: return "Libra" if day <= 22 else "Scorpio"
		11: return "Scorpio" if day <= 21 else "Sagittarius"
		12: return "Sagittarius" if day <= 21 else "Capricorn"
	return "Capricorn"


static func generate_profile(first_name: String, country: String, gender: String) -> Dictionary:
	var safe_country := country if NameCatalog.POOLS.has(country) else "United States"
	var month_idx := randi_range(0, 11)
	var month_info: Dictionary = MONTH_DATA[month_idx]
	var month_name: String = month_info["name"]
	var day: int = randi_range(1, int(month_info["days"]))
	var zodiac: String = get_zodiac(month_idx + 1, day)

	var last_name := ""
	var name_parts := first_name.split(" ", false)
	if name_parts.size() > 1:
		last_name = name_parts[name_parts.size() - 1]
	else:
		var r_parts := NameCatalog.random_name(safe_country, false).split(" ", false)
		last_name = r_parts[r_parts.size() - 1] if r_parts.size() > 0 else "Smith"

	# 1. Roll Socioeconomic Family Wealth Tier
	var wealth_roll := randf()
	var family_wealth := "middle_class"
	if wealth_roll < 0.25:
		family_wealth = "poor"
	elif wealth_roll < 0.80:
		family_wealth = "middle_class"
	else:
		family_wealth = "wealthy"

	# 2. Mother Details aligned with wealth
	var mom_parts := NameCatalog.random_name(safe_country, true).split(" ", false)
	var mom_first: String = mom_parts[0] if mom_parts.size() > 0 else "Sarah"
	var mom_age := randi_range(22, 44)
	var mom_job := ""
	var mom_edu := ""
	var mom_health := 80
	var mom_condition := ""
	var mom_has_cancer := false

	match family_wealth:
		"poor":
			mom_edu = POOR_EDU.pick_random()
			if randf() < 0.35:
				mom_job = "unemployed"
			else:
				mom_job = POOR_JOBS.pick_random()
		"wealthy":
			mom_edu = WEALTHY_EDU.pick_random()
			mom_job = WEALTHY_JOBS.pick_random()
		_: # middle_class
			mom_edu = MIDDLE_EDU.pick_random()
			mom_job = MIDDLE_JOBS.pick_random()

	# Mother health condition check (~14% chance)
	if randf() < 0.14:
		if randf() < 0.50:
			var cancer_type: String = CANCER_CONDITIONS.pick_random()
			mom_condition = cancer_type
			mom_has_cancer = true
			mom_health = randi_range(35, 50)
		else:
			mom_condition = OTHER_CONDITIONS.pick_random()
			mom_health = randi_range(50, 65)

	# 3. Father Details aligned with wealth
	var dad_present := randf() > 0.15
	var dad_first := ""
	var dad_age := mom_age + randi_range(-2, 5)
	var dad_job := ""
	var dad_edu := ""
	var dad_health := 80
	var dad_condition := ""
	var dad_has_cancer := false

	if dad_present:
		var dad_parts := NameCatalog.random_name(safe_country, false).split(" ", false)
		dad_first = dad_parts[0] if dad_parts.size() > 0 else "David"
		match family_wealth:
			"poor":
				dad_edu = POOR_EDU.pick_random()
				if randf() < 0.35:
					dad_job = "unemployed"
				else:
					dad_job = POOR_JOBS.pick_random()
			"wealthy":
				dad_edu = WEALTHY_EDU.pick_random()
				dad_job = WEALTHY_JOBS.pick_random()
			_: # middle_class
				dad_edu = MIDDLE_EDU.pick_random()
				dad_job = MIDDLE_JOBS.pick_random()

		# Father health condition check (~14% chance)
		if randf() < 0.14:
			if randf() < 0.50:
				var cancer_type: String = CANCER_CONDITIONS.pick_random()
				dad_condition = cancer_type
				dad_has_cancer = true
				dad_health = randi_range(35, 50)
			else:
				dad_condition = OTHER_CONDITIONS.pick_random()
				dad_health = randi_range(50, 65)

	var circumstance: String = CONCEPTION_STORIES.pick_random()
	var gender_term := "male" if gender.to_upper() == "MALE" else "female"

	var lines: Array[String] = []
	lines.append("I am a %s who came into the world in %s." % [gender_term, LifeLibrary.birth_location(country)])
	lines.append(circumstance)
	lines.append("My birthday is %s %d. I am a %s." % [month_name, day, zodiac])
	lines.append("My name is %s." % first_name)

	# Socioeconomic background line
	match family_wealth:
		"poor":
			lines.append("I was born into an impoverished household where money is tight and every dollar counts.")
		"wealthy":
			lines.append("I was born into an affluent, wealthy family surrounded by luxury and high society.")
		_: # middle_class
			lines.append("I was born into a hardworking middle-class family residing in a cozy suburban neighborhood.")

	# Mother line
	if mom_job == "unemployed":
		lines.append("My mother is %s %s (age %d), currently unemployed with a %s education." % [mom_first, last_name, mom_age, mom_edu])
	else:
		lines.append("My mother is %s %s (age %d), a %s with a %s education." % [mom_first, last_name, mom_age, mom_job, mom_edu])

	if mom_has_cancer:
		lines.append("Your mother has cancer (%s)." % mom_condition)
	elif mom_condition != "":
		lines.append("Your mother suffers from %s." % mom_condition)

	# Father line
	if dad_present:
		if dad_job == "unemployed":
			lines.append("My father is %s %s (age %d), currently unemployed with a %s education." % [dad_first, last_name, dad_age, dad_edu])
		else:
			lines.append("My father is %s %s (age %d), a %s with a %s education." % [dad_first, last_name, dad_age, dad_job, dad_edu])

		if dad_has_cancer:
			lines.append("Your father has cancer (%s)." % dad_condition)
		elif dad_condition != "":
			lines.append("Your father suffers from %s." % dad_condition)
	else:
		lines.append("My mother is raising me as a single parent.")

	var full_text := "\n".join(lines)

	return {
		"story": full_text,
		"birth_description": full_text,
		"birth_month": month_name,
		"birth_day": day,
		"zodiac": zodiac,
		"family_wealth": family_wealth,
		"mother_name": "%s %s" % [mom_first, last_name],
		"mother_age": mom_age,
		"mother_job": mom_job,
		"mother_education": mom_edu,
		"mother_condition": mom_condition,
		"mother_health": mom_health,
		"mother_portrait_track": randi() % 4,
		"father_name": "%s %s" % [dad_first, last_name] if dad_present else "Unknown",
		"father_age": dad_age if dad_present else 0,
		"father_job": dad_job if dad_present else "N/A",
		"father_education": dad_edu if dad_present else "N/A",
		"father_condition": dad_condition if dad_present else "",
		"father_health": dad_health,
		"father_portrait_track": randi() % 4,
		"has_father": dad_present
	}


static func generate_reincarnation_profile(first_name: String, country: String, gender: String, buffs: Array = [], debuffs: Array = []) -> Dictionary:
	var safe_country := country if NameCatalog.POOLS.has(country) else "United States"
	var month_idx := randi_range(0, 11)
	var month_info: Dictionary = MONTH_DATA[month_idx]
	var month_name: String = month_info["name"]
	var day: int = randi_range(1, int(month_info["days"]))
	var zodiac: String = get_zodiac(month_idx + 1, day)

	var last_name := ""
	var name_parts := first_name.split(" ", false)
	if name_parts.size() > 1:
		last_name = name_parts[name_parts.size() - 1]
	else:
		var r_parts := NameCatalog.random_name(safe_country, false).split(" ", false)
		last_name = r_parts[r_parts.size() - 1] if r_parts.size() > 0 else "Smith"

	# Socioeconomic Family Wealth Tier influenced by karmic blessings / curses
	var family_wealth := "middle_class"
	if "poverty" in debuffs:
		family_wealth = "poor"
	elif "silver_spoon" in buffs or "golden_pedigree" in buffs:
		family_wealth = "wealthy"
	else:
		var wealth_roll := randf()
		if wealth_roll < 0.25:
			family_wealth = "poor"
		elif wealth_roll < 0.80:
			family_wealth = "middle_class"
		else:
			family_wealth = "wealthy"

	var is_orphan: bool = ("no_parents" in debuffs)
	var has_golden_pedigree: bool = ("golden_pedigree" in buffs)

	var mom_first := ""
	var mom_name := ""
	var mom_age := 0
	var mom_job := ""
	var mom_edu := ""
	var mom_health := 0
	var mom_condition := ""
	var mom_alive := false
	var mom_portrait_track: int = randi() % 4

	var dad_present := false
	var dad_first := ""
	var dad_name := ""
	var dad_age := 0
	var dad_job := ""
	var dad_edu := ""
	var dad_health := 0
	var dad_condition := ""
	var dad_alive := false
	var dad_portrait_track: int = randi() % 4

	if is_orphan:
		mom_name = "Deceased"
		mom_alive = false
		mom_health = 0
		mom_job = "N/A"
		mom_edu = "N/A"
		dad_name = "Deceased"
		dad_alive = false
		dad_health = 0
		dad_job = "N/A"
		dad_edu = "N/A"
		dad_present = false
	else:
		var mom_parts := NameCatalog.random_name(safe_country, true).split(" ", false)
		mom_first = mom_parts[0] if mom_parts.size() > 0 else "Sarah"
		mom_name = "%s %s" % [mom_first, last_name]
		mom_age = randi_range(24, 42)
		mom_alive = true
		mom_health = 80

		if has_golden_pedigree:
			mom_edu = WEALTHY_EDU.pick_random()
			mom_job = WEALTHY_JOBS.pick_random()
			mom_health = 90
		else:
			match family_wealth:
				"poor":
					mom_edu = POOR_EDU.pick_random()
					mom_job = "unemployed" if randf() < 0.35 else POOR_JOBS.pick_random()
				"wealthy":
					mom_edu = WEALTHY_EDU.pick_random()
					mom_job = WEALTHY_JOBS.pick_random()
				_:
					mom_edu = MIDDLE_EDU.pick_random()
					mom_job = MIDDLE_JOBS.pick_random()

			if randf() < 0.12 and not ("radiant_vitality" in buffs):
				if randf() < 0.50:
					mom_condition = CANCER_CONDITIONS.pick_random()
					mom_health = randi_range(35, 50)
				else:
					mom_condition = OTHER_CONDITIONS.pick_random()
					mom_health = randi_range(50, 65)

		dad_present = has_golden_pedigree or (randf() > 0.12)
		if dad_present:
			var dad_parts := NameCatalog.random_name(safe_country, false).split(" ", false)
			dad_first = dad_parts[0] if dad_parts.size() > 0 else "David"
			dad_name = "%s %s" % [dad_first, last_name]
			dad_age = mom_age + randi_range(-2, 4)
			dad_alive = true
			dad_health = 80

			if has_golden_pedigree:
				dad_edu = WEALTHY_EDU.pick_random()
				dad_job = WEALTHY_JOBS.pick_random()
				dad_health = 90
			else:
				match family_wealth:
					"poor":
						dad_edu = POOR_EDU.pick_random()
						dad_job = "unemployed" if randf() < 0.35 else POOR_JOBS.pick_random()
					"wealthy":
						dad_edu = WEALTHY_EDU.pick_random()
						dad_job = WEALTHY_JOBS.pick_random()
					_:
						dad_edu = MIDDLE_EDU.pick_random()
						dad_job = MIDDLE_JOBS.pick_random()

				if randf() < 0.12 and not ("radiant_vitality" in buffs):
					if randf() < 0.50:
						dad_condition = CANCER_CONDITIONS.pick_random()
						dad_health = randi_range(35, 50)
					else:
						dad_condition = OTHER_CONDITIONS.pick_random()
						dad_health = randi_range(50, 65)
		else:
			dad_name = "Unknown"
			dad_alive = false
			dad_age = 0
			dad_job = "N/A"
			dad_edu = "N/A"
			dad_health = 0

	var circumstance: String = CONCEPTION_STORIES.pick_random()
	var gender_term := "male" if gender.to_upper() == "MALE" else "female"

	var lines: Array[String] = []
	lines.append("I am a %s who came into the world in %s." % [gender_term, LifeLibrary.birth_location(safe_country)])
	lines.append(circumstance)
	lines.append("My birthday is %s %d. I am a %s." % [month_name, day, zodiac])
	lines.append("My name is %s." % first_name)

	# Socioeconomic background line
	if has_golden_pedigree:
		lines.append("I was born into a prestigious, high-society family of renowned professionals who cherish and support me.")
	elif family_wealth == "wealthy":
		lines.append("I was born into an affluent, wealthy family surrounded by luxury and high society.")
	elif family_wealth == "poor":
		lines.append("I was born into an impoverished household where money is tight and every dollar counts.")
	else:
		lines.append("I was born into a hardworking middle-class family residing in a cozy suburban neighborhood.")

	# Parents description
	if is_orphan:
		lines.append("I was born an orphan. Both of my biological parents are absent or deceased, and I am being raised in austere state foster care.")
	else:
		if mom_alive:
			if mom_job == "unemployed":
				lines.append("My mother is %s (age %d), currently unemployed with a %s education." % [mom_name, mom_age, mom_edu])
			else:
				lines.append("My mother is %s (age %d), a %s with a %s education." % [mom_name, mom_age, mom_job, mom_edu])

			if mom_condition != "":
				if mom_condition in CANCER_CONDITIONS:
					lines.append("Your mother has cancer (%s)." % mom_condition)
				else:
					lines.append("Your mother suffers from %s." % mom_condition)

		if dad_present and dad_alive:
			if dad_job == "unemployed":
				lines.append("My father is %s (age %d), currently unemployed with a %s education." % [dad_name, dad_age, dad_edu])
			else:
				lines.append("My father is %s (age %d), a %s with a %s education." % [dad_name, dad_age, dad_job, dad_edu])

			if dad_condition != "":
				if dad_condition in CANCER_CONDITIONS:
					lines.append("Your father has cancer (%s)." % dad_condition)
				else:
					lines.append("Your father suffers from %s." % dad_condition)
		elif mom_alive:
			lines.append("My mother is raising me as a single parent.")

	var full_text := "\n".join(lines)

	return {
		"story": full_text,
		"birth_description": full_text,
		"birth_month": month_name,
		"birth_day": day,
		"zodiac": zodiac,
		"family_wealth": family_wealth,
		"mother_name": mom_name,
		"mother_age": mom_age,
		"mother_job": mom_job,
		"mother_education": mom_edu,
		"mother_condition": mom_condition,
		"mother_health": mom_health,
		"mother_portrait_track": mom_portrait_track,
		"mother_alive": mom_alive,
		"father_name": dad_name,
		"father_age": dad_age,
		"father_job": dad_job,
		"father_education": dad_edu,
		"father_condition": dad_condition,
		"father_health": dad_health,
		"father_portrait_track": dad_portrait_track,
		"father_alive": dad_alive,
		"has_father": dad_present and dad_alive
	}

