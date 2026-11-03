# Figuren selbst bearbeiten

Die sichtbaren Figuren sind transparente PNG-Spritesheets. Waffen, Haare, Masken und Kleidung sind jeweils als Pixel in den Einzelbildern gezeichnet. Du kannst Farben und Formen frei verändern, ohne den GDScript-Code anzufassen.

1. Öffne das Godot-Projekt. Kopiere `assets/sprites/shadepi.png`, `raven.png` oder `jackal.png` nach `assets/custom/`. Der Dateiname bleibt gleich.
2. Öffne die Kopie in deinem Pixelprogramm. In Aseprite kannst du sie als normales PNG mit einem Raster von **48 × 64 Pixeln** bearbeiten oder über **File → Import Sprite Sheet** als Einzelbilder importieren. Beim Import: 48 × 64, Versatz 0, ohne Zwischenraum, zeilenweise von links nach rechts. Siehe [Aseprite-Dokumentation](https://www.aseprite.org/docs/sprite-sheet/).
3. Bearbeite die betreffenden Bilder. Lass den Hintergrund transparent und halte die Füße ungefähr am bisherigen Standpunkt. Jede Zeile enthält acht Animationsbilder.
4. Speichere als **384 × 2048 Pixel großes PNG** mit acht Spalten und 32 Zeilen für die neuen Shadepi- und Raven-Sprites. Jackal und bisherige benutzerdefinierte Figuren nutzen das Format **384 × 1024 Pixel** mit 16 Zeilen. Kein Zuschneiden, keine Zwischenräume und kein automatisches Verkleinern transparenter Ränder. Warte den Godot-Import ab und starte das Spiel neu.

| Animation | Zeilen bei acht Richtungen | Zeilen bei vier Richtungen |
| --- | --- | --- |
| Stand | 1–8 | 1–4 |
| Laufen | 9–16 | 5–8 |
| Angriff | 17–24 | 9–12 |
| Trefferpose | 25–32 | 13–16 |

Die Richtungsfolge pro Gruppe ist unten, links, rechts, oben, oben-links, oben-rechts, unten-links, unten-rechts. Im Vier-Richtungs-Format endet jede Gruppe nach „oben“.

**Ein guter Einstieg:** Ändere zuerst die Augen- oder Rüstungsfarbe in einer Standzeile. Teste sie im Spiel, bevor du die Änderung auf Lauf- und Angriffsbilder überträgst. Mit **V** kannst du zwischen den drei Bildstilen vergleichen, wie deine Farben unter verschieden starken Effekten wirken.

Die Dateien unter `assets/custom/` werden vom Generator nicht überschrieben. Entfernst du deine Kopie aus dem Ordner, wird beim nächsten Start das Original verwendet. Für eine eigene Windows-EXE exportierst du das Projekt nach der Änderung erneut.
