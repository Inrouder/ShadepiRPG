extends SceneTree
## v0.61.0 CodexAI: deterministic native 12-fps fighting footage of actual rules.
const Kombat = preload("res://scripts/arcade/neon_kombat.gd")
const OUT := "/tmp/shadepi-v061-film"
func _initialize(): run.call_deferred()
func run():
	if DisplayServer.get_name() == "headless" or not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1); return
	root.size = Vector2i(640, 360); DirAccess.make_dir_recursive_absolute(OUT)
	var game = Kombat.new(); root.add_child(game); game.set_process(false)
	for i in 6: await process_frame
	var frame := 0
	for pair in [[0, 1], [1, 2], [3, 4], [5, 6], [7, 8], [9, 0]]:
		game.start_match(pair[0], pair[1], true); game.phase = "fight"; game.banner = ""
		game.fighters[0].x = 275.0; game.fighters[1].x = 340.0
		game.fighters[0].meter = 100.0; game.fighters[1].meter = 100.0
		for step in 36:
			for tick in 5:
				game.pressed = [{}, {}]; game.held = [{}, {}]
				if tick == 0:
					if step == 0: game.pressed[0] = {"a": true}
					if step == 2: game.pressed[0] = {"b": true}
					if step == 12: game.pressed[0] = {"c": true}
					if step == 22: game.pressed[1] = {"c": true}
				game.clock += 1.0 / 60.0
				game.shake = move_toward(game.shake, 0.0, 14.0 / 60.0)
				game._update_fight(1.0 / 60.0)
			game.stage_node.queue_redraw(); game.hud_node.queue_redraw()
			for i in 3: await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OUT + "/frame-%04d.png" % frame); frame += 1
	game.free(); await process_frame; print("ARCADE FILM: ", frame, " native frames"); quit()
