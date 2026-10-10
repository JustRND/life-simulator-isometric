class_name PetManager
extends RefCounted

const SOURCE_DOG_SHELTER := "dog_shelter"
const SOURCE_CAT_SHELTER := "cat_shelter"
const SOURCE_DOG_BREEDER := "dog_breeder"
const SOURCE_CAT_BREEDER := "cat_breeder"
const SOURCE_PET_STORE := "pet_store"
const SOURCE_RANCH := "ranch"

const DOG_BREEDS: Array[Dictionary] = [
	{"breed": "Golden Retriever", "price": 1600, "upkeep": 320, "icon": "🐕"},
	{"breed": "German Shepherd", "price": 1800, "upkeep": 350, "icon": "🐕"},
	{"breed": "French Bulldog", "price": 2400, "upkeep": 280, "icon": "🐶"},
	{"breed": "Siberian Husky", "price": 1700, "upkeep": 360, "icon": "🐺"},
	{"breed": "Cavalier King Charles", "price": 2100, "upkeep": 260, "icon": "🐶"},
	{"breed": "Standard Poodle", "price": 1900, "upkeep": 300, "icon": "🐩"},
	{"breed": "Rottweiler", "price": 1750, "upkeep": 380, "icon": "🐕"},
	{"breed": "Labrador Retriever", "price": 1500, "upkeep": 310, "icon": "🐕"},
	{"breed": "Pembroke Welsh Corgi", "price": 2200, "upkeep": 270, "icon": "🦊"},
	{"breed": "Shiba Inu", "price": 2000, "upkeep": 290, "icon": "🐕"},
	{"breed": "Australian Shepherd", "price": 1850, "upkeep": 340, "icon": "🐕"},
	{"breed": "Boxer", "price": 1650, "upkeep": 330, "icon": "🐕"},
	{"breed": "Doberman Pinscher", "price": 1950, "upkeep": 370, "icon": "🐕"},
	{"breed": "Great Dane", "price": 2300, "upkeep": 450, "icon": "🐕"},
	{"breed": "Beagle", "price": 1350, "upkeep": 250, "icon": "🐕"},
	{"breed": "Border Collie", "price": 1800, "upkeep": 330, "icon": "🐕"},
	{"breed": "Dachshund (Sausage Dog)", "price": 1450, "upkeep": 230, "icon": "🐕"},
	{"breed": "Yorkshire Terrier", "price": 1600, "upkeep": 210, "icon": "🐶"},
	{"breed": "Samoyed", "price": 2600, "upkeep": 380, "icon": "🐕"},
	{"breed": "Bernese Mountain Dog", "price": 2500, "upkeep": 420, "icon": "🐕"},
	{"breed": "Akita Inu", "price": 2250, "upkeep": 360, "icon": "🐕"},
	{"breed": "Pomeranian", "price": 1750, "upkeep": 220, "icon": "🐶"},
	{"breed": "Dalmatian", "price": 1900, "upkeep": 340, "icon": "🐕"},
	{"breed": "Cane Corso", "price": 2400, "upkeep": 400, "icon": "🐕"},
	{"breed": "Pug", "price": 1550, "upkeep": 240, "icon": "🐶"},
	{"breed": "Boston Terrier", "price": 1650, "upkeep": 250, "icon": "🐶"}
]

