# Tower-Posen, Außenansicht und KOBAN-TEC · v0.33.0 · CodexAI

**Laufzeitkorrektur v0.35.1 · CodexAI:** Unveränderte Quellbilder: `tower_escape.gd` beginnt auf `rooftop.png` am gespeicherten Aufsetzpunkt. Erst nach dem Abheben und Verlassen der Dachkante folgt `exterior.png` als Blick auf die Fassade darunter. Der Aerodyne fällt von oben am Balkon vorbei und fängt sich darunter; kein Start auf dem Balkon. Die unveränderte Fahrzeugzelle und Düsenanker in `cinematic_aerodyne.gd` bleiben erhalten. [Aktuelle Aufnahmen](../../../docs/tower-inszenierung.md).

## Aktive Quellen

- `kenzo-poses.png`: unverändert generierter transparenter Atlas, 1536×1024, 2×2 Zellen. Griffpaar mit Raven, schwer verletzter kniender Kenzō, Raven allein am Extraktionsdeck und zerstörter/zusammengebrochener Kenzō. Referenzen waren die tatsächlichen v0.32.2-Bildkarten aus den normalen Kenzo-/Raven-Gameplay-Sprites. Ruhige dunkle Pixelmaterialien, kleiner erwachsener Kopf, Raven 160 cm, gleiche Masken-/Haar-/Kostümmerkmale. Kein neues Figurenmodell.
- `exterior.png`: unverändert generierte eigene HQ-Pixel-Außenansicht des Penthouse-Zugangs, abgeleitet aus den vorhandenen Dach-/Suite-Kulissen. Ohne eingemalte Figuren, Fluggerät oder Explosion; diese werden in Godot animiert. Die Ansicht ist eine Filmkulisse, keine zusätzliche begehbare Karte.
- `koban-banner.png`: unverändert generierter opaker lokaler Wand-/Banner-Ausschnitt. Referenz war die per Godot gerenderte Region `(1070,15,210,250)` des originalen Hangarbilds. Nur in dieser Wandregion wird das alte Zeichen durch KOBAN-TEC ersetzt; Räume, Konsolen und Bodenkollisionen werden nicht neu gezeichnet.

KOBAN-TEC folgt den archivierten Merkmalen: roter futuristischer Helm, Waffen/Klingen, geometrischer Rahmen, Wortmarke und K-Monogramm auf dunklem Grund. Das Chat-Original liegt weiterhin nicht als lokale Datei vor; dieses Banner ist eine Umsetzung anhand der archivierten Beschreibung, kein behauptetes unverändertes Original-Logo. [Archiv Teil 3](../../../docs/universum/teil-3/README.md), [Firmenquelle](../../../docs/universum/teil-4/texte/07-Firmen-der-Zeitliene.txt).

## Anzeige und Metadaten

[tower_tableau.gd](../../../scripts/tower_tableau.gd) enthält die vier Atlasregionen, Anker und Maßstäbe. Die Griffpose verankert Kenzōs Füße; Ravens Füße liegen links daneben. Kniepose, Raven am Deck und Endpose besitzen eigene Anker. Die liegende Endpose wird nach Körperlänge statt liegender Höhe skaliert. Echte Transparenz und lineare Verkleinerung wie bei den benachbarten normalen Helden; kein harter Alpha-Freistellshader.

[tower_extraction.gd](../../../scripts/tower_extraction.gd) bindet die sichtbare Raven-Pose an ihren tatsächlichen Trefferpunkt. Die verdeckten normalen Sprites bleiben keine zweite sichtbare Figur. Kenzō bleibt lebendig und kann nicht angegriffen werden, bis die Daten gesichert sind. Erst danach folgt die tote, abgedunkelte Endpose.

[painted_world.gd](../../../scripts/painted_world.gd) zeichnet den opaken Banner-Ausschnitt an `HANGAR_BRAND_RECT` über die historische Quelle. Derselbe Aufruf wird im normalen Hangar und beim Hangar-Abflug verwendet. Die alten Quelldateien bleiben nachvollziehbar erhalten, zeigen im aktiven Spiel an dieser Stelle aber nicht mehr das frühere Emblem. Die Stilbibel-Weltübersicht berücksichtigt ebenfalls die aktive Brandschicht.

[tower_escape.gd](../../../scripts/tower_escape.gd) verwendet für Fluggerät und Explosions-/Triebwerksbilder die vorhandenen Fahrzeug-/FX-Atlanten. Die neue Filmkulisse allein behauptet keine bereits explodierte Spielwelt. [Ablauf, Bedienung und Bilder](../../../docs/tower-extraktion.md).
