extends RefCounted
## Authored spawn points and variants; no changes to player moves or boss rules.
const HUNT := [
	{"bounds": Vector2(-630, -290), "floor": Vector2(272, 496), "start": Vector2(-554, 356), "trail": 0, "waves": [
		[[Vector2(-491, 401), 0], [Vector2(-329, 432), 1]],
		[[Vector2(-490, 444), 2], [Vector2(-340, 342), 3]],
	]},
	{"bounds": Vector2(-290, 160), "floor": Vector2(272, 496), "start": Vector2(-246, 346), "trail": 1, "waves": [
		[[Vector2(-156, 356), 2], [Vector2(81, 404), 1]],
		[[Vector2(-165, 425), 0], [Vector2(80, 350), 3]],
	]},
	{"bounds": Vector2(160, 500), "floor": Vector2(272, 496), "start": Vector2(219, 451), "trail": 3, "waves": [
		[[Vector2(315, 343), 1], [Vector2(457, 432), 3]],
		[[Vector2(320, 425), 0], [Vector2(456, 345), 2]],
	]},
]
const RESCUE := [
	{"bounds": Vector2(280, 500), "floor": Vector2(272, 496), "start": Vector2(295, 451), "waves": [
		[[Vector2(347, 351), 2], [Vector2(466, 382), 3], [Vector2(483, 442), 0]],
		[[Vector2(330, 432), 1], [Vector2(465, 340), 2]],
		[[Vector2(340, 350), 0], [Vector2(465, 390), 1], [Vector2(465, 445), 3]],
	]},
]
const AMBUSH := [
	{"bounds": Vector2(20, 510), "floor": Vector2(268, 522), "start": Vector2(134, 421), "waves": [
		[[Vector2(450, 355), 0], [Vector2(445, 445), 1]],
		[[Vector2(190, 345), 2], [Vector2(455, 420), 1]],
		[[Vector2(200, 425), 3], [Vector2(455, 350), 0]],
	]},
	{"bounds": Vector2(510, 1000), "floor": Vector2(268, 522), "start": Vector2(550, 410), "waves": [
		[[Vector2(717, 364), 0], [Vector2(860, 395), 1]],
		[[Vector2(680, 365), 2], [Vector2(925, 370), 1]],
		[[Vector2(700, 390), 3], [Vector2(865, 360), 0], [Vector2(930, 415), 2]],
	]},
]
const ROOF := [
	{"bounds": Vector2(540, 1000), "floor": Vector2(235, 495), "start": Vector2(700, 360), "waves": [
		[[Vector2(735, 335), 2], [Vector2(870, 320), 1]],
		[[Vector2(680, 395), 0], [Vector2(920, 370), 1]],
		[[Vector2(720, 370), 2], [Vector2(895, 400), 3], [Vector2(940, 345), 1]],
	]},
]
