extends Node

## Centralized authoritative real-time game clock for Life.exe.
## Responsible for Gregorian calendar simulation, leap years, birthdays,
## deterministic delta time accumulation, age calculation, and progression events.

signal day_changed(year: int, month: int, day: int)
signal month_changed(year: int, month: int)
signal year_changed(year: int)
signal birthday(new_age: int)
signal clock_paused()
signal clock_resumed()
signal time_ticked(day_progress: float)

const MONTH_NAMES: Array[String] = [
	"January", "February", "March", "April", "May", "June",
	"July", "August", "September", "October", "November", "December"
]

const MONTH_SHORT_NAMES: Array[String] = [
	"Jan", "Feb", "Mar", "Apr", "May", "Jun",
	"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
]

const MONTH_DAYS_NORMAL: Array[int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

# Default starting configuration for new characters
const DEFAULT_START_YEAR: int = 2026
const DEFAULT_START_MONTH: int = 1
const DEFAULT_START_DAY: int = 1
const DEFAULT_START_AGE: int = 17

# Singleton instance reference
static var instance: Node = null

static func get_instance() -> Node:
	return instance

# Current In-Game Calendar State
var year: int = DEFAULT_START_YEAR
var month: int = DEFAULT_START_MONTH
var day: int = DEFAULT_START_DAY

# Character Birth Date
var birth_year: int = 2009
var birth_month: int = 1
var birth_day: int = 1

# Current Authoritative Age
var current_age: int = DEFAULT_START_AGE

# Time Progression & Accumulator
# 1.0 real-world second of active unpaused gameplay = 1 in-game day
var seconds_per_day: float = 1.0
var day_accumulator: float = 0.0

# Pause Management & Multi-Reason Lock Dictionary
var is_paused: bool = false
var pause_reasons: Dictionary = {}

# Event Processing Cursor to prevent duplicate triggers on the same calendar date
var event_cursor: Dictionary = {
	"year": 0,
	"month": 0,
	"day": 0
}

# External progression validator callback (e.g. MainScreen check)
var external_progression_check: Callable = Callable()


func _enter_tree() -> void:
	if instance != null and instance != self:
		push_warning("[GameClock] Duplicate GameClock instance detected! Self-destructing duplicate.")
		queue_free()
		return
	instance = self


func _exit_tree() -> void:
	if instance == self:
		instance = null


func _ready() -> void:
	# Recalculate age to guarantee synchronization
	current_age = calculate_age(year, month, day, birth_year, birth_month, birth_day)
	_sync_to_player_data()


# -----------------------------------------------------------------------------
# STATIC CALENDAR & DATE CALCULATIONS
# -----------------------------------------------------------------------------

static func is_leap_year(y: int) -> bool:
	return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)


static func get_days_in_month(y: int, m: int) -> int:
	if m < 1 or m > 12:
		return 30
	if m == 2 and is_leap_year(y):
		return 29
	return MONTH_DAYS_NORMAL[m - 1]


static func get_month_name(m: int) -> String:
	if m >= 1 and m <= 12:
		return MONTH_NAMES[m - 1]
	return "January"


static func get_month_short_name(m: int) -> String:
	if m >= 1 and m <= 12:
		return MONTH_SHORT_NAMES[m - 1]
	return "Jan"


static func month_name_to_index(m_name: String) -> int:
	var clean := m_name.strip_edges().to_lower()
	for i in range(MONTH_NAMES.size()):
		if MONTH_NAMES[i].to_lower() == clean or MONTH_SHORT_NAMES[i].to_lower() == clean:
			return i + 1
	return 1


## Pure deterministic function to calculate age given a date and a birth date.
## The same simulated date always produces the exact same age.
static func calculate_age(cur_y: int, cur_m: int, cur_d: int, b_y: int, b_m: int, b_d: int) -> int:
	var calculated: int = cur_y - b_y
	var eff_b_d := b_d
	# For people born on leap day Feb 29, treat their birthday as Feb 28 in non-leap years
	if b_m == 2 and b_d == 29 and not is_leap_year(cur_y):
		eff_b_d = 28

	if cur_m < b_m or (cur_m == b_m and cur_d < eff_b_d):
		calculated -= 1
	return maxi(0, calculated)


## Checks if today is the character's birthday.
static func is_birthday_on_date(cur_y: int, cur_m: int, cur_d: int, b_m: int, b_d: int) -> bool:
	if cur_m != b_m:
		return false
	if cur_d == b_d:
		return true
	# Handle Feb 29 birthdays in non-leap years on Feb 28
	if b_m == 2 and b_d == 29 and not is_leap_year(cur_y) and cur_d == 28:
		return true
	return false


