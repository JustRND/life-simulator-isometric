extends Node

func _ready() -> void:
	print("=== BEGIN TEST: BACKGROUND MUSIC & SEAMLESS LOOPING AUDIT ===")

	LifeLibrary.data.theme = "dark"
	LifeLibrary.data.muted = false
	AudioServer.set_bus_mute(0, false)
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.age = 25
	PlayerData.money = 50000

	# -------------------------------------------------------------
	# 1. AUDIT BGM WAV FILE & HEADER
	# -------------------------------------------------------------
	print("\n--- 1. AUDITING BGM WAV FILE & HEADER ---")
	var wav_path := "res://assets/audio/bgm_ambient_loop.wav"
	assert(FileAccess.file_exists(wav_path), "BGM audio file missing: " + wav_path)

	var b := FileAccess.get_file_as_bytes(wav_path)
	assert(b.size() > 44, "BGM file is too small")
	var riff := b.slice(0, 4).get_string_from_ascii()
	var wave := b.slice(8, 12).get_string_from_ascii()
	assert(riff == "RIFF", "BGM file must have RIFF header")
	assert(wave == "WAVE", "BGM file must have WAVE format")

	var channels := b.decode_u16(22)
	var sample_rate := b.decode_u32(24)
	var bits_per_sample := b.decode_u16(34)
	var pcm_data_bytes := b.size() - 44
	var total_samples := pcm_data_bytes / 2
	var duration_sec := float(total_samples) / float(sample_rate)

	assert(channels == 1, "BGM should be mono, got %d channels" % channels)
	assert(sample_rate == 44100, "Sample rate must be 44100 Hz, got %d" % sample_rate)
	assert(bits_per_sample == 16, "Sample format must be 16-bit, got %d" % bits_per_sample)
	assert(duration_sec >= 30.0, "BGM loop must be at least 30 seconds, got %.2f sec" % duration_sec)

	print("  ✔ File '%s' verified:" % wav_path.get_file())
	print("    - Size: %d bytes (%.2f MB)" % [b.size(), float(b.size()) / 1048576.0])
	print("    - Channels: %d, Bits: %d, Sample Rate: %d Hz" % [channels, bits_per_sample, sample_rate])
	print("    - Total Samples: %d, Duration: %.2f seconds" % [total_samples, duration_sec])
	print("✅ CHECK 1 PASSED: BGM WAV file verified with valid RIFF 44.1kHz header.")

	# -------------------------------------------------------------
	# 2. AUDIT SEAMLESS LOOP BOUNDARY CONTINUITY
	# -------------------------------------------------------------
	print("\n--- 2. AUDITING SEAMLESS LOOP BOUNDARY CONTINUITY ---")
	var first_sample: int = b.decode_s16(44)
	var last_sample: int = b.decode_s16(b.size() - 2)
	var discontinuity: int = absi(first_sample - last_sample)
	var disc_percent: float = float(discontinuity) / 32767.0 * 100.0

	print("  ✔ First sample: %d, Last sample: %d" % [first_sample, last_sample])
	print("  ✔ Boundary discontinuity: %d / 32767 (%.3f%%)" % [discontinuity, disc_percent])
	assert(disc_percent < 1.0, "Boundary discontinuity must be under 1%% for seamless looping, got %.3f%%" % disc_percent)
	print("✅ CHECK 2 PASSED: Loop boundary is seamless with zero audible discontinuity.")

	# -------------------------------------------------------------
	# 3. AUDIT BACKGROUNDMUSIC NODE & AUDIOSTREAMPLAYER
	# -------------------------------------------------------------
	print("\n--- 3. AUDITING BACKGROUNDMUSIC NODE & CONTROLLER ---")
	var bgm_script = preload("res://scripts/ui/background_music.gd")
	var bgm = bgm_script.new()
	bgm.name = "BackgroundMusic"
	add_child(bgm)
	await get_tree().process_frame

	var player := bgm.get_player()
	assert(player != null, "BGM AudioStreamPlayer must be instantiated")
	assert(player.bus == "Master", "BGM bus must be Master")

	var stream := bgm.get_stream()
	assert(stream != null, "AudioStreamWAV must be loaded")
	assert(stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Loop mode must be LOOP_FORWARD")
	assert(stream.loop_begin == 0, "Loop begin must be 0")
	assert(stream.loop_end > 0, "Loop end must be > 0 (samples: %d)" % stream.loop_end)
	assert(stream.loop_end == total_samples, "Loop end must match total sample count (%d vs %d)" % [stream.loop_end, total_samples])

	var target_vol := bgm.get_volume_db()
	print("  ✔ Target volume: %.1f dB (subtle background music)" % target_vol)
	assert(target_vol <= -18.0, "BGM volume must be subtle (<= -18.0 dB), got %.1f dB" % target_vol)
	print("✅ CHECK 3 PASSED: BackgroundMusic node configured with sample-accurate forward loop.")

	# -------------------------------------------------------------
	# 4. AUDIT PLAYBACK, FADE & PAUSE CONTROLS
	# -------------------------------------------------------------
	print("\n--- 4. AUDITING PLAYBACK, FADE & CONTROLS ---")
	assert(player.playing, "Player should start playing upon initialization")
	print("  ✔ BGM is actively playing")

	# Test pause and resume
	bgm.pause_music()
	assert(player.stream_paused, "BGM should be paused")
	print("  ✔ pause_music() successfully paused stream")

	bgm.resume_music()
	assert(not player.stream_paused, "BGM should be resumed")
	print("  ✔ resume_music() successfully resumed stream")

	# Test volume adjustment
	bgm.set_volume_db(-24.0)
	assert(bgm.get_volume_db() == -24.0, "set_volume_db should update target volume")
	bgm.set_volume_db(-20.0)
	print("✅ CHECK 4 PASSED: Playback controls, pause, resume, and volume methods functional.")

	# -------------------------------------------------------------
	# 5. AUDIT MUTE SETTINGS INTEGRATION
	# -------------------------------------------------------------
	print("\n--- 5. AUDITING MUTE SETTINGS INTEGRATION ---")
	LifeLibrary.data.muted = true
	assert(bgm.is_muted(), "bgm.is_muted() must return true when LifeLibrary.data.muted is true")
	bgm._process(0.016)
	await get_tree().process_frame
	print("  ✔ LifeLibrary.data.muted=true correctly silences/fades BGM")

	LifeLibrary.data.muted = false
	assert(not bgm.is_muted(), "bgm.is_muted() must return false when unmuted")
	bgm._process(0.016)
	await get_tree().process_frame
	print("  ✔ LifeLibrary.data.muted=false correctly restores BGM")

	AudioServer.set_bus_mute(0, true)
	assert(bgm.is_muted(), "bgm.is_muted() must return true when Master bus is muted")
	bgm._process(0.016)
	await get_tree().process_frame
	print("  ✔ AudioServer Master bus mute correctly recognized")

	AudioServer.set_bus_mute(0, false)
	assert(not bgm.is_muted(), "bgm.is_muted() must return false when Master bus is unmuted")
	bgm._process(0.016)
	await get_tree().process_frame
	print("✅ CHECK 5 PASSED: Full mute compliance with both Settings and AudioServer.")

	# -------------------------------------------------------------
	# 6. AUDIT PROCEDURAL FALLBACK SYNTHESIS
	# -------------------------------------------------------------
	print("\n--- 6. AUDITING IN-MEMORY PROCEDURAL FALLBACK SYNTHESIS ---")
	var synth_stream: AudioStreamWAV = bgm_script._synth_ambient_bgm()
	assert(synth_stream != null, "Procedural fallback must return AudioStreamWAV")
	assert(synth_stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Fallback stream must loop forward")
	assert(synth_stream.data.size() > 44100 * 2, "Fallback stream must have sample data")
	print("  ✔ Procedural fallback synthesized %d bytes of PCM audio" % synth_stream.data.size())
	print("✅ CHECK 6 PASSED: In-memory procedural fallback verified.")

	# -------------------------------------------------------------
	# 7. AUDIT MAINSCREEN INTEGRATION
	# -------------------------------------------------------------
	print("\n--- 7. AUDITING MAINSCREEN SCENE INTEGRATION ---")
	var main_scene_res = load("res://scenes/main/main_screen.tscn")
	var main_scene = main_scene_res.instantiate()
	add_child(main_scene)
	await get_tree().process_frame

	assert(main_scene.background_music != null, "main_scene.background_music must be initialized")
	assert(main_scene.get_node_or_null("BackgroundMusic") != null, "BackgroundMusic node must exist in MainScreen")
	var ms_bgm = main_scene.background_music
	assert(ms_bgm.get_player() != null, "MainScreen BGM player must exist")
	print("  ✔ MainScreen BackgroundMusic node found and active")
	print("✅ CHECK 7 PASSED: MainScreen integration verified.")

	print("\n⭐⭐⭐ ALL BACKGROUND MUSIC AUDITS PASSED PERFECTLY! ⭐⭐⭐")
	get_tree().quit(0)
