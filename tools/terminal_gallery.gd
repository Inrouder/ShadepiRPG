## Requires a graphical display. Captures the real in-game terminal controls.
extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(640, 360)
	var world = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(world)
	world._enter(world.Beat.HANGAR)
	world.ui.clear_dialogue()
	world.process_mode = Node.PROCESS_MODE_DISABLED
	for context in ["transponder", "garage", "power", "roof_signal", "repair"]:
		world.open_terminal(context, func(): pass)
		var panel = world.terminal
		match panel.puzzle.kind:
			"matrix":
				panel.puzzle.select_hex(1)
				panel.puzzle.select_hex(11)
			"decoder": panel.puzzle.filter = panel.puzzle.filter_target
			"signal": panel.puzzle.signal_values = [3, 2, 3]
			"jumper":
				panel.puzzle.wiring[2] = 2
				panel.puzzle.check_wiring()
		panel._process(0.0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/terminal-" + panel.puzzle.kind + ".png")
		world.cancel_terminal()
	world.queue_free()
	await process_frame
	quit()
