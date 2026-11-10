extends SceneTree
## v0.50.2 · CodexAI. Analysis only: real physical-window comparisons, no settings saved.
const OUT := "/tmp/shadepi-display-quality"
var checks:=0
var failures:=0
var records:Array=[]
func _initialize():run.call_deferred()
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;push_error("FAIL: "+label)
func freeze(node:Node):
	node.set_process(false);node.set_physics_process(false)
	for child in node.get_children():freeze(child)
func settle():
	for i in 5:await process_frame
	await RenderingServer.frame_post_draw
func capture(name:String) -> Image:
	await settle()
	var path=OUT+"/"+name+".png"
	var image=DisplayServer.screen_get_image_rect(Rect2i(root.position,root.size))
	if image==null:
		var output:Array=[]
		var window_id=str(DisplayServer.window_get_native_handle(DisplayServer.WINDOW_HANDLE))
		check(OS.execute("import",PackedStringArray(["-window",window_id,path]),output)==0,"physical window capture")
		image=Image.load_from_file(path)
	else:image.save_png(path)
	check(image!=null and image.get_size()==root.size,"physical capture retains actual output pixels")
	return image
func run():
	if DisplayServer.get_name()=="headless":push_error("Run on native desktop");quit(1);return
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):push_error("Isolated test data directory required");quit(1);return
	DirAccess.make_dir_recursive_absolute(OUT);set_meta("shadepi_admin_testing",true)
	var settings=root.get_node("DisplaySettings");settings.hq_enabled=false;settings.set_menu_context(false) # Historical direct-path comparison, no preference write.
	root.position=Vector2i.ZERO;root.mode=Window.MODE_WINDOWED;root.borderless=true
	var w=load("res://scenes/chapter_two.tscn").instantiate();root.add_child(w)
	for scene in ["hideout","ice","lake"]:
		if scene=="hideout":
			w._enter(w.Section.HIDEOUT);w.cutscene.abort();w.raven.position=Vector2(560,425);w.player.position=Vector2(505,425);w.raven.facing=Vector2.LEFT;w.player.facing=Vector2.RIGHT;w.raven.animate("idle",0);w.player.animate("idle",0);w.camera.position=Vector2(540,362)
		elif scene=="ice":
			w._enter(w.Section.DIVE,2);w.raven.position=Vector2(1095,530);w.raven.facing=Vector2.RIGHT;w.raven.animate("idle",0);w._sync_net_avatar(0);w.camera.position=w.ice_camera_home()
		else:
			w.free();w=load("res://scenes/campaign.tscn").instantiate();root.add_child(w);w.fresh_entry=false;w._enter(w.Beat.END);w.cutscene.abort();w.player.position=Vector2(655,400);w.raven.position=Vector2(675,400)
			var d=w.lake_sequence;d.tableau.position=w.player.position;d.tableau.show();d._hide_actors();d.tableau.set_pose(2);d.glow=.8;d.dragon_passage=.45;d._sync();w.camera.position=Vector2(630,340);w.camera.zoom=Vector2.ONE
		w.started=true;w.close_menu();w.ui.clear_dialogue();w.ui.clear_toast();freeze(w);Engine.time_scale=0
		for output_size in [Vector2i(1280,720),Vector2i(1920,1080)]:
			if scene!="hideout" and output_size.x==1280:continue
			root.size=output_size
			for method in [Window.CONTENT_SCALE_MODE_VIEWPORT,Window.CONTENT_SCALE_MODE_CANVAS_ITEMS]:
				root.content_scale_size=Vector2i(640,360);root.content_scale_factor=1;root.content_scale_mode=method;root.content_scale_stretch=Window.CONTENT_SCALE_STRETCH_FRACTIONAL
				await settle()
				var tag=scene+"-"+str(output_size.y)+("-pixel" if method==Window.CONTENT_SCALE_MODE_VIEWPORT else "-native")
				var logical=w.raven.get_global_transform_with_canvas().origin
				var physical=root.get_final_transform()*logical
				var image=await capture(tag)
				var center=Vector2i(physical)+Vector2i(0,-60)
				var region=Rect2i((center-Vector2i(320,180)).clamp(Vector2i.ZERO,output_size-Vector2i(640,360)),Vector2i(640,360))
				image.get_region(region).save_png(OUT+"/"+tag+"-detail.png")
				var advertised_size=root.get_texture().get_size()
				var target_size=Vector2(root.get_texture().get_image().get_size())
				check(target_size==(Vector2(640,360) if method==Window.CONTENT_SCALE_MODE_VIEWPORT else Vector2(output_size)),"measured internal render target")
				check(root.content_scale_size==Vector2i(640,360),"logical world and UI composition unchanged")
				records.append({"scene":scene,"output":[output_size.x,output_size.y],"mode":"viewport" if method==Window.CONTENT_SCALE_MODE_VIEWPORT else "canvas_items","render_target":[target_size.x,target_size.y],"advertised_texture_size":[advertised_size.x,advertised_size.y],"actor_screen":[physical.x,physical.y],"camera_zoom":w.camera.zoom.x,"capture":tag+".png","crop":[region.position.x,region.position.y,640,360]})
	for i in range(0,records.size(),2):
		check(records[i].actor_screen==records[i+1].actor_screen,"same actor size/framing in physical output")
		check(records[i].camera_zoom==records[i+1].camera_zoom,"no zoom change disguised as detail improvement")
	w.free();await process_frame
	var file=FileAccess.open(OUT+"/measurements.json",FileAccess.WRITE);file.store_string(JSON.stringify({"checks":checks,"failures":failures,"records":records},"\t"));file.close()
	print("DISPLAY QUALITY PROBE: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
