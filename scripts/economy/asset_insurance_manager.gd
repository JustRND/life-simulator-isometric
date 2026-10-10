class_name AssetInsuranceManager
extends RefCounted

const CATEGORY_VEHICLE := "vehicle"
const CATEGORY_PROPERTY := "property"

# Expensive base premiums & rates (scales with portfolio value)
const VEHICLE_BASE_PREMIUM := 2500
const VEHICLE_RATE := 0.045 # 4.5% annual rate of vehicle portfolio value

const PROPERTY_BASE_PREMIUM := 6000
const PROPERTY_RATE := 0.030 # 3.0% annual rate of property portfolio value

const VEHICLE_ASSET_CATEGORIES := [
	AssetCatalog.CATEGORY_CARS,
	AssetCatalog.CATEGORY_MOTORCYCLES,
	AssetCatalog.CATEGORY_BICYCLES,
	AssetCatalog.CATEGORY_AIRCRAFT,
	AssetCatalog.CATEGORY_YACHTS
]

const PROPERTY_ASSET_CATEGORIES := [
	AssetCatalog.CATEGORY_PROPERTIES
]

static func is_vehicle_asset(category: String) -> bool:
	return category in VEHICLE_ASSET_CATEGORIES

static func is_property_asset(category: String) -> bool:
	return category in PROPERTY_ASSET_CATEGORIES

static func get_asset_insurance_category(asset: Dictionary) -> String:
	var cat: String = str(asset.get("category", ""))
	if is_vehicle_asset(cat):
		return CATEGORY_VEHICLE
	if is_property_asset(cat):
		return CATEGORY_PROPERTY
	return ""

static func get_category_assets(player_data: Node, insurance_cat: String) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for asset in player_data.owned_assets:
		if get_asset_insurance_category(asset) == insurance_cat:
			list.append(asset)
	return list

static func get_category_valuation(player_data: Node, insurance_cat: String) -> int:
	var total: int = 0
	for asset in get_category_assets(player_data, insurance_cat):
		total += int(asset.get("current_value", asset.get("purchase_price", 0)))
	return total

static func get_annual_premium(player_data: Node, insurance_cat: String) -> int:
	var val: int = get_category_valuation(player_data, insurance_cat)
	if insurance_cat == CATEGORY_VEHICLE:
		return int(round(float(VEHICLE_BASE_PREMIUM) + float(val) * VEHICLE_RATE))
	elif insurance_cat == CATEGORY_PROPERTY:
		return int(round(float(PROPERTY_BASE_PREMIUM) + float(val) * PROPERTY_RATE))
	return 0

static func has_insurance(player_data: Node, insurance_cat: String) -> bool:
	if not "asset_insurance" in player_data:
		return false
	return bool(player_data.asset_insurance.get(insurance_cat, false))

static func can_afford_insurance(player_data: Node, insurance_cat: String) -> bool:
	var premium: int = get_annual_premium(player_data, insurance_cat)
	return player_data.get_available_funds() >= premium

static func buy_insurance(player_data: Node, insurance_cat: String) -> Dictionary:
	if has_insurance(player_data, insurance_cat):
		return {"success": false, "message": "You already have an active policy for this category."}
	
	var premium: int = get_annual_premium(player_data, insurance_cat)
	if not player_data.debit_funds(premium):
		return {"success": false, "message": "Insufficient funds to pay the annual premium of $%d." % premium}
	
	if not "asset_insurance" in player_data:
		player_data.asset_insurance = {}
	player_data.asset_insurance[insurance_cat] = true
	
	var cat_label := "Vehicle" if insurance_cat == CATEGORY_VEHICLE else "Property"

	return {
		"success": true,
		"cost": premium,
		"message": "Purchased %s Insurance for $%d. Your %s ventures and holdings are now fully protected." % [cat_label, premium, cat_label.to_lower()]
	}

static func cancel_insurance(player_data: Node, insurance_cat: String) -> Dictionary:
	if not has_insurance(player_data, insurance_cat):
		return {"success": false, "message": "No active policy found for this category."}
	
	player_data.asset_insurance[insurance_cat] = false
	var cat_label := "Vehicle" if insurance_cat == CATEGORY_VEHICLE else "Property"

	return {
		"success": true,
		"message": "Cancelled %s Insurance. Your %s holdings are now UNINSURED and vulnerable to permanent loss and liquidation." % [cat_label, cat_label.to_lower()]
	}

static func process_yearly_insurance(player_data: Node) -> Array[String]:
	var logs: Array[String] = []
	for cat in [CATEGORY_VEHICLE, CATEGORY_PROPERTY]:
		if has_insurance(player_data, cat):
			var premium: int = get_annual_premium(player_data, cat)
			var cat_label := "Vehicle" if cat == CATEGORY_VEHICLE else "Property"
			if player_data.bank_savings >= premium:
				player_data.bank_savings -= premium
				logs.append("🛡️ ASSET INSURANCE: Paid $%d annual premium for %s Insurance." % [premium, cat_label])
			elif player_data.debit_funds(premium):
				logs.append("🛡️ ASSET INSURANCE: Paid $%d annual premium for %s Insurance from available funds." % [premium, cat_label])
			else:
				# Cannot afford -> Policy lapses!
				player_data.asset_insurance[cat] = false
				player_data.happiness = maxi(5, player_data.happiness - 10)
				logs.append("⚠️ ASSET INSURANCE LAPSED: Insufficient funds to pay $%d annual premium for %s Insurance. Your %s holdings are NO LONGER PROTECTED against disasters and liquidation!" % [premium, cat_label, cat_label.to_lower()])
	return logs

