class_name RoomManager
extends RefCounted

## Walkable floor diamond derived from 2048x2048 isometric room artwork with safety margin.
## The floor corners in image coordinates are:
## Top: (1024, 755), Right: (1908, 1220), Bottom: (1024, 1690), Left: (140, 1220).
## Centered at (0, 0), these are (0, -269), (884, 196), (0, 666), (-884, 196).
## Inset by safe margins from walls and ledges:
const DEFAULT_WALKABLE_POLYGON: PackedVector2Array = [
	Vector2(0, -120),    # Top back corner (inset safely from baseboard)
	Vector2(630, 200),   # Right corner (inset safely from right edge)
	Vector2(0, 500),     # Bottom front corner (inset safely from front rim)
	Vector2(-630, 200)   # Left corner (inset safely from left edge)
]

const ROOM_DEFINITIONS: Dictionary = {
	# -------------------------------------------------------------------------
	# 24 PROPERTY HOUSING ROOM TEMPLATES (The Housing Update)
	# -------------------------------------------------------------------------
	"room_capsule": {
		"id": "room_capsule",
		"property_id": "prop_capsule",
		"name": "Cozy Starter Home",
		"texture_path": "res://assets/isometric/rooms/room_capsule.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_tenement": {
		"id": "room_tenement",
		"property_id": "prop_tenement",
		"name": "Old District Tenement Flat",
		"texture_path": "res://assets/isometric/rooms/room_tenement.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_studio": {
		"id": "room_studio",
		"property_id": "prop_studio",
		"name": "Downtown Studio Loft",
		"texture_path": "res://assets/isometric/rooms/room_studio.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_condo": {
		"id": "room_condo",
		"property_id": "prop_condo",
		"name": "Neon Heights 1-Bedroom Condo",
		"texture_path": "res://assets/isometric/rooms/room_condo.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_cottage": {
		"id": "room_cottage",
		"property_id": "prop_cottage",
		"name": "Sunnyvale Starter Cottage",
		"texture_path": "res://assets/isometric/rooms/room_cottage.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_suburban_split": {
		"id": "room_suburban_split",
		"property_id": "prop_suburban_split",
		"name": "Contemporary Split-Level House",
		"texture_path": "res://assets/isometric/rooms/room_suburban_split.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_townhouse": {
		"id": "room_townhouse",
		"property_id": "prop_townhouse",
		"name": "Cobblestone Row Townhouse",
		"texture_path": "res://assets/isometric/rooms/room_townhouse.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_eco_timber": {
		"id": "room_eco_timber",
		"property_id": "prop_eco_timber",
		"name": "Eco-Timber Sustainable Home",
		"texture_path": "res://assets/isometric/rooms/room_eco_timber.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_house": {
		"id": "room_house",
		"property_id": "prop_house",
		"name": "Suburban Family Residence",
		"texture_path": "res://assets/isometric/rooms/room_house.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_cabin": {
		"id": "room_cabin",
		"property_id": "prop_cabin",
		"name": "Pine Crest Lakeside Cabin",
		"texture_path": "res://assets/isometric/rooms/room_cabin.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_historic_brownstone": {
		"id": "room_historic_brownstone",
		"property_id": "prop_historic_brownstone",
		"name": "Heritage Brownstone Mansion",
		"texture_path": "res://assets/isometric/rooms/room_historic_brownstone.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_modern_villa": {
		"id": "room_modern_villa",
		"property_id": "prop_modern_villa",
		"name": "Zenith Modern Minimalist Villa",
		"texture_path": "res://assets/isometric/rooms/room_modern_villa.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_alpine_chalet": {
		"id": "room_alpine_chalet",
		"property_id": "prop_alpine_chalet",
		"name": "Alpine Ski Chalet",
		"texture_path": "res://assets/isometric/rooms/room_alpine_chalet.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_ranch": {
		"id": "room_ranch",
		"property_id": "prop_ranch",
		"name": "Rolling Hills Country Ranch",
		"texture_path": "res://assets/isometric/rooms/room_ranch.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_desert_estate": {
		"id": "room_desert_estate",
		"property_id": "prop_desert_estate",
		"name": "Palm Springs Desert Oasis",
		"texture_path": "res://assets/isometric/rooms/room_desert_estate.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_beachfront": {
		"id": "room_beachfront",
		"property_id": "prop_beachfront",
		"name": "Pacific Crest Beach House",
		"texture_path": "res://assets/isometric/rooms/room_beachfront.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_harbor_duplex": {
		"id": "room_harbor_duplex",
		"property_id": "prop_harbor_duplex",
		"name": "Waterfront Marina Duplex",
		"texture_path": "res://assets/isometric/rooms/room_harbor_duplex.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_penthouse": {
		"id": "room_penthouse",
		"property_id": "prop_penthouse",
		"name": "Skyline Sky-Villa Penthouse",
		"texture_path": "res://assets/isometric/rooms/room_penthouse.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_cyber_mansion": {
		"id": "room_cyber_mansion",
		"property_id": "prop_cyber_mansion",
		"name": "Neo-Tech Smart Manor",
		"texture_path": "res://assets/isometric/rooms/room_cyber_mansion.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_chateau": {
		"id": "room_chateau",
		"property_id": "prop_chateau",
		"name": "Grand Chateau & Vineyard",
		"texture_path": "res://assets/isometric/rooms/room_chateau.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_cliffside_compound": {
		"id": "room_cliffside_compound",
		"property_id": "prop_cliffside_compound",
		"name": "Cliffside Architectural Compound",
		"texture_path": "res://assets/isometric/rooms/room_cliffside_compound.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_private_island": {
		"id": "room_private_island",
		"property_id": "prop_private_island",
		"name": "Emerald Atoll Private Island",
		"texture_path": "res://assets/isometric/rooms/room_private_island.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_megatower_apex": {
		"id": "room_megatower_apex",
		"property_id": "prop_megatower_apex",
		"name": "Apex Triplex Megatower Sanctuary",
		"texture_path": "res://assets/isometric/rooms/room_megatower_apex.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_orbital": {
		"id": "room_orbital",
		"property_id": "prop_orbital",
		"name": "High-Orbit Luxury Satellite Suite",
		"texture_path": "res://assets/isometric/rooms/room_orbital.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},

	# -------------------------------------------------------------------------
	# LEGACY ROOM DEFINITIONS (Maintained for backwards compatibility)
	# -------------------------------------------------------------------------
	"room_wood": {
		"id": "room_wood",
		"name": "Cream & Wood",
		"texture_path": "res://assets/isometric/rooms/room_capsule.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_brick": {
		"id": "room_brick",
		"name": "Brick & Terracotta",
		"texture_path": "res://assets/isometric/rooms/room_tenement.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_carpet": {
		"id": "room_carpet",
		"name": "Gray & Blue Carpet",
		"texture_path": "res://assets/isometric/rooms/room_suburban_split.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_modern": {
		"id": "room_modern",
		"name": "Tiled & White Marble",
		"texture_path": "res://assets/isometric/rooms/room_modern_villa.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_dark": {
		"id": "room_dark",
		"name": "Industrial Dark",
		"texture_path": "res://assets/isometric/rooms/room_studio.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	}
}

static var _texture_cache: Dictionary = {}

static func get_room_id_for_property(property_id: String) -> String:
	if property_id == "":
		return "room_capsule"
	var candidate := property_id
	if candidate.begins_with("prop_"):
		candidate = candidate.replace("prop_", "room_")
	if ROOM_DEFINITIONS.has(candidate):
		return candidate
	return "room_capsule"

static func get_room_data(room_or_prop_id: String) -> Dictionary:
	var key := room_or_prop_id
	if key.begins_with("prop_"):
		key = get_room_id_for_property(key)
	if ROOM_DEFINITIONS.has(key):
		return ROOM_DEFINITIONS[key]
	if ROOM_DEFINITIONS.has("room_capsule"):
		return ROOM_DEFINITIONS["room_capsule"]
	return ROOM_DEFINITIONS["room_wood"]

static func get_room_texture(room_or_prop_id: String) -> Texture2D:
	var key := room_or_prop_id
	if key.begins_with("prop_"):
		key = get_room_id_for_property(key)
	if _texture_cache.has(key):
		return _texture_cache[key]
	var data := get_room_data(key)
	var path: String = data.get("texture_path", "")
	if ResourceLoader.exists(path):
		var tex = load(path) as Texture2D
		if tex != null:
			_texture_cache[key] = tex
			return tex
	return null

static func get_all_room_ids() -> Array[String]:
	var list: Array[String] = []
	for k in ROOM_DEFINITIONS.keys():
		list.append(str(k))
	return list

static func clear_cache() -> void:
	_texture_cache.clear()
