extends Node

# Modern style sound effects for the 5 core navigation buttons:
# 1. Life Overview (infant_button)
# 2. Assets (assets_button)
# 3. Age Up (age_button)
# 4. Relationships (relationships_button)
# 5. Activities (activities_button)

const SAMPLE_RATE := 44100
const VOLUME_DB := -10.0
const DEBOUNCE_MS := 35

var _player_overview: AudioStreamPlayer
var _player_assets: AudioStreamPlayer
var _player_age: AudioStreamPlayer
var _player_relationships: AudioStreamPlayer
var _player_activities: AudioStreamPlayer
var _player_core: AudioStreamPlayer

var _stream_overview: AudioStreamWAV
var _stream_assets: AudioStreamWAV
var _stream_age: AudioStreamWAV
var _stream_relationships: AudioStreamWAV
var _stream_activities: AudioStreamWAV
var _stream_core: AudioStreamWAV

var _last_press_ms: int = -1000


func _ready() -> void:
	_init_audio_streams()
	_init_audio_players()


func _init_audio_streams() -> void:
	_stream_overview = _load_or_synthesize("res://assets/audio/sfx_core_overview.wav", _synth_overview)
	_stream_assets = _load_or_synthesize("res://assets/audio/sfx_core_assets.wav", _synth_assets)
	_stream_age = _load_or_synthesize("res://assets/audio/sfx_core_age_up.wav", _synth_age_up)
	_stream_relationships = _load_or_synthesize("res://assets/audio/sfx_core_relationships.wav", _synth_relationships)
	_stream_activities = _load_or_synthesize("res://assets/audio/sfx_core_activities.wav", _synth_activities)
	_stream_core = _load_or_synthesize("res://assets/audio/sfx_core_click.wav", _synth_core_click)


func _init_audio_players() -> void:
	_player_overview = _make_player("CoreOverviewSound", _stream_overview)
	_player_assets = _make_player("CoreAssetsSound", _stream_assets)
	_player_age = _make_player("CoreAgeUpSound", _stream_age)
	_player_relationships = _make_player("CoreRelationshipsSound", _stream_relationships)
	_player_activities = _make_player("CoreActivitiesSound", _stream_activities)
	_player_core = _make_player("CoreClickSound", _stream_core)


func _make_player(player_name: String, sound: AudioStreamWAV) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.stream = sound
	player.volume_db = VOLUME_DB
	player.max_polyphony = 3
	player.bus = "Master"
	add_child(player)
	return player


# -----------------------------------------------------------------------------
# AUDIO PLAYBACK HANDLERS
# -----------------------------------------------------------------------------
func play_core_sound(button_type: String = "core") -> void:
	if AudioServer.is_bus_mute(0) or bool(LifeLibrary.data.get("muted", false)):
		return

	var now := Time.get_ticks_msec()
	if now - _last_press_ms < DEBOUNCE_MS:
		return
	_last_press_ms = now

	match button_type.to_lower():
		"overview", "infant", "life":
			if is_instance_valid(_player_overview):
				_player_overview.play()
		"assets", "asset":
			if is_instance_valid(_player_assets):
				_player_assets.play()
		"age", "age_up", "ageup":
			if is_instance_valid(_player_age):
				_player_age.play()
		"relationships", "rel", "relationship":
			if is_instance_valid(_player_relationships):
				_player_relationships.play()
		"activities", "act", "activity":
			if is_instance_valid(_player_activities):
				_player_activities.play()
		_:
			if is_instance_valid(_player_core):
				_player_core.play()


func play_overview() -> void:
	play_core_sound("overview")


func play_assets() -> void:
	play_core_sound("assets")


func play_age() -> void:
	play_core_sound("age")


func play_relationships() -> void:
	play_core_sound("relationships")


func play_activities() -> void:
	play_core_sound("activities")


func play_core_click() -> void:
	play_core_sound("core")


