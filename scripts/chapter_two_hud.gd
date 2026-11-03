extends "res://scripts/hud.gd"

const PANELS := {
	"industrie": preload("res://assets/comic/industrie.jpg"),
	"versteck": preload("res://assets/comic/versteck.jpg"),
	"netz": preload("res://assets/comic/netz.jpg"),
	"rueckkehr": preload("res://assets/comic/rueckkehr.jpg"),
}

var campaign_button: Button
var backdrop: Panel
var artwork: TextureRect

func _ready() -> void:
	super._ready()
	mission_title.text = "KAPITEL 2 / OFFENBARUNGEN"
	menu_description.text = "Industriegebiet · Ravens Versteck"
	mode_button.hide()
	restart_button.text = "Kapitel 2 neu starten"
	button_at("Zurück zu Kapitel 1", 274, func(): get_tree().change_scene_to_file("res://scenes/chapter_one.tscn"))
	campaign_button = button_at("Kapitel 3–7 fortsetzen", 93, func(): get_tree().change_scene_to_file("res://scenes/campaign.tscn"))
	campaign_button.hide()
	menu_help.position.y = 302
	menu_help.text = "E / A · Interagieren    Esc / Start · Menü"
	backdrop = panel(Rect2(0, 0, 640, 360))
	root.move_child(backdrop, dialogue_panel.get_index())
	artwork = TextureRect.new()
	artwork.position = Vector2(50, 12)
	artwork.size = Vector2(540, 204)
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	artwork.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	backdrop.add_child(artwork)
	backdrop.hide()

func show_menu(title: String = "KAPITEL 2") -> void:
	super.show_menu(title)

func _update_mode_buttons() -> void:
	resume_button.text = "Fortsetzen" if world.started else "Kapitel 2 starten"
	load_button.text = "Kontrollpunkt laden"
	load_button.disabled = world.saved_checkpoint() < 0
	campaign_button.visible = world.section == world.Section.END or world.saved_checkpoint() == world.Section.END or FileAccess.file_exists("user://shadepi-campaign.cfg")

func comic_texture(key: String) -> Texture2D:
	return PANELS.get(key, null)

func advance_dialogue() -> void:
	artwork.texture = comic_texture(dialogue_lines[0][2]) if not dialogue_lines.is_empty() else null
	super.advance_dialogue()

func _process(delta: float) -> void:
	super._process(delta)
	backdrop.visible = dialogue_open and artwork.texture != null and not world.menu_open
	dialogue_panel.visible = dialogue_open and not world.menu_open
	objective.text = world.chapter_objective()
	abilities.visible = false
	controls.text = "WASD / Stick · Bewegen     E / A · Interagieren     Esc / Start · Menü"
	if world.raven_leads():
		vitals.text = "RAVEN / DEEP DIVE"
