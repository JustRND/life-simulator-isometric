class_name AfterlifeMinigame
extends Node

const CreationOptionsRef = preload("res://scripts/core/creation_options.gd")
const NameCatalogRef = preload("res://scripts/core/name_catalog.gd")
const PortraitCatalogRef = preload("res://scripts/core/portrait_catalog.gd")

const DEBUFF_DEFS := {
	"bad_stats": {
		"title": "Diminished Core Attributes",
		"icon": "📉",
		"color": "#ef4444",
		"desc": "Born with frail health and clouded mind. Core stats (Health, Happiness, Smarts, Looks) start severely depleted (15-25%)."
	},
	"random_illness": {
		"title": "Congenital Chronic Illness",
		"icon": "🩺",
		"color": "#f97316",
		"desc": "Afflicted from birth with a severe chronic ailment (Asthma, Heart Defect, or Severe Migraines) requiring lifelong care."
	},
	"poverty": {
		"title": "Crushing Generational Poverty",
		"icon": "💸",
		"color": "#eab308",
		"desc": "Born into severe impoverishment with zero starting cash, no allowances, and struggling guardians."
	},
	"no_parents": {
		"title": "Orphaned at Birth",
		"icon": "🏚️",
		"color": "#a855f7",
		"desc": "Both parents are absent or deceased. Raised alone under austere state foster care."
	},
	"stuck_happiness": {
		"title": "Anhedonia (Stuck Happiness)",
		"icon": "⚡",
		"color": "#ec4899",
		"desc": "A spiritually cursed mind unable to experience joy. Happiness is permanently capped at 15%."
	},
	"health_cap_50": {
		"title": "Frail Vessel (Health Capped at 50%)",
		"icon": "💔",
		"color": "#dc2626",
		"desc": "A structurally damaged mortal form. Maximum health is permanently locked and restricted to 50%."
	},
	"crazy_debt": {
		"title": "Ancestral Debt Burden",
		"icon": "⛓️",
		"color": "#991b1b",
		"desc": "Burdened from youth with $60,000 - $100,000 of inherited ancestral and underworld debt."
	}
}

const BUFF_DEFS := {
	"super_smarts": {
		"title": "Transcendent Genius",
		"icon": "🧠",
		"color": "#38bdf8",
		"desc": "Cosmic enlightenment unlocks your mind. Smarts meter is enlightened and can never drop below 100%!"
	},
	"silver_spoon": {
		"title": "Silver Spoon Legacy",
		"icon": "💎",
		"color": "#22c55e",
		"desc": "Born into profound luxury with an inherited personal trust fund of $100,000 - $150,000!"
	},
	"radiant_vitality": {
		"title": "Radiant Vitality",
		"icon": "❤️",
		"color": "#10b981",
		"desc": "Blessed with an immaculate constitution. Health meter can never fall below 85%!"
	},
	"divine_looks": {
		"title": "Divine Radiance",
		"icon": "✨",
		"color": "#f59e0b",
		"desc": "Radiates unearthly grace and allure. Looks meter can never fall below 90%!"
	},
	"blessed_mind": {
		"title": "Serene Mind",
		"icon": "🧘",
		"color": "#a855f7",
		"desc": "Possesses impenetrable inner peace and emotional fortitude. Happiness can never fall below 80%!"
	},
	"golden_pedigree": {
		"title": "Golden Pedigree",
		"icon": "👑",
		"color": "#eab308",
		"desc": "Born into a high-prestige, loving family of renowned professionals who provide unconditional support."
	}
}

var overlay: ColorRect
var is_condemned: bool = false
var karmic_value: int = 0
var rolled_debuffs: Array = []
var rolled_buffs: Array = []
var reborn_identity: Dictionary = {}
var on_rebirth_callback: Callable

# Nodes for animation and stages
var scale_needle: Label
var scale_status_lbl: Label
var deeds_scroll: VBoxContainer
var verdict_panel: PanelContainer
var weigh_button: Button
var accept_button: Button


static func show_minigame(parent: Node, karma: int, callback: Callable) -> AfterlifeMinigame:
	var mg := AfterlifeMinigame.new()
	mg.name = "AfterlifeMinigame"
	parent.add_child(mg)
	mg.setup(karma, callback)
	return mg


