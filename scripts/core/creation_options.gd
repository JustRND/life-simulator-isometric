extends RefCounted

# Coordinates refer to the supplied 2048px sheet, expressed on its 1600px preview.
const COUNTRIES = [
	["Albania", 12, 9],
	["Argentina", 15, 2],
	["Australia", 2, 0],
	["Austria", 15, 5],
	["Azerbaijan", 5, 11],
	["Bahrain", 7, 6],
	["Bangladesh", 11, 9],
	["Barbados", 3, 7],
	["Belgium", 4, 5],
	["Bosnia and Herzegovina", 1, 10],
	["Botswana", 7, 15],
	["Brazil", 4, 1],
	["Bulgaria", 14, 1],
	["Cambodia", 1, 9],
	["Canada", 1, 1],
	["Chile", 8, 0],
	["Colombia", 2, 14],
	["Croatia", 6, 2],
	["Cuba", 11, 5],
	["Cyprus", 0, 1],
	["Czech Republic", 9, 12],
	["Denmark", 13, 3],
	["DR Congo", 1, 4],
	["Estonia", 8, 5],
	["Finland", 5, 8],
	["France", 5, 1],
	["Georgia", 13, 7],
	["Germany", 0, 2],
	["Ghana", 9, 6],
	["Greece", 11, 3],
	["Hungary", 5, 0],
	["Iceland", 7, 0],
	["India", 14, 0],
	["Indonesia", 3, 16],
	["Ireland", 8, 2],
	["Italy", 1, 2],
	["Japan", 4, 0],
	["Kazakhstan", 4, 8],
	["Kenya", 1, 8],
	["Kuwait", 13, 0],
	["Lebanon", 8, 3],
	["Lithuania", 6, 5],
	["Madagascar", 12, 15],
	["Malta", 4, 7],
	["Mexico", 5, 2],
	["Morocco", 13, 9],
	["Myanmar", 14, 2],
	["Netherlands", 7, 2],
	["New Zealand", 12, 3],
	["Nigeria", 6, 17],
	["North Korea", 9, 5],
	["Norway", 10, 5],
	["Panama", 5, 5],
	["Philippines", 0, 3],
	["Poland", 10, 0],
	["Portugal", 7, 4],
	["Romania", 12, 0],
	["Russia", 3, 0],
	["Saudi Arabia", 2, 6],
	["Senegal", 2, 7],
	["Serbia", 10, 12],
	["Singapore", 14, 3],
	["Slovakia", 15, 12],
	["South Africa", 15, 0],
	["South Korea", 11, 0],
	["Spain", 15, 1],
	["Sri Lanka", 8, 10],
	["Sweden", 6, 1],
	["Switzerland", 8, 9],
	["Taiwan", 4, 13],
	["Tanzania", 5, 7],
	["Thailand", 3, 5],
	["Tunisia", 11, 11],
	["Turkey", 6, 11],
	["Ukraine", 15, 11],
	["United Arab Emirates", 7, 5],
	["United Kingdom", 1, 0],
	["United States", 0, 0],
	["Venezuela", 9, 4],
	["Vietnam", 6, 6],
	["Zimbabwe", 1, 16]
]

