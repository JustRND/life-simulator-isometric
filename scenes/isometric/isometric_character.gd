class_name IsometricCharacter
extends Node2D

## ANIMATION & MODULAR CUSTOMIZATION ARCHITECTURE:
##
## 1. MOVEMENT & SIMULATION:
##    - Completely decoupled from character appearance and clothing data.
##    - Calculates 4-directional isometric heading ('se', 'sw', 'ne', 'nw') from 2D velocity vectors.
##    - Operates state machine: State.IDLE, State.WALKING.
##
## 2. MODULAR VISUAL LAYERING:
##    - Base body layer: $AnimatedSprite2D (drives master frame timing and animation state).
##    - Visual layers container: $VisualLayers (hosts modular AnimatedSprite2D layers).
##    - Supported slot categories: body, bottom, shoes, top, hair, accessory.
##    - Frame synchronization: When master AnimatedSprite2D advances frames (frame_changed signal),
##      all active visual layers instantly synchronize frame index and frame progress.
##    - Direction synchronization: Whenever facing or state changes, all active visual layers
##      play the matching directional animation (e.g. 'walk_se', 'idle_se').
##
## 3. DATA MODEL:
##    - Appearance properties are encapsulated in CharacterAppearance (Resource).
##    - Does not hardcode clothing, hairstyles, or asset paths in the movement controller.

const CharacterAppearanceScript = preload("res://scripts/isometric/character_appearance.gd")

enum State {
	IDLE,
	WALKING
}

## Standard Z-indices for layering modular character parts from bottom to top
const DEFAULT_SLOT_Z_INDICES: Dictionary = {
	"body": 0,
	"bottom": 10,
	"shoes": 20,
	"top": 30,
	"hair": 40,
	"accessory": 50
}

@export var walk_speed: float = 140.0
@export var min_idle_time: float = 1.5
@export var max_idle_time: float = 4.0
@export var character_scale: float = 1.0
@export var roam_enabled: bool = true
@export var apply_age_scaling: bool = false
@export var appearance: Resource = null

var current_state: State = State.IDLE
var current_facing: String = "se"
var target_position: Vector2 = Vector2.ZERO
var idle_timer: float = 0.0

var _room_ref: Node2D = null
var _visual_layers: Dictionary = {}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var visual_layers_container: Node2D = $VisualLayers
@onready var shadow: Polygon2D = $Shadow
@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	y_sort_enabled = true
	scale = Vector2(character_scale, character_scale)
	idle_timer = randf_range(min_idle_time, max_idle_time)
	
	# Register primary AnimatedSprite2D as the base body layer
	if animated_sprite:
		animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_visual_layers["body"] = animated_sprite
		
		# Connect frame_changed for lockstep multi-layer animation synchronization
		if not animated_sprite.frame_changed.is_connected(_on_master_frame_changed):
			animated_sprite.frame_changed.connect(_on_master_frame_changed)
			
	# Register any existing pre-configured children under VisualLayers
	if visual_layers_container:
		for child in visual_layers_container.get_children():
			if child is AnimatedSprite2D:
				var slot_key := child.name.to_lower()
				_visual_layers[slot_key] = child
				child.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	# Initialize appearance model if not explicitly set
	if appearance == null:
		_init_default_appearance()

	update_appearance()

func _init_default_appearance() -> void:
	if Engine.has_singleton("PlayerData") or has_node("/root/PlayerData"):
		var pd = get_node("/root/PlayerData")
		if pd.has_method("get_character_appearance"):
			appearance = pd.get_character_appearance()
		elif "character_appearance" in pd and pd.character_appearance is Dictionary:
			appearance = CharacterAppearanceScript.create_from_dict(pd.character_appearance)
			
	if appearance == null:
		appearance = CharacterAppearanceScript.new()

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
	if new_facing != current_facing or not is_playing_movement_animation():
		current_facing = new_facing
		play_animation("walk_" + current_facing)

func _pick_next_destination() -> void:
	if _room_ref and _room_ref.has_method("get_random_walkable_point"):
		var next_pt: Vector2 = _room_ref.get_random_walkable_point()
		if next_pt != Vector2.ZERO and next_pt.distance_to(position) > 40.0:
			target_position = next_pt
			current_state = State.WALKING
			var dir := (target_position - position).normalized()
			current_facing = get_direction_facing(dir)
			play_animation("walk_" + current_facing)
			return
			
	idle_timer = randf_range(min_idle_time, max_idle_time)

func _stop_walking() -> void:
	current_state = State.IDLE
	idle_timer = randf_range(min_idle_time, max_idle_time)
	play_animation("idle_" + current_facing)

func get_direction_facing(dir: Vector2) -> String:
	# Isometric diagonal direction mapping based on 2D room screen vector
	if dir.y >= 0.0:
		return "se" if dir.x >= 0.0 else "sw"
	else:
		return "ne" if dir.x >= 0.0 else "nw"

## Returns whether the primary visual layer is actively playing an animation.
func is_playing_movement_animation() -> bool:
	if animated_sprite and animated_sprite.is_playing():
		return true
	return false

# ==============================================================================
# MODULAR VISUAL LAYERS & SYNCHRONIZATION
# ==============================================================================

## Plays an animation synchronously across the base body and all active visual layers.
func play_animation(anim_name: String) -> void:
	for slot_key in _visual_layers:
		var layer_sprite: AnimatedSprite2D = _visual_layers[slot_key]
		if not is_instance_valid(layer_sprite):
			continue
			
		if layer_sprite.sprite_frames and layer_sprite.sprite_frames.has_animation(anim_name):
			layer_sprite.visible = true
			layer_sprite.play(anim_name)
			
			# Align frame and frame progress with the base body sprite
			if layer_sprite != animated_sprite and animated_sprite and animated_sprite.sprite_frames:
				layer_sprite.frame = animated_sprite.frame
				layer_sprite.frame_progress = animated_sprite.frame_progress
		else:
			# If a modular layer doesn't have this animation, hide it temporarily
			if layer_sprite != animated_sprite:
				layer_sprite.visible = false

