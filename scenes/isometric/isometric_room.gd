extends Node2D

const RoomManager = preload("res://scripts/isometric/room_manager.gd")
const IsometricCharacterScript = preload("res://scenes/isometric/isometric_character.gd")
const PortraitCatalog = preload("res://scripts/core/portrait_catalog.gd")

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
	_ensure_parents()
	_ensure_children()

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
		
	# Zoom out slightly (0.86x) to show full room walls and floor with ample breathing room,
	# creating the optical illusion that the room is large and expansive.
	var base_zoom: float = minf(vp_size.x / 2048.0, vp_size.y / 2048.0)
	var zoom_factor: float = clampf(base_zoom * 0.86, 0.05, 4.0)
	camera.zoom = Vector2(zoom_factor, zoom_factor)
	camera.position = Vector2(0, 80)

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
		if (child.get_script() == IsometricCharacterScript or child.has_method("set_room")) and child.name == "IsometricCharacter":
			_character_instance = child
			_character_instance.set_room(self)
			if _character_instance.has_method("update_appearance"):
				_character_instance.call("update_appearance")
			return
			
	# Instantiate player character if not present in scene
	var char_scene := load("res://scenes/isometric/isometric_character.tscn") as PackedScene
	if char_scene:
		var ch := char_scene.instantiate() as Node2D
		ch.name = "IsometricCharacter"
		characters.add_child(ch)
		_character_instance = ch
		_character_instance.call("set_room", self)
		_character_instance.position = Vector2(0, 200) # Floor center
		if _character_instance.has_method("update_appearance"):
			_character_instance.call("update_appearance")

func _is_valid_living_parent(p_name: String, p_alive: bool) -> bool:
	if not p_alive:
		return false
	var n := p_name.strip_edges().to_lower()
	if n == "" or n == "unknown" or n == "deceased" or n == "n/a" or n == "none":
		return false
	return true

func _ensure_parents() -> void:
	if not characters:
		return
		
	var mother_alive: bool = true
	var father_alive: bool = true
	var m_name: String = ""
	var f_name: String = ""
	var age: int = 0
	var eth: String = "white"
	var track: int = 0
	var m_base_age: int = 35
	var f_base_age: int = 37
	
	if Engine.has_singleton("PlayerData") or typeof(PlayerData) != TYPE_NIL:
		mother_alive = PlayerData.mother_alive if "mother_alive" in PlayerData else true
		father_alive = PlayerData.father_alive if "father_alive" in PlayerData else true
		m_name = PlayerData.mother_name if "mother_name" in PlayerData else ""
		f_name = PlayerData.father_name if "father_name" in PlayerData else ""
		age = PlayerData.age if "age" in PlayerData else 0
		eth = PlayerData.ethnicity if "ethnicity" in PlayerData else "white"
		track = PlayerData.portrait_track if "portrait_track" in PlayerData else 0
		m_base_age = PlayerData.mother_base_age if "mother_base_age" in PlayerData else 35
		f_base_age = PlayerData.father_base_age if "father_base_age" in PlayerData else 37
		
	var char_scene := load("res://scenes/isometric/isometric_character.tscn") as PackedScene
	if not char_scene:
		return
		
	var is_mother_valid := _is_valid_living_parent(m_name, mother_alive)
	var is_father_valid := _is_valid_living_parent(f_name, father_alive)

	# Parents are ALWAYS adults or elders (minimum age 25). They NEVER use baby or child portraits.
	var mom_age: int = max(m_base_age + age, 25)
	var dad_age: int = max(f_base_age + age, 25)
		
	# Mother bobbly head
	var mother_node = characters.get_node_or_null("MotherCharacter")
	if is_mother_valid:
		var m_tex: Texture2D = PortraitCatalog.get_portrait(mom_age, "FEMALE", (track + 1) % 4, eth)
		if mother_node == null:
			mother_node = char_scene.instantiate()
			mother_node.name = "MotherCharacter"
			characters.add_child(mother_node)
			mother_node.call("set_room", self)
			mother_node.position = Vector2(-160, 220)
			mother_node.idle_timer = randf_range(1.5, 3.5)
		if mother_node.has_method("setup_npc"):
			mother_node.call("setup_npc", m_tex, "Mother")
	elif mother_node != null:
		mother_node.queue_free()
		
	# Father bobbly head
	var father_node = characters.get_node_or_null("FatherCharacter")
	if is_father_valid:
		var f_tex: Texture2D = PortraitCatalog.get_portrait(dad_age, "MALE", (track + 2) % 4, eth)
		if father_node == null:
			father_node = char_scene.instantiate()
			father_node.name = "FatherCharacter"
			characters.add_child(father_node)
			father_node.call("set_room", self)
			father_node.position = Vector2(160, 240)
			father_node.idle_timer = randf_range(1.0, 3.0)
		if father_node.has_method("setup_npc"):
			father_node.call("setup_npc", f_tex, "Father")
	elif father_node != null:
		father_node.queue_free()

func _ensure_children() -> void:
	if not characters:
		return
		
	var living_kids: Array = []
	if Engine.has_singleton("PlayerData") or typeof(PlayerData) != TYPE_NIL:
		if PlayerData.has_method("get_living_children"):
			living_kids = PlayerData.get_living_children()
		elif "children" in PlayerData and PlayerData.children is Array:
			for c in PlayerData.children:
				if c is Dictionary and bool(c.get("is_alive", true)):
					living_kids.append(c)
					
	var char_scene := load("res://scenes/isometric/isometric_character.tscn") as PackedScene
	if not char_scene:
		return
		
	var active_kid_names: Array[String] = []
	var player_eth: String = PlayerData.ethnicity if "ethnicity" in PlayerData else "white"
	
	for i in range(living_kids.size()):
		var kid_data: Dictionary = living_kids[i]
		var kid_name: String = str(kid_data.get("name", "Child %d" % (i + 1)))
		var node_name := "ChildCharacter_%d" % i
		active_kid_names.append(node_name)
		
		var kid_age: int = int(kid_data.get("age", 0))
		var kid_gender: String = str(kid_data.get("gender", "MALE"))
		var kid_track: int = int(kid_data.get("portrait_track", i))
		var kid_eth: String = str(kid_data.get("ethnicity", player_eth))
		
		var kid_tex: Texture2D = PortraitCatalog.get_portrait(kid_age, kid_gender, kid_track, kid_eth)
		
		var kid_node = characters.get_node_or_null(node_name)
		if kid_node == null:
			kid_node = char_scene.instantiate()
			kid_node.name = node_name
			characters.add_child(kid_node)
			kid_node.call("set_room", self)
			kid_node.position = get_random_walkable_point()
			kid_node.idle_timer = randf_range(0.8, 2.5)
			
		if kid_node.has_method("setup_npc"):
			kid_node.call("setup_npc", kid_tex, "Child: " + kid_name)
			
	# Remove any child nodes whose children no longer exist/are not alive
	for child in characters.get_children():
		if child.name.begins_with("ChildCharacter_"):
			if not active_kid_names.has(child.name):
				child.queue_free()

func update_character() -> void:
	if _character_instance and _character_instance.has_method("update_appearance"):
		_character_instance.call("update_appearance")
	_ensure_parents()
	_ensure_children()

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