const CAT_BREEDS: Array[Dictionary] = [
	{"breed": "Persian", "price": 1300, "upkeep": 220, "icon": "🐈"},
	{"breed": "Maine Coon", "price": 1900, "upkeep": 260, "icon": "🐈"},
	{"breed": "British Shorthair", "price": 1500, "upkeep": 200, "icon": "🐱"},
	{"breed": "Siamese", "price": 1200, "upkeep": 190, "icon": "🐈"},
	{"breed": "Bengal Leopard Cat", "price": 2300, "upkeep": 280, "icon": "🐆"},
	{"breed": "Ragdoll", "price": 1650, "upkeep": 220, "icon": "🐱"},
	{"breed": "Sphynx Hairless", "price": 2200, "upkeep": 240, "icon": "🐈"},
	{"breed": "Scottish Fold", "price": 1800, "upkeep": 210, "icon": "🐱"},
	{"breed": "Russian Blue", "price": 1600, "upkeep": 195, "icon": "🐈"},
	{"breed": "Abyssinian", "price": 1450, "upkeep": 205, "icon": "🐈"},
	{"breed": "Norwegian Forest Cat", "price": 1850, "upkeep": 250, "icon": "🐈"},
	{"breed": "Birman Sacred Cat", "price": 1550, "upkeep": 215, "icon": "🐱"},
	{"breed": "Devon Rex", "price": 1750, "upkeep": 210, "icon": "🐱"},
	{"breed": "Oriental Shorthair", "price": 1400, "upkeep": 190, "icon": "🐈"},
	{"breed": "Turkish Angora", "price": 1650, "upkeep": 225, "icon": "🐈"},
	{"breed": "American Shorthair", "price": 1100, "upkeep": 180, "icon": "🐱"},
	{"breed": "Burmese", "price": 1350, "upkeep": 195, "icon": "🐈"},
	{"breed": "Chartreux", "price": 1700, "upkeep": 210, "icon": "🐈"},
	{"breed": "Siberian Forest Cat", "price": 1950, "upkeep": 260, "icon": "🐈"},
	{"breed": "Manx Tailless Cat", "price": 1500, "upkeep": 200, "icon": "🐱"},
	{"breed": "Somali Fox Cat", "price": 1600, "upkeep": 220, "icon": "🐈"},
	{"breed": "Japanese Bobtail", "price": 1550, "upkeep": 200, "icon": "🐱"},
	{"breed": "Savannah Exotic Cat", "price": 3200, "upkeep": 340, "icon": "🐆"},
	{"breed": "Bombay Panther Cat", "price": 1450, "upkeep": 205, "icon": "🐈"},
	{"breed": "Egyptian Mau", "price": 1800, "upkeep": 230, "icon": "🐆"},
	{"breed": "Selkirk Rex Curly Cat", "price": 1700, "upkeep": 215, "icon": "🐱"}
]

const PET_STORE_ANIMALS: Array[Dictionary] = [
	{"species": "Green Sea Turtle", "type": "turtle", "price": 85, "upkeep": 60, "icon": "🐢", "min_age": 1, "max_age": 3, "lifespan": 50},
	{"species": "Fancy Hooded Rat", "type": "rodent", "price": 35, "upkeep": 40, "icon": "🐀", "min_age": 1, "max_age": 2, "lifespan": 4},
	{"species": "Royal Ball Python Snake", "type": "reptile", "price": 150, "upkeep": 75, "icon": "🐍", "min_age": 1, "max_age": 3, "lifespan": 25},
	{"species": "Holland Lop Dwarf Rabbit", "type": "rabbit", "price": 95, "upkeep": 90, "icon": "🐇", "min_age": 1, "max_age": 2, "lifespan": 10},
	{"species": "Blue Budgerigar Parakeet", "type": "bird", "price": 65, "upkeep": 50, "icon": "🦜", "min_age": 1, "max_age": 2, "lifespan": 12},
	{"species": "Crown-Tail Betta Splendens", "type": "fish", "price": 30, "upkeep": 25, "icon": "🐠", "min_age": 1, "max_age": 1, "lifespan": 4}
]

const HORSE_BREEDS: Array[Dictionary] = [
	{"breed": "Thoroughbred Racehorse", "price": 12500, "upkeep": 1400, "icon": "🐎"},
	{"breed": "Arabian Desert Steed", "price": 16000, "upkeep": 1500, "icon": "🐎"},
	{"breed": "American Quarter Horse", "price": 7500, "upkeep": 1200, "icon": "🐎"},
	{"breed": "Friesian Royal Black Stallion", "price": 24000, "upkeep": 1800, "icon": "🐎"},
	{"breed": "Clydesdale Heavy Draft Horse", "price": 11000, "upkeep": 1600, "icon": "🐎"},
	{"breed": "Wild Mustang Gelding", "price": 4800, "upkeep": 1100, "icon": "🐎"}
]


static func get_shelter_animals(shelter_type: String) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	var count := randi_range(4, 6)

	if shelter_type == SOURCE_DOG_SHELTER:
		var dog_mixes := [
			"Labrador Mix", "Terrier Mix", "Hound Mix", "Shepherd Cross",
			"Beagle Mix", "Collie Cross", "Corgi Mix", "Husky Cross",
			"Boxer Mix", "Pitbull Cross", "Poodle Mix", "Spaniel Cross"
		]
		for i in range(count):
			var breed_name: String = dog_mixes[randi() % dog_mixes.size()]
			var pet_age: int = randi_range(1, 9)
			list.append({
				"id": "shelter_dog_%d_%d" % [i, randi() % 1000],
				"type": "dog",
				"species": breed_name,
				"breed": breed_name,
				"source": "Dog Shelter",
				"age": pet_age,
				"age_str": "%d years old" % pet_age,
				"price": 0,
				"upkeep": 220,
				"icon": "🐕",
				"health": randi_range(65, 90),
				"happiness": randi_range(50, 75),
				"lifespan": 14
			})
	elif shelter_type == SOURCE_CAT_SHELTER:
		var cat_mixes := [
			"Domestic Shorthair", "Tuxedo Cat", "Calico Tabby", "Orange Ginger Tabby",
			"Tortoiseshell", "Domestic Longhair", "Tabby Point Cross", "Bicolor Shorthair",
			"Silver Mackerel Tabby", "Smoke Gray Domestic"
		]
		for i in range(count):
			var breed_name: String = cat_mixes[randi() % cat_mixes.size()]
			var pet_age: int = randi_range(1, 10)
			list.append({
				"id": "shelter_cat_%d_%d" % [i, randi() % 1000],
				"type": "cat",
				"species": breed_name,
				"breed": breed_name,
				"source": "Cat Shelter",
				"age": pet_age,
				"age_str": "%d years old" % pet_age,
				"price": 0,
				"upkeep": 160,
				"icon": "🐈",
				"health": randi_range(70, 95),
				"happiness": randi_range(55, 80),
				"lifespan": 16
			})

	return list


