class_name AssetCatalog
extends RefCounted

const CATEGORY_BICYCLES := "bicycles"
const CATEGORY_CARS := "cars"
const CATEGORY_MOTORCYCLES := "motorcycles"
const CATEGORY_JEWELRY := "jewelry"
const CATEGORY_INSTRUMENTS := "instruments"
const CATEGORY_PROPERTIES := "properties"
const CATEGORY_AIRCRAFT := "aircraft"
const CATEGORY_YACHTS := "yachts"
const CATEGORY_FIREARMS := "firearms"

const ITEMS := {
	# =========================================================================
	# 🚗 16 CARS
	# =========================================================================
	"car_rustbucket": {
		"id": "car_rustbucket",
		"category": CATEGORY_CARS,
		"name": "Rustbucket Beater '88",
		"price": 1400,
		"upkeep": 190,
		"happiness_bonus": 3,
		"desc": "A faded, dented retro hatchback with rusted wheel arches. It barely starts on cold mornings, but it's completely yours.",
		"image_path": "res://assets/items/cars/car_rustbucket.jpg",
		"min_age": 16
	},
	"car_moped_car": {
		"id": "car_moped_car",
		"category": CATEGORY_CARS,
		"name": "Micro Commuter Pod",
		"price": 3800,
		"upkeep": 300,
		"happiness_bonus": 5,
		"desc": "A tiny 2-seater bubble city car in sunny yellow. Squeezes into impossible parking spots with unmatched efficiency.",
		"image_path": "res://assets/items/cars/car_moped_car.jpg",
		"min_age": 16
	},
	"car_hatchback": {
		"id": "car_hatchback",
		"category": CATEGORY_CARS,
		"name": "Cyber Hatchback '98",
		"price": 7700,
		"upkeep": 610,
		"happiness_bonus": 7,
		"desc": "A trusty Japanese-style retro 5-door runabout. Affordable, fuel-efficient, and easy to maintain.",
		"image_path": "res://assets/items/cars/car_hatchback.jpg",
		"min_age": 16
	},
	"car_wagon": {
		"id": "car_wagon",
		"category": CATEGORY_CARS,
		"name": "Nordic Station Wagon",
		"price": 13600,
		"upkeep": 1000,
		"happiness_bonus": 9,
		"desc": "A sturdy, boxy 90s family estate wagon with roof rails. Practical, reliable, and seats five comfortably.",
		"image_path": "res://assets/items/cars/car_wagon.jpg",
		"min_age": 16
	},
	"car_pickup": {
		"id": "car_pickup",
		"category": CATEGORY_CARS,
		"name": "Atlas Workhorse Pickup",
		"price": 20000,
		"upkeep": 1400,
		"happiness_bonus": 11,
		"desc": "A heavy-duty classic red steel utility pickup with chrome bumpers. Can haul concrete or tow a trailer effortlessly.",
		"image_path": "res://assets/items/cars/car_pickup.jpg",
		"min_age": 16
	},
	"car_sedan": {
		"id": "car_sedan",
		"category": CATEGORY_CARS,
		"name": "Neo City Sedan",
		"price": 30000,
		"upkeep": 1900,
		"happiness_bonus": 13,
		"desc": "A sleek, whisper-quiet electric commuter sedan with autonomous cruise and neon cyan trim.",
		"image_path": "res://assets/items/cars/car_sedan.jpg",
		"min_age": 16
	},
	"car_ev_compact": {
		"id": "car_ev_compact",
		"category": CATEGORY_CARS,
		"name": "Volt Eco-Runner",
		"price": 44800,
		"upkeep": 1500,
		"happiness_bonus": 15,
		"desc": "A modern aerodynamic electric hatchback with pearl white paint and illuminated LED accent lights.",
		"image_path": "res://assets/items/cars/car_ev_compact.jpg",
		"min_age": 16
	},
	"car_coupe": {
		"id": "car_coupe",
		"category": CATEGORY_CARS,
		"name": "Kuro 240 Sport Coupe",
		"price": 57600,
		"upkeep": 2600,
		"happiness_bonus": 18,
		"desc": "A legendary 90s JDM street tuner with iconic pop-up headlights, bronze alloy rims, and responsive handling.",
		"image_path": "res://assets/items/cars/car_coupe.jpg",
		"min_age": 18
	},
	"car_muscle": {
		"id": "car_muscle",
		"category": CATEGORY_CARS,
		"name": "V8 Iron Stallion",
		"price": 83200,
		"upkeep": 3800,
		"happiness_bonus": 22,
		"desc": "An aggressive American roaring muscle coupe with classic white racing stripes, chrome mag wheels, and thunderous torque.",
		"image_path": "res://assets/items/cars/car_muscle.jpg",
		"min_age": 18
	},
	"car_offroad": {
		"id": "car_offroad",
		"category": CATEGORY_CARS,
		"name": "Titan 4x4 Overland SUV",
		"price": 109000,
		"upkeep": 5100,
		"happiness_bonus": 24,
		"desc": "A lifted overland exploration truck with massive all-terrain knobby tires, bull bar, snorkel, and rooftop LED lightbar.",
		"image_path": "res://assets/items/cars/car_offroad.jpg",
		"min_age": 18
	},
	"car_executive": {
		"id": "car_executive",
		"category": CATEGORY_CARS,
		"name": "Aethelgard Executive Saloon",
		"price": 152000,
		"upkeep": 7700,
		"happiness_bonus": 27,
		"desc": "An elite obsidian black luxury stretch sedan. Acoustic soundproof glass, handcrafted walnut dash, and supreme prestige.",
		"image_path": "res://assets/items/cars/car_executive.jpg",
		"min_age": 18
	},
	"car_ev_luxury": {
		"id": "car_ev_luxury",
		"category": CATEGORY_CARS,
		"name": "Zephyr Cyber Sedan GT",
		"price": 216000,
		"upkeep": 8300,
		"happiness_bonus": 30,
		"desc": "A cutting-edge luxury EV with a full panoramic glass roof, glowing cybernetic underglow, and autopilot navigation.",
		"image_path": "res://assets/items/cars/car_ev_luxury.jpg",
		"min_age": 18
	},
	"car_grand_tourer": {
		"id": "car_grand_tourer",
		"category": CATEGORY_CARS,
		"name": "Monaco GT Coupe",
		"price": 384000,
		"upkeep": 19200,
		"happiness_bonus": 33,
		"desc": "A prestigious British-style grand touring coupe in polished liquid silver. High-speed continental cruising with bespoke leather.",
		"image_path": "res://assets/items/cars/car_grand_tourer.jpg",
		"min_age": 18
	},
	"car_sportscar": {
		"id": "car_sportscar",
		"category": CATEGORY_CARS,
		"name": "Apex GT Supercar",
		"price": 672000,
		"upkeep": 28800,
		"happiness_bonus": 36,
		"desc": "A blistering twin-turbo mid-engine supercar in fiery crimson. Turns heads and shatters 0-60 acceleration records.",
		"image_path": "res://assets/items/cars/car_sportscar.jpg",
		"min_age": 18
	},
	"car_hypercar": {
		"id": "car_hypercar",
		"category": CATEGORY_CARS,
		"name": "Valkyrie Phantom V12",
		"price": 2960000,
		"upkeep": 72000,
		"happiness_bonus": 42,
		"desc": "An exotic aerodynamic stealth hypercar in matte black and neon violet. Active aero wing, scissor doors, and 1,100 HP.",
		"image_path": "res://assets/items/cars/car_hypercar.jpg",
		"min_age": 21
	},
	"car_prototype": {
		"id": "car_prototype",
		"category": CATEGORY_CARS,
		"name": "Orbital Mag-Drive Prototype",
		"price": 5600000,
		"upkeep": 136000,
		"happiness_bonus": 50,
		"desc": "A one-of-a-kind concept vehicle engineered with carbon-fiber weave and magnetic induction drive. The pinnacle of automotive status.",
		"image_path": "res://assets/items/cars/car_prototype.jpg",
		"min_age": 21
	},

	# =========================================================================
	# 🏍️ 16 MOTORCYCLES
	# =========================================================================
	"moto_moped": {
		"id": "moto_moped",
		"category": CATEGORY_MOTORCYCLES,
		"name": "Rusty 50cc Moped",
		"price": 720,
		"upkeep": 96,
		"happiness_bonus": 3,
		"desc": "A weathered, rusted vintage commuter moped with a front wire basket. Putters along city back alleys at a relaxed pace.",
		"image_path": "res://assets/items/motorcycles/moto_moped.jpg",
		"min_age": 14
	},
	"moto_scooter": {
		"id": "moto_scooter",
		"category": CATEGORY_MOTORCYCLES,
		"name": "Vespa Mint 50cc",
		"price": 2200,
		"upkeep": 240,
		"happiness_bonus": 5,
		"desc": "A charming mint-green city scooter. Zips through congested city traffic with vintage Italian flair.",
		"image_path": "res://assets/items/motorcycles/moto_scooter.jpg",
		"min_age": 15
	},
	"moto_e_scooter": {
		"id": "moto_e_scooter",
		"category": CATEGORY_MOTORCYCLES,
		"name": "Volt Urban E-Glide",
		"price": 4200,
		"upkeep": 290,
		"happiness_bonus": 7,
		"desc": "A sleek modern electric urban scooter with cyan neon accent lights and zero emissions.",
		"image_path": "res://assets/items/motorcycles/moto_e_scooter.jpg",
		"min_age": 15
	},
	"moto_dirtbike": {
		"id": "moto_dirtbike",
		"category": CATEGORY_MOTORCYCLES,
		"name": "MudSlinger 250 Enduro",
		"price": 7200,
		"upkeep": 510,
		"happiness_bonus": 9,
		"desc": "A high-clearance off-road motocross bike with knobby dirt tires and bright orange plastics. Conquers trails and gravel.",
		"image_path": "res://assets/items/motorcycles/moto_dirtbike.jpg",
		"min_age": 16
	},
	"moto_cafe_racer": {
		"id": "moto_cafe_racer",
		"category": CATEGORY_MOTORCYCLES,
		"name": "Ace Vintage Cafe Racer",
		"price": 11500,
		"upkeep": 770,
		"happiness_bonus": 12,
		"desc": "A stripped-down retro racer with clip-on handlebars, round headlight, and polished chrome fuel tank.",
		"image_path": "res://assets/items/motorcycles/moto_cafe_racer.jpg",
		"min_age": 16
	},
	"moto_scrambler": {
		"id": "moto_scrambler",
		"category": CATEGORY_MOTORCYCLES,
		"name": "Desert Nomad Scrambler",
		"price": 14700,
		"upkeep": 900,
		"happiness_bonus": 14,
		"desc": "A rugged classic dual-sport bike with ribbed leather bench seat, wire wheels, and high-mounted scrambler exhaust.",
		"image_path": "res://assets/items/motorcycles/moto_scrambler.jpg",
		"min_age": 16
	},
	"moto_naked_bike": {
		"id": "moto_naked_bike",
		"category": CATEGORY_MOTORCYCLES,
		"name": "Shadow 400 Streetfighter",
		"price": 18400,
		"upkeep": 1100,
		"happiness_bonus": 16,
		"desc": "An aggressive naked street bike with neon lime exposed trellis frame and dual projector headlights.",
		"image_path": "res://assets/items/motorcycles/moto_naked_bike.jpg",
		"min_age": 16
	},
	"moto_cruiser": {
		"id": "moto_cruiser",
		"category": CATEGORY_MOTORCYCLES,
		"name": "Thunder Chopper V-Twin",
		"price": 21600,
		"upkeep": 1300,
		"happiness_bonus": 18,
		"desc": "Heavy chrome, a rumbling twin engine, and tall ape-hangers. The quintessential sound of the open road.",
		"image_path": "res://assets/items/motorcycles/moto_cruiser.jpg",
		"min_age": 16
	},
	"moto_touring": {
		"id": "moto_touring",
		"category": CATEGORY_MOTORCYCLES,
		"name": "Cross-Continent Tourer",
		"price": 28000,
		"upkeep": 1500,
		"happiness_bonus": 20,
		"desc": "A long-haul highway cruiser with aerodynamic windshield, heated grips, and lockable hard saddlebags.",
		"image_path": "res://assets/items/motorcycles/moto_touring.jpg",
		"min_age": 18
	},
	"moto_sportbike": {
		"id": "moto_sportbike",
		"category": CATEGORY_MOTORCYCLES,
		"name": "Ninja Pulse 600R",
		"price": 33600,
		"upkeep": 1900,
		"happiness_bonus": 22,
		"desc": "A razor-sharp supersport track motorcycle with race fairings and screaming high-RPM inline-four engine.",
		"image_path": "res://assets/items/motorcycles/moto_sportbike.jpg",
		"min_age": 18
	},
	"moto_bobber": {
		"id": "moto_bobber",
		"category": CATEGORY_MOTORCYCLES,
		"name": "Blackout Custom Bobber",
		"price": 40000,
		"upkeep": 2200,
		"happiness_bonus": 24,
		"desc": "A slammed custom bobber in matte black with brass detailing and a solo leather spring saddle.",
		"image_path": "res://assets/items/motorcycles/moto_bobber.jpg",
		"min_age": 18
	},
	"moto_kusanagi": {
		"id": "moto_kusanagi",
		"category": CATEGORY_MOTORCYCLES,
		"name": "Kusanagi RX-9 Sportbike",
		"price": 54400,
		"upkeep": 3500,
		"happiness_bonus": 28,
		"desc": "A legendary cyber-racing machine in glowing crimson and neon cyan. Extreme cornering stability and carbon chassis.",
		"image_path": "res://assets/items/motorcycles/moto_kusanagi.jpg",
		"min_age": 18
	},
	"moto_adventure": {
		"id": "moto_adventure",
		"category": CATEGORY_MOTORCYCLES,
		"name": "Dakar Rally Explorer 1200",
		"price": 70400,
		"upkeep": 4200,
		"happiness_bonus": 30,
		"desc": "A heavyweight globetrotting adventure motorcycle with reinforced crash bars and aluminum expedition boxes.",
		"image_path": "res://assets/items/motorcycles/moto_adventure.jpg",
		"min_age": 18
	},
	"moto_drag_bike": {
		"id": "moto_drag_bike",
		"category": CATEGORY_MOTORCYCLES,
		"name": "Nitro Hellcat Drag Bike",
		"price": 92800,
		"upkeep": 6100,
		"happiness_bonus": 34,
		"desc": "A supercharged drag motorcycle with stretched swingarm, wide rear racing slick, and hotrod flame livery.",
		"image_path": "res://assets/items/motorcycles/moto_drag_bike.jpg",
		"min_age": 18
	},
	"moto_superbike": {
		"id": "moto_superbike",
		"category": CATEGORY_MOTORCYCLES,
		"name": "Corse V4 Carbon Superbike",
		"price": 232000,
		"upkeep": 15200,
		"happiness_bonus": 38,
		"desc": "A hand-built Italian masterpiece with full dry-carbon bodywork and titanium exhaust. Pure racing adrenaline.",
		"image_path": "res://assets/items/motorcycles/moto_superbike.jpg",
		"min_age": 21
	},
	"moto_cyber_hover": {
		"id": "moto_cyber_hover",
		"category": CATEGORY_MOTORCYCLES,
		"name": "Neo-Tokyo Akuma Cyberbike",
		"price": 512000,
		"upkeep": 28800,
		"happiness_bonus": 45,
		"desc": "A breathtaking cyberpunk street machine with illuminated hubless wheels and electromagnetic drive.",
		"image_path": "res://assets/items/motorcycles/moto_cyber_hover.jpg",
		"min_age": 21
	},

	# =========================================================================
	# 🏠 16 PROPERTIES
	# =========================================================================
	"prop_capsule": {
		"id": "prop_capsule",
		"category": CATEGORY_PROPERTIES,
		"name": "Cozy Starter Home",
		"price": 220000,
		"upkeep": 4400,
		"happiness_bonus": 6,
		"desc": "A charming single-story starter house with a welcoming front porch, neat lawn, and warm glowing windows—perfect for humble beginnings.",
		"image_path": "res://assets/items/properties/prop_starter_home.jpg",
		"min_age": 18
	},
	"prop_tenement": {
		"id": "prop_tenement",
		"category": CATEGORY_PROPERTIES,
		"name": "Old District Tenement Flat",
		"price": 380000,
		"upkeep": 7600,
		"happiness_bonus": 8,
		"desc": "A historic red brick apartment above a bustling noodle shop with classic exterior iron fire escapes.",
		"image_path": "res://assets/items/properties/prop_tenement.jpg",
		"min_age": 18
	},
	"prop_studio": {
		"id": "prop_studio",
		"category": CATEGORY_PROPERTIES,
		"name": "Downtown Studio Loft",
		"price": 650000,
		"upkeep": 13000,
		"happiness_bonus": 12,
		"desc": "A vibrant modern loft situated above late-night ramen spots and illuminated cyber storefronts.",
		"image_path": "res://assets/items/properties/prop_studio.jpg",
		"min_age": 18
	},
	"prop_condo": {
		"id": "prop_condo",
		"category": CATEGORY_PROPERTIES,
		"name": "Neon Heights 1-Bedroom Condo",
		"price": 980000,
		"upkeep": 19600,
		"happiness_bonus": 15,
		"desc": "A sleek high-rise condo featuring a private glass balcony overlooking the sparkling metropolis night skyline.",
		"image_path": "res://assets/items/properties/prop_condo.jpg",
		"min_age": 18
	},
	"prop_cottage": {
		"id": "prop_cottage",
		"category": CATEGORY_PROPERTIES,
		"name": "Sunnyvale Starter Cottage",
		"price": 1450000,
		"upkeep": 29000,
		"happiness_bonus": 18,
		"desc": "A storybook suburban cottage with stone chimney, white picket fence, flower garden, and peaceful surroundings.",
		"image_path": "res://assets/items/properties/prop_cottage.jpg",
		"min_age": 18
	},
	"prop_suburban_split": {
		"id": "prop_suburban_split",
		"category": CATEGORY_PROPERTIES,
		"name": "Contemporary Split-Level House",
		"price": 1850000,
		"upkeep": 37000,
		"happiness_bonus": 19,
		"desc": "A stylish contemporary split-level family residence with wide picture windows, stone accents, and manicured lawn.",
		"image_path": "res://assets/items/properties/prop_suburban_split.jpg",
		"min_age": 18
	},
	"prop_townhouse": {
		"id": "prop_townhouse",
		"category": CATEGORY_PROPERTIES,
		"name": "Cobblestone Row Townhouse",
		"price": 2200000,
		"upkeep": 44000,
		"happiness_bonus": 21,
		"desc": "A charming three-story brick Victorian townhouse with grand bay windows, wrought iron gates, and warm glowing lamps.",
		"image_path": "res://assets/items/properties/prop_townhouse.jpg",
		"min_age": 18
	},
	"prop_eco_timber": {
		"id": "prop_eco_timber",
		"category": CATEGORY_PROPERTIES,
		"name": "Eco-Timber Sustainable Home",
		"price": 2650000,
		"upkeep": 53000,
		"happiness_bonus": 22,
		"desc": "A modern eco-designed cedar timber residence featuring rooftop solar panels, smart thermal glass, and serene gardens.",
		"image_path": "res://assets/items/properties/prop_eco_timber.jpg",
		"min_age": 18
	},
	"prop_house": {
		"id": "prop_house",
		"category": CATEGORY_PROPERTIES,
		"name": "Suburban Family Residence",
		"price": 3200000,
		"upkeep": 64000,
		"happiness_bonus": 24,
		"desc": "A picturesque two-story home with a manicured front lawn, driveway, garage, and leafy tree in a peaceful suburb.",
		"image_path": "res://assets/items/properties/prop_house.jpg",
		"min_age": 18
	},
	"prop_cabin": {
		"id": "prop_cabin",
		"category": CATEGORY_PROPERTIES,
		"name": "Pine Crest Lakeside Cabin",
		"price": 3900000,
		"upkeep": 78000,
		"happiness_bonus": 27,
		"desc": "A peaceful timber log cabin nestled among dense evergreens on the edge of a serene mountain lake.",
		"image_path": "res://assets/items/properties/prop_cabin.jpg",
		"min_age": 18
	},
	"prop_historic_brownstone": {
		"id": "prop_historic_brownstone",
		"category": CATEGORY_PROPERTIES,
		"name": "Heritage Brownstone Mansion",
		"price": 5500000,
		"upkeep": 110000,
		"happiness_bonus": 28,
		"desc": "An opulent 4-story historic Victorian brownstone mansion with grand exterior stone stoop and ornate architectural relief.",
		"image_path": "res://assets/items/properties/prop_historic_brownstone.jpg",
		"min_age": 18
	},
	"prop_modern_villa": {
		"id": "prop_modern_villa",
		"category": CATEGORY_PROPERTIES,
		"name": "Zenith Modern Minimalist Villa",
		"price": 7200000,
		"upkeep": 144000,
		"happiness_bonus": 30,
		"desc": "An architectural marvel with floor-to-ceiling glass walls, warm timber soffits, and a luminous infinity pool.",
		"image_path": "res://assets/items/properties/prop_modern_villa.jpg",
		"min_age": 18
	},
	"prop_alpine_chalet": {
		"id": "prop_alpine_chalet",
		"category": CATEGORY_PROPERTIES,
		"name": "Alpine Ski Chalet",
		"price": 8500000,
		"upkeep": 170000,
		"happiness_bonus": 31,
		"desc": "A luxury heavy-timber ski lodge in the snowy alpine peaks with stone hearth fireplace and heated outdoor sauna.",
		"image_path": "res://assets/items/properties/prop_alpine_chalet.jpg",
		"min_age": 18
	},
	"prop_ranch": {
		"id": "prop_ranch",
		"category": CATEGORY_PROPERTIES,
		"name": "Rolling Hills Country Ranch",
		"price": 10500000,
		"upkeep": 210000,
		"happiness_bonus": 33,
		"desc": "An expansive rural sanctuary with wooden red barn, pastures, grazing animals, and endless golden sunset vistas.",
		"image_path": "res://assets/items/properties/prop_ranch.jpg",
		"min_age": 18
	},
	"prop_desert_estate": {
		"id": "prop_desert_estate",
		"category": CATEGORY_PROPERTIES,
		"name": "Palm Springs Desert Oasis",
		"price": 12800000,
		"upkeep": 256000,
		"happiness_bonus": 34,
		"desc": "A private mid-century modern architectural desert compound with illuminated turquoise pool and palm trees under sunset skies.",
		"image_path": "res://assets/items/properties/prop_desert_estate.jpg",
		"min_age": 18
	},
	"prop_beachfront": {
		"id": "prop_beachfront",
		"category": CATEGORY_PROPERTIES,
		"name": "Pacific Crest Beach House",
		"price": 16500000,
		"upkeep": 330000,
		"happiness_bonus": 36,
		"desc": "A modern oceanfront villa directly on soft golden sand with a sundeck, swimming pool, and swaying palms.",
		"image_path": "res://assets/items/properties/prop_beachfront.jpg",
		"min_age": 18
	},
	"prop_harbor_duplex": {
		"id": "prop_harbor_duplex",
		"category": CATEGORY_PROPERTIES,
		"name": "Waterfront Marina Duplex",
		"price": 21000000,
		"upkeep": 420000,
		"happiness_bonus": 38,
		"desc": "A sleek modern waterfront glass duplex with private deep-water yacht mooring dock and teak dining deck.",
		"image_path": "res://assets/items/properties/prop_harbor_duplex.jpg",
		"min_age": 18
	},
	"prop_penthouse": {
		"id": "prop_penthouse",
		"category": CATEGORY_PROPERTIES,
		"name": "Skyline Sky-Villa Penthouse",
		"price": 28000000,
		"upkeep": 560000,
		"happiness_bonus": 40,
		"desc": "The pinnacle of cosmopolitan prestige. Rooftop panoramic views, private heated infinity spa, and 24/7 concierge.",
		"image_path": "res://assets/items/properties/prop_penthouse.jpg",
		"min_age": 21
	},
	"prop_cyber_mansion": {
		"id": "prop_cyber_mansion",
		"category": CATEGORY_PROPERTIES,
		"name": "Neo-Tech Smart Manor",
		"price": 45000000,
		"upkeep": 900000,
		"happiness_bonus": 44,
		"desc": "A fortified architectural estate featuring drone landing pads, quantum-encrypted security gates, and indoor atrium.",
		"image_path": "res://assets/items/properties/prop_cyber_mansion.jpg",
		"min_age": 21
	},
	"prop_chateau": {
		"id": "prop_chateau",
		"category": CATEGORY_PROPERTIES,
		"name": "Grand Chateau & Vineyard",
		"price": 68000000,
		"upkeep": 1360000,
		"happiness_bonus": 48,
		"desc": "A historic French stone castle with stone towers, sprawling vineyard terraces, hedge mazes, and marble fountains.",
		"image_path": "res://assets/items/properties/prop_chateau.jpg",
		"min_age": 21
	},
	"prop_cliffside_compound": {
		"id": "prop_cliffside_compound",
		"category": CATEGORY_PROPERTIES,
		"name": "Cliffside Architectural Compound",
		"price": 95000000,
		"upkeep": 1900000,
		"happiness_bonus": 50,
		"desc": "A dramatic cliffside masterpiece hanging above the ocean with private helipad, cantilevered pool, and glass elevator.",
		"image_path": "res://assets/items/properties/prop_cliffside_compound.jpg",
		"min_age": 21
	},
	"prop_private_island": {
		"id": "prop_private_island",
		"category": CATEGORY_PROPERTIES,
		"name": "Emerald Atoll Private Island",
		"price": 140000000,
		"upkeep": 2800000,
		"happiness_bonus": 55,
		"desc": "A private tropical island surrounded by turquoise waters, with overwater thatch bungalows, private pier, and beach firepit.",
		"image_path": "res://assets/items/properties/prop_private_island.jpg",
		"min_age": 21
	},
	"prop_megatower_apex": {
		"id": "prop_megatower_apex",
		"category": CATEGORY_PROPERTIES,
		"name": "Apex Triplex Megatower Sanctuary",
		"price": 220000000,
		"upkeep": 4400000,
		"happiness_bonus": 60,
		"desc": "A sovereign three-story penthouse crown atop a futuristic megatower skyscraper with an indoor botanical garden atrium.",
		"image_path": "res://assets/items/properties/prop_megatower_apex.jpg",
		"min_age": 21
	},
	"prop_orbital": {
		"id": "prop_orbital",
		"category": CATEGORY_PROPERTIES,
		"name": "High-Orbit Luxury Satellite Suite",
		"price": 380000000,
		"upkeep": 7600000,
		"happiness_bonus": 65,
		"desc": "The ultimate expression of planetary wealth. A private orbital space station suite with panoramic glass observation lounge.",
		"image_path": "res://assets/items/properties/prop_orbital.jpg",
		"min_age": 21
	},
	# =========================================================================
	# 🚲 BICYCLES (Bicycle Category)
	# =========================================================================
	"bike_commuter": {
		"id": "bike_commuter",
		"category": CATEGORY_BICYCLES,
		"name": "Vintage Urban Commuter Bike",
		"price": 380,
		"upkeep": 0,
		"happiness_bonus": 4,
		"desc": "A timeless 3-speed steel city cruiser with a front basket and bell. Perfect for sunny rides through the neighborhood.",
		"image_path": "res://assets/items/bicycles/bike_commuter.jpg",
		"min_age": 6
	},
	"bike_mountain": {
		"id": "bike_mountain",
		"category": CATEGORY_BICYCLES,
		"name": "Apex Trail Mountain Bike",
		"price": 1100,
		"upkeep": 0,
		"happiness_bonus": 7,
		"desc": "Rugged dual-suspension trail bike equipped with hydraulic disc brakes and knobby off-road tires.",
		"image_path": "res://assets/items/bicycles/bike_mountain.jpg",
		"min_age": 10
	},
	"bike_road": {
		"id": "bike_road",
		"category": CATEGORY_BICYCLES,
		"name": "Aero Carbon Racing Bike",
		"price": 4200,
		"upkeep": 64,
		"happiness_bonus": 12,
		"desc": "Ultra-lightweight aerodynamic carbon fiber road bike designed for blistering highway sprints and endurance racing.",
		"image_path": "res://assets/items/bicycles/bike_road.jpg",
		"min_age": 14
	},
	"bike_cargo_ev": {
		"id": "bike_cargo_ev",
		"category": CATEGORY_BICYCLES,
		"name": "Volt Cargo Electric e-Bike",
		"price": 7000,
		"upkeep": 130,
		"happiness_bonus": 16,
		"desc": "High-torque pedal-assist electric cargo bike with integrated lithium battery and heavy-duty utility carrier.",
		"image_path": "res://assets/items/bicycles/bike_cargo_ev.jpg",
		"min_age": 14
	},
	# =========================================================================
	# 💎 JEWELRY (Jewelers)
	# =========================================================================
	"jewelry_silver_ring": {
		"id": "jewelry_silver_ring",
		"category": CATEGORY_JEWELRY,
		"name": "Engraved Sterling Silver Signet Ring",
		"price": 1400,
		"upkeep": 0,
		"happiness_bonus": 5,
		"desc": "A solid sterling silver heirloom ring featuring subtle hand-chiseled detailing.",
		"image_path": "res://assets/items/jewelry/jewelry_silver_ring.jpg",
		"min_age": 14
	},
	"jewelry_gold_cufflinks": {
		"id": "jewelry_gold_cufflinks",
		"category": CATEGORY_JEWELRY,
		"name": "18K Solid Gold Guilloché Cufflinks",
		"price": 3000,
		"upkeep": 0,
		"happiness_bonus": 8,
		"desc": "Handcrafted luxury 18k yellow gold oval cufflinks with intricate engine-turned guilloché patterns and diamond borders.",
		"image_path": "res://assets/items/jewelry/jewelry_gold_cufflinks.jpg",
		"min_age": 16
	},
	"jewelry_pearl_necklace": {
		"id": "jewelry_pearl_necklace",
		"category": CATEGORY_JEWELRY,
		"name": "South Sea Cultured Pearl Necklace",
		"price": 6700,
		"upkeep": 0,
		"happiness_bonus": 10,
		"desc": "An elegant string of glowing iridescent cultured pearls finished with an 18k white gold clasp.",
		"image_path": "res://assets/items/jewelry/jewelry_pearl_necklace.jpg",
		"min_age": 16
	},
	"jewelry_sapphire_pendant": {
		"id": "jewelry_sapphire_pendant",
		"category": CATEGORY_JEWELRY,
		"name": "Royal Ceylon Sapphire Halo Pendant",
		"price": 15200,
		"upkeep": 0,
		"happiness_bonus": 14,
		"desc": "A brilliant oval-cut royal blue Ceylon sapphire framed by a shimmering pavé diamond halo on a platinum chain.",
		"image_path": "res://assets/items/jewelry/jewelry_sapphire_pendant.jpg",
		"min_age": 16
	},
	"jewelry_diamond_bracelet": {
		"id": "jewelry_diamond_bracelet",
		"category": CATEGORY_JEWELRY,
		"name": "Platinum Diamond Tennis Bracelet",
		"price": 29600,
		"upkeep": 0,
		"happiness_bonus": 18,
		"desc": "A dazzling continuous band of brilliant-cut diamonds prong-set in pure platinum.",
		"image_path": "res://assets/items/jewelry/jewelry_diamond_bracelet.jpg",
		"min_age": 18
	},
	"jewelry_luxury_watch": {
		"id": "jewelry_luxury_watch",
		"category": CATEGORY_JEWELRY,
		"name": "Geneva Tourbillon Chronometer Watch",
		"price": 104000,
		"upkeep": 1300,
		"happiness_bonus": 26,
		"desc": "A masterwork Swiss mechanical timepiece with an open-heart tourbillon escapement and alligator leather strap.",
		"image_path": "res://assets/items/jewelry/jewelry_luxury_watch.jpg",
		"min_age": 18
	},
	"jewelry_emerald_ring": {
		"id": "jewelry_emerald_ring",
		"category": CATEGORY_JEWELRY,
		"name": "Colombian Emerald & Diamond Ring",
		"price": 176000,
		"upkeep": 1900,
		"happiness_bonus": 32,
		"desc": "A magnificent vivid green emerald-cut Colombian emerald mounted with tapered diamond baguettes in platinum.",
		"image_path": "res://assets/items/jewelry/jewelry_emerald_ring.jpg",
		"min_age": 18
	},
	"jewelry_royal_tiara": {
		"id": "jewelry_royal_tiara",
		"category": CATEGORY_JEWELRY,
		"name": "Royal Emerald & Diamond Diadem",
		"price": 720000,
		"upkeep": 4000,
		"happiness_bonus": 38,
		"desc": "An opulent museum-grade diadem crowned with Colombian emeralds and hundreds of pavé diamonds.",
		"image_path": "res://assets/items/jewelry/jewelry_royal_tiara.jpg",
		"min_age": 18
	},
	# =========================================================================
	# 🎸 MUSICAL INSTRUMENTS (Music Stores)
	# =========================================================================
	"inst_acoustic_guitar": {
		"id": "inst_acoustic_guitar",
		"category": CATEGORY_INSTRUMENTS,
		"name": "Solid Spruce Acoustic Guitar",
		"price": 610,
		"upkeep": 0,
		"happiness_bonus": 6,
		"desc": "A resonant dreadnought acoustic guitar with warm spruce projection and smooth rosewood fretboard.",
		"image_path": "",
		"min_age": 8
	},
	"inst_electric_guitar": {
		"id": "inst_electric_guitar",
		"category": CATEGORY_INSTRUMENTS,
		"name": "Custom Sunburst Stratocaster",
		"price": 3000,
		"upkeep": 0,
		"happiness_bonus": 12,
		"desc": "An iconic electric guitar finished in vintage three-color sunburst with single-coil pickups and tremolo bridge.",
		"image_path": "",
		"min_age": 12
	},
	"inst_cello": {
		"id": "inst_cello",
		"category": CATEGORY_INSTRUMENTS,
		"name": "Handcrafted Master Cello",
		"price": 10200,
		"upkeep": 130,
		"happiness_bonus": 16,
		"desc": "Carved from European flamed maple with an ebony fingerboard, producing deep, haunting orchestral resonance.",
		"image_path": "",
		"min_age": 14
	},
	"inst_synthesizer": {
		"id": "inst_synthesizer",
		"category": CATEGORY_INSTRUMENTS,
		"name": "Vintage Analog Polyphonic Synthesizer",
		"price": 22400,
		"upkeep": 190,
		"happiness_bonus": 22,
		"desc": "A legendary vintage synth with voltage-controlled oscillators, analog ladder filters, and warm wooden side cheeks.",
		"image_path": "",
		"min_age": 16
	},
	"inst_grand_piano": {
		"id": "inst_grand_piano",
		"category": CATEGORY_INSTRUMENTS,
		"name": "Concert Grand Piano 'Imperial 97'",
		"price": 115000,
		"upkeep": 880,
		"happiness_bonus": 32,
		"desc": "The crown jewel of acoustic pianos. Handcrafted in Vienna with 97 keys and unmatched dynamic projection.",
		"image_path": "",
		"min_age": 16
	},
	# =========================================================================
	# ✈️ AIRPLANES & HELICOPTERS (Airplane & Helicopter Dealers)
	# =========================================================================
	"aircraft_cessna": {
		"id": "aircraft_cessna",
		"category": CATEGORY_AIRCRAFT,
		"name": "Skyhawk 172 Light Propeller Plane",
		"price": 608000,
		"upkeep": 35200,
		"happiness_bonus": 26,
		"desc": "A renowned four-seat single-engine high-wing aircraft. The gold standard for private cross-country flying.",
		"image_path": "res://assets/items/aircraft/aircraft_cessna.jpg",
		"min_age": 18
	},
	"aircraft_helicopter": {
		"id": "aircraft_helicopter",
		"category": CATEGORY_AIRCRAFT,
		"name": "RotorCraft 505 Executive Helicopter",
		"price": 4480000,
		"upkeep": 192000,
		"happiness_bonus": 38,
		"desc": "A high-visibility turbine rotorcraft with glass cockpit and leather cabin seating for executive hops.",
		"image_path": "res://assets/items/aircraft/aircraft_helicopter.jpg",
		"min_age": 18
	},
	"aircraft_personal_jet": {
		"id": "aircraft_personal_jet",
		"category": CATEGORY_AIRCRAFT,
		"name": "Aero Vision SF50 Personal Light Jet",
		"price": 10000000,
		"upkeep": 448000,
		"happiness_bonus": 48,
		"desc": "A revolutionary carbon-fiber single-engine personal jet capable of cruising at 28,000 feet in whisper-quiet luxury.",
		"image_path": "res://assets/items/aircraft/aircraft_personal_jet.jpg",
		"min_age": 18
	},
	"aircraft_business_jet": {
		"id": "aircraft_business_jet",
		"category": CATEGORY_AIRCRAFT,
		"name": "Apex G650 Ultra Long-Range Private Jet",
		"price": 136000000,
		"upkeep": 5120000,
		"happiness_bonus": 65,
		"desc": "The pinnacle of private aviation. Intercontinental speed, master stateroom, conference lounge, and private flight crew.",
		"image_path": "res://assets/items/aircraft/aircraft_business_jet.jpg",
		"min_age": 18
	},
	# =========================================================================
	# 🛥️ YACHTS & MARINE VESSELS (Yacht Dealers)
	# =========================================================================
	"yacht_speedboat": {
		"id": "yacht_speedboat",
		"category": CATEGORY_YACHTS,
		"name": "Veloce 24ft Twin-Turbo Speedboat",
		"price": 152000,
		"upkeep": 10400,
		"happiness_bonus": 16,
		"desc": "A sleek performance powerboat built for wakesurfing, waterskiing, and high-speed coastal cruising.",
		"image_path": "res://assets/items/yachts/yacht_speedboat.jpg",
		"min_age": 18
	},
	"yacht_cruiser": {
		"id": "yacht_cruiser",
		"category": CATEGORY_YACHTS,
		"name": "Riviera 42ft Luxury Sport Cruiser",
		"price": 1310000,
		"upkeep": 67200,
		"happiness_bonus": 28,
		"desc": "A twin-diesel express cabin cruiser with sunbathing deck, full galley, and sleeping quarters for weekend voyages.",
		"image_path": "res://assets/items/yachts/yacht_cruiser.jpg",
		"min_age": 18
	},
	"yacht_flybridge": {
		"id": "yacht_flybridge",
		"category": CATEGORY_YACHTS,
		"name": "Perseo 76ft Flybridge Superyacht",
		"price": 8640000,
		"upkeep": 336000,
		"happiness_bonus": 42,
		"desc": "An Italian-designed luxury motor yacht with panoramic flybridge lounge, hydraulic swim platform, and VIP suites.",
		"image_path": "res://assets/items/yachts/yacht_flybridge.jpg",
		"min_age": 18
	},
	"yacht_megayacht": {
		"id": "yacht_megayacht",
		"category": CATEGORY_YACHTS,
		"name": "Oceanic Sovereign 180ft Megayacht",
		"price": 120000000,
		"upkeep": 4480000,
		"happiness_bonus": 62,
		"desc": "A multi-deck floating palace featuring a helipad, infinity pool, beach club, cinema, and dedicated maritime crew.",
		"image_path": "res://assets/items/yachts/yacht_megayacht.jpg",
		"min_age": 18
	},

	# =========================================================================
	# 🎯 FIREARMS & DEFENSE ARSENAL
	# =========================================================================
	"gun_pistol_compact": {
		"id": "gun_pistol_compact",
		"category": CATEGORY_FIREARMS,
		"name": "Compact 9mm Concealed Carry Pistol",
		"price": 1000,
		"upkeep": 56,
		"happiness_bonus": 4,
		"desc": "A lightweight polymer striker-fired 9x19mm subcompact handgun with tritium night sights. Conceals cleanly inside an IWB holster for discreet personal defense.",
		"image_path": "res://assets/items/firearms/gun_pistol_compact.jpg",
		"min_age": 21
	},
	"gun_service_handgun": {
		"id": "gun_service_handgun",
		"category": CATEGORY_FIREARMS,
		"name": "Tactical Full-Frame Service Handgun",
		"price": 1500,
		"upkeep": 80,
		"happiness_bonus": 5,
		"desc": "A military-grade 17-round full-size service pistol equipped with an undercut trigger guard, flared magwell, and an optic-ready slide.",
		"image_path": "res://assets/items/firearms/gun_service_handgun.jpg",
		"min_age": 21
	},
	"gun_magnum_revolver": {
		"id": "gun_magnum_revolver",
		"category": CATEGORY_FIREARMS,
		"name": ".357 Combat Magnum Revolver",
		"price": 2000,
		"upkeep": 96,
		"happiness_bonus": 6,
		"desc": "A satin stainless steel heavy frame revolver chambered in .357 Magnum with a smooth double-action trigger and custom textured walnut grips.",
		"image_path": "res://assets/items/firearms/gun_magnum_revolver.jpg",
		"min_age": 21
	},
	"gun_tactical_shotgun": {
		"id": "gun_tactical_shotgun",
		"category": CATEGORY_FIREARMS,
		"name": "12-Gauge Tactical Home Defense Shotgun",
		"price": 1400,
		"upkeep": 72,
		"happiness_bonus": 5,
		"desc": "A rugged pump-action 12-gauge scattergun outfitted with an extended 8-round magazine tube, ghost ring sights, Picatinny heat shield, and breacher muzzle.",
		"image_path": "res://assets/items/firearms/gun_tactical_shotgun.jpg",
		"min_age": 21
	},
	"gun_defense_carbine": {
		"id": "gun_defense_carbine",
		"category": CATEGORY_FIREARMS,
		"name": "5.56mm Semi-Auto Patrol Carbine",
		"price": 3000,
		"upkeep": 140,
		"happiness_bonus": 7,
		"desc": "A modular, lightweight direct-impingement carbine featuring free-float M-LOK handguards, ambidextrous controls, and a parallax-free holographic weapon sight.",
		"image_path": "res://assets/items/firearms/gun_defense_carbine.jpg",
		"min_age": 21
	},
	"gun_custom_subgun": {
		"id": "gun_custom_subgun",
		"category": CATEGORY_FIREARMS,
		"name": "Personal Defense Weapon (PDW) 9mm",
		"price": 3800,
		"upkeep": 180,
		"happiness_bonus": 8,
		"desc": "A roller-delayed blowback sub-compact platform with collapsible stabilizing brace, ambidextrous selector, and quick-detach suppressor mount.",
		"image_path": "res://assets/items/firearms/gun_custom_subgun.jpg",
		"min_age": 21
	},
	"gun_precision_rifle": {
		"id": "gun_precision_rifle",
		"category": CATEGORY_FIREARMS,
		"name": ".308 Long-Range Match Precision Rifle",
		"price": 5800,
		"upkeep": 240,
		"happiness_bonus": 9,
		"desc": "A blueprint bolt-action marksman rifle bedded in an aerospace aluminum chassis with a 26-inch fluted match barrel and a variable 24x magnification scope.",
		"image_path": "res://assets/items/firearms/gun_precision_rifle.jpg",
		"min_age": 21
	}
}

