extends SceneTree
const Pilot=preload("res://tools/legacy_pilot.gd")
func _initialize() -> void: run.call_deferred()
func capture(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-legacy-"+tag+".png")
func run() -> void:
	var world=load("res://scenes/campaign.tscn").instantiate()
	root.add_child(world)
	world._enter(world.Beat.ECHO,0,2,true,true,true,false)
	world.ui.clear_dialogue()
	world.raven.position=world.Painted.ECHO_POINTS[2]
	world.interact()
	var panel=world.memory_scene
	var seen:={}
	var wait_time:=0.0
	for i in 1200:
		if not is_instance_valid(panel) or panel.closed: break
		if panel.menu_open: panel.toggle_pause()
		if not seen.has(panel.phase):
			seen[panel.phase]=true
			await capture("scene-"+panel.phase)
		if panel.phase=="master_death" and panel.master.visible and panel.cutscene.overlay.color.a<0.02 and panel.camera.zoom.x>1.2 and not seen.has("master_body"):
			seen.master_body=true
			await capture("master-body")
		if panel.phase=="final_battle" and panel.aura.power>0.9 and not seen.has("aura_battle"):
			seen.aura_battle=true
			await capture("aura-battle")
		if panel.phase=="temple_breach" and panel.map.door_frame==2 and not seen.has("breach_peak"):
			seen.breach_peak=true
			await capture("door-break")
		if panel.phase=="transfer" and panel.transfer_frame==4 and not seen.has("transfer_peak"):
			seen.transfer_peak=true
			await capture("transfer-peak")
		if panel.phase=="final_battle" and panel.battle!=null:
			Pilot.step(panel)
			if panel.battle.dead:
				push_error("Renderer pilot lost the final battle")
				break
			if panel.tanks[0].destroyed and not seen.has("one_down"):
				seen.one_down=true
				await capture("battle-one-down")
		if panel.cutscene.waiting_input:
			wait_time+=0.1
			if wait_time>1.2:
				panel.cutscene.advance()
				wait_time=0
		else: wait_time=0
		if i%2==0: await capture("film-%03d"%i)
		await create_timer(0.1).timeout
	await capture("return")
	print("LEGACY FILM: third_complete=",world.memory_legacy_complete," beat=",world.beat)
	world.queue_free()
	await process_frame
	quit()
