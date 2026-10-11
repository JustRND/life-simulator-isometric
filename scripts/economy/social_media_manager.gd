class_name SocialMediaManager
extends RefCounted

const PLATFORM_INSTAGRAM := "instagram"
const PLATFORM_YOUTUBE := "youtube"
const PLATFORM_TWITCH := "twitch"
const PLATFORM_X := "x"
const PLATFORM_TIKTOK := "tiktok"

const PLATFORMS: Dictionary = {
	PLATFORM_INSTAGRAM: {
		"id": PLATFORM_INSTAGRAM,
		"name": "Instagram",
		"icon": "📸",
		"color": "#e1306c",
		"metric": "Followers",
		"min_age": 13,
		"desc": "Share curated photo carousels, aesthetic lifestyle reels, and behind-the-scenes stories."
	},
	PLATFORM_YOUTUBE: {
		"id": PLATFORM_YOUTUBE,
		"name": "YouTube",
		"icon": "▶️",
		"color": "#ef4444",
		"metric": "Subscribers",
		"min_age": 13,
		"desc": "Produce long-form video essays, gaming playthroughs, documentaries, and tech deep-dives."
	},
	PLATFORM_TWITCH: {
		"id": PLATFORM_TWITCH,
		"name": "Twitch",
		"icon": "🟣",
		"color": "#9333ea",
		"metric": "Followers",
		"min_age": 13,
		"desc": "Broadcast live gaming marathons, interactive chat sessions, and esports tournaments."
	},
	PLATFORM_X: {
		"id": PLATFORM_X,
		"name": "X",
		"icon": "🐦",
		"color": "#38bdf8",
		"metric": "Followers",
		"min_age": 13,
		"desc": "Post witty hot takes, breaking thoughts, memes, and intellectual discourse threads."
	},
	PLATFORM_TIKTOK: {
		"id": PLATFORM_TIKTOK,
		"name": "TikTok",
		"icon": "🎵",
		"color": "#06b6d4",
		"metric": "Followers",
		"min_age": 13,
		"desc": "Create fast-paced short-form videos, viral audio trends, comedy skits, and choreography."
	}
}


static func get_platforms() -> Dictionary:
	return PLATFORMS


static func has_account(player_data: Node, platform: String) -> bool:
	if not player_data.get("social_media") is Dictionary:
		return false
	return player_data.social_media.has(platform)


static func get_account(player_data: Node, platform: String) -> Dictionary:
	if not player_data.get("social_media") is Dictionary:
		return {}
	return player_data.social_media.get(platform, {})


static func create_account(player_data: Node, platform: String, custom_handle: String = "") -> Dictionary:
	if not PLATFORMS.has(platform):
		return {"success": false, "message": "Invalid social media platform."}

	var p_info: Dictionary = PLATFORMS[platform]
	var min_age: int = int(p_info.get("min_age", 13))
	if player_data.age < min_age:
		return {"success": false, "message": "Age restriction: You must be at least %d years old to join %s." % [min_age, p_info.name]}

	if not player_data.get("social_media") is Dictionary:
		player_data.social_media = {}

	if player_data.social_media.has(platform):
		return {"success": false, "message": "You already have an active %s account!" % p_info.name}

	var clean_handle := custom_handle.strip_edges()
	if clean_handle == "":
		var base_name: String = player_data.first_name.to_lower().replace(" ", "_")
		if base_name == "":
			base_name = "user"
		clean_handle = "@%s_%d" % [base_name, randi() % 900 + 100]
	elif not clean_handle.begins_with("@"):
		clean_handle = "@" + clean_handle

	var init_count: int = randi_range(25, 120)
	var account_data: Dictionary = {
		"platform": platform,
		"name": p_info.name,
		"handle": clean_handle,
		"followers": init_count,
		"is_verified": false,
		"created_age": player_data.age,
		"posts_count": 0,
		"last_post_age": -1,
		"total_earnings": 0
	}

	player_data.social_media[platform] = account_data
	player_data.happiness = mini(100, player_data.happiness + 5)
	player_data.add_life_log_entry("📱 SOCIAL MEDIA: You created an official %s account (%s) with %d initial %s!" % [
		p_info.name,
		clean_handle,
		init_count,
		p_info.metric
	], "milestone")

	return {
		"success": true,
		"message": "Welcome to %s! Your account %s is live with %d initial %s." % [
			p_info.name,
			clean_handle,
			init_count,
			p_info.metric
		],
		"account": account_data
	}


