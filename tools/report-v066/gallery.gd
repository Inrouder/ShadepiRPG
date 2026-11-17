extends SceneTree
## v0.66.0 · CodexAI. Native isolated gameplay/cutscene captures, no asset drawing.
var w
var index:=0
const OUT:="/tmp/shadepi-v066-frames"
func _initialize(): Engine.max_fps=30; run.call_deferred()
func frames(n: int=3):
	for i in n: await process_frame
func snap(name: String):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-v066-"+name+".png")
func frame(folder: String):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"/"+folder+"/%03d.png"%index); index+=1
func prepare(folder: String):
	index=0;var path:=OUT+"/"+folder
	DirAccess.make_dir_recursive_absolute(path)
	for file in DirAccess.get_files_at(path):
		if file.ends_with(".png"): DirAccess.remove_absolute(path+"/"+file)
func load_world(path: String):
	if is_instance_valid(w): w.free();current_scene=null;await frames()
	w=load(path).instantiate();root.add_child(w);current_scene=w
	await frames(12);w.cutscene.abort();w.close_menu();w.ui.clear_dialogue();w.started=true
	root.size=Vector2i(1280,720)
func run():
	if DisplayServer.get_name()=="headless" or not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1);return
	set_meta("shadepi_admin_testing",true)
	root.get_node("DisplaySettings").mode=0;root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1280,720)
	if "--garage" in OS.get_cmdline_user_args(): await garage()
	elif "--digital" in OS.get_cmdline_user_args(): await digital()
	elif "--bridge" in OS.get_cmdline_user_args(): await bridge()
	elif "--tower" in OS.get_cmdline_user_args(): await tower()
	else: await jackal()
	if is_instance_valid(w): w.free();current_scene=null
	Engine.time_scale=1;await frames();quit()
func jackal():
	await load_world("res://scenes/chapter_one.tscn")
	w._enter_checkpoint(w.Phase.TEAM);w.cutscene.abort();w.close_menu()
	for actor in [w.player,w.raven,w.enemy]: actor.set_physics_process(false)
	w.player.position=w.DOWNED_SPOT+Vector2(-50,30)
	w.phase=w.Phase.REVIVE;w._scene_revive()
	for i in 150:
		await process_frame
		if w.cutscene.waiting_input:break
	await snap("jackal")
	w.cutscene.abort();w.raven_joined=true;w.reset_raven(w.DOWNED_SPOT);w.raven.reset_visual_pose()
	w.enemy.health=0;w.enemy.active=false;w.enemy.show_reaction(1,"death")
	w._begin_epilogue();Engine.time_scale=3;prepare("alley")
	var waited:=0;var exiting:=false;var saved:=false
	for i in 1500:
		await process_frame
		if w.cutscene.waiting_input:
			waited+=1
			if waited>5:w.cutscene.advance();waited=0
		if w.cutscene.speaker_label.text.contains("LEISE") and not w.cutscene.waiting_input: exiting=true
		if exiting and i%2==0:await frame("alley")
		if exiting and w.player.position.y<295 and w.player.visible and not saved:await snap("alley");saved=true
		if w.phase==w.Phase.COMPLETE and not w.in_cinematic():break
	print("GALLERY JACKAL: shadow exit=",not w.player.visible," saved=",saved)
func garage():
	await load_world("res://scenes/campaign.tscn")
	w.fresh_entry=false;w._enter(w.Beat.GARAGE);w.cutscene.abort();w.close_menu()
	w._scene_garage();Engine.time_scale=2;prepare("garage")
	var waited:=0;var outside:=false;var entered:=false
	for i in 1000:
		await process_frame
		if w.cutscene.waiting_input:
			waited+=1
			if waited>12:w.cutscene.advance();waited=0
		if i%3==0:await frame("garage")
		if w.bike_mode=="approach" and w.bike_pos.x>280 and not outside:await snap("garage-outside");outside=true
		if w.bike_mode=="ride" and w.bike_pos.y>300 and not entered:
			print("GARAGE CAMERA: bike=",w.bike_pos," screen=",w.get_global_transform_with_canvas()*w.bike_pos," camera=",w.camera.position," centre=",w.camera.get_screen_center_position()," zoom=",w.camera.zoom)
			await snap("garage-in");entered=true
		if i>30 and not w.in_cinematic():break
	print("GALLERY GARAGE: outside=",outside," inside=",entered," parked=",w.bike_mode)
func digital():
	await load_world("res://scenes/chapter_two.tscn")
	w._enter(w.Section.DIVE,1);w.cutscene.abort();w.close_menu();w.set_coop(true)
	w._open_net_layer("dive_core",func():pass)
	for t in w.threats.duplicate():w._destroy_threat(t)
	w.raven.position=w.net_layer.point(Vector2(520,230));w.raven.health_floor=100
	w.companion.presence=0;w.companion.kind="";w.companion._process(0.1)
	await frames(20);await snap("red-world")
	w._enter(w.Section.DIVE,2);w.cutscene.abort();w.close_menu();w.raven.health_floor=100;w.ui.clear_toast()
	prepare("boss");Engine.time_scale=1
	for i in 160:
		await process_frame
		if i%3==0:await frame("boss")
		if i==48:await snap("boss")
	print("GALLERY DIGITAL: boss moved=",w.ice_guardian().position)
func bridge():
	await load_world("res://scenes/chapter_two.tscn")
	w._enter(w.Section.END);w.cutscene.abort();w.close_menu();w.ui.clear_dialogue()
	w.continue_to_pact();Engine.time_scale=2;prepare("bridge")
	var waited:=0;var saved:=false;var before:=false
	for i in 900:
		await process_frame
		if not is_instance_valid(w):break
		if w.cutscene.waiting_input:
			waited+=1
			if waited>10:w.cutscene.advance();waited=0
		if i%3==0:await frame("bridge")
		if not is_instance_valid(w):break
		if w.player.position.x<560 and w.player.position.x>460 and not saved:await snap("chapter-walk");saved=true
		if w.player.position.distance_to(Vector2(437,427))<1 and not before:await snap("chapter-before");before=true
	await frames(4)
	if current_scene!=null and current_scene!=w:
		w=current_scene
		for i in 200:
			await process_frame
			if i%3==0:await frame("bridge")
			if w.cutscene.waiting_input:await snap("chapter-after");break
	print("GALLERY BRIDGE: walked=",saved," ready=",before)

func tower():
	await load_world("res://scenes/campaign.tscn")
	w.fresh_entry=false;w.set_coop(true);w._enter(w.Beat.BOSS);w.cutscene.abort();w.close_menu();w.ui.clear_toast()
	w.player.position=Vector2(725,395);w.raven.position=Vector2(690,420)
	for foe in w.foes:foe.set_physics_process(false)
	await frames(18);await snap("tower-coop")
	print("GALLERY TOWER: Raven=",w.coop_raven_playable()," pet=",w.companion.visible)
	w.escape_guards_cleared=true;w._enter(w.Beat.ESCAPE,0,3);w.cutscene.abort();w.close_menu()
	w._start_passages(w.WAY_OUT,func():pass);w.cutscene.skip();await frames(18)
	for foe in w.foes:foe.set_physics_process(false)
	w.ui.clear_toast();await frames(3);await snap("tower-corridor")
	print("GALLERY CORRIDOR: Raven=",w.coop_raven_playable()," pet=",w.companion.visible)
