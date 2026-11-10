extends RefCounted
## v0.31.0 · CodexAI: source-local environmental cues, never gameplay hazards.
## Coordinates use the unscaled 1024×640 background; the host supplies room transforms.
## Steam: [source, size, tint]; mist/glow: [centre, size, tint, opacity].
const KEYS := ["alley", "street", "apartment", "industry", "hideout", "dive", "ambush", "garage", "hangar", "chamber", "compensator", "memory", "rooftop", "suite", "lakeside", "memory_attack", "memory_sacrifice", "memory_temple"]

static func get_profile(key: String) -> Dictionary:
	match key:
		"alley", "street":
			return {"steam": [[Vector2(322,278),Vector2(66,94),Color("a7c9d8")],[Vector2(-165,290),Vector2(72,108),Color("b5b7d1")]], "reflections": [[Vector2(202,411),94,Color("d4569b")],[Vector2(407,403),85,Color("52c5da")],[Vector2(-428,402),90,Color("dc6e8d")]], "bloom":0.82}
		"apartment":
			return {"dust":[Rect2(85,290,335,175)],"motes":22,"windows":[Rect2(112,0,170,153)],"glows":[[Vector2(225,276),Vector2(110,70),Color("75c7d4"),0.045]],"warm":true,"bloom":0.58}
		"industry":
			return {"steam":[[Vector2(855,269),Vector2(82,128),Color("a9bfae")]],"mist":[[Vector2(170,282),Vector2(225,58),Color("95aea8"),0.075]],"reflections":[[Vector2(845,374),110,Color("a9bd76")]],"bloom":0.75}
		"hideout":
			return {"dust":[Rect2(405,240,355,200)],"motes":12,"steam":[[Vector2(685,360),Vector2(82,100),Color("8dc4d8")]],"panels":[Rect2(401,212,330,26)],"glows":[[Vector2(685,360),Vector2(120,60),Color("80d2df"),0.04]],"bloom":0.64}
		"dive", "memory":
			return {"paths":[[Vector2(350,430),Vector2(552,300)],[Vector2(552,300),Vector2(812,414)],[Vector2(465,305),Vector2(688,330)]],"packets":12,"mist":[[Vector2(610,220),Vector2(300,54),Color("a182d1"),0.055]],"bloom":0.72}
		"ambush":
			return {"steam":[[Vector2(160,255),Vector2(80,110),Color("a0bfd1")]],"reflections":[[Vector2(431,405),130,Color("bd5b92")],[Vector2(858,393),120,Color("69c3d7")]],"bloom":0.82}
		"garage":
			return {"dust":[Rect2(260,250,570,230)],"motes":25,"mist":[[Vector2(260,260),Vector2(190,58),Color("b7ab9b"),0.045]],"glows":[[Vector2(737,257),Vector2(145,90),Color("e4b47e"),0.035]],"warm":true,"bloom":0.62}
		"hangar":
			return {"dust":[Rect2(250,200,650,280)],"motes":24,"steam":[[Vector2(399,301),Vector2(54,87),Color("aebfbd")],[Vector2(682,468),Vector2(62,96),Color("a8bcca")]],"panels":[Rect2(268,278,66,18),Rect2(486,342,86,22)],"glows":[[Vector2(546,214),Vector2(95,135),Color("9fdb9c"),0.035]],"bloom":0.65}
		"chamber":
			return {"dust":[Rect2(245,280,360,185)],"motes":16,"windows":[Rect2(610,139,150,52)],"glows":[[Vector2(441,233),Vector2(145,115),Color("e5ac78"),0.04]],"warm":true,"bloom":0.56}
		"compensator":
			return {"dust":[Rect2(340,240,300,180)],"motes":10,"panels":[Rect2(402,150,166,53)],"glows":[[Vector2(221,244),Vector2(80,120),Color("7dd6dc"),0.045],[Vector2(487,179),Vector2(130,75),Color("73d7ea"),0.03]],"warm":true,"bloom":0.56}
		"rooftop":
			return {"mist":[[Vector2(160,255),Vector2(245,56),Color("89bdcf"),0.075]],"reflections":[[Vector2(323,380),94,Color("5bcddd")],[Vector2(697,369),105,Color("cf5e9b")]],"glows":[[Vector2(222,326),Vector2(160,56),Color("69d5e5"),0.035]],"bloom":0.8}
		"suite":
			return {"dust":[Rect2(340,285,550,180)],"motes":12,"windows":[Rect2(260,20,450,125)],"glows":[[Vector2(625,262),Vector2(150,80),Color("b493d5"),0.025]],"bloom":0.62}
		"lakeside":
			return {"moonlight":true,"fireflies":32,"mist":[[Vector2(510,238),Vector2(250,45),Color("9ac8ce"),0.11],[Vector2(849,338),Vector2(220,45),Color("9ac8ce"),0.09]],"water":true,"bloom":0.63}
		"memory_attack", "memory_sacrifice":
			return {"dust":[Rect2(180,210,820,320)],"motes":18 if key=="memory_attack" else 28,"ash":true,"embers":[Vector2(827,280),Vector2(970,289),Vector2(899,480),Vector2(490,110)],"mist":[[Vector2(850,230),Vector2(240,145),Color("8d7971"),0.09]],"bloom":0.7}
		"memory_temple":
			return {"dust":[Rect2(420,185,540,280)],"motes":20,"ash":true,"embers":[Vector2(72,390),Vector2(993,362)],"mist":[[Vector2(700,210),Vector2(260,90),Color("a18b80"),0.075]],"bloom":0.7}
	return {}