static func create_post(player_data: Node, platform: String) -> Dictionary:
	if not has_account(player_data, platform):
		return {"success": false, "message": "No account found."}

	var account: Dictionary = player_data.social_media[platform]
	var p_info: Dictionary = PLATFORMS[platform]
	var metric: String = p_info.metric

	var cur_m: int = int(player_data.get("in_game_month")) if player_data.get("in_game_month") != null else 1
	var cur_y: int = int(player_data.get("in_game_year")) if player_data.get("in_game_year") != null else 2026
	var cur_a: int = player_data.age
	var last_p_month: int = int(account.get("last_post_month", -1))
	var last_p_year: int = int(account.get("last_post_year", -1))
	var last_p_age: int = int(account.get("last_post_age", -1))

	if (last_p_month == cur_m and last_p_year == cur_y and last_p_age == cur_a) or (last_p_month < 0 and last_p_age == cur_a):
		return {"success": false, "message": "Monthly Post Limit (Annual Post Limit): You have already shared a post on %s this month. Followers await fresh content next month!" % p_info.name}

	account["posts_count"] = int(account.get("posts_count", 0)) + 1
	account["last_post_age"] = cur_a
	account["last_post_month"] = cur_m
	account["last_post_year"] = cur_y

	var roll: float = randf()
	var looks_bonus: float = float(player_data.looks) / 200.0
	var smarts_bonus: float = float(player_data.smarts) / 200.0

	var viral_threshold: float = 0.85 - (looks_bonus + smarts_bonus) * 0.15

	var delta: int = 0
	var outcome_title := ""
	var happiness_delta := 0

	if roll > 0.96:
		# MEGA VIRAL
		delta = randi_range(5000, 35000)
		happiness_delta = 18
		outcome_title = "🔥 MEGA VIRAL EXPLOSION! Your post hit global trending algorithms! +%s %s!" % [
			_format_number(delta),
			metric
		]
	elif roll > viral_threshold:
		# VIRAL HIT
		delta = randi_range(400, 3200)
		happiness_delta = 10
		outcome_title = "🚀 VIRAL HIT! Massive engagement and endless shares! +%s %s!" % [
			_format_number(delta),
			metric
		]
	elif roll > 0.12:
		# ORGANIC ENGAGEMENT
		delta = randi_range(20, 180)
		happiness_delta = 4
		outcome_title = "✨ Good engagement! Followers appreciated your content (+%d %s)." % [
			delta,
			metric
		]
	else:
		# CRITIQUE / RATIO
		delta = -randi_range(5, 35)
		happiness_delta = -3
		outcome_title = "📉 Mild backlash. Your post flopped and attracted critical comments (%d %s)." % [
			delta,
			metric
		]

	var cur: int = int(account.get("followers", 0))
	account["followers"] = maxi(5, cur + delta)
	player_data.happiness = clamp(player_data.happiness + happiness_delta, 0, 100)

	player_data.add_life_log_entry("📱 %s POST: %s" % [p_info.name.to_upper(), outcome_title], "activity")

	return {
		"success": true,
		"message": outcome_title,
		"delta": delta,
		"total": account["followers"]
	}


static func apply_verification(player_data: Node, platform: String) -> Dictionary:
	if not has_account(player_data, platform):
		return {"success": false, "message": "No account found."}

	var account: Dictionary = player_data.social_media[platform]
	var p_info: Dictionary = PLATFORMS[platform]
	var metric: String = p_info.metric

	if bool(account.get("is_verified", false)):
		return {"success": false, "message": "Your %s account is already officially verified with a blue badge ☑️!" % p_info.name}

	var cur_count: int = int(account.get("followers", 0))
	var req_count: int = 25000 if platform == PLATFORM_YOUTUBE else 50000

	if cur_count < req_count:
		return {
			"success": false,
			"message": "Verification Denied ❌: %s requires at least %s %s to verify authentic public figures (Current: %s %s)." % [
				p_info.name,
				_format_number(req_count),
				metric,
				_format_number(cur_count),
				metric
			]
		}

	account["is_verified"] = true
	player_data.happiness = mini(100, player_data.happiness + 20)
	player_data.add_life_log_entry("☑️ VERIFIED CREATOR: Your %s account %s was officially awarded the verified blue tick badge!" % [
		p_info.name,
		account.get("handle", "")
	], "milestone")

	return {
		"success": true,
		"message": "Congratulations! Your %s account was officially VERIFIED with the iconic blue badge ☑️!" % p_info.name
	}


