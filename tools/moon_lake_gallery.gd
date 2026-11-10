extends SceneTree
## v0.49.0 · CodexAI. Native menu sizes, registered poses and the real complete finale.
const OUT="/tmp/shadepi-v049-gallery"
var w
var index:=0
func _initialize():run.call_deferred()
func shot(tag: String="",movie: bool=false):
	await RenderingServer.frame_post_draw
	var picture=root.get_texture().get_image()
	if not tag.is_empty():picture.save_png(OUT+"/"+tag+".png")
	if movie:
		picture.save_png(OUT+"/frame-%04d.png"%index);index+=1
func run():
	DirAccess.make_dir_recursive_absolute(OUT)
	set_meta("shadepi_admin_testing",true)
	Engine.max_fps=60
	w=load("res://scenes/campaign.tscn").instantiate();root.add_child(w)
	w.cutscene.abort();w.ui.clear_dialogue();w.set_process(false);w.started=false;w.menu_open=true
	w.ui.show_menu()
	for size in [Vector2i(640,360),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.size=size
		for i in 8:await process_frame
		await shot("menu-"+str(size.x))
	if "--menus-only" in OS.get_cmdline_user_args():
		w.free();print("MOON MENU SIZES complete");quit();return
	w.started=true;w.close_menu();root.size=Vector2i(1280,720)
	w._enter(w.Beat.END);w.cutscene.abort()
	var d=w.lake_sequence
	w.player.position=Vector2(655,400);w.raven.position=w.player.position+Vector2(20,0)
	d.tableau.position=w.player.position;d.tableau.show();d._hide_actors()
	w.ui.set_lake_cinema(true)
	w.camera.position=Vector2(670,366);w.camera.zoom=Vector2.ONE*2.3
	for frame in 8:
		d.tableau.transitioning=true;d.tableau._frame(frame)
		for i in 4:await process_frame
		await shot("pose-"+str(frame))
	d.tableau.set_pose(2);d.glow=.8;d.dragon_passage=.45;d._sync()
	w.camera.position=Vector2(540,277);w.camera.zoom=Vector2.ONE*.65
	for i in 4:await process_frame
	await shot("lake-wide")
	w.fresh_entry=true;w._enter(w.Beat.END)
	var seen={};var waiting:=0.0
	for i in 5000:
		await process_frame
		if not is_instance_valid(w.lake_sequence):break
		d=w.lake_sequence
		if w.cutscene.waiting_input:
			waiting+=get_process_time()
			if waiting>.9:w.cutscene.advance();waiting=0
		else:waiting=0
		if i%9==0:
			var tag=""
			if d.stage in ["kiss","dragon","embrace"] and not seen.has(d.stage):
				if d.stage!="dragon" or (d.dragon_passage>.35 and d.dragon_passage<.65):
					tag="scene-"+d.stage;seen[d.stage]=true
			await shot(tag,true)
		if not w.cutscene.running:break
	w.free();await process_frame
	print("MOON GALLERY: %d native movie frames"%index);quit()
func get_process_time() -> float:return 1.0/60.0
