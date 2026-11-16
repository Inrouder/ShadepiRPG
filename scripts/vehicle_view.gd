extends RefCounted
## v0.65.0 · CodexAI. Wider vehicle field, common projection for scenery, hazards, vehicles and FX.
const SCALE := 0.8
const OFFSET := Vector2(64,72)
const SPAWN_Y := -130.0
const FRAME := Rect2(-80,-90,800,450)
static func projection() -> Transform2D:
	return Transform2D(0.0,Vector2.ONE*SCALE,0.0,OFFSET)
static func tile(canvas: CanvasItem, texture: Texture2D, y: float, shake: Vector2 = Vector2.ZERO):
	# Preserve the road/collision corridor. Widen the existing side scenery continuously,
	# without mirrored signs, duplicate people or uncovered edges over the old world.
	var unit:=Vector2(texture.get_size())/Vector2(640,360)
	canvas.draw_set_transform(shake)
	canvas.draw_texture_rect_region(texture,Rect2(-80,y,278,360),Rect2(Vector2.ZERO,Vector2(198,360)*unit))
	canvas.draw_texture_rect_region(texture,Rect2(198,y,244,360),Rect2(Vector2(198,0)*unit,Vector2(244,360)*unit))
	canvas.draw_texture_rect_region(texture,Rect2(442,y,278,360),Rect2(Vector2(442,0)*unit,Vector2(198,360)*unit))
