extends SceneTree
## v0.42.0 · CodexAI. Actual source phases at normal world size, without new artwork.
const Tech = preload("res://scripts/technology_art.gd")
const Old = preload("res://scripts/prop_art.gd")
func _initialize(): run.call_deferred()
func run():
	var n := Node2D.new()
	root.add_child(n)
	n.draw.connect(func():n.draw_rect(Rect2(0,0,640,360),Color("182730")))
	for row in 2:
		var kind := "electrical" if row==0 else "server"
		for i in 9:
			var sprite := Sprite2D.new()
			if i==0: Old.apply(sprite,5 if row==0 else 7,0)
			else:
				Tech.apply(sprite,kind)
				sprite.frame = i-1
			sprite.position += Vector2(38+i*68,135+row*160)
			n.add_child(sprite)
	for pair in [[Vector2(12,6),"TECHNIK · v0.42.0 · CodexAI · Spielgröße"],[Vector2(12,30),"Schaltkasten: bisher | 0–3 Betrieb | 4/5 Zugriff | 6 Bestätigung | 7 Fehler"],[Vector2(12,190),"Serverschrank: gleiche Phasen, fester Bodenanker und Lüftergehäuse"],[Vector2(12,336),"Techniktafel aus vorhandenen Quellpixeln · beschädigt/zerstört nutzt den Altbestand"]]:
		var label := Label.new()
		label.position = pair[0]
		label.text = pair[1]
		label.add_theme_font_size_override("font_size",11)
		n.add_child(label)
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-technology-poses-v042.png")
	quit()
