# Hangar-Abflug · v0.30.0 · CodexAI

- `hangar-empty.png`: passende HQ-Pixel-Variante der vorhandenen Hangarkulisse ohne eingebranntes parkendes Fluggerät, mit Dachschleuse zum Nachthimmel.
- `cockpit.png`: vier Quellbilder, 2 × 2 Zellen. Start, stotterndes System mit erhobener Hand, Schlag auf die Armatur, wieder laufende Systeme. Die tatsächliche PNG-Größe bestimmt die Zellmaße.

Außen wird der vorhandene Aerodyne aus `vehicles.png` animiert, ohne ein zweites unveränderliches Fluggerät im Hintergrund. Die Figuren beim Einsteigen nutzen ihre bestehenden Sprites. Staub stammt aus den vorhandenen Erinnerungs-FX; Motor-/Klopfsounds aus der bestehenden Soundbibliothek. Ablauf und Pausenführung: `scripts/hangar_departure.gd`.