static func get_breeder_animals(breeder_type: String) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	if breeder_type == SOURCE_DOG_BREEDER:
		for b in DOG_BREEDS:
			# Age puppy -> 1 y.o. max
			var months: int = [2, 4, 6, 8, 12][randi() % 5]
			var age_str := "%d months old (Puppy)" % months if months < 12 else "1 year old"
			list.append({
				"id": "breeder_dog_%s" % b.breed.to_lower().replace(" ", "_"),
				"type": "dog",
				"species": b.breed,
				"breed": b.breed,
				"source": "Dog Breeder",
				"age": 0 if months < 12 else 1,
				"age_str": age_str,
				"price": int(b.price),
				"upkeep": int(b.upkeep),
				"icon": b.icon,
				"health": randi_range(90, 100),
				"happiness": randi_range(85, 100),
				"lifespan": 15
			})
	elif breeder_type == SOURCE_CAT_BREEDER:
		for b in CAT_BREEDS:
			# Age kitten -> 1 y.o. max
			var months: int = [2, 3, 5, 7, 12][randi() % 5]
			var age_str := "%d months old (Kitten)" % months if months < 12 else "1 year old"
			list.append({
				"id": "breeder_cat_%s" % b.breed.to_lower().replace(" ", "_"),
				"type": "cat",
				"species": b.breed,
				"breed": b.breed,
				"source": "Cat Breeder",
				"age": 0 if months < 12 else 1,
				"age_str": age_str,
				"price": int(b.price),
				"upkeep": int(b.upkeep),
				"icon": b.icon,
				"health": randi_range(90, 100),
				"happiness": randi_range(85, 100),
				"lifespan": 17
			})
	return list


static func get_pet_store_animals() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for a in PET_STORE_ANIMALS:
		var pet_age: int = randi_range(int(a.min_age), int(a.max_age))
		list.append({
			"id": "store_%s" % a.type,
			"type": a.type,
			"species": a.species,
			"breed": a.species,
			"source": "Pet Store",
			"age": pet_age,
			"age_str": "%d year%s old" % [pet_age, "s" if pet_age > 1 else ""],
			"price": int(a.price),
			"upkeep": int(a.upkeep),
			"icon": a.icon,
			"health": randi_range(80, 95),
			"happiness": randi_range(70, 90),
			"lifespan": int(a.lifespan)
		})
	return list


static func get_ranch_horses() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for h in HORSE_BREEDS:
		var h_age: int = randi_range(2, 6)
		list.append({
			"id": "horse_%s" % h.breed.to_lower().replace(" ", "_"),
			"type": "horse",
			"species": "Horse",
			"breed": h.breed,
			"source": "Equestrian Ranch",
			"age": h_age,
			"age_str": "%d years old" % h_age,
			"price": int(h.price),
			"upkeep": int(h.upkeep),
			"icon": h.icon,
			"health": randi_range(88, 100),
			"happiness": randi_range(80, 95),
			"lifespan": 28
		})
	return list


