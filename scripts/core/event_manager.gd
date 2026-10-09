extends Node

var events: Array = []


func _ready() -> void:
	load_events()


func load_events() -> void:
	var file := FileAccess.open(
		"res://data/events/basic_events.json",
		FileAccess.READ
	)

	if file == null:
		push_error("Could not open event file.")
		return

	var json_text := file.get_as_text()
	file.close()

	var parsed_data = JSON.parse_string(json_text)

	if parsed_data == null:
		push_error("Failed to parse event JSON.")
		return

	if parsed_data is not Array:
		push_error("Event JSON root must be an array.")
		return

	events = parsed_data
	print("Loaded %d events." % events.size())


func get_valid_events(
	age: int,
	event_history: Array,
	player_stats: Dictionary,
	event_history_log: Dictionary = {}
) -> Array:
	var valid_events: Array = []

	for event in events:
		if event is not Dictionary:
			continue

		if not _passes_age_check(event, age):
			continue

		if not _passes_repeat_check(event, event_history, age, event_history_log):
			continue

		if not _passes_conditions(event, player_stats, event_history):
			continue

		valid_events.append(event)

	return valid_events


func _passes_age_check(event: Dictionary, age: int) -> bool:
	var min_age := int(event.get("min_age", 0))
	var max_age := int(event.get("max_age", 999))
	return age >= min_age and age <= max_age


func _passes_repeat_check(
	event: Dictionary,
	event_history: Array,
	age: int = -1,
	event_history_log: Dictionary = {}
) -> bool:
	var event_id := str(event.get("id", ""))
	if event_id == "":
		return true

	var repeatable := bool(event.get("repeatable", true))
	if not repeatable:
		return not event_history.has(event_id)

	# For repeatable events, enforce minimum cooldown period to prevent annoying repeats
	if age >= 0 and not event_history_log.is_empty():
		if event_history_log.has(event_id):
			var last_age: int = int(event_history_log.get(event_id, -999))
			var cooldown: int = int(event.get("cooldown_years", 10))
			if (age - last_age) < cooldown:
				return false

	return true


func _passes_conditions(
	event: Dictionary,
	player_stats: Dictionary,
	event_history: Array
) -> bool:
	var conditions: Dictionary = event.get("conditions", {})

	if conditions.has("min_health") and int(player_stats.get("health", 0)) < int(conditions["min_health"]):
		return false
	if conditions.has("max_health") and int(player_stats.get("health", 0)) > int(conditions["max_health"]):
		return false
	if conditions.has("min_happiness") and int(player_stats.get("happiness", 0)) < int(conditions["min_happiness"]):
		return false
	if conditions.has("max_happiness") and int(player_stats.get("happiness", 0)) > int(conditions["max_happiness"]):
		return false
	if conditions.has("min_smarts") and int(player_stats.get("smarts", 0)) < int(conditions["min_smarts"]):
		return false
	if conditions.has("max_smarts") and int(player_stats.get("smarts", 0)) > int(conditions["max_smarts"]):
		return false
	if conditions.has("min_looks") and int(player_stats.get("looks", 0)) < int(conditions["min_looks"]):
		return false
	if conditions.has("max_looks") and int(player_stats.get("looks", 0)) > int(conditions["max_looks"]):
		return false
	if conditions.has("min_karma") and int(player_stats.get("karma", 0)) < int(conditions["min_karma"]):
		return false
	if conditions.has("max_karma") and int(player_stats.get("karma", 0)) > int(conditions["max_karma"]):
		return false

	if conditions.has("required_event"):
		var required_event := str(conditions["required_event"])
		if not event_history.has(required_event):
			return false

	if conditions.has("excluded_event"):
		var excluded_event := str(conditions["excluded_event"])
		if event_history.has(excluded_event):
			return false

	if conditions.has("requires_firearm") and bool(conditions["requires_firearm"]):
		if not bool(player_stats.get("has_firearm", false)):
			return false

	if conditions.has("has_firearm") and bool(conditions["has_firearm"]):
		if not bool(player_stats.get("has_firearm", false)):
			return false

	return true


func get_firearm_defense_event(
	age: int,
	event_history: Array,
	player_stats: Dictionary,
	event_history_log: Dictionary = {}
):
	if not bool(player_stats.get("has_firearm", false)):
		return null

	var valid_firearm_events: Array = []
	for event in events:
		var conditions: Dictionary = event.get("conditions", {})
		if not bool(conditions.get("requires_firearm", false)) and not bool(conditions.get("has_firearm", false)):
			continue
		if age < int(event.get("min_age", 0)) or age > int(event.get("max_age", 120)):
			continue
		if not _passes_repeat_check(event, event_history, age, event_history_log):
			continue
		if _passes_conditions(event, player_stats, event_history):
			valid_firearm_events.append(event)

	if valid_firearm_events.is_empty():
		return null
	return _pick_weighted_event(valid_firearm_events)


func get_random_event(
	age: int,
	event_history: Array,
	player_stats: Dictionary,
	event_history_log: Dictionary = {}
):
	var valid_events := get_valid_events(age, event_history, player_stats, event_history_log)

	if valid_events.is_empty():
		return null

	return _pick_weighted_event(valid_events)


func _pick_weighted_event(valid_events: Array):
	var total_weight := 0

	for event in valid_events:
		total_weight += max(int(event.get("weight", 100)), 0)

	if total_weight <= 0:
		return valid_events.pick_random()

	var roll := randi_range(1, total_weight)
	var running_total := 0

	for event in valid_events:
		running_total += max(int(event.get("weight", 100)), 0)
		if roll <= running_total:
			return event

	return valid_events.back()
