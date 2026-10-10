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

# -----------------------------------------------------------------------------
# FURNITURE COLLISION & INTERACTION CATALOG
# -----------------------------------------------------------------------------

const ARCHETYPE_MAP: Dictionary = {
	"room_capsule": "capsule",
	"room_tenement": "tenement",
	"room_brick": "tenement",
	"room_studio": "studio",
	"room_dark": "studio",
	"room_condo": "condo",
	"room_modern_villa": "condo",
	"room_modern": "condo",
	"room_harbor_duplex": "condo",
	"room_penthouse": "condo",
	"room_cyber_mansion": "condo",
	"room_megatower_apex": "condo",
	"room_orbital": "condo",
	"room_cottage": "cottage",
	"room_suburban_split": "suburban_split",
	"room_carpet": "suburban_split",
	"room_desert_estate": "suburban_split",
	"room_cliffside_compound": "suburban_split",
	"room_townhouse": "townhouse",
	"room_historic_brownstone": "townhouse",
	"room_chateau": "townhouse",
	"room_eco_timber": "eco_timber",
	"room_beachfront": "eco_timber",
	"room_private_island": "eco_timber",
	"room_house": "house",
	"room_cabin": "cabin",
	"room_alpine_chalet": "cabin",
	"room_ranch": "cabin",
	"room_wood": "cabin"
}

const ARCHETYPE_OBSTACLES: Dictionary = {
	"capsule": [
		Rect2(-420, 20, 240, 240),   # Bed
		Rect2(-130, -120, 220, 85),  # Study desk
		Rect2(210, -30, 190, 140),   # Bookcase
		Rect2(320, 90, 180, 170)     # Armchair
	],
	"tenement": [
		Rect2(90, 50, 340, 200),     # Leather sofa
		Rect2(-320, 10, 180, 160),   # Turntable & vinyl table
		Rect2(-460, 110, 160, 150)   # Cast-iron radiator
	],
	"studio": [
		Rect2(-430, 30, 260, 240),   # Loft bed
		Rect2(130, 30, 280, 190)     # Work desk
	],
	"condo": [
		Rect2(-240, -40, 380, 230),  # Platform king bed
		Rect2(-40, 260, 280, 140),   # Modern sofa
		Rect2(-460, 60, 170, 170)    # Media console & TV
	],
	"cottage": [
		Rect2(-160, 60, 210, 190),   # Floral armchair
		Rect2(160, 20, 290, 200),    # Stone fireplace
		Rect2(-360, 100, 140, 140)   # Tea table
	],
	"suburban_split": [
		Rect2(80, 80, 330, 250),     # L-shaped sectional couch
		Rect2(-440, -10, 190, 150)   # TV console
	],
	"townhouse": [
		Rect2(20, 60, 180, 180),     # Wingback chair
		Rect2(240, 0, 210, 250)      # Mahogany bookcase
	],
	"eco_timber": [
		Rect2(-380, 40, 230, 180),   # Timber desk
		Rect2(10, 60, 170, 170)      # Lounge chair
	],
	"house": [
		Rect2(-140, -20, 350, 210),  # Master bed
		Rect2(260, 40, 230, 190),    # Vanity dresser
		Rect2(-420, 80, 170, 170)    # Reading armchair
	],
	"cabin": [
		Rect2(150, 30, 280, 210),    # Stone fireplace
		Rect2(-140, 60, 190, 180)    # Leather armchair
	]
}

