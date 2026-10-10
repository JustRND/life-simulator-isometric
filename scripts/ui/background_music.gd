extends Node

# Background Music Controller for Life Simulator
# Features:
# - Ambient, cozy, chill lofi harmonic progression
# - Seamless loop forward (loop points configured at sample-accurate boundaries)
# - Subtle background volume (-20.0 dB default) that supports gameplay without overpowering UI
# - Full mute compliance with Settings (LifeLibrary.data.muted & AudioServer Master bus mute)
# - Browser Web Audio autoplay unlock handler for mobile/desktop browsers
# - In-memory procedural fallback synthesis if WAV asset is missing

const SAMPLE_RATE := 44100
const DEFAULT_VOLUME_DB := -20.0
const SILENCE_DB := -60.0
const FADE_IN_DURATION := 1.5
const FADE_OUT_DURATION := 0.6

var _player: AudioStreamPlayer = null
var _stream: AudioStreamWAV = null
var _target_volume_db: float = DEFAULT_VOLUME_DB
var _fade_tween: Tween = null
var _was_muted: bool = false
var _web_audio_unlocked: bool = false


func _ready() -> void:
	_init_stream()
	_init_player()
	_was_muted = is_muted()
	if not _was_muted:
		start_music(true)


func _init_stream() -> void:
	var wav_path := "res://assets/audio/bgm_ambient_loop.wav"
	if FileAccess.file_exists(wav_path):
		var file_bytes := FileAccess.get_file_as_bytes(wav_path)
		if file_bytes.size() > 44:
			_stream = AudioStreamWAV.new()
			_stream.format = AudioStreamWAV.FORMAT_16_BITS
			_stream.mix_rate = SAMPLE_RATE
			_stream.stereo = false
			_stream.data = file_bytes.slice(44)
			_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			_stream.loop_begin = 0
			_stream.loop_end = (file_bytes.size() - 44) / 2
			return

	# Fallback: synthesize ambient loop directly in memory
	_stream = _synth_ambient_bgm()


func _init_player() -> void:
	_player = AudioStreamPlayer.new()
	_player.name = "BGMPlayer"
	_player.stream = _stream
	_player.volume_db = SILENCE_DB
	_player.bus = "Master"
	add_child(_player)


func _input(event: InputEvent) -> void:
	# Unlock web browser audio on first user touch/click gesture
	if event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventKey:
		if not _web_audio_unlocked:
			_ensure_web_audio_unlocked()
		if not is_muted() and is_instance_valid(_player) and not _player.playing:
			start_music(true)


func _process(_delta: float) -> void:
	var currently_muted := is_muted()
	if currently_muted != _was_muted:
		_was_muted = currently_muted
		if currently_muted:
			_on_muted()
		else:
			_on_unmuted()


# -----------------------------------------------------------------------------
# PLAYBACK CONTROLS
# -----------------------------------------------------------------------------
func start_music(fade_in: bool = true) -> void:
	if not is_instance_valid(_player) or _stream == null:
		return
	if is_muted():
		return

	_ensure_web_audio_unlocked()

	if not _player.playing:
		_player.play()

	if fade_in:
		_player.volume_db = SILENCE_DB
		fade_to(_target_volume_db, FADE_IN_DURATION)
	else:
		_player.volume_db = _target_volume_db


func stop_music(fade_out: bool = true) -> void:
	if not is_instance_valid(_player):
		return
	if not _player.playing:
		return

	if fade_out:
		fade_to(SILENCE_DB, FADE_OUT_DURATION)
		if _fade_tween:
			_fade_tween.finished.connect(func():
				if is_instance_valid(_player) and _player.volume_db <= SILENCE_DB + 1.0:
					_player.stop()
			, CONNECT_ONE_SHOT)
	else:
		_player.stop()


func pause_music() -> void:
	if is_instance_valid(_player):
		_player.stream_paused = true


func resume_music() -> void:
	if is_instance_valid(_player):
		if not _player.playing:
			start_music(true)
		else:
			_player.stream_paused = false


func set_volume_db(new_vol_db: float) -> void:
	_target_volume_db = new_vol_db
	if is_instance_valid(_player) and not is_muted():
		_player.volume_db = new_vol_db


func get_volume_db() -> float:
	return _target_volume_db


func fade_to(target_db: float, duration: float) -> void:
	if not is_instance_valid(_player):
		return
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.set_trans(Tween.TRANS_SINE)
	_fade_tween.set_ease(Tween.EASE_OUT)
	_fade_tween.tween_property(_player, "volume_db", target_db, duration)


func is_playing() -> bool:
	return is_instance_valid(_player) and _player.playing and not _player.stream_paused


func get_player() -> AudioStreamPlayer:
	return _player


func get_stream() -> AudioStreamWAV:
	return _stream


# -----------------------------------------------------------------------------
# MUTE & SYSTEM INTEGRATION
# -----------------------------------------------------------------------------
func is_muted() -> bool:
	if AudioServer.is_bus_mute(0):
		return true
	if Engine.has_singleton("LifeLibrary"):
		var lib = Engine.get_singleton("LifeLibrary")
		if lib and "data" in lib and bool(lib.data.get("muted", false)):
			return true
	elif typeof(LifeLibrary) != TYPE_NIL and LifeLibrary != null and "data" in LifeLibrary:
		if bool(LifeLibrary.data.get("muted", false)):
			return true
	return false


