extends SceneTree
## v0.40.0 · CodexAI. Renderer reference card using existing source pixels only.
const Bike = preload("res://scripts/motorcycle_art.gd")
const Air = preload("res://scripts/aerodyne_art.gd")
const Old = preload("res://assets/world/hq/vehicles.png")
func _initialize(): run.call_deferred()
func run():
	var n := Node2D.new()
	root.add_child(n)
	n.draw.connect(func():
		n.draw_rect(Rect2(0,0,640,360),Color("182730"))
		for i in 4:
			n.draw_set_transform(Vector2(80+i*160,115),0,Vector2.ONE*1.6)
			if i==0: n.draw_texture_rect_region(Old,Rect2(-42,-42,84,84),Rect2(0,627,627,627))
			else: Bike.draw(n,Vector2.ZERO,[0.0,0.0,-1.0,1.0][i],false,0.25)
			n.draw_set_transform(Vector2(80+i*160,280),0,Vector2.ONE*1.15)
			Air.draw(n,Rect2(-56,-41,112,82),0,1,Color.WHITE,[0.0,0.0,-1.0,1.0][i],1.0 if i==1 else 0.0)
			n.draw_set_transform(Vector2.ZERO)
	)
	for item in [[Vector2(16,4),"FAHRZEUGPOSEN · v0.40.0 · CodexAI"],[Vector2(22,29),"Bisher gerade"],[Vector2(190,29),"Neu gerade"],[Vector2(356,29),"Links"],[Vector2(520,29),"Rechts"],[Vector2(16,202),"Aerodyne: gerade / Luftbremse / links / rechts"],[Vector2(16,340),"Techniktafel · Motorrad ×1,6 · Fluggerät ×1,15 der Spielgröße"]]:
		var label := Label.new()
		label.position = item[0]
		label.text = item[1]
		label.add_theme_font_size_override("font_size",12)
		n.add_child(label)
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-vehicle-poses-v040.png")
	quit()
