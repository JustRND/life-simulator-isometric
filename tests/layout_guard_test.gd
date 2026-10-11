extends Node

func _ready() -> void:
	var compact_value := Label.new()
	compact_value.custom_minimum_size = Vector2(80, 0)
	LayoutGuard.configure_compact_label(compact_value, 140)
	assert(compact_value.autowrap_mode == TextServer.AUTOWRAP_OFF)
	assert(compact_value.size_flags_horizontal == Control.SIZE_SHRINK_END)
	assert(is_equal_approx(compact_value.custom_minimum_size.x, 140.0))

	var action := Button.new()
	LayoutGuard.configure_action_button(action)
	assert(action.size_flags_horizontal == Control.SIZE_EXPAND_FILL)
	assert(action.custom_minimum_size.x >= LayoutGuard.STANDARD_ACTION_MIN_WIDTH)
	assert(action.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART)

	var avatar := TextureRect.new()
	LayoutGuard.configure_compact_avatar(avatar, 112)
	assert(avatar.size_flags_horizontal == Control.SIZE_SHRINK_BEGIN)
	assert(is_equal_approx(avatar.custom_minimum_size.x, 112.0))

	print("LAYOUT_GUARD_TEST_PASSED")
	get_tree().quit(0)
