# Aerodyne-Rumpfanimation · v0.37.0 · CodexAI

`airframe.png` erweitert den tatsächlich verwendeten Aerodyne aus der linken oberen Zelle von `assets/world/hq/vehicles.png`. Einmalig mit dieser vorhandenen HQ-Pixelgrafik als Bildreferenz generiert, danach unverändert kopiert. Dunkles, gebrauchtes bronze-/gunmetallenes Fluggerät, langes Cyan-Cockpit, zwei große hintere Triebwerke, Leitungen und schmale Nase bleiben erhalten. Keine neue Fahrzeugidentität, keine programmgesteuert bemalten Pixel.

1536×1024, drei Spalten und zwei Reihen, Zelle 512×512, echter transparenter Außenraum:

| Bild | Zustand |
| --- | --- |
| 0 | Geschlossene Kabine, abgeschaltete Mechanik |
| 1 | Kabine beginnt sich rechts zu öffnen |
| 2 | Halb geöffnete Kabine |
| 3 | Offene Kabine mit Zugang |
| 4 / 5 | Geschlossene Kabine, unterschiedliche Phasen der laufenden Triebwerksmechanik |

`aerodyne_art.gd` enthält gemessene Rumpfanker je Zelle: `(268,256)`, `(256,256)`, `(244,256)`, `(268,258)`, `(256,258)`, `(244,258)`. Diese gleichen unterschiedliche transparente Ränder aus. Düsenzentren relativ zum registrierten Rumpf: `(-82,186)`, `(82,186)` Quellpixel. Im filmischen Renderer entsprechen 512 Quellpixel 240 Weltpixeln vor dessen gemeinsamer Perspektivprojektion. Rumpf und Abgasstrahlen verwenden denselben Drehpunkt und dieselbe Skalierung; die PNG enthält keine eingebrannten Abgasstrahlen.

Ruhender Rumpf nutzt Bild 0; bei Schub läuft die Folge 4–5–4–0 mit acht Bildern pro Sekunde. Öffnen/Schließen durchläuft 0–1–2–3 beziehungsweise umgekehrt. Eine offene Tür unterbricht die Triebwerksfolge; die übergeordnete Szenenuhr steuert Bewegung und Pause. Der Flug, die Landung, das geparkte Dachschiff und die filmischen Start-/Seeansichten lesen dieselbe Quelle. Das alte eingemalte Fahrzeug im normalen Erkundungs-Hangar ist weiterhin ein gesonderter Bestand; dessen Austausch steht in der [Roadmap](../../../docs/cinema-roadmap.md).

Diese sechs Zustände sind ein erster konkreter Ausbau. Echte Seiten-/Kurven-/Rollansichten, Fahrwerk und mehr Cockpit-/Einsteigeposen bleiben weiterer Spritebedarf. Ein gedrehtes Bild ist keine zusätzlich gezeichnete Ansicht.
