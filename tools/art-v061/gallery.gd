extends SceneTree
## v0.61.0 · CodexAI. Native game captures, isolated saves, no production mutations.
var w
const OUT := "/tmp/shadepi-v061-world"
func _initialize(): run.call_deferred()
func settle():
	for i in 90:
		await process_frame
		if w.cutscene.running: w.cutscene.skip()
		if w.ui.dialogue_open: w.ui.clear_dialogue()
func shot(name: String):
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + "/" + name + ".png")
func pose_pet(kind: String, red: bool):
	var pet = w.companion
	pet.kind = kind; pet.presence = 1.0; pet.visible = true; pet.modulate.a = 1.0
	pet.lead = w.raven if kind == "drone" else w.player
	pet.position = pet.lead.position + Vector2(36, -36)
	pet.clock = 2.3; pet.attack_flash = 0.1 if red else 0.0
	pet.pulse_time = 0.0; pet.shield_time = 0.0; pet.queue_redraw()
func run():
	if DisplayServer.get_name() == "headless" or not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1); return
	DirAccess.make_dir_recursive_absolute(OUT)
	root.size = Vector2i(1920, 1080)
	w = load("res://scenes/campaign.tscn").instantiate(); root.add_child(w); current_scene = w
	await settle(); w.close_menu(); w.started = true; w.fresh_entry = false
	w._enter(w.Beat.ROOF); await settle()
	w.process_mode = Node.PROCESS_MODE_DISABLED; pose_pet("drone", false); await shot("drone")
	pose_pet("drone", true); await shot("drone-fire")
	w.process_mode = Node.PROCESS_MODE_INHERIT; w.set_coop(true); w._enter(w.Beat.BOSS); await settle()
	w.process_mode = Node.PROCESS_MODE_DISABLED; pose_pet("nanites", false); await shot("nanites")
	pose_pet("nanites", true); await shot("nanites-red")
	w.companion.shield_time = 1.5; w.companion.pulse_time = 0.3; w.companion.queue_redraw(); await shot("nanites-shield")
	w.process_mode = Node.PROCESS_MODE_INHERIT; w._enter(w.Beat.HANGAR); await settle()
	w.process_mode = Node.PROCESS_MODE_DISABLED
	w.raven.position = w.ARCADE_SPOT + Vector2(38, 4)
	w.camera.position = w.ARCADE_SPOT + Vector2(0, -25); w.camera.zoom = Vector2.ONE * 1.4; w.camera.reset_smoothing(); w.camera.force_update_scroll()
	await shot("cabinet")
	w.process_mode = Node.PROCESS_MODE_INHERIT; w._enter(w.Beat.CHASE); await settle()
	w.process_mode = Node.PROCESS_MODE_DISABLED
	w.drive.objects.assign([{"k":"slick", "p":Vector2(245,170), "done":false, "r":0.0}, {"k":"boost", "p":Vector2(350,165), "done":false, "r":0.0}, {"k":"mine", "p":Vector2(400,270), "done":false, "r":0.0}])
	w.drive.hazards.assign([Vector2(250,100)]); w.drive.fx_clock = 2.2; w.drive.queue_redraw(); await shot("road")
	w.free(); current_scene = null; await process_frame
	print("v0.61.0 CodexAI: native world gallery saved to " + OUT); quit()