const ARCHETYPE_INTERACTIONS: Dictionary = {
	"capsule": [
		{"id": "armchair", "pos": Vector2(380, 170), "facing": -1, "action": "sit", "label": "Armchair", "pose_y_offset": 8.0, "duration": 10.0},
		{"id": "desk", "pos": Vector2(-20, 30), "facing": -1, "action": "sit", "label": "Study Desk", "pose_y_offset": 6.0, "duration": 9.0},
		{"id": "bed", "pos": Vector2(-290, 130), "facing": 1, "action": "rest", "label": "Bed", "pose_y_offset": 10.0, "duration": 12.0},
		{"id": "window", "pos": Vector2(240, 60), "facing": 1, "action": "look", "label": "Window", "pose_y_offset": 0.0, "duration": 7.0},
		{"id": "rug", "pos": Vector2(60, 250), "facing": 0, "action": "relax", "label": "Rug", "pose_y_offset": 4.0, "duration": 8.0}
	],
	"tenement": [
		{"id": "sofa_left", "pos": Vector2(180, 140), "facing": -1, "action": "sit", "label": "Leather Sofa", "pose_y_offset": 8.0, "duration": 11.0},
		{"id": "sofa_right", "pos": Vector2(300, 190), "facing": -1, "action": "sit", "label": "Leather Sofa", "pose_y_offset": 8.0, "duration": 11.0},
		{"id": "records", "pos": Vector2(-210, 110), "facing": -1, "action": "listen", "label": "Record Player", "pose_y_offset": 0.0, "duration": 8.0},
		{"id": "radiator", "pos": Vector2(-320, 190), "facing": -1, "action": "warm", "label": "Radiator", "pose_y_offset": 0.0, "duration": 7.0},
		{"id": "rug", "pos": Vector2(-30, 280), "facing": 1, "action": "relax", "label": "Persian Rug", "pose_y_offset": 4.0, "duration": 8.0}
	],
	"studio": [
		{"id": "desk", "pos": Vector2(210, 120), "facing": -1, "action": "sit", "label": "Workstation", "pose_y_offset": 6.0, "duration": 9.0},
		{"id": "bed", "pos": Vector2(-270, 130), "facing": 1, "action": "rest", "label": "Loft Bed", "pose_y_offset": 10.0, "duration": 12.0},
		{"id": "window", "pos": Vector2(-100, 10), "facing": -1, "action": "look", "label": "Loft Window", "pose_y_offset": 0.0, "duration": 7.0},
		{"id": "mat", "pos": Vector2(10, 260), "facing": 0, "action": "relax", "label": "Floor Mat", "pose_y_offset": 4.0, "duration": 8.0}
	],
	"condo": [
		{"id": "sofa", "pos": Vector2(90, 310), "facing": -1, "action": "sit", "label": "Modern Sofa", "pose_y_offset": 8.0, "duration": 10.0},
		{"id": "bed", "pos": Vector2(-40, 50), "facing": 1, "action": "rest", "label": "Platform Bed", "pose_y_offset": 10.0, "duration": 12.0},
		{"id": "balcony", "pos": Vector2(370, 180), "facing": 1, "action": "look", "label": "City Skyline", "pose_y_offset": 0.0, "duration": 8.0},
		{"id": "tv", "pos": Vector2(-260, 170), "facing": -1, "action": "look", "label": "TV Screen", "pose_y_offset": 0.0, "duration": 8.0}
	],
	"cottage": [
		{"id": "armchair", "pos": Vector2(-60, 140), "facing": 1, "action": "sit", "label": "Floral Armchair", "pose_y_offset": 8.0, "duration": 12.0},
		{"id": "hearth", "pos": Vector2(160, 150), "facing": 1, "action": "warm", "label": "Fireplace", "pose_y_offset": 0.0, "duration": 8.0},
		{"id": "tea_table", "pos": Vector2(-230, 170), "facing": -1, "action": "sit", "label": "Tea Table", "pose_y_offset": 6.0, "duration": 8.0},
		{"id": "rug", "pos": Vector2(0, 300), "facing": 0, "action": "relax", "label": "Braided Rug", "pose_y_offset": 4.0, "duration": 8.0}
	],
	"suburban_split": [
		{"id": "sectional_left", "pos": Vector2(160, 190), "facing": -1, "action": "sit", "label": "Sectional Sofa", "pose_y_offset": 8.0, "duration": 10.0},
		{"id": "sectional_right", "pos": Vector2(270, 240), "facing": -1, "action": "sit", "label": "Sectional Sofa", "pose_y_offset": 8.0, "duration": 10.0},
		{"id": "tv", "pos": Vector2(-220, 120), "facing": -1, "action": "look", "label": "OLED TV", "pose_y_offset": 0.0, "duration": 8.0},
		{"id": "rug", "pos": Vector2(-20, 240), "facing": 0, "action": "relax", "label": "Modern Rug", "pose_y_offset": 4.0, "duration": 8.0}
	],
	"townhouse": [
		{"id": "wingback", "pos": Vector2(110, 140), "facing": -1, "action": "sit", "label": "Wingback Chair", "pose_y_offset": 8.0, "duration": 11.0},
		{"id": "books", "pos": Vector2(250, 180), "facing": 1, "action": "read", "label": "Bookcase", "pose_y_offset": 0.0, "duration": 9.0},
		{"id": "bay_window", "pos": Vector2(-210, 150), "facing": -1, "action": "look", "label": "Bay Window", "pose_y_offset": 0.0, "duration": 7.0},
		{"id": "parquet", "pos": Vector2(-30, 290), "facing": 0, "action": "relax", "label": "Parquet Floor", "pose_y_offset": 4.0, "duration": 8.0}
	],
	"eco_timber": [
		{"id": "desk", "pos": Vector2(-210, 130), "facing": -1, "action": "sit", "label": "Timber Desk", "pose_y_offset": 6.0, "duration": 9.0},
		{"id": "lounge", "pos": Vector2(90, 140), "facing": -1, "action": "sit", "label": "Lounge Chair", "pose_y_offset": 8.0, "duration": 10.0},
		{"id": "balcony", "pos": Vector2(320, 180), "facing": 1, "action": "look", "label": "Ocean Vista", "pose_y_offset": 0.0, "duration": 8.0},
		{"id": "deck", "pos": Vector2(20, 290), "facing": 0, "action": "relax", "label": "Bamboo Deck", "pose_y_offset": 4.0, "duration": 8.0}
	],
	"house": [
		{"id": "bed", "pos": Vector2(30, 70), "facing": -1, "action": "rest", "label": "King Bed", "pose_y_offset": 10.0, "duration": 12.0},
		{"id": "armchair", "pos": Vector2(-300, 160), "facing": 1, "action": "sit", "label": "Armchair", "pose_y_offset": 8.0, "duration": 9.0},
		{"id": "vanity", "pos": Vector2(320, 160), "facing": 1, "action": "groom", "label": "Vanity", "pose_y_offset": 0.0, "duration": 7.0},
		{"id": "carpet", "pos": Vector2(-30, 300), "facing": 0, "action": "relax", "label": "Plush Carpet", "pose_y_offset": 4.0, "duration": 8.0}
	],
	"cabin": [
		{"id": "armchair", "pos": Vector2(-40, 130), "facing": 1, "action": "sit", "label": "Hearth Chair", "pose_y_offset": 8.0, "duration": 11.0},
		{"id": "hearth", "pos": Vector2(170, 150), "facing": 1, "action": "warm", "label": "Stone Fireplace", "pose_y_offset": 0.0, "duration": 8.0},
		{"id": "window", "pos": Vector2(-260, 170), "facing": -1, "action": "look", "label": "Alpine Window", "pose_y_offset": 0.0, "duration": 7.0},
		{"id": "rug", "pos": Vector2(20, 280), "facing": 0, "action": "relax", "label": "Woven Rug", "pose_y_offset": 4.0, "duration": 8.0}
	]
}

static func get_room_archetype(room_id: String) -> String:
	var key := room_id
	if key.begins_with("prop_"):
		key = get_room_id_for_property(key)
	if ARCHETYPE_MAP.has(key):
		return ARCHETYPE_MAP[key]
	return "capsule"

static func get_obstacles_for_room(room_id: String) -> Array[Rect2]:
	var arch := get_room_archetype(room_id)
	if ARCHETYPE_OBSTACLES.has(arch):
		var res: Array[Rect2] = []
		for item in ARCHETYPE_OBSTACLES[arch]:
			res.append(item)
		return res
	return []

static func get_interaction_spots_for_room(room_id: String) -> Array[Dictionary]:
	var arch := get_room_archetype(room_id)
	if ARCHETYPE_INTERACTIONS.has(arch):
		var res: Array[Dictionary] = []
		for item in ARCHETYPE_INTERACTIONS[arch]:
			res.append(item.duplicate())
		return res
	return []

static func is_point_obstructed(room_id: String, pt: Vector2, margin: float = 12.0) -> bool:
	var obstacles := get_obstacles_for_room(room_id)
	for rect in obstacles:
		if rect.grow(margin).has_point(pt):
			return true
	return false

