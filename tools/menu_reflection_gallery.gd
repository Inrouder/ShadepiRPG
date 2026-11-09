extends SceneTree
## v0.44.1 · CodexAI. Fixed-clock native comparison of the wet-floor light correction.
const OUT := "/tmp/shadepi-reflection-v0441"
func _initialize():run.call_deferred()
func shot(tag: String) -> Image:
	await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	image.save_png(OUT+"/"+tag+".png")
	return image
func run():
	if DisplayServer.get_name()=="headless":
		push_error("Reflection comparison requires a real renderer")
		quit(1)
		return
	set_meta("shadepi_admin_testing",true)
	DirAccess.make_dir_recursive_absolute(OUT)
	Engine.max_fps=60
	var w=load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(w)
	w.save_game()
	w.ui.show_menu()
	root.size=Vector2i(1920,1080)
	for i in 15:await process_frame
	var b=w.ui.start_backdrop
	b.set_process(false)
	w.ui.menu_chrome.set_process(false)
	b.city_material.set_shader_parameter("contact_reflections",0.0)
	var before: Image = await shot("before")
	b.city_material.set_shader_parameter("contact_reflections",1.0)
	var after: Image = await shot("after")
	var changed:=0
	var outside:=0
	for y in 1080:
		for x in 1000:
			if before.get_pixel(x,y)!=after.get_pixel(x,y):
				changed+=1
				if y<865 or y>980:outside+=1
	print("REFLECTION PIXELS changed=",changed," outside_ground=",outside)
	b.set_quality(0)
	await shot("reduced")
	w.free()
	await process_frame
	quit(1 if changed<500 or outside>0 else 0)
