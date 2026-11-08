extends Node2D
## v0.31.0 · CodexAI: bounded, deterministic pixel FX tied to real locations.
const Profiles = preload("res://scripts/atmosphere_profiles.gd")
const Painted = preload("res://scripts/painted_world.gd")
const FX = preload("res://assets/memories/attack/props-fx.png")
const LIGHT = preload("res://assets/world/light.png")
var world: Node2D
var profile_override := ""
var profile_key := ""
var settings: Dictionary = {}
var elapsed := 0.0
var quality := 2
var water: Node2D
var water_material: ShaderMaterial
var fx_regions: Array[AtlasTexture] = []

func _ready() -> void:
	z_index = 35
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var unlit := CanvasItemMaterial.new()
	unlit.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = unlit
	for i in 4:
		var texture := AtlasTexture.new()
		texture.atlas = FX
		texture.region = Rect2(Vector2(i,2)*FX.get_size()/4, FX.get_size()/4)
		fx_regions.append(texture)
	sync_profile()

func sync_profile() -> void:
	if world == null: return
	var key: String = profile_override if not profile_override.is_empty() else world.atmosphere_profile()
	var rect: Rect2 = Rect2(0,0,1024,640) if not profile_override.is_empty() else world.atmosphere_rect()
	position = rect.position
	scale = rect.size / Vector2(1024,640)
	if key == profile_key: return
	profile_key = key
	settings = Profiles.get_profile(key)
	elapsed = 0.0
	if is_instance_valid(water):
		water.hide()
		water.queue_free()
	water = null
	water_material = null
	if settings.get("water",false): _make_water()
	_apply_grade()
	queue_redraw()

func set_quality(value: int) -> void:
	quality = clampi(value,0,2)
	if is_instance_valid(water): water.visible = quality > 0
	if water_material != null: water_material.set_shader_parameter("strength",0.65 if quality==2 else 0.35)
	_apply_grade()
	queue_redraw()

func _apply_grade() -> void:
	var filter = world.get("filter_material") if world != null else null
	if filter == null or not profile_override.is_empty(): return
	filter.set_shader_parameter("grade_tint",Vector3(1.025,1.0,0.985) if settings.get("warm",false) else Vector3(0.98,1.01,1.045))
	filter.set_shader_parameter("bloom",(0.28 if quality==2 else 0.15)*float(settings.get("bloom",1.0)))

func paused() -> bool:
	return world == null or world.menu_open or world.terminal != null or world.get("memory_scene") != null or world.get("closed") == true

func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	sync_profile()
	if paused() or quality == 0 or settings.is_empty(): return
	elapsed += delta
	if water_material != null: water_material.set_shader_parameter("clock",elapsed)
	queue_redraw()

func _make_water() -> void:
	water = Node2D.new()
	# Main installs this node before actors: the water stays behind their silhouettes.
	water.z_as_relative = false
	water.z_index = 0
	add_child(water)
	water_material = ShaderMaterial.new()
	water_material.shader = preload("res://shaders/lake_surface.gdshader")
	water_material.set_shader_parameter("strength",0.65 if quality==2 else 0.35)
	var clip := PackedVector2Array([Vector2(0,212),Vector2(1024,212),Vector2(1024,490),Vector2(0,490)])
	for outline in Geometry2D.intersect_polygons(PackedVector2Array(Painted.WATER_EDGE),clip):
		var surface := Polygon2D.new()
		surface.polygon = outline
		surface.texture = Painted.ART.lakeside
		surface.material = water_material
		var uv := PackedVector2Array()
		for point in outline: uv.append(point/Vector2(1024,640)*surface.texture.get_size())
		surface.uv = uv
		water.add_child(surface)
	water.visible = quality > 0

func amount(full: int) -> int:
	return full if quality==2 else ceili(full*0.45) if quality==1 else 0

