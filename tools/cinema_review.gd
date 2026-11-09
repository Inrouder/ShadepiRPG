extends "res://tools/cutscene_gallery.gd"
## v0.37.0 · CodexAI. Sample all seven chapters using actual current scene methods.
## Combat is traversed by the existing gallery's QA shortcuts, not manually played.
func _initialize() -> void:
	out = "/tmp/shadepi-cinema-v037/"
	DirAccess.make_dir_recursive_absolute(out)
	run.call_deferred()

func play(scene, tag: String, every: int = 90) -> void:
	Engine.time_scale = 3
	await super.play(scene,tag,every*3)
