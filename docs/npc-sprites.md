# Illustrierte NPCs und Gegner

**Statushinweis v0.46.2 · CodexAI:** Herstellungsbericht des ursprünglichen NPC-Satzes. Die fertigen Atlanten bleiben aktiv; spätere Kontaktposen und Größenkorrekturen ergänzen diesen Bestand. [Aktuelle Einordnung](repository-status.md).

Die NPC-Grafiken orientieren sich an den illustrierten HQ-Helden Raven und Shadepi. Die Figurenbilder wurden mit dem eingebauten **Imagegen-Werkzeug** erzeugt. Das Packskript zeichnet keine Figuren nach: Es ordnet die vorhandenen Bildposen zu, richtet Fußpunkte aus und erstellt die Godot-Atlanten.

## Enthaltene Figuren

| Datei unter `assets/sprites/npcs/` | Figur und Verwendung |
| --- | --- |
| `jackal.png` | Chrome Jackal, schwer gepanzerter Cyborg mit magentafarbenen Implantaten |
| `kenzo.png` | Kenzō Moriyama, kybernetischer Boss im Penthouse |
| `punk-1.png` | Gangmitglied mit rotem Mantel und orangefarbenem Irokesenschnitt |
| `punk-2.png` | Gangmitglied mit grünem Mantel und mintfarbenem Haar; auch als Turmwache verwendet |
| `punk-3.png` | Gangmitglied mit violettem Mantel und violettem Stachelhaar; auch als Schildwache verwendet |
| `punk-4.png` | Gangmitglied mit ockerfarbenem Mantel und blondem Haar |
| `shooter-visor.png` | Gepanzerter Schütze mit cyanfarbenem Visier |
| `shooter-violet.png` | Gepanzerter Schütze mit violettem Visier |
| `dive-virus.png` | Schwebender Virus-Gegner im Deep Dive |
| `ice-guardian.png` | Größerer ICE-Wächter im Deep Dive |

Die vier Gangvarianten werden in der Jagd, bei der Rettung und teilweise im Tower wiederverwendet. Im bisherigen Spiel gibt es keine weiteren separaten humanoiden Zivilisten-Sprites. ARTOS ist eine Dialog-/Systemstimme; Fahrzeuge gehören zu einer eigenen Darstellung.

## Humanoide Atlanten und Quellbilder

Die acht Quelltafeln liegen in `tools/npc_sources/*-keyframes.png`. Jede Tafel ist **1536 × 1024 Pixel** groß und enthält **32 gezeichnete Ausgangsposen**:

- Acht Spalten: unten, links, rechts, oben, oben-links, oben-rechts, unten-links, unten-rechts.
- Vier Zeilen: Ruhepose, linker Schritt, rechter Schritt, Angriff.
- Ein Quellfeld misst 192 × 256 Pixel; der Hintergrund besitzt einen echten Alphakanal.

Die Godot-Atlanten sind **1024 × 5120 Pixel** groß, mit **128 × 160 Pixeln je Einzelbild**. Acht Animationsbilder stehen nebeneinander. Die 32 Zeilen sind folgendermaßen aufgeteilt:

| Zeilen, ab 1 gezählt | Zustand |
| --- | --- |
| 1–8 | Stand |
| 9–16 | Laufen |
| 17–24 | Angriff |
| 25–32 | Treffer |

Innerhalb jeder Gruppe gilt dieselbe Richtungsreihenfolge wie in den Quelltafeln. Der Fußpunkt liegt bei Y = 152. Im Spiel werden diese Atlanten mit Faktor 0,5 dargestellt.

**256 Atlasfelder sind nicht 256 einzeln gezeichnete Posen.** Der Compiler stellt die Animationen aus den 32 Ausgangsposen zusammen. Die Laufbewegung kombiniert Ruhepose und beide Schritte. Angriffe verwenden Ruhe- und Angriffspose; Stand und Treffer wiederholen die Ruhepose. Trefferfeedback und weitere Effekte kommen aus der Spielsteuerung.

## Erneut zusammenstellen

Python mit Pillow wird nur zum Neuaufbau der Atlanten benötigt:

```bash
python tools/compile_npcs.py
```

Einzelne Figuren lassen sich gezielt neu packen:

```bash
python tools/compile_npcs.py jackal kenzo
```

Der Compiler isoliert zusammenhängende Figurenbereiche und berücksichtigt transparente Randpixel. Waffen dürfen innerhalb einer Zeile über eine Spaltengrenze reichen, solange sie sich nicht mit der Nachbarfigur verbinden. Alle Posen einer Figur verwenden denselben Maßstab. Überlappende Körper, fehlende Posen und abgeschnittene Ausgabebilder führen zu einer Fehlermeldung.

`tools/npc_sources/atlas-report.json` dokumentiert Quell- und Ausgabegrenzen, Fußanker, Maßstab und die Anzahl nicht leerer Atlasfelder. Originaltafeln vor Änderungen sichern. Die Generierungsanweisungen werden in `tools/npc_sources/prompts.json` dokumentiert.

## Einbindung im Spiel

Seit **v0.13.2** laden alle Szenen die HQ-Grafiken unmittelbar aus `assets/sprites/npcs/`. Die alten Pixel-Zwischengrafiken unter `assets/sprites/` wurden entfernt. `scripts/sprite_assets.gd` stellt nur noch die optionale Ersetzung durch eigene Grafiken und die Größenprüfung bereit.

Eigene humanoide Figuren unter `assets/custom/` behalten Vorrang. Der Dateiname muss zur Figur passen, beispielsweise `assets/custom/jackal.png`; ein unterstütztes Raster ist erforderlich. Die neuen HQ-Atlanten verwenden acht Blickrichtungen, die von `PixelActor` anhand der Atlasgröße erkannt werden.

## Digitale Gegner

Virus und ICE-Wächter verwenden jeweils eine quadratische, transparente Einzelillustration mit mehr als 1024 Pixeln Kantenlänge. `scripts/dive_threat.gd` skaliert die gesamte Textur relativ zu ihrer tatsächlichen Größe auf 48 beziehungsweise 72 Spielpixel. Es gibt dafür keinen Richtungsatlas.

Eine leichte Pulsation und Drehbewegung beleben das Bild. Der Wechsel in das bestehende Verwundbarkeitsfenster färbt es zusätzlich cyan. Angriffsmarkierungen, der Richtungszeiger des Virus sowie Strahl und seitliche Markierungen des Wächters werden darüber gezeichnet. Bewegung, Schadenswerte, Angriffstimer und Trefferbedingungen bleiben davon getrennt. Bei geöffnetem Menü pausieren auch die neuen Bildbewegungen.

## Prüfen

Nach Änderungen zuerst die Ressourcen importieren und dann die Spieltests sowie den gezielten Digitalgegner-Test ausführen:

```bash
godot --headless --editor --import --quit
godot --headless --script res://tests/run.gd
godot --headless --script res://tests/npc_dive_visuals.gd
```

Der zusätzliche Test prüft beide Texturen, Transparenz, Darstellungsreihenfolge der Angriffsmarkierungen, Pause/Fortsetzung, die bestehenden Verwundbarkeitsgrenzen und genau einen Schadentreffer pro Angriff. Die Skripttests ersetzen keine Sichtprüfung der Animationen im laufenden Spiel.

Der Digitalgegner-Test wurde unter Windows mit Godot 4.7.2 ausgeführt: **20 Prüfungen, 0 Fehler**, Exit-Code 0.
