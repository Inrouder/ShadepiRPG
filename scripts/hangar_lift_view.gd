extends Node2D
## v0.39.0 · CodexAI. Actual actors remain registered on a moving lift deck.
const Art = preload("res://scripts/hangar_art.gd")
const Craft = preload("res://scripts/cinematic_aerodyne.gd")
var director: Node2D
var space: Node2D
var bike: Sprite2D
var vehicle: Node2D
var props: Array[Node] = []
var garage_matrix := Transform2D.IDENTITY
var dock_matrix := Transform2D.IDENTITY
func _ready():
	var unshaded := CanvasItemMaterial.new()
	unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = unshaded
	space = Node2D.new()
	space.y_sort_enabled = true
	add_child(space)
	bike = Art.bike_sprite()
	bike.position -= Art.SHIFT
	space.add_child(bike)
	vehicle = Craft.new()
	space.add_child(vehicle)
	vehicle.set_pose(Art.CRAFT,0.9,0,0,0)
	vehicle.hide()
	for item in preload("res://scripts/world_dressing.gd").items("hangar"):
		var prop := preload("res://scripts/world_prop.gd").new()
		prop.setup(director.world,item[0],item[1],item[2])
		space.add_child(prop)
		prop.restore_health(int(director.world.prop_states.get("hangar",{}).get(item[0],prop.max_health)))
		prop.collision_layer = 0
		prop.shape.set_deferred("disabled",true)
		prop.hide()
		props.append(prop)
func _process(_delta: float):
	if director.view=="shaft":
		space.transform = garage_matrix
		space.position.y += sin(director.travel*PI)*12.0
	else:
		director.world.camera.force_update_scroll()
		space.transform = dock_matrix.interpolate_with(get_viewport().get_canvas_transform(),director.gate)
		vehicle.visible = director.gate>0.99
		for prop in props: prop.visible = director.gate>0.99
	queue_redraw()
func _draw():
	if director.view=="hangar":
		draw_set_transform_matrix(space.transform)
		Art.room(self)
		Art.shadow(self,space.transform)
		draw_set_transform( Vector2.ZERO)
	var scroll: float = director.travel*600.0
	if director.view=="shaft" or director.gate<1:
		draw_texture_rect(Art.SHAFT,Rect2(0,-scroll-director.gate*400,640,960),false)
	draw_set_transform_matrix(space.transform)
	Art.floor(self,director.view=="hangar",director.deck_frame)
	draw_set_transform(Vector2.ZERO)
