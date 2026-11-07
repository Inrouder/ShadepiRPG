extends RefCounted


const LAYOUTS: = {
	"demo": [
		["west_lamp", "lamp", Vector2(102, 299)], ["west_crate", "crate", Vector2(94, 474)], 
		["east_car", "car", Vector2(814, 472)], ["east_bin", "dumpster", Vector2(933, 335)], 
	], 
	"street": [
		["market_lamp", "lamp", Vector2(-546, 292)], ["market_vending", "vending", Vector2(-473, 308)], 
		["market_crate", "crate", Vector2(-364, 489)], ["market_barrel", "barrel", Vector2(-310, 489)], 
		["market_lamp_2", "lamp", Vector2(-206, 295)], ["market_car", "car", Vector2(-143, 489)], 
		["market_electric", "electrical", Vector2(-47, 298)], ["yard_car", "car", Vector2(95, 489)], 
		["service_crate", "crate", Vector2(291, 489)], ["service_barrel", "barrel", Vector2(338, 489)], 
		["yard_lamp", "lamp", Vector2(565, 283)], ["yard_vending", "vending", Vector2(719, 289)], 
		["yard_car_2", "car", Vector2(818, 473)], ["yard_electric", "electrical", Vector2(966, 393)], 
		["yard_bin", "dumpster", Vector2(949, 471)], 
	], 
	"industry": [
		["entry_car", "car", Vector2(192, 473)], ["entry_lamp", "lamp", Vector2(89, 300)], 
		["loading_crate", "crate", Vector2(225, 300)], ["loading_barrel", "barrel", Vector2(272, 372)], 
		["track_bin", "dumpster", Vector2(467, 299)], ["track_lamp", "lamp", Vector2(554, 283)], 
		["loading_crate_2", "crate", Vector2(727, 482)], ["loading_crate_3", "crate", Vector2(780, 482)], 
		["fuse_box", "electrical", Vector2(969, 301)], ["back_barrel", "barrel", Vector2(936, 462)], 
	], 
	"hideout": [
		["spare_crate", "crate", Vector2(454, 370)], ["spare_server", "server", Vector2(713, 427)], 
		["spare_electrical", "electrical", Vector2(602, 442)], 
	], 
	"dive": [
		["cache_1", "data_cache", Vector2(221, 306)], ["cache_2", "data_cache", Vector2(303, 475)], 
		["cache_3", "data_cache", Vector2(477, 470)], ["cache_4", "data_cache", Vector2(723, 310)], 
		["cache_5", "data_cache", Vector2(911, 471)], 
	], 
	"ambush": [
		["door_lamp", "lamp", Vector2(181, 285)], ["entry_crate", "crate", Vector2(237, 474)], 
		["cover_barrel", "barrel", Vector2(279, 475)], ["far_car", "car", Vector2(681, 477)], 
		["lookout_lamp", "lamp", Vector2(706, 288)], ["far_bin", "dumpster", Vector2(918, 472)], 
		["fuse_box", "electrical", Vector2(969, 306)], 
	], 
	"garage": [
		["spares", "crate", Vector2(210, 470)], ["tool_case", "electrical", Vector2(534, 299)],
		["oil_drum", "barrel", Vector2(628, 476)], ["retired_car", "car", Vector2(299, 466)], 
		["parts_bin", "dumpster", Vector2(91, 303)], 
	], 
	"hangar": [
		["spare_crate", "crate", Vector2(268, 478)], ["spare_server", "server", Vector2(98, 299)], 
		["fuel_drum", "barrel", Vector2(389, 478)], ["spare_fuel", "barrel", Vector2(434, 478)], 
		["parts_case", "crate", Vector2(582, 305)], ["diagnostics", "server", Vector2(948, 434)], 
	], 
	"chamber": [
		["wall_box", "electrical", Vector2(738.75, 301.5)],
	], 
	"roof": [
		["entry_lamp", "lamp", Vector2(117, 285)], ["cargo_1", "crate", Vector2(479, 475)], 
		["cargo_2", "crate", Vector2(526, 475)], ["backup_generator", "electrical", Vector2(628, 294)], 
		["east_lamp", "lamp", Vector2(969, 285)], ["lift_freight", "crate", Vector2(969, 460)], 
	], 
	"suite": [
		["lift_server", "server", Vector2(477, 314)],
		["power_box", "electrical", Vector2(947, 470)],
	], 
	"lake": [],
}

static func items(layout: String) -> Array:
	return LAYOUTS.get(layout, [])
