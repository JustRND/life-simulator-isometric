extends Node2D

const PortraitCatalog = preload("res://scripts/core/portrait_catalog.gd")

## ANIMATION SYSTEM:
## Characters are 128x128 pixel-art avatars. In the isometric room, they feature:
## 1. Frame-rate independent programmatic squash-and-stretch and step bounce while walking.
## 2. Furniture Collision: Obstacle avoidance prevents walking through beds, sofas, fireplaces, desks.
## 3. Furniture Interaction: Characters seek out seats, beds, fireplaces, windows, bookshelves, and rugs.
## 4. Subtle Living Animations: Seated posture drop, cozy breathing, micro-sway, reading tilt, and warming bob.

enum State {
	IDLE,
	WALKING,
	INTERACTING
}

@export var walk_speed: float = 150.0
@export var min_idle_time: float = 1.5
@export var max_idle_time: float = 4.0
@export var character_scale: float = 1.1
@export var roam_enabled: bool = true

@export var is_npc: bool = false
@export var npc_role: String = ""
var custom_texture: Texture2D = null

var current_state: State = State.IDLE
var target_position: Vector2 = Vector2.ZERO
var idle_timer: float = 0.0
var walk_cycle: float = 0.0
var idle_cycle: float = 0.0

# Furniture interaction state
var current_spot: Dictionary = {}
var interaction_timer: float = 0.0
var interaction_action: String = ""
var interaction_pose_offset: float = 0.0

var _room_ref: Node2D = null

@onready var sprite_anchor: Node2D = $SpriteAnchor
@onready var sprite: Sprite2D = $SpriteAnchor/Sprite2D
@onready var shadow: Polygon2D = $Shadow

func _ready() -> void:
	y_sort_enabled = true
	idle_timer = randf_range(min_idle_time, max_idle_time)
	update_appearance()

func set_room(room: Node2D) -> void:
	_room_ref = room

func _exit_tree() -> void:
	_release_current_spot()

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
		
	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.WALKING:
			_process_walking(delta)
		State.INTERACTING:
			_process_interacting(delta)

func _process_idle(delta: float) -> void:
	idle_cycle += delta * 2.2
	var breath: float = sin(idle_cycle) * 0.02
	if sprite_anchor:
		sprite_anchor.position = Vector2.ZERO
	if sprite:
		sprite.scale = Vector2(character_scale, character_scale * (1.0 + breath))
		sprite.rotation = 0.0
		sprite.offset = Vector2(0, -45)
	if shadow:
		shadow.scale = Vector2(1.0 + breath * 0.5, 1.0 + breath * 0.5)
	
	if not roam_enabled:
		return
		
	idle_timer -= delta
	if idle_timer <= 0.0:
		_pick_next_destination()

