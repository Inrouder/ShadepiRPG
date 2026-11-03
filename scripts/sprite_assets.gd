class_name SpriteAssets
extends RefCounted

const SHEET_SIZE := Vector2i(384, 1024)

static func valid_sheet(texture: Texture2D) -> bool:
	return texture != null and Vector2i(texture.get_size()) == SHEET_SIZE

static func resolve(original: Texture2D) -> Texture2D:
	var candidate := "res://assets/custom/" + original.resource_path.get_file()
	if ResourceLoader.exists(candidate):
		var replacement := load(candidate) as Texture2D
		if valid_sheet(replacement):
			return replacement
		push_warning("Eigene Figur hat falsche Maße (384 × 1024 erwartet): " + candidate)
	return original
