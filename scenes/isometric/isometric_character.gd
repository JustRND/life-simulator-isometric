class_name IsometricCharacter
extends Node2D

## ANIMATION ARCHITECTURE NOTE:
## The character uses an AnimatedSprite2D with a SpriteFrames resource containing
## 4-directional walking and idle animations:
## - walk_se & idle_se: Source from sprite sheet Row 0 (front-right facing).
## - walk_ne & idle_ne: Source from sprite sheet Row 2 (back-right facing).
## - walk_sw & idle_sw: Sourced by horizontal mirroring of the South-East frames.
## - walk_nw & idle_nw: Sourced by horizontal mirroring of the North-East frames.
## The source sprite sheet natively contained SE and NE directions; SW and NW are
## mirrored to complete all 4 isometric diagonal directions.

enum State {
	IDLE,
	WALKING
}

@export var walk_speed: float = 140.0
@export var min_idle_time: float = 1.5
@export var max_idle_time: float = 4.0
@export var character_scale: float = 1.0
@export var roam_enabled: bool = true

var current_state: State = State.IDLE
var current_facing: String = "se"
var target_position: Vector2 = Vector2.ZERO
var idle_timer: float = 0.0

var _room_ref: Node2D = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadow: Polygon2D = $Shadow
@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	y_sort_enabled = true
	scale = Vector2(character_scale, character_scale)
	idle_timer = randf_range(min_idle_time, max_idle_time)
	
	if animated_sprite:
		animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		animated_sprite.play("idle_" + current_facing)

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
	
	# Determine and update facing direction
	var new_facing := get_direction_facing(dir)
	if new_facing != current_facing or (animated_sprite and not animated_sprite.is_playing()):
		current_facing = new_facing
		if animated_sprite:
			animated_sprite.play("walk_" + current_facing)

func _pick_next_destination() -> void:
	if _room_ref and _room_ref.has_method("get_random_walkable_point"):
		var next_pt: Vector2 = _room_ref.get_random_walkable_point()
		if next_pt != Vector2.ZERO and next_pt.distance_to(position) > 40.0:
			target_position = next_pt
			current_state = State.WALKING
			var dir := (target_position - position).normalized()
			current_facing = get_direction_facing(dir)
			if animated_sprite:
				animated_sprite.play("walk_" + current_facing)
			return
			
	idle_timer = randf_range(min_idle_time, max_idle_time)

func _stop_walking() -> void:
	current_state = State.IDLE
	idle_timer = randf_range(min_idle_time, max_idle_time)
	if animated_sprite:
		animated_sprite.play("idle_" + current_facing)

func get_direction_facing(dir: Vector2) -> String:
	# Isometric diagonal direction mapping based on 2D room screen vector
	if dir.y >= 0.0:
		return "se" if dir.x >= 0.0 else "sw"
	else:
		return "ne" if dir.x >= 0.0 else "nw"

func update_appearance() -> void:
	# AnimatedSprite2D handles the multi-frame pixel art character
	if animated_sprite:
		animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var anim_name := ("walk_" if current_state == State.WALKING else "idle_") + current_facing
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(anim_name):
			animated_sprite.play(anim_name)
