class_name NeuralCatalog
extends RefCounted

## Catalog and configuration for Neural Specialist modifications, AI brain chips, and neuro-implants.

const SLOTS: Dictionary = {
	"cortex": {
		"id": "cortex",
		"name": "Cerebral Cortex Co-Processor",
		"icon": "🧠",
		"description": "Primary neural socket interfacing AI chips directly with executive reasoning and computational synapses."
	},
	"memory": {
		"id": "memory",
		"name": "Hippocampal Memory Matrix",
		"icon": "💾",
		"description": "Deep-crystal cognitive storage unit for photographic recall, linguistic models, and mental acceleration."
	},
	"sensory": {
		"id": "sensory",
		"name": "Ocular & Sensory Array",
		"icon": "👁️",
		"description": "Direct optic and synaptic links augmenting perception, reflexive timing, and visual diagnostics."
	},
	"bio_reg": {
		"id": "bio_reg",
		"name": "Autonomic Bio-Regulator",
		"icon": "🧬",
		"description": "Hypothalamic nanite valve stabilizing emotional chemistry, cellular regeneration, and physical vitality."
	},
	"interface": {
		"id": "interface",
		"name": "Sub-Neural Digital Interface",
		"icon": "🌐",
		"description": "High-frequency cybernetic uplink connecting consciousness to decentralized financial networks and data streams."
	}
}

const CATEGORIES: Array[Dictionary] = [
	{
		"id": "ai_chips",
		"name": "AI BRAIN CHIPS",
		"icon": "🤖",
		"color": "#06b6d4",
		"description": "Cortical processors running autonomous machine intelligence directly inside your neural pathways."
	},
	{
		"id": "cognitive",
		"name": "MEMORY & COGNITION",
		"icon": "💾",
		"color": "#3b82f6",
		"description": "Photographic recall units, optical data storage, and multilingual semantic processors."
	},
	{
		"id": "sensory",
		"name": "SENSORY & OCULAR",
		"icon": "👁️",
		"color": "#a855f7",
		"description": "Cybernetic ocular HUDs, micro-expression telemetry, and sub-millisecond synaptic overclocking."
	},
	{
		"id": "bio_reg",
		"name": "BIO-REGULATORS",
		"icon": "🧬",
		"color": "#10b981",
		"description": "Nanite bio-scaffolds, homeostatic cortisol shields, and endorphin neurochemical stabilizers."
	},
	{
		"id": "interface",
		"name": "DIGITAL INTERFACES",
		"icon": "🌐",
		"color": "#f59e0b",
		"description": "Direct high-frequency trading uplinks, encrypted consciousness backups, and quantum networks."
	}
]