func setup(karma: int, callback: Callable) -> void:
	karmic_value = karma
	is_condemned = (karma < 0)
	on_rebirth_callback = callback

	_roll_modifiers_and_identity()
	_build_ui()


func _roll_modifiers_and_identity() -> void:
	if is_condemned:
		var debuff_keys := DEBUFF_DEFS.keys()
		debuff_keys.shuffle()
		var count := randi_range(1, 3)
		rolled_debuffs = debuff_keys.slice(0, count)
		rolled_buffs = []
	else:
		var buff_keys := BUFF_DEFS.keys()
		buff_keys.shuffle()
		var count := randi_range(1, 3)
		rolled_buffs = buff_keys.slice(0, count)
		rolled_debuffs = []

	# Generate completely randomized character
	var country_entry: Array = CreationOptionsRef.COUNTRIES.pick_random()
	var country_name: String = str(country_entry[0])
	var is_female: bool = (randf() < 0.5)
	var full_name: String = NameCatalogRef.random_name(country_name, is_female)
	var eth: String = PortraitCatalogRef.random_ethnicity_for_country(country_name)
	var p_track: int = randi() % 2
	var p_variant: int = randi() % 5

	reborn_identity = {
		"first_name": full_name,
		"gender": "FEMALE" if is_female else "MALE",
		"birthplace": country_name,
		"ethnicity": eth,
		"portrait_track": p_track,
		"portrait_variant": p_variant
	}