static func get_item(item_id: String) -> Dictionary:
	var actual_id := "prop_capsule" if item_id == "prop_starter_home" else item_id
	return ITEMS.get(actual_id, {}).duplicate(true)

static func get_items_by_category(category: String) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for key in ITEMS.keys():
		var it: Dictionary = ITEMS[key]
		if it.get("category", "") == category:
			list.append(it.duplicate(true))
	list.sort_custom(func(a, b): return int(a.get("price", 0)) < int(b.get("price", 0)))
	return list

static func get_category_display_title(category: String) -> String:
	match category:
		CATEGORY_BICYCLES:
			return "🚲 VELO CYCLES • BICYCLE EMPORIUM"
		CATEGORY_CARS:
			return "🚗 APEX CYBER MOTORS • CAR DEALERSHIP"
		CATEGORY_MOTORCYCLES:
			return "🏍️ NEON SPEED CYCLES • MOTORCYCLE SHOWROOM"
		CATEGORY_JEWELRY:
			return "💎 AURA & BRILLIANCE • HAUTE JEWELERS"
		CATEGORY_INSTRUMENTS:
			return "🎸 STRATOSPHERE SOUNDS • MUSIC STORE"
		CATEGORY_PROPERTIES:
			return "🏠 METRO PRIME REALTY • PROPERTY BROKERAGE"
		CATEGORY_AIRCRAFT:
			return "✈️ AERO LUXE FLIGHT • AIRCRAFT DEALERSHIP"
		CATEGORY_YACHTS:
			return "🛥️ OCEANIC HORIZON • YACHT & MARINE BROKERS"
		CATEGORY_FIREARMS:
			return "🎯 IRONCLAD DEFENSE • TACTICAL ARMORY & GUN STORE"
		_:
			return "COMMERCIAL MARKETPLACE"

