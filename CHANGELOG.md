# Versionshinweise

## v0.19.0 – ClaudeHelper: Kampfgefühl, Deep Dive, Apartment · 7. November 2026

- Trefferrückmeldung: Trefferstopp, Rückstoß/Zucken (Bosse nur bei schweren Treffern), Kamerastoß, Funken, neue Schadenszahlen, Kombozähler, K.O.-Fallanimation, roter Treffer-Blitz, Tonhöhenvariation.
- Shadepi: Ausfallschritt pro Hieb und Nahkampf-Zielhilfe. Raven: Zielkegel statt 8-Pixel-Linie.
- Deep Dive: ICE kollidiert mit Datenwänden, Schuss-Zielhilfe, „Schale knacken“ macht ICE sofort verwundbar.
- Ravens Apartment im Figurenmaßstab (16:10, Skalierung 0,46) mit eigener Kamera; Szene und Lichter angepasst.
- Kapitel 2: Storyschritte im Versteck behalten die Positionen (kein Zurückspringen zum Eingang).
- Unsicherer Cloak-Test stabilisiert; 13 neue Prüfungen; `tools/feedback_gallery.gd`.


## v0.18.0 – ClaudeHelper: Zwischensequenzen statt Comicseiten · 6. November 2026

- Alle Story-Dialoge in Kapitel 1, 2 und der Kampagne (3–7) sind jetzt inszenierte Szenen im Spiel; die Comic-Einblendungen der Dialoge entfallen (`comic_texture` liefert keine Bilder mehr, `Story.DIALOGUE`/`PANELS` entfernt).
- Texte folgen der Romanfassung „Shadepi im Schatten des Raben“ (Archiv Teil 4). Kenzōs Deck enthüllt nach seinem Tod, dass er das Massaker mit Militech-Minotauren inszeniert hat.
- Penthouse nach dem Roman: Kenzō im Sessel, „Lange nicht gesehen“, Raven wird quer durch den Raum geschleudert, das Tarnfeld fällt, erster Schlag in die Schulterservos.
- Kapitel-Titelkarten, Rückblende Shadepi über den Dächern, Explosion beim Abflug, Ritual und Maskenkodex mit Romantexten.
- Fehlerkorrekturen: Kampfhinweise (`combat_ready`) nur in Kampfphasen; Hinweistexte werden beim Szenen-/Kontrollpunktwechsel gelöscht; Zielmarker und Lebensbalken während Szenen ausgeblendet; Kapitel-1-Titel ergänzt.
- Cutscene-Werkzeuge: `lines`, `leap`, `play_lines`; `tools/cutscene_gallery.gd` rendert alle Szenen (Filter per Argument).
- Archiv Teil 4 mit sechs PDFs, Textkopien und bestätigten Storyfakten; AGENTS.md ergänzt.


## v0.17.0 – ClaudeHelper: Szenen und Kapitel-6-Fix · 6. November 2026

- **Fehlerkorrektur:** Die Aufzugwachen griffen bisher auf dem Dach *vor* Kenzōs Kampf an. Sie folgen jetzt seinem Tod (Totmannschalter) mit drei Wellen im Penthouse; der 60-Sekunden-Timer läuft erst danach. Speicherstand merkt sich den Zwischenstand, alte Stände am Dachkampf springen direkt zu Kenzō.
- **Zwischensequenz-System** (`scripts/cutscene.gd`): Kinobalken, Kamerafahrten mit Zoom, Laufwege, Untertitel mit Sprecherfarben, Blitz/Überblendung, Titelkarten, Dachsprung. E/A blättert weiter, Leertaste/B überspringt. Pause, Kontrollpunkt und Neustart brechen Szenen sauber ab.
- **Neue Szenen:** Jackals Auftritt, Shadepis Landung in der Wartungsgasse, Penthouse-Konfrontation mit Enttarnung, Kenzōs Ende durch Raven, Alarm und Aufzug, Ritual am See ohne Teleport, Finale mit Maskenkodex und Titelkarte.
- Kenzō erhält eine Boss-Anzeige; Lebensbalken werden in Zwischensequenzen ausgeblendet.
- „Orden des Weißen Drachen“ in Kapitel 2 korrigiert.
- Tests angepasst und erweitert (Reihenfolge Kenzō → Wachen, Timer, Laden während der Wachen); `tools/cutscene_gallery.gd` rendert alle Szenen.


