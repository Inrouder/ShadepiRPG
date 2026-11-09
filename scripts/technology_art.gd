extends RefCounted
## v0.42.0 · CodexAI. Registered cabinet shells, mechanical idle and access phases.
const ELECTRICAL = preload("res://assets/world/technology/electrical.png")
const SERVER = preload("res://assets/world/technology/server.png")
const CELL := Vector2(384,512)
const FEET := {"electrical":Vector2(195,444),"server":Vector2(210,477)}
const SIZES := {"electrical":Vector2(52,74),"server":Vector2(64,78)}
# Explicit connected status devices, not a nearest-decoration guess or a new story gate.
const LINKS := {
	"garage":{"garage":["tool_case"]},
	"hangar":{"power":["spare_server"],"transponder":["diagnostics"]},
	"roof":{"roof_signal":["backup_generator"],"penthouse":["backup_generator"]},
	"suite":{"charge":["lift_server","power_box"]},
}
static func supports(kind: String) -> bool: return FEET.has(kind)
static func frame_for(clock: float,mode: String,left: float) -> int:
	if mode=="waiting": return 4
	if mode=="fault": return 7
	if mode=="success":
		var elapsed := 1.1-left
		return 4 if elapsed<0.12 else 5 if elapsed<0.34 else 6
	return posmod(int(floor(clock*8.0)),4)
static func apply(sprite: Sprite2D,kind: String):
	sprite.frame = 0
	sprite.texture = ELECTRICAL if kind=="electrical" else SERVER
	sprite.region_enabled = false
	sprite.hframes = 4
	sprite.vframes = 2
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.scale = SIZES[kind]/CELL
	sprite.position = (CELL*0.5-FEET[kind])*sprite.scale+Vector2(0,-4)

static func apply_damage(sprite: Sprite2D,kind: String):
	var art=preload("res://scripts/prop_art.gd").texture(5 if kind=="electrical" else 7,1)
	var bounds:=Rect2(44,54,154,191) if kind=="electrical" else Rect2(29,59,167,189)
	var visible_size:=Vector2(286.0*52/384,417.0*74/512) if kind=="electrical" else Vector2(279.0*64/384,464.0*78/512)
	sprite.texture=art
	sprite.scale=visible_size/bounds.size
	sprite.position=(art.get_size()*0.5-Vector2(bounds.get_center().x,bounds.end.y))*sprite.scale+Vector2(0,-4)
