extends Node2D
## One source map, separate props/occlusion, real floor collisions and atlas FX.
const BACKGROUND = preload("res://assets/memories/attack/courtyard.png")
const FX = preload("res://assets/memories/attack/props-fx.png")
const SIZE := Vector2(1024,640)
const FLOOR := Rect2(24,270,976,270)
const WALLS := [Rect2(-16,0,32,640),Rect2(1008,0,32,640),Rect2(0,0,60,268),Rect2(125,0,899,268),Rect2(0,550,1024,90)]
const PROPS := [[0,Vector2(760,322),0.24],[1,Vector2(620,465),0.34],[2,Vector2(899,480),0.23],[3,Vector2(280,310),0.29]]
const FIRES := [Vector2(827,280),Vector2(970,289),Vector2(899,480),Vector2(490,110)]
var actors: Node2D
var elapsed := 0.0
var paused := false
var impacts: Array[Dictionary] = []
var scenery: Array[StaticBody2D] = []
var fx_sprites: Array[Sprite2D] = []
var impact_serial := 0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	actors = Node2D.new()
	actors.y_sort_enabled = true
	add_child(actors)
	for rect in WALLS: _solid(rect)
	for entry in PROPS:
		var sprite := Sprite2D.new()
		sprite.texture = region(entry[0],0)
		sprite.position = entry[1]
		sprite.scale = Vector2.ONE * entry[2]
		sprite.offset.y = -float(FX.get_height())/8
		actors.add_child(sprite)
		var width: float = [58,42,60,24][entry[0]]
		_solid(Rect2(entry[1]-Vector2(width/2,8),Vector2(width,16)))
	for point in FIRES:
		var sprite := Sprite2D.new()
		sprite.position = point
		sprite.scale = Vector2.ONE*0.25
		sprite.offset.y = -float(FX.get_height())/8
		sprite.texture = region(0,1)
		actors.add_child(sprite)
		fx_sprites.append(sprite)
	# Reuse only the source pixels covering the foreground parapet.
	var front := Polygon2D.new()
	front.z_index = 80
	front.texture = BACKGROUND
	front.polygon = PackedVector2Array([Vector2(0,550),Vector2(1024,550),Vector2(1024,640),Vector2(0,640)])
	var uvs := PackedVector2Array()
	for p in front.polygon: uvs.append(p/SIZE*BACKGROUND.get_size())
	front.uv = uvs
	add_child(front)
	var column := Polygon2D.new()
	column.z_index = 80
	column.texture = BACKGROUND
	column.polygon = PackedVector2Array([Vector2(928,446),Vector2(1016,440),Vector2(1024,550),Vector2(928,550)])
	var column_uv := PackedVector2Array()
	for p in column.polygon: column_uv.append(p/SIZE*BACKGROUND.get_size())
	column.uv = column_uv
	add_child(column)
	_solid(Rect2(930,500,94,50))

func region(column: int,row: int) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = FX
	texture.region = Rect2(Vector2(column,row)*FX.get_size()/4,FX.get_size()/4)
	return texture

func _solid(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var collision := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	collision.shape = box
	body.position = rect.get_center()
	body.add_child(collision)
	add_child(body)
	scenery.append(body)

func impact(point: Vector2) -> void:
	impact_serial += 1
	if impacts.size() < 6: impacts.append({"p":point,"age":0.0})
	queue_redraw()

func _process(delta: float) -> void:
	if paused: return
	elapsed += delta
	for i in fx_sprites.size():
		var texture: AtlasTexture = fx_sprites[i].texture
		texture.region.position.x = (int(elapsed*7+i)%4)*FX.get_width()/4.0
	for i in range(impacts.size()-1,-1,-1):
		impacts[i].age += delta
		if impacts[i].age>0.85: impacts.remove_at(i)
	queue_redraw()

func _draw() -> void:
	draw_texture_rect(BACKGROUND,Rect2(Vector2.ZERO,SIZE),false)
	# Large FX live above the map texture but do not burn figures into it.
	for blast in impacts:
		var column := mini(3,int(blast.age*6))
		var frame := region(column,3)
		draw_texture_rect(frame,Rect2(blast.p-Vector2(46,68),Vector2(92,92)),false,Color(1,1,1,1-blast.age*0.6))
	for i in 4:
		var frame := region(int(elapsed*3+i)%4,2)
		var point: Vector2 = FIRES[i]+Vector2(sin(elapsed*0.4+i)*8,-45)
		draw_texture_rect(frame,Rect2(point-Vector2(40,72),Vector2(80,112)),false,Color(1,1,1,0.5))
