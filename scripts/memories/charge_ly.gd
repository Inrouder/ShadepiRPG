extends "res://scripts/memories/memory_actor.gd"
const CHARGE_ART = preload("res://assets/memories/sacrifice/ly-charge.png")
const CHARGE_POSES := {"charge_draw":2,"charge_arm":3,"charge_leap":4,"charge_attach":5,"charge_brace":6}
static var charge_data: Array = []
var carrying := false
func _init() -> void:
	if charge_data.is_empty(): charge_data = JSON.parse_string(FileAccess.get_file_as_string("res://assets/memories/sacrifice/actors.json")).ly
func animate(state: String,delta: float) -> void:
	if fallen or not CHARGE_POSES.has(state) and not (state=="walk" and carrying):
		super.animate(state,delta)
		return
	if animation_name!=state: animation_time=0
	animation_name=state
	animation_time += delta
	var column: int = int(animation_time*8)%2 if state=="walk" else CHARGE_POSES[state]
	frame_key = "charge_%d"%column
	apply_pose(charge_data[column],CHARGE_ART,facing.x<0)
