extends RefCounted
## v0.30.0 · CodexAI: present-day chronology, separate from historical memories.

static func arrival(w) -> void:
	var cs = w.begin_cutscene()
	var ticket: int = cs.generation
	cs.pose(w.raven, "idle")
	await cs.fade(Color.BLACK, 0.0)
	if not cs.alive(ticket): return
	await cs.title("KAPITEL 5 · HEILIGTUM", "Nach der Reparatur des Aerodyne", 2.2)
	if not cs.alive(ticket): return
	await cs.camera(w.Painted.CHAMBER_CAMERA, 0.0, 1.15)
	if not cs.alive(ticket): return
	await cs.fade(Color.TRANSPARENT, 0.6)
	if not cs.alive(ticket): return
	await cs.walk(w.raven, Vector2(550, 350), 65)
	if not cs.alive(ticket): return
	await cs.say("RAVEN", "Shadepi? Der Aerodyne läuft wieder. Wo steckst du?")
	if not cs.alive(ticket): return
	cs.face(w.raven, w.SanctuaryTableau.DOOR)
	cs.do(func(): w.sanctuary_tableau.speech.speak("Hey Raven, ich bin hier. Ruhe dich aus, ich komme gleich.", w.SanctuaryTableau.DOOR + Vector2(0, -43)))
	await cs.say("SHADEPI / HINTER DER TÜR", "Hey Raven, ich bin hier. Ruhe dich aus, ich komme gleich.")
	if not cs.alive(ticket): return
	cs.do(func(): w.sanctuary_tableau.speech.hide())
	await cs.walk(w.raven, Vector2(492, 321), 55)
	if not cs.alive(ticket): return
	cs.face(w.raven, Vector2(399, 270))
	await cs.say("RAVEN", "Sogar eine alte Samurai-Rüstung … Du sammelst wohl alles.")
	if not cs.alive(ticket): return
	await cs.walk(w.raven, w.SanctuaryTableau.BEDSIDE, 55)
	if not cs.alive(ticket): return
	await cs.say("RAVEN", "Na gut. Dann mache ich kurz die Augen zu.")
	if not cs.alive(ticket): return
	cs.end(func(): sleep(w))

static func sleep(w) -> void:
	var cs = w.begin_cutscene()
	var ticket: int = cs.generation
	await cs.walk(w.raven, w.SanctuaryTableau.BEDSIDE, 55)
	if not cs.alive(ticket): return
	await cs.camera(Vector2(603, 273), 0.7, 2.15)
	if not cs.alive(ticket): return
	await cs.leap(w.raven, w.SanctuaryTableau.BEDSIDE + Vector2(0, -24), 18, 0.6)
	if not cs.alive(ticket): return
	cs.do(func():
		w.raven.hide()
		w.sanctuary_tableau.set_pose(3)
		w.sanctuary_tableau.sprite.show()
	)
	await cs.wait(1.5)
	if not cs.alive(ticket): return
	cs.do(func(): w.sanctuary_tableau.set_pose(4))
	await cs.wait(3.6)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK, 0.5)
	if not cs.alive(ticket): return
	await cs.title("ZWEI STUNDEN SPÄTER", "Das Summen hinter der Tür hält an", 2.2)
	if not cs.alive(ticket): return
	cs.do(func():
		w.sanctuary_stage = 1
		w.sanctuary_tableau.set_pose(5)
		w.autosave()
	)
	await cs.fade(Color.TRANSPARENT, 0.5)
	if not cs.alive(ticket): return
	await cs.wait(1.2)
	if not cs.alive(ticket): return
	cs.do(func():
		w.sanctuary_tableau.show_room(false)
		w.raven.position = w.SanctuaryTableau.BEDSIDE
		w.raven.show()
	)
	cs.pose(w.raven, "idle")
	await cs.say("RAVEN", "Zwei Stunden? Shadepi … bist du immer noch da drin?")
	if not cs.alive(ticket): return
	cs.face(w.raven, w.SanctuaryTableau.DOOR)
	cs.end(func(): w.toast("E / A an der Tür · Nach Shadepi sehen"))

static func enter_room(w) -> void:
	var cs = w.begin_cutscene()
	var ticket: int = cs.generation
	await cs.walk(w.raven, w.SanctuaryTableau.DOOR, 55)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK, 0.35)
	if not cs.alive(ticket): return
	cs.do(func():
		w.sanctuary_stage = 2
		w._set_sanctuary_room()
		w.raven.position = w.SanctuaryTableau.ENTRY
		w.autosave()
		w.sound("prop_metal")
	)
	await cs.camera(w.Painted.CHAMBER_CAMERA, 0.0, 1.15)
	if not cs.alive(ticket): return
	await cs.fade(Color.TRANSPARENT, 0.5)
	if not cs.alive(ticket): return
	await cs.walk(w.raven, Vector2(615, 351), 45)
	if not cs.alive(ticket): return
	cs.face(w.raven, w.SanctuaryTableau.SEAT)
	await cs.say("RAVEN", "Shadepi?")
	if not cs.alive(ticket): return
	await cs.wait(0.7)
	if not cs.alive(ticket): return
	cs.end(func(): w.toast("E / A am Kompensator · Vorsichtig nach ihm sehen"))