static func get_category_subtitle(category: String) -> String:
	match category:
		CATEGORY_BICYCLES:
			return "Eco-friendly commuter bikes, rugged trail riders, aero racers, and electric cargo haulers."
		CATEGORY_CARS:
			return "Acquire personal automobiles for swift transit, personal prestige, and weekend joyrides."
		CATEGORY_MOTORCYCLES:
			return "Feel the open rush of two-wheeled performance, agility, and street rebellion."
		CATEGORY_JEWELRY:
			return "Acquire heirloom gemstones, luxury tourbillons, and platinum diamond jewelry."
		CATEGORY_INSTRUMENTS:
			return "Fine handcrafted guitars, concert pianos, analog synths, and orchestral strings."
		CATEGORY_PROPERTIES:
			return "Invest in luxury real estate, escape landlord rent, and build long-term generational equity."
		CATEGORY_AIRCRAFT:
			return "High-performance propeller aircraft, turbine helicopters, and intercontinental private jets."
		CATEGORY_YACHTS:
			return "Ocean power speedboats, luxury flybridge cruisers, and multi-deck sovereign megayachts."
		CATEGORY_FIREARMS:
			return "Licensed handguns, home defense shotguns, semi-auto patrol carbines, and precision marksman rifles."
		_:
			return "Browse luxury and commercial goods available for acquisition."

