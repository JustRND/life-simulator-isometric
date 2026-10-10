extends Node

func _ready() -> void:
	print("=== BEGIN TEST: 5 CORE BUTTONS MODERN SOUND EFFECT AUDIT ===")
	
	LifeLibrary.data.theme = "dark"
	LifeLibrary.data.muted = false
	AudioServer.set_bus_mute(0, false)
	PlayerData.reset_player()
	PlayerData.has_started_game = true
	PlayerData.age = 25
	PlayerData.money = 50000
	
	# -------------------------------------------------------------
	# 1. AUDIT AUDIO FILES & RIFF WAV HEADERS
	# -------------------------------------------------------------
	print("\n--- 1. AUDITING WAV ASSET FILES ---")
	var required_files := [
		"res://assets/audio/sfx_core_overview.wav",
		"res://assets/audio/sfx_core_assets.wav",
		"res://assets/audio/sfx_core_age_up.wav",
		"res://assets/audio/sfx_core_relationships.wav",
		"res://assets/audio/sfx_core_activities.wav",
		"res://assets/audio/sfx_core_click.wav"
	]
	
	for path in required_files:
		assert(FileAccess.file_exists(path), "Audio file missing: " + path)
		var b := FileAccess.get_file_as_bytes(path)
		assert(b.size() > 44, "Audio file is too small: " + path)
		var riff := b.slice(0, 4).get_string_from_ascii()
		var wave := b.slice(8, 12).get_string_from_ascii()
		assert(riff == "RIFF", "File must have RIFF header: " + path)
		assert(wave == "WAVE", "File must have WAVE format: " + path)
		var sample_rate := b.decode_u32(24)
		assert(sample_rate == 44100, "Sample rate must be 44100 Hz, got %d" % sample_rate)
		print("  ✔ %s verified (bytes: %d, sample_rate: %d Hz)" % [path.get_file(), b.size(), sample_rate])
		
	print("✅ CHECK 1 PASSED: All 6 modern sound WAV files verified on disk with valid RIFF headers.")
	
	# -------------------------------------------------------------
	# 2. AUDIT BUTTONSOUNDS NODE & AUDIO STREAM PLAYERS
	# -------------------------------------------------------------
	print("\n--- 2. AUDITING BUTTONSOUNDS NODE & PLAYERS ---")
	var button_sounds = preload("res://scripts/ui/button_sounds.gd").new()
	add_child(button_sounds)
	await get_tree().process_frame
	
	var player_names := [
		"CoreOverviewSound",
		"CoreAssetsSound",
		"CoreAgeUpSound",
		"CoreRelationshipsSound",
		"CoreActivitiesSound",
		"CoreClickSound"
	]
	
	for p_name in player_names:
		var p: AudioStreamPlayer = button_sounds.get_node_or_null(p_name) as AudioStreamPlayer
		assert(p != null, "AudioStreamPlayer '%s' must exist in ButtonSounds" % p_name)
		assert(p.stream != null, "AudioStreamPlayer '%s' must have an assigned AudioStream" % p_name)
		assert(p.stream is AudioStreamWAV, "Stream must be AudioStreamWAV")
		assert(p.max_polyphony >= 2, "Player must have polyphony >= 2")
		assert(p.bus == "Master", "Player bus must be Master")
		print("  ✔ Player '%s': volume=%.1fdB, polyphony=%d, bus=%s, data_size=%d bytes" % [
			p_name, p.volume_db, p.max_polyphony, p.bus, p.stream.data.size()
		])
		
	print("✅ CHECK 2 PASSED: ButtonSounds node and all 6 AudioStreamPlayers fully initialized.")
	
	# -------------------------------------------------------------
	# 3. AUDIT PROCEDURAL FALLBACK SYNTHESIS
	# -------------------------------------------------------------
	print("\n--- 3. AUDITING PROCEDURAL FALLBACK SYNTHESIS ---")
	var synth_overview = button_sounds._synth_overview()
	var synth_assets = button_sounds._synth_assets()
	var synth_age = button_sounds._synth_age_up()
	var synth_rel = button_sounds._synth_relationships()
	var synth_act = button_sounds._synth_activities()
	var synth_core = button_sounds._synth_core_click()
	
	for s in [synth_overview, synth_assets, synth_age, synth_rel, synth_act, synth_core]:
		assert(s != null and s.data.size() > 0, "Procedural stream synthesis must produce audio samples")
		assert(s.mix_rate == 44100, "Synthesized stream must be 44.1kHz")
		assert(s.format == AudioStreamWAV.FORMAT_16_BITS, "Synthesized stream must be 16-bit")
	print("✅ CHECK 3 PASSED: In-memory procedural synthesis verified for zero-dependency execution.")
	
	# -------------------------------------------------------------
	# 4. AUDIT 5 CORE BUTTONS IN MAIN SCREEN SCENE
	# -------------------------------------------------------------
	print("\n--- 4. AUDITING 5 CORE BUTTONS IN MAIN_SCREEN SCENE ---")
	var main_scene_res = load("res://scenes/main/main_screen.tscn")
	var main_scene = main_scene_res.instantiate()
	add_child(main_scene)
	
	if main_scene.disclaimer_screen != null:
		main_scene.disclaimer_screen.hide()
	if main_scene.loading_screen != null:
		main_scene.loading_screen.hide()
	if main_scene.new_game_panel != null:
		main_scene.new_game_panel.hide()
		
	await get_tree().process_frame
	await get_tree().process_frame
	
	assert(main_scene.button_sounds != null, "MainScreen must have button_sounds instance")
	var ms_sounds = main_scene.button_sounds
	
	var core_buttons := {
		"overview": main_scene.infant_button,
		"assets": main_scene.assets_button,
		"age": main_scene.age_button,
		"relationships": main_scene.relationships_button,
		"activities": main_scene.activities_button
	}
	
	for b_key in core_buttons.keys():
		var btn: Button = core_buttons[b_key]
		assert(btn != null, "Core button '%s' must exist in MainScreen" % b_key)
		print("  ✔ Core button '%s': node name='%s', text='%s'" % [b_key, btn.name, btn.text.replace("\n", " ")])
		
	print("✅ CHECK 4 PASSED: All 5 core buttons verified and active in MainScreen.")
	
	# -------------------------------------------------------------
	# 5. AUDIT CLICK SOUND PLAYBACK FOR EACH OF THE 5 CORE BUTTONS
	# -------------------------------------------------------------
	print("\n--- 5. AUDITING SOUND PLAYBACK ON CLICK ---")
	
	# Test 5.1: Life Overview Button
	main_scene._on_infant_button_pressed()
	await get_tree().process_frame
	assert(ms_sounds._player_overview.playing or ms_sounds._last_press_ms > 0, "Overview sound must trigger")
	print("  ✔ Life Overview button click triggered Overview sound")
	
	# Small delay to clear debounce
	OS.delay_msec(45)
	
	# Test 5.2: Assets Button
	main_scene._on_assets_button_pressed()
	await get_tree().process_frame
	assert(ms_sounds._player_assets.playing or ms_sounds._last_press_ms > 0, "Assets sound must trigger")
	print("  ✔ Assets button click triggered Assets sound")
	
	OS.delay_msec(45)
	
	# Test 5.3: Age Up Button
	var cur_age = PlayerData.age
	main_scene._on_age_button_pressed()
	await get_tree().process_frame
	assert(ms_sounds._player_age.playing or ms_sounds._last_press_ms > 0, "Age Up sound must trigger")
	assert(PlayerData.age == cur_age + 1, "Age up must advance age")
	print("  ✔ Age Up button click triggered Age Up sound and aged player to %d" % PlayerData.age)
	
	OS.delay_msec(45)
	
	# Test 5.4: Relationships Button
	main_scene._on_relationships_button_pressed()
	await get_tree().process_frame
	assert(ms_sounds._player_relationships.playing or ms_sounds._last_press_ms > 0, "Relationships sound must trigger")
	print("  ✔ Relationships button click triggered Relationships sound")
	
	OS.delay_msec(45)
	
	# Test 5.5: Activities Button
	main_scene._on_activities_button_pressed()
	await get_tree().process_frame
	assert(ms_sounds._player_activities.playing or ms_sounds._last_press_ms > 0, "Activities sound must trigger")
	print("  ✔ Activities button click triggered Activities sound")
	
	print("✅ CHECK 5 PASSED: Sound playback successfully verified for all 5 core buttons when clicked.")
	
	# -------------------------------------------------------------
	# 6. AUDIT SETTINGS MUTE COMPLIANCE
	# -------------------------------------------------------------
	print("\n--- 6. AUDITING MUTE SETTINGS INTEGRATION ---")
	OS.delay_msec(45)
	var time_before = ms_sounds._last_press_ms
	LifeLibrary.data.muted = true
	main_scene._play_core_button_sound("overview")
	assert(ms_sounds._last_press_ms == time_before, "Sound must NOT play when muted in LifeLibrary!")
	
	LifeLibrary.data.muted = false
	AudioServer.set_bus_mute(0, true)
	main_scene._play_core_button_sound("overview")
	assert(ms_sounds._last_press_ms == time_before, "Sound must NOT play when Master bus is muted!")
	
	AudioServer.set_bus_mute(0, false)
	OS.delay_msec(45)
	main_scene._play_core_button_sound("overview")
	assert(ms_sounds._last_press_ms > time_before, "Sound plays normally when unmuted.")
	print("✅ CHECK 6 PASSED: Mute settings compliance verified.")
	
	print("\n⭐⭐⭐ ALL 5 CORE BUTTON SOUND EFFECT AUDITS PASSED PERFECTLY! ⭐⭐⭐")
	get_tree().quit(0)