static func protect_assets_from_disaster(player_data: Node, disaster_title: String) -> Dictionary:
	var saved_assets: Array[Dictionary] = []
	var lost_assets: Array[Dictionary] = []
	var remaining_assets: Array[Dictionary] = []
	var payout_val: int = 0
	var lost_val: int = 0

	var has_veh_ins: bool = has_insurance(player_data, CATEGORY_VEHICLE)
	var has_prop_ins: bool = has_insurance(player_data, CATEGORY_PROPERTY)

	for asset in player_data.owned_assets:
		var ins_cat: String = get_asset_insurance_category(asset)
		var val: int = int(asset.get("current_value", asset.get("purchase_price", 0)))
		var is_protected: bool = false
		if ins_cat == CATEGORY_VEHICLE and has_veh_ins:
			is_protected = true
		elif ins_cat == CATEGORY_PROPERTY and has_prop_ins:
			is_protected = true
		
		if is_protected:
			saved_assets.append(asset)
			remaining_assets.append(asset)
			payout_val += val
		else:
			lost_assets.append(asset)
			lost_val += val

	player_data.owned_assets.clear()
	for rem in remaining_assets:
		player_data.owned_assets.append(rem)

	return {
		"saved_assets": saved_assets,
		"lost_assets": lost_assets,
		"payout_value": payout_val,
		"lost_value": lost_val,
		"disaster_title": disaster_title
	}

static func check_yearly_asset_incidents(player_data: Node) -> Dictionary:
	if player_data.owned_assets.is_empty():
		return {"occurred": false}

	# 3.5% chance per year of an asset incident
	if randf() > 0.035:
		return {"occurred": false}

	var veh_assets := get_category_assets(player_data, CATEGORY_VEHICLE)
	var prop_assets := get_category_assets(player_data, CATEGORY_PROPERTY)

	var candidates: Array[Dictionary] = []
	for v in veh_assets:
		candidates.append({"asset": v, "type": CATEGORY_VEHICLE})
	for p in prop_assets:
		candidates.append({"asset": p, "type": CATEGORY_PROPERTY})

	if candidates.is_empty():
		return {"occurred": false}

	var target_entry: Dictionary = candidates.pick_random()
	var target_asset: Dictionary = target_entry["asset"]
	var target_type: String = target_entry["type"]
	var asset_name: String = str(target_asset.get("name", "Asset"))
	var asset_val: int = int(target_asset.get("current_value", target_asset.get("purchase_price", 0)))
	var instance_id: String = str(target_asset.get("instance_id", ""))

	var is_insured: bool = has_insurance(player_data, target_type)

	if target_type == CATEGORY_VEHICLE:
		var incidents := [
			"A reckless hit-and-run truck smashed into your parked %s!" % asset_name,
			"A flash hailstorm severely crushed the chassis and bodywork of your %s!" % asset_name,
			"A high-speed freeway blowout caused severe structural rollover damage to your %s!" % asset_name
		]
		var incident_desc: String = incidents.pick_random()
		if is_insured:
			return {
				"occurred": true,
				"protected": true,
				"message": "%s\n\n🛡️ INSURANCE CLAIM APPROVED: First National Pixel Bank Vehicle Insurance paid $%d in full replacement and repair claims! Your %s was completely restored." % [incident_desc, asset_val, asset_name]
			}
		else:
			# Destroy asset!
			for i in range(player_data.owned_assets.size() - 1, -1, -1):
				if player_data.owned_assets[i].get("instance_id", "") == instance_id:
					player_data.owned_assets.remove_at(i)
					break
			return {
				"occurred": true,
				"protected": false,
				"message": "%s\n\n💥 TOTAL UNINSURED LOSS: Because you lacked Vehicle Insurance, your %s was completely totaled and scrapped! ($%d loss)" % [incident_desc, asset_name, asset_val]
			}
	else:
		var prop_incidents := [
			"A ruptured water main flooded the foundation and lower floors of your %s!" % asset_name,
			"An electrical junction surge ignited an intense roof and attic fire at your %s!" % asset_name,
			"A severe localized microburst storm collapsed trees and roofing onto your %s!" % asset_name
		]
		var incident_desc: String = prop_incidents.pick_random()
		if is_insured:
			return {
				"occurred": true,
				"protected": true,
				"message": "%s\n\n🛡️ INSURANCE CLAIM APPROVED: First National Pixel Bank Property Insurance covered $%d in full structural restoration claims! Your %s was completely rebuilt." % [incident_desc, asset_val, asset_name]
			}
		else:
			# Severe damage or destruction
			for i in range(player_data.owned_assets.size() - 1, -1, -1):
				if player_data.owned_assets[i].get("instance_id", "") == instance_id:
					player_data.owned_assets.remove_at(i)
					break
			return {
				"occurred": true,
				"protected": false,
				"message": "%s\n\n🏚️ TOTAL UNINSURED LOSS: Because you lacked Property Insurance, your %s was condemned and lost! ($%d loss)" % [incident_desc, asset_name, asset_val]
			}
