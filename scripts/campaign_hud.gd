extends "res://scripts/chapter_two_hud.gd"

func _ready() -> void :
	super._ready()
	menu_description.text = "Kapitel 3–7 · Der Pakt bis Der neue Orden"
	restart_button.text = "Ab Kapitel 3 neu starten"

func show_menu(title: String = "SHADEPI / KAMPAGNE") -> void :
	super.show_menu(title)

func _update_mode_buttons() -> void :
	resume_button.text = "Fortsetzen" if world.started else "Kampagne starten"
	load_button.text = "Kontrollpunkt laden"
	load_button.disabled = world.saved_checkpoint() < 0

func comic_texture(key: String) -> Texture2D:
	return world.Story.PANELS.get(key, null)

func comic_heading() -> String:
	return world.chapter_label()

func _process(delta: float) -> void :
	super._process(delta)
	mission_title.text = world.chapter_label()
	if world.raven_leads():
		vitals.text = "RAVEN / NETRUNNERIN"
	if world.drive != null:
		vitals.text = "INTEGRITÄT / %d %%" % maxi(0, world.drive.health)
		health_bar.size.x = 164.0 * maxf(0.0, world.drive.health) / 100.0
		energy_bar.size.x = 0.0
		if world.drive.flight:
			objective.text = "Tower-Anflug · %.0f s" % maxf(0.0, 15.0 - world.drive.elapsed)
			controls.text = "A/D / Stick · Flugspur wechseln    Q / RB · Gleiterkennung"
			abilities.visible = not dialogue_open and not world.menu_open
			abilities.text = "Kennung bestätigt" if world.drive.transponder_sent else ("Scanner in Reichweite · Q / RB" if world.drive.elapsed >= 9.0 else "Scanner noch außer Reichweite")
		else:
			objective.text = "Verfolger · %d %% Panzerung" % maxi(0, world.drive.armour)
			controls.text = "A/D / Stick · Lenken    J / X · Feuer    Q / RB · Hack    Leertaste / B · Granate"
			abilities.visible = not dialogue_open and not world.menu_open
			abilities.text = "Hack %.0f s    Granate %.0f s" % [world.drive.hack_cooldown, world.drive.grenade_cooldown]
	elif world.timing != null:
		controls.text = "J / X · Tippen    U / zweiter Controller · Raven    Esc / Start · Pause"
	elif world.is_combat():
		controls.text = "WASD / Stick · Bewegen    J / X · Katana    Q / RB · Ravens Hack    Leertaste / B · Dash"