## Given a target start date, starting age (e.g. 17), and birth month/day,
## returns the exact birth year required so the character is exactly `starting_age` on `start_date`.
static func derive_birth_year(start_y: int, start_m: int, start_d: int, b_m: int, b_d: int, starting_age: int = DEFAULT_START_AGE) -> int:
	var eff_b_d := b_d
	if b_m == 2 and b_d == 29 and not is_leap_year(start_y):
		eff_b_d = 28

	if start_m > b_m or (start_m == b_m and start_d >= eff_b_d):
		return start_y - starting_age
	else:
		return (start_y - 1) - starting_age


# -----------------------------------------------------------------------------
# INITIALIZATION & NEW GAME SETUP
# -----------------------------------------------------------------------------

## Initializes a fresh game character with Gregorian calendar and starting age 17.
func setup_new_game(b_month: int, b_day: int, start_y: int = DEFAULT_START_YEAR, start_m: int = DEFAULT_START_MONTH, start_d: int = DEFAULT_START_DAY, starting_age: int = DEFAULT_START_AGE) -> void:
	year = start_y
	month = start_m
	day = start_d

	birth_month = clampi(b_month, 1, 12)
	birth_day = clampi(b_day, 1, get_days_in_month(year, birth_month))
	birth_year = derive_birth_year(year, month, day, birth_month, birth_day, starting_age)

	current_age = calculate_age(year, month, day, birth_year, birth_month, birth_day)
	day_accumulator = 0.0
	pause_reasons.clear()
	is_paused = false
	event_cursor = {"year": year, "month": month, "day": day}

	_sync_to_player_data()


# -----------------------------------------------------------------------------
# REAL-TIME PROCESS & DETERMINISTIC TIME ACCUMULATION
# -----------------------------------------------------------------------------

var _last_process_frame: int = -1


func _process(delta: float) -> void:
	var cur_frame := Engine.get_process_frames()
	if cur_frame == _last_process_frame and cur_frame > 0:
		return
	_last_process_frame = cur_frame
	step_clock(delta)


func was_stepped_this_frame() -> bool:
	var cur_frame := Engine.get_process_frames()
	return cur_frame > 0 and cur_frame == _last_process_frame


func step_clock(delta: float) -> void:
	if not is_running():
		return

	day_accumulator += delta
	while day_accumulator >= seconds_per_day:
		if not is_running():
			break
		day_accumulator -= seconds_per_day
		_advance_single_day()

	if is_running():
		emit_signal("time_ticked", day_accumulator / seconds_per_day)


## Advances the game clock by a specific number of days, safely handling
## multi-day elapsed frames deterministically and stopping immediately if paused.
func advance_days(count: int) -> void:
	if count <= 0:
		return

	for _i in range(count):
		if not is_running():
			break
		_advance_single_day()


func _advance_single_day() -> void:
	day += 1
	var max_days := get_days_in_month(year, month)
	var month_rolled := false
	var year_rolled := false

	if day > max_days:
		day = 1
		month += 1
		month_rolled = true
		if month > 12:
			month = 1
			year += 1
			year_rolled = true

	# Calculate age strictly from date and birth date
	var previous_age := current_age
	current_age = calculate_age(year, month, day, birth_year, birth_month, birth_day)

	# Update cursor & PlayerData
	event_cursor = {"year": year, "month": month, "day": day}
	_sync_to_player_data()

	# Emit signals
	emit_signal("day_changed", year, month, day)

	if month_rolled:
		emit_signal("month_changed", year, month)

	if year_rolled:
		emit_signal("year_changed", year)

	# Birthday trigger
	if is_birthday_on_date(year, month, day, birth_month, birth_day):
		emit_signal("birthday", current_age)

	emit_signal("time_ticked", 0.0)


func _sync_to_player_data() -> void:
	if PlayerData == null:
		return
	PlayerData.age = current_age
	PlayerData.in_game_day = day
	PlayerData.in_game_month = month
	PlayerData.in_game_year = year
	PlayerData.birth_year = birth_year
	PlayerData.birth_month = get_month_name(birth_month)
	PlayerData.birth_month_idx = birth_month
	PlayerData.birth_day = birth_day
	PlayerData.day_accumulator = day_accumulator



# -----------------------------------------------------------------------------
# PAUSE & RESUME CONTROLS
# -----------------------------------------------------------------------------

func pause(reason: String = "general") -> void:
	pause_reasons[reason] = true
	var was_paused := is_paused
	is_paused = true
	if not was_paused:
		emit_signal("clock_paused")