## v0.16.0 – Ravens Terminals, Arcade-Kämpfe und Live-Menü · 6. November 2026

- Fünf interaktive Terminal-Rätseltypen an acht Storypunkten mit Eingaben per Maus, Tastatur und Controller, Pause, Wiederholung und gespeichertem Fortschritt. Aerodyne-Notfall nun per Jumper-Wartungsdeck statt Klopf-Sequenz.
- Zusätzliche Gegnerwellen mit Abschnittssperren und Kontrollpunkten; aufladbarer Katana-Schlag mit Energiewelle, Kick und Ravens aufgeladener Pistolenschuss samt HQ-Kampfposen.
- Bewegtes Hauptmenü mit Neonstadt, Parallax-Effekt, Regen, Reflexionen und Windanimationen; Steuerung über Maus und Controller.
- Korrekturen an der Dachkante für Raven, Größenverhältnissen im Versteck sowie dem Boden-/Straßenübergang von Bingo Street zur Gasse.
- Automatisierte Tests für Terminal-Mechanik, Arcade-Wellen und neue Kampfbewegungen in den Build-Workflow eingebunden. **Build-/Release-Erfolg für v0.16.0 noch nicht bestätigt.**
- Versionsnummer in `project.godot` und auf der Projektstartseite vereinheitlicht.

**Hinweis:** v0.16.0 bezeichnet zunächst den dokumentierten Quellstand auf `main`. Ein GitHub Release wird nicht allein durch die Änderung der Versionsnummer angelegt.


## Weiterentwicklung – Ravens Terminals · 6. November 2026

- Acht Story-Einsätze mit fünf Rätseltypen: Hex-Matrix samt überlappenden Daemons, Glitch-/Passwort-Decoder, Leitungsnetz mit Active ICE und Überlast, Oszilloskop-Abgleich und Jumper-Platine.
- Jackals Schleuse verlangt nach den Wellen einen Raven-Hack. Garagenzugang, Hangar, Dach und Penthouse erhalten interaktive Terminals; der Aufzug wird per synchronisierter Sperrladung blockiert.
- Aerodyne-Reparatur ersetzt die Klopf-Eingaben durch Pins und Widerstände. Scannerfenster bleibt erhalten; Abbruch, Wiederholung und 45-Sekunden-Wiederzugriff sind möglich.
- Maus-, Tastatur- und Controller-Bedienung, Terminal-Pause, Erfolgsbestätigung und gespeicherter Kampagnenfortschritt. Laufende Rätsel frieren die Welt ein.
- Regel-, Fehlerpfad- und Integrationstests sowie eine Godot-Bildergalerie und aktualisierte Spieleranleitung.

## v0.15.0 – HQ-Weltobjekte und Fahrzeug-Action · 5. November 2026

- Neun HQ-Objekttypen mit drei Schadenszuständen; feste Requisiten verwenden dieselbe Grafikbasis. Alte Pixel-Atlanten entfernt.
- Gemalte Fahrzeuge ersetzen die geometrischen Platzhalter in Anflug und Verfolgungsjagd.
- Einmaliger Triebwerksausfall mit acht Sekunden Reparaturzeit, zwölf einzelnen Klopf-Eingaben, Rauch, Schräglage und Wiederzündung. Anflugzeit und Scannerfenster bleiben während der Reparatur erhalten.
- Träge, bildratenstabile Lenkung, Rückstoß, Trefferfunken, Mündungsfeuer, Explosionen und begrenzte Trümmer-/Rauchsysteme.
- Fünf eigenständig synthetisierte Sounds respektieren den vorhandenen Ton-Schalter.
- Neue automatisierte Tests für Reparatur, Pause, Fehlversuch, Scanner, Physik, Treffer und Effektgrenzen.


## v0.14.0 – Verstecktes Testmenü · 5. November 2026

