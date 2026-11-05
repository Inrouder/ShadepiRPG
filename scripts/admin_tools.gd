class_name AdminTools
extends RefCounted

# Developer conveniences are not an authentication or security boundary.
# A testing session uses separate checkpoint files and never writes normal saves.
const SETTINGS_PATH := "user://shadepi-admin-settings.cfg"
const SESSION_KEY := "shadepi_admin_testing"
const REQUEST_KEY := "shadepi_admin_chapter_request"
const OPTIONS := ["unlock_all", "god_mode", "one_hit", "infinite_energy", "no_cooldowns", "freeze_timer"]

static func read_flags() -> Dictionary:
	var flags := {}
	var file := ConfigFile.new()
	var loaded := file.load(SETTINGS_PATH) == OK
	for key in OPTIONS:
		var value: Variant = file.get_value("flags", key, false) if loaded else false
		flags[key] = value if value is bool else false
	return flags

static func save_flags(flags: Dictionary) -> bool:
	var file := ConfigFile.new()
	for key in OPTIONS:
		file.set_value("flags", key, bool(flags.get(key, false)))
	return file.save(SETTINGS_PATH) == OK

static func is_test_session(tree: SceneTree) -> bool:
	return tree.get_meta(SESSION_KEY, false) == true

static func checkpoint_path(original: String, tree: SceneTree) -> String:
	if not is_test_session(tree):
		return original
	return original.replace("user://shadepi-", "user://shadepi-admin-")

static func scene_for_chapter(chapter: int) -> String:
	if chapter == 1:
		return "res://scenes/chapter_one.tscn"
	if chapter == 2:
		return "res://scenes/chapter_two.tscn"
	if chapter >= 3 and chapter <= 7:
		return "res://scenes/campaign.tscn"
	return ""

static func first_beat(chapter: int) -> int:
	match chapter:
		3: return 0 # Pact
		4: return 3 # Garage
		5: return 5 # Sanctuary
		6: return 6 # Flight
		7: return 10 # Lake
	return -1

static func request_chapter(tree: SceneTree, chapter: int) -> Error:
	var target := scene_for_chapter(chapter)
	if target.is_empty():
		return ERR_INVALID_PARAMETER
	var previous_testing := is_test_session(tree)
	tree.set_meta(SESSION_KEY, true)
	tree.set_meta(REQUEST_KEY, chapter)
	var error := tree.change_scene_to_file(target)
	if error != OK:
		tree.remove_meta(REQUEST_KEY)
		if not previous_testing:
			tree.remove_meta(SESSION_KEY)
	return error

static func consume_chapter(tree: SceneTree, scene_path: String) -> int:
	var requested: Variant = tree.get_meta(REQUEST_KEY, -1)
	if not (requested is int) or scene_for_chapter(requested) != scene_path:
		return -1
	tree.remove_meta(REQUEST_KEY)
	return requested