func resume(reason: String = "general") -> void:
	pause_reasons.erase(reason)
	if pause_reasons.is_empty():
		var was_paused := is_paused
		is_paused = false
		if was_paused:
			emit_signal("clock_resumed")


func set_paused(paused: bool, reason: String = "general") -> void:
	if paused:
		pause(reason)
	else:
		resume(reason)


func is_running() -> bool:
	if is_paused or not pause_reasons.is_empty():
		return false

	if external_progression_check.is_valid():
		var target_obj = external_progression_check.get_object()
		if target_obj != null and is_instance_valid(target_obj):
			if not external_progression_check.call():
				return false

	if PlayerData != null:
		if not PlayerData.has_started_game:
			return false
		if PlayerData.is_dead:
			return false
		if PlayerData.is_time_paused:
			return false

	return true


# -----------------------------------------------------------------------------
# FORMATTING & DISPLAY HELPERS
# -----------------------------------------------------------------------------

func get_date_string() -> String:
	return "%s %d, %d" % [get_month_name(month), day, year]


func get_short_date_string() -> String:
	return "%s %d" % [get_month_short_name(month), day]


func get_birthday_string() -> String:
	return "%s %d, %d" % [get_month_name(birth_month), birth_day, birth_year]


# -----------------------------------------------------------------------------
# PERSISTENCE & OLD SAVE MIGRATION
# -----------------------------------------------------------------------------

func capture_save_data() -> Dictionary:
	return {
		"calendar_year": year,
		"calendar_month": month,
		"calendar_day": day,
		"birth_year": birth_year,
		"birth_month": birth_month,
		"birth_day": birth_day,
		"current_age": current_age,
		"day_accumulator": day_accumulator,
		"event_cursor": event_cursor.duplicate(),
		"is_paused": is_paused,
		"clock_version": 2
	}


func restore_save_data(data: Dictionary) -> void:
	if data.has("calendar_year") and int(data.get("clock_version", 1)) >= 2:
		# Standard version 2+ save
		year = int(data.get("calendar_year", DEFAULT_START_YEAR))
		month = clampi(int(data.get("calendar_month", 1)), 1, 12)
		day = clampi(int(data.get("calendar_day", 1)), 1, get_days_in_month(year, month))

		birth_year = int(data.get("birth_year", 2014))
		birth_month = clampi(int(data.get("birth_month", 1)), 1, 12)
		birth_day = clampi(int(data.get("birth_day", 1)), 1, get_days_in_month(birth_year, birth_month))

		day_accumulator = float(data.get("day_accumulator", 0.0))
		event_cursor = Dictionary(data.get("event_cursor", {"year": year, "month": month, "day": day}))
		is_paused = bool(data.get("is_paused", false))
		current_age = calculate_age(year, month, day, birth_year, birth_month, birth_day)
	else:
		# Safe versioned migration for older saves (preserves existing age, money, assets)
		migrate_legacy_save(data)

	_sync_to_player_data()


func migrate_legacy_save(data: Dictionary) -> void:
	var legacy_age: int = maxi(0, int(data.get("age", 12)))
	var raw_month: int = int(data.get("in_game_month", 1))
	var raw_day: int = int(data.get("in_game_day", 1))
	var raw_year: int = int(data.get("in_game_year", 1))

	# Map relative in_game_year to modern Gregorian baseline
	if raw_year >= 1900:
		year = raw_year
	else:
		year = DEFAULT_START_YEAR + maxi(0, raw_year - 1)
	month = clampi(raw_month, 1, 12)
	day = clampi(raw_day, 1, get_days_in_month(year, month))

	# Extract or parse birth month/day
	var raw_b_month = data.get("birth_month", "January")
	if typeof(raw_b_month) == TYPE_STRING:
		birth_month = month_name_to_index(str(raw_b_month))
	else:
		birth_month = clampi(int(raw_b_month), 1, 12)

	birth_day = clampi(int(data.get("birth_day", 1)), 1, get_days_in_month(year, birth_month))

	# Derive birth year such that age on the current date matches existing age exactly
	birth_year = derive_birth_year(year, month, day, birth_month, birth_day, legacy_age)
	current_age = legacy_age

	day_accumulator = 0.0
	pause_reasons.clear()
	is_paused = false
	event_cursor = {"year": year, "month": month, "day": day}

	print("[GameClock] Safe migration complete for legacy character (Age: %d, Calendar: %04d-%02d-%02d, Birth: %04d-%02d-%02d)." % [
		current_age, year, month, day, birth_year, birth_month, birth_day
	])
