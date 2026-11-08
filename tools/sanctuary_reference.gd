extends SceneTree
## v0.32.0 · CodexAI: canonical game sprite reference, rendered by Godot.
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1024, 360)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var paths := ["shadepi", "raven", "shadepi", "raven"]
	for i in 4:
		var atlas := AtlasTexture.new()
		atlas.atlas = load("res://assets/sprites/heroes/" + paths[i] + ".png")
		atlas.region = Rect2(0, 160 if i >= 2 else 0, 128, 160)
		var sprite := Sprite2D.new()
		sprite.texture = atlas
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.scale = Vector2.ONE * 2
		sprite.position = Vector2(128 + 256 * i, 180)
		viewport.add_child(sprite)
	await process_frame
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png("/tmp/shadepi-sanctuary-reference.png")
	quit()
