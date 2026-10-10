extends RefCounted
## Ordered phrases precede broad actions. Match words, not fragments such as
## "car" inside "carefully". Canonical English keeps icons stable across locales.
const RULES = [
	["finance", "🏛️"], ["banking|bank", "🏦"], ["micro advance", "🪙"], ["personal loan", "💳"], ["major commercial", "🏢"], ["executive capital", "🏦"],
	["repay full debt", "✅"], ["repay", "💸"], ["borrow", "🏦"], ["tax", "🧾"],
	["deposit", "📥"], ["withdraw", "📤"], ["transfer", "💱"], ["donate|charity", "🤲"],
	["flashcards|vocabulary", "📇"], ["compete|competition", "🏆"], ["stomach ache|sick", "🤒"],
	["reading|read|library", "📚"], ["puzzle", "🧩"], ["chess", "♟"], ["museum", "🏛"],
	["language", "🌐"], ["workshop|repair", "🔧"], ["study|school|education|enroll", "🎓"],
	["job|career|apply for role|work", "💼"], ["business|enterprise|incorporate", "🏢"],
	["stock|invest|ipo", "📈"], ["buy|purchase|acquire", "🛒"], ["sell|resell", "💰"],
	["ring|propose", "💍"], ["bouquet|flowers", "💐"], ["gift", "🎁"], ["marry|marriage|wedding", "💒"],
	["date|romantic", "💘"], ["break up|divorce", "💔"], ["baby|child", "👶"],
	["spend time|socialize|friends", "👥"], ["compliment|praise", "🥰"], ["talk|chat|ask", "💬"],
	["flight|pilot", "✈"], ["boat|boating", "⛵"], ["car|drive|driver", "🚗"],
	["license|exam|certified|qualification", "📜"], ["health|doctor|clinic|surgery", "🩺"],
	["meds|medicine|treatment", "💊"], ["pet|adopt|animal", "🐾"], ["gym|fitness|exercise", "💪"],
	["meditate|meditation|rest", "🧘"], ["salon|hair", "💇"], ["spa|massage", "💆"],
	["save", "💾"], ["load|restore", "📂"], ["delete|erase|remove", "🗑"],
	["cancel|back|return|leave", "↩"], ["continue|next|proceed", "➡"], ["confirm|accept|agree|apply", "✅"],
	["decline|refuse|reject|skip", "🙅"], ["ignore|wait|postpone", "⏳"], ["help|protect|rescue", "🤝"],
	["report|police", "👮"], ["fight|punch|attack", "🥊"], ["steal|sneak|crime", "🥷"],
	["gamble|lottery|bet|guess", "🎲"], ["learn|practice|train", "📖"],
	["youtube", "▶"], ["instagram", "📸"], ["twitch", "🟣"], ["tiktok", "🎵"], ["\\bx account\\b|\\bx\\b", "𝕏"],
	["create|new|add", "✨"], ["choose|select|manage|view|open", "📋"],
]

static func for_text(text: String) -> String:
	var expression := RegEx.new()
	for rule in RULES:
		expression.compile("(?i)\\b(?:" + rule[0] + ")\\b")
		if expression.search(text) != null:
			return rule[1]
	return "👉"

static func for_choice(choice: Dictionary, used: Array[String]) -> String:
	var icon := str(choice.get("icon", for_text(str(choice.get("text", "")))))
	if not icon in used:
		return icon
	# Generated choices can describe the same action; distinguish their intent.
	var intent := str(choice.get("type", ""))
	var intents := {"generous": "🎁", "reckless": "⚡", "adventurous": "🧭", "responsible": "🛡", "smart": "🧠"}
	var alternatives: Array = [intents.get(intent, "💭"), "🧭", "🤔", "✋", "💡"]
	for alternative in alternatives:
		if not alternative in used:
			return alternative
	return icon
