class_name CharacterAppearance
extends Resource

## Lightweight appearance data model for isometric characters.
## Separates appearance configuration (body, hair, clothing, shoes, accessories, age)
## from character movement, roaming, and physics simulation logic.

const AGE_INFANT := "infant"
const AGE_CHILD := "child"
const AGE_TEEN := "teen"
const AGE_ADULT := "adult"
const AGE_ELDER := "elder"

const VALID_AGE_GROUPS: Array[String] = [
	AGE_INFANT,
	AGE_CHILD,
	AGE_TEEN,
	AGE_ADULT,
	AGE_ELDER
]

const SLOT_BODY := "body"
const SLOT_BOTTOM := "bottom"
const SLOT_SHOES := "shoes"
const SLOT_TOP := "top"
const SLOT_HAIR := "hair"
const SLOT_ACCESSORY := "accessory"

const STANDARD_SLOTS: Array[String] = [
	SLOT_BODY,
	SLOT_BOTTOM,
	SLOT_SHOES,
	SLOT_TOP,
	SLOT_HAIR,
	SLOT_ACCESSORY
]

@export var age_group: String = AGE_ADULT
@export var gender: String = "neutral"
@export var body_id: String = "default"
@export var hair_id: String = ""
@export var top_id: String = ""
@export var bottom_id: String = ""
@export var shoes_id: String = ""
@export var accessory_id: String = ""
@export var custom_slots: Dictionary = {}

func _init(p_body_id: String = "default", p_age_group: String = AGE_ADULT) -> void:
	body_id = p_body_id
	age_group = p_age_group

## Derives the life stage / age group from an integer age in years.
static func get_age_group_from_years(years: int) -> String:
	if years < 3:
		return AGE_INFANT
	elif years < 13:
		return AGE_CHILD
	elif years < 20:
		return AGE_TEEN
	elif years < 65:
		return AGE_ADULT
	else:
		return AGE_ELDER

## Sets a customizable slot by name.
func set_slot(slot_name: String, item_id: String) -> void:
	match slot_name.to_lower():
		SLOT_BODY:
			body_id = item_id
		SLOT_HAIR:
			hair_id = item_id
		SLOT_TOP:
			top_id = item_id
		SLOT_BOTTOM:
			bottom_id = item_id
		SLOT_SHOES:
			shoes_id = item_id
		SLOT_ACCESSORY:
			accessory_id = item_id
		_:
			custom_slots[slot_name] = item_id

## Gets the item ID assigned to a specific slot name.
func get_slot(slot_name: String) -> String:
	match slot_name.to_lower():
		SLOT_BODY:
			return body_id
		SLOT_HAIR:
			return hair_id
		SLOT_TOP:
			return top_id
		SLOT_BOTTOM:
			return bottom_id
		SLOT_SHOES:
			return shoes_id
		SLOT_ACCESSORY:
			return accessory_id
		_:
			return str(custom_slots.get(slot_name, ""))

## Returns whether a slot has an assigned item.
func has_slot_item(slot_name: String) -> bool:
	return get_slot(slot_name).strip_edges() != ""

## Clears an item assignment from a slot.
func clear_slot(slot_name: String) -> void:
	set_slot(slot_name, "")

## Serializes the appearance model to a clean Dictionary for save game storage.
func to_dict() -> Dictionary:
	return {
		"age_group": age_group,
		"gender": gender,
		"body_id": body_id,
		"hair_id": hair_id,
		"top_id": top_id,
		"bottom_id": bottom_id,
		"shoes_id": shoes_id,
		"accessory_id": accessory_id,
		"custom_slots": custom_slots.duplicate()
	}

## Deserializes appearance data from a Dictionary.
func from_dict(data: Dictionary) -> void:
	age_group = str(data.get("age_group", AGE_ADULT))
	gender = str(data.get("gender", "neutral"))
	body_id = str(data.get("body_id", "default"))
	hair_id = str(data.get("hair_id", ""))
	top_id = str(data.get("top_id", ""))
	bottom_id = str(data.get("bottom_id", ""))
	shoes_id = str(data.get("shoes_id", ""))
	accessory_id = str(data.get("accessory_id", ""))
	var raw_custom = data.get("custom_slots", {})
	if raw_custom is Dictionary:
		custom_slots = raw_custom.duplicate()
	else:
		custom_slots = {}

## Static factory constructor from Dictionary.
static func create_from_dict(data: Dictionary):
	var app = new()
	app.from_dict(data)
	return app

## Clones this appearance model.
func clone():
	return create_from_dict(to_dict())
