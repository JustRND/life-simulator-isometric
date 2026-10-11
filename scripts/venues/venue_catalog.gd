class_name VenueCatalog
extends RefCounted

## VenueCatalog provides centralized data-driven definitions for all 8 Social Venues & Nightlife categories:
## 1. Fast-Food Restaurants
## 2. Casual Restaurants
## 3. Fine-Dining Restaurants
## 4. Cafés and Coffee Shops
## 5. Bars and Pubs
## 6. Nightclubs
## 7. Lounges
## 8. Entertainment Venues

const LEGAL_DRINKING_AGE: int = 18

const CATEGORIES: Dictionary = {
	"fast_food": {
		"id": "fast_food",
		"name": "Fast-Food Restaurants",
		"icon": "🍔",
		"color": Color("#f97316"),
		"description": "Quick, budget-friendly comfort food and rapid hunger relief."
	},
	"casual_dining": {
		"id": "casual_dining",
		"name": "Casual Restaurants",
		"icon": "🍝",
		"color": Color("#3b82f6"),
		"description": "Relaxed sit-down dining with diverse dishes, ideal for friends or family."
	},
	"fine_dining": {
		"id": "fine_dining",
		"name": "Fine-Dining Restaurants",
		"icon": "🍷",
		"color": Color("#a855f7"),
		"description": "Exquisite gourmet creations, world-class service, and luxury ambiance."
	},
	"cafes": {
		"id": "cafes",
		"name": "Cafés & Coffee Shops",
		"icon": "☕",
		"color": Color("#eab308"),
		"description": "Artisan coffee, teas, light snacks, and cozy spots to chat or study."
	},
	"bars_pubs": {
		"id": "bars_pubs",
		"name": "Bars & Pubs",
		"icon": "🍺",
		"color": Color("#f59e0b"),
		"description": "Draft beers, craft cocktails, pub trivia, and lively local chatter (18+)."
	},
	"nightclubs": {
		"id": "nightclubs",
		"name": "Nightclubs",
		"icon": "🪩",
		"color": Color("#ec4899"),
		"description": "Heavy bass, laser shows, dance floors, and VIP skyboxes (18+)."
	},
	"lounges": {
		"id": "lounges",
		"name": "Lounges",
		"icon": "🎷",
		"color": Color("#06b6d4"),
		"description": "Smooth jazz, plush booths, tapas, and intimate conversations (18+)."
	},
	"entertainment": {
		"id": "entertainment",
		"name": "Entertainment Venues",
		"icon": "🎮",
		"color": Color("#10b981"),
		"description": "Retro arcades, comedy clubs, bowling alleys, and premiere cinemas."
	}
}