## Synchronizes frame index and progress from the master body sprite to all active layers.
func _on_master_frame_changed() -> void:
	if not animated_sprite:
		return
		
	var target_anim := animated_sprite.animation
	var target_frame := animated_sprite.frame
	var target_progress := animated_sprite.frame_progress
	
	for slot_key in _visual_layers:
		var layer_sprite: AnimatedSprite2D = _visual_layers[slot_key]
		if layer_sprite == animated_sprite or not is_instance_valid(layer_sprite):
			continue
			
		if layer_sprite.sprite_frames and layer_sprite.sprite_frames.has_animation(target_anim):
			if layer_sprite.animation != target_anim or not layer_sprite.is_playing():
				layer_sprite.play(target_anim)
			layer_sprite.frame = target_frame
			layer_sprite.frame_progress = target_progress

## Synchronizes all layers manually (frames, playback, direction).
func sync_visual_layers() -> void:
	if not animated_sprite:
		return
	var current_anim := ("walk_" if current_state == State.WALKING else "idle_") + current_facing
	play_animation(current_anim)

## Adds or updates a modular visual layer (hair, top, bottom, shoes, accessory, etc.).
func add_visual_layer(slot_name: String, frames: SpriteFrames, custom_z_index: int = -999) -> AnimatedSprite2D:
	var key := slot_name.to_lower()
	var z := custom_z_index if custom_z_index != -999 else int(DEFAULT_SLOT_Z_INDICES.get(key, 10))
	
	# If updating the base body layer
	if key == "body":
		if animated_sprite:
			animated_sprite.sprite_frames = frames
			_visual_layers["body"] = animated_sprite
			play_current_animation()
			return animated_sprite
			
	var layer_node: AnimatedSprite2D = get_visual_layer(key)
	if layer_node == null:
		layer_node = AnimatedSprite2D.new()
		layer_node.name = key.capitalize()
		layer_node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		layer_node.offset = animated_sprite.offset if animated_sprite else Vector2(0, -148)
		layer_node.z_index = z
		
		var container = visual_layers_container if visual_layers_container else self
		container.add_child(layer_node)
		_visual_layers[key] = layer_node
	else:
		layer_node.z_index = z
		
	layer_node.sprite_frames = frames
	layer_node.visible = true
	
	var current_anim := ("walk_" if current_state == State.WALKING else "idle_") + current_facing
	if frames.has_animation(current_anim):
		layer_node.play(current_anim)
		if animated_sprite:
			layer_node.frame = animated_sprite.frame
			layer_node.frame_progress = animated_sprite.frame_progress
			
	return layer_node

## Removes a modular visual layer.
func remove_visual_layer(slot_name: String) -> void:
	var key := slot_name.to_lower()
	if key == "body":
		# Do not remove base body node
		return
		
	if _visual_layers.has(key):
		var node: AnimatedSprite2D = _visual_layers[key]
		_visual_layers.erase(key)
		if is_instance_valid(node):
			node.queue_free()

## Retrieves an active visual layer by slot name.
func get_visual_layer(slot_name: String) -> AnimatedSprite2D:
	var key := slot_name.to_lower()
	if _visual_layers.has(key):
		var node = _visual_layers[key]
		if is_instance_valid(node):
			return node
	return null

## Checks if a visual layer exists and is valid.
func has_visual_layer(slot_name: String) -> bool:
	return get_visual_layer(slot_name) != null

## Returns a list of all active slot names.
func get_active_slots() -> Array[String]:
	var result: Array[String] = []
	for k in _visual_layers:
		if is_instance_valid(_visual_layers[k]):
			result.append(k)
	return result

## Plays the appropriate animation for the current state and facing.
func play_current_animation() -> void:
	var anim_name := ("walk_" if current_state == State.WALKING else "idle_") + current_facing
	play_animation(anim_name)

# ==============================================================================
# APPEARANCE & AGE MODEL APPLICATION
# ==============================================================================

## Sets the character appearance data model.
func set_appearance(new_appearance: Resource) -> void:
	appearance = new_appearance
	update_appearance()

## Gets the current character appearance data model.
func get_appearance() -> Resource:
	return appearance

## Returns the scale multiplier for a given age group.
func get_age_scale_multiplier(age_group: String) -> float:
	match age_group:
		CharacterAppearanceScript.AGE_INFANT:
			return 0.55
		CharacterAppearanceScript.AGE_CHILD:
			return 0.75
		CharacterAppearanceScript.AGE_TEEN:
			return 0.90
		CharacterAppearanceScript.AGE_ADULT:
			return 1.0
		CharacterAppearanceScript.AGE_ELDER:
			return 0.95
		_:
			return 1.0

## Updates character visuals and scale according to the appearance data model.
func update_appearance(new_appearance: Resource = null) -> void:
	if new_appearance != null:
		appearance = new_appearance
		
	if appearance == null:
		_init_default_appearance()
		
	if appearance and apply_age_scaling:
		var age_factor := get_age_scale_multiplier(appearance.age_group)
		scale = Vector2(character_scale * age_factor, character_scale * age_factor)
	else:
		scale = Vector2(character_scale, character_scale)
		
	# Refresh current animation across all visual layers
	play_current_animation()
