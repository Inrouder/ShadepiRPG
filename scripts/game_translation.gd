extends Translation
## v0.70.0 · CodexAI. Native UI translation, including the game's assembled HUD text.
## Source strings, story IDs, passwords and gameplay comparisons stay German/stable.
const CATALOG: Translation = preload("res://localization/game.en.po")
const CACHE_LIMIT := 2048
var catalog_entries := {}
var templates: Array[Dictionary] = []
var edges: Array[String] = []
var cache := {}
var spec := RegEx.new()

func _init() -> void:
	locale = "en"
	spec.compile("%[-+ 0#]*[0-9]*(?:\\.[0-9]+)?[dsf]")
	for key in CATALOG.get_message_list():
		var source := String(key)
		catalog_entries[source] = String(CATALOG.get_message(key))
		var matches := spec.search_all(source)
		if not matches.is_empty():
			var parts: Array[String] = []
			var pattern := "^"
			var last := 0
			var weight := 0
			for token in matches:
				var literal := source.substr(last, token.get_start() - last).replace("%%", "%")
				pattern += _escape(literal)
				weight += literal.length()
				var kind := token.get_string().right(1)
				var words := "([\\s\\S]*?)" if source.trim_suffix("\n").contains("\n") else "(.*?)"
				pattern += words if kind == "s" else ("([+-]?[0-9]+)" if kind == "d" else "([+-]?[0-9]+(?:[.,][0-9]+)?)")
				last = token.get_end()
			var tail := source.substr(last).replace("%%", "%")
			pattern += _escape(tail) + "\\z"
			weight += tail.length()
			# Avoid catch-all templates such as %s%s: they cannot identify a message.
			if weight < 3: continue
			var expression := RegEx.new()
			if expression.compile(pattern) != OK: continue
			var target: String = catalog_entries[source]
			last = 0
			for token in spec.search_all(target):
				parts.append(target.substr(last, token.get_start() - last).replace("%%", "%"))
				last = token.get_end()
			parts.append(target.substr(last).replace("%%", "%"))
			if parts.size() == matches.size() + 1:
				templates.append({"regex": expression, "parts": parts, "weight": weight})
		elif source != catalog_entries[source] and (source.begins_with(" ") or source.ends_with(" ") or source.begins_with("\n")):
			edges.append(source)
	templates.sort_custom(func(a, b): return a.weight > b.weight)
	edges.sort_custom(func(a, b): return a.length() > b.length())

func _escape(value: String) -> String:
	var result := ""
	for character in value:
		if character in "\\.^$|?*+()[]{}": result += "\\"
		result += character
	return result

func _get_message(source: StringName, _context: StringName) -> StringName:
	return StringName(resolve(String(source)))

func resolve(source: String, depth: int = 0) -> String:
	if source.is_empty(): return source
	if catalog_entries.has(source): return catalog_entries[source]
	if cache.has(source): return cache[source]
	if depth >= 4: return source
	var result := source
	# Stage names are displayed with capitalize(); their canonical keys are capitals.
	if catalog_entries.has(source.to_upper()) and source == source.capitalize():
		result = String(catalog_entries[source.to_upper()]).capitalize()
	for entry in templates:
		if result != source: break
		var matched: RegExMatch = entry.regex.search(source)
		if matched == null: continue
		result = entry.parts[0]
		for i in range(1, matched.get_group_count() + 1):
			result += resolve(matched.get_string(i), depth + 1) + entry.parts[i]
		break
	if result == source:
		for edge in edges:
			if source.begins_with(edge):
				result = catalog_entries[edge] + resolve(source.substr(edge.length()), depth + 1)
				break
			if source.ends_with(edge):
				result = resolve(source.left(-edge.length()), depth + 1) + catalog_entries[edge]
				break
	if result == source:
		for separator in ["\n", " · ", "    ", " / "]:
			if not source.contains(separator): continue
			var pieces := source.split(separator)
			for i in pieces.size():
				# History rows retain their newline while matching their catalog template.
				if separator == "\n" and i < pieces.size() - 1:
					var translated := resolve(pieces[i], depth + 1)
					if translated == pieces[i]: translated = resolve(pieces[i] + "\n", depth + 1).trim_suffix("\n")
					pieces[i] = translated
				else: pieces[i] = resolve(pieces[i], depth + 1)
			result = separator.join(pieces)
			if result != source: break
	if depth == 0:
		if cache.size() >= CACHE_LIMIT: cache.clear()
		cache[source] = result
	return result
