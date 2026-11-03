class_name SaveService
extends RefCounted

const PATH := "user://shadepi-test-save.json"

static func validate(value: Variant) -> Dictionary:
	if not value is Dictionary:
		return {}
	var data: Dictionary = value
	for key in ["version", "stage", "health", "energy", "x", "y", "enemy_health"]:
		if not data.has(key) or not (data[key] is float or data[key] is int) or not is_finite(float(data[key])):
			return {}
	if data.version != 1 or data.stage < 0 or data.stage > 4 or data.stage != floor(data.stage):
		return {}
	if data.health < 1 or data.health > 100 or data.energy < 0 or data.energy > 100 or data.enemy_health < 0 or data.enemy_health > 180:
		return {}
	if data.stage >= 3 and data.enemy_health != 0:
		return {}
	if data.stage < 3 and data.enemy_health <= 0:
		return {}
	if not WorldData.walkable(Vector2(data.x, data.y), data.stage >= 2):
		return {}
	return data

static func write(data: Dictionary, path: String = PATH) -> bool:
	if validate(data).is_empty():
		return false
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	file.flush()
	file.close()
	# POSIX rename replaces atomically; Windows needs the previous slot moved first.
	if FileAccess.file_exists(path):
		if FileAccess.file_exists(path + ".bak"):
			DirAccess.remove_absolute(path + ".bak")
		if DirAccess.rename_absolute(path, path + ".bak") != OK:
			return false
	if DirAccess.rename_absolute(path + ".tmp", path) == OK:
		return true
	if FileAccess.file_exists(path + ".bak"):
		DirAccess.rename_absolute(path + ".bak", path)
	return false

static func read(path: String = PATH) -> Dictionary:
	for candidate in [path, path + ".bak"]:
		if not FileAccess.file_exists(candidate):
			continue
		var file := FileAccess.open(candidate, FileAccess.READ)
		if file == null or file.get_length() > 65536:
			continue
		var parser := JSON.new()
		if parser.parse(file.get_as_text()) != OK:
			continue
		var result := validate(parser.data)
		if not result.is_empty():
			return result
	return {}