static func can_afford(player_data: Node, price: int) -> bool:
	var total_funds: int = player_data.money + player_data.bank_savings
	return total_funds >= price

static func can_purchase_asset(player_data: Node, item_id: String, payment_method: String = "funds") -> Dictionary:
	var actual_id := "prop_capsule" if item_id == "prop_starter_home" else item_id
	if not ITEMS.has(actual_id):
		return {"allowed": false, "reason": "Item not found in catalog."}

	var item: Dictionary = ITEMS[actual_id]
	var category: String = str(item.get("category", ""))
	var price: int = int(item.get("price", 0))
	var min_age: int = int(item.get("min_age", 18))

	if player_data.age < min_age:
		return {
			"allowed": false,
			"reason": "Legal age requirement not met. You must be at least %d years old to purchase this asset." % min_age
		}

	# Vehicle Driver/Operator License Verification
	if category == CATEGORY_CARS and not player_data.has_license("license_car"):
		return {
			"allowed": false,
			"reason": "Requires Driver's License (Class C). Take the qualification exam in Activities -> Licensing first!"
		}
	if category == CATEGORY_MOTORCYCLES and not player_data.has_license("license_motorcycle"):
		return {
			"allowed": false,
			"reason": "Requires Motorcycle Operator License (Class M). Take the qualification exam in Activities -> Licensing first!"
		}
	if category == CATEGORY_AIRCRAFT and not player_data.has_license("license_pilot"):
		return {
			"allowed": false,
			"reason": "Requires Private Pilot & Rotorcraft License. Take the flight certification exam in Activities -> Licensing first!"
		}
	if category == CATEGORY_YACHTS and not player_data.has_license("license_boating"):
		return {
			"allowed": false,
			"reason": "Requires Master Coastal Boater & Yachting License. Take the certification exam in Activities -> Licensing first!"
		}
	if category == CATEGORY_FIREARMS and not player_data.has_license("license_firearm"):
		return {
			"allowed": false,
			"reason": "Requires Concealed Carry & Tactical Firearms License. Obtain your state permit in Activities -> Licensing first!"
		}

	if payment_method == "credit_card":
		if not player_data.has_credit_card:
			return {
				"allowed": false,
				"reason": "No active credit card account. Apply for a card in the Banking panel."
			}
		var avail_credit: int = player_data.get_credit_card_available()
		if avail_credit < price:
			return {
				"allowed": false,
				"reason": "Insufficient credit limit. Purchase price $%d exceeds available credit ($%d)." % [price, avail_credit]
			}
	else:
		var total_funds: int = player_data.money + player_data.bank_savings
		if total_funds < price:
			return {
				"allowed": false,
				"reason": "Insufficient funds. You require $%d (Total available: $%d)." % [price, total_funds]
			}

	return {"allowed": true, "reason": "Eligible to purchase."}

