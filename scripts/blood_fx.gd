extends Node2D
## v0.46.0 · CodexAI: physical enemy hits, falling droplets and grounded pixel decals.
const ART = preload("res://assets/fx/blood/atlas.png")
const CELLS = [Rect2(0,0,443,443),Rect2(443,0,444,443),Rect2(887,0,443,443),Rect2(1330,0,444,443)]
const ORIGINS = [Vector2(54,270),Vector2(50,270),Vector2(52,270),Vector2(61,270)]
const MAX_SPRAYS = 16
const MAX_DROPS = 96
const MAX_STAINS = 48
const STAIN_LIFE = 90.0
var world: Node2D
var sprays: Array[Dictionary] = []
var drops: Array[Dictionary] = []
var stains: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
var floor_layer: Node2D
var air_layer: Node2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rng.seed = 460
	floor_layer = Node2D.new()
	floor_layer.name = "BloodOnFloor"
	floor_layer.z_index = -5
	floor_layer.draw.connect(_draw_floor)
	add_child(floor_layer)
	air_layer = Node2D.new()
	air_layer.name = "BloodInAir"
	air_layer.z_index = 48
	air_layer.draw.connect(_draw_air)
	add_child(air_layer)

func reduced() -> bool:
	return world.visual_quality == 0

func _trim_budgets() -> void:
	while sprays.size()>(6 if reduced() else MAX_SPRAYS):sprays.pop_front()
	while drops.size()>(24 if reduced() else MAX_DROPS):drops.pop_front()
	while stains.size()>(16 if reduced() else MAX_STAINS):stains.pop_front()

func hit(target: Node2D, direction: Vector2, amount: int, killed: bool) -> void:
	if amount <= 0: return
	_trim_budgets()
	var push := direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT
	var point := target.global_position
	var heavy := amount >= 30
	if sprays.size() >= (6 if reduced() else MAX_SPRAYS): sprays.pop_front()
	sprays.append({"p":point+Vector2(0,-28),"d":push,"t":0.0,"s":0.12 if heavy or killed else 0.09})
	var count := (4 if reduced() else 12) if heavy or killed else (2 if reduced() else 7)
	for i in mini(count, maxi(0,(24 if reduced() else MAX_DROPS)-drops.size())):
		var spread := push.rotated(rng.randf_range(-0.65,0.65))
		drops.append({"p":point,"v":spread*rng.randf_range(14,48),"h":28.0,"vz":rng.randf_range(10,65),"t":0.0,"s":rng.randf_range(0.009,0.017)})
	if killed:
		# Follow the actual short corpse slide, then keep the decal fixed on the floor.
		_add_stain(point, 2, 0.10, weakref(target))

func _add_stain(point: Vector2, variant: int, size: float, follow: WeakRef = null) -> void:
	var limit := 16 if reduced() else MAX_STAINS
	# Tiny droplets share nearby marks; each kill retains one proper puddle.
	if variant == 0:
		for stain in stains:
			if stain.variant==0 and stain.p.distance_squared_to(point)<64:
				stain.s=minf(0.045,stain.s+0.003)
				stain.t=minf(stain.t,10.0)
				return
	if stains.size()>=limit:stains.pop_front()
	stains.append({"p":point.round(),"variant":variant,"s":size,"t":0.0,"follow":follow,"flip":-1.0 if rng.randf()<0.5 else 1.0})

func clear() -> void:
	sprays.clear()
	drops.clear()
	stains.clear()
	if is_instance_valid(floor_layer):floor_layer.queue_redraw()
	if is_instance_valid(air_layer):air_layer.queue_redraw()

func _process(delta: float) -> void:
	_trim_budgets()
	if world.menu_open or world.terminal != null:return
	for i in range(sprays.size()-1,-1,-1):
		sprays[i].t+=delta
		if sprays[i].t>=0.32:sprays.remove_at(i)
	for i in range(drops.size()-1,-1,-1):
		var drop := drops[i]
		drop.t+=delta
		var wanted: Vector2=drop.p+drop.v*delta
		var wall: Dictionary=world.trace_scenery(drop.p,wanted)
		if wall.is_empty():drop.p=wanted
		else:drop.v=Vector2.ZERO
		drop.h+=drop.vz*delta
		drop.vz-=230.0*delta
		if drop.h<=0 or drop.t>=1.0:
			_add_stain(drop.p,0,0.026)
			drops.remove_at(i)
	for i in range(stains.size()-1,-1,-1):
		var stain := stains[i]
		stain.t+=delta
		if stain.follow!=null:
			var body=stain.follow.get_ref()
			if is_instance_valid(body) and stain.t<0.4:stain.p=body.global_position.round()
			else:stain.follow=null
		if stain.t>=STAIN_LIFE:stains.remove_at(i)
	floor_layer.queue_redraw()
	air_layer.queue_redraw()

func _draw_air() -> void:
	for spray in sprays:
		var frame := mini(3,int(spray.t/0.08))
		var rect: Rect2=CELLS[frame]
		air_layer.draw_set_transform(spray.p.round(),spray.d.angle(),Vector2.ONE*spray.s)
		air_layer.draw_texture_rect_region(ART,Rect2(-ORIGINS[frame],rect.size),rect,Color(0.85,0.75,0.8,1.0-smoothstep(0.23,0.32,spray.t)))
	for drop in drops:
		air_layer.draw_set_transform((drop.p-Vector2(0,drop.h)).round(),drop.v.angle(),Vector2.ONE*drop.s)
		air_layer.draw_texture_rect_region(ART,Rect2(-50,-48,100,96),Rect2(115,645,100,96))
	air_layer.draw_set_transform(Vector2.ZERO)

func _draw_floor() -> void:
	for stain in stains:
		var variant: int=stain.variant
		if variant==2 and stain.t>8.0:variant=3
		var rect: Rect2=CELLS[variant]
		rect.position.y=443
		rect.size.y=444
		var grow := lerpf(0.25,1.0,smoothstep(0.0,0.85,stain.t)) if stain.variant==2 else 1.0
		var alpha := 1.0-smoothstep(STAIN_LIFE-12.0,STAIN_LIFE,stain.t)
		floor_layer.draw_set_transform(stain.p,0,Vector2(stain.flip,1)*stain.s*grow)
		# Bottom row shares the floor-contact centre at source-local (222,249).
		floor_layer.draw_texture_rect_region(ART,Rect2(-222,-249,rect.size.x,rect.size.y),rect,Color(0.66,0.54,0.58,alpha*0.94))
	floor_layer.draw_set_transform(Vector2.ZERO)
