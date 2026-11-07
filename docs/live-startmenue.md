# HQ-Startmenü · v0.20.3 · CodexAI

![Hauptscreen in Full HD](startmenue.png)

[Animierte Vorschau öffnen](previews/startmenue-live.webp) · [PNG in Full HD öffnen](startmenue.png)

Die vorhandene Neonstadt mit weißem Drachen und Dachplattform bleibt die Kulisse. Die neue transparente Figurenebene `assets/menu/start-heroes-hq.png` wurde aus der bestehenden Referenzillustration `start-heroes.png` im gemalten Material- und Lichtstil von `assets/world/painted/alley.png` erstellt. Die bisherige Illustration bleibt als Quelle erhalten. Die HQ-PNG hat 1254 × 1254 Pixel, die Stadt-PNG 1280 × 720 Pixel; die Full-HD-Vorschau ist ein tatsächlicher Godot-Render in 1920 × 1080.

Shadepi behält den flachen schwarzen Kasa, die segmentierte Maske mit roten Augenlinsen, Schal, taktische Weste, Protektoren, geteilten Umhang und das rote Laser-Katana. Raven behält ihre schwarz-blauen Haare, roten Augen, das goldene Septum, zwei rechteckige Cyan-Kragenmodule, Cyan-Anzuglinien, rote Rabenembleme, Holster, Stiefel und Tablet. Ravens verbindliche Körpergröße bleibt 160 cm. Metall, Stoff und Leder sind jetzt detailliert gemalt, mit Regenperlen und Cyan-/Magenta-Kantenlicht passend zur Spielkulisse.

Die Chat-Referenzen vom 7. November sind weiterhin keine zusätzlich archivierten lokalen Originaldateien. Die neue Grafik ist eine Menüillustration aus diesen bereits dokumentierten Quellen. Gameplay-Sprites, Story und Tower werden durch diese Änderung nicht ersetzt.

## Darstellung und Bewegung

- Nur das Hauptmenü rendert Bilder und Schrift direkt in Fensterauflösung (`CANVAS_ITEMS`). Beim Starten des Spiels und im Pausenmenü wird wieder das ursprüngliche 640×360-Spielraster (`VIEWPORT`) verwendet. Die Spielmechanik und Kameramaßstäbe bleiben erhalten.
- Zwei getrennte Figurenmeshes stehen mit festen Körper- und Fußankern auf der vorderen Plattform. Raven ist proportional skaliert und leicht nach hinten versetzt. Kontaktschatten unter den Stiefeln verbinden die Figuren mit dem Boden. Maus und Fokus verschieben weder Figuren noch Dach.
- Wind wirkt nur auf freie Haarspitzen und Umhangränder; Gesicht, Rüstung, Hände, Waffen und Stiefel bleiben ruhig.
- Regen fällt in mehreren Tiefen und Geschwindigkeiten, mit wechselnder Windrichtung und schwachen Lichtfahnen. Sprühnebel und Wasserringe treffen die Dachfläche; Flugverkehr zieht durch die Skyline.
- Ein separater Stadtshader belebt die nassen Reflexe und lässt das Licht um den Drachen langsam atmen. Architektur und Plattformkante bleiben fest.
- Ein Bildschirmshader ergänzt wandernden Nebel, schwache Neonlichtstrahlen, wenige Glaströpfchenspuren, zurückhaltenden Bloom und Filmkorn. Er liegt unter der Menüschrift und verzerrt keine Gesichter oder Knöpfe.
- Menükonturen und kleine wandernde Cyan-Lichtsegmente greifen Ravens Nightwing-Terminals auf. Hover und Fokus sind deutlich sichtbar; Klicks erzeugen einen Lichtimpuls.
- **Reduziert** deaktiviert Stadt-/Atmosphäre-Shader, Figurenwind und Menülichtanimation; es bleibt eine sparsame Regenlage. Verdeckte Menüs stoppen ihre Zeichen- und Eingabeverarbeitung.
- Im Hauptmenü läuft weiterhin `Level.mp3`, dieselbe Musik wie am See und im Finale.

## Prüfen und Vorschau erzeugen

```sh
godot --headless --script res://tests/run.gd
godot --audio-driver Dummy --script res://tools/menu_gallery.gd
# Optional: 48 Animationsbilder mit 12 Schritten pro Sekunde
godot --audio-driver Dummy --script res://tools/menu_gallery.gd -- --animate
```

Die Galerie benötigt einen echten Renderer (z. B. Xvfb/Mesa) und schreibt nach `/tmp/shadepi-menu-*.png`. Sie kontrolliert einen tatsächlichen Full-HD-Render, einen Mausklick in Fensterkoordinaten und erhaltenen UI-Fokus nach dem Skalierungswechsel. Weitere Aufnahmen zeigen Fokus, Wetter, alle vier Mausecken, reduzierten Bildstil, zwei isolierte Windphasen und das Pausenmenü. Die Animationsbilder zeigen die echten Engine-Effekte; es ist kein vorgerendertes Menüvideo im Spiel hinterlegt.

Die Gameplay-Prüfung kontrolliert zusätzlich feste Körper-/Fußpunkte, sicheren Stand innerhalb der Plattform, korrekte Qualitätsstufen, den Wechsel zwischen HQ-Menü und Spielraster sowie das Abschalten verdeckter Menüs. Originalquellen und Nutzerbestätigungen stehen im [Universum-Archiv](universum/README.md).

Die animierte WebP liegt unter `docs/previews/` mit `.gdignore`, da sie eine Browser-Vorschau ist und Godot animierte WebP nicht als Spieltextur importieren soll.
