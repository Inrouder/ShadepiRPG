class_name SpriteAssets
extends RefCounted

const HQ_SHEET_SIZE := Vector2i(1024, 5120)
const SHEET_SIZES := [Vector2i(384, 1024), Vector2i(384, 2048), HQ_SHEET_SIZE]
const HEROES := {
	"raven.png": preload("res://assets/sprites/heroes/raven.png"),
	"shadepi.png": preload("res://assets/sprites/heroes/shadepi.png"),
}
const NPCS := {
	"jackal.png": preload("res://assets/sprites/npcs/jackal.png"),
	"kenzo.png": preload("res://assets/sprites/npcs/kenzo.png"),
	"punk-1.png": preload("res://assets/sprites/npcs/punk-1.png"),
	"punk-2.png": preload("res://assets/sprites/npcs/punk-2.png"),
	"punk-3.png": preload("res://assets/sprites/npcs/punk-3.png"),
	"punk-4.png": preload("res://assets/sprites/npcs/punk-4.png"),
	"shooter-visor.png": preload("res://assets/sprites/npcs/shooter-visor.png"),
	"shooter-violet.png": preload("res://assets/sprites/npcs/shooter-violet.png"),
}

static func valid_sheet(texture: Texture2D) -> bool:
	return texture != null and Vector2i(texture.get_size()) in SHEET_SIZES

static func frame_size(texture: Texture2D) -> Vector2i:
	return Vector2i(128, 160) if Vector2i(texture.get_size()) == HQ_SHEET_SIZE else Vector2i(48, 64)

static func display_scale(texture: Texture2D) -> float:
	return 0.5 if Vector2i(texture.get_size()) == HQ_SHEET_SIZE else 1.0

static func foot_baseline(texture: Texture2D) -> float:
	return 152.0 if Vector2i(texture.get_size()) == HQ_SHEET_SIZE else 58.0

static func resolve(original: Texture2D) -> Texture2D:
	var candidate := "res://assets/custom/" + original.resource_path.get_file()
	if ResourceLoader.exists(candidate):
		var replacement := load(candidate) as Texture2D
		if valid_sheet(replacement):
			return replacement
		push_warning("Eigene Figur hat falsche Maße (384 × 1024, 384 × 2048 oder 1024 × 5120 erwartet): " + candidate)
	var filename := original.resource_path.get_file()
	return NPCS.get(filename, HEROES.get(filename, original))
