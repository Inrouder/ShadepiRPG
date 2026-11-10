extends SceneTree
## v0.50.0 · CodexAI. Deterministic native game capture, never edits source artwork.
const OUT := "/tmp/shadepi-v050-gallery"
var w
var index := 0
func _initialize(): run.call_deferred()
func shot(tag: String="", movie: bool=false):
	await RenderingServer.frame_post_draw
	var picture=root.get_texture().get_image()
	if not tag.is_empty(): picture.save_png(OUT+"/"+tag+".png")
	if movie:
		picture.save_png(OUT+"/frame-%04d.png"%index);index+=1
func run():
	DirAccess.make_dir_recursive_absolute(OUT)
	set_meta("shadepi_admin_testing",true)
	Engine.max_fps=60
	w=load("res://scenes/chapter_two.tscn").instantiate();root.add_child(w)
	w.cutscene.abort();w._enter(w.Section.DIVE,2);w.ui.clear_dialogue();w.started=true;w.close_menu();w.ui.clear_toast()
	root.size=Vector2i(1280,720)
	var boss=w.ice_guardian()
	w.raven.position=Vector2(850,650);w.raven.facing=Vector2.RIGHT
	# Full encounter capture uses real timers, collisions and attacks. Script only
	# steers the same movement/attack/dash inputs a player has.
	var seen={};var shot_timer:=0.0
	for i in 5000:
		await process_frame
		if not is_instance_valid(boss) or boss.is_queued_for_deletion():break
		var target: Vector2
		if boss.vulnerable():
			target=Vector2(860,530) if w.raven.position.y>550 and w.raven.position.x<1000 else boss.position-Vector2(54,0)
		else:
			target=Vector2(860,540) if w.raven.position.x>880 else Vector2(860,650)
		var step:Vector2=target-w.raven.position
		for action in ["move_left","move_right","move_up","move_down"]: Input.action_release(action)
		if step.length()>4:
			if absf(step.x)>3:Input.action_press("move_right" if step.x>0 else "move_left")
			if absf(step.y)>3:Input.action_press("move_down" if step.y>0 else "move_up")
			if step.length()>180 and w.raven.dash_cooldown<=0 and w.raven.attack_time<=0:w.raven.try_dash(step.normalized())
		shot_timer+=1.0/60.0
		if boss.vulnerable() and step.length()<12 and shot_timer>.55:
			w.raven.facing=(boss.position-w.raven.position).normalized();w.raven.try_attack();shot_timer=0
		if i%6==0:
			var tag=""
			if boss.phase==boss.Phase.FIRE and boss.bolts.size()>7 and not seen.has("salvo"):
				tag="salvo";seen.salvo=true
			if boss.vulnerable() and w.raven.position.distance_to(boss.position)<65 and not seen.has("core"):
				tag="core";seen.core=true
			if boss.phase==boss.Phase.DEFEATED:tag="victory"
			await shot(tag,true)
		if w.threats.is_empty():break
	for action in ["move_left","move_right","move_up","move_down"]:Input.action_release(action)
	print("ICE GALLERY: %d frames, threats %d, Raven %d, victory recorded %s, seen %s"%[index,w.threats.size(),w.raven.health,str(FileAccess.file_exists(OUT+"/victory.png")),str(seen)])
	w.free();await process_frame;quit()
