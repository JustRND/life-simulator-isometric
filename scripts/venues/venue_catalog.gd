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