- Das Testmenü öffnet sich im Haupt- oder Pausenmenü mit **Strg+Umschalt+F10** oder fünf Klicks auf den Menütitel.
- Kapitelwahl für alle sieben Kapitel; Kapitel 3–7 starten am passenden Beginn innerhalb der gemeinsamen Kampagne.
- Testschalter: Unsterblichkeit, One-Hit-K.O., unendliche Energie, keine Abklingzeiten, Fluchttimer-Stopp und Alle-Kapitel-Freischaltung.
- Testaktionen: Gegner im aktuellen Kampf ausschalten, Leben/Energie auffüllen und alle Testschalter zurücksetzen.
- Normale Spielstände bleiben getrennt: Ab Öffnen des Testmenüs werden Kontrollpunkte mit Admin-Dateinamen gespeichert.
- Testoptionen werden lokal gespeichert, es gibt keinen Passwortschutz. Storybedingte Schutzmechaniken bleiben bei regulären Treffern erhalten.
- Neue Prüfungen für Kapitelzuordnung, getrennte Speicherpfade, UI, Unsterblichkeit und One-Hit-Modus.


## v0.13.2 – Direkte HQ-Sprites und weniger Altlasten · 5. November 2026

- Alle Szenen laden Raven, Shadepi und die humanoiden Gegner unmittelbar aus den fertigen HQ-Atlanten.
- Zehn alte Pixel-Sprites samt Godot-Importdateien entfernt; die HQ-Atlanten, Original-Keyframes und digitalen Gegner bleiben bestehen.
- `SpriteAssets` auf die Custom-Sprite-Auswahl und Atlasgrößenprüfung vereinfacht. Benutzereigene ältere 4-/8-Richtungs-Pixelraster bleiben kompatibel.
- Gameplay- und Animationstests prüfen den direkten HQ-Ladevorgang und das Fehlen der Pixel-Zwischendateien.
- Node-Generator auf die weiterhin genutzten Pixel-Requisiten, Lichttextur und Basissounds reduziert; keine Figuren/Level/Icons werden mehr überschrieben.
- Aktualisierte Dokumentation, identische Kapitel- und Spielstandformate.


## v0.13.1 – Story, Kapitel und Szenen · 5. November 2026

- Story-Ausgänge starten das folgende Kapitel am Anfang, auch bei älteren abgeschlossenen Spielständen. Menü-Fortsetzen lädt weiterhin den gespeicherten Kontrollpunkt; ungültige Dateien schalten keine Kapitel frei.
- Startposition in Kapitel 2 aus der Autokollision verschoben; Gesundheit, Energie und Hackbereitschaft werden bei der Wiederherstellung zurückgesetzt. Niederlagen außerhalb des Deep Dive führen ebenfalls zum Kontrollpunkt.
- Erinnerungsraum erhält einen definierten Einstieg; falsche Echos führen zum echten Erinnerungsanker zurück.
- Ravens Hackreichweite wird von Raven aus gemessen. Der bewaffnete Ganggegner in Kapitel 1 benutzt Fernangriffe. Der Dachsprung stellt den Fußpunkt der HQ-Grafik korrekt wieder her.
- Überarbeitete Hinterhalt-, Tower-, Rückkehr- und Fluchtdialoge; erklärter Zeitsprung zum nächsten Abend. Das Notfallprotokoll erklärt die Überlastung anstelle nie gelegter Sprengsätze. Fernzugriff und Dachausgang entsprechen den Fluchtaktionen im Penthouse.
- Towerplan wird am Arbeitsterminal geprüft; kontextbezogene Steuerungshinweise. Lange Dialoge werden ohne Textverlust aufgeteilt; HUD-Breiten und mehrzeilige Hinweise angepasst.
- Wassergrenze folgt dem gemalten Ufer. Ritual und Schlusspositionen liegen auf begehbarem Land. Keine Frachtkisten am See, kein Getränkeautomat im Heiligtum oder Penthouse.
- 501 Prüfungen erfolgreich (241 Gameplay, 240 Story/Geometrie/HUD, 20 digitale NPCs). Story-Prüfung in den GitHub-Workflow aufgenommen; Renderübersicht visuell kontrolliert.