static func create_asset_instance(item_id: String, purchase_age: int = 0) -> Dictionary:
	var actual_id := "prop_capsule" if item_id == "prop_starter_home" else item_id
	if not ITEMS.has(actual_id):
		return {}
	var item: Dictionary = ITEMS[actual_id]
	var price: int = int(item.get("price", 0))
	var instance_id: String = actual_id + "_" + str(Time.get_unix_time_from_system()).replace(".", "") + "_" + str(randi() % 10000)
	var inst_upkeep: int = int(item.get("upkeep", 0))
	if str(item.get("category", "")) == CATEGORY_PROPERTIES:
		inst_upkeep = maxi(500, int(round(float(price) * 0.02)))
	return {
		"instance_id": instance_id,
		"item_id": actual_id,
		"category": str(item.get("category", "")),
		"name": str(item.get("name", "")),
		"purchase_price": price,
		"current_value": price,
		"purchase_age": purchase_age,
		"condition": 100,
		"image_path": str(item.get("image_path", "")),
		"upkeep": inst_upkeep,
		"happiness_bonus": int(item.get("happiness_bonus", 5)),
		"last_used_age": -1,
		"purchased_with_credit": false
	}

static func grant_starting_property(player_data: Node) -> Dictionary:
	for asset in player_data.owned_assets:
		if str(asset.get("category", "")) == CATEGORY_PROPERTIES:
			return {}
	var starter := create_asset_instance("prop_capsule", player_data.age)
	if not starter.is_empty():
		player_data.owned_assets.append(starter)
	return starter

