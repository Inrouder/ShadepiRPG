# Auftragsannahme und Dachauftritt · v0.43.0 · CodexAI

`poses.png` ist die unverändert kopierte transparente Bildwerkzeugquelle vom 9. November 2026; Original außerhalb des Repos: `/workspace/generated_images/exec-ebbec1c5-01e5-4c1a-910e-8e050697148e.png`. Tatsächlich **1774 × 887**, kein nominelles 1792er-Raster annehmen. Ausschnitte und Bodenanker stehen in `scripts/chapter_one_intro.gd`.

| Zelle | Handlung | Bodenanker im Ausschnitt |
| --- | --- | --- |
| 0 | Raven erreicht Terminal | 244, 428 |
| 1 | Raven bestätigt Auftrag | 245, 428 |
| 2 | Raven kontrolliert Pistole | 246, 428 |
| 3 | Raven führt Pistole zum Holster | 242, 427 |
| 4 | Shadepi kauert auf dem Sims | 253, 406 |
| 5 | Shadepi blickt hinunter | 254, 406 |
| 6 | Shadepi landet in Kniebeuge | 252, 413 |
| 7 | Shadepi richtet sich auf | 258, 408 |

Quell-X: 0 / 443 / 887 / 1330; Quell-Y: 0 / 443; Breiten 443 / 444 / 443 / 444; Höhen 443 / 444. Außenraum mit echter Transparenz, sehr geringe Alpha-Restwerte unter 0,02 an leeren Ecken; kein Freistellshader. Scale 0,149: Ravens sichtbare Standhöhe rund 59 Weltpixel, im normalen Heldenmaßstab. Lineare Abtastung wie die aktiven Helden. Im Dachzwischenschnitt Faktor 1,8 als eigener Kameramaßstab, kein Lore-Größenwechsel.

Referenzen: tatsächlich betrachtete aktive Figurenkarten `figur-raven.png` / `figur-shadepi.png`; dieselben Kostüme, rote Raben-Schulterzeichen und Cyan, schwarzer Kasa, geschlossene Maskensegmente/rote Linsen, Weste und dunkler Stoff. Hintergrund aus vorhandener `assets/world/painted/rooftop.png`, linke Skyline ohne Konzernlogo und ohne sichtbaren Tower-Landeplatz. Keine neue Spielkarte.

Ravens Terminal-Handpunkt (100,145) wird mit dem Monitorpunkt `apartment_point(160,240)` registriert. Normale Figur einschließlich beider Schatten und Occluder vollständig verstecken; genau ihren vorherigen Sichtbarkeitszustand wiederherstellen. Fallpose wird über ihren Bodenanker bewegt, nicht als stehender Körper gedreht. Keine Waffenfunktion auslösen, wenn Raven lediglich prüft.

[Spielaufnahmen, Filme und Abnahme](../../../docs/kapitel1-auftakt.md) · [Arbeitsnachweis](../../../docs/arbeiten/kapitel1-v043.md).
