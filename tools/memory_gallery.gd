extends SceneTree
var memory: Node2D
func _initialize() -> void: run.call_deferred()
func capture(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png('/tmp/shadepi-memory-'+tag+'.png')
func run() -> void:
	memory = load('res://scenes/memories/attack.tscn').instantiate()
	memory.autoplay = false
	root.add_child(memory)
	memory.camera.zoom = Vector2(0.5625,0.5625)
	memory.camera.position = Vector2(512,320)
	memory.ui.hide()
	await capture('map')
	for actor in memory.squad+memory.residents: actor.hide()
	for i in memory.squad.size():
		var actor = memory.squad[i]
		actor.show()
		actor.position = Vector2(210+i*145,390)
		actor.facing = Vector2.RIGHT
		actor.animate('idle',0)
	await capture('warriors')
	for actor in memory.squad: actor.hide()
	for i in 4:
		var actor = memory.residents[i]
		actor.show()
		actor.position = Vector2(240+i*170,400)
		actor.facing = Vector2.LEFT
		actor.animate('walk',0.15)
	await capture('residents')
	# Close view of the four real gait frames, separate from the story recording.
	memory.camera.zoom = Vector2.ONE*1.2
	memory.camera.position = Vector2(512,400)
	for i in 4:
		memory.residents[i].position = Vector2(320+i*130,400)
		memory.residents[i].animation_name = ""
	for frame in 4:
		for i in 4: memory.residents[i].animate("walk",0 if frame==0 else 1.0/9.0+0.0001)
		await capture("gait-%d"%frame)
	memory.queue_free()
	await process_frame
	if "--record" in OS.get_cmdline_user_args(): await record()
	quit()

func record() -> void:
	var world = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(world)
	world._enter(world.Beat.ECHO,0,0,true,false)
	world.ui.clear_dialogue()
	world.raven.position = world.Painted.ECHO_POINTS[0]
	world.interact()
	var panel = world.memory_scene
	var wait_time := 0.0
	var captured := {}
	for i in 1500:
		if not is_instance_valid(panel) or panel.closed: break
		if panel.cutscene.waiting_input:
			wait_time += 0.1
			if wait_time>0.9:
				panel.cutscene.advance()
				wait_time = 0
		else: wait_time = 0
		if not captured.has(panel.phase):
			captured[panel.phase] = true
			await capture("scene-"+panel.phase)
		if i%2==0: await capture("film-%03d"%i)
		await create_timer(0.1).timeout
	await capture("return")
	print("MEMORY FILM: point=",world.point_index," complete=",world.memory_attack_complete)
	world.queue_free()
	await process_frame