static func buy_followers(player_data: Node, platform: String, tier: int) -> Dictionary:
	if not has_account(player_data, platform):
		return {"success": false, "message": "No account found."}

	var account: Dictionary = player_data.social_media[platform]
	var p_info: Dictionary = PLATFORMS[platform]
	var metric: String = p_info.metric

	var cur_m: int = int(player_data.get("in_game_month")) if player_data.get("in_game_month") != null else 1
	var cur_y: int = int(player_data.get("in_game_year")) if player_data.get("in_game_year") != null else 2026
	var cur_a: int = player_data.age
	var last_ad_month: int = int(account.get("last_ad_month", -1))
	var last_ad_year: int = int(account.get("last_ad_year", -1))
	var last_ad_age: int = int(account.get("last_ad_age", -1))

	if (last_ad_month == cur_m and last_ad_year == cur_y and last_ad_age == cur_a) or (last_ad_month < 0 and last_ad_age == cur_a):
		return {"success": false, "message": "Monthly Campaign Limit (Annual Campaign Limit): You have already run a promotional campaign on %s this month. Ad algorithms need time to recalibrate before next month!" % p_info.name}

	var tiers := [
		{"amount": 1000, "cost": 150},
		{"amount": 5000, "cost": 650},
		{"amount": 25000, "cost": 2800}
	]

	if tier < 0 or tier >= tiers.size():
		return {"success": false, "message": "Invalid follower package."}

	var chosen: Dictionary = tiers[tier]
	var cost: int = int(chosen["cost"])
	var amount: int = int(chosen["amount"])

	var total_funds: int = player_data.money + player_data.bank_savings
	if total_funds < cost:
		return {"success": false, "message": "Insufficient funds: Package costs $%d (Available: $%d)." % [cost, total_funds]}

	player_data.debit_funds(cost)

	account["last_ad_age"] = cur_a
	account["last_ad_month"] = cur_m
	account["last_ad_year"] = cur_y

	# 15% risk of bot detection purge
	if randf() < 0.15:
		player_data.karma = maxi(-100, player_data.karma - 5)
		var purged: int = int(amount * 0.7)
		var actual_gain: int = amount - purged
		account["followers"] = int(account.get("followers", 0)) + actual_gain
		player_data.add_life_log_entry("⚠️ BOT PURGE: You purchased %d bot %s on %s, but anti-spam algorithms purged %d of them!" % [
			amount,
			metric,
			p_info.name,
			purged
		], "crime")
		return {
			"success": true,
			"message": "You spent $%d. Platform anti-spam algorithms flagged suspicious traffic and purged %d bot %s (+%d net)." % [
				cost,
				purged,
				metric,
				actual_gain
			]
		}

	account["followers"] = int(account.get("followers", 0)) + amount
	player_data.add_life_log_entry("📈 MARKETING BOOST: You invested $%d in follower campaigns on %s (+%d %s)." % [
		cost,
		p_info.name,
		amount,
		metric
	], "activity")

	return {
		"success": true,
		"message": "Campaign Successful! Gained +%s %s on %s for $%d." % [
			_format_number(amount),
			metric,
			p_info.name,
			cost
		]
	}


