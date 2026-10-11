@tool
extends SceneTree

const AvatarRegistry = preload("res://scripts/core/avatar_registry.gd")
const CreationOptions = preload("res://scripts/core/creation_options.gd")

func _init() -> void:
	print("--- TESTING AVATAR REGISTRY ---")
	var f_count := AvatarRegistry.get_teen_count("FEMALE")
	var m_count := AvatarRegistry.get_teen_count("MALE")
	print("Female teen count: %d, Male teen count: %d" % [f_count, m_count])
	assert(f_count == 32, "Female teen count must be 32")
	assert(m_count == 64, "Male teen count must be 64")

	for i in range(f_count):
		var tex := AvatarRegistry.get_teen_texture("FEMALE", i)
		assert(tex != null, "Female teen %d texture must exist" % i)

	for i in range(m_count):
		var tex := AvatarRegistry.get_teen_texture("MALE", i)
		assert(tex != null, "Male teen %d texture must exist" % i)

	for country in CreationOptions.get_all_country_names():
		var def_f_idx := AvatarRegistry.get_default_teen_index(country, "FEMALE")
		var def_m_idx := AvatarRegistry.get_default_teen_index(country, "MALE")
		assert(def_f_idx >= 0 and def_f_idx < f_count, "Default female teen index out of range for " + country)
		assert(def_m_idx >= 0 and def_m_idx < m_count, "Default male teen index out of range for " + country)

	var tex_by_id := AvatarRegistry.get_texture_by_id("teen_female_10")
	assert(tex_by_id != null, "Texture by ID must load")

	print("AVATAR REGISTRY TEST PASSED!")
	quit(0)
