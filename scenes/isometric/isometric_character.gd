extends Node2D

const PortraitCatalog = preload("res://scripts/core/portrait_catalog.gd")

## ANIMATION LIMITATION NOTE:
## The existing character assets consist of 128x128 pixel-art character portraits/avatars
## for each life stage (infant, child, teen, adult, elder). There are no multi-frame walk
## cycles or directional sprite sheets in the project. Movement is therefore realized
## with frame-rate independent programmatic squash-and-stretch, vertical step bouncing,
## directional horizontal flipping, and an isometric drop shadow.

enum State {
	IDLE,
	WALKING
}

@export var walk_speed: float = 160.0
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

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
		
	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.WALKING:
			_process_walking(delta)

func _process_idle(delta: float) -> void:
	idle_cycle += delta * 2.5
	# Subtle breathing animation
	var breath: float = sin(idle_cycle) * 0.02
	if sprite_anchor:
		sprite_anchor.position = Vector2.ZERO
	if sprite:
		sprite.scale = Vector2(character_scale, character_scale * (1.0 + breath))
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
	
	if dist <= 4.0:
		position = target_position
		_stop_walking()
		return
		
	var dir := diff.normalized()
	var step := walk_speed * delta
	
	if step >= dist:
		position = target_position
		_stop_walking()
		return
		
	position += dir * step
	
	# Face movement direction
	if sprite:
		if dir.x > 0.05:
			sprite.flip_h = false
		elif dir.x < -0.05:
			sprite.flip_h = true
		
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

func _pick_next_destination() -> void:
	if _room_ref and _room_ref.has_method("get_random_walkable_point"):
		var next_pt: Vector2 = _room_ref.get_random_walkable_point()
		if next_pt != Vector2.ZERO and next_pt.distance_to(position) > 20.0:
			target_position = next_pt
			current_state = State.WALKING
			walk_cycle = 0.0
			return
			
	# If no new destination found, reset idle timer
	idle_timer = randf_range(min_idle_time, max_idle_time)

func _stop_walking() -> void:
	current_state = State.IDLE
	idle_timer = randf_range(min_idle_time, max_idle_time)
	walk_cycle = 0.0
	if sprite_anchor:
		sprite_anchor.position = Vector2.ZERO
	if sprite:
		sprite.scale = Vector2(character_scale, character_scale)
	if shadow:
		shadow.scale = Vector2.ONE

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
		
	# Ensure crisp pixel filtering
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	if is_npc and custom_texture != null:
		sprite.texture = custom_texture
		sprite.offset = Vector2(0, -45)
		sprite.scale = Vector2(character_scale, character_scale)
		return
		
	# Fetch portrait from game's PortraitCatalog
	var tex: Texture2D = null
	if Engine.has_singleton("PlayerData") or typeof(PlayerData) != TYPE_NIL:
		var age: int = PlayerData.age if "age" in PlayerData else 0
		var gender: String = PlayerData.gender if "gender" in PlayerData else "MALE"
		var track: int = PlayerData.portrait_track if "portrait_track" in PlayerData else 0
		var eth: String = PlayerData.ethnicity if "ethnicity" in PlayerData else "white"
		tex = PortraitCatalog.get_portrait(age, gender, track, eth)
	
	if tex == null:
		# Fallback to white baby or default if before player init
		tex = load("res://assets/portraits/white/baby_0.png") as Texture2D
		
	if tex != null:
		sprite.texture = tex
		# Offset so character's feet rest at (0, 0)
		sprite.offset = Vector2(0, -45)
		sprite.scale = Vector2(character_scale, character_scale)
