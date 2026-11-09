extends RefCounted
## v0.40.0 · CodexAI. Registered rear-wheel contact, bank and suspension poses.
const ATLAS = preload("res://assets/vehicles/motorcycle/riding.png")
const CELL := Vector2(418,418)
const SCALE := 78.0/418.0
# Measured rear tyre contacts; the same asphalt point survives every pose change.
const REAR: Array[Vector2] = [Vector2(300,383),Vector2(224,383),Vector2(209,383),Vector2(182,383),Vector2(169,381),Vector2(212,381),Vector2(230,390),Vector2(207,390)]
const EXHAUST := [[Vector2(249,351),Vector2(335,309)],[Vector2(175,344),Vector2(281,335)],[Vector2(159,340),Vector2(263,340)],[Vector2(147,332),Vector2(257,352)],[Vector2(137,312),Vector2(238,351)],[Vector2(161,334),Vector2(269,334)],[Vector2(176,347),Vector2(284,347)],[Vector2(155,346),Vector2(264,346)]]

static func region(frame: int) -> Rect2:
	return Rect2(Vector2(frame%3,frame/3)*CELL,CELL)

static func anchor(frame: int) -> Vector2: return REAR[frame]-Vector2(0,165)

static func layers(lean: float, braking: bool, clock: float) -> Array:
	var strength := clampf(absf(lean),0,1)
	if strength>0.18:
		var soft := 1 if lean<0 else 3
		var hard := 0 if lean<0 else 4
		return [[hard if strength>0.65 else soft,1.0]]
	if braking: return [[5,1.0]]
	# Short physical compression/rebound; the rear contact never bobs off the asphalt.
	var pulse := fposmod(clock*1.8,1.0)
	return [[6 if pulse<0.16 else 7 if pulse>0.5 and pulse<0.66 else 2,1.0]]

static func exhaust(lean: float, braking: bool, clock: float) -> Array[Vector2]:
	var result: Array[Vector2] = [Vector2.ZERO,Vector2.ZERO]
	for entry in layers(lean,braking,clock):
		for i in 2: result[i] += (EXHAUST[entry[0]][i]-anchor(entry[0]))*SCALE*entry[1]
	return result

static func draw(canvas: CanvasItem, center: Vector2, lean: float, braking: bool, clock: float):
	for entry in layers(lean,braking,clock):
		if entry[1]<=0.001: continue
		var frame: int = entry[0]
		canvas.draw_texture_rect_region(ATLAS,Rect2(center-anchor(frame)*SCALE,CELL*SCALE),region(frame),Color(1,1,1,entry[1]))