static func contact(w) -> void:
	var cs = w.begin_cutscene()
	var ticket: int = cs.generation
	cs.pose(w.raven, "idle")
	await cs.walk(w.raven, w.SanctuaryTableau.APPROACH, 38)
	if not cs.alive(ticket): return
	await cs.camera(Vector2(528, 296), 0.5, 2.1)
	if not cs.alive(ticket): return
	cs.face(w.raven, w.SanctuaryTableau.SEAT)
	await cs.say("RAVEN", "Schläfst du?")
	if not cs.alive(ticket): return
	await cs.wait(0.6)
	if not cs.alive(ticket): return
	await cs.say("RAVEN / LEISE", "Wer ist eigentlich unter der Maske?")
	if not cs.alive(ticket): return
	cs.do(func():
		w.raven.hide()
		w.sanctuary_tableau.set_pose(1)
	)
	await cs.wait(0.5)
	if not cs.alive(ticket): return
	cs.do(func(): w.sanctuary_tableau.set_pose(2))
	await cs.say("SHADEPI", "Mach das nicht.")
	if not cs.alive(ticket): return
	await cs.say("RAVEN / LACHT", "Hast du Angst vor einer Frau?")
	if not cs.alive(ticket): return
	await cs.say("SHADEPI", "Nein, ich glaube nur …")
	if not cs.alive(ticket): return
	cs.do(func(): w.sound("hack"))
	await cs.animate(func(k: float):
		if is_instance_valid(w.sanctuary_tableau): w.sanctuary_tableau.transfer_step(k)
	, 1.8)
	if not cs.alive(ticket): return
	await cs.fade(Color.WHITE, 0.3)
	if not cs.alive(ticket): return
	cs.end(func(): w._enter_echo())

static func memory_entry(w) -> void:
	var cs = w.begin_cutscene()
	var ticket: int = cs.generation
	cs.pose(w.raven, "idle")
	await cs.fade(Color.WHITE, 0.0)
	if not cs.alive(ticket): return
	await cs.fade(Color.TRANSPARENT, 0.7)
	if not cs.alive(ticket): return
	await cs.say("RAVEN", "Rauch … Explosionen … Schreie. Das ist nicht mehr das Versteck. Wo bin ich?")
	if not cs.alive(ticket): return
	cs.end(func(): w.toast("Erinnerungsanker suchen · E / A lässt dich hineinsehen"))

static func aftermath(w) -> void:
	var cs = w.begin_cutscene()
	var ticket: int = cs.generation
	await cs.fade(Color.WHITE, 0.25)
	if not cs.alive(ticket): return
	cs.do(func():
		w.echo_ready = false
		w.sanctuary_stage = 2
		w._set_sanctuary_room()
		w.raven.position = w.SanctuaryTableau.APPROACH
		w.raven.show()
		w.set_music_section("chapter_5_sanctuary")
	)
	await cs.camera(Vector2(539, 313), 0.0, 1.8)
	if not cs.alive(ticket): return
	await cs.fade(Color.TRANSPARENT, 0.5)
	if not cs.alive(ticket): return
	w.raven.show_reaction(3,"recover")
	await cs.wait(1.0)
	if not cs.alive(ticket):return
	w.raven.clear_reaction()
	await cs.walk(w.raven, Vector2(581, 359), 40)
	if not cs.alive(ticket): return
	cs.face(w.raven, w.SanctuaryTableau.SEAT)
	cs.pose(w.raven, "hurt")
	await cs.wait(0.5)
	if not cs.alive(ticket): return
	cs.pose(w.raven, "idle")
	await cs.say("RAVEN", "Was war das denn? Waren das deine Erinnerungen?")
	if not cs.alive(ticket): return
	await cs.say("SHADEPI", "Tut mir leid. Ich wollte dich noch warnen. Während der Eindämmung kann das passieren.")
	if not cs.alive(ticket): return
	await cs.say("RAVEN", "Eindämmung? Du sitzt seit Stunden hier. Was macht dieses Ding mit dir?")
	if not cs.alive(ticket): return
	await cs.say("SHADEPI", "Es ist ein Kompensator. Alle sechs Tage muss ich hierher. Sonst zerstören die Naniten meinen Körper.")
	if not cs.alive(ticket): return
	await cs.say("RAVEN", "Das weiße Licht … das kam von dem Heiligtum?")
	if not cs.alive(ticket): return
	await cs.say("SHADEPI", "Ja. Ich trage es, seit mein Meister es mir übergeben hat. Was du gesehen hast, war echt.")
	if not cs.alive(ticket): return
	await cs.say("RAVEN", "Und dieser Orden? Was ist mit der Anlage unter dem Tempel?")
	if not cs.alive(ticket): return
	await cs.say("SHADEPI", "Der Tempel war die Tarnung unserer Basis. Mehr kann ich dir darüber gerade nicht sagen. Das sind Geheimnisse des Ordens.")
	if not cs.alive(ticket): return
	# v0.47.0 · ClaudeHelper: Kodex (Roman, Kapitel 6) als Grund für den abgefangenen Griff;
	# die Aufnahme am See löst ihn später auf. Danach Zeitsprung zum Dienstagabend.
	await cs.say("RAVEN", "Und die Maske? Du hast mein Handgelenk gepackt, als ginge es um dein Leben.")
	if not cs.alive(ticket): return
	await cs.say("SHADEPI", "Mein Kodex verbietet es, mein Gesicht jemandem außerhalb des Ordens zu zeigen.")
	if not cs.alive(ticket): return
	await cs.say("RAVEN", "Dann sag mir wenigstens, ob ich mir Sorgen machen muss.")
	if not cs.alive(ticket): return
	await cs.say("SHADEPI", "Atme erst mal durch. Ich erkläre dir, worauf du achten musst. Langsam.")
	if not cs.alive(ticket): return
	await cs.say("SHADEPI", "Und dann schlaf. Morgen Abend ist Kenzō allein – und wir sind bereit.")
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK, 0.6)
	if not cs.alive(ticket): return
	cs.do(func(): w._advance())