const MODIFICATIONS: Array[Dictionary] = [
	# --- AI BRAIN CHIPS ---
	{
		"id": "cortex_neurolink_mk1",
		"name": "NeuroLink Mk.I Cortex Coprocessor",
		"icon": "🧠",
		"slot": "cortex",
		"category": "ai_chips",
		"price": 1500000,
		"annual_maintenance": 45000,
		"min_age": 18,
		"description": "Subdermal carbon-nanotube neural mesh running an on-chip LLM co-pilot. Sharpens executive logic, comprehension speed, and cognitive reflex.",
		"perk_title": "Neural Co-Pilot",
		"perk_summary": "+25 Smarts, +10 Mental State, +5 Happiness. Accelerates learning and freelance project output.",
		"stat_boosts": {
			"smarts": 25,
			"mental_state": 10,
			"happiness": 5
		}
	},
	{
		"id": "cortex_omnimind_quantum",
		"name": "OmniMind Quantum Deep Neural Core",
		"icon": "🤖",
		"slot": "cortex",
		"category": "ai_chips",
		"price": 4500000,
		"annual_maintenance": 125000,
		"min_age": 18,
		"description": "Cryo-stabilized quantum neural processing unit interfacing directly with your neocortex. Runs real-time predictive simulations across millions of synapses.",
		"perk_title": "Quantum Calculation",
		"perk_summary": "Smarts permanently maximized to 100%. +25 Mental State, +15 Health. Boosts salary and business performance by +20%.",
		"stat_boosts": {
			"smarts": 40,
			"mental_state": 25,
			"health": 15
		},
		"locks_max_smarts": true
	},
	{
		"id": "cortex_singularity_mesh",
		"name": "Singularity-7 Autonomous AGI Mesh",
		"icon": "✨",
		"slot": "cortex",
		"category": "ai_chips",
		"price": 12500000,
		"annual_maintenance": 350000,
		"min_age": 18,
		"description": "The absolute zenith of cybernetic consciousness. Fuses an autonomous self-evolving Artificial General Intelligence shard directly into cerebral hemispheres.",
		"perk_title": "Omniscience Protocol",
		"perk_summary": "Locks Smarts and Mental State at 100%. +20 Happiness, +20 Health. Grants massive dividends to business and crypto/stock insights.",
		"stat_boosts": {
			"smarts": 50,
			"mental_state": 50,
			"happiness": 20,
			"health": 20
		},
		"locks_max_smarts": true,
		"locks_max_mental_state": true
	},

	# --- MEMORY & COGNITION ---
	{
		"id": "memory_eidetic_matrix",
		"name": "Eidetic Chrono-Memory Matrix",
		"icon": "💾",
		"slot": "memory",
		"category": "cognitive",
		"price": 2200000,
		"annual_maintenance": 60000,
		"min_age": 18,
		"description": "High-density optical-crystal flash storage integrated with the hippocampus. Provides photographic recall of every study material, event, and book.",
		"perk_title": "Total Recall",
		"perk_summary": "+20 Smarts, +15 Mental State. Guarantees 100% pass on university degrees & exams; prevents age-related smarts decay.",
		"stat_boosts": {
			"smarts": 20,
			"mental_state": 15
		},
		"prevents_smarts_decay": true
	},
	{
		"id": "memory_neuro_polyglot",
		"name": "Polyglot Semantic Neuro-Linguist",
		"icon": "🗣️",
		"slot": "memory",
		"category": "cognitive",
		"price": 2900000,
		"annual_maintenance": 75000,
		"min_age": 18,
		"description": "Deep-neural language decoder storing acoustic and grammatical models for all global tongues, dialects, and digital protocols.",
		"perk_title": "Universal Eloquence",
		"perk_summary": "+18 Smarts, +15 Looks (Charisma), +15 Happiness. Unlocks +30% relationship gains with all contacts and business partners.",
		"stat_boosts": {
			"smarts": 18,
			"looks": 15,
			"happiness": 15
		}
	},

	# --- SENSORY & OCULAR ---
	{
		"id": "sensory_argus_hud",
		"name": "Argus-IV Cybernetic Retinal HUD",
		"icon": "👁️",
		"slot": "sensory",
		"category": "sensory",
		"price": 1800000,
		"annual_maintenance": 50000,
		"min_age": 18,
		"description": "Optic-nerve micro-projector displaying a real-time cybernetic HUD with biometric diagnostics, emotional aura detection, and facial recognition.",
		"perk_title": "Optic Telemetry",
		"perk_summary": "+20 Looks, +15 Smarts, +10 Mental State. Heightens charm, aesthetic elegance, and social interaction outcomes.",
		"stat_boosts": {
			"looks": 20,
			"smarts": 15,
			"mental_state": 10
		}
	},
	{
		"id": "sensory_synapse_overclock",
		"name": "Synaptic Reflex Overclocker",
		"icon": "⚡",
		"slot": "sensory",
		"category": "sensory",
		"price": 3600000,
		"annual_maintenance": 95000,
		"min_age": 18,
		"description": "Superconducting micro-wiring bypassing biological signal delays, multiplying sensory reaction time and motor coordination tenfold.",
		"perk_title": "Sub-Millisecond Reflexes",
		"perk_summary": "+20 Health, +15 Smarts, +15 Happiness. Dramatically reduces odds of injury in vehicular accidents or dangerous incidents.",
		"stat_boosts": {
			"health": 20,
			"smarts": 15,
			"happiness": 15
		}
	},

	# --- BIO-NEUROLOGICAL REGULATORS ---
	{
		"id": "reg_soma_guard",
		"name": "Soma-Guard Autonomic Neuro-Regulator",
		"icon": "🛡️",
		"slot": "bio_reg",
		"category": "bio_reg",
		"price": 2800000,
		"annual_maintenance": 80000,
		"min_age": 18,
		"description": "Endocrine bio-nanite monitor embedded in the hypothalamus. Automatically dampens stress cortisol, balances hormones, and enhances immune resistance.",
		"perk_title": "Homeostatic Shield",
		"perk_summary": "+25 Health, +25 Mental State. Slows biological aging degradation and grants immunity to mental breakdowns.",
		"stat_boosts": {
			"health": 25,
			"mental_state": 25
		},
		"stress_immunity": true
	},
	{
		"id": "reg_euphoria_core",
		"name": "Euphoria-Core Serotonin Synthesizer",
		"icon": "💖",
		"slot": "bio_reg",
		"category": "bio_reg",
		"price": 3400000,
		"annual_maintenance": 90000,
		"min_age": 18,
		"description": "Precision neurochemical infusion valve regulating dopamine and endorphin flow to maintain peak inner joy and emotional invulnerability.",
		"perk_title": "Serenity Equilibrium",
		"perk_summary": "+35 Happiness, +20 Mental State. Happiness is safeguarded above 75% as long as chip is active and maintained.",
		"stat_boosts": {
			"happiness": 35,
			"mental_state": 20
		},
		"min_happiness_floor": 75
	},
	{
		"id": "reg_biopump_regenerator",
		"name": "Cellular Neuro-Regenerator Biopump",
		"icon": "🧬",
		"slot": "bio_reg",
		"category": "bio_reg",
		"price": 5500000,
		"annual_maintenance": 160000,
		"min_age": 18,
		"description": "Spinal stem-cell micro-fabricator that continuously repairs damaged neurons, heart tissue, and cellular mitochondria using synthetic bio-scaffolds.",
		"perk_title": "Vital Nanite Healing",
		"perk_summary": "+35 Health, +15 Mental State. Restores +8 Health automatically every year and grants high resistance to malignant illnesses.",
		"stat_boosts": {
			"health": 35,
			"mental_state": 15
		},
		"yearly_health_regen": 8
	},

	# --- DIGITAL INTERFACES ---
	{
		"id": "interface_neuro_broker",
		"name": "Cranial High-Frequency Neuro-Broker",
		"icon": "📈",
		"slot": "interface",
		"category": "interface",
		"price": 4800000,
		"annual_maintenance": 140000,
		"min_age": 18,
		"description": "Sub-millisecond optical interface linking synapses directly into worldwide stock and crypto exchanges and liquidity networks.",
		"perk_title": "Market Foresight",
		"perk_summary": "+20 Smarts, +15 Mental State. Increases capital gains and annual financial investment yields by +25%.",
		"stat_boosts": {
			"smarts": 20,
			"mental_state": 15
		},
		"financial_yield_boost": 0.25
	},
	{
		"id": "interface_ghost_net",
		"name": "Ghost-Net Sub-Neural Cloud Vault",
		"icon": "🌐",
		"slot": "interface",
		"category": "interface",
		"price": 7200000,
		"annual_maintenance": 210000,
		"min_age": 18,
		"description": "Quantum-encrypted satellite uplink that mirrors consciousness data continuously to off-planet vaults, guaranteeing psychological transcendence.",
		"perk_title": "Digital Transcendence",
		"perk_summary": "+20 Smarts, +25 Mental State, +20 Happiness. Immense psychological tranquility, +20 Karma, and legacy estate prestige.",
		"stat_boosts": {
			"smarts": 20,
			"mental_state": 25,
			"happiness": 20
		}
	}
]

static func get_all_modifications() -> Array[Dictionary]:
	return MODIFICATIONS

static func get_modification(mod_id: String) -> Dictionary:
	for m in MODIFICATIONS:
		if m.get("id", "") == mod_id:
			return m
	return {}

static func get_modifications_by_slot(slot: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for m in MODIFICATIONS:
		if m.get("slot", "") == slot:
			result.append(m)
	return result

static func get_modifications_by_category(category: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for m in MODIFICATIONS:
		if m.get("category", "") == category:
			result.append(m)
	return result

static func get_slot_info(slot: String) -> Dictionary:
	return SLOTS.get(slot, {
		"id": slot,
		"name": "Neural Socket",
		"icon": "🧠",
		"description": "Cerebral interface socket."
	})
