extends SceneTree
func _initialize() -> void: run.call_deferred()
func capture(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-sacrifice-"+tag+".png")
func run() -> void:
	var scene=load("res://scenes/memories/sacrifice.tscn").instantiate()
	scene.autoplay=false
	root.add_child(scene)
	scene.ui.hide()
	scene.tank.show()
	scene.tank.position=Vector2(780,400)
	scene.camera.position=Vector2(512,340)
	scene.camera.zoom=Vector2.ONE*0.65
	await capture("map")
	scene.queue_free()
	await process_frame
	var world=load("res://scenes/campaign.tscn").instantiate()
	root.add_child(world)
	world._enter(world.Beat.ECHO,0,1,true,true,false)
	world.ui.clear_dialogue()
	world.raven.position=world.Painted.ECHO_POINTS[1]
	world.interact()
	var panel=world.memory_scene
	var seen := {}
	var wait_time:=0.0
	for i in 1000:
		if not is_instance_valid(panel) or panel.closed: break
		if not seen.has(panel.phase):
			seen[panel.phase]=true
			await capture("scene-"+panel.phase)
		if panel.cutscene.waiting_input:
			wait_time+=0.1
			if wait_time>1.1:
				panel.cutscene.advance()
				wait_time=0
		else: wait_time=0
		if i%2==0: await capture("film-%03d"%i)
		await create_timer(0.1).timeout
	await capture("return")
	print("SACRIFICE FILM: point=",world.point_index," complete=",world.memory_sacrifice_complete)
	world.queue_free()
	await process_frame
	quit()
