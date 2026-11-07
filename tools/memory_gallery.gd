extends SceneTree
var memory: Node2D
func _initialize() -> void: run.call_deferred()
func capture(tag: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png('/tmp/shadepi-memory-'+tag+'.png')
func run() -> void:
	memory = load('res://scenes/memories/attack.tscn').instantiate()
	memory.autoplay = false
	root.add_child(memory)
	memory.camera.zoom = Vector2(0.5625,0.5625)
	memory.camera.position = Vector2(512,320)
	memory.ui.hide()
	await capture('map')
	for actor in memory.squad+memory.residents: actor.hide()
	for i in memory.squad.size():
		var actor = memory.squad[i]
		actor.show()
		actor.position = Vector2(210+i*145,390)
		actor.facing = Vector2.RIGHT
		actor.animate('idle',0)
	await capture('warriors')
	for actor in memory.squad: actor.hide()
	for i in 4:
		var actor = memory.residents[i]
		actor.show()
		actor.position = Vector2(240+i*170,400)
		actor.facing = Vector2.LEFT
		actor.animate('walk',0.15)
	await capture('residents')
	memory.queue_free()
	await process_frame
	quit()
