# Figuren selbst bearbeiten

Die sichtbaren Figuren sind transparente PNG-Spritesheets. Raven und Shadepi nutzen seit v0.12.0 ausgearbeitete illustrierte Figuren. Du kannst Farben und Formen frei verändern, ohne den GDScript-Code anzufassen.

1. Öffne das Godot-Projekt. Kopiere `assets/sprites/heroes/shadepi.png` oder `raven.png` nach `assets/custom/`. Jackal und die früheren Pixelvarianten stehen direkt in `assets/sprites/`. Der Dateiname bleibt gleich.
2. Öffne die Kopie in deinem Bildprogramm. Die neuen Helden nutzen ein Raster von **128 × 160 Pixeln**, die früheren Pixelvarianten **48 × 64 Pixel**. Beim Import: Versatz 0, ohne Zwischenraum, zeilenweise von links nach rechts. Siehe [Aseprite-Dokumentation](https://www.aseprite.org/docs/sprite-sheet/).
3. Bearbeite die betreffenden Bilder. Lass den Hintergrund transparent und halte die Füße ungefähr am bisherigen Standpunkt. Jede Zeile enthält acht Animationsbilder.
4. Speichere die illustrierten Helden als **1024 × 5120 Pixel großes PNG**, mit acht Spalten und 32 Zeilen. Ihre Füße stehen bei ungefähr Y = 152 im Einzelbild; das Spiel stellt sie mit halber Bildauflösung dar. Frühere acht Richtungen nutzen **384 × 2048 Pixel**, vier Richtungen **384 × 1024 Pixel**, jeweils mit Füßen bei Y = 58. Kein Zuschneiden, keine Zwischenräume und kein automatisches Verkleinern transparenter Ränder. Warte den Godot-Import ab und starte das Spiel neu.

| Animation | Zeilen bei acht Richtungen | Zeilen bei vier Richtungen |
| --- | --- | --- |
| Stand | 1–8 | 1–4 |
| Laufen | 9–16 | 5–8 |
| Angriff | 17–24 | 9–12 |
| Trefferpose | 25–32 | 13–16 |

Die Richtungsfolge pro Gruppe ist unten, links, rechts, oben, oben-links, oben-rechts, unten-links, unten-rechts. Im Vier-Richtungs-Format endet jede Gruppe nach „oben“.

**Ein guter Einstieg:** Ändere zuerst die Augen- oder Rüstungsfarbe in einer Standzeile. Teste sie im Spiel, bevor du die Änderung auf Lauf- und Angriffsbilder überträgst. Mit **V** kannst du zwischen den drei Bildstilen vergleichen, wie deine Farben unter verschieden starken Effekten wirken.

Die Dateien unter `assets/custom/` werden vom Generator nicht überschrieben. Entfernst du deine Kopie aus dem Ordner, wird beim nächsten Start das Original verwendet. Für eine eigene Windows-EXE exportierst du das Projekt nach der Änderung erneut.

## Kapitelbilder und Level nachträglich ändern

| Was du ändern möchtest | Wo du es findest |
| --- | --- |
| Comicbilder und Zwischensequenzen | `assets/comic/`. Ersetze ein JPG unter demselben Namen und lass Godot neu importieren. Die Bildzuordnung steht in `scripts/chapter_hud.gd` unter `COMIC`. |
| Dialoge und Abläufe | `scripts/chapter_one.gd`. Ein Dialogeintrag enthält Sprecher, Text und Bildschlüssel. |
| Boden, Fassaden und Schilder in Bingo Street | `assets/world/painted/market.png` und `assets/world/painted/alley.png`. Die Bildmaße beibehalten und Hindernisse in `scripts/painted_world.gd` abgleichen. |
| Wege, Hindernisse und Gegner | `scripts/chapter_one.gd` mit `BARRIERS`, `TRAIL`, `HUNT_GUARDS` und `RESCUE_GUARDS`. Gemeinsame Wände und Requisiten stehen in `scripts/world_data.gd`. |

Die Kapitelkarte wird aus den gemalten Kulissen und den Szenendaten aufgebaut. Wenn du eine Mauer versetzt, passe sowohl das Bild als auch die Kollisionen in `scripts/painted_world.gd` an. Starte das Kapitel in Godot und prüfe den Weg bis zur Schleuse. Für eine eigene Windows-Fassung exportierst du anschließend neu.

Kapitel 2 nutzt die Szene `scenes/chapter_two.tscn`. Dialoge, Scanpunkte, Netzwerkknoten und Hindernisse stehen in `scripts/chapter_two.gd`; die Comiczuordnung steht in `scripts/chapter_two_hud.gd`.