const VENUES: Dictionary = {
	# -------------------------------------------------------------------------
	# 1. FAST-FOOD RESTAURANTS
	# -------------------------------------------------------------------------
	"ff_neon_burger": {
		"id": "ff_neon_burger",
		"category": "fast_food",
		"name": "Neon Byte Burger",
		"tagline": "Grilled to synthetic perfection under neon glow",
		"icon": "🍔",
		"color": Color("#f97316"),
		"min_age": 0,
		"cover_charge": 0,
		"dress_code": "Casual",
		"operating_hours": "24/7",
		"menu": [
			{
				"id": "nb_classic_combo",
				"name": "Byte Burger Combo (Fries & Soda)",
				"type": "food",
				"price": 12,
				"hunger": 45.0,
				"thirst": 35.0,
				"health": -1,
				"happiness": 8,
				"alcohol_level": 0,
				"description": "Double smash burger with crispy seasoned fries and a refillable fountain soda."
			},
			{
				"id": "nb_crispy_tenders",
				"name": "Glitch Crispy Tenders",
				"type": "food",
				"price": 10,
				"hunger": 38.0,
				"thirst": 0.0,
				"health": -1,
				"happiness": 7,
				"alcohol_level": 0,
				"description": "Golden tenders with sweet barbecue dipping sauce."
			},
			{
				"id": "nb_cheese_fries",
				"name": "Loaded Cheddar Fries",
				"type": "food",
				"price": 7,
				"hunger": 25.0,
				"thirst": 0.0,
				"health": -2,
				"happiness": 6,
				"alcohol_level": 0,
				"description": "Fries drenched in warm cheddar and bacon crumbs."
			},
			{
				"id": "nb_fountain_soda",
				"name": "Electro Cola",
				"type": "drink",
				"price": 3,
				"hunger": 0.0,
				"thirst": 40.0,
				"health": -1,
				"happiness": 4,
				"alcohol_level": 0,
				"description": "Ice-cold sparkling cola with a zesty citrus hint."
			},
			{
				"id": "nb_milkshake",
				"name": "Strawberry Neon Shake",
				"type": "drink",
				"price": 6,
				"hunger": 15.0,
				"thirst": 25.0,
				"health": -1,
				"happiness": 9,
				"alcohol_level": 0,
				"description": "Rich, creamy strawberry milkshake crowned with whipped cream."
			}
		],
		"activities": [
			{
				"id": "act_quick_bite",
				"name": "Quick Counter Bite",
				"cost": 0,
				"happiness": 3,
				"social_gain": 0,
				"hunger_cost": 0.0,
				"thirst_cost": 0.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Grab a booth and enjoy your meal quietly while scrolling city news.",
				"outcomes": [
					"You sat in a corner booth, savoring hot fries while neon traffic streamed past outside.",
					"A cheerful counter attendant handed you your order with extra dipping sauce."
				]
			},
			{
				"id": "act_arcade_table",
				"name": "Play Tabletop Mini-Arcade",
				"cost": 5,
				"happiness": 8,
				"social_gain": 5,
				"hunger_cost": 2.0,
				"thirst_cost": 3.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Insert a token into the vintage table-mounted pixel shooter.",
				"outcomes": [
					"You hit the high score on the arcade cabinet! A nearby patron cheered for your run.",
					"You had fun dodging retro 8-bit lasers while sipping your drink."
				]
			}
		]
	},

	# -------------------------------------------------------------------------
	# 2. CASUAL RESTAURANTS
	# -------------------------------------------------------------------------
	"cr_ramen_house": {
		"id": "cr_ramen_house",
		"category": "casual_dining",
		"name": "Neo-Tokyo Ramen & Grill",
		"tagline": "Simmered broth, handmade noodles, and warm wood lanterns",
		"icon": "🍜",
		"color": Color("#3b82f6"),
		"min_age": 0,
		"cover_charge": 0,
		"dress_code": "Casual",
		"operating_hours": "11:00 AM - 11:00 PM",
		"menu": [
			{
				"id": "rm_tonkotsu",
				"name": "Rich Tonkotsu Black Garlic Ramen",
				"type": "food",
				"price": 22,
				"hunger": 65.0,
				"thirst": 20.0,
				"health": 2,
				"happiness": 14,
				"alcohol_level": 0,
				"description": "Rich 18-hour broth, springy noodles, soft-boiled egg, and seared chashu pork."
			},
			{
				"id": "rm_gyoza",
				"name": "Pan-Fried Pork & Cabbage Gyoza",
				"type": "food",
				"price": 12,
				"hunger": 30.0,
				"thirst": 0.0,
				"health": 1,
				"happiness": 8,
				"alcohol_level": 0,
				"description": "Crispy bottom dumplings served with spicy sesame ponzu dip."
			},
			{
				"id": "rm_salmon_teriyaki",
				"name": "Glazed Salmon Rice Bowl",
				"type": "food",
				"price": 26,
				"hunger": 60.0,
				"thirst": 10.0,
				"health": 4,
				"happiness": 12,
				"alcohol_level": 0,
				"description": "Fresh Atlantic salmon grilled with mirin glaze over steamed jasmine rice."
			},
			{
				"id": "rm_iced_green_tea",
				"name": "Chilled Roasted Genmaicha Tea",
				"type": "drink",
				"price": 5,
				"hunger": 0.0,
				"thirst": 45.0,
				"health": 2,
				"happiness": 6,
				"alcohol_level": 0,
				"description": "Fragrant roasted brown rice green tea served over crystal ice."
			},
			{
				"id": "rm_ramune",
				"name": "Japanese Marble Soda",
				"type": "drink",
				"price": 6,
				"hunger": 0.0,
				"thirst": 35.0,
				"health": 0,
				"happiness": 7,
				"alcohol_level": 0,
				"description": "Sweet fizzy soda with the satisfying pop of the glass marble stopper."
			}
		],
		"activities": [
			{
				"id": "act_chef_counter",
				"name": "Watch Master Chefs at the Noodle Bar",
				"cost": 0,
				"happiness": 8,
				"social_gain": 6,
				"hunger_cost": 0.0,
				"thirst_cost": 0.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Sit along the open kitchen counter and admire the culinary artistry.",
				"outcomes": [
					"The head chef nodded kindly and handed you a complimentary bowl of seasoned edamame.",
					"The rhythmic chopping and steamy aroma created a deeply tranquil dining atmosphere."
				]
			}
		]
	},

	# -------------------------------------------------------------------------
	# 3. FINE-DINING RESTAURANTS
	# -------------------------------------------------------------------------
	"fd_letoile": {
		"id": "fd_letoile",
		"category": "fine_dining",
		"name": "L'Étoile Synthétique",
		"tagline": "Michelin-starred molecular gastronomy on the 88th floor",
		"icon": "🍷",
		"color": Color("#a855f7"),
		"min_age": 0,
		"cover_charge": 50,
		"dress_code": "Upscale / Formal",
		"operating_hours": "5:30 PM - 11:30 PM",
		"menu": [
			{
				"id": "fd_wagyu_truffle",
				"name": "A5 Wagyu Tenderloin with Black Truffle",
				"type": "food",
				"price": 280,
				"hunger": 80.0,
				"thirst": 15.0,
				"health": 5,
				"happiness": 32,
				"alcohol_level": 0,
				"description": "Melt-in-your-mouth prime beef served with Perigord truffle reduction."
			},
			{
				"id": "fd_caviar_course",
				"name": "Imperial Ossetra Caviar Service",
				"type": "food",
				"price": 220,
				"hunger": 40.0,
				"thirst": 10.0,
				"health": 4,
				"happiness": 26,
				"alcohol_level": 0,
				"description": "Chilled caviar on buckwheat blinis with crème fraîche and chives."
			},
			{
				"id": "fd_gold_dessert",
				"name": "24K Gold Leaf Dark Chocolate Dome",
				"type": "food",
				"price": 95,
				"hunger": 35.0,
				"thirst": 5.0,
				"health": 1,
				"happiness": 22,
				"alcohol_level": 0,
				"description": "Valrhona grand cru ganache melted with hot salted caramel."
			},
			{
				"id": "fd_sparkling_grape",
				"name": "Artisanal Sparkling White Grape Nectar",
				"type": "drink",
				"price": 45,
				"hunger": 5.0,
				"thirst": 50.0,
				"health": 3,
				"happiness": 16,
				"alcohol_level": 0,
				"description": "Alcohol-free cold-pressed reserve grape nectar with refined effervescence."
			},
			{
				"id": "fd_vintage_wine",
				"name": "Château Grand Cru Reserve (Glass)",
				"type": "drink",
				"price": 120,
				"hunger": 0.0,
				"thirst": 30.0,
				"health": 0,
				"happiness": 24,
				"alcohol_level": 20,
				"description": "Vintage oak-aged red blend with notes of blackberry and French oak (18+)."
			}
		],
		"activities": [
			{
				"id": "act_chefs_table",
				"name": "Sommelier Pairing & Chef's Tasting",
				"cost": 350,
				"happiness": 35,
				"social_gain": 20,
				"hunger_cost": 0.0,
				"thirst_cost": 0.0,
				"health_effect": 2,
				"is_vip": true,
				"description": "Private dining experience accompanied by the restaurant's master sommelier.",
				"outcomes": [
					"The executive chef visited your table to describe each course's origin. An unforgettable evening!",
					"The panoramic view of the sparkling metropolis below left you feeling on top of the world."
				]
			}
		]
	},

	# -------------------------------------------------------------------------
	# 4. CAFÉS AND COFFEE SHOPS
	# -------------------------------------------------------------------------
	"cf_daily_grind": {
		"id": "cf_daily_grind",
		"category": "cafes",
		"name": "The Daily Java Grind",
		"tagline": "Single-origin pour-overs, cozy velvet armchairs, and vinyl acoustics",
		"icon": "☕",
		"color": Color("#eab308"),
		"min_age": 0,
		"cover_charge": 0,
		"dress_code": "Casual",
		"operating_hours": "6:30 AM - 9:00 PM",
		"menu": [
			{
				"id": "cf_nitro_brew",
				"name": "Nitro Cold Brew Coffee",
				"type": "drink",
				"price": 7,
				"hunger": 0.0,
				"thirst": 45.0,
				"health": 1,
				"happiness": 10,
				"alcohol_level": 0,
				"description": "Velvety cascara-infused nitro brew poured fresh on tap."
			},
			{
				"id": "cf_oat_latte",
				"name": "Honey Cinnamon Oat Latte",
				"type": "drink",
				"price": 8,
				"hunger": 10.0,
				"thirst": 40.0,
				"health": 2,
				"happiness": 12,
				"alcohol_level": 0,
				"description": "Steamed organic oat milk, double espresso shot, wildflower honey and Ceylon cinnamon."
			},
			{
				"id": "cf_matcha_latte",
				"name": "Ceremonial Uji Matcha Latte",
				"type": "drink",
				"price": 8,
				"hunger": 8.0,
				"thirst": 40.0,
				"health": 3,
				"happiness": 11,
				"alcohol_level": 0,
				"description": "Vibrant Japanese matcha whisked with lightly sweetened oat milk."
			},
			{
				"id": "cf_croissant",
				"name": "Butter Almond Croissant",
				"type": "food",
				"price": 6,
				"hunger": 28.0,
				"thirst": 0.0,
				"health": 0,
				"happiness": 9,
				"alcohol_level": 0,
				"description": "Flaky French pastry filled with sweet almond frangipane paste."
			},
			{
				"id": "cf_avocado_toast",
				"name": "Sourdough Avocado Tartine",
				"type": "food",
				"price": 14,
				"hunger": 40.0,
				"thirst": 5.0,
				"health": 4,
				"happiness": 11,
				"alcohol_level": 0,
				"description": "Country sourdough toasted with mashed avocado, chili flakes, and microgreens."
			}
		],
		"activities": [
			{
				"id": "act_cafe_relax",
				"name": "Read Book in Velvet Armchair",
				"cost": 0,
				"happiness": 10,
				"social_gain": 0,
				"hunger_cost": 2.0,
				"thirst_cost": 4.0,
				"health_effect": 1,
				"is_vip": false,
				"description": "Curl up in a cozy corner with a captivating novel and acoustic jazz.",
				"outcomes": [
					"You lost yourself in good literature while warm coffee aroma filled the air. Peaceful and restoring.",
					"A gentle rain tapped the cafe window as you enjoyed a quiet moment of contemplation."
				]
			},
			{
				"id": "act_cafe_mingle",
				"name": "Chat with Fellow Coffee Lover",
				"cost": 0,
				"happiness": 12,
				"social_gain": 12,
				"hunger_cost": 0.0,
				"thirst_cost": 2.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Start an open, friendly conversation about music or books at the community table.",
				"outcomes": [
					"You shared a stimulating chat about indie literature with someone sitting across from you.",
					"You and a fellow patron exchanged recommendations for favorite books and cafes."
				]
			}
		]
	},

	# -------------------------------------------------------------------------
	# 5. BARS AND PUBS
	# -------------------------------------------------------------------------
	"bp_rusty_tap": {
		"id": "bp_rusty_tap",
		"category": "bars_pubs",
		"name": "The Rusty Foundry Pub",
		"tagline": "Hearty copper taps, wood dartboards, and local community spirits",
		"icon": "🍺",
		"color": Color("#f59e0b"),
		"min_age": 18,
		"cover_charge": 5,
		"dress_code": "Casual",
		"operating_hours": "4:00 PM - 2:00 AM",
		"menu": [
			{
				"id": "bp_craft_ipa",
				"name": "Hazy Copper Craft IPA",
				"type": "drink",
				"price": 9,
				"hunger": 5.0,
				"thirst": 35.0,
				"health": -1,
				"happiness": 12,
				"alcohol_level": 15,
				"description": "Locally brewed citrusy IPA with crisp hoppy bite (18+)."
			},
			{
				"id": "bp_whiskey_neat",
				"name": "Smoked Rye Whiskey (Double)",
				"type": "drink",
				"price": 16,
				"hunger": 0.0,
				"thirst": 15.0,
				"health": -3,
				"happiness": 15,
				"alcohol_level": 35,
				"description": "Small-batch charred oak rye whiskey served over an ice sphere (18+)."
			},
			{
				"id": "bp_virgin_mojito",
				"name": "Fresh Mint Virgin Mojito (Non-Alcoholic)",
				"type": "drink",
				"price": 8,
				"hunger": 0.0,
				"thirst": 50.0,
				"health": 2,
				"happiness": 11,
				"alcohol_level": 0,
				"description": "Refreshing crushed lime, fresh garden mint, pure cane sugar, and club soda."
			},
			{
				"id": "bp_ginger_beer",
				"name": "Artisanal Spicy Ginger Beer (Non-Alcoholic)",
				"type": "drink",
				"price": 6,
				"hunger": 0.0,
				"thirst": 45.0,
				"health": 2,
				"happiness": 9,
				"alcohol_level": 0,
				"description": "Fiery cold-pressed ginger root sparkling soda with fresh lime wedge."
			},
			{
				"id": "bp_pub_nachos",
				"name": "Cast-Iron Skillet Nachos",
				"type": "food",
				"price": 15,
				"hunger": 45.0,
				"thirst": 0.0,
				"health": -1,
				"happiness": 10,
				"alcohol_level": 0,
				"description": "Crispy corn tortilla chips baked with spicy jalapeños, black beans, and melted pepper jack."
			}
		],
		"activities": [
			{
				"id": "act_pub_trivia",
				"name": "Join Pub Trivia Night",
				"cost": 10,
				"happiness": 18,
				"social_gain": 15,
				"hunger_cost": 3.0,
				"thirst_cost": 5.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Team up with regulars to test your wits on history, cinema, and pop science.",
				"outcomes": [
					"Your team dominated the 90s cinema trivia round! The crowd applauded and bought your table snacks.",
					"You had a hilarious time debating trivia answers over drinks with friendly patrons."
				]
			},
			{
				"id": "act_pub_darts",
				"name": "Play Championship Darts",
				"cost": 0,
				"happiness": 12,
				"social_gain": 10,
				"hunger_cost": 2.0,
				"thirst_cost": 3.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Challenge a local to a classic game of 501 darts on the cork board.",
				"outcomes": [
					"Bullseye! You nailed the final throw and exchanged friendly high-fives with your opponent.",
					"A relaxed match of darts gave you an easy icebreaker with someone standing by the boards."
				]
			}
		]
	},

	# -------------------------------------------------------------------------
	# 6. NIGHTCLUBS
	# -------------------------------------------------------------------------
	"nc_pulse_2088": {
		"id": "nc_pulse_2088",
		"category": "nightclubs",
		"name": "Club Pulse 2088",
		"tagline": "Laser ceilings, holographic visuals, and bass shaking the floorboards",
		"icon": "🪩",
		"color": Color("#ec4899"),
		"min_age": 18,
		"cover_charge": 25,
		"dress_code": "Nightclub Chic",
		"operating_hours": "10:00 PM - 5:00 AM",
		"menu": [
			{
				"id": "nc_neon_cocktail",
				"name": "Electric Violet Glow Cocktail",
				"type": "drink",
				"price": 22,
				"hunger": 0.0,
				"thirst": 30.0,
				"health": -2,
				"happiness": 18,
				"alcohol_level": 25,
				"description": "Luminescent butterfly-pea gin cocktail served with dry ice mist (18+)."
			},
			{
				"id": "nc_tequila_shot",
				"name": "Premium Agave Tequila Shot",
				"type": "drink",
				"price": 14,
				"hunger": 0.0,
				"thirst": 10.0,
				"health": -3,
				"happiness": 14,
				"alcohol_level": 35,
				"description": "Aged blue agave tequila with sea salt and fresh lime wheel (18+)."
			},
			{
				"id": "nc_electro_elixir",
				"name": "Cyber Fuel Energy Spritz (Non-Alcoholic)",
				"type": "drink",
				"price": 12,
				"hunger": 0.0,
				"thirst": 50.0,
				"health": 1,
				"happiness": 14,
				"alcohol_level": 0,
				"description": "B-vitamin and taurine infused sparkling botanical punch to keep you dancing all night."
			},
			{
				"id": "nc_mineral_water",
				"name": "Chilled Sparkling Artesian Water",
				"type": "drink",
				"price": 7,
				"hunger": 0.0,
				"thirst": 60.0,
				"health": 3,
				"happiness": 8,
				"alcohol_level": 0,
				"description": "Crisp mineral spring water served with ice and lemon."
			},
			{
				"id": "nc_club_sliders",
				"name": "Midnight Truffle Beef Sliders",
				"type": "food",
				"price": 24,
				"hunger": 50.0,
				"thirst": 0.0,
				"health": -1,
				"happiness": 12,
				"alcohol_level": 0,
				"description": "Three mini brioche sliders with caramelized onions and truffle aioli."
			}
		],
		"activities": [
			{
				"id": "act_dance_floor",
				"name": "Hit the Center Dance Floor",
				"cost": 0,
				"happiness": 22,
				"social_gain": 18,
				"hunger_cost": 8.0,
				"thirst_cost": 15.0,
				"health_effect": 1,
				"is_vip": false,
				"description": "Surrender to the rhythm and dance amidst pulsing lasers and swirling smoke.",
				"outcomes": [
					"You stepped into the center of the dance circle! The crowd hyped you up as the DJ dropped the beat.",
					"Sweating and laughing with strangers under neon strobes, you felt an incredible rush of pure energy."
				]
			},
			{
				"id": "act_vip_lounge",
				"name": "Reserve Elevated VIP Booth",
				"cost": 500,
				"happiness": 38,
				"social_gain": 30,
				"hunger_cost": 0.0,
				"thirst_cost": 0.0,
				"health_effect": 0,
				"is_vip": true,
				"description": "Skip the line and gain exclusive velvet-rope skybox access with dedicated bottle service.",
				"outcomes": [
					"VIP hosts escorted you past the velvet rope to a plush leather booth overlooking the entire club. Pure luxury!",
					"Several high-profile nightlife influencers and artists stopped by your table to say hello."
				]
			}
		]
	},

	# -------------------------------------------------------------------------
	# 7. LOUNGES
	# -------------------------------------------------------------------------
	"lg_skyline_jazz": {
		"id": "lg_skyline_jazz",
		"category": "lounges",
		"name": "Blue Horizon Sky Lounge",
		"tagline": "Live acoustic saxophone, ambient fireplace, and panoramic skyline vistas",
		"icon": "🎷",
		"color": Color("#06b6d4"),
		"min_age": 18,
		"cover_charge": 15,
		"dress_code": "Smart Casual",
		"operating_hours": "6:00 PM - 2:00 AM",
		"menu": [
			{
				"id": "lg_smoked_old_fashioned",
				"name": "Smoked Hickory Old Fashioned",
				"type": "drink",
				"price": 20,
				"hunger": 0.0,
				"thirst": 25.0,
				"health": -2,
				"happiness": 16,
				"alcohol_level": 30,
				"description": "Bourbon stirred with Angostura bitters and torched orange peel under glass cloche (18+)."
			},
			{
				"id": "lg_lavender_mocktail",
				"name": "Sparkling Lavender French Blossom (Non-Alcoholic)",
				"type": "drink",
				"price": 14,
				"hunger": 0.0,
				"thirst": 50.0,
				"health": 2,
				"happiness": 14,
				"alcohol_level": 0,
				"description": "Wild culinary lavender syrup, fresh Meyer lemon, and effervescent elderflower soda."
			},
			{
				"id": "lg_charcuterie",
				"name": "Artisanal Cheese & Charcuterie Slate",
				"type": "food",
				"price": 32,
				"hunger": 50.0,
				"thirst": 5.0,
				"health": 2,
				"happiness": 16,
				"alcohol_level": 0,
				"description": "Aged Manchego, prosciutto di Parma, fig jam, and toasted rosemary crostini."
			},
			{
				"id": "lg_tuna_tartare",
				"name": "Yellowfin Ahi Tuna Tartare",
				"type": "food",
				"price": 26,
				"hunger": 40.0,
				"thirst": 5.0,
				"health": 4,
				"happiness": 15,
				"alcohol_level": 0,
				"description": "Diced sashimi tuna with sesame oil, avocado, and wonton crisps."
			}
		],
		"activities": [
			{
				"id": "act_listen_jazz",
				"name": "Relax by the Fireplace & Live Jazz Quartet",
				"cost": 0,
				"happiness": 18,
				"social_gain": 8,
				"hunger_cost": 2.0,
				"thirst_cost": 3.0,
				"health_effect": 1,
				"is_vip": false,
				"description": "Listen to soothing saxophone improvisations while admiring city headlights below.",
				"outcomes": [
					"The jazz saxophonist played a mesmerizing solo. The quiet murmur of conversation felt refined and effortless.",
					"Sitting near the warm hearth, you felt any residual stress melt away completely."
				]
			}
		]
	},

	# -------------------------------------------------------------------------
	# 8. ENTERTAINMENT VENUES
	# -------------------------------------------------------------------------
	"et_pixel_arcade": {
		"id": "et_pixel_arcade",
		"category": "entertainment",
		"name": "Pixel Matrix Arcade & Bowl",
		"tagline": "Neon glow bowling, rhythm dance cages, and holographic VR games",
		"icon": "🎮",
		"color": Color("#10b981"),
		"min_age": 0,
		"cover_charge": 20,
		"dress_code": "Casual",
		"operating_hours": "10:00 AM - Midnight",
		"menu": [
			{
				"id": "et_monster_pizza",
				"name": "Pepperoni & Hot Honey Flatbread Pizza",
				"type": "food",
				"price": 18,
				"hunger": 65.0,
				"thirst": 0.0,
				"health": 0,
				"happiness": 15,
				"alcohol_level": 0,
				"description": "Stone-baked flatbread loaded with mozzarella, cupping pepperoni, and chili-infused honey."
			},
			{
				"id": "et_popcorn_bucket",
				"name": "Warm Butter Movie Popcorn",
				"type": "food",
				"price": 9,
				"hunger": 30.0,
				"thirst": -5.0,
				"health": 0,
				"happiness": 10,
				"alcohol_level": 0,
				"description": "Jumbo bucket of freshly popped corn drizzled with warm golden butter."
			},
			{
				"id": "et_slushie",
				"name": "Blue Raspberry Mega Slushie",
				"type": "drink",
				"price": 7,
				"hunger": 10.0,
				"thirst": 45.0,
				"health": -1,
				"happiness": 12,
				"alcohol_level": 0,
				"description": "Electric blue icy slushie with an intense sweet berry explosion."
			},
			{
				"id": "et_craft_cider",
				"name": "Crisp Apple Draft Cider",
				"type": "drink",
				"price": 10,
				"hunger": 0.0,
				"thirst": 35.0,
				"health": 0,
				"happiness": 12,
				"alcohol_level": 15,
				"description": "Refreshing fermented orchard apple cider served cold on tap (18+)."
			}
		],
		"activities": [
			{
				"id": "act_neon_bowling",
				"name": "Glow-in-the-Dark Cosmic Bowling",
				"cost": 25,
				"happiness": 20,
				"social_gain": 20,
				"hunger_cost": 5.0,
				"thirst_cost": 8.0,
				"health_effect": 1,
				"is_vip": false,
				"description": "Rent cosmic bowling shoes and compete on the glow-in-the-dark blacklight lanes.",
				"outcomes": [
					"STRIKE! You rolled three consecutive strikes (a turkey!) and high-fived the adjacent lane.",
					"You had an absolute blast laughing over gutter balls and spinning trick shots."
				]
			},
			{
				"id": "act_rhythm_arcade",
				"name": "Dance Machine Rhythm Battle",
				"cost": 10,
				"happiness": 18,
				"social_gain": 14,
				"hunger_cost": 6.0,
				"thirst_cost": 10.0,
				"health_effect": 1,
				"is_vip": false,
				"description": "Step up to the dance pads and hit combo arrows to fast-paced electronic beats.",
				"outcomes": [
					"Full combo! A small crowd gathered around the machine clapping to your footwork rhythm.",
					"Heart pumping and feet flying, you set a brand new personal record on expert difficulty."
				]
			}
		]
	},

	# -------------------------------------------------------------------------
	# FAST-FOOD EXPANSIONS
	# -------------------------------------------------------------------------
	"ff_fuego_tacos": {
		"id": "ff_fuego_tacos",
		"category": "fast_food",
		"name": "El Fuego Cyber Tacos",
		"tagline": "Sizzling street tacos, crispy nachos, and fiery habanero salsa",
		"icon": "🌮",
		"color": Color("#ef4444"),
		"min_age": 0,
		"cover_charge": 0,
		"dress_code": "Casual",
		"operating_hours": "24/7",
		"menu": [
			{
				"id": "ft_street_tacos",
				"name": "Birria Street Tacos Trio",
				"type": "food",
				"price": 9,
				"hunger": 38.0,
				"thirst": 10.0,
				"health": -1,
				"happiness": 8,
				"alcohol_level": 0,
				"description": "Three slow-braised birria tacos with chopped cilantro, onions, and dipping consommé."
			},
			{
				"id": "ft_loaded_nachos",
				"name": "Loaded Cyber Nachos",
				"type": "food",
				"price": 11,
				"hunger": 42.0,
				"thirst": 5.0,
				"health": -2,
				"happiness": 9,
				"alcohol_level": 0,
				"description": "Crispy corn tortilla chips piled high with spicy beef, queso, jalapeños, and guacamole."
			},
			{
				"id": "ft_churros",
				"name": "Cinnamon Sugar Churro Bites",
				"type": "food",
				"price": 6,
				"hunger": 18.0,
				"thirst": 0.0,
				"health": -1,
				"happiness": 7,
				"alcohol_level": 0,
				"description": "Crispy fried pastry dusted with cinnamon sugar and warm dulce de leche."
			},
			{
				"id": "ft_horchata",
				"name": "Iced Sweet Horchata",
				"type": "drink",
				"price": 4,
				"hunger": 5.0,
				"thirst": 35.0,
				"health": 0,
				"happiness": 6,
				"alcohol_level": 0,
				"description": "Creamy cinnamon rice milk served over crushed ice."
			}
		],
		"activities": [
			{
				"id": "act_salsa_challenge",
				"name": "Fiery Ghost Pepper Salsa Challenge",
				"cost": 5,
				"happiness": 10,
				"social_gain": 8,
				"hunger_cost": 0.0,
				"thirst_cost": 15.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Test your heat tolerance with El Fuego's legendary ghost pepper salsa.",
				"outcomes": [
					"You powered through the scorching heat, earning cheers from fellow diners!",
					"The salsa scorched your palate, but the exhilarating adrenaline rush was unforgettable."
				]
			},
			{
				"id": "act_taco_feast",
				"name": "Late Night Street Taco Hangout",
				"cost": 0,
				"happiness": 5,
				"social_gain": 4,
				"hunger_cost": 0.0,
				"thirst_cost": 0.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Relax under colorful string lights while listening to vibrant urban beats.",
				"outcomes": [
					"You savored every bite as neon streetlamps bathed the patio in warm crimson glow.",
					"The lively music and aroma of sizzling carne asada lifted your spirits."
				]
			}
		]
	},

	"ff_golden_cluck": {
		"id": "ff_golden_cluck",
		"category": "fast_food",
		"name": "Golden Cluck Fried Chicken",
		"tagline": "Crispy double-battered chicken, honey butter biscuits, and thick milkshakes",
		"icon": "🍗",
		"color": Color("#f59e0b"),
		"min_age": 0,
		"cover_charge": 0,
		"dress_code": "Casual",
		"operating_hours": "10:00 - 02:00",
		"menu": [
			{
				"id": "gc_chicken_box",
				"name": "4-Piece Golden Crispy Combo",
				"type": "food",
				"price": 12,
				"hunger": 48.0,
				"thirst": 20.0,
				"health": -2,
				"happiness": 9,
				"alcohol_level": 0,
				"description": "Double-dredged crispy fried chicken, seasoned fries, and a fountain drink."
			},
			{
				"id": "gc_spicy_sandwich",
				"name": "Nashville Firebird Sandwich",
				"type": "food",
				"price": 10,
				"hunger": 40.0,
				"thirst": 10.0,
				"health": -1,
				"happiness": 8,
				"alcohol_level": 0,
				"description": "Fried chicken breast dipped in fiery chili oil, topped with pickles and coleslaw."
			},
			{
				"id": "gc_biscuits",
				"name": "Honey Butter Biscuits (3pc)",
				"type": "food",
				"price": 5,
				"hunger": 22.0,
				"thirst": 0.0,
				"health": -1,
				"happiness": 6,
				"alcohol_level": 0,
				"description": "Flaky buttermilk biscuits drizzled with melted sweet wildflower honey butter."
			},
			{
				"id": "gc_caramel_shake",
				"name": "Salted Caramel Waffle Shake",
				"type": "drink",
				"price": 6,
				"hunger": 14.0,
				"thirst": 25.0,
				"health": -1,
				"happiness": 9,
				"alcohol_level": 0,
				"description": "Rich vanilla ice cream blended with salted caramel syrup and waffle cone pieces."
			}
		],
		"activities": [
			{
				"id": "act_cluck_wing_duel",
				"name": "Atomic Hot Wing Showdown",
				"cost": 8,
				"happiness": 12,
				"social_gain": 10,
				"hunger_cost": 0.0,
				"thirst_cost": 12.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Go wing-for-wing against a brave friend or fellow patron.",
				"outcomes": [
					"You conquered the final atomic wing without reaching for milk, earning victorious applause!",
					"The burning spice tested your limits, leaving you sweating and laughing together."
				]
			}
		]
	},

	# -------------------------------------------------------------------------
	# CASUAL RESTAURANTS EXPANSIONS
	# -------------------------------------------------------------------------
	"cd_bella_trattoria": {
		"id": "cd_bella_trattoria",
		"category": "casual_dining",
		"name": "Bella Vista Italian Trattoria",
		"tagline": "Wood-fired artisan pizzas, hand-rolled pasta, and rustic Tuscan warmth",
		"icon": "🍕",
		"color": Color("#e11d48"),
		"min_age": 0,
		"cover_charge": 0,
		"dress_code": "Smart Casual",
		"operating_hours": "11:30 - 23:00",
		"menu": [
			{
				"id": "bv_woodfired_pizza",
				"name": "Wood-Fired Pizza Margherita",
				"type": "food",
				"price": 22,
				"hunger": 55.0,
				"thirst": 15.0,
				"health": 0,
				"happiness": 14,
				"alcohol_level": 0,
				"description": "San Marzano tomato sauce, fresh mozzarella di bufala, basil, and extra virgin olive oil."
			},
			{
				"id": "bv_fettuccine_alfredo",
				"name": "Handmade Truffle Fettuccine",
				"type": "food",
				"price": 26,
				"hunger": 52.0,
				"thirst": 10.0,
				"health": 0,
				"happiness": 16,
				"alcohol_level": 0,
				"description": "Silky pasta ribbons tossed in aged Parmigiano-Reggiano cream and black truffle shavings."
			},
			{
				"id": "bv_calamari",
				"name": "Crispy Calamari Fritti",
				"type": "food",
				"price": 16,
				"hunger": 28.0,
				"thirst": 5.0,
				"health": 0,
				"happiness": 10,
				"alcohol_level": 0,
				"description": "Golden fried tender squid rings served with spicy marinara and lemon wedges."
			},
			{
				"id": "bv_tiramisu",
				"name": "Classic Espresso Tiramisu",
				"type": "food",
				"price": 11,
				"hunger": 18.0,
				"thirst": 5.0,
				"health": 0,
				"happiness": 12,
				"alcohol_level": 0,
				"description": "Espresso-soaked ladyfingers layered with whipped mascarpone cream and cocoa."
			},
			{
				"id": "bv_chianti_wine",
				"name": "Tuscan Chianti Classico",
				"type": "drink",
				"price": 14,
				"hunger": 0.0,
				"thirst": 20.0,
				"health": 0,
				"happiness": 12,
				"alcohol_level": 2,
				"description": "A full-bodied ruby red wine with notes of wild cherries and toasted oak."
			}
		],
		"activities": [
			{
				"id": "act_pizza_tossing",
				"name": "Artisan Pizza Tossing Workshop",
				"cost": 30,
				"happiness": 20,
				"social_gain": 15,
				"hunger_cost": 5.0,
				"thirst_cost": 5.0,
				"health_effect": 1,
				"is_vip": false,
				"description": "Learn the authentic Neapolitan technique of hand-stretching dough with the pizzaiolo.",
				"outcomes": [
					"You spun dough in the air like a maestro, baking a golden custom pizza to perfection!",
					"Flour dusted your apron as you laughed and enjoyed creating your own artisan pie."
				]
			},
			{
				"id": "act_candlelight_toast",
				"name": "Candlelight Family & Friends Toast",
				"cost": 15,
				"happiness": 16,
				"social_gain": 18,
				"hunger_cost": 0.0,
				"thirst_cost": 5.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Raise a glass under ambient fairy lights and checkered tablecloths.",
				"outcomes": [
					"Warm laughter and touching toasts filled the cozy dining room, deepening your bonds.",
					"The rustic charm and fragrant aroma of roasted garlic made for an unforgettable evening."
				]
			}
		]
	},

	"cd_seoul_bbq": {
		"id": "cd_seoul_bbq",
		"category": "casual_dining",
		"name": "Seoul Smokehouse Korean BBQ",
		"tagline": "Tabletop sizzling Galbi ribs, crisp kimchi, and ice-cold soju",
		"icon": "🥩",
		"color": Color("#ea580c"),
		"min_age": 0,
		"cover_charge": 0,
		"dress_code": "Casual",
		"operating_hours": "12:00 - 01:00",
		"menu": [
			{
				"id": "sb_prime_galbi",
				"name": "Marinated Prime Beef Galbi",
				"type": "food",
				"price": 32,
				"hunger": 60.0,
				"thirst": 15.0,
				"health": 0,
				"happiness": 18,
				"alcohol_level": 0,
				"description": "Sweet soy and garlic marinated short ribs grilled sizzling hot at your table grill."
			},
			{
				"id": "sb_pork_belly",
				"name": "Thick-Cut Kurobuta Pork Belly",
				"type": "food",
				"price": 24,
				"hunger": 50.0,
				"thirst": 10.0,
				"health": -1,
				"happiness": 14,
				"alcohol_level": 0,
				"description": "Crispy charred pork belly served with sesame oil salt and fresh perilla leaves."
			},
			{
				"id": "sb_kimchi_pancake",
				"name": "Crispy Seafood Kimchi Jeon",
				"type": "food",
				"price": 16,
				"hunger": 30.0,
				"thirst": 5.0,
				"health": 0,
				"happiness": 11,
				"alcohol_level": 0,
				"description": "Crispy golden savory pancake packed with squid, scallions, and aged tangy kimchi."
			},
			{
				"id": "sb_peach_soju",
				"name": "Chilled Peach Soju Bottle",
				"type": "drink",
				"price": 12,
				"hunger": 0.0,
				"thirst": 25.0,
				"health": 0,
				"happiness": 14,
				"alcohol_level": 2,
				"description": "Smooth Korean distilled spirit infused with sweet aromatic white peach."
			}
		],
		"activities": [
			{
				"id": "act_grill_master",
				"name": "Tabletop Grilling Master Duel",
				"cost": 15,
				"happiness": 16,
				"social_gain": 16,
				"hunger_cost": 4.0,
				"thirst_cost": 6.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Take control of the tongs and scissors to grill meat to mouthwatering perfection.",
				"outcomes": [
					"You expertly flipped the ribs at the perfect sear, earning praised clinks from everyone at the table!",
					"The sizzle of marbled beef on the iron grate brought everyone closer together in celebration."
				]
			},
			{
				"id": "act_soju_cheers",
				"name": "Soju Bomb Countdown Cheers",
				"cost": 18,
				"happiness": 18,
				"social_gain": 16,
				"hunger_cost": 0.0,
				"thirst_cost": 10.0,
				"health_effect": -1,
				"is_vip": false,
				"description": "Drop a shot of soju into an ice-cold draft beer with a synchronized table slam.",
				"outcomes": [
					"'Gunbae!' The table erupted in cheers as the glasses clinked and fizzed to life.",
					"Spirits soared high as lively music and savory barbecue aromas filled the dining hall."
				]
			}
		]
	},

	# -------------------------------------------------------------------------
	# FINE-DINING EXPANSIONS
	# -------------------------------------------------------------------------
	"fd_kurofune_omakase": {
		"id": "fd_kurofune_omakase",
		"category": "fine_dining",
		"name": "Kurofune Grand Omakase",
		"tagline": "Exclusive 12-seat cedar sushi bar with imported Toyosu bluefin tuna",
		"icon": "🍣",
		"color": Color("#0284c7"),
		"min_age": 16,
		"cover_charge": 50,
		"dress_code": "Formal",
		"operating_hours": "17:30 - 22:30",
		"menu": [
			{
				"id": "ko_omakase_tasting",
				"name": "Grand 15-Course Omakase",
				"type": "food",
				"price": 220,
				"hunger": 65.0,
				"thirst": 20.0,
				"health": 2,
				"happiness": 32,
				"alcohol_level": 0,
				"description": "Master chef curated seasonal nigiri including otoro, uni, and abalone with caviar."
			},
			{
				"id": "ko_a5_wagyu",
				"name": "Seared A5 Miyazaki Wagyu Nigiri",
				"type": "food",
				"price": 65,
				"hunger": 25.0,
				"thirst": 5.0,
				"health": 1,
				"happiness": 22,
				"alcohol_level": 0,
				"description": "Torch-seared A5 wagyu with truffle soy glaze and fresh wasabi that melts on the tongue."
			},
			{
				"id": "ko_hokkaido_uni",
				"name": "Hokkaido Sea Urchin & Ossetra Caviar",
				"type": "food",
				"price": 75,
				"hunger": 20.0,
				"thirst": 5.0,
				"health": 2,
				"happiness": 25,
				"alcohol_level": 0,
				"description": "Sweet, creamy sea urchin served on crispy nori topped with royal Ossetra caviar."
			},
			{
				"id": "ko_rare_sake",
				"name": "Dassai 23 Junmai Daiginjo",
				"type": "drink",
				"price": 70,
				"hunger": 0.0,
				"thirst": 20.0,
				"health": 0,
				"happiness": 24,
				"alcohol_level": 3,
				"description": "Ultra-premium sake milled down to 23%, offering delicate floral aromas of melon and peach."
			}
		],
		"activities": [
			{
				"id": "act_sushi_appreciation",
				"name": "Private Chef Counter Presentation",
				"cost": 80,
				"happiness": 26,
				"social_gain": 20,
				"hunger_cost": 0.0,
				"thirst_cost": 0.0,
				"health_effect": 1,
				"is_vip": true,
				"description": "Watch the itamae master perform precise knife cuts on whole pristine bluefin tuna.",
				"outcomes": [
					"The chef explained the pedigree and cure time of each cut, transforming dinner into an art exhibition.",
					"Every delicate mouthful opened a symphony of ocean flavors and exquisite culinary heritage."
				]
			}
		]
	},

	"fd_chateau_imperial": {
		"id": "fd_chateau_imperial",
		"category": "fine_dining",
		"name": "Château Imperial Grand Steakhouse",
		"tagline": "Gilded chandeliers, dry-aged prime Tomahawk cuts, and premier Bordeaux vintages",
		"icon": "🥩",
		"color": Color("#831843"),
		"min_age": 18,
		"cover_charge": 60,
		"dress_code": "Black Tie / Formal",
		"operating_hours": "18:00 - 23:30",
		"menu": [
			{
				"id": "ci_tomahawk",
				"name": "45-Day Dry-Aged Tomahawk (38oz)",
				"type": "food",
				"price": 195,
				"hunger": 75.0,
				"thirst": 15.0,
				"health": 0,
				"happiness": 30,
				"alcohol_level": 0,
				"description": "Bone-in ribeye roasted with roasted marrow butter, rosemary, and smoked flaked sea salt."
			},
			{
				"id": "ci_foie_gras",
				"name": "Pan-Seared Duck Foie Gras",
				"type": "food",
				"price": 58,
				"hunger": 22.0,
				"thirst": 5.0,
				"health": -1,
				"happiness": 20,
				"alcohol_level": 0,
				"description": "Rich caramelized foie gras with brioche toast points and fig-balsamic reduction."
			},
			{
				"id": "ci_oysters_rockefeller",
				"name": "Oysters Rockefeller with Champagne",
				"type": "food",
				"price": 48,
				"hunger": 20.0,
				"thirst": 10.0,
				"health": 1,
				"happiness": 18,
				"alcohol_level": 0,
				"description": "Baked coastal oysters with creamed spinach, herbsaint, and pernod breadcrumbs."
			},
			{
				"id": "ci_bordeaux_vintage",
				"name": "Château Margaux 2015 Grand Cru",
				"type": "drink",
				"price": 110,
				"hunger": 0.0,
				"thirst": 20.0,
				"health": 0,
				"happiness": 25,
				"alcohol_level": 3,
				"description": "Legendary first growth Bordeaux with seamless velvet tannins, dark cassis, and violets."
			}
		],
		"activities": [
			{
				"id": "act_sommelier_decanting",
				"name": "Sommelier Vintage Decanting Ritual",
				"cost": 70,
				"happiness": 24,
				"social_gain": 18,
				"hunger_cost": 0.0,
				"thirst_cost": 5.0,
				"health_effect": 0,
				"is_vip": true,
				"description": "A master sommelier aerates a library vintage through lead-free crystal under candlelight.",
				"outcomes": [
					"The sommelier presented the cork and poured ruby nectar that bloomed with cedar and berry aromatics.",
					"Surrounded by crystal chandeliers and plush velvet banquettes, you felt like nobility."
				]
			}
		]
	},

	# -------------------------------------------------------------------------
	# CAFÉS & COFFEE SHOPS EXPANSIONS
	# -------------------------------------------------------------------------
	"cf_purrfect_cat": {
		"id": "cf_purrfect_cat",
		"category": "cafes",
		"name": "Purrfect Paws Cat Café",
		"tagline": "Playful rescue kittens, velvet cushions, matcha lattes, and purr therapy",
		"icon": "🐱",
		"color": Color("#f472b6"),
		"min_age": 0,
		"cover_charge": 8,
		"dress_code": "Casual",
		"operating_hours": "09:00 - 20:00",
		"menu": [
			{
				"id": "pc_strawberry_matcha",
				"name": "Iced Strawberry Matcha Latte",
				"type": "drink",
				"price": 8,
				"hunger": 10.0,
				"thirst": 40.0,
				"health": 1,
				"happiness": 14,
				"alcohol_level": 0,
				"description": "Layered ceremonial Uji matcha, fresh organic strawberry puree, and creamy oat milk."
			},
			{
				"id": "pc_cat_cupcake",
				"name": "Fluffy Kitten Paw Cupcake",
				"type": "food",
				"price": 6,
				"hunger": 16.0,
				"thirst": 0.0,
				"health": 0,
				"happiness": 11,
				"alcohol_level": 0,
				"description": "Vanilla sponge cupcake with soft strawberry fondant molded like a kitten paw."
			},
			{
				"id": "pc_salmon_biscuit",
				"name": "Salmon Mousse Brioche Biscuit",
				"type": "food",
				"price": 7,
				"hunger": 22.0,
				"thirst": 5.0,
				"health": 1,
				"happiness": 10,
				"alcohol_level": 0,
				"description": "Flaky French pastry filled with smoked salmon pate and herb cream cheese."
			},
			{
				"id": "pc_chamomile_calm",
				"name": "Organic Chamomile Blossom Tea",
				"type": "drink",
				"price": 5,
				"hunger": 0.0,
				"thirst": 35.0,
				"health": 2,
				"happiness": 10,
				"alcohol_level": 0,
				"description": "Soothing whole Egyptian chamomile blossoms with a drizzle of clover honey."
			}
		],
		"activities": [
			{
				"id": "act_kitten_cuddle",
				"name": "Rescue Kitten Play & Cuddle Therapy",
				"cost": 0,
				"happiness": 22,
				"social_gain": 12,
				"hunger_cost": 2.0,
				"thirst_cost": 2.0,
				"health_effect": 2,
				"is_vip": false,
				"description": "Sit on a cozy beanbag while curious rescue cats curl up on your lap and purr.",
				"outcomes": [
					"A tiny calico kitten curled up in your lap, purring softly as you gently scratched behind its ears.",
					"The rhythmic purrs and gentle paw rubs melted away your stress and filled your heart with joy."
				]
			},
			{
				"id": "act_cat_photo",
				"name": "Kitten Photo Session",
				"cost": 12,
				"happiness": 15,
				"social_gain": 14,
				"hunger_cost": 0.0,
				"thirst_cost": 0.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Snap adorable candid pictures of playing kittens for your social gallery.",
				"outcomes": [
					"You snapped an impossibly cute photo of a sleeping tabby kitten that gained lots of smiles!",
					"The staff smiled as you waved a feather wand, making three playful kittens leap in unison."
				]
			}
		]
	},

	"cf_cyber_tea_bakery": {
		"id": "cf_cyber_tea_bakery",
		"category": "cafes",
		"name": "Moonlit Cyber Tea & Board Games",
		"tagline": "Artisan brown sugar boba, matcha crêpe cakes, and shelves of tabletop board games",
		"icon": "🧋",
		"color": Color("#14b8a6"),
		"min_age": 0,
		"cover_charge": 0,
		"dress_code": "Casual",
		"operating_hours": "10:00 - 00:00",
		"menu": [
			{
				"id": "ct_tiger_boba",
				"name": "Tiger Brown Sugar Roasted Boba",
				"type": "drink",
				"price": 9,
				"hunger": 15.0,
				"thirst": 35.0,
				"health": -1,
				"happiness": 12,
				"alcohol_level": 0,
				"description": "Chewy tapioca pearls simmered in caramelized brown sugar syrup with fresh cream."
			},
			{
				"id": "ct_matcha_crepe",
				"name": "Mille-Crêpe Green Tea Cake",
				"type": "food",
				"price": 11,
				"hunger": 25.0,
				"thirst": 5.0,
				"health": 0,
				"happiness": 13,
				"alcohol_level": 0,
				"description": "Twenty micro-thin paper crêpes layered with rich green tea cream."
			},
			{
				"id": "ct_taro_cheese",
				"name": "Taro Foam Jasmine Tea",
				"type": "drink",
				"price": 8,
				"hunger": 8.0,
				"thirst": 38.0,
				"health": 0,
				"happiness": 10,
				"alcohol_level": 0,
				"description": "Fragrant jasmine green tea topped with salted Himalayan cheese foam and purple taro."
			},
			{
				"id": "ct_custard_buns",
				"name": "Steamed Golden Custard Buns (2pc)",
				"type": "food",
				"price": 7,
				"hunger": 24.0,
				"thirst": 0.0,
				"health": 0,
				"happiness": 9,
				"alcohol_level": 0,
				"description": "Pillowy steamed white buns filled with molten sweet egg yolk custard."
			}
		],
		"activities": [
			{
				"id": "act_board_game_match",
				"name": "Tabletop Board Game Strategy Match",
				"cost": 8,
				"happiness": 16,
				"social_gain": 16,
				"hunger_cost": 2.0,
				"thirst_cost": 4.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Pick a boxed strategy board game from the library wall and compete.",
				"outcomes": [
					"You pulled off a brilliant tactical move, capturing the game board and drawing hearty cheers!",
					"Hours flew by over cups of sweet boba as your group laughed through every close turn."
				]
			},
			{
				"id": "act_study_session",
				"name": "Co-Working & Study Session",
				"cost": 0,
				"happiness": 8,
				"social_gain": 4,
				"hunger_cost": 2.0,
				"thirst_cost": 3.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Plug in your laptop, put on lo-fi beats, and grind out productive focus time.",
				"outcomes": [
					"Surrounded by warm lanterns and soft keyboard clicks, you accomplished a major study goal.",
					"Your focus was sharp, your notes were organized, and your smarts felt honed and refreshed."
				]
			}
		]
	},

	# -------------------------------------------------------------------------
	# BARS & PUBS EXPANSIONS
	# -------------------------------------------------------------------------
	"bp_overtime_sports": {
		"id": "bp_overtime_sports",
		"category": "bars_pubs",
		"name": "Overtime Champions Sports Bar",
		"tagline": "360-degree stadium screens, spicy buffalo wings, craft draft towers, and lively fan chants",
		"icon": "🏈",
		"color": Color("#2563eb"),
		"min_age": 18,
		"cover_charge": 0,
		"dress_code": "Casual",
		"operating_hours": "11:00 - 02:00",
		"menu": [
			{
				"id": "os_buffalo_wings",
				"name": "Jumbo Crispy Buffalo Wings (12pc)",
				"type": "food",
				"price": 18,
				"hunger": 48.0,
				"thirst": 10.0,
				"health": -2,
				"happiness": 13,
				"alcohol_level": 0,
				"description": "Crispy fried wings tossed in tangy cayenne pepper butter sauce with blue cheese dressing."
			},
			{
				"id": "os_beer_flight",
				"name": "Local Craft Brewery Tasting Flight",
				"type": "drink",
				"price": 16,
				"hunger": 0.0,
				"thirst": 30.0,
				"health": 0,
				"happiness": 14,
				"alcohol_level": 2,
				"description": "Four distinct samplers of Hazy IPA, Belgian Blonde, Amber Ale, and Oatmeal Stout."
			},
			{
				"id": "os_stadium_nachos",
				"name": "Loaded Stadium Nachos Tower",
				"type": "food",
				"price": 15,
				"hunger": 42.0,
				"thirst": 5.0,
				"health": -2,
				"happiness": 11,
				"alcohol_level": 0,
				"description": "Tortilla chips smothered in melted pepper jack, pickled jalapeños, and pulled brisket."
			},
			{
				"id": "os_beer_tower",
				"name": "3-Liter Tabletop Beer Tower",
				"type": "drink",
				"price": 38,
				"hunger": 0.0,
				"thirst": 50.0,
				"health": -1,
				"happiness": 20,
				"alcohol_level": 3,
				"description": "Giant self-dispensing chilled draft tower for table celebrations and victory cheers."
			}
		],
		"activities": [
			{
				"id": "act_watch_championship",
				"name": "Watch Championship Final on Big Screen",
				"cost": 15,
				"happiness": 20,
				"social_gain": 18,
				"hunger_cost": 3.0,
				"thirst_cost": 8.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Cheer alongside passionate crowds as the championship match plays out in 4K resolution.",
				"outcomes": [
					"A game-winning goal in the final seconds caused the entire bar to erupt in pandemonium!",
					"High-fives flew across tables as everyone celebrated the unforgettable clutch victory."
				]
			},
			{
				"id": "act_darts_tournament",
				"name": "Pub Darts Championship Duel",
				"cost": 8,
				"happiness": 14,
				"social_gain": 12,
				"hunger_cost": 1.0,
				"thirst_cost": 3.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Step up to the cork board and throw three steel-tip darts for the bullseye.",
				"outcomes": [
					"Triple 20! You nailed the inner ring with surgical precision, taking the match victory.",
					"You threw a solid grouping and shared laughs with your opponent over a cold brew."
				]
			}
		]
	},

	"bp_velvet_speakeasy": {
		"id": "bp_velvet_speakeasy",
		"category": "bars_pubs",
		"name": "Velvet Keyhole Secret Speakeasy",
		"tagline": "Hidden behind an antique grandfather clock; prohibition craft mixology and candlelit allure",
		"icon": "🗝️",
		"color": Color("#7c3aed"),
		"min_age": 21,
		"cover_charge": 20,
		"dress_code": "Smart Casual",
		"operating_hours": "19:00 - 03:00",
		"menu": [
			{
				"id": "vk_old_fashioned",
				"name": "Smoked Cherrywood Old Fashioned",
				"type": "drink",
				"price": 24,
				"hunger": 0.0,
				"thirst": 20.0,
				"health": 0,
				"happiness": 16,
				"alcohol_level": 3,
				"description": "Bourbon infused with demerara and aromatic bitters, smoked table-side with oak shavings."
			},
			{
				"id": "vk_lavender_fizz",
				"name": "Lavender Empress Gin Fizz",
				"type": "drink",
				"price": 22,
				"hunger": 0.0,
				"thirst": 25.0,
				"health": 0,
				"happiness": 14,
				"alcohol_level": 2,
				"description": "Botanical indigo gin, wild lavender blossom syrup, egg white foam, and club soda."
			},
			{
				"id": "vk_charcuterie",
				"name": "Artisanal Truffle Charcuterie Board",
				"type": "food",
				"price": 28,
				"hunger": 32.0,
				"thirst": 5.0,
				"health": 1,
				"happiness": 15,
				"alcohol_level": 0,
				"description": "Prosciutto di Parma, black truffle pecorino, honeycomb, and rosemary crisps."
			},
			{
				"id": "vk_mezcal_negroni",
				"name": "Smoky Oaxacan Mezcal Negroni",
				"type": "drink",
				"price": 25,
				"hunger": 0.0,
				"thirst": 20.0,
				"health": 0,
				"happiness": 15,
				"alcohol_level": 3,
				"description": "Artisanal smoky mezcal, Campari, sweet vermouth, and flamed orange peel."
			}
		],
		"activities": [
			{
				"id": "act_mixology_masterclass",
				"name": "Private Prohibition Mixology Session",
				"cost": 60,
				"happiness": 24,
				"social_gain": 18,
				"hunger_cost": 0.0,
				"thirst_cost": 10.0,
				"health_effect": 0,
				"is_vip": true,
				"description": "Step behind the marble bar with the head mixologist and craft custom concoctions.",
				"outcomes": [
					"You learned the delicate balance of bitters, ice dilution, and shaking technique like a pro.",
					"The bartender praised your palate and served your custom cocktail to fellow patrons to enjoy."
				]
			}
		]
	},

	# -------------------------------------------------------------------------
	# NIGHTCLUBS EXPANSIONS
	# -------------------------------------------------------------------------
	"nc_techno_vault": {
		"id": "nc_techno_vault",
		"category": "nightclubs",
		"name": "Sub-Zero Underground Techno Vault",
		"tagline": "Industrial concrete warehouse, pounding 140 BPM Berlin techno, strobe tunnels, and hypnotic trance",
		"icon": "⚡",
		"color": Color("#6366f1"),
		"min_age": 18,
		"cover_charge": 30,
		"dress_code": "Club / All Black",
		"operating_hours": "23:00 - 08:00",
		"menu": [
			{
				"id": "tv_vodka_energy",
				"name": "Electro-Stim Vodka Red Bull",
				"type": "drink",
				"price": 18,
				"hunger": 0.0,
				"thirst": 30.0,
				"health": -1,
				"happiness": 16,
				"alcohol_level": 3,
				"description": "Double shot of premium grain vodka poured over chilled taurine energy drink."
			},
			{
				"id": "tv_tequila_shot",
				"name": "Silver Agave Tequila Shot",
				"type": "drink",
				"price": 14,
				"hunger": 0.0,
				"thirst": 15.0,
				"health": -1,
				"happiness": 12,
				"alcohol_level": 3,
				"description": "Straight chilled silver tequila slammed back with sea salt and fresh lime wedge."
			},
			{
				"id": "tv_electrolyte_elixir",
				"name": "Vault Electrolyte Hydro-Shot",
				"type": "drink",
				"price": 8,
				"hunger": 0.0,
				"thirst": 45.0,
				"health": 1,
				"happiness": 8,
				"alcohol_level": 0,
				"description": "Chilled mineral water infused with magnesium, citrus, and electrolytes for endurance."
			},
			{
				"id": "tv_pizza_slice",
				"name": "Late Night Fuel Pizza Slice",
				"type": "food",
				"price": 8,
				"hunger": 26.0,
				"thirst": 0.0,
				"health": -1,
				"happiness": 8,
				"alcohol_level": 0,
				"description": "Greasy, delicious pepperoni slice grabbed quickly at the back bar counter."
			}
		],
		"activities": [
			{
				"id": "act_rave_dancefloor",
				"name": "Surrender to the Industrial Techno Bass",
				"cost": 15,
				"happiness": 25,
				"social_gain": 18,
				"hunger_cost": 8.0,
				"thirst_cost": 15.0,
				"health_effect": 1,
				"is_vip": false,
				"description": "Immerse yourself deep in the strobe lights and thunderous, hypnotic 140 BPM beats.",
				"outcomes": [
					"The relentless bass vibrated your chest as you lost all sense of time in pure dance euphoria.",
					"Surrounded by dancing silhouettes and laser beams, you felt unstoppable electrical energy."
				]
			},
			{
				"id": "act_stage_front",
				"name": "Rave at the Main DJ Altar",
				"cost": 25,
				"happiness": 22,
				"social_gain": 20,
				"hunger_cost": 5.0,
				"thirst_cost": 12.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Push your way to the front railing right beneath the guest headliner DJ.",
				"outcomes": [
					"The DJ dropped a thunderous new track and pointed directly at you as CO2 cannons blasted the room!",
					"You cheered alongside hundreds of ravers with hands raised high toward the strobe ceiling."
				]
			}
		]
	},

	"nc_solaris_rooftop": {
		"id": "nc_solaris_rooftop",
		"category": "nightclubs",
		"name": "Solaris Sunset Rooftop Beach Club",
		"tagline": "Skyline infinity pool, sunset tropical deep house, VIP cabanas, and champagne fountains",
		"icon": "🍾",
		"color": Color("#f59e0b"),
		"min_age": 21,
		"cover_charge": 45,
		"dress_code": "Upscale Summer Chic",
		"operating_hours": "14:00 - 02:00",
		"menu": [
			{
				"id": "sr_dom_perignon",
				"name": "Dom Pérignon Vintage Champagne (Bottle)",
				"type": "drink",
				"price": 350,
				"hunger": 0.0,
				"thirst": 30.0,
				"health": 0,
				"happiness": 40,
				"alcohol_level": 3,
				"description": "The gold standard of prestige champagne with brioche, almond, and vibrant minerality."
			},
			{
				"id": "sr_watermelon_frose",
				"name": "Frozen Watermelon Frosé",
				"type": "drink",
				"price": 22,
				"hunger": 0.0,
				"thirst": 35.0,
				"health": 0,
				"happiness": 16,
				"alcohol_level": 2,
				"description": "Blended Provençal rosé, fresh watermelon juice, and organic agave nectar."
			},
			{
				"id": "sr_caviar_oysters",
				"name": "Imperial Caviar & Pacific Oysters",
				"type": "food",
				"price": 95,
				"hunger": 25.0,
				"thirst": 10.0,
				"health": 2,
				"happiness": 28,
				"alcohol_level": 0,
				"description": "Half-dozen freshly shucked oysters topped with Siberian caviar and yuzu pearls."
			},
			{
				"id": "sr_coconut_mojito",
				"name": "Fresh Coconut Mojito",
				"type": "drink",
				"price": 20,
				"hunger": 0.0,
				"thirst": 35.0,
				"health": 0,
				"happiness": 15,
				"alcohol_level": 2,
				"description": "Light rum muddled with fresh spearmint leaves, coconut water, and lime juice."
			}
		],
		"activities": [
			{
				"id": "act_vip_cabana",
				"name": "Reserve VIP Skyline Cabana",
				"cost": 450,
				"happiness": 45,
				"social_gain": 35,
				"hunger_cost": 0.0,
				"thirst_cost": 0.0,
				"health_effect": 0,
				"is_vip": true,
				"description": "Enjoy private poolside cabana service with dedicated hosts and fruit platters.",
				"outcomes": [
					"Lounging on plush white daybeds overlooking the glowing sunset skyline, you lived like a superstar.",
					"Your companion beamed with delight as sparklers and chilled bottles were brought to your table."
				]
			},
			{
				"id": "act_infinity_swim",
				"name": "Sunset Infinity Pool Dip",
				"cost": 30,
				"happiness": 24,
				"social_gain": 16,
				"hunger_cost": 4.0,
				"thirst_cost": 6.0,
				"health_effect": 1,
				"is_vip": false,
				"description": "Take a swim right up to the glass edge overlooking the sprawling city below.",
				"outcomes": [
					"Warm water lapped your shoulders as the golden sun dipped beneath the metropolitan skyline.",
					"A tropical house track played softly overhead, creating an ethereal, picture-perfect moment."
				]
			}
		]
	},

	# -------------------------------------------------------------------------
	# LOUNGES EXPANSIONS
	# -------------------------------------------------------------------------
	"lg_midnight_jazz": {
		"id": "lg_midnight_jazz",
		"category": "lounges",
		"name": "The Midnight Saxophone Jazz Cellar",
		"tagline": "Low red lamps, velvety acoustics, live double-bass quartets, and vintage single-malt whiskeys",
		"icon": "🎺",
		"color": Color("#b45309"),
		"min_age": 18,
		"cover_charge": 15,
		"dress_code": "Smart Casual",
		"operating_hours": "19:30 - 02:30",
		"menu": [
			{
				"id": "mj_single_malt",
				"name": "Macallan 18-Year Double Cask",
				"type": "drink",
				"price": 34,
				"hunger": 0.0,
				"thirst": 20.0,
				"health": 0,
				"happiness": 18,
				"alcohol_level": 3,
				"description": "Rich, smooth single malt with notes of dried fruits, ginger, and rich toffee."
			},
			{
				"id": "mj_new_orleans_sazerac",
				"name": "Classic French Quarter Sazerac",
				"type": "drink",
				"price": 24,
				"hunger": 0.0,
				"thirst": 20.0,
				"health": 0,
				"happiness": 15,
				"alcohol_level": 2,
				"description": "Rye whiskey, Peychaud's bitters, and an aromatic absinthe rinse."
			},
			{
				"id": "mj_crab_dip",
				"name": "Warm Artichoke & Dungeness Crab Dip",
				"type": "food",
				"price": 22,
				"hunger": 30.0,
				"thirst": 5.0,
				"health": 0,
				"happiness": 14,
				"alcohol_level": 0,
				"description": "Baked golden with Gruyère cheese and served with grilled sourdough baguette crostini."
			},
			{
				"id": "mj_salmon_crostini",
				"name": "Smoked Salmon & Dill Crostini",
				"type": "food",
				"price": 18,
				"hunger": 24.0,
				"thirst": 5.0,
				"health": 1,
				"happiness": 12,
				"alcohol_level": 0,
				"description": "Crispy rye crisps topped with cold-smoked salmon, capers, and lemon dill mascarpone."
			}
		],
		"activities": [
			{
				"id": "act_request_song",
				"name": "Request Custom Jazz Ballad",
				"cost": 25,
				"happiness": 18,
				"social_gain": 15,
				"hunger_cost": 0.0,
				"thirst_cost": 0.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Slip a tip to the saxophonist and request your favorite romantic slow ballad.",
				"outcomes": [
					"The saxophonist smiled, serenading the candlelit room with a soulful, breathtaking melody.",
					"The warm acoustic notes resonated through the cellar, holding the audience spellbound."
				]
			},
			{
				"id": "act_slow_dance",
				"name": "Romantic Cellar Slow Dance",
				"cost": 0,
				"happiness": 20,
				"social_gain": 22,
				"hunger_cost": 2.0,
				"thirst_cost": 3.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Step onto the small polished hardwood floor and slow dance to the rhythm.",
				"outcomes": [
					"Swaying gently to the upright bass and muted trumpet, you felt deeply connected and calm.",
					"The gentle applause of patrons welcomed you as the song came to an elegant finish."
				]
			}
		]
	},

	"lg_botanical_atrium": {
		"id": "lg_botanical_atrium",
		"category": "lounges",
		"name": "Greenhouse Botanical Atrium Lounge",
		"tagline": "Cascading indoor waterfalls, exotic orchids, herbal infusion mocktails, and serene lounge ambient beats",
		"icon": "🌿",
		"color": Color("#059669"),
		"min_age": 0,
		"cover_charge": 0,
		"dress_code": "Casual / Chic",
		"operating_hours": "10:00 - 23:00",
		"menu": [
			{
				"id": "ga_hibiscus_sparkler",
				"name": "Wild Hibiscus & Rose Elixir",
				"type": "drink",
				"price": 14,
				"hunger": 0.0,
				"thirst": 42.0,
				"health": 2,
				"happiness": 14,
				"alcohol_level": 0,
				"description": "Tart wild hibiscus blossom tea, sparkling water, rose water, and edible orchid petals."
			},
			{
				"id": "ga_matcha_tartine",
				"name": "Avocado & Yuzu Matcha Tartine",
				"type": "food",
				"price": 16,
				"hunger": 32.0,
				"thirst": 5.0,
				"health": 3,
				"happiness": 12,
				"alcohol_level": 0,
				"description": "Crushed Hass avocado on toasted grain bread with shaved radishes, yuzu kosho, and pea shoots."
			},
			{
				"id": "ga_cheese_figs",
				"name": "Artisanal Goat Cheese & Fig Compote",
				"type": "food",
				"price": 22,
				"hunger": 35.0,
				"thirst": 5.0,
				"health": 1,
				"happiness": 15,
				"alcohol_level": 0,
				"description": "Warm honeyed goat cheese crostini with mission fig spread and toasted walnuts."
			},
			{
				"id": "ga_elderflower_spritz",
				"name": "Cucumber Elderflower Spritz",
				"type": "drink",
				"price": 13,
				"hunger": 0.0,
				"thirst": 45.0,
				"health": 2,
				"happiness": 12,
				"alcohol_level": 0,
				"description": "Crisp English cucumber ribbons, elderflower cordial, and mint sprigs over ice."
			}
		],
		"activities": [
			{
				"id": "act_botanical_walk",
				"name": "Botanical Garden Meditation Walk",
				"cost": 0,
				"happiness": 16,
				"social_gain": 8,
				"hunger_cost": 1.0,
				"thirst_cost": 2.0,
				"health_effect": 3,
				"is_vip": false,
				"description": "Stroll along winding stone paths beneath towering palms and tranquil water fountains.",
				"outcomes": [
					"The scent of blooming jasmine and gentle mist from the waterfall washed away all fatigue.",
					"Breathing the oxygen-rich floral air restored your mental clarity and inner peace."
				]
			},
			{
				"id": "act_harp_concert",
				"name": "Acoustic Celtic Harp Performance",
				"cost": 20,
				"happiness": 18,
				"social_gain": 14,
				"hunger_cost": 0.0,
				"thirst_cost": 0.0,
				"health_effect": 2,
				"is_vip": false,
				"description": "Listen to delicate harp and flute harmonies echoed by the glass atrium dome.",
				"outcomes": [
					"Each plucked chord drifted peacefully through the foliage, creating an enchanting sanctuary.",
					"You left feeling rejuvenated, tranquil, and deeply refreshed in mind and spirit."
				]
			}
		]
	},

	# -------------------------------------------------------------------------
	# ENTERTAINMENT VENUES EXPANSIONS
	# -------------------------------------------------------------------------
	"en_laughing_byte": {
		"id": "en_laughing_byte",
		"category": "entertainment",
		"name": "The Laughing Byte Standup Comedy",
		"tagline": "Intimate brick-wall comedy stage featuring rising improv stars and celebrity standup roasts",
		"icon": "🎭",
		"color": Color("#ec4899"),
		"min_age": 16,
		"cover_charge": 20,
		"dress_code": "Casual",
		"operating_hours": "19:00 - 01:00",
		"menu": [
			{
				"id": "lb_pretzel_bites",
				"name": "Warm Pretzel Bites & Beer Cheese",
				"type": "food",
				"price": 12,
				"hunger": 32.0,
				"thirst": 5.0,
				"health": -1,
				"happiness": 12,
				"alcohol_level": 0,
				"description": "Soft oven-baked salted pretzel bites served with sharp cheddar ale dip."
			},
			{
				"id": "lb_craft_cider",
				"name": "Crisp Apple Blossom Hard Cider",
				"type": "drink",
				"price": 12,
				"hunger": 0.0,
				"thirst": 30.0,
				"health": 0,
				"happiness": 12,
				"alcohol_level": 2,
				"description": "Naturally fermented crisp orchard apples with a refreshing semi-dry finish."
			},
			{
				"id": "lb_truffle_popcorn",
				"name": "Bottomless Buttered Popcorn",
				"type": "food",
				"price": 8,
				"hunger": 20.0,
				"thirst": 5.0,
				"health": -1,
				"happiness": 9,
				"alcohol_level": 0,
				"description": "Classic movie-style popcorn tossed in warm real butter and sea salt."
			},
			{
				"id": "lb_house_lager",
				"name": "Laughing Byte House Draft",
				"type": "drink",
				"price": 9,
				"hunger": 0.0,
				"thirst": 32.0,
				"health": 0,
				"happiness": 10,
				"alcohol_level": 2,
				"description": "Crisp, cold-filtered American golden lager with clean malt finish."
			}
		],
		"activities": [
			{
				"id": "act_standup_showcase",
				"name": "Attend Headline Comedy Showcase",
				"cost": 25,
				"happiness": 25,
				"social_gain": 16,
				"hunger_cost": 2.0,
				"thirst_cost": 6.0,
				"health_effect": 1,
				"is_vip": false,
				"description": "Enjoy two hours of gut-busting standup routines from touring headliners.",
				"outcomes": [
					"Tears of laughter streamed down your face as the headliner roasted modern corporate life!",
					"The room vibrated with infectious belly laughter, leaving you in high spirits for days."
				]
			},
			{
				"id": "act_open_mic",
				"name": "Attempt Open-Mic 3-Minute Routine",
				"cost": 10,
				"happiness": 20,
				"social_gain": 18,
				"hunger_cost": 3.0,
				"thirst_cost": 8.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Step behind the mic, adjust the stand, and deliver your best punchlines to the crowd.",
				"outcomes": [
					"Your opening joke hit the sweet spot! The crowd roared with laughter and applauded your courage.",
					"You delivered your set with punchy timing, earning respect from the local comedy community."
				]
			}
		]
	},

	"en_omnisphere_cinema": {
		"id": "en_omnisphere_cinema",
		"category": "entertainment",
		"name": "OmniSphere Luxury IMAX Cinema",
		"tagline": "Reclining heated plush leather beds, laser projection, 64-channel Dolby Atmos, and in-seat dining",
		"icon": "🎬",
		"color": Color("#8b5cf6"),
		"min_age": 0,
		"cover_charge": 0,
		"dress_code": "Casual",
		"operating_hours": "10:00 - 01:00",
		"menu": [
			{
				"id": "oc_truffle_popcorn",
				"name": "Gourmet White Cheddar Truffle Popcorn",
				"type": "food",
				"price": 15,
				"hunger": 28.0,
				"thirst": 5.0,
				"health": 0,
				"happiness": 14,
				"alcohol_level": 0,
				"description": "Fresh popped kernels seasoned with real white truffle oil and aged white cheddar."
			},
			{
				"id": "oc_angus_sliders",
				"name": "Prime Angus Beef Sliders (3pc)",
				"type": "food",
				"price": 22,
				"hunger": 48.0,
				"thirst": 10.0,
				"health": 0,
				"happiness": 16,
				"alcohol_level": 0,
				"description": "Mini brioche buns with seared Angus patties, caramelized onions, and garlic aioli."
			},
			{
				"id": "oc_frozen_icee",
				"name": "Giant Blue Raspberry Icee",
				"type": "drink",
				"price": 9,
				"hunger": 0.0,
				"thirst": 40.0,
				"health": -1,
				"happiness": 11,
				"alcohol_level": 0,
				"description": "Massive cup of frosty semi-frozen berry soda that cools you down instantly."
			},
			{
				"id": "oc_lava_cake",
				"name": "Molten Dark Chocolate Lava Cake",
				"type": "food",
				"price": 13,
				"hunger": 24.0,
				"thirst": 5.0,
				"health": -1,
				"happiness": 15,
				"alcohol_level": 0,
				"description": "Warm chocolate cake with a molten fudge core, crowned with vanilla gelato."
			}
		],
		"activities": [
			{
				"id": "act_blockbuster_3d",
				"name": "Watch Blockbuster 3D Premiere",
				"cost": 28,
				"happiness": 22,
				"social_gain": 14,
				"hunger_cost": 4.0,
				"thirst_cost": 6.0,
				"health_effect": 0,
				"is_vip": false,
				"description": "Put on 3D glasses and experience heart-thumping cinematic action with Dolby Atmos sound.",
				"outcomes": [
					"The visual effects and bone-rattling audio completely transported you into another world!",
					"Reclined in heated leather luxury, you enjoyed every breathtaking minute of the film."
				]
			},
			{
				"id": "act_private_skybox",
				"name": "Rent Private Cinema Skybox Suite",
				"cost": 160,
				"happiness": 36,
				"social_gain": 28,
				"hunger_cost": 0.0,
				"thirst_cost": 0.0,
				"health_effect": 0,
				"is_vip": true,
				"description": "Enjoy the film from an elevated soundproof glass suite with private lounge seating.",
				"outcomes": [
					"With plush sofas, concierge catering, and an unobstructed panoramic screen view, you felt like cinema royalty.",
					"Your companion was completely amazed by the VIP experience, making it an unforgettable date."
				]
			}
		]
	},

	"en_starlight_rollers": {
		"id": "en_starlight_rollers",
		"category": "entertainment",
		"name": "Neon Starlight Roller Skating & Disco",
		"tagline": "Retro 80s roller rink, neon light canopy, disco mirror ball, and smooth quad roller skating",
		"icon": "🛼",
		"color": Color("#06b6d4"),
		"min_age": 0,
		"cover_charge": 12,
		"dress_code": "Retro / Casual",
		"operating_hours": "13:00 - 23:00",
		"menu": [
			{
				"id": "sr_roller_slush",
				"name": "Electric Neon Blue Slushie",
				"type": "drink",
				"price": 7,
				"hunger": 0.0,
				"thirst": 38.0,
				"health": -1,
				"happiness": 10,
				"alcohol_level": 0,
				"description": "Frosty sweet raspberry and lime slush with an LED glow straw."
			},
			{
				"id": "sr_pizza_slice",
				"name": "Giant Cheesy Pepperoni Slice",
				"type": "food",
				"price": 6,
				"hunger": 28.0,
				"thirst": 0.0,
				"health": -1,
				"happiness": 9,
				"alcohol_level": 0,
				"description": "Classic roller rink pizza slice loaded with gooey mozzarella."
			},
			{
				"id": "sr_funnel_fries",
				"name": "Powdered Sugar Funnel Cake Fries",
				"type": "food",
				"price": 9,
				"hunger": 25.0,
				"thirst": 0.0,
				"health": -2,
				"happiness": 12,
				"alcohol_level": 0,
				"description": "Crispy fried sweet funnel strips dusted in sweet powdered sugar."
			}
		],
		"activities": [
			{
				"id": "act_roller_disco",
				"name": "Roller Disco Freestyle Skate",
				"cost": 10,
				"happiness": 20,
				"social_gain": 15,
				"hunger_cost": 5.0,
				"thirst_cost": 8.0,
				"health_effect": 2,
				"is_vip": false,
				"description": "Lace up retro skates and glide around the maple wood floor under spinning mirror balls.",
				"outcomes": [
					"You grooved to upbeat funk music, pulling off smooth spins on the polished rink floor!",
					"Skating with wind in your hair and music pulsing through the floor, you felt completely free."
				]
			},
			{
				"id": "act_couples_skate",
				"name": "Couples Hand-in-Hand Slow Skate",
				"cost": 15,
				"happiness": 24,
				"social_gain": 22,
				"hunger_cost": 3.0,
				"thirst_cost": 5.0,
				"health_effect": 1,
				"is_vip": false,
				"description": "Glide gently hand-in-hand as lights dim down to soft romantic purple spotlights.",
				"outcomes": [
					"Gliding smoothly in unison, you shared warm smiles and felt your bond deepen naturally.",
					"The crowd cleared room for the slow skate, making for a timeless, heartfelt memory."
				]
			}
		]
	}
}

static func get_all_categories() -> Array:
	return CATEGORIES.values()

static func get_category(cat_id: String) -> Dictionary:
	return CATEGORIES.get(cat_id, {})

static func get_venues_in_category(cat_id: String) -> Array:
	var list: Array = []
	for v in VENUES.values():
		if v.get("category", "") == cat_id:
			list.append(v)
	return list

static func get_venue(venue_id: String) -> Dictionary:
	return VENUES.get(venue_id, {})

static func get_all_venues() -> Array:
	return VENUES.values()
