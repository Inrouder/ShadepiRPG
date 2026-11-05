extends RefCounted
## Painted atlas regions include transparent gutters. Footprints remain gameplay data.
const ATLAS = preload("res://assets/world/hq/props.png")
const EDGES = [0, 244, 480, 699, 1000, 1234, 1470, 1714, 1944, 2172]
const ROWS = [0, 250, 505, 724]
const SIZES = [Vector2(54, 58), Vector2(44, 58), Vector2(74, 111), Vector2(116, 67), Vector2(76, 62), Vector2(52, 74), Vector2(59, 79), Vector2(56, 78), Vector2(67, 69)]

static func texture(column: int, row: int = 0) -> AtlasTexture:
	var result := AtlasTexture.new()
	result.atlas = ATLAS
	result.region = Rect2(EDGES[column], ROWS[row], EDGES[column + 1] - EDGES[column], ROWS[row + 1] - ROWS[row])
	result.filter_clip = true
	return result

static func apply(sprite: Sprite2D, column: int, row: int = 0) -> void:
	var art := texture(column, row)
	sprite.region_enabled = false
	sprite.texture = art
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var size: Vector2 = SIZES[column]
	if row == 2:
		size.y *= 0.62
	sprite.scale = size / art.get_size()
	sprite.position.y = -size.y * 0.5 + 2.0
