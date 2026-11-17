extends SceneTree
## v0.61.0 · CodexAI. Actual arcade inputs, contact windows and separate generated poses.
const Kombat = preload("res://scripts/arcade/neon_kombat.gd")
class PadArcade extends "res://scripts/arcade/neon_kombat.gd":
	func _pad_for(index: int) -> int: return 77 if index == 0 else 78

var checks := 0
var failures := 0
var game
var frame_number := 0
const OUT := "/tmp/shadepi-v061-gallery"

func _initialize(): run.call_deferred()
func check(ok: bool, label: String):
	checks += 1
	if not ok: failures += 1; push_error("FAIL: " + label)
func settle():
	for i in 4: await process_frame
	if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw
func capture(name: String):
	game.stage_node.queue_redraw(); game.hud_node.queue_redraw()
	await settle()
	if DisplayServer.get_name() != "headless":
		var im := root.get_texture().get_image()
		im.save_png(OUT + "/" + name + ".png")
		im.save_png(OUT + "/frame-%03d.png" % frame_number)
		frame_number += 1
func pad(button: JoyButton, down: bool):
	var e := InputEventJoypadButton.new(); e.device = 77; e.button_index = button; e.pressed = down
	Input.parse_input_event(e); await process_frame
	game._poll()
func press(button: JoyButton):
	await pad(button, true)
	game._control(0, {"held": game.held[0], "pressed": game.pressed[0]})
	await pad(button, false)
func fresh(index: int = 0):
	game.start_match(index, (index + 1) % 10, true); game.phase = "fight"; game.banner = ""
	game.fighters[0].x = 260.0; game.fighters[1].x = 320.0

func run():
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1); return
	root.size = Vector2i(1920, 1080)
	if "--small" in OS.get_cmdline_user_args(): root.size = Vector2i(640, 360)
	DirAccess.make_dir_recursive_absolute(OUT)
	game = PadArcade.new(); root.add_child(game); game.set_process(false); await settle()
	check(game.ATLAS.data.poses.size() == 16, "sixteen named exclusive poses")
	for index in 10:
		fresh(index)
		var f: Dictionary = game.fighters[0]
		var im: Image = game.sheets[f.data.id].get_image()
		check(im.get_size() == Vector2i(2048, 1280), str(f.data.id) + " uses its exclusive atlas")
		var unique := {}
		for pose in 16:
			var cell := im.get_region(Rect2i((pose % 4) * 512, (pose / 4) * 320, 512, 320))
			unique[hash(cell.get_data())] = true
			check(cell.get_used_rect().has_area(), str(f.data.id) + " complete pose " + str(pose))
		check(unique.size() >= 15, str(f.data.id) + " distinct drawn actions")
		for action in ["light", "medium", "heavy", str(f.data.special)]:
			game._begin(f, action); f.t = 0.0
			var before: int = game.pose_index(f)
			f.t = game.MOVES[action].start
			check(game.pose_index(f) == before + 1, str(f.data.id) + " contact matches damage window " + action)
		f.state = "block"; check(game.pose_index(f) == 5, "real guard pose")
		f.state = "jump"; check(game.pose_index(f) == 4, "real knees-up pose")
		f.state = "ko"; f.y = 0.0; check(game.pose_index(f) == 7, "real lying pose")
		f.face = 1.0; var right: Vector2 = game.emitter(f)
		f.face = -1.0; var left: Vector2 = game.emitter(f)
		check(is_equal_approx(right.x - f.x, f.x - left.x) and right.y == left.y, "mirrored hand/muzzle anchor " + str(f.data.id))
		# Native footage walks through real action frames for every selectable fighter.
		if "--gallery" in OS.get_cmdline_user_args():
			f.face = 1.0; f.y = 0.0; f.x = 220.0; game.fighters[1].x = 440.0
			for pose in ["idle", "light", "heavy", str(f.data.special), "block", "ko"]:
				f.state = pose; f.flash = 0.0; f.hp = 0.0 if pose == "ko" else float(f.data.hp)
				f.t = float(game.MOVES[pose].start) if game.MOVES.has(pose) else 0.0
				await capture(str(f.data.id) + "-" + pose)
	fresh()
	var f: Dictionary = game.fighters[0]; var other: Dictionary = game.fighters[1]
	game._begin(f, "light"); f.t = game.MOVES.light.start
	game._strike(0); var remaining: float = other.hp
	game._strike(0)
	check(f.confirmed and other.hp == remaining, "one punch contact damages exactly once")
	f.t = game.MOVES.light.active; game.hitstop = 0.0
	game._control(0, {"held": {}, "pressed": {"b": true}})
	check(f.state == "medium", "confirmed Light cancels into Medium")
	fresh(); f = game.fighters[0]; game._begin(f, "light"); f.t = game.MOVES.light.active; game.hitstop = 0.0
	game._control(0, {"held": {}, "pressed": {"b": true}})
	check(f.state == "light", "whiff keeps recovery")
	fresh(); f = game.fighters[0]; other = game.fighters[1]
	other.blocking = true; other.face = -1.0
	game._begin(f, "light"); f.t = game.MOVES.light.start; game._strike(0)
	check(not f.confirmed, "blocked punch cannot confirm-cancel")
	fresh(1); f = game.fighters[0]; f.meter = 100.0
	await press(JOY_BUTTON_X); check(f.state == "light", "controller X punches")
	fresh(1); f = game.fighters[0]
	await press(JOY_BUTTON_Y); check(f.state == "medium", "controller Y is Medium")
	fresh(1); f = game.fighters[0]
	await press(JOY_BUTTON_B); check(f.state == "heavy", "controller B is Heavy")
	fresh(1); f = game.fighters[0]; f.meter = 100.0
	await press(JOY_BUTTON_A); check(f.state == "shot" and f.meter == 50.0, "controller A is Special EX")
	f.t = game.MOVES.shot.start; game._strike(0)
	check(not game.shots.is_empty() and Vector2(game.shots[0].x, game.shots[0].y).is_equal_approx(game.emitter(f)), "actual projectile starts at registered palm")
	check(game.shots[0].art == 4, "Raven casts lightning rather than bullet")
	fresh(8); f = game.fighters[0]; f.meter = 100.0
	game._begin(f, "shot"); f.t = game.MOVES.shot.start; game._strike(0)
	check(game.shots[0].art == 5, "guard rifle fires bullet")
	fresh(); f = game.fighters[0]
	await press(JOY_BUTTON_DPAD_UP); check(f.vy < 0.0 and f.state == "jump", "controller jumps into dedicated pose")
	fresh(); f = game.fighters[0]
	await press(JOY_BUTTON_DPAD_DOWN); check(not f.blocking and game.pose_index(f) == 15, "controller down crouches in the dedicated low pose")
	fresh(); game.winner = 0; game.phase = "ko"
	check(game.pose_index(game.fighters[0]) == 14, "only actual round winner celebrates")
	check(game.pose_index(game.fighters[1]) != 14, "timeout loser does not celebrate")
	game.back(); check(game.fighters.is_empty() and game.shots.is_empty(), "leaving fight clears actions")
	game.free(); await process_frame
	print("ARCADE ART: %d checks, %d failures" % [checks, failures]); quit(1 if failures else 0)