static func buy_asset(player_data: Node, item_id: String, payment_method: String = "funds") -> Dictionary:
	var actual_id := "prop_capsule" if item_id == "prop_starter_home" else item_id
	var eval := can_purchase_asset(player_data, actual_id, payment_method)
	if not bool(eval.get("allowed", false)):
		return {
			"success": false,
			"message": str(eval.get("reason", "Cannot purchase asset."))
		}

	var item: Dictionary = ITEMS[actual_id]
	var price: int = int(item.get("price", 0))

	if payment_method == "credit_card":
		player_data.credit_card_balance += price
		if float(player_data.credit_card_balance) / float(maxi(1, player_data.credit_card_limit)) > 0.8:
			player_data.modify_credit_score(-5)
	else:
		# Debit funds: Prefer bank savings first, then draw remainder from cash
		player_data.debit_funds(price)

	var new_asset: Dictionary = create_asset_instance(actual_id, player_data.age)
	new_asset["purchased_with_credit"] = (payment_method == "credit_card")

	player_data.owned_assets.append(new_asset)
	player_data.happiness = mini(100, player_data.happiness + int(item.get("happiness_bonus", 10)))

	if str(item.get("category", "")) == CATEGORY_PROPERTIES:
		if player_data.has_method("add_milestone"):
			player_data.add_milestone("Purchased real estate: %s." % str(item.get("name", "Property")), player_data.age, "🏡")

	var method_desc := "charged to %s Credit Card" % player_data.credit_card_tier if payment_method == "credit_card" else "paid in full"
	return {
		"success": true,
		"message": "Congratulations! You purchased %s for $%d (%s)." % [new_asset["name"], price, method_desc],
		"asset": new_asset
	}

