extends RefCounted
## v0.45.0 · CodexAI. Real gameplay poses, registered independently of cell gutters.
const RAVEN = "res://assets/sprites/heroes/gameplay/raven.png"
const SHADEPI = "res://assets/sprites/heroes/gameplay/shadepi.png"
const ROWS := [0,3,2,1,6,7,4,5] # Existing south/west/east/north/NW/NE/SW/SE order.
static func supports(texture: Texture2D) -> bool:
	if texture is AtlasTexture:texture=texture.atlas
	return texture!=null and texture.resource_path in [RAVEN,SHADEPI]
static func catalog_for(texture: Texture2D) -> Array:
	if texture is AtlasTexture:texture=texture.atlas
	var document: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/sprites/heroes/gameplay/poses.json"))
	return document["raven" if texture.resource_path==RAVEN else "shadepi"]
static func data(texture: Texture2D,row: int,column: int) -> Dictionary:
	return catalog_for(texture)[ROWS[row]][column]
static func apply(actor,state: String,row: int,time: float):
	var col := 0
	if state=="walk":col=1+posmod(int(time*7),4)
	elif state=="attack":col=5 if time<0.10 else 6
	elif state=="hurt":col=7
	var d: Dictionary=actor.hero_frames[ROWS[row]][col]
	var offset: Vector2=actor.visual.position-actor.standing_visual_position
	var rect: Array=d.region
	var cell:=Vector2(rect[2],rect[3])
	var anchor:=Vector2(d.anchor[0],d.anchor[1])
	actor.hero_pose_texture.region=Rect2(rect[0],rect[1],rect[2],rect[3])
	actor.visual.texture=actor.hero_pose_texture
	actor.visual.hframes=1
	actor.visual.vframes=1
	actor.visual.frame=0
	actor.hero_frame=ROWS[row]*8+col
	actor.visual.scale=Vector2.ONE*float(d.scale)
	actor.standing_visual_position=(cell*0.5-anchor)*float(d.scale)
	actor.visual.position=actor.standing_visual_position+offset
	actor.visual.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	actor.cast_shadow.texture=actor.hero_pose_texture
	actor.cast_shadow.hframes=1
	actor.cast_shadow.vframes=1
	actor.cast_shadow.frame=0
	actor.cast_shadow.scale=Vector2(1.05,0.3)*float(d.scale)
	actor.cast_shadow.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
static func attachment(actor,_row: int) -> Vector2:
	var d: Dictionary=actor.hero_frames[int(actor.hero_frame/8)][actor.hero_frame%8]
	var point:=Vector2(d.muzzle[0],d.muzzle[1])
	return actor.visual.to_global(point-actor.visual.texture.get_size()*0.5)
