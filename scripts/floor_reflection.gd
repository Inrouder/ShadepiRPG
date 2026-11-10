extends Sprite2D
## v0.52.0 · ClaudeHelper: Bodenspiegelung einer Figur (nasser Asphalt, Marmor, Hallenboden).
## Folgt jedem Bild der sichtbaren Figur – auch Sonder- und Kontaktposen – und liegt
## unter allen Figuren, aber über dem gemalten Boden. Stärke kommt vom Ort
## (world.floor_reflection(position)); 0 blendet die Spiegelung aus.
const SHADER := preload("res://shaders/floor_reflection.gdshader")
var actor: PixelActor
var level := 0.0

func _ready() -> void:
	# Erstes Kind der y-sortierten Figur: liegt unter ihrem eigenen Körper und unter allen
	# weiter vorn stehenden Figuren, aber über der vom Weltknoten gezeichneten Kulisse.
	show_behind_parent = false
	process_priority = 200       # nach Animation und Sonderposen des Bilds
	material = ShaderMaterial.new()
	material.shader = SHADER
	hide()

func _process(delta: float) -> void:
	var source: Sprite2D = actor.visual
	var wanted := 0.0
	if actor.visible and source.visible and absf(source.rotation) < 0.1 and not actor.external_pose and actor.world != null and actor.world.has_method("floor_reflection"):
		wanted = actor.world.floor_reflection(actor.global_position)
	level = move_toward(level, wanted, delta * 1.5)
	visible = level > 0.005
	if not visible:
		return
	texture = source.texture
	hframes = source.hframes
	vframes = source.vframes
	frame = source.frame
	flip_h = source.flip_h
	texture_filter = source.texture_filter
	scale = Vector2(source.scale.x, -source.scale.y * 0.92)
	rotation = -source.rotation
	# Spiegelachse ist die Standlinie der Figur (Ursprung des Akteurs).
	position = Vector2(source.position.x, -source.position.y * 0.92 + 1.0)
	var rect := Vector4(0, 0, 1, 1)
	var cell := Vector2(texture.get_size()) / Vector2(hframes, vframes)
	if texture is AtlasTexture:
		var atlas := texture as AtlasTexture
		var full := Vector2(atlas.atlas.get_size())
		rect = Vector4(atlas.region.position.x / full.x, atlas.region.position.y / full.y, atlas.region.size.x / full.x, atlas.region.size.y / full.y)
		cell = atlas.region.size
	else:
		rect = Vector4(float(frame % hframes) / hframes, float(frame / hframes) / vframes, 1.0 / hframes, 1.0 / vframes)
	# Fußlinie in der Pose: der Akteursursprung liegt |position.y| unter der Posenmitte.
	var foot := clampf(0.5 + absf(source.position.y) / maxf(1.0, cell.y * absf(source.scale.y)), 0.5, 1.0)
	material.set_shader_parameter("frame_rect", rect)
	material.set_shader_parameter("foot", foot)
	material.set_shader_parameter("strength", level * (0.25 if actor.cloaked else 1.0))