static func adopt_pet(
	player_data: Node,
	pet_spec: Dictionary,
	custom_name: String = "",
	enforce_annual_limit: bool = false,
	apply_default_buffs: bool = true,
	set_annual_cooldown: bool = true
) -> Dictionary:
	if enforce_annual_limit:
		var last_adopt_age = player_data.get("last_pet_adoption_age")
		if last_adopt_age != null and int(last_adopt_age) == player_data.age:
			return {"success": false, "message": "Annual Adoption Limit: You have already adopted a companion pet for Age %d! Advance age (+1 Year) to adopt another pet." % player_data.age}

	var price: int = int(pet_spec.get("price", 0))
	var total_funds: int = player_data.money + player_data.bank_savings
	if price > 0 and total_funds < price:
		return {"success": false, "message": "Insufficient funds: Adoption fee is $%d (Available: $%d)." % [price, total_funds]}

	if price > 0:
		player_data.debit_funds(price)

	var final_name := custom_name.strip_edges()
	if final_name == "":
		if pet_spec.has("name") and str(pet_spec["name"]).strip_edges() != "":
			final_name = str(pet_spec["name"]).strip_edges()
		else:
			var p_type: String = str(pet_spec.get("type", "pet")).to_lower()
			if p_type == "dog":
				var dog_names := ["Barnaby", "Buddy", "Lucky", "Milo", "Bella", "Charlie", "Daisy", "Coco", "Shadow", "Penny", "Thor", "Scruffy", "Rusty", "Buster", "Max", "Rocky"]
				final_name = dog_names[randi() % dog_names.size()]
			elif p_type == "cat":
				var cat_names := ["Luna", "Milo", "Oliver", "Simba", "Coco", "Shadow", "Cleo", "Mochi", "Felix", "Whiskers", "Smokey", "Jasper", "Pepper", "Mittens"]
				final_name = cat_names[randi() % cat_names.size()]
			else:
				var default_names := ["Barnaby", "Luna", "Milo", "Bella", "Charlie", "Daisy", "Oliver", "Simba", "Coco", "Shadow", "Penny", "Thor"]
				final_name = default_names[randi() % default_names.size()]

	if not player_data.get("pets") is Array:
		player_data.set("pets", [])

	var new_pet := {
		"id": "pet_%d_%d" % [player_data.age, randi() % 10000],
		"name": final_name,
		"type": str(pet_spec.get("type", "pet")),
		"species": str(pet_spec.get("species", pet_spec.get("breed", "Companion"))),
		"breed": str(pet_spec.get("breed", "Companion")),
		"source": str(pet_spec.get("source", "Adoption")),
		"age": int(pet_spec.get("age", 1)),
		"icon": str(pet_spec.get("icon", "🐾")),
		"health": int(pet_spec.get("health", 90)),
		"happiness": int(pet_spec.get("happiness", 85)),
		"upkeep": int(pet_spec.get("upkeep", 150)),
		"lifespan": int(pet_spec.get("lifespan", 15)),
		"adopted_age": player_data.age,
		"last_interact_age": -1,
		"last_play_age": -1,
		"last_walk_age": -1,
		"last_treat_age": -1,
		"last_vet_age": -1
	}

	player_data.pets.append(new_pet)
	if set_annual_cooldown:
		player_data.last_pet_adoption_age = player_data.age

	if apply_default_buffs:
		player_data.happiness = mini(100, player_data.happiness + 15)
		var log_desc := ""
		if price == 0:
			player_data.karma = mini(100, player_data.karma + 6)
			log_desc = "🐾 RESCUE ADOPTION: You adopted a loving %s (%s) from the %s for free! (+15 Happiness)." % [
				new_pet.breed,
				final_name,
				new_pet.source
			]
		else:
			log_desc = "🐾 PET PURCHASE: You welcomed your new %s (%s) from the %s for $%d! (+15 Happiness)." % [
				new_pet.breed,
				final_name,
				new_pet.source,
				price
			]
		player_data.add_life_log_entry(log_desc, "milestone")

	return {
		"success": true,
		"message": "Welcome home, %s! %s is thrilled to be part of your family." % [final_name, final_name],
		"pet": new_pet
	}


static func rename_pet(player_data: Node, pet_id: String, new_name: String) -> Dictionary:
	var clean := new_name.strip_edges()
	if clean == "":
		return {"success": false, "message": "Name cannot be empty."}
	if not player_data.get("pets") is Array:
		return {"success": false, "message": "No pets found."}
	for pet in player_data.pets:
		if str(pet.get("id", "")) == pet_id:
			var old_name: String = str(pet.get("name", "Companion"))
			pet["name"] = clean
			return {"success": true, "message": "You renamed %s to %s." % [old_name, clean]}
	return {"success": false, "message": "Pet not found."}


