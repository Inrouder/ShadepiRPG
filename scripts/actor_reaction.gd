extends Node2D
## v0.45.0 · CodexAI. Real collapse, grounded body and disoriented recovery poses.
const ART=preload("res://assets/story/reactions/poses.png")
const REGIONS=[Rect2(80,70,280,365),Rect2(455,120,390,315),Rect2(870,250,465,185),Rect2(1400,15,295,420),Rect2(65,460,310,405),Rect2(445,585,310,280),Rect2(800,640,455,225),Rect2(1265,690,495,175)]
const FEET=[Vector2(130,350),Vector2(180,296),Vector2(230,165),Vector2(145,405),Vector2(155,393),Vector2(150,269),Vector2(220,215),Vector2(245,160)]
var actor
var sprite: Sprite2D
var frame:=0
var mode:=""
var elapsed:=0.0
var released:=false
func _ready():
	sprite=Sprite2D.new()
	sprite.centered=false
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(sprite)
	actor.external_pose=true
	actor.visual.hide()
	actor.cast_shadow.hide()
	actor.light_occluder.hide()
	actor.queue_redraw()
	set_pose(frame)
	if mode=="recover":actor.world.cutscene.ended.connect(release,CONNECT_ONE_SHOT)
func set_pose(index: int):
	frame=index
	var t:=AtlasTexture.new();t.atlas=ART;t.region=REGIONS[frame];t.filter_clip=true
	sprite.texture=t
	var factor:=0.149 if frame<4 else 0.16
	sprite.scale=Vector2.ONE*factor
	sprite.position=-FEET[frame]*factor
func _process(delta: float):
	if actor.world.menu_open or actor.world.terminal!=null:return
	elapsed+=delta
	if mode=="collapse":set_pose(0 if elapsed<0.24 else 1 if elapsed<0.52 else 2)
	elif mode=="death":set_pose(4 if elapsed<0.20 else 5 if elapsed<0.45 else 6 if elapsed<0.72 else 7)
func release():
	if released:return
	released=true
	if is_instance_valid(actor):
		actor.external_pose=false
		if is_instance_valid(actor.visual):actor.visual.show()
		if is_instance_valid(actor.cast_shadow):actor.cast_shadow.show()
		if is_instance_valid(actor.light_occluder):actor.light_occluder.visible=not actor.cloaked
		actor.queue_redraw()
	mode=""
	hide()
func _exit_tree():release()