static func sell_asset(player_data: Node, instance_id: String) -> Dictionary:
	for i in range(player_data.owned_assets.size() - 1, -1, -1):
		var asset: Dictionary = player_data.owned_assets[i]
		if asset.get("instance_id", "") == instance_id:
			if str(asset.get("category", "")) == CATEGORY_PROPERTIES and player_data.age < 18:
				return {
					"success": false,
					"message": "You cannot sell real estate as a minor! Your family manages the residence until you reach adulthood at age 18."
				}

			var total_value: int = int(asset.get("current_value", asset.get("purchase_price", 0)))

			# Settle any active mortgage on this real estate property first
			var mortgage_settled: int = 0
			if "mortgages" in player_data and player_data.mortgages is Array:
				for m_i in range(player_data.mortgages.size() - 1, -1, -1):
					var m = player_data.mortgages[m_i]
					if m is Dictionary and str(m.get("instance_id", "")) == instance_id:
						var m_rem: int = int(m.get("remaining_principal", 0))
						mortgage_settled = mini(total_value, m_rem)
						m["remaining_principal"] = maxi(0, m_rem - mortgage_settled)
						if int(m["remaining_principal"]) <= 0:
							player_data.mortgages.remove_at(m_i)
						break

			var value_after_mortgage: int = total_value - mortgage_settled
			var was_credit: bool = bool(asset.get("purchased_with_credit", false))
			var pay_to_card: int = 0

			# Anti-loophole: if purchased with credit card or card balance exists, refund card
			if (was_credit or player_data.credit_card_balance > 0) and player_data.has_credit_card:
				pay_to_card = mini(value_after_mortgage, player_data.credit_card_balance)
				player_data.credit_card_balance -= pay_to_card

			var cash_proceeds: int = value_after_mortgage - pay_to_card
			if cash_proceeds > 0:
				player_data.money += cash_proceeds

			player_data.owned_assets.remove_at(i)

			var msg: String = ""
			if mortgage_settled > 0 and cash_proceeds > 0:
				msg = "Sold %s for $%d ($%d settled remaining mortgage principal, $%d cash proceeds received)." % [
					asset.get("name", "Asset"), total_value, mortgage_settled, cash_proceeds
				]
			elif mortgage_settled > 0:
				msg = "Sold %s for $%d ($%d settled remaining mortgage principal)." % [
					asset.get("name", "Asset"), total_value, mortgage_settled
				]
			elif pay_to_card > 0 and cash_proceeds > 0:
				msg = "Sold %s for $%d ($%d directly paid off credit card balance, $%d cash received)." % [
					asset.get("name", "Asset"), total_value, pay_to_card, cash_proceeds
				]
			elif pay_to_card > 0:
				msg = "Sold %s for $%d (Entire $%d proceeds refunded directly to settle credit card usage)." % [
					asset.get("name", "Asset"), total_value, pay_to_card
				]
			else:
				msg = "Sold %s for $%d." % [asset.get("name", "Asset"), total_value]

			return {
				"success": true,
				"message": msg,
				"sale_price": total_value,
				"mortgage_settled": mortgage_settled,
				"credit_settled": pay_to_card,
				"cash_proceeds": cash_proceeds
			}
	return {"success": false, "message": "Asset not found in ownership portfolio."}

