extends SceneTree
## v0.50.1 · CodexAI. Native game views and animated source-pose lattice.
const OUT := "/tmp/shadepi-v0501-gallery"
var w
var index:=0
func _initialize():run.call_deferred()
func shot(tag:String="",movie:bool=false):
	await RenderingServer.frame_post_draw
	var picture=root.get_texture().get_image()
	if not tag.is_empty():picture.save_png(OUT+"/"+tag+".png")
	if movie:picture.save_png(OUT+"/frame-%04d.png"%index);index+=1
func run():
	DirAccess.make_dir_recursive_absolute(OUT)
	set_meta("shadepi_admin_testing",true)
	w=load("res://scenes/chapter_two.tscn").instantiate();root.add_child(w)
	w.cutscene.abort();w._enter(w.Section.DIVE,2);w.started=true;w.close_menu();w.ui.clear_dialogue();w.ui.clear_toast()
	w.set_process(false);w.raven.set_physics_process(false);w.ice_guardian().set_process(false)
	w.raven.position=Vector2(1095,530);w.raven.facing=Vector2.RIGHT;w.raven.animate("idle",0);w._sync_net_avatar(0)
	w.camera.position=w.ice_camera_home()
	for i in 5:await process_frame
	await shot("game")
	for node in w.ui.game_hud_nodes:node.hide()
	w.ui.set_process(false);w.camera.zoom=Vector2.ONE*2.4;w.camera.position=w.raven.position+Vector2(25,-32)
	for i in 3:await process_frame
	await shot("detail")
	for i in 64:
		w.raven.facing=Vector2.from_angle((i/8)*PI/4)
		w.raven.attack_time=.22 if i>=40 else 0
		w.raven.animate("attack" if i>=40 else "walk",.10)
		w._sync_net_avatar(.10)
		await process_frame
		if i==44:await shot("hand")
		await shot("",true)
	w._enter(w.Section.HIDEOUT);w.cutscene.abort();w.raven.position=Vector2(595,430);w.raven.facing=Vector2.LEFT;w.raven.animate("idle",0)
	w.camera.position=w.raven.position+Vector2(0,-32);w.camera.zoom=Vector2.ONE*2.4
	for i in 3:await process_frame
	await shot("physical")
	w.free();await process_frame;print("NET GALLERY: %d frames"%index);quit()
