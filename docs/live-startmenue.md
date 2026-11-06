# Interaktives Startmenü

![Startmenü im Godot-Renderer](startmenue.png)

Das Menü verwendet zwei getrennte Bildquellen: `assets/menu/start-city.png` für Skyline und weißen Drachen sowie `assets/menu/start-heroes.png` für die freigestellten Figuren. Die früher im Stadtbild eingebrannten Personen sind entfernt.

Shadepis Darstellung orientiert sich an der Figur aus `03-Berschreibung-Shadepi.pdf` und den archivierten Referenzen: breiter schwarzer Kasa, segmentierte Maske mit roten Augenlinsen, moderne taktische Weste, Taschen und dunkle Stoffbahnen. Raven ist relativ zu Shadepi kleiner dargestellt; ihre verbindliche Größe bleibt 160 cm. Lange schwarz-blaue Haare, rote Augen, goldfarbenes Septum-Piercing, rote Schulterembleme und Cyan-Linien folgen den Referenzblättern.

## Bewegung und Bedienung

- Die Maus steuert eine gegensinnige Verschiebung von Stadt und Figuren. Menüfokus per Tastatur oder Controller erzeugt ebenfalls eine Reaktion.
- Ein unterteiltes Figurenmesh verformt äußere Haarsträhnen, Schalenden und freie Stoffbereiche. Gesichter und Füße bleiben dabei verankert.
- Regen in mehreren Geschwindigkeiten, Flugverkehr und kleine Wasserringe beleben das Dach. Ein separater Shader ergänzt Nebel, Neonlicht und eine dezente Vignette unterhalb der Menüschrift.
- Fokus und Hover erhalten eine sichtbare Kontur und eine kurze Skalierungsanimation. Klicks erzeugen einen kleinen Lichtimpuls.
- `Reduziert` deaktiviert den zusätzlichen Bildschirmfilter und reduziert Regen und Bewegung. Verdeckte Startmenüs stoppen ihre Animations- und Eingabeverarbeitung vollständig.
- Kapitel 1 nutzt denselben Menürahmen wie die anderen Szenen. Seine vorgemerkte Koop-Auswahl bleibt beim Pausieren erhalten; die Startgrafik erscheint nur vor Spielbeginn.

## Visuell prüfen

`godot --audio-driver Dummy --script res://tools/menu_gallery.gd` benötigt ein Display mit echtem Renderer (auch Xvfb/Mesa ist geeignet). Das Werkzeug schreibt neutrale, Wind-, Fokus-, reduzierte und Pause-Aufnahmen nach `/tmp/shadepi-menu-*.png`. Die automatisierten Gameplay-Prüfungen kontrollieren zusätzlich Parallax, Grafikoptionen, den angehaltenen Hintergrund und den Kapitel-1-Menüablauf.

Geprüft mit Godot 4.7.2: 303 Gameplay-/Menüprüfungen, 46 Fahrzeugprüfungen, 240 Story-Prüfungen und 20 NPC-/Dive-Prüfungen ohne Fehler. Die Screenshots wurden zusätzlich unter OpenGL Compatibility mit Xvfb/Mesa gerendert; dabei wurden auch die beiden neuen Shader ausgeführt.

Die neuen Menüillustrationen wurden aus den vorhandenen Quellen erstellt; die unveränderten Nutzerquellen bleiben im Universum-Archiv dokumentiert. Gameplay-Sprites werden von dieser Menüüberarbeitung nicht ersetzt.
