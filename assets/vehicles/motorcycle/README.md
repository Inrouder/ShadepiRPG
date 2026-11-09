# Motorrad-Fahrposen · v0.40.0 · CodexAI

`riding.png` ist ein direkt generierter HQ-Pixelatlas mit dem bestehenden roten Motorrad und seinen beiden Fahrern als tatsächlichen Bildreferenzen. Shadepi bleibt vorne mit schwarzem Kasa, geschlossener Maske, taktischer Weste und Stoffbahnen; Raven hinten mit schwarz-blauem Haar, schwarzer Ausrüstung und Cyan-Linien. Raven bleibt 160 cm; aus der Top-down-Projektion keine neue Körpergröße ableiten. Das geparkte Motorrad und die normale Figurenbibliothek bleiben gültig.

**Tatsächliche Quelle: 1254×1254, drei Spalten/Reihen, Zellen 418×418.** Das angeforderte größere Raster wurde vom Bildwerkzeug nicht geliefert; keine Hochskalierung als Detailgewinn ausgeben. Die unverändert kopierte Quelle besitzt echte transparente Ränder und genügend Materialdetails für die dargestellte Größe. Maßstab 78/418, etwa dieselbe sichtbare Radstandlänge wie das vorherige 84/627-Bild. Normale Verfolgung bei 640×360 und vergrößerte Vergleichstafel im Renderer gesichtet.

| Zelle | Inhalt |
| --- | --- |
| 0 / 1 | Starke / leichte Linkslage, Fahrer und Motorrad lehnen gemeinsam |
| 2 | Gerade Fahrt |
| 3 / 4 | Leichte / starke Rechtslage |
| 5 | Bremsen, vorgelagerte Körper-/Gabelhaltung |
| 6 / 7 | Federung komprimiert / zurückfedernd |
| 8 | Zusätzlicher Schussentwurf mit eingebranntem Mündungsfeuer; **nicht aktiv**. Kein Ersatz für eine separat registrierte Pistolen-/Schussanimation. |

`motorcycle_art.gd` registriert die acht verwendeten Bilder am tatsächlichen hinteren Reifenkontakt (`REAR`); daraus berechnet sich der Anker um 165 Quellpixel darüber. Dadurch bleibt derselbe Kontaktpunkt auf dem Asphalt, während sich Körperhaltung und vorderer Radbereich verändern. Keine zusätzliche Rotation des ganzen alten Einzelbilds. Zwei Auspuffkontakte je aktiver Zelle führen den vorhandenen Turbo-FX mit. Leichte/starke Kurvenlage folgt der wirklichen Lenkgeschwindigkeit, Bremsen dem vorhandenen Rückwärts-/Bremsinput. Geradeausfolge enthält kurze Kompressions-/Rückfederungsphasen und pausiert mit der vorhandenen Fahrzeuguhr.

Keine programmgesteuerten Zeichen-/Freistellschritte. Der Generator lieferte neun Bilder; acht sind in diesem Block tatsächlich eingebunden. [Spielbilder und Filme](../../../docs/fahrzeugbewegung.md) · [Nachweis und Grenzen](../../../docs/arbeiten/fahrzeugbewegung-v040.md).
