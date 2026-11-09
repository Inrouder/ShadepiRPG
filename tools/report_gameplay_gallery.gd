extends SceneTree
## v0.45.0 · CodexAI. Actual source comparison and reported scene transitions.
const OUT := "/tmp/shadepi-report-v045"
var serial:=0
func _initialize():run.call_deferred()
func shot(tag: String):
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"/"+tag+".png")
func finish(w):
	for i in 4000:
		await process_frame
		if w.cutscene.waiting_input:w.cutscene.advance()
		if not w.cutscene.running:return
func run():
	set_meta("shadepi_admin_testing",true)
	DirAccess.make_dir_recursive_absolute(OUT)
	Engine.max_fps=60
	var w=load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(w)
	w._enter_checkpoint(w.Phase.TEAM)
	w.cutscene.abort()
	w.set_process(false)
	w.enemy.hide()
	w.player.position=Vector2(720,430)
	w.raven.reset_visual_pose()
	w.raven.health=100
	w.raven.position=Vector2(775,430)
	w.raven.facing=Vector2.LEFT
	w.player.facing=Vector2.RIGHT
	w.camera.position=Vector2(747,392)
	w.camera.zoom=Vector2.ONE*2.5
	w.player.animate("idle",0)
	w.raven.animate("idle",0)
	await shot("heroes-new")
	w.player.hide();w.raven.hide()
	var old_actors: Array=[]
	for pair in [["shadepi",w.player],["raven",w.raven]]:
		var old=PixelActor.new()
		old.setup(load("res://assets/sprites/heroes/backup-v0441/"+pair[0]+".png"),w)
		old.position=pair[1].position;old.facing=pair[1].facing
		w.actors.add_child(old);old.animate("idle",0);old_actors.append(old)
	await shot("heroes-backup")
	for old in old_actors:old.free()
	w.player.show();w.raven.show()
	for actor in [w.player,w.raven]:actor.set_physics_process(false)
	for frame in 4:
		w.raven.facing=Vector2.RIGHT
		w.raven.animate("walk",0.15)
		await shot("raven-east-"+str(frame))
	w.raven.show_reaction(2)
	await shot("raven-ground")
	w.raven.clear_reaction()
	w.enemy.position=Vector2(745,430)
	w.enemy.show()
	w.enemy.health=1;w.enemy.min_health=0
	w.enemy.take_damage(100,w.player.position)
	w.enemy.reaction._process(0.9)
	await shot("jackal-ground")
	w.free()
	await process_frame
	w=load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w.restore_dressing_state({})
	w._enter(w.Beat.AMBUSH)
	w.set_process(false)
	w.cutscene.abort()
	w.player.set_physics_process(false)
	for i in 2:
		var foe=w.foes[i]
		foe.set_physics_process(false)
		foe.position=Vector2(450+i*50,420)
		foe.facing=Vector2.RIGHT
		foe.attack_direction=Vector2.RIGHT
		foe.attack_visual_time=0.35
		foe.animate("attack",0.15)
	w.camera.position=Vector2(475,383)
	w.camera.zoom=Vector2.ONE*2
	await shot("shooters")
	w._enter(w.Beat.GARAGE);w.cutscene.abort()
	for device in w.destructibles:
		if device.kind=="electrical":
			w.raven.position=device.position+Vector2(44,4);w.raven.facing=Vector2.LEFT;w.raven.animate("idle",0)
			w.camera.position=device.position+Vector2(22,-36);w.camera.zoom=Vector2.ONE*2
			await shot("electrical-intact")
			device.take_damage(device.max_health/2+1)
			for i in 15:await process_frame
			await shot("electrical-damaged")
			break
	w.fresh_entry=true
	w._enter(w.Beat.GARAGE)
	for i in 4000:
		await process_frame
		if w.cutscene.waiting_input:w.cutscene.advance()
		if w.garage_door>0.85:
			await shot("garage-entry")
			break
	w.cutscene.skip()
	await finish(w)
	await shot("garage-console")
	w.cutscene.abort()
	w._enter(w.Beat.LAKE)
	w._ritual_step()
	for i in 1200:
		await process_frame
		if w.cutscene.waiting_input:
			await shot("lake-facing")
			break
	w.cutscene.abort()
	w.free()
	await process_frame
	print("REPORT GAMEPLAY GALLERY complete")
	quit()