static func troll_someone(player_data: Node, platform: String) -> Dictionary:
	if not has_account(player_data, platform):
		return {"success": false, "message": "No account found."}

	var account: Dictionary = player_data.social_media[platform]
	var p_info: Dictionary = PLATFORMS[platform]
	var metric: String = p_info.metric

	var cur_m: int = int(player_data.get("in_game_month")) if player_data.get("in_game_month") != null else 1
	var cur_y: int = int(player_data.get("in_game_year")) if player_data.get("in_game_year") != null else 2026
	var cur_a: int = player_data.age
	var last_troll_month: int = int(account.get("last_troll_month", -1))
	var last_troll_year: int = int(account.get("last_troll_year", -1))
	var last_troll_age: int = int(account.get("last_troll_age", -1))

	if (last_troll_month == cur_m and last_troll_year == cur_y and last_troll_age == cur_a) or (last_troll_month < 0 and last_troll_age == cur_a):
		return {"success": false, "message": "Internet Cooldown: You have already engaged in online drama on %s this month. Moderation algorithms are watching until next month (or next year)!" % p_info.name}

	account["last_troll_age"] = cur_a
	account["last_troll_month"] = cur_m
	account["last_troll_year"] = cur_y

	# Trolling increases happiness, decreases karma
	player_data.happiness = mini(100, player_data.happiness + 12)
	player_data.karma = maxi(-100, player_data.karma - 8)

	var msg := ""
	if randf() < 0.30:
		var lost: int = mini(int(account.get("followers", 0)) - 10, randi_range(50, 400))
		if lost > 0:
			account["followers"] = maxi(5, int(account.get("followers", 0)) - lost)
		msg = "😈 Trolled an online influencer! You enjoyed the spicy drama (+12 Happiness), but disgusted fans unfollowed you (-%d %s)." % [
			lost,
			metric
		]
	else:
		msg = "😈 Savage Internet Roast! You ruthlessly trolled someone on %s and soaked in the replies (+12 Happiness)." % p_info.name

	player_data.add_life_log_entry("💬 TROLLING ON %s: %s" % [p_info.name.to_upper(), msg], "event")

	return {
		"success": true,
		"message": msg
	}


static func delete_account(player_data: Node, platform: String) -> Dictionary:
	if not has_account(player_data, platform):
		return {"success": false, "message": "Account does not exist."}

	var handle: String = str(player_data.social_media[platform].get("handle", ""))
	var p_name: String = str(PLATFORMS.get(platform, {}).get("name", platform))
	player_data.social_media.erase(platform)

	player_data.add_life_log_entry("🗑️ SOCIAL DETOX: You permanently deleted your %s account (%s)." % [p_name, handle], "activity")

	return {
		"success": true,
		"message": "Your %s account (%s) has been permanently deactivated." % [p_name, handle]
	}


static func process_monthly_social_media(player_data: Node) -> Array[String]:
	var logs: Array[String] = []
	if not player_data.get("social_media") is Dictionary:
		return logs

	for platform in player_data.social_media.keys():
		var account: Dictionary = player_data.social_media[platform]
		var p_info: Dictionary = PLATFORMS.get(platform, {})
		var count: int = int(account.get("followers", 0))

		# Organic monthly follower growth
		var growth_rate: float = randf_range(0.003, 0.015)
		var organic_gain: int = maxi(1, int(count * growth_rate))
		account["followers"] = count + organic_gain

		# Creator monetization for accounts with over 20,000 followers/subs (monthly ad revenue)
		if account["followers"] >= 20000:
			var m_revenue: int = maxi(10, int(round(float((account["followers"] / 1000) * randi_range(12, 35)) / 12.0)))
			player_data.money += m_revenue
			account["total_earnings"] = int(account.get("total_earnings", 0)) + m_revenue
			player_data.social_media_earnings_this_year = int(player_data.get("social_media_earnings_this_year")) + m_revenue
			logs.append("💰 %s Creator Payout: You earned $%s in monthly creator ad-revenue!" % [
				str(p_info.get("name", platform)),
				_format_number(m_revenue)
			])

	return logs


static func process_yearly_social_media(player_data: Node) -> Array[String]:
	var logs: Array[String] = []
	if not player_data.get("social_media") is Dictionary:
		return logs

	for platform in player_data.social_media.keys():
		var account: Dictionary = player_data.social_media[platform]
		var p_info: Dictionary = PLATFORMS.get(platform, {})
		var metric: String = str(p_info.get("metric", "Followers"))
		var count: int = int(account.get("followers", 0))
		if count > 1000:
			logs.append("📱 %s: Maintained %s active %s across the year." % [
				str(p_info.get("name", platform)),
				_format_number(count),
				metric
			])

	return logs


static func _format_number(val: int) -> String:
	var s := str(abs(val))
	var res := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		count += 1
		if count % 3 == 0 and i > 0:
			res = "," + res
	return ("-" if val < 0 else "") + res
