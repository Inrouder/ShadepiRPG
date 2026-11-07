## Requires a graphical display. Captures the real in-game terminal controls in
## the scene where each terminal is used (themed frame over the blurred level).
extends SceneTree

const SCENES := {"transponder": "HANGAR", "garage": "GARAGE", "power": "HANGAR", "roof_signal": "ROOF",
	"repair": "FLIGHT", "penthouse": "ROOF", "charge": "ESCAPE"}
const DOCS := ["transponder", "garage", "power", "roof_signal", "repair"]

func _initialize() -> void:
	run.call_deferred()

func capture(world, context: String) -> void:
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
	for i in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	image.save_png("/tmp/shadepi-terminal-%s.png" % context)
	if context in DOCS:
		image.save_png("res://docs/terminal-" + panel.puzzle.kind + ".png")
	if context == "transponder":
		panel._toggle_help()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/terminal-hilfe.png")
	world.cancel_terminal()
	await process_frame

func run() -> void:
	root.size = Vector2i(1280, 720)
	var one = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(one)
	await process_frame
	one.close_menu()
	one.started = true
	one._enter_checkpoint(one.Phase.HUNT)
	one.cutscene.abort()
	one.ui.clear_toast()
	await create_timer(0.3).timeout
	await capture(one, "jackal")
	one.queue_free()
	await process_frame
	var world = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(world)
	await process_frame
	world.close_menu()
	world.started = true
	for context in ["transponder", "garage", "power", "roof_signal", "penthouse", "charge", "repair"]:
		world._enter(world.Beat[SCENES[context]])
		world.cutscene.abort()
		world.ui.clear_dialogue()
		world.ui.clear_toast()
		await create_timer(0.3).timeout
		await capture(world, context)
	world.queue_free()
	await process_frame
	quit()