# -----------------------------------------------------------------------------
# WIRING HELPER FOR THE 5 CORE BUTTONS
# -----------------------------------------------------------------------------
func wire_core_buttons(
	infant_btn: Button,
	assets_btn: Button,
	age_btn: Button,
	rel_btn: Button,
	act_btn: Button
) -> void:
	if is_instance_valid(infant_btn):
		var cb := func(): play_core_sound("overview")
		if not infant_btn.pressed.is_connected(cb):
			infant_btn.pressed.connect(cb)

	if is_instance_valid(assets_btn):
		var cb := func(): play_core_sound("assets")
		if not assets_btn.pressed.is_connected(cb):
			assets_btn.pressed.connect(cb)

	if is_instance_valid(age_btn):
		var cb := func(): play_core_sound("age")
		if not age_btn.pressed.is_connected(cb):
			age_btn.pressed.connect(cb)

	if is_instance_valid(rel_btn):
		var cb := func(): play_core_sound("relationships")
		if not rel_btn.pressed.is_connected(cb):
			rel_btn.pressed.connect(cb)

	if is_instance_valid(act_btn):
		var cb := func(): play_core_sound("activities")
		if not act_btn.pressed.is_connected(cb):
			act_btn.pressed.connect(cb)


# -----------------------------------------------------------------------------
# AUDIO STREAM LOADER / SYNTHESIZER
# -----------------------------------------------------------------------------
func _load_or_synthesize(wav_path: String, synth_fn: Callable) -> AudioStreamWAV:
	if FileAccess.file_exists(wav_path):
		var file_bytes := FileAccess.get_file_as_bytes(wav_path)
		if file_bytes.size() > 44:
			var stream := AudioStreamWAV.new()
			stream.format = AudioStreamWAV.FORMAT_16_BITS
			stream.mix_rate = SAMPLE_RATE
			stream.stereo = false
			stream.data = file_bytes.slice(44)
			return stream

	# Procedural fallback
	return synth_fn.call()


# 1. Overview Sound: warm, rounded modern bubble / drop (580Hz -> 440Hz)
static func _synth_overview() -> AudioStreamWAV:
	var duration := 0.080
	var frames := int(duration * SAMPLE_RATE)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	var phase := 0.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var noise_val := 0.0

	for i in range(frames):
		var t := float(i) / SAMPLE_RATE
		var freq := 440.0 + 140.0 * exp(-50.0 * t)
		phase += TAU * freq / SAMPLE_RATE
		var attack := smoothstep(0.0, 0.003, t)
		var decay := exp(-48.0 * t)
		var release := 1.0 - smoothstep(0.060, duration, t)
		noise_val = noise_val * 0.85 + rng.randf_range(-1.0, 1.0) * 0.15
		var noise_burst := noise_val * exp(-1200.0 * t) * 0.08
		var tone := sin(phase) + 0.18 * sin(phase * 2.0)
		var sample := (tone * 0.85 + noise_burst) * attack * decay * release * 0.55
		bytes.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))

	return _make_stream(bytes)


# 2. Assets Sound: crisp modern metallic glass chime (987Hz + 1480Hz dual partial)
static func _synth_assets() -> AudioStreamWAV:
	var duration := 0.085
	var frames := int(duration * SAMPLE_RATE)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	var phase1 := 0.0
	var phase2 := 0.0
	var phase3 := 0.0

	for i in range(frames):
		var t := float(i) / SAMPLE_RATE
		var f1 := 987.77 + 750.0 * exp(-320.0 * t)
		var f2 := 1479.98
		var f3 := 2960.0
		phase1 += TAU * f1 / SAMPLE_RATE
		phase2 += TAU * f2 / SAMPLE_RATE
		phase3 += TAU * f3 / SAMPLE_RATE
		var attack := smoothstep(0.0, 0.002, t)
		var decay := exp(-45.0 * t)
		var release := 1.0 - smoothstep(0.065, duration, t)
		var shimmer := sin(phase3) * 0.08 * exp(-100.0 * t)
		var tone := sin(phase1) * 0.70 + sin(phase2) * 0.28 + shimmer
		var sample := tone * attack * decay * release * 0.50
		bytes.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))

	return _make_stream(bytes)


