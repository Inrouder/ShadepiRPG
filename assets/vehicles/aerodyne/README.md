# Aerodyne-Rumpfanimation · v0.37.0 · CodexAI

**Erweiterung v0.40.0 · CodexAI:** `banks.png` enthält sechs 512×512-Zellen (1536×1024), unmittelbar anhand dieses Rumpfs generiert. Erste Quelle wegen weißer/transluzenter Matte verworfen und gezielt neu freigestellt; die korrigierte RGBA-PNG unverändert kopiert. Keine programmgesteuerte Bemalung oder Alpha-Erzwingung. Metall, Cockpit, zwei Triebwerke und Lichtakzente bleiben dieselbe Fahrzeugidentität.

| Zelle | Inhalt / Verwendung |
| --- | --- |
| 0 / 1 | Starke / leichte Linkslage |
| 2 | Gerade Referenzansicht; im Spiel bleibt dafür der vorhandene mechanische Atlas aktiv |
| 3 / 4 | Leichte / starke Rechtslage |
| 5 | Luftbremse mit sichtbar ausgeklappten Seitenflächen |

Tatsächlich gemessene Cockpitanker und die beiden Düsenzentren je Ansicht stehen in `aerodyne_art.gd` (`BANK_ANCHORS`, `BANK_NOZZLES`). Quellpunkte vor Abgas-FX auf dieselbe 240/512-Skalierung bringen. Klare Pixelphasen verwenden; Überblendung verschobener Silhouetten führte zu durchsichtigen Fahrzeugen und wurde verworfen. Die Kabine verwendet weiterhin die sechs mechanischen Bilder unten; beim Öffnen müssen Rumpf **und Düsenanker** sofort zur geraden Ansicht zurückkehren. Banklage ist ein separates Argument in `cinematic_aerodyne.gd`, nicht identisch mit dem bisherigen Heading-/Drehwinkel. Anflug, Abfangen, Landung und Standbild behalten so ihre Weg- und Kontaktpunkte.

[Neue Spielbilder und Bewegungsfilme](../../../docs/fahrzeugbewegung.md) · [Arbeitsnachweis](../../../docs/arbeiten/fahrzeugbewegung-v040.md).

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

Ruhender Rumpf nutzt Bild 0; bei Schub läuft die Folge 4–5–4–0 mit acht Bildern pro Sekunde. Öffnen/Schließen durchläuft 0–1–2–3 beziehungsweise umgekehrt. Eine offene Tür unterbricht die Triebwerksfolge; die übergeordnete Szenenuhr steuert Bewegung und Pause. Der Flug, die Landung, das geparkte Dachschiff und die filmischen Start-/Seeansichten lesen dieselbe Quelle. Seit v0.39.0 verwendet auch der normale Erkundungs-Hangar diesen separaten Renderer.

Diese sechs Zustände sind ein erster konkreter Ausbau. v0.40.0 ergänzt die oben beschriebenen Kurvenlagen. Vollständige Seiten-/Unterseiten-/360°-Rollansichten, Fahrwerk und mehr Cockpit-/Einsteigeposen bleiben weiterer Spritebedarf. Ein gedrehtes Bild ist keine zusätzlich gezeichnete Ansicht.
