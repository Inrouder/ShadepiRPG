# Shadepi · Echos in Neon

**v0.13.1 · Godot 4.7.2 · Windows und Linux · Einzelspieler und Lokal-Koop**

## Story- und Fehlerkorrekturen v0.13.1

Kapitelübergänge überspringen keine Handlung mehr durch ältere Spielstände. Kapitel 2 startet neben dem geparkten Wagen, Niederlagen stellen den Kontrollpunkt wieder her. Dialoge, Kampfhinweise und Missionsziele wurden mit den spielbaren Szenen abgeglichen; lange Dialoge werden vollständig auf mehrere Seiten verteilt. Die Uferkollision und das Abschlussritual passen jetzt zur gemalten See-Kulisse. Unpassende Requisiten wurden entfernt.

**501 automatisierte Prüfungen, 0 Fehler** unter Windows mit Godot 4.7.2: 241 bestehende/erweiterte Spielprüfungen, 240 Story-, Layout- und Kollisionsprüfungen sowie 20 digitale Gegnerprüfungen. 16 Szenenansichten, Erinnerungsraum und Dialogdarstellung im Renderer kontrolliert. Kein vollständiger manueller Durchlauf; kein neuer Linux- oder Exporttest für diesen Patch.

[Korrekturen, Kapitelreihenfolge und Prüfgrenzen](docs/v0.13.1-fehlerpruefung.md) · [Versionshinweise](CHANGELOG.md)

Das bereitgestellte Projekt-ZIP enthält diesen lokalen Stand. Ein Upload von v0.13.1 auf GitHub ist damit noch nicht bestätigt; der `main`-Download kann einen älteren Stand enthalten.

## NPC-Update v0.13.0

Alle acht humanoiden NPC-Typen haben neue illustrierte HQ-Sprites: Chrome Jackal, Kenzō, vier Gangmitglieder und zwei Schützen. Virus und ICE-Wächter im Deep Dive besitzen ebenfalls neue transparente Grafiken. Raven und Shadepi behalten ihre vorhandenen HQ-Sprites.

Je humanoider Figur: acht Blickrichtungen, 32 gezeichnete Ausgangsposen und daraus zusammengestellte Stand-, Lauf-, Angriffs- und Treffersequenzen. Die 256 Atlasfelder enthalten wiederholte Posen. Schützen und Kenzō zeigen ihre Angriffspose nun auch beim Schuss beziehungsweise Rundumschlag.

Lokal mit Godot 4.7.2 unter Windows geprüft: **239 Spielprüfungen und 20 Deep-Dive-Prüfungen ohne Fehler**. Galerie im Godot-Renderer visuell geprüft. Kein vollständiger manueller Spieldurchlauf.

[Neue NPCs und Bearbeitung](docs/npc-sprites.md) · [Versionshinweise](CHANGELOG.md)



Ein 2D-Action-RPG im Shadepi-Universum mit Raven und Shadepi, sieben Kapiteln, gemalten Kulissen und illustrierten Helden.

