extends SceneTree
## v0.68.0 · CodexAI. Native frames of the real splash/notice/menu, isolated saves only.
const OUT:="/tmp/shadepi-v068-film"
var b
var number:=0
func _initialize():Engine.max_fps=60;run.call_deferred()
func frame():
	await process_frame;await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"/%03d.png"%number);number+=1
func run():
	if DisplayServer.get_name()=="headless" or not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):quit(1);return
	root.get_node("DisplaySettings").mode=0;root.mode=Window.MODE_WINDOWED
	DirAccess.make_dir_recursive_absolute(OUT)
	for name in DirAccess.get_files_at(OUT):
		if name.ends_with(".png"):DirAccess.remove_absolute(OUT+"/"+name)
	b=load("res://scenes/startup.tscn").instantiate();root.add_child(b);current_scene=b;b.set_process(false)
	for i in 4:await process_frame
	root.size=Vector2i(1280,720);b.active=true
	for i in 150:
		b._process(1.0/30)
		if i%3==0:await frame()
	b.request_menu()
	while is_instance_valid(b) and not b.changing_scene:
		b._process(1.0/30);await frame()
	for i in 12:await frame()
	current_scene.free();current_scene=null
	for i in 3:await process_frame
	print("STARTUP FILM v0.68.0 CodexAI: ",number," native frames");quit()
