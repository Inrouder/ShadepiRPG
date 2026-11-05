class_name WorldProp
extends StaticBody2D

const Art = preload("res://scripts/prop_art.gd")
const TYPES: = {
	"crate": {"column": 0, "hp": 40, "footprint": Vector2(43, 22), "color": "b28d64", "label": "Frachtkiste"}, 
	"barrel": {"column": 1, "hp": 34, "footprint": Vector2(31, 21), "color": "bd7163", "label": "Brennstofffass"}, 
	"lamp": {"column": 2, "hp": 64, "footprint": Vector2(11, 12), "color": "8da6af", "label": "Straßenlaterne"}, 
	"car": {"column": 3, "hp": 168, "footprint": Vector2(103, 29), "color": "8195a3", "label": "Geparkter Wagen"}, 
	"dumpster": {"column": 4, "hp": 94, "footprint": Vector2(64, 26), "color": "708b74", "label": "Müllcontainer"}, 
	"electrical": {"column": 5, "hp": 58, "footprint": Vector2(40, 19), "color": "77bfd1", "label": "Schaltkasten"}, 
	"vending": {"column": 6, "hp": 74, "footprint": Vector2(48, 20), "color": "c379a7", "label": "Getränkeautomat"}, 
	"server": {"column": 7, "hp": 82, "footprint": Vector2(44, 21), "color": "82b7c9", "label": "Serverschrank"}, 
	"data_cache": {"column": 8, "hp": 34, "footprint": Vector2(54, 24), "color": "ac8be0", "label": "Datenkristall"}, 
}

var world: Node2D
var prop_id: = ""
var kind: = "crate"
var health: = 40
var max_health: = 40
var sprite: Sprite2D
var shape: CollisionShape2D
var lamp: PointLight2D
var hurt: = 0.0

func setup(game: Node2D, id: String, type: String, point: Vector2) -> void :
	world = game
	prop_id = id
	kind = type
	position = point
	max_health = TYPES[kind].hp
	health = max_health
	collision_layer = 1
	collision_mask = 0
	shape = CollisionShape2D.new()
	var rectangle: = RectangleShape2D.new()
	rectangle.size = TYPES[kind].footprint
	shape.shape = rectangle
	shape.position.y = - rectangle.size.y * 0.5
	add_child(shape)
	sprite = Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.region_enabled = true
	sprite.position.y = -50
	add_child(sprite)
	if kind == "lamp":
		lamp = PointLight2D.new()
		lamp.texture = preload("res://assets/world/light.png")
		lamp.position = Vector2(28, -89)
		lamp.color = Color("f5c59a")
		lamp.texture_scale = 2.7
		lamp.energy = 0.74
		add_child(lamp)
	_update_art()
	set_process(false)

func footprint() -> Rect2:
	var size: Vector2 = TYPES[kind].footprint
	return Rect2(global_position - Vector2(size.x * 0.5, size.y), size)

func nearest_point(origin: Vector2) -> Vector2:
	var box: = footprint()
	return origin.clamp(box.position, box.end)

func restore_health(value: int) -> void :
	health = clampi(value, 0, max_health)
	collision_layer = 1 if health > 0 else 0
	shape.set_deferred("disabled", health == 0)
	hurt = 0.0
	sprite.position.x = 0.0
	sprite.modulate = Color.WHITE
	_update_art()
	set_process(false)

func take_damage(amount: int) -> void :
	if health <= 0 or amount <= 0:
		return
	health = maxi(0, health - amount)
	hurt = 0.17 if health > 0 else 0.0
	if health == 0:
		collision_layer = 0
		shape.set_deferred("disabled", true)
		sprite.position.x = 0.0
		sprite.modulate = Color.WHITE
	_update_art()
	set_process(health > 0)
	world.prop_damaged(self, amount)

func _update_art() -> void :
	var row: = 2 if health == 0 else 1 if health <= max_health / 2 else 0
	Art.apply(sprite, TYPES[kind].column, row)
	if lamp != null:
		lamp.enabled = health > 0
		lamp.energy = 0.74 if row == 0 else 0.3
	queue_redraw()

func _process(delta: float) -> void :
	if world.is_busy():
		return
	hurt = maxf(0, hurt - delta)
	sprite.position.x = sin(hurt * 170.0) * hurt * 6.0
	sprite.modulate = Color(1.0 + hurt * 2.0, 1.0 + hurt * 1.3, 1.0 + hurt)
	if hurt == 0.0:
		set_process(false)
	queue_redraw()

func _draw() -> void :
	if hurt <= 0.0 or health <= 0:
		return
	var top: = -101.0 if kind == "lamp" else -69.0
	draw_rect(Rect2(-18, top, 36, 3), Color("172333"))
	draw_rect(Rect2(-18, top, 36.0 * health / max_health, 3), Color("d3bc93"))