static func interact_pet(player_data: Node, pet_id: String, action: String) -> Dictionary:
	if not player_data.get("pets") is Array:
		return {"success": false, "message": "No pets found."}

	for pet in player_data.pets:
		if str(pet.get("id", "")) == pet_id:
			var pet_name: String = str(pet.get("name", "your pet"))
			var p_type: String = str(pet.get("type", "dog"))

			var act_field := "last_" + action + "_age"
			if int(pet.get(act_field, -1)) == player_data.age:
				var verb: String = "played with" if action == "play" else ("walked" if action == "walk" else ("given treats to" if action == "treat" else "taken to the vet"))
				return {"success": false, "message": "Already done for Age %d! You have already %s %s this year. Wait until next year!" % [player_data.age, verb, pet_name]}

			match action:
				"play":
					pet["happiness"] = mini(100, int(pet.get("happiness", 80)) + 15)
					player_data.happiness = mini(100, player_data.happiness + 8)
					pet[act_field] = player_data.age
					player_data.add_life_log_entry("🎾 You spent joyous time playing and bonding with %s!" % pet_name, "activity")
					return {"success": true, "message": "You played and cuddled with %s! %s is wagging and purring with joy." % [pet_name, pet_name]}
				"walk":
					if p_type in ["fish", "turtle", "snake"]:
						return {"success": false, "message": "You cannot take a %s out for an outdoor walk!" % p_type}
					pet["happiness"] = mini(100, int(pet.get("happiness", 80)) + 12)
					pet["health"] = mini(100, int(pet.get("health", 80)) + 6)
					player_data.health = mini(100, player_data.health + 4)
					player_data.happiness = mini(100, player_data.happiness + 6)
					pet[act_field] = player_data.age
					player_data.add_life_log_entry("🦮 You took %s on a refreshing outdoor walk through the park!" % pet_name, "activity")
					return {"success": true, "message": "You went on a scenic walk with %s! Great cardio for both of you." % pet_name}
				"treat":
					var treat_cost := 25
					if player_data.get_available_funds() < treat_cost:
						return {"success": false, "message": "You need $%d in available funds to buy gourmet organic treats." % treat_cost}
					player_data.debit_funds(treat_cost)
					pet["happiness"] = mini(100, int(pet.get("happiness", 80)) + 20)
					player_data.happiness = mini(100, player_data.happiness + 5)
					pet[act_field] = player_data.age
					return {"success": true, "message": "You fed %s delicious artisan treats! %s happily devoured them." % [pet_name, pet_name]}
				"vet":
					var vet_cost := 160
					var total_funds: int = player_data.money + player_data.bank_savings
					if total_funds < vet_cost:
						return {"success": false, "message": "Veterinary examination costs $%d (Available: $%d)." % [vet_cost, total_funds]}
					player_data.debit_funds(vet_cost)
					pet["health"] = mini(100, int(pet.get("health", 70)) + 30)
					pet[act_field] = player_data.age
					player_data.add_life_log_entry("🩺 You brought %s to the veterinarian clinic for shots and health checkups ($%d). Health restored!" % [pet_name, vet_cost], "activity")
					return {"success": true, "message": "The veterinarian gave %s a clean bill of health! Pet vitality restored." % pet_name}

	return {"success": false, "message": "Pet not found."}


static func process_yearly_pets(player_data: Node) -> Array[String]:
	var logs: Array[String] = []
	if not player_data.get("pets") is Array:
		return logs

	for i in range(player_data.pets.size() - 1, -1, -1):
		var pet: Dictionary = player_data.pets[i]
		pet["age"] = int(pet.get("age", 0)) + 1
		var pet_age: int = pet["age"]
		var pet_name: String = str(pet.get("name", "Pet"))
		var lifespan: int = int(pet.get("lifespan", 15))
		var upkeep: int = int(pet.get("upkeep", 150))

		# Upkeep
		if upkeep > 0:
			if player_data.bank_savings >= upkeep:
				player_data.bank_savings -= upkeep
			elif player_data.get_available_funds() >= upkeep:
				player_data.debit_funds(upkeep)
			else:
				pet["happiness"] = maxi(10, int(pet.get("happiness", 70)) - 15)
				pet["health"] = maxi(10, int(pet.get("health", 70)) - 10)
				logs.append("⚠️ Pet Care: You were low on funds to provide full premium care for %s ($%d upkeep)." % [pet_name, upkeep])

		# Elderly mortality check
		if pet_age >= lifespan:
			var death_roll: float = randf()
			if death_roll < 0.35 or pet_age >= lifespan + 3:
				player_data.happiness = maxi(0, player_data.happiness - 25)
				logs.append("🌈 PET LOSS: Your beloved companion %s passed away peacefully from old age at %d years old. Their memory will live on in your heart." % [pet_name, pet_age])
				player_data.add_life_log_entry("🌈 MEMORIAL: Your beloved %s %s passed away peacefully at age %d. You held a heartfelt memorial." % [pet.get("species", "pet"), pet_name, pet_age], "tragedy")
				player_data.pets.remove_at(i)

	return logs
