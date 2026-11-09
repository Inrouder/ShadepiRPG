extends SceneTree
## v0.41.0 · CodexAI. Existing source pixels at the actual pursuit scale.
const Car = preload("res://scripts/pursuit_car_art.gd")
const Drone = preload("res://scripts/cargo_drone_art.gd")
const Old = preload("res://assets/world/hq/vehicles.png")
func _initialize(): run.call_deferred()
func run():
	var n := Node2D.new()
	root.add_child(n)
	n.draw.connect(func():
		n.draw_rect(Rect2(0,0,640,360),Color("182730"))
		n.draw_texture_rect_region(Old,Rect2(Vector2(38,120)-Vector2(49,36),Vector2(98,72)),Rect2(627,0,627,627))
		for i in 9: Car.draw(n,Vector2(100+i*62,120),i)
		n.draw_texture_rect_region(Old,Rect2(32,246,64,64),Rect2(627,627,627,627))
		for i in 4: Drone.draw(n,Vector2(192+i*128,278),Vector2(64,64),i/18.0)
	)
	for item in [[Vector2(12,8),"VERFOLGER · v0.41.0 · CodexAI"],[Vector2(12,30),"Spielgröße: bisher | 0 gerade · 1/2 lenken · 3/4 federn · 5 ansetzen · 6/7 Schuss · 8 Rammstoß"],[Vector2(12,205),"FRACHTDROHNE: bisher | vier Rotorphasen, feste Ringe/Last · Ansicht ×1,28"],[Vector2(12,338),"Techniktafel aus aktiven Quellpixeln · keine zusätzliche Spielszene"]]:
		var label := Label.new()
		label.position = item[0]
		label.text = item[1]
		label.add_theme_font_size_override("font_size",11)
		n.add_child(label)
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-pursuit-poses-v041.png")
	quit()
