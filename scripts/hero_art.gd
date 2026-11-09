extends RefCounted
## v0.45.0 · CodexAI. Real gameplay poses, registered independently of cell gutters.
const RAVEN = "res://assets/sprites/heroes/gameplay/raven.png"
const SHADEPI = "res://assets/sprites/heroes/gameplay/shadepi.png"
const ROWS := [0,3,2,1,6,7,4,5] # Existing south/west/east/north/NW/NE/SW/SE order.
static func supports(texture: Texture2D) -> bool:
	return texture!=null and texture.resource_path in [RAVEN,SHADEPI]
static func catalog_for(texture: Texture2D) -> Array:
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
	var cell: Vector2=actor.visual.texture.get_size()/8.0
	var anchor:=Vector2(d.anchor[0],d.anchor[1])
	actor.visual.hframes=8
	actor.visual.vframes=8
	actor.visual.frame=ROWS[row]*8+col
	actor.visual.scale=Vector2.ONE*float(d.scale)
	actor.standing_visual_position=(cell*0.5-anchor)*float(d.scale)
	actor.visual.position=actor.standing_visual_position+offset
	actor.visual.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	actor.cast_shadow.texture=actor.visual.texture
	actor.cast_shadow.hframes=8
	actor.cast_shadow.vframes=8
	actor.cast_shadow.frame=actor.visual.frame
	actor.cast_shadow.scale=Vector2(1.05,0.3)*float(d.scale)
	actor.cast_shadow.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
static func attachment(actor,row: int) -> Vector2:
	const MUZZLES=[Vector2(0.615,0.286),Vector2(0.653,0.241),Vector2(0.865,0.272),Vector2(0.147,0.266),Vector2(0.27,0.316),Vector2(0.744,0.369),Vector2(0.79,0.18),Vector2(0.77,0.146)]
	var point: Vector2=MUZZLES[ROWS[row]]
	return actor.visual.to_global((point-Vector2(0.5,0.5))*actor.visual.texture.get_size()/8.0)
