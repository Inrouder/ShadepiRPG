extends RefCounted

const FRESH_ENTRY := "shadepi_fresh_chapter"

# Story exits start the next chapter; menu entries may resume its checkpoint.
static func advance(tree: SceneTree, path: String) -> Error:
	tree.set_meta(FRESH_ENTRY, path)
	var error := tree.change_scene_to_file(path)
	if error != OK:
		tree.remove_meta(FRESH_ENTRY)
	return error

static func consume_entry(tree: SceneTree, path: String) -> bool:
	if tree.get_meta(FRESH_ENTRY, "") != path:
		return false
	tree.remove_meta(FRESH_ENTRY)
	return true

static func checkpoint(path: String, section: String, key: String, allowed: Array) -> int:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return -1
	var value: Variant = config.get_value(section, key, -1)
	return value if value is int and value in allowed else -1
