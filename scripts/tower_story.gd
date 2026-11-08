extends RefCounted
## v0.33.0 · CodexAI: capture -> intervention -> living prisoner -> protected data.
const Tableau = preload("res://scripts/tower_tableau.gd")

static func opening(w) -> void:
	var k = w.foes.back()
	k.position = Vector2(612,306)
	w.player.position = Vector2(430,446)
	w.raven.position = Vector2(420,396)
	w.player.set_cloaked(true)
	var cs = w.begin_cutscene()
	var ticket: int = cs.generation
	cs.pose(k,"idle")
	cs.pose(w.player,"idle")
	cs.pose(w.raven,"idle")
	await cs.camera(Vector2(570,340),0.4,1.4)
	if not cs.alive(ticket): return
	await cs.walk(w.raven,Vector2(540,385),65)
	if not cs.alive(ticket): return
	cs.face(w.raven,k.position)
	await cs.say("RAVEN","Du hast lange genug nach mir gesucht. Hier bin ich.")
	if not cs.alive(ticket): return
	await cs.walk(k,Vector2(570,386),48)
	if not cs.alive(ticket): return
	cs.do(func():
		w.tower_grip = Tableau.new()
		w.actors.add_child(w.tower_grip)
		w.tower_grip.position = k.position
		w.tower_grip.show_pose("grip")
		k.visual.hide()
		k.cast_shadow.hide()
		w.raven.visual.hide()
		w.raven.cast_shadow.hide()
		w.sound("hit")
	)
	await cs.wait(0.65)
	if not cs.alive(ticket): return
	await cs.say("KENZŌ MORIYAMA","Und diesmal läufst du mir nicht davon.")
	if not cs.alive(ticket): return
	await cs.say("RAVEN","Lass. Mich. Los.")
	if not cs.alive(ticket): return
	# Shadepi reveals himself only after the physical grip is visibly established.
	cs.do(func(): w.player.set_cloaked(false))
	await cs.say("SHADEPI","Nimm die Hand von ihr.")
	if not cs.alive(ticket): return
	await cs.walk(w.player,k.position+Vector2(-35,15),420)
	if not cs.alive(ticket): return
	cs.do(func():
		w.effects.slash(k.position+Vector2(0,-32),Vector2.RIGHT)
		w.effects.burst(k.position+Vector2(0,-30),Color("ffb36b"),20)
		w.sound("slash")
		w.shake = 7
		w.tower_grip.queue_free()
		w.tower_grip = null
		for a in [k,w.raven]:
			a.visual.show()
			a.cast_shadow.show()
	)
	cs.pose(k,"hurt")
	await cs.leap(w.raven,Vector2(410,420),18,0.45)
	if not cs.alive(ticket): return
	await cs.walk(k,Vector2(690,360),220)
	if not cs.alive(ticket): return
	cs.face(k,w.player.position)
	cs.face(w.player,k.position)
	cs.pose(k,"idle")
	cs.pose(w.raven,"idle")
	await cs.lines([
		["KENZŌ MORIYAMA","Die Maske … Dich hätte dort niemand überleben lassen dürfen."],
		["SHADEPI","Dann versuch es selbst."],
		["RAVEN","Sein Schulterservo flackert. Da komme ich in die Implantate."],
	])
	if not cs.alive(ticket): return
	cs.end(func(): w.toast("KENZŌ · Shadepi kämpft · Q / RB: Ravens Implantat-Hack"))

static func defeated(w) -> void:
	var cs = w.begin_cutscene()
	var ticket: int = cs.generation
	w.player.position = w.boss_spot+Vector2(-100,65)
	w.raven.position = w.boss_spot+Vector2(-110,20)
	cs.pose(w.player,"idle")
	cs.pose(w.raven,"idle")
	cs.face(w.player,w.boss_spot)
	await cs.camera(w.boss_spot+Vector2(-65,-35),0.4,1.5)
	if not cs.alive(ticket): return
	await cs.say("RAVEN","Seine Motorik ist blockiert. Er kann sich nicht mehr bewegen.")
	if not cs.alive(ticket): return
	await cs.walk(w.raven,w.boss_spot+Tableau.RAVEN_OFFSET,48)
	if not cs.alive(ticket): return
	await cs.lines([
		["RAVEN","In seinem Deck steckt die ganze Operation. Ich ziehe die Daten, bevor er sie löscht."],
		["SHADEPI","Tu es. Ich halte dir den Rücken frei."],
		["RAVEN","Wachen im Aufzug. Wenn sie mich dreimal erwischen, bricht die Verbindung ab."],
	])
	if not cs.alive(ticket): return
	cs.end(func(): w.tower.begin())

static func resolution(w) -> void:
	var cs = w.begin_cutscene()
	var ticket: int = cs.generation
	w.raven.position = w.boss_spot+Tableau.RAVEN_OFFSET
	w.raven.visual.hide()
	w.raven.cast_shadow.hide()
	w.tower.tableau.show_pose("extract")
	cs.pose(w.player,"idle")
	await cs.camera(w.boss_spot+Vector2(-45,-35),0.5,1.55)
	if not cs.alive(ticket): return
	await cs.lines([
		["RAVEN","Ich habe es. Einsatzbefehle, Zahlungen, die Minotauren. Kenzō hat den Angriff auf deinen Orden inszeniert."],
		["SHADEPI","Warum?"],
		["RAVEN","Die Begründung fehlt. Und der Auftraggeber ist aus den Daten entfernt worden. Kenzō war beteiligt – aber die Spur endet nicht bei ihm."],
		["KENZŌ MORIYAMA","Ihr habt keine Ahnung, womit ihr euch anlegt."],
		["RAVEN","Vielleicht. Aber du wirst niemanden mehr einsperren."],
	])
	if not cs.alive(ticket): return
	cs.do(func(): w.sound("hack"))
	await cs.animate(func(p: float):
		if not is_instance_valid(w.tower): return
		w.tower.tableau.kenzo.modulate = Color(1+p*1.2,1+p*1.2,1+p*1.2)
		w.effects.hack_arc(w.raven.position+Vector2(26,-44),w.boss_spot+Vector2(-4,-32))
	,0.9)
	if not cs.alive(ticket): return
	cs.do(func():
		w.tower.tableau.show_pose("dead")
		w.tower.tableau.kenzo.modulate = Color(0.62,0.56,0.5)
		w.kenzo_body.health = 0
		w.effects.burst(w.boss_spot+Vector2(0,-18),Color("ffb66d"),28)
		w.sound("drive_explosion",0.25)
		w.shake = 7
		w.raven.visual.show()
		w.raven.cast_shadow.show()
	)
	await cs.wait(0.8)
	if not cs.alive(ticket): return
	cs.face(w.raven,w.player.position)
	await cs.lines([
		["RAVEN","Meine Eltern … Wenigstens kann er ihnen niemanden mehr nachschicken."],
		["SHADEPI","Deine Rache ist vorbei. Die Sache mit dem Orden nicht."],
		["RAVEN","Dann suchen wir weiter. Zusammen."],
		["SYSTEM","Sicherheitsprotokoll überlastet. Evakuierung. Sechzig Sekunden."],
	])
	if not cs.alive(ticket): return
	cs.do(func():
		w.tower_stage = 2
		w.escape_guards_cleared = true
		w.point_index = 1
		w.countdown = 60
		w.set_music_section("chapter_6_escape")
		w.autosave()
	)
	cs.end(func(): w.toast("T-60 · Aufzug sperren · Fernstart · zum Dach"))
