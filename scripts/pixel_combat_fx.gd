class_name PixelCombatFX
extends RefCounted
const LIGHTNING = preload("res://assets/fx/lightning.png")
const BULLET = preload("res://assets/fx/bullet.png")
const MUZZLE = preload("res://assets/fx/muzzle.png")
static func packet(canvas: CanvasItem, point: Vector2, direction: Vector2, age: float, electric: bool, muzzle: bool = false, alpha: float = 1.0, tail_limit: float = INF, head_limit: float = INF) -> void:
	var frame := posmod(int(age * 36), 8)
	var texture: Texture2D = MUZZLE if muzzle else LIGHTNING if electric else BULLET
	var scale := 0.42 if muzzle else 0.65
	var left := maxf(-48, -tail_limit/scale)
	var right := minf(48, head_limit/scale)
	canvas.draw_set_transform(point.round(), direction.angle(), Vector2.ONE * scale)
	canvas.draw_texture_rect_region(texture, Rect2(left,-24,right-left,48), Rect2(frame*96+48+left,0,right-left,48), Color(1,1,1,alpha))
	canvas.draw_set_transform(Vector2.ZERO)
