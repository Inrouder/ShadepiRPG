extends SceneTree
## v0.46.0 · CodexAI: actual enemy damage and live blood rendering, isolated QA setup.
const OUT="/tmp/shadepi-blood-v046"
var index:=0
var w
var foe
func _initialize():run.call_deferred()
func capture(tag: String=""):
	await RenderingServer.frame_post_draw
	var picture=root.get_texture().get_image()
	picture.save_png(OUT+"/frame-%04d.png"%index)
	if not tag.is_empty():picture.save_png(OUT+"/"+tag+".png")
	index+=1
func frames(count: int,tag: String=""):
	for i in count:
		await process_frame
		if is_instance_valid(foe) and foe.health>0:foe.animate(foe.animation_name,1.0/60.0)
		if i%3==0:await capture(tag if i==0 else "")
func strike(amount: int):
	w.player.facing=Vector2.RIGHT
	w.player.animate("attack",0.12)
	foe.take_damage(amount,w.player.position)
	foe.animate("hurt",0)
	w.blood_effects.sprays.back().t=0.08
func run():
	set_meta("shadepi_admin_testing",true)
	DirAccess.make_dir_recursive_absolute(OUT)
	Engine.max_fps=60
	w=load("res://scenes/chapter_one.tscn").instantiate();root.add_child(w)
	w._enter_checkpoint(w.Phase.RESCUE);w.cutscene.abort()
	for actor in w.patrol:actor.hide();actor.set_physics_process(false)
	w.encounter.set_process(false)
	w.close_menu();w.set_process(false)
	w.audio_on=false
	w.enemy.hide();w.enemy.set_physics_process(false)
	w.raven.reset_visual_pose();w.raven.show();w.raven.position=Vector2(874,445);w.raven.facing=Vector2.LEFT;w.raven.animate("idle",0)
	w.player.position=Vector2(718,430)
	for actor in [w.player,w.raven]:actor.set_physics_process(false)
	w.player.facing=Vector2.RIGHT;w.player.animate("idle",0)
	foe=w.EnemyScript.new();foe.setup(load("res://assets/sprites/npcs/punk-1.png"),w)
	w.actors.add_child(foe);foe.position=Vector2(779,430);foe.set_physics_process(false)
	foe.health=100;foe.max_health=100;foe.active=true;foe.facing=Vector2.LEFT;foe.animate("idle",0)
	w.camera.position=Vector2(778,394);w.camera.zoom=Vector2.ONE*2.25
	await frames(18,"before")
	strike(12)
	await frames(24,"hit")
	w.player.animate("idle",0);foe.animate("idle",0)
	await frames(60)
	await capture("spatter")
	strike(38)
	await frames(22,"heavy")
	w.player.animate("idle",0);foe.animate("idle",0)
	await frames(65)
	strike(120)
	await frames(26,"lethal")
	w.player.animate("idle",0)
	await frames(110)
	await capture("pool")
	# Move the real player across the decal to show that it stays below the feet.
	for i in 90:
		w.player.position=Vector2(735,443).lerp(Vector2(835,443),float(i)/89)
		w.player.animate("walk",1.0/60.0)
		await process_frame
		if i%3==0:await capture()
	w.player.animate("idle",0)
	w.set_visual_quality(0)
	await frames(20,"reduced")
	w.set_visual_quality(2)
	await frames(15)
	w.queue_free();await process_frame
	print("BLOOD GALLERY: %d actual frames"%index)
	quit()
