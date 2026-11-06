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
	if world.beat == world.Beat.BOSS and not world.foes.is_empty() and not world.in_cinematic():
		var kenzo: PixelActor = world.foes.back()
		var window: bool = kenzo.health <= 180 and fposmod(world.clock, 3.0) <= 1.45
		boss_panel.visible = kenzo.health > 0
		boss.text = "KENZŌ MORIYAMA / %d HP\n%s" % [maxi(0, kenzo.health), "SCHULTERSERVO OFFEN · Q / RB" if window else ("Leitung gesperrt" if kenzo.health <= 180 else "Implantate aktiv")]
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
			if world.drive.engine_failed:
				objective.text = "TRIEBWERK AUS · %.1f s" % world.drive.repair_left
				controls.text = "J / X · Ravens Wartungsdeck    A/D / Stick · Gegenlenken"
				abilities.text = "Jumper prüfen · TX/RX kreuzen · Alpha 120 Ω"
				energy_bar.size.x = 164.0 * world.drive.repair_left / world.drive.REPAIR_SECONDS
			elif world.drive.restart_flash > 0:
				abilities.text = "TRIEBWERK LÄUFT · Anflug fortsetzen"
		else:
			objective.text = "Verfolger · %d %% Panzerung" % maxi(0, world.drive.armour)
			controls.text = "A/D / Stick · Lenken    J / X · Feuer    Q / RB · Hack    Leertaste / B · Granate"
			abilities.visible = not dialogue_open and not world.menu_open
			abilities.text = "Hack %.0f s    Granate %.0f s" % [world.drive.hack_cooldown, world.drive.grenade_cooldown]
	elif world.timing != null:
		controls.text = "J / X · Tippen    U / zweiter Controller · Raven    Esc / Start · Pause"
	elif world.is_combat():
		controls.text = "WASD / Stick · Bewegen    J / X · Katana    Q / RB · Ravens Hack    Leertaste / B · Dash"
	elif world.beat == world.Beat.END:
		controls.text = "Geschichte abgeschlossen · Esc / Start öffnet das Menü"
	else:
		controls.text = "WASD / Stick · Bewegen    E / A · Interagieren    Leertaste / B · Ausweichen    Esc · Menü"
