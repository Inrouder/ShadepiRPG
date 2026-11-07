extends RefCounted

# This interior uses human-sized furniture; all geometry uses the same transform.
const CHAMBER_SCALE := 0.55
const CHAMBER_RECT := Rect2(230, 120, 563.2, 352)
const CHAMBER_CAMERA := Vector2(512, 310)

static func chamber_point(point: Vector2) -> Vector2:
	return CHAMBER_RECT.position + point * CHAMBER_SCALE

const ART: = {
	"alley": preload("res://assets/world/painted/alley.png"), 
	"market": preload("res://assets/world/painted/market.png"), 
	"apartment": preload("res://assets/world/painted/apartment.png"), 
	"industry": preload("res://assets/world/painted/industry.png"), 
	"hideout": preload("res://assets/world/painted/hideout.png"), 
	"dive": preload("res://assets/world/painted/dive.png"), 
	"ambush": preload("res://assets/world/painted/ambush.png"), 
	"garage": preload("res://assets/world/painted/garage.png"), 
	"hangar": preload("res://assets/world/painted/hangar.png"), 
	"chamber": preload("res://assets/world/painted/chamber.png"), 
	"memory": preload("res://assets/world/painted/memory.png"), 
	"rooftop": preload("res://assets/world/painted/rooftop.png"), 
	"suite": preload("res://assets/world/painted/suite.png"), 
	"lakeside": preload("res://assets/world/painted/lakeside.png"), 
	"highway": preload("res://assets/world/painted/highway.png"), 
	"airspace": preload("res://assets/world/painted/airspace.png"), 
}



const FLOOR_EDGES: = {
	"industry": Vector2(250, 507), "hideout": Vector2(242, 545), 
	"dive": Vector2(243, 495), "ambush": Vector2(268, 522), 
	"garage": Vector2(250, 516), "hangar": Vector2(232, 547), 
	"chamber": Vector2(286.65, 416.45), "memory": Vector2(199, 495),
	"rooftop": Vector2(235, 495), "suite": Vector2(283, 523), 
	"lakeside": Vector2(251, 540), 
}
const SOLIDS: = {
	"industry": [Rect2(346, 252, 81, 137), Rect2(591, 384, 80, 122)], 
	"hideout": [
		Rect2(373, 242, 10, 229), Rect2(766, 242, 10, 229), Rect2(373, 461, 403, 10), 
		Rect2(443, 281, 113, 36), Rect2(630, 322, 115, 57), Rect2(505, 385, 82, 30), 
	], 
	"dive": [Rect2(354, 264, 68, 125), Rect2(599, 386, 59, 107)], 
	"ambush": [Rect2(282, 367, 115, 45), Rect2(559, 293, 93, 54), Rect2(729, 442, 110, 26)], 
	"garage": [Rect2(884, 354, 36, 62)], # parked motorcycle on the lift platform
	"hangar": [Rect2(360, 280, 84, 36), Rect2(621, 410, 108, 71), Rect2(505, 250, 100, 10), Rect2(807, 281, 185, 60)], 
	"chamber": [Rect2(449, 286.65, 47, 8.35), Rect2(566, 286.65, 68, 7.35)],
	"memory": [], 
	"rooftop": [Rect2(774, 262, 160, 49), Rect2(293, 318, 94, 25)], 
	"suite": [Rect2(330, 360, 61, 24), Rect2(573, 283, 80, 24), Rect2(755, 422, 92, 25)], 
	"lakeside": [], 
}
const WATER_EDGE: = [
	Vector2(0, 0), Vector2(1024, 0), Vector2(1024, 460),
	Vector2(925, 434), Vector2(800, 420), Vector2(740, 400),
	Vector2(690, 376), Vector2(657, 356), Vector2(633, 336),
	Vector2(616, 322), Vector2(592, 309), Vector2(562, 298),
	Vector2(522, 283), Vector2(473, 272), Vector2(429, 262),
	Vector2(400, 250), Vector2(342, 243), Vector2(265, 239),
	Vector2(195, 230), Vector2(160, 210), Vector2(0, 205),
]
const ECHO_POINTS: = [Vector2(465, 305), Vector2(688, 330), Vector2(874, 340)]



const OCCLUDERS: = {
	"market": [
		[379.0, [Vector2(199, 284), Vector2(225, 250), Vector2(235, 250), Vector2(235, 348), Vector2(209, 379), Vector2(199, 376)]], 
		[480.0, [Vector2(368, 374), Vector2(399, 334), Vector2(412, 334), Vector2(412, 437), Vector2(381, 480), Vector2(368, 478)]], 
		[379.0, [Vector2(528, 284), Vector2(555, 250), Vector2(567, 250), Vector2(567, 347), Vector2(540, 379), Vector2(528, 377)]], 
	], 
	"alley": [
		[394.0, [Vector2(178, 331), Vector2(190, 274), Vector2(204, 274), Vector2(204, 388), Vector2(195, 394), Vector2(178, 392)]], 
		[495.0, [Vector2(376, 431), Vector2(387, 354), Vector2(399, 354), Vector2(405, 485), Vector2(394, 495), Vector2(376, 493)]], 
	], 
	"industry": [
		[389.0, [Vector2(346, 246), Vector2(427, 246), Vector2(427, 389), Vector2(346, 389)]], 
		[506.0, [Vector2(591, 384), Vector2(671, 384), Vector2(671, 506), Vector2(591, 506)]], 
	], 
	"dive": [
		[389.0, [Vector2(351, 239), Vector2(417, 219), Vector2(426, 372), Vector2(351, 389)]], 
		[493.0, [Vector2(598, 369), Vector2(650, 365), Vector2(659, 491), Vector2(598, 493)]], 
	], 
	"ambush": [
		[412.0, [Vector2(282, 353), Vector2(388, 350), Vector2(397, 412), Vector2(282, 412)]], 
		[347.0, [Vector2(558, 251), Vector2(641, 251), Vector2(652, 347), Vector2(558, 347)]], 
		[468.0, [Vector2(729, 424), Vector2(836, 424), Vector2(839, 468), Vector2(729, 468)]], 
	], 
	"hangar": [
		[316.0, [Vector2(360, 241), Vector2(444, 241), Vector2(444, 316), Vector2(360, 316)]], 
		[481.0, [Vector2(621, 380), Vector2(729, 380), Vector2(729, 481), Vector2(621, 481)]], 
	], 
	"suite": [
		[384.0, [Vector2(330, 335), Vector2(391, 335), Vector2(391, 384), Vector2(330, 384)]], 
		[307.0, [Vector2(573, 235), Vector2(653, 235), Vector2(653, 307), Vector2(573, 307)]], 
		[447.0, [Vector2(755, 390), Vector2(847, 390), Vector2(847, 447), Vector2(755, 447)]], 
	], 
}

static func walls(key: String) -> Array[Rect2]:
	var result: Array[Rect2] = []
	if not FLOOR_EDGES.has(key):
		return result
	var edges: Vector2 = FLOOR_EDGES[key]
	if key == "chamber":
		result.append(Rect2(0, 0, CHAMBER_RECT.position.x, 640))
		result.append(Rect2(CHAMBER_RECT.end.x, 0, 1024 - CHAMBER_RECT.end.x, 640))
	result.append(Rect2(0, 0, 1024, edges.x))
	result.append(Rect2(0, edges.y, 1024, 640 - edges.y))
	for box: Rect2 in SOLIDS.get(key, []):
		result.append(box)
	return result
