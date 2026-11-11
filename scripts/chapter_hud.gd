extends "res://scripts/hud.gd"

var next_chapter_button: Button
var campaign_button: Button
func _ready() -> void :
	super._ready()
	mission_title.text = "KAPITEL 1 / ECHOS IN NEON UND SCHATTEN"
	menu_description.text = "Kapitel 1 · Ravens Jagd\nLokal-Koop beginnt mit Ravens Rückkehr."
	next_chapter_button = button_at("Kapitel 2 öffnen", 274, func(): open_chapter("res://scenes/chapter_two.tscn"))
	# v0.55.0 · ClaudeHelper: auch die späteren Kapitel direkt aus dem Hauptmenü.
	campaign_button = button_at("Kapitel 3–7 öffnen", 274, func(): open_chapter("res://scenes/campaign.tscn"))
	menu_help.text = "Stick / Kreuz und A · F11 Vollbild"
	restart_button.text = "Kapitel 1 neu starten"
func show_menu(title: String = "KAPITEL 1") -> void :
	requested_coop = world.chapter_coop
	# v0.55.0 · ClaudeHelper: Rückkehr aus einem späteren Kapitel behält den gewählten Modus.
	if not world.started and world.is_inside_tree() and world.get_tree().get_meta(world.COOP_SESSION, false):
		requested_coop = true
	_show_menu_shell(title)

## Chapter 1 is Raven's hunt for the Chrome Jackals.
func menu_theme() -> String:
	return "jackal"

func _update_mode_buttons() -> void :
	var mode: = "Lokal-Koop" if requested_coop else "Einzelspieler"
	mode_button.text = "Modus · " + mode
	resume_button.text = "Fortsetzen" if world.started and world.chapter_coop == requested_coop else "Kapitel 1 starten"
	load_button.text = "Letzten Kontrollpunkt laden"
	_update_checkpoint_button()
	var later: int = world.ChapterFlow.checkpoint("user://shadepi-chapter-two.cfg", "chapter", "section", range(6))
	var opening: bool = not world.started
	var unlocked: bool = world.admin_enabled("unlock_all")
	next_chapter_button.visible = opening and (unlocked or world.saved_checkpoint(false) == world.Phase.COMPLETE or world.saved_checkpoint(true) == world.Phase.COMPLETE or later >= 0)
	next_chapter_button.text = "Kapitel 2 fortsetzen" if later >= 0 else "Kapitel 2 starten"
	var campaign: int = world.ChapterFlow.checkpoint("user://shadepi-campaign.cfg", "campaign", "beat", range(12))
	campaign_button.visible = opening and (unlocked or campaign >= 0 or later == 4)
	campaign_button.text = "Kapitel 3–7 fortsetzen" if campaign >= 0 else "Kapitel 3 starten"

func _start_new() -> void :
	world.chapter_coop = requested_coop
	world.new_game()

func start_selected() -> void :
	if world.started and world.chapter_coop == requested_coop:
		world.close_menu()
	else:
		_start_new()

func comic_texture(_key: String) -> Texture2D:
	return null

func _process(delta: float) -> void :
	super._process(delta)
	if world.raven_leads():
		vitals.text = "RAVEN / %03d   EN %03d" % [world.raven.health, roundi(world.raven.energy)]
		health_bar.size.x = 164.0 * world.raven.health / 100.0
		energy_bar.size.x = 164.0 * world.raven.energy / 100.0
		if world.gamepads.shadepi_device < 0:
			controls.text = "WASD / Pfeile  Bewegen     Maus / J  Schuss     Leertaste  Ausweichen     Esc  Menü"
	if world.raven_leads() and world.gamepads.shadepi_device >= 0:
		controls.text = "Linker Stick  Bewegen     Rechter Stick  Zielen     X  Schuss     B  Ausweichen"
	elif world.coop and world.raven_joined:
		controls.text = "Raven · Rechter Stick / X oder rechte Maustaste / U     Shadepi · J / linke Maustaste"
	match world.phase:
		world.Phase.APARTMENT:
			objective.text = "Kopfgeld / Chrome Jackal"
		world.Phase.HUNT:
			if world.gate_open:
				objective.text = "Betritt den Wartungshof"
			elif world._guards_left() > 0:
				objective.text = "Folge der Spur · %d Punks übrig" % world._guards_left()
			elif world._hunt_terminal_ready():
				objective.text = "Raven: Jackals Torschleuse hacken"
			else:
				objective.text = "Folge der Spur zur Schleuse"
		world.Phase.DUEL:
			objective.text = "Halte durch. Dein Hack läuft."
		world.Phase.ROOFTOP:
			objective.text = "Signal verloren"
		world.Phase.RESCUE:
			objective.text = "Finde Raven" if world.gate_open else "Besiege die Wachen in der Wartungsgasse"
		world.Phase.REVIVE:
			objective.text = "Hör Raven zu"
		world.Phase.TEAM:
			objective.text = "Schaltet Jackals Implantate aus" if world.raven_joined else "Bring Jackal auf halbe Stärke"
		world.Phase.EPILOGUE:
			objective.text = "Der Auftrag danach"
		world.Phase.COMPLETE:
			objective.text = "Kapitel 1 abgeschlossen"
	if world.encounter != null and not world.encounter.finished:
		objective.text = world.encounter.status_text()
	abilities.visible = abilities.visible and world.phase in [world.Phase.DUEL, world.Phase.RESCUE, world.Phase.TEAM]
	if world.phase == world.Phase.DUEL:
		var remaining: = ceili(world.DUEL_DURATION - world.duel_time)
		boss.text = "CHROME JACKAL / %d HP\n%s" % [world.enemy.health, "GEGENHACK" if world.counter_warning else "Panzerung undurchdringlich"]
		abilities.text = "NETRUNNING / Handshake in %02d s     Leertaste / B  Ausweichen" % remaining
	elif world.phase == world.Phase.TEAM:
		boss.text = "CHROME JACKAL / %d von %d HP\n%s" % [world.enemy.health, world.enemy.max_health, "IMPLANTATE GESTÖRT" if world.enemy.exposed > 0 else "Panzerung aktiv"]
	if world.phase == world.Phase.RESCUE or (world.phase == world.Phase.TEAM and not world.raven_joined):
		var cloak: = "%.0fs" % world.player.cloak_cooldown if world.player.cloak_cooldown > 0.0 else "bereit"
		abilities.text = "C / Y  Tarnfeld: %s" % cloak