func _build_ui() -> void:
	overlay = ColorRect.new()
	overlay.name = "AfterlifeMinigameOverlay"
	overlay.set_meta("theme_exempt", true)
	set_meta("theme_exempt", true)
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.grow_horizontal = Control.GROW_DIRECTION_BOTH
	overlay.grow_vertical = Control.GROW_DIRECTION_BOTH
	overlay.z_index = 95
	overlay.color = Color(0.015, 0.005, 0.01, 1.0) if is_condemned else Color(0.01, 0.02, 0.04, 1.0)
	add_child(overlay)

	var screen_margin := MarginContainer.new()
	screen_margin.set_meta("theme_exempt", true)
	screen_margin.anchors_preset = Control.PRESET_FULL_RECT
	screen_margin.anchor_right = 1.0
	screen_margin.anchor_bottom = 1.0
	screen_margin.grow_horizontal = Control.GROW_DIRECTION_BOTH
	screen_margin.grow_vertical = Control.GROW_DIRECTION_BOTH
	screen_margin.add_theme_constant_override("margin_left", 36)
	screen_margin.add_theme_constant_override("margin_right", 36)
	screen_margin.add_theme_constant_override("margin_top", 44)
	screen_margin.add_theme_constant_override("margin_bottom", 44)
	overlay.add_child(screen_margin)
	preload("res://scripts/ui/panel_pull_up.gd").watch(screen_margin, overlay)

	var card := PanelContainer.new()
	card.set_meta("theme_exempt", true)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color("#070205") if is_condemned else Color("#050c18")
	card_style.border_color = Color("#dc2626") if is_condemned else Color("#38bdf8")
	card_style.set_border_width_all(3)
	card_style.set_corner_radius_all(16)
	card_style.shadow_color = Color(0, 0, 0, 0.95)
	card_style.shadow_size = 30
	card.add_theme_stylebox_override("panel", card_style)
	screen_margin.add_child(card)

	var card_margin := MarginContainer.new()
	card_margin.set_meta("theme_exempt", true)
	card_margin.add_theme_constant_override("margin_left", 26)
	card_margin.add_theme_constant_override("margin_right", 26)
	card_margin.add_theme_constant_override("margin_top", 24)
	card_margin.add_theme_constant_override("margin_bottom", 24)
	card.add_child(card_margin)

	var main_v := VBoxContainer.new()
	main_v.set_meta("theme_exempt", true)
	main_v.add_theme_constant_override("separation", 16)
	card_margin.add_child(main_v)

	# 1. Header (Fixed at top of modal)
	var title_lbl := Label.new()
	title_lbl.set_meta("reference_part", true)
	title_lbl.text = "⚖️ ASTRAL TRIBUNAL • SCALES OF SAMSARA" if is_condemned else "✨ CELESTIAL HALL • ASCENSION OF SOULS"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 38)
	title_lbl.add_theme_color_override("font_color", Color("#ef4444") if is_condemned else Color("#38bdf8"))
	main_v.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.set_meta("reference_part", true)
	sub_lbl.text = "YOUR MORTAL LIFE HAS ENDED. THE COSMIC ARBITER WEIGHS YOUR EXISTENCE."
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub_lbl.add_theme_font_size_override("font_size", 26)
	sub_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
	main_v.add_child(sub_lbl)

	# 2. ScrollContainer to ensure all content can be scrolled comfortably and never clips
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	main_v.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 16)
	scroll.add_child(vbox)

	# 3. The Interactive Scales of Judgment Card
	var scale_card := PanelContainer.new()
	var sc_style := StyleBoxFlat.new()
	sc_style.bg_color = Color("#090204") if is_condemned else Color("#081528")
	sc_style.border_color = Color("#7f1d1d") if is_condemned else Color("#64748b")
	sc_style.set_border_width_all(2)
	sc_style.set_corner_radius_all(12)
	scale_card.add_theme_stylebox_override("panel", sc_style)
	vbox.add_child(scale_card)

	var sc_margin := MarginContainer.new()
	sc_margin.add_theme_constant_override("margin_left", 20)
	sc_margin.add_theme_constant_override("margin_right", 20)
	sc_margin.add_theme_constant_override("margin_top", 18)
	sc_margin.add_theme_constant_override("margin_bottom", 18)
	scale_card.add_child(sc_margin)

	var sc_v := VBoxContainer.new()
	sc_v.add_theme_constant_override("separation", 14)
	sc_margin.add_child(sc_v)

	var sc_header := Label.new()
	sc_header.set_meta("reference_part", true)
	sc_header.text = "THE SACRED BALANCE OF DEEDS"
	sc_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sc_header.add_theme_font_size_override("font_size", 30)
	sc_header.add_theme_color_override("font_color", Color("#ef4444") if is_condemned else Color("#f59e0b"))
	sc_v.add_child(sc_header)

	# Visual representation of the scale: Two-pan header
	var pans_row := HBoxContainer.new()
	pans_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc_v.add_child(pans_row)

	var left_pan := Label.new()
	left_pan.set_meta("reference_part", true)
	left_pan.text = "⚖️ [ Sins & Transgressions ]"
	left_pan.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_pan.add_theme_font_size_override("font_size", 28)
	left_pan.add_theme_color_override("font_color", Color("#f87171"))
	pans_row.add_child(left_pan)

	var right_pan := Label.new()
	right_pan.set_meta("reference_part", true)
	right_pan.text = "[ Virtues & Merits ] ⚖️"
	right_pan.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right_pan.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_pan.add_theme_font_size_override("font_size", 28)
	right_pan.add_theme_color_override("font_color", Color("#4ade80"))
	pans_row.add_child(right_pan)

	# Dedicated Center Badge for Needle & Tipped Outcome
	var needle_panel := PanelContainer.new()
	var np_style := StyleBoxFlat.new()
	np_style.bg_color = Color("#0e0205") if is_condemned else Color("#0d1e38")
	np_style.border_color = Color("#991b1b") if is_condemned else Color("#475569")
	np_style.set_border_width_all(1)
	np_style.set_corner_radius_all(8)
	needle_panel.add_theme_stylebox_override("panel", np_style)
	sc_v.add_child(needle_panel)

	var npm := MarginContainer.new()
	npm.add_theme_constant_override("margin_left", 12)
	npm.add_theme_constant_override("margin_right", 12)
	npm.add_theme_constant_override("margin_top", 10)
	npm.add_theme_constant_override("margin_bottom", 10)
	needle_panel.add_child(npm)

	scale_needle = Label.new()
	scale_needle.set_meta("reference_part", true)
	scale_needle.text = "• • [ BALANCING ] • •"
	scale_needle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scale_needle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scale_needle.add_theme_font_size_override("font_size", 30)
	scale_needle.add_theme_color_override("font_color", Color("#e2e8f0"))
	npm.add_child(scale_needle)

	scale_status_lbl = Label.new()
	scale_status_lbl.set_meta("reference_part", true)
	scale_status_lbl.text = "Press below to place your mortal soul upon the Scales of Judgment."
	scale_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scale_status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scale_status_lbl.add_theme_font_size_override("font_size", 27)
	scale_status_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
	sc_v.add_child(scale_status_lbl)

	# Weigh Button
	weigh_button = Button.new()
	weigh_button.set_meta("reference_part", true)
	weigh_button.text = "⚖️ WEIGH MORTAL RECORD"
	weigh_button.custom_minimum_size.y = 98
	weigh_button.add_theme_font_size_override("font_size", 34)
	var wb_style := StyleBoxFlat.new()
	wb_style.bg_color = Color("#7f1d1d") if is_condemned else Color("#0284c7")
	wb_style.border_color = Color("#ef4444") if is_condemned else Color("#38bdf8")
	wb_style.set_border_width_all(2)
	wb_style.set_corner_radius_all(10)
	weigh_button.add_theme_stylebox_override("normal", wb_style)
	var wb_hover := wb_style.duplicate() as StyleBoxFlat
	wb_hover.bg_color = wb_style.bg_color.lightened(0.2)
	weigh_button.add_theme_stylebox_override("hover", wb_hover)
	weigh_button.pressed.connect(_on_weigh_pressed)
	sc_v.add_child(weigh_button)

	# 3. Verdict & Rebirth Panel (Initially hidden until scales weighed)
	verdict_panel = PanelContainer.new()
	verdict_panel.visible = false
	var vp_style := StyleBoxFlat.new()
	vp_style.bg_color = Color("#070205") if is_condemned else Color("#07050e")
	vp_style.border_color = Color("#dc2626") if is_condemned else Color("#22c55e")
	vp_style.set_border_width_all(2)
	vp_style.set_corner_radius_all(12)
	verdict_panel.add_theme_stylebox_override("panel", vp_style)
	vbox.add_child(verdict_panel)

	var vp_margin := MarginContainer.new()
	vp_margin.add_theme_constant_override("margin_left", 24)
	vp_margin.add_theme_constant_override("margin_right", 24)
	vp_margin.add_theme_constant_override("margin_top", 20)
	vp_margin.add_theme_constant_override("margin_bottom", 20)
	verdict_panel.add_child(vp_margin)

	var vp_v := VBoxContainer.new()
	vp_v.add_theme_constant_override("separation", 14)
	vp_margin.add_child(vp_v)

	var verdict_title := Label.new()
	verdict_title.set_meta("reference_part", true)
	verdict_title.text = "💀 ARBITER'S VERDICT: CONDEMNED BY KARMIC DEBT" if is_condemned else "🌟 ARBITER'S VERDICT: BLESSED WITH CELESTIAL MERIT"
	verdict_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	verdict_title.add_theme_font_size_override("font_size", 34)
	verdict_title.add_theme_color_override("font_color", Color("#ef4444") if is_condemned else Color("#22c55e"))
	vp_v.add_child(verdict_title)

	var verdict_decree := Label.new()
	verdict_decree.set_meta("reference_part", true)
	if is_condemned:
		verdict_decree.text = "\"Mortal soul, your worldly journey was burdened with dishonor, cruelty, or transgressions. The cosmic balance demands restitution. You are condemned to immediate forced reincarnation burdened with karmic penalties. No appeals are permitted.\""
	else:
		verdict_decree.text = "\"Noble soul, your life resonated with virtue, kindness, and honorable choices. The cosmos rewards spiritual merit. You are granted an auspicious rebirth endowed with celestial blessings.\""
	verdict_decree.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	verdict_decree.add_theme_font_size_override("font_size", 28)
	verdict_decree.add_theme_color_override("font_color", Color("#cbd5e1"))
	vp_v.add_child(verdict_decree)

	# 4. Modifiers (Debuffs or Buffs)
	var mod_header := Label.new()
	mod_header.set_meta("reference_part", true)
	mod_header.text = "⚡ IMPOSED KARMIC PENALTIES:" if is_condemned else "✨ BESTOWED COSMIC BLESSINGS:"
	mod_header.add_theme_font_size_override("font_size", 30)
	mod_header.add_theme_color_override("font_color", Color("#f87171") if is_condemned else Color("#38bdf8"))
	vp_v.add_child(mod_header)

	var active_list: Array = rolled_debuffs if is_condemned else rolled_buffs
	var def_dict: Dictionary = DEBUFF_DEFS if is_condemned else BUFF_DEFS

	for key in active_list:
		var d_info: Dictionary = def_dict.get(key, {})
		var item_card := PanelContainer.new()
		item_card.set_meta("theme_exempt", true)
		var item_style := StyleBoxFlat.new()
		item_style.bg_color = Color("#0c0205") if is_condemned else Color("#091728")
		item_style.border_color = Color(d_info.get("color", "#64748b"))
		item_style.set_border_width_all(2)
		item_style.set_corner_radius_all(8)
		item_card.add_theme_stylebox_override("panel", item_style)

		var im := MarginContainer.new()
		im.set_meta("theme_exempt", true)
		im.add_theme_constant_override("margin_left", 16)
		im.add_theme_constant_override("margin_right", 16)
		im.add_theme_constant_override("margin_top", 12)
		im.add_theme_constant_override("margin_bottom", 12)
		item_card.add_child(im)

		var iv := VBoxContainer.new()
		iv.set_meta("theme_exempt", true)
		iv.add_theme_constant_override("separation", 6)
		im.add_child(iv)

		var item_title := Label.new()
		item_title.set_meta("reference_part", true)
		item_title.text = "%s %s" % [d_info.get("icon", "•"), d_info.get("title", "Effect")]
		item_title.add_theme_font_size_override("font_size", 30)
		item_title.add_theme_color_override("font_color", Color(d_info.get("color", "#f87171")))
		iv.add_child(item_title)

		var item_desc := Label.new()
		item_desc.set_meta("reference_part", true)
		item_desc.text = str(d_info.get("desc", ""))
		item_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		item_desc.add_theme_font_size_override("font_size", 26)
		item_desc.add_theme_color_override("font_color", Color("#cbd5e1"))
		iv.add_child(item_desc)

		vp_v.add_child(item_card)

	# 5. Randomized New Identity Card
	var id_card := PanelContainer.new()
	id_card.set_meta("theme_exempt", true)
	id_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var id_style := StyleBoxFlat.new()
	id_style.bg_color = Color("#070205") if is_condemned else Color("#050f1d")
	id_style.border_color = Color("#dc2626") if is_condemned else Color("#38bdf8")
	id_style.set_border_width_all(2)
	id_style.set_corner_radius_all(10)
	id_card.add_theme_stylebox_override("panel", id_style)
	vp_v.add_child(id_card)

	var idm := MarginContainer.new()
	idm.set_meta("theme_exempt", true)
	idm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	idm.add_theme_constant_override("margin_left", 20)
	idm.add_theme_constant_override("margin_right", 20)
	idm.add_theme_constant_override("margin_top", 16)
	idm.add_theme_constant_override("margin_bottom", 16)
	id_card.add_child(idm)

	var id_row := HBoxContainer.new()
	id_row.set_meta("theme_exempt", true)
	id_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	id_row.add_theme_constant_override("separation", 24)
	idm.add_child(id_row)

	# Avatar Portrait Preview
	var av_rect := TextureRect.new()
	av_rect.set_meta("theme_exempt", true)
	av_rect.custom_minimum_size = Vector2(136, 136)
	av_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	av_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var av_tex: Texture2D = PortraitCatalogRef.get_portrait(
		0, # Infant stage
		str(reborn_identity["gender"]),
		int(reborn_identity["portrait_variant"]),
		str(reborn_identity["ethnicity"])
	)
	av_rect.texture = av_tex
	id_row.add_child(av_rect)

	var id_info_v := VBoxContainer.new()
	id_info_v.set_meta("theme_exempt", true)
	id_info_v.custom_minimum_size.x = 350
	id_info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	id_info_v.add_theme_constant_override("separation", 6)
	id_row.add_child(id_info_v)

	var id_title := Label.new()
	id_title.set_meta("reference_part", true)
	id_title.text = "NEW MORTAL VESSEL (%s)" % ("FORCED REBIRTH" if is_condemned else "BLESSED REBIRTH")
	id_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	id_title.add_theme_font_size_override("font_size", 28)
	id_title.add_theme_color_override("font_color", Color("#fbbf24"))
	id_info_v.add_child(id_title)

	var id_name := Label.new()
	id_name.set_meta("reference_part", true)
	id_name.text = "Name: %s" % str(reborn_identity["first_name"])
	id_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	id_name.add_theme_font_size_override("font_size", 32)
	id_name.add_theme_color_override("font_color", Color("#ffffff"))
	id_info_v.add_child(id_name)

	var id_details := Label.new()
	id_details.set_meta("reference_part", true)
	id_details.text = "Gender: %s   •   Birthplace: %s   •   Ethnicity: %s" % [
		str(reborn_identity["gender"]),
		str(reborn_identity["birthplace"]),
		str(reborn_identity["ethnicity"]).capitalize()
	]
	id_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	id_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	id_details.add_theme_font_size_override("font_size", 28)
	id_details.add_theme_color_override("font_color", Color("#cbd5e1"))
	id_info_v.add_child(id_details)

	var unnegotiable_note := Label.new()
	unnegotiable_note.set_meta("reference_part", true)
	unnegotiable_note.text = "⛔ UNMODIFIABLE & UNNEGOTIABLE: Destiny is sealed by cosmic verdict." if is_condemned else "✨ BLESSED DESTINY: Reborn with auspicious cosmic grace."
	unnegotiable_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	unnegotiable_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	unnegotiable_note.add_theme_font_size_override("font_size", 26)
	unnegotiable_note.add_theme_color_override("font_color", Color("#f87171") if is_condemned else Color("#4ade80"))
	vp_v.add_child(unnegotiable_note)

	# 6. Final Rebirth Action Button
	accept_button = Button.new()
	accept_button.set_meta("reference_part", true)
	accept_button.text = "⚡ ACCEPT FORCED REBIRTH" if is_condemned else "🌟 EMBARK ON BLESSED REBIRTH"
	accept_button.custom_minimum_size.y = 110
	accept_button.add_theme_font_size_override("font_size", 36)
	var ab_style := StyleBoxFlat.new()
	ab_style.bg_color = Color("#7f1d1d") if is_condemned else Color("#15803d")
	ab_style.border_color = Color("#ef4444") if is_condemned else Color("#22c55e")
	ab_style.set_border_width_all(3)
	ab_style.set_corner_radius_all(12)
	accept_button.add_theme_stylebox_override("normal", ab_style)
	var ab_hover := ab_style.duplicate() as StyleBoxFlat
	ab_hover.bg_color = ab_style.bg_color.lightened(0.2)
	accept_button.add_theme_stylebox_override("hover", ab_hover)
	accept_button.visible = false
	accept_button.pressed.connect(_on_accept_rebirth_pressed)
	vbox.add_child(accept_button)


