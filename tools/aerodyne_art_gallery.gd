extends SceneTree
## v0.37.0 · CodexAI. Actual renderer comparison; left is historical single frame.
const Rig = preload("res://scripts/cinematic_aerodyne.gd")
const Old = preload("res://assets/world/hq/vehicles.png")
var rig: Node2D
var clock := 0.0
func _initialize(): run.call_deferred()
func run():
	DirAccess.make_dir_recursive_absolute("/tmp/shadepi-airframe-v037/film")
	Engine.max_fps = 60
	var canvas := Node2D.new()
	root.add_child(canvas)
	canvas.draw.connect(func():
		canvas.draw_rect(Rect2(0,0,640,360),Color("101a22"))
		canvas.draw_set_transform(Vector2(145,190),0,Vector2(1,0.6))
		canvas.draw_texture_rect_region(Old,Rect2(-82,-82,164,164),Rect2(0,0,627,627))
		canvas.draw_set_transform(Vector2.ZERO)
	)
	rig = Rig.new()
	canvas.add_child(rig)
	for item in [[Vector2(24,18),"TECHNIKVORSCHAU · v0.37.0 · CodexAI"],[Vector2(52,65),"Bisher: ein Rumpfbild"],[Vector2(350,65),"Neu: 6 mechanische Bilder"]]:
		var label := Label.new()
		label.position = item[0]
		label.text = item[1]
		label.add_theme_font_size_override("font_size",13)
		canvas.add_child(label)
	var film := 0
	var seen := {}
	for i in 390:
		await process_frame
		clock += root.get_process_delta_time()
		var door := clampf(clock/1.0,0,1) if clock<2 else clampf(3-clock,0,1)
		var power := 0.0 if clock<3.2 else 0.7
		rig.set_door(door)
		rig.set_pose(Vector2(465,190),0.68,0,power,clock)
		canvas.queue_redraw()
		if not seen.has(rig.hull.frame):
			seen[rig.hull.frame] = true
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/shadepi-airframe-v037/state-%s.png"%rig.hull.frame)
		if i%3==0:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/shadepi-airframe-v037/film/frame-%04d.png"%film)
			film += 1
	print("AIRFRAME GALLERY: source states=",seen.size()," film frames=",film)
	quit(0 if seen.size()==6 else 1)
