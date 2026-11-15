extends RefCounted
## v0.64.0 · CodexAI. The same active input context drives local and remote touch UI.
const CONTEXTS := ["menu", "terminal", "arcade", "arcade_menu", "shadepi", "raven"]

static func for_world(world: Node, remote_player: bool = false) -> String:
	if not is_instance_valid(world): return "menu"
	var arcade = world.get("arcade")
	if is_instance_valid(arcade):
		if arcade.session_paused: return "menu"
		return "arcade" if arcade.screen == arcade.Screen.FIGHT else "arcade_menu"
	if world.get("menu_open") == true: return "menu"
	var terminal = world.get("terminal")
	if is_instance_valid(terminal) and terminal.visible: return "terminal"
	var pads = world.get("gamepads")
	if remote_player or (world.has_method("raven_leads") and world.raven_leads()) or (pads != null and pads.raven_device == 100): return "raven"
	return "shadepi"