static func use_asset(player_data: Node, instance_id: String) -> Dictionary:
	for asset in player_data.owned_assets:
		if asset.get("instance_id", "") == instance_id:
			if int(asset.get("last_used_age", -1)) == player_data.age:
				return {
					"success": false,
					"message": "You already enjoyed your %s this year. Available again next year." % asset.get("name", "asset")
				}
			asset["last_used_age"] = player_data.age
			var cat: String = str(asset.get("category", ""))
			var bonus: int = int(asset.get("happiness_bonus", 5))
			player_data.happiness = mini(100, player_data.happiness + bonus)
			var action_desc := ""
			match cat:
				CATEGORY_BICYCLES:
					action_desc = "You went for an energizing ride on your %s through city greenways!" % asset.get("name", "bike")
				CATEGORY_CARS, CATEGORY_MOTORCYCLES:
					action_desc = "You took your %s out for an exhilarating joyride!" % asset.get("name", "ride")
				CATEGORY_JEWELRY:
					player_data.looks = mini(100, player_data.looks + 1)
					action_desc = "You wore your exquisite %s to an exclusive gala and turned every head in the room!" % asset.get("name", "jewelry")
				CATEGORY_INSTRUMENTS:
					player_data.smarts = mini(100, player_data.smarts + 1)
					action_desc = "You practiced complex musical compositions on your %s and mastered new rhythms!" % asset.get("name", "instrument")
				CATEGORY_AIRCRAFT:
					action_desc = "You piloted your %s high above the cloud line with complete freedom!" % asset.get("name", "aircraft")
				CATEGORY_YACHTS:
					action_desc = "You cruised aboard your %s across sparkling coastal waters!" % asset.get("name", "yacht")
				CATEGORY_FIREARMS:
					player_data.smarts = mini(100, player_data.smarts + 1)
					action_desc = "You ran tactical target transition and defensive handling drills at the range with your %s!" % asset.get("name", "firearm")
				_:
					if player_data.age < 18:
						action_desc = "You spent a cozy day relaxing with your family at your %s!" % asset.get("name", "residence")
					else:
						action_desc = "You spent a serene, luxurious weekend relaxing at your %s!" % asset.get("name", "residence")
			return {
				"success": true,
				"message": action_desc
			}
	return {"success": false, "message": "Asset not found."}

static func process_yearly_assets(player_data: Node) -> Array[String]:
	var logs: Array[String] = []
	for asset in player_data.owned_assets:
		var cat: String = str(asset.get("category", ""))
		var cur_val: int = int(asset.get("current_value", 0))
		var orig_price: int = int(asset.get("purchase_price", cur_val))
		var upkeep: int = int(asset.get("upkeep", 0))

		# 1. Maintenance / Upkeep auto-debit
		if cat == CATEGORY_PROPERTIES:
			# Maintenance cost is calculated as a percentage of the house value (2.0% of current asset value)
			upkeep = maxi(500, int(round(float(cur_val) * 0.02)))
			asset["upkeep"] = upkeep

		if upkeep > 0:
			# If player is a minor (< 18), parents / guardians cover family residence and asset upkeep
			if player_data.age < 18:
				pass
			elif player_data.bank_savings >= upkeep:
				player_data.bank_savings -= upkeep
			elif player_data.get_available_funds() >= upkeep:
				player_data.debit_funds(upkeep)
			else:
				# Cannot pay upkeep -> condition drops
				asset["condition"] = maxi(10, int(asset.get("condition", 100)) - 15)
				if cat == CATEGORY_PROPERTIES:
					logs.append("⚠️ Maintenance Neglect: You lacked sufficient funds to maintain your %s ($%d maintenance, 2%% of house value). Its condition deteriorated." % [asset.get("name", "asset"), upkeep])
				else:
					logs.append("⚠️ Maintenance Neglect: You lacked sufficient funds to service your %s ($%d upkeep). Its condition deteriorated." % [asset.get("name", "asset"), upkeep])

		# 2. Value adjustments (Vehicles and Real Estate depreciate over years, fine art/jewelry appreciate, firearms hold strong value)
		if cat in [CATEGORY_CARS, CATEGORY_MOTORCYCLES]:
			var floor_val: int = int(orig_price * 0.20)
			var dep: int = int(cur_val * 0.06)
			asset["current_value"] = maxi(floor_val, cur_val - dep)
		elif cat == CATEGORY_BICYCLES:
			var floor_val: int = int(orig_price * 0.15)
			var dep: int = int(cur_val * 0.08)
			asset["current_value"] = maxi(floor_val, cur_val - dep)
		elif cat in [CATEGORY_AIRCRAFT, CATEGORY_YACHTS]:
			var floor_val: int = int(orig_price * 0.25)
			var dep: int = int(cur_val * 0.05)
			asset["current_value"] = maxi(floor_val, cur_val - dep)
		elif cat in [CATEGORY_JEWELRY, CATEGORY_INSTRUMENTS]:
			var app: int = int(cur_val * 0.01)
			asset["current_value"] = cur_val + app
		elif cat == CATEGORY_PROPERTIES:
			# Real estate depreciation: assets lose value over years, making assets cheaper to sell after X number of years
			var floor_val: int = int(orig_price * 0.30)
			var dep: int = int(round(float(cur_val) * 0.025))
			asset["current_value"] = maxi(floor_val, cur_val - dep)
			asset["total_depreciation"] = int(asset.get("total_depreciation", 0)) + dep
		elif cat == CATEGORY_FIREARMS:
			var floor_val: int = int(orig_price * 0.75)
			var dep: int = int(cur_val * 0.02)
			asset["current_value"] = maxi(floor_val, cur_val - dep)

	return logs