const COUNTRY_ISO_MAP: Dictionary = {
	"Albania": "AL",
	"Argentina": "AR",
	"Australia": "AU",
	"Austria": "AT",
	"Azerbaijan": "AZ",
	"Bahrain": "BH",
	"Bangladesh": "BD",
	"Barbados": "BB",
	"Belgium": "BE",
	"Bosnia and Herzegovina": "BA",
	"Botswana": "BW",
	"Brazil": "BR",
	"Bulgaria": "BG",
	"Cambodia": "KH",
	"Canada": "CA",
	"Chile": "CL",
	"Colombia": "CO",
	"Croatia": "HR",
	"Cuba": "CU",
	"Cyprus": "CY",
	"Czech Republic": "CZ",
	"Denmark": "DK",
	"DR Congo": "CD",
	"Estonia": "EE",
	"Finland": "FI",
	"France": "FR",
	"Georgia": "GE",
	"Germany": "DE",
	"Ghana": "GH",
	"Greece": "GR",
	"Hungary": "HU",
	"Iceland": "IS",
	"India": "IN",
	"Indonesia": "ID",
	"Ireland": "IE",
	"Italy": "IT",
	"Japan": "JP",
	"Kazakhstan": "KZ",
	"Kenya": "KE",
	"Kuwait": "KW",
	"Lebanon": "LB",
	"Lithuania": "LT",
	"Madagascar": "MG",
	"Malta": "MT",
	"Mexico": "MX",
	"Morocco": "MA",
	"Myanmar": "MM",
	"Netherlands": "NL",
	"New Zealand": "NZ",
	"Nigeria": "NG",
	"North Korea": "KP",
	"Norway": "NO",
	"Panama": "PA",
	"Philippines": "PH",
	"Poland": "PL",
	"Portugal": "PT",
	"Romania": "RO",
	"Russia": "RU",
	"Saudi Arabia": "SA",
	"Senegal": "SN",
	"Serbia": "RS",
	"Singapore": "SG",
	"Slovakia": "SK",
	"South Africa": "ZA",
	"South Korea": "KR",
	"Spain": "ES",
	"Sri Lanka": "LK",
	"Sweden": "SE",
	"Switzerland": "CH",
	"Taiwan": "TW",
	"Tanzania": "TZ",
	"Thailand": "TH",
	"Tunisia": "TN",
	"Turkey": "TR",
	"Ukraine": "UA",
	"United Arab Emirates": "AE",
	"United Kingdom": "GB",
	"United States": "US",
	"Venezuela": "VE",
	"Vietnam": "VN",
	"Zimbabwe": "ZW"
}

const FLAG_ROW_TOP = [153, 242, 327, 412, 494, 575, 656, 738, 818, 899, 979, 1059, 1139, 1219, 1299, 1380, 1459, 1539]
const FLAG_ROW_BOTTOM = [199, 286, 371, 455, 537, 619, 699, 780, 861, 941, 1021, 1101, 1182, 1262, 1342, 1423, 1502, 1582]

static func get_country_iso(country_name: String) -> String:
	for c_name in COUNTRY_ISO_MAP.keys():
		if str(c_name).to_lower() == country_name.to_lower():
			return str(COUNTRY_ISO_MAP[c_name])
	return "US"

static func get_country_by_iso(iso: String) -> String:
	var upper_iso := iso.to_upper().strip_edges()
	for c_name in COUNTRY_ISO_MAP.keys():
		if str(COUNTRY_ISO_MAP[c_name]).to_upper() == upper_iso:
			return str(c_name)
	return "United States"

static func get_all_country_names() -> Array[String]:
	var names: Array[String] = []
	for entry in COUNTRIES:
		names.append(str(entry[0]))
	return names

static func is_country_supported(country_name: String) -> bool:
	for entry in COUNTRIES:
		if str(entry[0]).to_lower() == country_name.to_lower():
			return true
	return false

static func normalize_name(value: String) -> String:
	var words := value.strip_edges().split(" ", false)
	for index in range(words.size()):
		words[index] = words[index].left(1).to_upper() + words[index].substr(1).to_lower()
	return " ".join(words)

static func valid_name(value: String) -> bool:
	var pattern := RegEx.new()
	pattern.compile("^[\\p{L}]+(?: [\\p{L}]+)*$")
	return value.length() >= 2 and value.length() <= 40 and pattern.search(value) != null

static func flag_texture(column: int, row: int) -> AtlasTexture:
	var sheet: Texture2D = load("res://assets/sheets/flags.jpg")
	if sheet == null:
		return null
	var icon := AtlasTexture.new()
	icon.atlas = sheet
	var factor := float(sheet.get_width()) / 1600.0
	# Inset inside the colored flag face, excluding the sheet's black frame.
	icon.region = Rect2((column * 100 + 17) * factor, (FLAG_ROW_TOP[row] + 1) * factor, 66 * factor, (FLAG_ROW_BOTTOM[row] - FLAG_ROW_TOP[row] - 1) * factor)
	icon.filter_clip = true
	return icon

static func get_flag_for_country(country_name: String) -> AtlasTexture:
	for entry in COUNTRIES:
		if entry[0].to_lower() == country_name.to_lower():
			return flag_texture(int(entry[1]), int(entry[2]))
	# Fallback to first entry if not found
	return flag_texture(int(COUNTRIES[0][1]), int(COUNTRIES[0][2]))