func _draw() -> void:
	if quality==0 or settings.is_empty(): return
	var fade := 1.0 if quality==2 else 0.7
	for light in settings.get("glows",[]):
		var size: Vector2 = light[1]
		var power: float = float(light[3])*(0.92+0.08*sin(elapsed*1.1+light[0].x))*fade
		draw_texture_rect(LIGHT,Rect2(light[0]-size*0.5,size),false,Color(light[2],power))
	var fields: Array = settings.get("dust",[])
	for i in amount(int(settings.get("motes",0))):
		var field: Rect2 = fields[i%fields.size()]
		var life := fposmod(i*0.137+elapsed*(0.04 if settings.get("ash",false) else 0.025),1)
		var point := field.position+Vector2(8+fposmod(i*83.0,field.size.x-16)+sin(elapsed*0.31+i)*7,field.size.y*(1-life))
		var tint := Color("c5aba1") if settings.get("ash",false) else Color("c6c7bb")
		draw_rect(Rect2(point.round(),Vector2(1 if i%3 else 2,1)),Color(tint,sin(life*PI)*0.26*fade))
	for source in settings.get("steam",[]):
		for i in amount(3):
			var life := fposmod(elapsed*0.14+i*0.34,1)
			var size: Vector2 = source[1]*(0.65+life*0.35)
			var p: Vector2 = source[0]+Vector2(sin(life*4+i)*8,-life*40)-Vector2(size.x*0.5,size.y*0.8)
			draw_texture_rect(fx_regions[(int(elapsed*5)+i)%4],Rect2(p.round(),size),false,Color(source[2],sin(life*PI)*0.15*fade))
	for cloud in settings.get("mist",[]):
		var size: Vector2 = cloud[1]
		var p: Vector2 = cloud[0]+Vector2(sin(elapsed*0.12+cloud[0].x)*17,cos(elapsed*0.1)*3)
		draw_texture_rect(fx_regions[int(elapsed*2)%4],Rect2((p-size*0.5).round(),size),false,Color(cloud[2],float(cloud[3])*fade))
	for pane: Rect2 in settings.get("windows",[]):
		for i in amount(15):
			var life := fposmod(elapsed*0.24+i*0.127,1)
			var p := pane.position+Vector2(1+fposmod(i*17.0+life*2,pane.size.x-3),1+life*(pane.size.y-7))
			draw_line(p.round(),(p+Vector2(-1,5)).round(),Color(0.5,0.77,0.83,0.27*sin(life*PI)*fade))
	for panel: Rect2 in settings.get("panels",[]):
		var y := panel.position.y+fposmod(elapsed*4,panel.size.y)
		draw_rect(Rect2(Vector2(panel.position.x,y).round(),Vector2(panel.size.x,1)),Color(0.5,0.87,0.91,0.12*fade))
	for reflection in settings.get("reflections",[]):
		for i in amount(8):
			var width: float = float(reflection[1])*(1-i*0.075)
			var point: Vector2 = reflection[0]+Vector2(sin(elapsed*1.1+i)*3,i*3)
			draw_line((point-Vector2(width*0.5,0)).round(),(point+Vector2(width*0.5,0)).round(),Color(reflection[2],(0.07-i*0.006)*fade))
	var paths: Array = settings.get("paths",[])
	for i in amount(int(settings.get("packets",0))):
		var path: Array = paths[i%paths.size()]
		var life := fposmod(elapsed*0.13+i*0.171,1)
		var p: Vector2 = path[0].lerp(path[1],life)
		draw_rect(Rect2(p.round(),Vector2(3,1)),Color(0.6,0.84,1,sin(life*PI)*0.4*fade))
	for source: Vector2 in settings.get("embers",[]):
		for i in amount(7):
			var life := fposmod(elapsed*0.24+i*0.171,1)
			var p := source+Vector2(sin(life*3+i)*14+life*12,-life*(44+i*5))
			draw_rect(Rect2(p.round(),Vector2(1,2)),Color(1,0.63,0.28,sin(life*PI)*0.48*fade))
	for i in amount(int(settings.get("fireflies",0))):
		var p := Vector2(200+i*79%790,234+i*31%215)+Vector2(sin(elapsed*0.31+i)*7,cos(elapsed*0.27+i)*4)
		var glow := maxf(0.0,sin(elapsed*0.9+i*1.7))*0.6*fade
		draw_texture_rect(LIGHT,Rect2(p-Vector2(4,4),Vector2(8,8)),false,Color(0.74,0.86,0.47,glow*0.2))
		draw_rect(Rect2(p.round(),Vector2.ONE),Color(0.83,0.95,0.63,glow))
