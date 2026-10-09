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
	"room_wood": {
		"id": "room_wood",
		"name": "Cream & Wood",
		"texture_path": "res://assets/isometric/rooms/room_wood.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_brick": {
		"id": "room_brick",
		"name": "Brick & Terracotta",
		"texture_path": "res://assets/isometric/rooms/room_brick.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_carpet": {
		"id": "room_carpet",
		"name": "Gray & Blue Carpet",
		"texture_path": "res://assets/isometric/rooms/room_carpet.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_modern": {
		"id": "room_modern",
		"name": "Tiled & White Marble",
		"texture_path": "res://assets/isometric/rooms/room_modern.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	},
	"room_dark": {
		"id": "room_dark",
		"name": "Industrial Dark",
		"texture_path": "res://assets/isometric/rooms/room_dark.png",
		"walkable_polygon": DEFAULT_WALKABLE_POLYGON
	}
}

static var _texture_cache: Dictionary = {}

static func get_room_data(room_id: String) -> Dictionary:
	if ROOM_DEFINITIONS.has(room_id):
		return ROOM_DEFINITIONS[room_id]
	return ROOM_DEFINITIONS["room_wood"]

static func get_room_texture(room_id: String) -> Texture2D:
	if _texture_cache.has(room_id):
		return _texture_cache[room_id]
	var data := get_room_data(room_id)
	var path: String = data.get("texture_path", "")
	if ResourceLoader.exists(path):
		var tex = load(path) as Texture2D
		if tex != null:
			_texture_cache[room_id] = tex
			return tex
	return null

static func get_all_room_ids() -> Array[String]:
	return ["room_wood", "room_brick", "room_carpet", "room_modern", "room_dark"]

static func clear_cache() -> void:
	_texture_cache.clear()
