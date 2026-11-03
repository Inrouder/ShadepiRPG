# Figuren selbst bearbeiten

Die sichtbaren Figuren sind transparente PNG-Spritesheets. Waffen, Haare, Masken und Kleidung sind jeweils als Pixel in den Einzelbildern gezeichnet. Du kannst Farben und Formen frei verändern, ohne den GDScript-Code anzufassen.

1. Öffne das Godot-Projekt. Kopiere `assets/sprites/shadepi.png`, `raven.png` oder `jackal.png` nach `assets/custom/`. Der Dateiname bleibt gleich.
2. Öffne die Kopie in deinem Pixelprogramm. In Aseprite kannst du sie als normales PNG mit einem Raster von **48 × 64 Pixeln** bearbeiten oder über **File → Import Sprite Sheet** als Einzelbilder importieren. Beim Import: 48 × 64, Versatz 0, ohne Zwischenraum, zeilenweise von links nach rechts. Siehe [Aseprite-Dokumentation](https://www.aseprite.org/docs/sprite-sheet/).
3. Bearbeite die betreffenden Bilder. Lass den Hintergrund transparent und halte die Füße ungefähr am bisherigen Standpunkt. Jede Zeile enthält acht Animationsbilder.
4. Speichere als **384 × 1024 Pixel großes PNG**, acht Spalten und 16 Zeilen. Kein Zuschneiden, keine Zwischenräume und kein automatisches Verkleinern transparenter Ränder. Warte den Godot-Import ab und starte das Spiel neu.

| Zeilen (ab 1) | Animation | Richtungen innerhalb der Gruppe |
| --- | --- | --- |
| 1–4 | Stand | unten, links, rechts, oben |
| 5–8 | Laufen | unten, links, rechts, oben |
| 9–12 | Angriff | unten, links, rechts, oben |
| 13–16 | Trefferpose | unten, links, rechts, oben |

**Ein guter Einstieg:** Ändere zuerst die Augen- oder Rüstungsfarbe in einer Standzeile. Teste sie im Spiel, bevor du die Änderung auf Lauf- und Angriffsbilder überträgst. Mit **V** kannst du zwischen den drei Bildstilen vergleichen, wie deine Farben unter verschieden starken Effekten wirken.

Die Dateien unter `assets/custom/` werden vom Generator nicht überschrieben. Entfernst du deine Kopie aus dem Ordner, wird beim nächsten Start das Original verwendet. Für eine eigene Windows-EXE exportierst du das Projekt nach der Änderung erneut.
