extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	var scene := Node2D.new()
	root.add_child(scene)
	RenderingServer.set_default_clear_color(Color("121e2b"))
	var title := Label.new()
	title.text = "SHADEPI  /  NPC COLLECTION  /  v0.13"
	title.position = Vector2(48, 28)
	title.add_theme_font_size_override("font_size", 28)
	scene.add_child(title)
	var names := ["jackal", "kenzo", "punk-1", "punk-2", "punk-3", "punk-4", "shooter-visor", "shooter-violet"]
	for i in names.size():
		var origin := Vector2(80 + (i % 4) * 300, 245 + (i / 4) * 270)
		for j in 2:
			var actor := PixelActor.new()
			scene.add_child(actor)
			actor.position = origin + Vector2(j * 110, 0)
			actor.setup(load("res://assets/sprites/" + names[i] + ".png"), scene)
			actor.scale = Vector2.ONE * 2.0
			actor.facing = Vector2.DOWN if j == 0 else Vector2.LEFT
			actor.animate("idle" if j == 0 else "attack", 0.18)
		var label := Label.new()
		label.text = names[i].to_upper()
		label.position = origin + Vector2(-20, 15)
		scene.add_child(label)
	for i in 2:
		var art := Sprite2D.new()
		art.texture = load("res://assets/sprites/npcs/" + ("dive-virus" if i == 0 else "ice-guardian") + ".png")
		art.position = Vector2(520 + i * 210, 630)
		art.scale = Vector2.ONE * (110.0 / art.texture.get_width())
		scene.add_child(art)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("user://npc-gallery.png")
	quit()
