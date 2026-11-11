extends RefCounted
## Authored spawn points and variants; no changes to player moves or boss rules.
const HUNT := [
	{"bounds": Vector2(-630, -290), "floor": Vector2(272, 496), "start": Vector2(-554, 356), "trail": 0, "waves": [
		[[Vector2(-491, 401), 0], [Vector2(-329, 432), 1]],
		[[Vector2(-490, 444), 2], [Vector2(-340, 342), 3]],
		# v0.59.0 · ClaudeHelper: je Abschnitt eine dritte Welle zu dritt.
		[[Vector2(-491, 401), 1], [Vector2(-329, 432), 0], [Vector2(-340, 342), 2]],
	]},
	{"bounds": Vector2(-290, 160), "floor": Vector2(272, 496), "start": Vector2(-246, 346), "trail": 1, "waves": [
		[[Vector2(-156, 356), 2], [Vector2(81, 404), 1]],
		[[Vector2(-165, 425), 0], [Vector2(80, 350), 3]],
		[[Vector2(-156, 356), 3], [Vector2(81, 404), 2], [Vector2(80, 350), 1]],
	]},
	{"bounds": Vector2(160, 500), "floor": Vector2(272, 496), "start": Vector2(219, 451), "trail": 3, "waves": [
		[[Vector2(315, 343), 1], [Vector2(457, 432), 3]],
		[[Vector2(320, 425), 0], [Vector2(456, 345), 2]],
		[[Vector2(315, 343), 3], [Vector2(457, 432), 1], [Vector2(456, 345), 0]],
	]},
]
const RESCUE := [
	{"bounds": Vector2(280, 500), "floor": Vector2(272, 496), "start": Vector2(295, 451), "waves": [
		[[Vector2(347, 351), 2], [Vector2(466, 382), 3], [Vector2(483, 442), 0]],
		[[Vector2(330, 432), 1], [Vector2(465, 340), 2]],
		[[Vector2(340, 350), 0], [Vector2(465, 390), 1], [Vector2(465, 445), 3]],
		# v0.59.0 · ClaudeHelper: letzte Welle vor Jackal.
		[[Vector2(347, 351), 3], [Vector2(483, 442), 2], [Vector2(466, 382), 0]],
	]},
]
const AMBUSH := [
	{"bounds": Vector2(20, 510), "floor": Vector2(268, 522), "start": Vector2(134, 421), "waves": [
		[[Vector2(450, 355), 0], [Vector2(445, 445), 1]],
		[[Vector2(190, 345), 2], [Vector2(455, 420), 1]],
		[[Vector2(200, 425), 3], [Vector2(455, 350), 0]],
		# v0.58.0 · ClaudeHelper: vierte Welle – Kenzōs Leute rücken von beiden Seiten nach.
		[[Vector2(190, 345), 2], [Vector2(450, 355), 0], [Vector2(445, 445), 1]],
	]},
	{"bounds": Vector2(510, 1000), "floor": Vector2(268, 522), "start": Vector2(550, 410), "waves": [
		[[Vector2(717, 364), 0], [Vector2(860, 395), 1]],
		[[Vector2(680, 365), 2], [Vector2(925, 370), 1]],
		[[Vector2(700, 390), 3], [Vector2(865, 360), 0], [Vector2(930, 415), 2]],
		# Truppführer (Variante 4): Schild nach vorn, mehr Leben; zwei Schützen decken ihn.
		[[Vector2(900, 390), 4], [Vector2(690, 360), 0], [Vector2(935, 430), 1]],
	]},
]
# Kenzō's guards storm the penthouse from the lift (bottom centre) only after
# Kenzō has fallen; the dead-man switch calls them up from the floor below.
const LIFT := [
	{"bounds": Vector2(12, 1012), "floor": Vector2(283, 523), "start": Vector2(60, 420), "waves": [
		[[Vector2(450, 482), 0], [Vector2(575, 486), 1]],
		[[Vector2(380, 470), 2], [Vector2(650, 475), 1], [Vector2(512, 498), 0]],
		[[Vector2(420, 490), 3], [Vector2(600, 494), 2], [Vector2(512, 470), 1]],
		# v0.59.0 · ClaudeHelper: Nachhut mit zwei Schildträgern (Variante 2).
		[[Vector2(400, 482), 2], [Vector2(620, 484), 2], [Vector2(512, 498), 3]],
	]},
]