func _on_weigh_pressed() -> void:
	weigh_button.disabled = true
	weigh_button.text = "⏳ WEIGHING DEEDS..."

	# Animate the scales tipping
	var tween := create_tween()
	scale_needle.text = "⚖️ • • EVALUATING SINS & VIRTUES • • ⚖️"

	tween.tween_property(scale_needle, "modulate:a", 0.4, 0.4)
	tween.tween_property(scale_needle, "modulate:a", 1.0, 0.4)
	tween.tween_callback(Callable(self, "_finish_weighing"))


func _finish_weighing() -> void:
	if is_condemned:
		scale_needle.text = "⬅️ 💀 TIPPED: RETRIBUTION & CONDEMNATION"
		scale_needle.add_theme_color_override("font_color", Color("#ef4444"))
		scale_status_lbl.text = "The scales crash under the heavy burden of worldly misdeeds."
	else:
		scale_needle.text = "🌟 TIPPED: HARMONIC ASCENSION ➡️"
		scale_needle.add_theme_color_override("font_color", Color("#22c55e"))
		scale_status_lbl.text = "The scales elevate gracefully with the light of earthly merit and virtues."

	weigh_button.visible = false
	verdict_panel.visible = true
	accept_button.visible = true


func _on_accept_rebirth_pressed() -> void:
	# Start reincarnated life
	PlayerData.start_reincarnated_life(reborn_identity, rolled_debuffs, rolled_buffs)

	if on_rebirth_callback.is_valid():
		on_rebirth_callback.call()

	overlay.queue_free()
	queue_free()
