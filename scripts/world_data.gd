class_name WorldData
extends RefCounted

const SIZE := Vector2(1024, 640)
const START := Vector2(146, 406)
const RAVEN := Vector2(348, 370)
const TERMINAL := Vector2(468, 334)
const JACKAL := Vector2(770, 323)
const EXIT := Vector2(926, 284)
const GATE := Rect2(504, 160, 12, 336)
const WALLS: Array[Rect2] = [Rect2(0, 0, 400, 272), Rect2(452, 0, 572, 256), Rect2(0, 496, 1024, 144), Rect2(-20, 0, 20, 640), Rect2(1024, 0, 20, 640)]
const PROPS: Array[Dictionary] = [
	{"kind": 0, "position": Vector2(306, 310), "collision": Rect2(276, 294, 60, 18)},
	{"kind": 1, "position": Vector2(241, 424), "collision": Rect2(228, 410, 27, 15)},
	{"kind": 1, "position": Vector2(271, 432), "collision": Rect2(258, 418, 27, 15)},
	{"kind": 0, "position": Vector2(656, 451), "collision": Rect2(626, 435, 60, 18)},
	{"kind": 1, "position": Vector2(876, 286), "collision": Rect2(863, 272, 27, 15)},
	{"kind": 2, "position": TERMINAL + Vector2(0, -6), "collision": Rect2(458, 313, 23, 18)}
]

static func walkable(point: Vector2, gate_open: bool, margin: float = 8.0) -> bool:
	if point.x < margin or point.x > SIZE.x - margin or point.y < margin or point.y > SIZE.y - margin:
		return false
	for wall in WALLS:
		if wall.grow(margin).has_point(point):
			return false
	for prop in PROPS:
		if (prop.collision as Rect2).grow(margin).has_point(point):
			return false
	return gate_open or not GATE.grow(margin).has_point(point)
