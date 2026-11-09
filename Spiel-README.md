# Shadepi · Echos in Neon

**Spieleranleitung für v0.41.0 · CodexAI.** Aktuelle Downloads: [Releases](https://github.com/Inrouder/ShadepiRPG/releases/latest) · Prüfstatus: [Repository-Startseite](README.md) · Änderungen: [Versionshinweise](CHANGELOG.md).

**Verfolger v0.41.0 · CodexAI:** Wagenlenkung, Federung und Geschütz zeigen eigene Bewegungsphasen; Frachtdrohnen haben laufende Rotoren. Feuer kommt aus dem Dachgeschütz, Minen aus dem Frachtkontakt. Q/RB hackt wie bisher den Wagen oder eine Drohne in Reichweite. Pause hält auch diese Animationen an. [Bilder und Film](docs/verfolger-animationen.md).

**Fahrzeugbewegung v0.40.0 · CodexAI:** Motorrad und Aerodyne zeigen jetzt eigene Kurvenbilder; das Motorrad zusätzlich Brems-/Federungsbewegung, der Aerodyne ausgeklappte Luftbremsflächen. A/D oder Stick lenkt, W/S oder Stick längs gibt Schub und bremst. Leertaste/B bleibt im Flug die Ausweichrolle, am Motorrad die Granate. Keine neue Belegung. [Bilder und Filme](docs/fahrzeugbewegung.md).

**Garage und Hangar v0.39.0 · CodexAI:** Nach dem Garagen-Decoder siehst du die Entriegelung und die gemeinsame Plattformfahrt mit dem Motorrad. Die Kamera zeigt den Hangar und den Aerodyne, bevor Raven reagiert. Danach reparierst du als Raven wie bisher das Fahrzeug und überträgst die Kennung. **E / Enter / A**: Dialog weiter; **Leertaste / B**: Szene überspringen; **Esc / Start**: Pause. Laden während der Fahrt beginnt den Übergang erneut; abgeschlossene Szenen werden nicht wiederholt. [Bilder und Film](docs/hangar-entdeckung.md).

**Eisbad v0.38.0 · CodexAI:** In Kapitel 2 siehst du Ravens Anschluss und Einstieg ins Wasser sowie ihre Rückkehr aus dem Netz. Danach holst du als Shadepi das Kryospray am Überwachungstisch (**E / Enter / A**) und gehst zu Raven zurück. Dort startet dieselbe Taste das Stützen und die Behandlung. **Leertaste / B** überspringt eine Szene, **Esc / Start** pausiert. Aufgenommenes Spray bleibt beim Laden erhalten; unterbrochene Anschluss-, Rückkehr- und Behandlungsszenen beginnen sicher erneut. [Bilder und Filme](docs/eisbad.md).

**Musik und Aerodyne v0.37.0 · CodexAI:** In ganz Kapitel 7 läuft nun `assets/music/menu.mp3`. Das Hauptmenü verwendet weiterhin `Level.mp3`. Der Aerodyne besitzt zusätzliche Bilder für Kabinenöffnung, Schließen und die laufende Triebwerksmechanik. Öffnen und Schließen gehören zu Ein-/Aussteigen; die Bedienung bleibt erhalten. [Musikpfade](assets/music/README.md) · [Cinema-/Sprite-Roadmap](docs/cinema-roadmap.md).

**Handkorrektur v0.36.1 · CodexAI:** Raven hebt die Maske mit ihrer **rechten** Hand; ihre **linke** berührt und verdeckt Shadepis Gesicht. Diese Zuordnung gilt auch während des Kusses. Bedienung und Szenenablauf bleiben wie bisher. [Aktuelle Spielbilder](docs/see-finale.md).

**See-Finale v0.36.0 · CodexAI:** Kapitel 7 beginnt mit dem sichtbaren Landeanflug und Aussteigen am See. Danach führt der bisherige Weg ans Wasser und durch Ravens freiwillige Aufnahme in den Orden. Anschließend nimmt sie Shadepis Maske ab und küsst ihn; seine Gesichtszüge bleiben durch ihre Hand und den Kasa verdeckt. Der kurze Drachenschatten und das Leuchten sind Teil der Szene. **E / Enter / A**: Dialog weiter; **Leertaste / B**: Szene überspringen; **Esc / Start**: Pause. Laden während der Ankunft oder des Finales startet nur diese Szene neu; abgeschlossene neue Szenen werden nicht wiederholt. Ältere Spielstände am Kapitelanfang oder Ende erhalten die jeweilige neue Szene einmal. Die vorhandene Seemusik bleibt erhalten. [Bilder und Film](docs/see-finale.md).

**Szenen v0.35.1 · CodexAI:** Im Penthouse läuft Raven vom Eingang zu Kenzō, der bereits neben dem Sessel wartet. Erst nach dem Griff läuft Shadepi dazu. Die Flucht startet auf dem Tower-Landeplatz: Beide steigen in den dort geparkten Aerodyne, heben ab und verlieren Schub. In der folgenden Fassadenansicht rauscht das Schiff von oben am Balkon vorbei und fängt sich darunter. Im Hangar laufen beide über den freien Gang um die Geräte und steigen nacheinander ein. **E / Enter / A** blättert Dialoge weiter, **Leertaste / B** überspringt die Szene und **Esc / Start** pausiert wie bisher. Speichern/Laden während des Abflugs beginnt am Anfang der Abflugsequenz; der Abstellpunkt bleibt erhalten. [Bilder und Film](docs/tower-inszenierung.md).

**Anzeige v0.34.0 · CodexAI:** Das Spiel startet beim ersten Mal im **Fenstervollbild**. Im Haupt- oder Pausenmenü öffnet **Anzeige** die Bildschirmoptionen. Wähle **Fenster**, **Fenstervollbild** (randlos auf dem Desktop) oder **Vollbild**. **F11 / Alt+Enter** wechselt zwischen Fenster und dem zuletzt gewählten Vollbildmodus. Im Fenster kannst du 720p, 900p, 1080p, 1440p oder 4K auswählen; zu große Fenster werden passend verkleinert. Vollbild nutzt die Auflösung deines Desktops, also auch 1920×1080, 2560×1440 oder 3840×2160. **Bildschirmfüllend** vergrößert das gesamte 16:9-Spielbild passend; **Pixelgenau** verwendet ganze Stufen und kann mehr Rand lassen. Auf anderen Bildschirmformaten bleiben Ränder, ohne das Bild zu verzerren. Controller: **Stick / Kreuz** wählen, **A** öffnen/bestätigen, **B** zuerst Auswahlliste, danach Optionen schließen. **Esc** verhält sich entsprechend. Änderungen werden sofort für kommende Starts gespeichert. Die Gameplay-Pixelbasis bleibt 640×360, das HQ-Hauptmenü wird in Fensterauflösung gezeichnet. [Bilder und Details](docs/bildschirm.md).

**Tower v0.33.0 · CodexAI:** Nach Kenzōs Niederlage schützt du Raven bei der Datenextraktion vor drei Wachwellen. Sie bleibt am Deck und kann in dieser Zeit keine Wachensysteme hacken. **Drei Treffer auf Raven** unterbrechen die Verbindung: Du wiederholst nur den Extraktionsabschnitt, nicht den Bosskampf. Die Anzeige nennt Fortschritt und Treffer. **J / X**: Katana, **L / LT**: Kick, **K / RT halten und loslassen**: Kraftschlag, **Leertaste / B**: Ausweichen; **Esc / Start** pausiert. Erst nach gesicherten Daten folgt Ravens endgültige Abrechnung. Danach bleiben 60 Sekunden für Aufzugssperre, Fernstart und Dachausgang; Rennen, Einsteigen und knapper Abflug werden sichtbar inszeniert.

**Gesamtspiel-Stilbibel v0.32.2 · CodexAI:** Die [bebilderte Referenz für alle Bereiche](docs/stilbibel/README.md) zeigt jetzt jede der 23 vorhandenen Figuren-/Gegnerarten, Kulissen, Fahrzeuge, Objekte, UI und Effekte. Sie dient Mitwirkenden als gemeinsamer Gestaltungsstandard; diese Dokumentation verändert die Spielbedienung nicht.

**Projektstandard v0.32.1 · CodexAI:** Für Mitwirkende gibt es jetzt eine [verbindliche Konsistenzvorlage](KONSISTENZ.md) mit aktiven Grafikreferenzen und Prüfnachweisen. Diese Version ergänzt die Projektdokumentation; die Bedienung bleibt unverändert.

**Heiligtum-Figuren v0.32.0 · CodexAI:** Ravens Einschlafen, Liegen und Aufwachen sowie Shadepis Sitz- und Handgriffposen verwenden grafisch an die normalen Spielfiguren angeglichene Pixelgrafiken. Ihre Größe und Standflächen bleiben beim Wechsel stimmig. Ablauf und Bedienung bleiben wie unten beschrieben. [Bildvergleich](docs/heiligtum-figuren-v032.md).

**Atmosphäre v0.31.0 · CodexAI:** Unter „Bildstil“ steuert **Atmosphärisch** die volle neue Umgebungsdichte; **Ausgewogen** reduziert Partikel und Wasserbewegung. **Reduziert** schaltet die neuen Zusatzpartikel und den Wasser-Zusatzpass ab; vorhandene Regen- und Kampfindikatoren bleiben erhalten. Pause und offene Hack-Terminals halten die Umgebungsbewegung an. [Film und Designbericht](docs/design-atmosphaere.md).

**Heiligtum und Abflug v0.30.0 · CodexAI:** Raven kommt nach der Aerodyne-Reparatur allein im Versteck an und legt sich nach dem Gespräch automatisch schlafen. Nach „Zwei Stunden später“ gehst du zur beleuchteten Tür und drückst **E / A**. Im Kompensatorraum vorsichtig an den Sessel treten und erneut **E / A** drücken. Nach den drei Erinnerungen kehrt Raven zurück; danach zeigt das Spiel das Einsteigen, den missglückten Start und den Abflug aus dem Hangar. Erst draußen beginnt die Flugsteuerung. **E / A**: Dialog weiter; **Leertaste / B**: Szene überspringen; **Esc / Start**: Pause. Speichern während des Abflugs setzt beim Laden sicher am Beginn dieser Szene fort. [Korrekturen und Bilder](docs/fehlerbericht-8.md).

**Erinnerungseffekte v0.28.0 · CodexAI:** Der Meister stirbt nach der Übertragung des Heiligtums. Shadepi erhält dabei eine goldweiße Energieaura mit aufsteigenden Flammen und Blitzen, die ihn im Kampf begleitet und beim Zusammenbruch erlischt. „Bildstil → Reduziert“ lässt die Aura bestehen, reduziert aber Blitzakzente und Animationsfrequenz. Pause hält auch die Aura und den Energieton an; Ton aus schaltet ihn ab. [Vorschau](docs/das-vermaechtnis.md).

**Erinnerung III v0.27.0 · CodexAI:** Am dritten Knoten startet „Das Vermächtnis“ im Tempelinneren über der verborgenen Hightech-Basis. Nach der Übergabe brechen die beiden Minotauren durch das Tor ein. Nach dem Versprechen und der Heiligtumsübergabe kämpfst du als Shadepi gegen zwei Minotauren. **WASD / Pfeile / Stick / Steuerkreuz** bewegt, **J / X / linke Maustaste** schlägt zu, **Leertaste / B** weicht aus. Triff die Servogelenke in Nahkampfreichweite und verlasse die angekündigten Einschlagsflächen. Beide Gegner müssen zerstört werden. Nach Niederlage startet **E / Enter / A** nur den Kampf neu. **Esc / Start** pausiert; dort lässt sich die Erinnerung bewusst überspringen oder ohne Abschluss verlassen. In Dialogen gilt E / Enter / A für Weiter und Leertaste / B für Überspringen. Nach dem Sieg folgt Shadepis Zusammenbruch. [Bilder und Ablauf](docs/das-vermaechtnis.md).

**Erinnerung II v0.25.0 · CodexAI:** Am zweiten Erinnerungsknoten startet „Lys Opfer“. Nach dem Auftakt steuerst du Shadepi **45 Sekunden** gegen den Minotaurus: **WASD / Pfeile / linker Stick / Steuerkreuz** bewegen, **J / linke Maustaste / X** schlägt mit dem Katana zu, **Leertaste / B** weicht in Bewegungs- oder Blickrichtung aus. Vier Treffer bringen den gepanzerten Gegner kurz ins Taumeln. Die roten Einschlagmarkierungen fixieren die Ziele vor dem Schuss; laufe aus ihnen heraus oder weiche im richtigen Moment aus. Das Sperrfeuer wird nach 15 und 30 Sekunden stärker. Bei Niederlage startet **E / Enter / A** den Kampf erneut. Bei Timerende folgt Lys Opferszene. **Esc / Start** pausiert; dort kannst du die gesamte Erinnerung bewusst überspringen oder ohne Abschluss verlassen. Außerhalb des Kampfes schaltet **E / Enter / A** Dialoge weiter und **Leertaste / B** überspringt die Szene. [Bilder und Hinweise](docs/lys-opfer.md).

**Erinnerung v0.23.0 · CodexAI:** Am ersten Erinnerungsknoten startet „Der Angriff“ auf Shadepis Kloster. **E / Enter / A** blättert Dialoge weiter; **Leertaste / B** überspringt bewusst die Szene. **Esc / Start** pausiert: Fortsetzen, Szene überspringen oder Erinnerung abbrechen. Im Pausenmenü mit Steuerkreuz / linkem Stick oder Pfeiltasten wählen und mit A / Enter bestätigen. Abbrechen führt ohne Abschluss zum selben Knoten zurück; Ende und Überspringen speichern den Fortschritt. Die Szene zeigt jetzt drei inszenierte Bot-Wellen und die Schutzopfer von Oni und MG-Krieger; Mönche und Bewohner besitzen eine vierteilige Schrittfolge in jeder Laufrichtung. [Bilder und Umfang](docs/kloster-kampf.md).

**Aerodyne-Flug v0.21.3 · ClaudeHelper:** In Kapitel 6 steuerst du den Aerodyne frei durch die Häuserschluchten (A/D, W/S für Schub und Bremse). **Leertaste / B** rollt seitlich weg – schmal genug für gelb blinkende enge Brückenlücken und kurz unverwundbar gegen Drohnen und Laser. Rote Linien zeigen, wo die Turmabwehr gleich feuert. Am Tower-Scanner folgt die **Sequenzkalibrierung**: Sobald der Strahl auf dem Aerodyne liegt („JETZT“, Ring um den Rumpf), die angezeigte Richtung drücken. Drei Abweichungen lösen Alarm aus, danach scannt der Tower erneut. Zum Schluss beim Signal die Driftkurve fliegen, den Schatten in den Landering bringen und mit **J / X** die Bremsdüsen halten. [Ablauf mit Bildern](docs/aerodyne-flug.md).

**Kampfupdate v0.21.0 · CodexAI:** Im Deep Dive schleudert Raven Blitze aus der offenen Hand. Außerhalb nutzt sie ihre Pistole mit eigenem Schussgeräusch. J / X bzw. Maustaste und die bisherigen Ladetasten bleiben gültig. Gegner holen sichtbar aus, treffen und nehmen die Waffe zurück; Treffer und Tod erhalten unterschiedliche Laute. Die Tonoption schaltet auch diese Stimmen aus. [Vorschau und Hörprobe](docs/raven-gegner-kampf.md).

**Menüs und Terminals v0.20.5 · ClaudeHelper:** Haupt- und Pausenmenü sowie Ravens Hack-Decks sind jetzt echte Pixelart im Spielraster: genietete Stahlrahmen mit Neonkanten, Pixel-Buttons und eine Pixelschrift. Jedes Terminal trägt die Farben und das Emblem des gehackten Systems (Chrome Jackals, Orden des Weißen Drachen, ARToS-7, Moriyama-Tower); das Pausenmenü passt sich dem Kapitel an. Der hervorgehobene Knopf zeigt einen Pfeil rechts; bei den Codezellen markieren helle Ecken den Cursor, verbrauchte Felder werden dunkel. [Übersicht](docs/pixel-ui.md).

**Hauptscreen v0.20.3 · CodexAI:** Das Menü zeigt die HQ-Figuren im gemalten Stil der Spielwelt, mit animiertem Regen, Nebel, Neonlicht und Wasserreflexen. Maus und Controller bedienen die Knöpfe; die Figuren bleiben auf der Plattform stehen. Unter **Bildstil → Reduziert** werden Wind, zusätzliche Filter und Menülichtanimation abgeschaltet. Das Spiel selbst behält seine ursprüngliche Darstellung.

**Aktualisierung v0.20.1 · CodexAI:** Enthält zusätzlich den GitHub-Entwicklungsstand v0.20.0 mit verbessertem Kampfgefühl, passendem Apartmentmaßstab, erweiterter Verfolgungsjagd und Garageneinfahrt. [Verfolgungsjagd](docs/verfolgungsjagd.md) · [Kampfgefühl](docs/kampf-feedback.md).

**Hack-Update v0.18.3 · CodexAI:** Im Terminal navigierst du mit Steuerkreuz oder linkem Stick. **A** wählt ein Feld, dreht eine Leitung oder betätigt einen Knopf. Bei Reglern und Steckplätzen ändert **Links/Rechts** den Wert; **LB/RB** wechselt durch alle verfügbaren Elemente einschließlich der Knöpfe unten. **Y / F1** öffnet die Schritt-für-Schritt-Hilfe und hält das Rätsel an. **B / Esc** schließt zuerst die Hilfe, sonst das Terminal. **Start / P** pausiert. Nach Erfolg **Übernehmen** bestätigen. [Alle Aufgaben mit Bildern](docs/ravens-terminals.md).

**Menüupdate v0.18.2 · CodexAI:** Shadepi und Raven stehen passend skaliert auf der vorderen Plattform. Ravens Haarspitzen und Shadepis Umhangränder bewegen sich sanft im Wind; Körper und Füße bleiben fest. Der Bildstil „Reduziert“ schaltet den Figurenwind ab. Im Hauptmenü läuft die Musik vom Finale am See.

**Kapitel und Kontrollpunkte:** Mit „Weiter zu Kapitel …“ beginnt das folgende Kapitel am Anfang. Die Menüoption „Fortsetzen“ lädt dessen vorhandenen Kontrollpunkt. Kapitel 2 verläuft über Industriegebiet → Versteck → Kühlsystem → Deep Dive → Kryospray → Abschluss. Danach folgen Pakt, Hinterhalt und Verfolgung (3), Garage und Hangar (4), Heiligtum und Erinnerungen (5), Anflug, Dach, Kenzō und Flucht (6), See und Aufnahme in den Orden (7).

**Zwischensequenzen:** Die Story läuft in inszenierten Szenen mit Kinobalken. E / Enter / A blättert weiter, Leertaste / B überspringt die Szene.

**Flucht:** Nach Kenzōs Fall und den Aufzugwachen: Daten sichern, Aufzug blockieren, Treibstoffpumpe fernstarten, Dachausgang erreichen. Die sechzig Sekunden laufen während des Spielens; Dialoge und Pause halten den Timer an. Lange Dialoge besitzen mehrere Seiten, die vollständig mit E / Enter / A weitergeschaltet werden.

**Kapitel 1 · Echos in Neon und Schatten** ist der spielbare Auftakt zu „Shadepi – Im Schatten des Raben“.

Raven bekommt in ihrem Apartment einen Hinweis auf Chrome Jackal, räumt die Punks in Bingo Street aus dem Weg und verfolgt ihn bis zum Wartungshof. Dort hält seine Panzerung jedem Treffer stand. Nach 30 Kampfsekunden dreht er Ravens Hack gegen sie. Shadepi kämpft sich durch die Wartungsgasse und stellt Jackal mit 360 HP. Sobald die Hälfte seiner Lebenspunkte weg ist, steht Raven auf und steigt in den Kampf ein.

**Gegnerwellen:** Die Jagd, der Rettungsweg, der Hinterhalt und der Towerkampf sind in gesperrte Kampfabschnitte aufgeteilt. Besiege alle Wellen, bis „WEITER →“ erscheint. Zwischen Wellen hast du zwei Sekunden Pause. Ein geschaffter Abschnitt gibt bis zu 15 Lebenspunkte und 20 Energie zurück. Am nächsten Abschnitt wird automatisch gespeichert; nach einer Niederlage beginnt dessen erste Welle erneut. [Alle Abschnitte und Gegnerzahlen](docs/arcade-wellen.md).

**Neue Kampfbewegungen:** Halte **K / RT**, bis nach 1,1 Sekunden der kurze Wellenring „bereit“ signalisiert. Loslassen sendet Shadepis Katana-Welle oder Ravens Kraftschuss aus. Im Koop lädt Raven mit **I / RT** an ihrem Controller. **L / LT** führt Shadepis Kick aus. Frühes Loslassen ergibt einen normalen Angriff; Treffer, Ausweichen und Pausen brechen das Laden ab. [Details und animierte Vorschau](docs/kampfbewegungen.md).

Seit v0.18.0 laufen alle Zwischenszenen im Spiel selbst – mit Kamerafahrten, Figurenbewegung und Untertiteln nach der Romanfassung „Shadepi im Schatten des Raben“. [Übersicht der Szenen](docs/zwischensequenzen.md).

## Verstecktes Test-/Admin-Menü

Im Haupt- oder Pausenmenü **Strg + Umschalt + F10** drücken oder fünfmal auf die Überschrift klicken. Alle Kapitel freischalten und Kapitel 1–7 direkt starten; zusätzlich unendlich Leben/Energie, One-Hit-K.O., keine Abklingzeiten und ein Fluchttimer-Stopp. Im Testmenü können aktuelle Gegner besiegt oder Figuren geheilt werden. Das erste Jackal-Duell ist weiterhin ein geskriptetes Storyereignis. Test-Kontrollpunkte bleiben von normalen Spielständen getrennt. [Weitere Details](docs/admin-testmodus.md).

## Illustrierte Helden in v0.12.0

Raven und Shadepi verwenden neue, transparent freigestellte Figurenbilder im Stil der gemalten Kulissen. Raven trägt detaillierte schwarze Rüstung mit cyanfarbenen Leuchtlinien und blauen Haarakzenten. Shadepi hat einen breiten Kasa-Hut, rote Augen hinter der Maske, einen Mantel mit Drachenemblem und ein rotes Katana.

Beide Figuren behalten acht Blickrichtungen. Die Lauf- und Angriffsanimationen sind aus jeweils 32 generierten Schlüsselposen zusammengestellt; Stand und Treffer nutzen die Ruhepose. Die Spielatlanten in `assets/sprites/heroes/` sind 1024 × 5120 Pixel groß, mit 128 × 160 Pixeln pro Einzelbild. Ihre Darstellung wird auf die bisherige Figurengröße abgestimmt. Fußpunkte, Drehungen, Schatten und Tarnung berücksichtigen das neue Format.

Die Originalposen liegen in `tools/hero_sources/`. Mit Pillow und `python tools/compile_heroes.py` werden sie ohne erneute Bildgenerierung in die Spielatlanten gepackt. Eigene Figuren unter `assets/custom/` haben weiterhin Vorrang; auch die bisherigen Formate bleiben unterstützt.

## Bildkulissen in v0.11.0

Alle Schauplätze verwenden ausgearbeitete, eigens generierte Hintergrundbilder. Die 16 Bilddateien umfassen Apartment, Bingo Street, Wartungshof, Industriegebiet, Ravens Versteck, Deep Dive, Hinterhalt, Garage, Sanktuarium, Wohnraum, Erinnerungsraum, Landedach, Penthouse, See sowie die Straße und die Häuserschlucht der Fahrzeugsequenzen.

Die Hintergrundbilder stehen in `assets/world/painted/`. Die Wandkollisionen, festen Einbauten und Vordergrundausschnitte sind in `scripts/painted_world.gd` auf diese Bilder abgestimmt. Die Ausschnitte verwenden dieselben Bildpixel und lassen Figuren hinter Mauern verschwinden. Zerstörbare Gegenstände werden als eigene Objekte darüber dargestellt.

Die 16 gemalten Kulissen liegen direkt in `assets/world/painted/`; ihre Zuordnung und die darauf abgestimmten Hindernisse stehen in `scripts/painted_world.gd`. Ein Generator für diese gemalten Bilder liegt nicht im Repository.

## Zerstörbare Gegenstände in v0.10.0

Die Gassen, das Industriegebiet, das Versteck, die Garage, der Hangar und der Tower sind mit zusätzlichen Gegenständen ausgestattet. Dazu gehören Frachtkisten, Straßenlaternen, geparkte Wagen, Müllcontainer, Brennstofffässer, Schaltkästen, Getränkeautomaten und Serverschränke. Im Deep Dive gibt es zerstörbare Datenkristalle.

**J / X** greift mit der aktiven Figur an. Shadepis Katana trifft auch die Kante großer Gegenstände. Ravens Schüsse treffen zuerst die Deckung vor einem Gegner. Beschädigte Gegenstände erhalten sichtbare Risse und Dellen. Zerstörte Objekte hinterlassen begehbare Trümmer oder Wracks. Lampen gehen aus, Metallteile sprühen Funken und Fässer explodieren und können benachbarte Gegenstände zerstören. Auch gegnerische Angriffe beschädigen die Deckung.

**F5 / LB** speichert die Schäden zusammen mit dem Kapitelkontrollpunkt. Solo und Koop behalten ihre getrennten Zustände. Im Penthouse bleiben die Schäden während der anschließenden Flucht sichtbar.

Lichttextur und Basissounds lassen sich mit `npm ci` und `npm run assets` neu erzeugen. Der Generator verändert **keine** Charakter-Sprites, gemalten Level oder das App-Symbol. Vor Änderungen an Requisiten/Geräuschen die vorhandenen Dateien sichern. Die Platzierungen stehen in `scripts/world_dressing.gd`.

## Comicgestaltung in v0.9.0 (bis v0.17.0)

Die Bildregie orientierte sich an der deutschen Comicfassung. Bis v0.17.0 nutzten Zwischenszenen einen gemeinsamen Panelrahmen; seit v0.18.0 sind sie durch Szenen im Spiel ersetzt. Die Bilder liegen weiterhin unter `assets/comic/`.

| Kapitel | PDF-Seiten | Motive im Spiel |
| --- | --- | --- |
| 1 | 2–9 | Kaltes Monitorlicht im Apartment, Neonreklame und Reflexe in den Gassen |
| 2 | 10–16 | Totenkopf am Versteck, Kühlbad, magentafarbene Netzflächen und rote ICE-Scanlinie |
| 3 | 17–28 | Blaue Hinterhaltgasse mit Einschlägen und kupferrotes Motorrad vor dem dunklen Verfolgerwagen |
| 4 | 29–34 | Verdeckte Absenkplattform und grüner Zylinder im Sanktuarium |
| 5 | 35–42 | Blaues Licht am Bett und unterscheidbare Echos von Kloster, Trägern und Angriff |
| 6 | 43–53 | Aerodyne mit orangefarbenen Triebwerken, grünes Zeichen am Dach und Kenzōs cyanfarbene Implantate |
| 7 | 54–55 | Waldlichter am See und rote sowie cyanfarbene Lichtspuren beim Abschluss |

Die tatsächlich verwendeten Levelbilder liegen in `assets/world/painted/`. Nicht mehr benutzte prozedurale Vorlagen aus `assets/world/levels/` gehören nicht länger zum Quellstand. Zum Anpassen der Spielwelt die jeweilige gemalte Kulisse und ihre Kollisionen in `scripts/painted_world.gd` gemeinsam bearbeiten.

## Spielen

1. Unter [Actions](https://github.com/Inrouder/ShadepiRPG/actions/workflows/build.yml) den letzten erfolgreichen Lauf öffnen.
2. **ShadepiRPG-Windows** herunterladen, ZIP vollständig entpacken und `Shadepi-Echos-in-Neon.exe` starten. Eine Godot-Installation wird zum Spielen nicht benötigt.
3. Im Startmenü **Einzelspieler** oder **Lokal-Koop** wählen und starten. Das Missionsziel steht oben rechts. Mit **E**, **Enter** oder **A** geht es in den Zwischenszenen weiter.

Ein Linux-Build und das vollständige Godot-Projekt werden ebenfalls als Artefakte erzeugt. Bei späteren Versions-Tags veröffentlicht der Workflow zusätzlich Windows-ZIP und Projekt-ZIP im Bereich [Releases](https://github.com/Inrouder/ShadepiRPG/releases).

## Lokal-Koop

Im Start- oder Pausenmenü über **Modus** den **Lokal-Koop** auswählen. Ravens Jagd und Shadepis Rettung spielt ihr nacheinander mit der Hauptsteuerung. Sobald Shadepi Jackal auf 180 HP gebracht hat, übernimmt im Lokal-Koop die zweite Person Raven. Im Einzelspieler folgt Raven und feuert auf Jackal, sobald sie freie Sicht hat. Ihr könnt eine Tastatur, zwei Controller oder eine Tastatur zusammen mit einem Controller nutzen. Beide Figuren sind auf einem Bildschirm zu sehen. Die Kamera folgt eurem Mittelpunkt. Wenn ihr euch zu weit voneinander entfernt, geht ihr wieder aufeinander zu.

| Aktion | Shadepi | Raven |
| --- | --- | --- |
| Bewegen | WASD | Pfeiltasten |
| Angriff | J oder linke Maustaste für das Katana | U für einen Impulsschuss in Blickrichtung |
| Aufgeladener Angriff | K halten und nach dem Bereitschaftsimpuls loslassen | I halten und nach dem Bereitschaftsimpuls loslassen |
| Kick | L | – |
| Ausweichen | Leertaste oder Umschalt | P |
| Spezialfähigkeit | C für Tarnung | O für einen Hack aus Ravens Reichweite |
| Interagieren | E | Enter |

Jede Figur hat eigene Lebenspunkte und Energie. Wenn eine Figur besiegt wird, setzt ihr den Kampf gemeinsam am Kontrollpunkt fort. **F5** und **F9** speichern und laden den aktiven Modus. Solo und Koop haben getrennte Spielstände.

Raven zielt mit der Maus und schießt im Solo mit Linksklick, im lokalen Koop mit Rechtsklick. Auf dem Controller zielt sie mit dem rechten Stick und feuert mit X. J beziehungsweise U feuert in Blickrichtung.

[Kapitelbilder, Level und Figuren bearbeiten](docs/figuren-bearbeiten.md)

## Kapitel 2 · Offenbarungen im Verborgenen

Nach Kapitel 1 führt **E / A** direkt ins Industriegebiet. Nach dem ersten Abschluss ist Kapitel 2 auch aus dem Menü erreichbar. Scanne das Gelände, zeige Raven das Fragment und schließe das Kühlsystem an. Im Deep Dive bestätigt Raven die Seriennummer per Timing-Hack, bekämpft zwei Viruswellen und hält die Verbindung beim letzten Knoten. J / X feuert Impulse, Q / RB stört die Pfosten am ICE-Wächter. Nach dem Abbruch holt Shadepi das Kryospray. Kapitel 2 wechselt erzählerisch zwischen Shadepi und Raven und hat einen eigenen Kontrollpunkt.

## Kapitel 3–7 · Der Pakt bis Der neue Orden

Mit **E / A** nach Kapitel 2 startet die restliche Kampagne. Der Kontrollpunkt liegt in einem eigenen Spielstand. Die Geschichte führt vom Hinterhalt über Shadepis Sanktuarium bis zum Penthouse im Arasaka-Tower und zum Ordensritual am See.

- **Motorrad:** A/D, Pfeiltasten oder Stick wechseln die Spur. J/X feuert, Q/RB hackt den Wagen, Leertaste/B wirft eine Granate. Der Wagen bleibt hinter dem Motorrad. Feuer und Granaten gehen nach hinten. Weiche dem Verkehr vor dir und den Schüssen sowie Rammversuchen des Wagens aus. Für den Hack musst du auf seiner Spur sein.
- **Sanktuarium:** Fahre gemeinsam mit Raven auf der Plattform hinab. Schalte Strom, Gleiterkennung und Transponder frei und prüfe die Ports 2, 1 und 3 bei Cyan.
- **Heiligtum:** Starte die Timing-Runde mit J/X im Solo oder Leertaste/B zu zweit. Shadepi tippt mit J, Raven mit U. Mit zwei Controllern nutzen beide X. Anschließend ordnet Raven die drei Erinnerungsanker.
- **Aerodyne:** Wechsle beim Tower-Anflug die Flugspur und sende die Kennung mit Q/RB, sobald der Scanner in Reichweite ist.
- **Kampf und Flucht:** Q/RB stört gegnerische Implantate. Kenzō kämpft im Penthouse allein. Erst nach seinem Tod ruft sein Totmannschalter die Aufzugwachen (drei Wellen); danach startet der Fluchttimer. Sichere anschließend die Daten, blockiere den Aufzug, starte die Pumpe neu und erreiche den Aerodyne vor Ablauf von 60 Sekunden.

Die Geschichte bleibt im Spiel vollständig bis zum Ende am See. Die Geschichte wechselt zwischen den Figuren an der Hauptsteuerung. Kapitel 5 bietet zusätzlich ein lokales Timing-Duell. Der Kapiteltext, die Comiczuordnungen und die Missionsziele stehen in `scripts/campaign_story.gd`.

## Controller

Vor dem gemeinsamen Kampf steuert der erste Controller die jeweils aktive Figur. Im Einzelspieler bleibt diese Zuordnung auch im Finale erhalten. Im Koop steuern zwei verbundene Controller Shadepi und Raven in der Reihenfolge ihrer Gerätezuordnung. Bei einem Controller übernimmt er Raven und Shadepi wird mit WASD gespielt.

| Aktion | Controller (Xbox-Tasten) |
| --- | --- |
| Bewegen / Menüauswahl | Linker Stick oder Steuerkreuz |
| Angriff | X für Katana oder Impulsschuss |
| Ausweichen | B |
| Spezialfähigkeit | Y für Shadepis Tarnung oder Ravens Hack |
| Ravens Hilfe im Einzelspieler | RB für Hack |
| Interagieren / Dialog weiter / Menü bestätigen | A |
| Pause / Fortsetzen | Start |
| Speichern | LB |

## Steuerung im Einzelspieler

| Taste | Aktion |
| --- | --- |
| WASD / Pfeiltasten | Bewegen; Bewegungsrichtung bestimmt die Blickrichtung |
| J | Impulsschuss als Raven, Katana als Shadepi |
| Linke Maustaste | Katana in Richtung des Mauszeigers |
| Leertaste / Umschalt | Ausweichen mit kurzem Schutzfenster |
| E / Enter | Sprechen, Terminal bedienen, Dialog weiterführen |
| C | Tarnfeld aktivieren oder beenden |
| Q | Raven stört Chrome Jackals Implantate |
| F5 / F9 | Speichern / Laden |
| Esc / H | Pause und Hilfe |
| M | Musik und Effekte umschalten |
| V | Bildstil wechseln: Atmosphärisch, Reduziert, Ausgewogen |

**Kampftipp:** Der rote Bogen kündigt Jackals Vorstoß an. Seitlich ausweichen, dann zuschlagen. Ravens Hack unterbricht den Angriff und schwächt die Panzerung für sechs Sekunden. Angreifen beendet die Tarnung. Energie regeneriert sich automatisch, während das Tarnfeld ausgeschaltet ist.

## Was enthalten ist

- Eigene PNG-Spritesheets mit acht Bildern je Zyklus: Stand, Laufbewegung, Katanahieb und Trefferpose; acht Blickrichtungen für Shadepi und Raven, vier für Jackal. Beim Laufen wechseln Shadepi und Raven über diagonale Zwischenposen zur neuen Richtung.
- Begehbare Gasse mit Gebäudekollisionen, Hindernissen, Sicherheitsschleuse und markierter Jagdroute.
- Gegner mit angekündigtem Angriff, Vorstoß, Erholungsphase und hackbarer Panzerung.
- Katana-Kombination, Energie, Ausweichen, zehn Sekunden maximales Tarnfenster und Fähigkeitencooldowns.
- Comic-Zwischenszenen, zwei Kämpfe gegen Jackal, vier animierte Punk-Varianten, eine Rettung mit drei Gegnerwellen und separate Kapitel-Kontrollpunkte für Solo und Koop.
- Geworfene Schatten, Neonhalos, nasse Spiegelungen, Schritte im Regen, Dampf, Hackentladungen und ein dezenter Farb- und Lichtfilter. Die drei Bildstile sind im Menü und mit **V** umschaltbar; die Einstellung bleibt beim Neustart erhalten.
- Eigens synthetisierte elektronische Hintergrundmusik und Kampf-/Hackeffekte.

## Godot-Projekt öffnen

Verwendete und geprüfte Version: **Godot 4.7.2 Standard**, Renderer **Compatibility**, kein C# erforderlich.

Repository herunterladen oder klonen, `project.godot` importieren, Ressourcenimport abwarten und **F5** drücken. Die Darstellung rechnet mit 640 × 360 Pixeln und ganzzahliger Skalierung; das Fenster startet mit 1280 × 720 Pixeln.

## Tests und eigene Builds

```bash
godot --headless --editor --import --quit
godot --headless --script res://tests/run.gd
godot --headless --script res://tests/drive_action.gd
godot --headless --script res://tests/painted_world.gd
mkdir -p build/windows build/linux
godot --headless --export-release "Windows Desktop" build/windows/Shadepi-Echos-in-Neon.exe
godot --headless --export-release Linux build/linux/Shadepi-Echos-in-Neon.x86_64
```

Zum Export müssen die offiziellen Exportvorlagen derselben Godot-Version installiert sein. Die GitHub Action richtet dies automatisch ein. Die Windows-EXE wird unter Linux exportiert; ihre Ausführung auf einem tatsächlichen Windows-PC ist ein gesonderter manueller Prüfschritt.

Die automatisierten Prüfungen behandeln den Kapitelfortschritt vom Apartment bis zum Finale sowie Bewegung und Gebäudekollision, Missionsfortschritt, Kampf, Tarnung, Spriteformate, Grafikprofile, gleichzeitige Eingaben für beide Figuren, Koop-Kampf, simulierte Controller-Eingaben, Laden beider Figuren sowie ungültige und beschädigte Spielstände einschließlich Backup-Wiederherstellung.

Kapitel-Kontrollpunkte liegen in `user://shadepi-chapter-one.cfg`. Beim Laden beginnt der gespeicherte Abschnitt von vorn. Die spätere Testszene nutzt Godots `user://shadepi-test-save.json` für Solo und `user://shadepi-coop-save.json` für Koop (unter Windows normalerweise `%APPDATA%/Godot/app_userdata/Shadepi - Echos in Neon/`). Bei beschädigter Hauptdatei wird ein validiertes Backup versucht. Beim Laden werden laufende Fähigkeiten zurückgesetzt und Jackal an seine Startposition gesetzt; sein gespeicherter Lebensstand bleibt erhalten.

## Grafiken und Audio weiterbearbeiten

Die Figuren sind als transparente PNGs enthalten. Kopiere die gewünschte Figur aus `assets/sprites/` nach `assets/custom/` und bearbeite die Kopie. Das Spiel lädt deine Variante automatisch. In der [Bearbeitungsanleitung](docs/figuren-bearbeiten.md) stehen Raster, Zeilenreihenfolge und Exportvorgaben.

Node.js wird nur für eine erneute Asset-Erzeugung benötigt:

```bash
npm ci
npm run assets
```

`tools/generate_assets.cjs` erzeugt nur noch kleine Hilfsgrafiken und Basissounds. Die Figuren nutzen die fertigen HQ-Atlanten unter `assets/sprites/heroes/` und `assets/sprites/npcs/`. Das Spiel läuft lokal, ohne Konten, KI-Dienste oder Onlinepflicht.

## Weiterentwicklung

Neue Änderungen auf dem vollständigen v0.12-Projekt aufbauen. Vor größeren Eingriffen einen Projektstand sichern und anschließend Import, Tests sowie einen Starttest durchführen. Aktuelle Hinweise stehen in der [README](README.md).


### Tower-Anflug und Fahrzeug-Action (v0.15.0)

Beim Anflug fällt nach etwa drei Sekunden das rechte Triebwerk aus. Ravens **Jumper-Wartungsdeck** öffnet sich: Pins nach Wartungslog verbinden, TX/RX kreuzen, Kette Alpha auf insgesamt 120 Ω bringen und die Verbindungen prüfen. Erst **Übernehmen** startet das Triebwerk. Nach Abbruch öffnet **J / X** die Konsole erneut; dafür bleiben 45 Sekunden außerhalb des Decks. **A/D bzw. linker Stick** gleichen währenddessen den seitlichen Drift aus. Konsole und Pause halten die Reparaturfrist an. Nach erfolgreichem Neustart im Scannerfenster **Q / RB** für die kopierte Kennung drücken.

Raven nutzt außerdem Matrix-Hacks, Passwort-Decoder, Schaltungsnetze und Signalabgleich für Türen, Jackals Tor, Hangar und die Sperrladung am Aufzug. **E / A** öffnet das Terminal; **Tab / Pfeile / Steuerkreuz** wählt, **Enter / A** bestätigt, **Esc / B** bricht ab. **P / Start** pausiert. Fehlversuche lassen sich direkt wiederholen. [Alle Rätsel mit Bildern und Regeln](docs/ravens-terminals.md).

In der Motorradverfolgung schießt Raven nach hinten: **J / X** halten, **Q / RB** hackt auf der Spur des Verfolgers, **Leertaste / B** wirft eine Granate. Der Wagen wechselt seine Spur jetzt weich. Warnlinien kündigen Rammangriffe an. Treffer und Hindernisse versetzen das Motorrad seitlich; Rauch zeigt den beschädigten Verfolger. Seine letzte Explosion bleibt kurz sichtbar, bevor es in der Garage weitergeht.