[Detaillierter Prüfbericht und Grenzen](docs/v0.13.1-fehlerpruefung.md)

## v0.13.0 – HQ-NPCs · 5. November 2026

- Acht illustrierte humanoide NPC-Atlanten mit acht Blickrichtungen; zwei neue digitale Gegnergrafiken.
- Neue Schuss-/Rundumschlag-Animationen bei unverändertem Kampftiming.
- Originalposen, reproduzierbares Packwerkzeug und NPC-Anleitung enthalten.
- 239 Spieltests und 20 digitale Gegnerprüfungen unter Windows erfolgreich; Godot-Galerie visuell geprüft.
- 32 Ausgangsposen je humanoider Figur werden für die Animationsfelder wiederholt; keine 256 unabhängig gezeichneten Frames.


## v0.12.0 – wiederhergestellter Quellstand auf GitHub

**4. November 2026** · [Upload 3d4b2c4](https://github.com/Inrouder/ShadepiRPG/commit/3d4b2c492ded8a656a2311997781de6d027e1e34)

### Spiel und Medien

- Illustrierte HQ-Sprites für Raven und Shadepi mit acht Blickrichtungen sowie Lauf- und Angriffsanimationen.
- Originale Schlüsselposen und `tools/compile_heroes.py` zur Bearbeitung der Heldenatlanten.
- Die vorherigen Ausbaustufen mit 16 gemalten Kulissen, abgestimmter Kollisions-/Vordergrunddarstellung und zerstörbaren Requisiten sind enthalten.
- Kapitel 1–7, Solo-/Koop-Steuerung, Controller-Unterstützung und Spielstände bleiben Teil des Projekts.

### Wiederherstellung und Sicherung

- Alle 25 Spielskripte dekompiliert und alle 105 importierten Ressourcen konvertiert.
- Originaldateien aus dem separaten HQ-Archiv ergänzt.
- Alle 243 Dateien des bereitgestellten Projekts auf GitHub nachgewiesen; 242 stimmen mit dem lokal geprüften Stand überein. Die neu serialisierte Projektkonfiguration nennt 0.12.0.
- README, Projektaufbau, Bearbeitungshinweise und Wiederherstellungsbericht aktualisiert.

### Prüfung und Grenzen

- Lokale Rekonstruktion unter Windows mit Godot 4.7.2: **177 Prüfungen, 0 Fehler**, erfolgreicher Starttest.
- [GitHub-Test- und Buildlauf des Uploads](https://github.com/Inrouder/ShadepiRPG/actions/runs/41922510900): **erfolgreich**, einschließlich Windows-/Linux-Export und Linux-Starttest.
- 30 Ressourcen von GDRE als verlustbehaftet konvertiert eingestuft. Ursprüngliche Medienquellen und nicht exportierte Entwicklungsdateien sind nicht vollständig rekonstruierbar.
- Kein vollständiger manueller Spieldurchlauf. Die früher genannten 301 Tests gelten nicht als Testzahl dieser Rekonstruktion.
- Der Quellstand auf `main` und die Actions-Artefakte sind vorhanden. Ein eigenständiger GitHub Release ist ein zusätzlicher Veröffentlichungsschritt.

[Ausführlicher Wiederherstellungsbericht](docs/v0.12.0-wiederherstellung.md)

## Entwicklungsschritte vor der Wiederherstellung

Diese Zuordnung stammt aus den bisherigen Entwicklungsberichten; sie bezeichnet keine nachträglich angelegten Git-Tags oder separat geprüften Releases.

| Version | Schwerpunkt |
| --- | --- |
| v0.11.0 | 16 gemalte Levelkulissen, abgestimmte Kollisionen und Vordergrundwände |
| v0.10.0 | Zerstörbare Kisten, Straßenlaternen, Autos, Fässer und weitere Requisiten |
| v0.9.0 | Comicgerechte Kapitelinszenierung |
| v0.7.0 | Vorheriger GitHub-Quellstand vor der Rückführung des v0.12-Projekts |