func _on_muted() -> void:
	if is_instance_valid(_player):
		fade_to(SILENCE_DB, 0.4)


func _on_unmuted() -> void:
	if is_instance_valid(_player):
		if not _player.playing:
			_player.play()
		_player.stream_paused = false
		fade_to(_target_volume_db, FADE_IN_DURATION)


func _ensure_web_audio_unlocked() -> void:
	_web_audio_unlocked = true
	if OS.has_feature("web") and OS.has_feature("JavaScript"):
		JavaScriptBridge.eval("""
			try {
				if (typeof AudioContext !== 'undefined' || typeof webkitAudioContext !== 'undefined') {
					if (window.__godot_audio_ctx && window.__godot_audio_ctx.state === 'suspended') {
						window.__godot_audio_ctx.resume();
					}
				}
			} catch(e) {}
		""")


# -----------------------------------------------------------------------------
# IN-MEMORY PROCEDURAL SYNTHESIS FALLBACK (8-BAR AMBIENT LO-FI PROGRESSION)
# -----------------------------------------------------------------------------
static func _synth_ambient_bgm() -> AudioStreamWAV:
	var bpm := 60.0
	var bar_sec := 4.0
	var loop_sec := 32.0
	var tail_sec := 4.0
	var total_sec := loop_sec + tail_sec
	var total_frames := int(total_sec * SAMPLE_RATE)
	var loop_frames := int(loop_sec * SAMPLE_RATE)

	var buffer: PackedFloat32Array = PackedFloat32Array()
	buffer.resize(total_frames)

	# 8-bar progression: Fmaj9 -> Am9 -> Dm9 -> Cmaj7 -> Fmaj9 -> Em7 -> Dm9 -> Gsus4/G7
	var chords: Array = [
		[0.0, 3.85, 43.65, [174.61, 220.00, 261.63, 329.63, 392.00]],
		[4.0, 3.85, 55.00, [164.81, 220.00, 261.63, 329.63, 493.88]],
		[8.0, 3.85, 36.71, [146.83, 174.61, 220.00, 261.63, 329.63]],
		[12.0, 3.85, 49.00, [164.81, 196.00, 246.94, 293.66, 329.63]],
		[16.0, 3.85, 43.65, [174.61, 220.00, 261.63, 329.63, 392.00]],
		[20.0, 3.85, 41.20, [164.81, 196.00, 246.94, 293.66, 392.00]],
		[24.0, 3.85, 36.71, [146.83, 174.61, 220.00, 261.63, 329.63]],
		[28.0, 3.85, 49.00, [146.83, 196.00, 261.63, 293.66, 349.23]]
	]

	# Synthesize chords
	for chord_data in chords:
		var st: float = chord_data[0]
		var dur: float = chord_data[1]
		var bass_f: float = chord_data[2]
		var voices: Array = chord_data[3]
		var start_idx := int(st * SAMPLE_RATE)
		var env_frames := int((dur + 1.2) * SAMPLE_RATE)

		for fi in range(env_frames):
			var idx := start_idx + fi
			if idx >= total_frames:
				break
			var t := float(fi) / SAMPLE_RATE
			var att := smoothstep(0.0, 0.08, t)
			var dec := exp(-0.35 * t)
			var rel := 1.0 - smoothstep(dur, dur + 1.2, t)
			var env := att * dec * rel

			# Bass
			var bass_ph := TAU * bass_f * t
			var bass_samp := (sin(bass_ph) + 0.22 * sin(bass_ph * 2.0)) * env * 0.25

			# Voices
			var chord_samp := 0.0
			for vf in voices:
				var v_ph := TAU * float(vf) * t
				chord_samp += (sin(v_ph) * 0.65 + sin(v_ph * 2.0) * 0.22 + sin(v_ph * 3.0) * 0.08) * 0.18
			chord_samp = chord_samp * env * 0.30

			buffer[idx] += bass_samp + chord_samp

	# Seamless loop wrap-around
	var tail_frames := total_frames - loop_frames
	for ti in range(tail_frames):
		buffer[ti] += buffer[loop_frames + ti]

	# Normalize peak to 0.60
	var max_peak := 0.0001
	for si in range(loop_frames):
		var val := absf(buffer[si])
		if val > max_peak:
			max_peak = val

	var norm_scale := 0.60 / max_peak

	var out_bytes := PackedByteArray()
	out_bytes.resize(loop_frames * 2)

	# Micro-crossfade last 1024 samples to first 1024 samples for 100% pop-free seam
	var fade_samples := 1024
	for fi in range(fade_samples):
		var w := float(fi) / float(fade_samples)
		var end_idx := loop_frames - fade_samples + fi
		var blended := buffer[end_idx] * (1.0 - w) + buffer[fi] * w
		buffer[end_idx] = blended
	buffer[loop_frames - 1] = buffer[0]

	for i in range(loop_frames):
		var samp := clampf(buffer[i] * norm_scale, -1.0, 1.0)
		out_bytes.encode_s16(i * 2, int(samp * 32767.0))

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = out_bytes
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = loop_frames
	return stream