# 3. Age Up Sound: impactful ascending modern power pop / chime (360Hz -> 720Hz)
static func _synth_age_up() -> AudioStreamWAV:
	var duration := 0.140
	var frames := int(duration * SAMPLE_RATE)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	var phase := 0.0
	var sub_phase := 0.0
	var chime_phase := 0.0

	for i in range(frames):
		var t := float(i) / SAMPLE_RATE
		var freq := 360.0 + 360.0 * (1.0 - exp(-65.0 * t))
		phase += TAU * freq / SAMPLE_RATE
		sub_phase += TAU * (freq * 0.5) / SAMPLE_RATE
		chime_phase += TAU * 1080.0 / SAMPLE_RATE
		var attack := smoothstep(0.0, 0.003, t)
		var decay := exp(-22.0 * t)
		var release := 1.0 - smoothstep(0.100, duration, t)
		var sub := sin(sub_phase) * 0.25 * exp(-55.0 * t)
		var chime := sin(chime_phase) * 0.15 * exp(-28.0 * t)
		var tone := sin(phase) * 0.70 + sub + chime + 0.12 * sin(phase * 2.0)
		var sample := tone * attack * decay * release * 0.55
		bytes.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))

	return _make_stream(bytes)


# 4. Relationships Sound: warm harmonic chord pluck (659Hz + 830Hz)
static func _synth_relationships() -> AudioStreamWAV:
	var duration := 0.095
	var frames := int(duration * SAMPLE_RATE)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	var phase1 := 0.0
	var phase2 := 0.0
	var phase_warmth := 0.0

	for i in range(frames):
		var t := float(i) / SAMPLE_RATE
		var f1 := 659.25
		var f2 := 830.61
		var f3 := 1318.5
		phase1 += TAU * f1 / SAMPLE_RATE
		phase2 += TAU * f2 / SAMPLE_RATE
		phase_warmth += TAU * f3 / SAMPLE_RATE
		var attack := smoothstep(0.0, 0.0025, t)
		var decay := exp(-38.0 * t)
		var release := 1.0 - smoothstep(0.075, duration, t)
		var tone := sin(phase1) * 0.62 + sin(phase2) * 0.35 + sin(phase_warmth) * 0.12
		var sample := tone * attack * decay * release * 0.52
		bytes.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))

	return _make_stream(bytes)


# 5. Activities Sound: snappy modern digital toggle / snap (1050Hz -> 560Hz)
static func _synth_activities() -> AudioStreamWAV:
	var duration := 0.065
	var frames := int(duration * SAMPLE_RATE)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	var phase := 0.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var noise_val := 0.0

	for i in range(frames):
		var t := float(i) / SAMPLE_RATE
		var freq := 560.0 + 490.0 * exp(-120.0 * t)
		phase += TAU * freq / SAMPLE_RATE
		var attack := smoothstep(0.0, 0.0015, t)
		var decay := exp(-62.0 * t)
		var release := 1.0 - smoothstep(0.050, duration, t)
		noise_val = noise_val * 0.80 + rng.randf_range(-1.0, 1.0) * 0.20
		var noise_burst := noise_val * exp(-800.0 * t) * 0.10
		var tone := sin(phase) + 0.15 * sin(phase * 2.0)
		var sample := (tone * 0.85 + noise_burst) * attack * decay * release * 0.50
		bytes.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))

	return _make_stream(bytes)


# 6. Unified Core Click Sound: universal modern sleek tap (700Hz -> 480Hz)
static func _synth_core_click() -> AudioStreamWAV:
	var duration := 0.075
	var frames := int(duration * SAMPLE_RATE)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	var phase := 0.0

	for i in range(frames):
		var t := float(i) / SAMPLE_RATE
		var freq := 480.0 + 220.0 * exp(-80.0 * t)
		phase += TAU * freq / SAMPLE_RATE
		var attack := smoothstep(0.0, 0.002, t)
		var decay := exp(-50.0 * t)
		var release := 1.0 - smoothstep(0.055, duration, t)
		var tone := sin(phase) + 0.16 * sin(phase * 2.0)
		var sample := tone * attack * decay * release * 0.52
		bytes.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))

	return _make_stream(bytes)


static func _make_stream(bytes: PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	return stream