func _process_walking(delta: float) -> void:
	var diff := target_position - position
	var dist := diff.length()
	
	if dist <= 6.0:
		position = target_position
		if not current_spot.is_empty():
			_start_interacting()
		else:
			_stop_walking()
		return
		
	var dir := diff.normalized()
	
	# Social spacing / Collision avoidance between multiple characters
	if _room_ref and _room_ref.has_method("get_all_characters"):
		var all_chars: Array[Node2D] = _room_ref.call("get_all_characters")
		for other in all_chars:
			if other != self and is_instance_valid(other):
				var o_diff: Vector2 = other.position - position
				var o_dist: float = o_diff.length()
				if o_dist < 42.0 and o_dist > 1.0:
					# Steer slightly around the other character
					var dot_prod: float = dir.dot(o_diff.normalized())
					if dot_prod > 0.4:
						var perp := Vector2(-dir.y, dir.x)
						if perp.dot(o_diff) > 0.0:
							perp = -perp
						dir = (dir + perp * 0.7).normalized()
						break
	
	var step := walk_speed * delta
	if step >= dist:
		step = dist
		
	var next_pos := position + dir * step
	
	# Obstacle avoidance: do not step into furniture unless entering final destination spot
	if dist > 30.0 and _room_ref and _room_ref.has_method("is_point_walkable"):
		if not _room_ref.is_point_walkable(next_pos):
			# Try tangential slide
			var sides: Array[Vector2] = [Vector2(-dir.y, dir.x), Vector2(dir.y, -dir.x)]
			var routed: bool = false
			for side: Vector2 in sides:
				var test_pos: Vector2 = position + (dir * 0.4 + side * 0.9).normalized() * step
				if _room_ref.is_point_walkable(test_pos):
					next_pos = test_pos
					routed = true
					break
			if not routed:
				# Trapped by obstacle, stop and pick another path
				_stop_walking()
				return
				
	position = next_pos
	
	# Face movement direction
	if sprite:
		if dir.x > 0.05:
			sprite.flip_h = false
		elif dir.x < -0.05:
			sprite.flip_h = true
		sprite.offset = Vector2(0, -45)
		sprite.rotation = 0.0
		
	# Walk bounce and squash-and-stretch
	walk_cycle += delta * 12.0
	var bounce: float = absf(sin(walk_cycle)) * 5.0
	var squish: float = sin(walk_cycle * 2.0) * 0.04
	
	if sprite_anchor:
		sprite_anchor.position.y = -bounce
	if sprite:
		sprite.scale = Vector2(character_scale * (1.0 - squish), character_scale * (1.0 + squish))
	
	if shadow:
		var shadow_squeeze: float = 1.0 - (bounce / 5.0) * 0.15
		shadow.scale = Vector2(shadow_squeeze, shadow_squeeze)

func _start_interacting() -> void:
	current_state = State.INTERACTING
	interaction_action = str(current_spot.get("action", "sit"))
	interaction_pose_offset = float(current_spot.get("pose_y_offset", 0.0))
	interaction_timer = float(current_spot.get("duration", randf_range(8.0, 13.0)))
	
	if current_spot.has("facing"):
		var f: int = int(current_spot["facing"])
		if f < 0 and sprite:
			sprite.flip_h = true
		elif f > 0 and sprite:
			sprite.flip_h = false
			
	walk_cycle = 0.0
	if sprite_anchor:
		sprite_anchor.position = Vector2.ZERO

func _process_interacting(delta: float) -> void:
	idle_cycle += delta * 2.0
	
	# Pose offset: sit down slightly into the seat cushions
	var base_y_offset: float = -45.0
	if interaction_action in ["sit", "rest", "relax"]:
		base_y_offset = -45.0 + interaction_pose_offset
		if shadow:
			shadow.scale = Vector2(0.85, 0.85)
	else:
		if shadow:
			shadow.scale = Vector2.ONE
			
	if sprite:
		sprite.offset = Vector2(0, base_y_offset)
		
	# Subtle living animations tuned by furniture action
	var breath: float = sin(idle_cycle * 1.6) * 0.025
	var sway: float = cos(idle_cycle * 0.8) * 0.015
	var tilt: float = sin(idle_cycle * 0.5) * 0.02
	
	match interaction_action:
		"rest": # Relaxing / sleeping in bed
			breath = sin(idle_cycle * 1.0) * 0.018
			sway = 0.0
			tilt = 0.01
		"warm": # Fireplace / radiator warming
			breath = sin(idle_cycle * 2.2) * 0.03
			tilt = sin(idle_cycle * 1.1) * 0.025
		"read": # Browsing / reading books
			tilt = -0.04 + sin(idle_cycle * 0.6) * 0.015
			sway = sin(idle_cycle * 0.3) * 0.01
		"look": # Looking out window / watching tv
			tilt = 0.0
			sway = sin(idle_cycle * 0.4) * 0.012
		"listen": # Listening to record player
			sway = cos(idle_cycle * 1.4) * 0.02
			tilt = sin(idle_cycle * 1.4) * 0.03
			
	if sprite:
		sprite.scale = Vector2(character_scale * (1.0 + sway), character_scale * (1.0 + breath))
		sprite.rotation = tilt
		
	interaction_timer -= delta
	if interaction_timer <= 0.0:
		_stop_interacting()

