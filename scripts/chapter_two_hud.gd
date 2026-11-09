extends "res://scripts/hud.gd"

var campaign_button: Button

func _ready() -> void :
	super._ready()
	mission_title.text = "KAPITEL 2 / OFFENBARUNGEN"
	menu_description.text = "Industriegebiet · Ravens Versteck"
	mode_button.hide()
	restart_button.text = "Kapitel 2 neu starten"
	button_at("Zurück zu Kapitel 1", 274, func(): get_tree().change_scene_to_file("res://scenes/chapter_one.tscn"))
	campaign_button = button_at("Kapitel 3–7 fortsetzen", 93, func(): get_tree().change_scene_to_file("res://scenes/campaign.tscn"))
	campaign_button.hide()
	menu_help.position.y = 333
	menu_help.text = "E / A Zugriff · F11 Vollbild"
func show_menu(title: String = "KAPITEL 2") -> void :
	super.show_menu(title)

func _update_mode_buttons() -> void :
	resume_button.text = "Fortsetzen" if world.started else "Kapitel 2 starten"
	load_button.text = "Letzten Kontrollpunkt laden"
	_update_checkpoint_button()
	var later: int = world.ChapterFlow.checkpoint("user://shadepi-campaign.cfg", "campaign", "beat", range(12))
	campaign_button.visible = world.admin_enabled("unlock_all") or world.section == world.Section.END or world.saved_checkpoint() == world.Section.END or later >= 0
	campaign_button.text = "Kapitel 3–7 fortsetzen" if later >= 0 else "Kapitel 3 starten"

func comic_texture(_key: String) -> Texture2D:
	return null

func _process(delta: float) -> void :
	super._process(delta)
	objective.text = world.chapter_objective()
	abilities.visible = false
	controls.text = "WASD / Stick · Bewegen    J / X · Angriff    E / A · Interagieren    Esc / Start · Menü"
	if world.raven_leads():
		vitals.text = "RAVEN / DEEP DIVE · %d %%" % world.raven.health
		health_bar.size.x = 164.0 * world.raven.health / 100.0
		energy_bar.size.x = 164.0 * world.raven.energy / 100.0
		controls.text = "WASD / Stick · Bewegen    J / X · Impuls    Q / RB · Hack    E / A · Zugriff"
