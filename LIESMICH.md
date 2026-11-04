# Raven & Shadepi · HQ-Sprites · v0.12.0

Zwei neue illustrierte Figuren, orientiert an den vorhandenen Comicvorlagen:

- **Raven:** schwarze Rüstung mit Materialdetails, cyanfarbene Leuchtlinien, schwarze Haare mit blauen Spitzen und eine Impulspistole.
- **Shadepi:** breiter Kasa-Hut, maskiertes Gesicht mit roten Augen, segmentierte Rüstung, Mantel mit weißem Drachen und rotes Katana.

Die PNGs haben einen echten transparenten Hintergrund. Die Originalbilder enthalten jeweils 32 generierte Schlüsselposen. Daraus sind die Stand-, Lauf-, Angriffs- und Treffersequenzen für das Spiel zusammengesetzt. Stand und Treffer verwenden die Ruhepose; beim Laufen werden die beiden Schrittposen mit der Ruhepose kombiniert.

| Dateien | Verwendung |
| --- | --- |
| `assets/sprites/heroes/raven.png`, `shadepi.png` | Fertige Spielatlanten, je 1024 × 5120 Pixel |
| `tools/hero_sources/*-keyframes.png` | Ursprüngliche Bildtafeln, je 1536 × 1024 Pixel |
| `tools/hero_sources/prompts.json` | Bildbeschreibungen und Rasterdaten |
| `tools/compile_heroes.py` | Erneute Zusammenstellung mit Python und Pillow |
| `scripts/` und die Projektdateien | Integration im Godot-Projekt v0.12.0 |

## Raster und Fußpunkt

**Spielatlanten:** Acht Spalten mit je acht Animationsbildern pro Zeile. Ein Einzelbild misst 128 × 160 Pixel. Die Füße liegen bei Y = 152; das Spiel zeichnet die Bilder mit Faktor 0,5.

| Zeilen, ab 1 gezählt | Animation |
| --- | --- |
| 1–8 | Stand |
| 9–16 | Laufen |
| 17–24 | Angriff |
| 25–32 | Treffer |

Die acht Richtungen pro Gruppe sind: unten, links, rechts, oben, oben-links, oben-rechts, unten-links, unten-rechts.

**Originaltafeln:** Acht Spalten und vier Zeilen, je 192 × 256 Pixel pro Rasterfeld. Die Richtungen entsprechen der Liste oben; die Zeilen zeigen Stand, linken Schritt, rechten Schritt und Angriff. Einzelne Waffenspitzen reichen über die Rasterlinien hinaus. Das Packskript ordnet diese Bildteile ihrer Figur zu und stellt die Fußpunkte einheitlich auf.

## Im Spiel verwenden

Die Windows-Fassung v0.12.0 enthält die neuen Figuren bereits. ZIP vollständig entpacken und `Shadepi-Echos-in-Neon.exe` starten.

Im vollständigen Repository v0.12.0 sind die Figuren bereits integriert; `project.godot` öffnen. Godot 4.7.2 importiert die PNGs beim nächsten Öffnen. Die vollständige Spieleranleitung liegt als `Spiel-README.md` bei. Eigene Figuren unter `assets/custom/` haben weiterhin Vorrang; die bisherigen Pixelraster werden unterstützt.

Zur erneuten Zusammenstellung: `python tools/compile_heroes.py` aus dem Projektordner ausführen. Das Skript benötigt Pillow und verwendet die vorhandenen Originalbilder.

## Prüfung

Die wiederhergestellte v0.12 bestand lokal unter Windows mit Godot 4.7.2 **177 Prüfungen ohne Fehler** und einen Starttest. Auch der [GitHub-Build des manuellen Uploads](https://github.com/Inrouder/ShadepiRPG/actions/runs/41922510900) ist erfolgreich.

Die früheren Angaben von 301 Prüfungen und 171 Prüfungen mit einem eigenen Sprite stammen aus dem ursprünglichen Entwicklungsbericht. Diese damaligen Durchläufe wurden für die Rekonstruktion nicht in diesem Umfang reproduziert. Ein vollständiger manueller Spieldurchlauf steht weiterhin aus.
