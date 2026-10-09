extends Node2D

const RoomManager = preload("res://scripts/isometric/room_manager.gd")
const IsometricCharacterScript = preload("res://scenes/isometric/isometric_character.gd")

@export_enum("room_wood", "room_brick", "room_carpet", "room_modern", "room_dark") var initial_room: String = "room_wood"
@export var show_debug_walkable_area: bool = false

var current_room_id: String = "room_wood"

@onready var room_background: Sprite2D = $RoomBackground
@onready var walkable_area: Polygon2D = $WalkableArea
@onready var world_objects: Node2D = $WorldObjects
@onready var characters: Node2D = $Characters
@onready var camera: Camera2D = $Camera2D

var _character_instance: Node2D = null
var _cached_triangles: Array = []
var _triangle_areas: Array[float] = []
var _total_polygon_area: float = 0.0

func _ready() -> void:
	y_sort_enabled = true
	if characters:
		characters.y_sort_enabled = true
	if world_objects:
		world_objects.y_sort_enabled = true
		
	# Setup WalkableArea debug visibility
	if walkable_area:
		walkable_area.visible = show_debug_walkable_area
		
	# Connect to viewport resize to dynamically adjust zoom
	var vp := get_viewport()
	if vp:
		vp.size_changed.connect(_on_viewport_size_changed)
		
	set_room(initial_room)
	_update_camera_zoom()
	_ensure_character()

func _on_viewport_size_changed() -> void:
	_update_camera_zoom()

func _update_camera_zoom() -> void:
	if not camera:
		return
	var vp := get_viewport()
	if not vp:
		return
	var vp_size := Vector2(vp.get_visible_rect().size)
	if vp_size.x <= 0 or vp_size.y <= 0:
		return
		
	# The room artwork is 2048 x 2048.
	# Scale proportionally to fit both width and height within the SubViewport,
	# maintaining 1:1 pixel aspect ratio.
	var zoom_factor: float = minf(vp_size.x / 2048.0, vp_size.y / 2048.0)
	zoom_factor = clampf(zoom_factor, 0.05, 4.0)
	camera.zoom = Vector2(zoom_factor, zoom_factor)
	camera.position = Vector2.ZERO

func set_room(room_id: String) -> void:
	current_room_id = room_id
	var tex: Texture2D = RoomManager.get_room_texture(room_id)
	if tex and room_background:
		room_background.texture = tex
		room_background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
	var data: Dictionary = RoomManager.get_room_data(room_id)
	if data.has("walkable_polygon") and walkable_area:
		walkable_area.polygon = data["walkable_polygon"]
		
	_rebuild_triangulation()

func _ensure_character() -> void:
	if not characters:
		return
		
	for child in characters.get_children():
		if child.get_script() == IsometricCharacterScript or child.has_method("set_room"):
			_character_instance = child
			_character_instance.set_room(self)
			return
			
	# Instantiate character if not present in scene
	var char_scene := load("res://scenes/isometric/isometric_character.tscn") as PackedScene
	if char_scene:
		var ch := char_scene.instantiate() as Node2D
		characters.add_child(ch)
		_character_instance = ch
		_character_instance.call("set_room", self)
		_character_instance.position = Vector2(0, 200) # Floor center
		if _character_instance.has_method("update_appearance"):
			_character_instance.call("update_appearance")

func update_character() -> void:
	if _character_instance and _character_instance.has_method("update_appearance"):
		_character_instance.call("update_appearance")

func is_point_walkable(pt: Vector2) -> bool:
	if not walkable_area or walkable_area.polygon.size() < 3:
		return false
	return Geometry2D.is_point_in_polygon(pt, walkable_area.polygon)

func _rebuild_triangulation() -> void:
	_cached_triangles.clear()
	_triangle_areas.clear()
	_total_polygon_area = 0.0
	
	if not walkable_area or walkable_area.polygon.size() < 3:
		return
		
	var poly := walkable_area.polygon
	var indices := Geometry2D.triangulate_polygon(poly)
	if indices.is_empty():
		return
		
	for i in range(0, indices.size(), 3):
		var a: Vector2 = poly[indices[i]]
		var b: Vector2 = poly[indices[i + 1]]
		var c: Vector2 = poly[indices[i + 2]]
		var area: float = absf((b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y)) * 0.5
		if area > 0.001:
			_cached_triangles.append([a, b, c])
			_triangle_areas.append(area)
			_total_polygon_area += area

func get_random_walkable_point() -> Vector2:
	if _cached_triangles.is_empty():
		_rebuild_triangulation()
	if _cached_triangles.is_empty():
		return Vector2(0, 200)
		
	var r: float = randf() * _total_polygon_area
	var accumulated: float = 0.0
	var chosen_tri = _cached_triangles[0]
	for idx in range(_cached_triangles.size()):
		accumulated += _triangle_areas[idx]
		if r <= accumulated:
			chosen_tri = _cached_triangles[idx]
			break
			
	var a: Vector2 = chosen_tri[0]
	var b: Vector2 = chosen_tri[1]
	var c: Vector2 = chosen_tri[2]
	
	var r1 := randf()
	var r2 := randf()
	if r1 + r2 > 1.0:
		r1 = 1.0 - r1
		r2 = 1.0 - r2
		
	return a + r1 * (b - a) + r2 * (c - a)