func _stop_interacting() -> void:
	_release_current_spot()
	current_state = State.IDLE
	idle_timer = randf_range(min_idle_time, max_idle_time)
	if sprite:
		sprite.offset = Vector2(0, -45)
		sprite.rotation = 0.0
		sprite.scale = Vector2(character_scale, character_scale)
	if shadow:
		shadow.scale = Vector2.ONE

func _pick_next_destination() -> void:
	if not _room_ref:
		idle_timer = randf_range(min_idle_time, max_idle_time)
		return
		
	# 60% chance to interact with a furniture spot if available
	var pick_furniture: bool = (randf() < 0.60)
	if pick_furniture and _room_ref.has_method("get_available_interaction_spots"):
		var available: Array[Dictionary] = _room_ref.call("get_available_interaction_spots")
		if not available.is_empty():
			available.shuffle()
			for cand in available:
				var c_pos: Vector2 = cand.get("pos", Vector2.ZERO)
				if c_pos.distance_to(position) > 25.0:
					var s_id: String = str(cand.get("id", ""))
					if _room_ref.call("reserve_interaction_spot", s_id, self):
						_release_current_spot()
						current_spot = cand
						target_position = c_pos
						current_state = State.WALKING
						walk_cycle = 0.0
						return
						
	# 40% chance or fallback: Wander to an unobstructed floor point
	_release_current_spot()
	if _room_ref.has_method("get_random_walkable_point"):
		var next_pt: Vector2 = _room_ref.call("get_random_walkable_point")
		if next_pt != Vector2.ZERO and next_pt.distance_to(position) > 25.0:
			target_position = next_pt
			current_state = State.WALKING
			walk_cycle = 0.0
			return
			
	idle_timer = randf_range(min_idle_time, max_idle_time)

func _stop_walking() -> void:
	current_state = State.IDLE
	idle_timer = randf_range(min_idle_time, max_idle_time)
	walk_cycle = 0.0
	if sprite_anchor:
		sprite_anchor.position = Vector2.ZERO
	if sprite:
		sprite.scale = Vector2(character_scale, character_scale)
		sprite.offset = Vector2(0, -45)
		sprite.rotation = 0.0
	if shadow:
		shadow.scale = Vector2.ONE

func _release_current_spot() -> void:
	if not current_spot.is_empty() and _room_ref and _room_ref.has_method("release_interaction_spot"):
		_room_ref.call("release_interaction_spot", current_spot.get("id", ""), self)
	current_spot.clear()

## Called when player purchases a new property or switches rooms
func on_room_changed() -> void:
	_release_current_spot()
	current_state = State.IDLE
	idle_timer = randf_range(0.5, 2.0)
	if sprite:
		sprite.offset = Vector2(0, -45)
		sprite.rotation = 0.0
	if _room_ref and _room_ref.has_method("is_point_walkable"):
		if not _room_ref.call("is_point_walkable", position):
			position = _room_ref.call("get_random_walkable_point")

## Configures this character as an NPC (e.g. mother, father)
func setup_npc(p_tex: Texture2D, p_role: String = "") -> void:
	is_npc = true
	npc_role = p_role
	custom_texture = p_tex
	update_appearance()

## Updates the sprite texture from PlayerData and PortraitCatalog
func update_appearance() -> void:
	if not sprite:
		return
		
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	if is_npc and custom_texture != null:
		sprite.texture = custom_texture
		sprite.offset = Vector2(0, -45)
		sprite.scale = Vector2(character_scale, character_scale)
		return
		
	var tex: Texture2D = null
	if Engine.has_singleton("PlayerData") or typeof(PlayerData) != TYPE_NIL:
		var age: int = PlayerData.age if "age" in PlayerData else 0
		var gender: String = PlayerData.gender if "gender" in PlayerData else "MALE"
		var track: int = PlayerData.portrait_track if "portrait_track" in PlayerData else 0
		var eth: String = PlayerData.ethnicity if "ethnicity" in PlayerData else "white"
		tex = PortraitCatalog.get_portrait(age, gender, track, eth)
	
	if tex == null:
		tex = load("res://assets/portraits/white/baby_0.png") as Texture2D
		
	if tex != null:
		sprite.texture = tex
		sprite.offset = Vector2(0, -45)
		sprite.scale = Vector2(character_scale, character_scale)
