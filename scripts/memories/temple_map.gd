extends "res://scripts/memories/monastery_map.gd"
## Interior of the temple cover above the Order's underground base.
## The shaft is behind the rear wall; the combat floor has its own geometry.
const INTERIOR=preload("res://assets/memories/legacy/temple-interior.png")
const DOOR=preload("res://assets/memories/legacy/temple-door.png")
const ENTRY=Vector2(945,335)
const DOOR_FOOT=Vector2(940,340)
const ROOM_WALLS=[Rect2(-16,0,32,640),Rect2(1008,0,32,640),Rect2(0,0,1024,292),Rect2(0,555,1024,85),Rect2(0,365,72,42),Rect2(978,376,46,32),Rect2(945,465,79,90)]
const ROOM_FIRES=[Vector2(72,390),Vector2(993,362)]
var gate_body: StaticBody2D
var door_sprite: Sprite2D
var door_halves: Array[Sprite2D]=[]
var door_frame:=0
var breached:=false

func _ready() -> void:
	background_texture=INTERIOR
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	actors=Node2D.new()
	actors.y_sort_enabled=true
	add_child(actors)
	for rect in ROOM_WALLS: _solid(rect)
	_solid(Rect2(880,292,128,68))
	gate_body=scenery.back()
	door_sprite=Sprite2D.new()
	door_sprite.position=DOOR_FOOT
	door_sprite.scale=Vector2.ONE*0.35
	door_sprite.offset=Vector2(384,256)-Vector2(384,490)
	door_sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	actors.add_child(door_sprite)
	for side in 2:
		var piece:=Sprite2D.new()
		piece.scale=Vector2.ONE*0.35
		piece.offset=Vector2(0,-234)
		piece.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		actors.add_child(piece)
		door_halves.append(piece)
	set_door_frame(0)
	for point in ROOM_FIRES:
		var sprite:=Sprite2D.new()
		sprite.position=point
		sprite.scale=Vector2.ONE*0.16
		sprite.offset.y=-float(FX.get_height())/8
		sprite.texture=region(0,1)
		actors.add_child(sprite)
		fx_sprites.append(sprite)
	# These occluders use the interior's own wall/column pixels, never courtyard props.
	_occluder(PackedVector2Array([Vector2(0,555),Vector2(1024,555),Vector2(1024,640),Vector2(0,640)]))
	_occluder(PackedVector2Array([Vector2(979,0),Vector2(1024,0),Vector2(1024,410),Vector2(979,410)]))
	_occluder(PackedVector2Array([Vector2(0,0),Vector2(65,0),Vector2(65,410),Vector2(0,410)]))
	_occluder(PackedVector2Array([Vector2(945,465),Vector2(1024,465),Vector2(1024,555),Vector2(945,555)]))

func _occluder(points: PackedVector2Array) -> void:
	var polygon:=Polygon2D.new()
	polygon.z_index=80
	polygon.texture=INTERIOR
	polygon.polygon=points
	var uvs:=PackedVector2Array()
	for point in points: uvs.append(point/SIZE*INTERIOR.get_size())
	polygon.uv=uvs
	add_child(polygon)

func set_door_frame(index: int) -> void:
	door_frame=clampi(index,0,3)
	var texture:=AtlasTexture.new()
	texture.atlas=DOOR
	texture.region=Rect2((door_frame%2)*768,(door_frame/2)*512,768,512)
	door_sprite.texture=texture
	door_sprite.visible=door_frame<2
	for side in 2:
		var piece: Sprite2D=door_halves[side]
		piece.visible=door_frame>=2
		var half:=AtlasTexture.new()
		half.atlas=DOOR
		half.region=Rect2((door_frame%2)*768+side*384,(door_frame/2)*512,384,512)
		piece.texture=half
		var spread:=23 if door_frame==3 else 10
		piece.position=DOOR_FOOT+Vector2((-1 if side==0 else 1)*(192*0.35+spread),0)
	if door_frame==3:
		breached=true
		gate_body.collision_layer=0

func breach_step(k: float) -> void:
	var next:=mini(3,int(k*4))
	if next!=door_frame:
		set_door_frame(next)
		if next in [1,2]: impact(ENTRY+Vector2(-10,-12))

func _draw() -> void:
	draw_texture_rect(INTERIOR,Rect2(Vector2.ZERO,SIZE),false)
	for blast in impacts:
		var frame:=region(mini(3,int(blast.age*6)),3)
		draw_texture_rect(frame,Rect2(blast.p-Vector2(46,68),Vector2(92,92)),false,Color(1,1,1,1-blast.age*0.6))
	for i in (1 if quality==0 else ROOM_FIRES.size()):
		var frame:=region(int(elapsed*3+i)%4 if quality>0 else 0,2)
		var point: Vector2=ROOM_FIRES[i]+Vector2(sin(elapsed*0.4+i)*4,-24)
		draw_texture_rect(frame,Rect2(point-Vector2(30,60),Vector2(60,80)),false,Color(1,1,1,0.3))
