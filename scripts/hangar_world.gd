extends Node2D
## v0.39.0 · CodexAI. The explored ship is the same model used by later flights.
const Art = preload("res://scripts/hangar_art.gd")
const Craft = preload("res://scripts/cinematic_aerodyne.gd")
var world: Node2D
var vehicle: Node2D
var clock := 0.0
func _ready():
	y_sort_enabled = true
	vehicle = Craft.new()
	add_child(vehicle)
	add_child(Art.bike_sprite())
	vehicle.set_pose(Art.CRAFT,0.9,0,0,0)
func _process(delta: float):
	if world.menu_open or world.terminal!=null: return
	clock += delta
	vehicle.set_pose(Art.CRAFT,0.9,0,0,clock)
func _draw(): Art.shadow(self)
