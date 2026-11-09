# Eisbad-Posen · v0.38.0 · CodexAI

`poses.png` zeigt acht körperliche Phasen von Raven sowie zwei gemeinsame Stütz-/Behandlungsmomente mit Shadepi. Quelle: direkte HQ-Pixelgenerierung anhand der tatsächlich gesichteten normalen Figurenkarten Raven/Shadepi und der aktiven `painted/hideout.png`-Kulisse. Eine erste Quelle wurde wegen Nachbarfragmenten und zu engen Paarzellen gezielt überarbeitet. Die aktive überarbeitete PNG wurde unverändert kopiert; keine programmgesteuerte Bemalung oder Alpha-Erzwingung.

Raven behält ihre etablierte taktische Kleidung, schwarz-blaue Haare, rote Schulterzeichen und Cyan-Linien; 160 cm. Shadepi bleibt vollständig maskiert mit Kasa, Schal, Weste und dunklen Stoffbahnen; keine neue Zentimetergröße. Die Umsetzung übernimmt den Anschluss, das Eiswasser und die Kryospray-Rettung aus Roman Kapitel 2; die Bekleidung bleibt aus Konsistenzgründen die aktive Spielfassung.

Die Quelle ist 1536×1024, vier nominelle Spalten und zwei Reihen. **Tatsächliche Ausschnitte in `ice_bath_sequence.gd` verwenden:** Zelle 5 ist auf 352 Pixel Breite begrenzt, um keine Fragmente der Nachbarfigur zu übernehmen. Die beiden Paarposen beginnen bei X=744 beziehungsweise X=1128 und besitzen 384 beziehungsweise 408 Pixel Breite. So bleiben vollständige Umhänge, Haare, Hände und Hüte erhalten. Nicht blind das nominelle 384er-Raster als Zuschnitt verwenden.

| Pose | Handlung |
| --- | --- |
| 0 | Am Wannenrand sitzen, Verbindung am Kragen anschließen |
| 1 | Knie einziehen und Körper absenken |
| 2 | Kontrolliert zurücklehnen |
| 3 | Angeschlossene Ruhe im Wasser |
| 4 | Rückkehrreaktion, nach Luft ringen |
| 5 | Erschöpft am Rand sitzen, während das Spray geholt wird |
| 6 | Shadepi stützt Raven und sprüht auf ihre obere Brust-/Anzugfläche |
| 7 | Stabilisiert sitzen, Spray abgesenkt, Kontakt am Arm |

Weltmaßstab 0,125; gemessene Sitz-/Hüftanker pro Ausschnitt. Der größere Shader-Zeichenrahmen hält auch die diagonal zurückgelehnte Kopf-/Haarpartie vollständig im Bild. Normale Figuren und ihre Kontaktschatten sind während entsprechender Ersatzposen transparent; sie werden nach Behandlung oder Abbruch vollständig zurückgesetzt.

Der vorhandene vordere Wannen-/Wasserbereich wird als exakt registrierte Ebene aus der bestehenden Raumtextur über eingetauchte Körperteile gezeichnet. Anschlusskabel verwendet ein kleines Stück der vorhandenen Schlauchtextur und einen festen Pumpenanschluss sowie den pro Pose bestimmten Kragenkontakt. Kleine lokale Atem-/Sprühbewegung ist Shader-FX, kein zusätzlicher gezeichneter Frame. Kein neues Becken, Stuhl oder Raum in der PNG. [Szenenablauf und echte Bilder](../../../docs/eisbad.md).