Der wiederhergestellte v0.12.0-Quellstand ist auf `main` angekommen. Der Upload wurde mit dem bereitgestellten Projekt abgeglichen; alle 243 Dateien sind vorhanden. Der [GitHub-Test- und Buildlauf für den Upload](https://github.com/Inrouder/ShadepiRPG/actions/runs/41922510900) ist erfolgreich.

[Godot-Projekt als ZIP](https://github.com/Inrouder/ShadepiRPG/archive/refs/heads/main.zip) · [Spiel-Builds](https://github.com/Inrouder/ShadepiRPG/actions/workflows/build.yml) · [Versionshinweise](CHANGELOG.md) · [Projektaufbau](docs/architecture.md)

## Neu in v0.12.0 und den vorherigen Ausbaustufen

- **Raven und Shadepi:** illustrierte HQ-Atlanten, acht Blickrichtungen, Lauf- und Angriffsanimationen.
- **16 gemalte Kulissen:** unter anderem Apartment, Industriegebiet, Versteck, Tower, See und Fahrzeugsequenzen.
- **Interaktive Umgebung:** zerstörbare Requisiten mit Treffern, Effekten und Geräuschen.
- **Bearbeitbares Projekt:** Spielskripte, Szenen, Medien sowie originale Helden-Schlüsselposen und das Packwerkzeug.

Der Stand wurde aus dem ursprünglichen Windows-Spiel rekonstruiert und durch Originaldateien aus dem HQ-Archiv ergänzt. Einige Medien wurden verlustbehaftet zurückgewonnen. Details und Prüfgrenzen stehen im [Wiederherstellungsbericht](docs/v0.12.0-wiederherstellung.md).

## Schnellstart

**Entwickeln:** Projekt-ZIP entpacken, `project.godot` mit **Godot 4.7.2 Standard** importieren, Ressourcenimport abwarten und F5 drücken. Kein C# erforderlich.

**Spielen:** Im erfolgreichen [v0.12-Workflowlauf](https://github.com/Inrouder/ShadepiRPG/actions/runs/41922510900) das Windows- oder Linux-Artefakt herunterladen und entpacken. Für Actions-Downloads ist eine GitHub-Anmeldung erforderlich. Das Quellcode-ZIP enthält das Godot-Projekt, keine fertig exportierte EXE.

**Dokumentation:** [Figuren und Level bearbeiten](docs/figuren-bearbeiten.md) · [HQ-Sprites und Raster](docs/helden-sprites.md) · [Spieleranleitung](Spiel-README.md)

## Geschichte

**Kapitel 1 · Echos in Neon und Schatten** ist der spielbare Auftakt zu „Shadepi – Im Schatten des Raben“.

Raven bekommt in ihrem Apartment einen Hinweis auf Chrome Jackal, räumt die Punks in Bingo Street aus dem Weg und verfolgt ihn bis zum Wartungshof. Dort hält seine Panzerung jedem Treffer stand. Nach 30 Kampfsekunden dreht er Ravens Hack gegen sie. Shadepi kämpft sich durch die Wartungsgasse und stellt Jackal mit 360 HP. Sobald die Hälfte seiner Lebenspunkte weg ist, steht Raven auf und steigt in den Kampf ein.

Die Zwischenszenen nutzen Ausschnitte aus dem Comic „Shadepi – Im Schatten des Raben“ (deutsche Fassung, PDF-Seiten 2, 4, 5, 6 und 9) mit eigens für das Spiel geschriebenen Dialogen.

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
- **Kampf und Flucht:** Q/RB stört gegnerische Implantate. Die Aufzugwachen stehen vor dem Penthouse. Kenzō kämpft dort allein. Sichere anschließend die Daten, blockiere den Aufzug, starte die Pumpe neu und erreiche den Aerodyne vor Ablauf von 60 Sekunden.

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

- Illustrierte HQ-Spritesheets für Shadepi und Raven mit acht Blickrichtungen; Stand, Laufbewegung, Angriff und Trefferpose. Die bisherigen Spriteformate für eigene Figuren bleiben unterstützt.
- Begehbare Gasse mit Gebäudekollisionen, Hindernissen, Sicherheitsschleuse und markierter Jagdroute.
- Gegner mit angekündigtem Angriff, Vorstoß, Erholungsphase und hackbarer Panzerung.
- Katana-Kombination, Energie, Ausweichen, zehn Sekunden maximales Tarnfenster und Fähigkeitencooldowns.
- Comic-Zwischenszenen, zwei Kämpfe gegen Jackal, vier animierte Punk-Varianten, eine Rettung mit drei Wachen und separate Kapitel-Kontrollpunkte für Solo und Koop.
- Geworfene Schatten, Neonhalos, nasse Spiegelungen, Schritte im Regen, Dampf, Hackentladungen und ein dezenter Farb- und Lichtfilter. Die drei Bildstile sind im Menü und mit **V** umschaltbar; die Einstellung bleibt beim Neustart erhalten.
- Eigens synthetisierte elektronische Hintergrundmusik und Kampf-/Hackeffekte.

## Godot-Projekt öffnen

Verwendete und geprüfte Version: **Godot 4.7.2 Standard**, Renderer **Compatibility**, kein C# erforderlich.

Repository herunterladen oder klonen, `project.godot` importieren, Ressourcenimport abwarten und **F5** drücken. Die Darstellung rechnet mit 640 × 360 Pixeln und ganzzahliger Skalierung; das Fenster startet mit 1280 × 720 Pixeln.

## Tests und eigene Builds

```bash
godot --headless --editor --import --quit
godot --headless --script res://tests/run.gd
mkdir -p build/windows build/linux
godot --headless --export-release "Windows Desktop" build/windows/Shadepi-Echos-in-Neon.exe
godot --headless --export-release Linux build/linux/Shadepi-Echos-in-Neon.x86_64
```

Zum Export müssen die offiziellen Exportvorlagen derselben Godot-Version installiert sein. Die GitHub Action richtet dies automatisch ein. Die Windows-EXE wird unter Linux exportiert; ihre Ausführung auf einem tatsächlichen Windows-PC ist ein gesonderter manueller Prüfschritt.

Die automatisierten Prüfungen behandeln den Kapitelfortschritt vom Apartment bis zum Finale sowie Bewegung und Gebäudekollision, Missionsfortschritt, Kampf, Tarnung, Spriteformate, Grafikprofile, gleichzeitige Eingaben für beide Figuren, Koop-Kampf, simulierte Controller-Eingaben, Laden beider Figuren sowie ungültige und beschädigte Spielstände einschließlich Backup-Wiederherstellung.

Kapitel-Kontrollpunkte liegen in `user://shadepi-chapter-one.cfg`. Beim Laden beginnt der gespeicherte Abschnitt von vorn. Die spätere Testszene nutzt Godots `user://shadepi-test-save.json` für Solo und `user://shadepi-coop-save.json` für Koop (unter Windows normalerweise `%APPDATA%/Godot/app_userdata/Shadepi - Echos in Neon/`). Bei beschädigter Hauptdatei wird ein validiertes Backup versucht. Beim Laden werden laufende Fähigkeiten zurückgesetzt und Jackal an seine Startposition gesetzt; sein gespeicherter Lebensstand bleibt erhalten.

## Grafiken und Audio weiterbearbeiten

Die HQ-Helden liegen als transparente PNGs in `assets/sprites/heroes/`. Kopiere die gewünschte Figur als `shadepi.png` oder `raven.png` nach `assets/custom/` und bearbeite die Kopie. Das Spiel lädt deine Variante automatisch. In der [Bearbeitungsanleitung](docs/figuren-bearbeiten.md) stehen Raster, Zeilenreihenfolge und Exportvorgaben.

Die HQ-Atlanten werden mit `python tools/compile_heroes.py` aus `tools/hero_sources/` zusammengestellt; dafür wird Pillow benötigt. Die [HQ-Anleitung](docs/helden-sprites.md) beschreibt Raster und Fußpunkte.

Der ältere Generator für Rastergrafiken und synthetische Audiodateien benötigt Node.js. Er rekonstruiert nicht die gemalten Kulissen oder die HQ-Originalbilder. Vor einer erneuten Generierung den aktuellen Stand sichern und die Änderungen prüfen:


```bash
npm ci
npm run assets
```

`tools/generate_assets.cjs` enthält die Rasterzeichner und den Synthesizer. Es werden keine SVG-Figuren und keine extern geladenen Bilder verwendet. Die Szene läuft vollständig lokal, ohne Konten, KI-Dienste oder Onlinepflicht.

## Prüfung und Sicherung

Die lokale Wiederherstellung bestand unter Windows **177 Prüfungen ohne Fehler** und einen Starttest über 120 Frames. Der GitHub-Workflow für den manuell hochgeladenen Stand hat anschließend Import, Tests sowie Windows-/Linux-Export erfolgreich abgeschlossen. Ein vollständiger manueller Spieldurchlauf ist damit nicht ersetzt.

Nach jedem Meilenstein Quellen und benötigte Medien gemeinsam committen, übertragen und den neuen Commit auf GitHub prüfen. Zusätzlich eine vollständige Projekt-ZIP sichern. Fertige Spiele können über [Releases](https://github.com/Inrouder/ShadepiRPG/releases) veröffentlicht werden; ein Upload auf `main` allein erstellt noch keinen Release.

Die frühere Angabe von 301 Tests bezieht sich auf den ursprünglichen Entwicklungsbericht und ist nicht die Testzahl dieser Rekonstruktion.
