# Heiligtum-Posen · v0.30.0 · CodexAI

Aktiv ist `poses-seated.png`: 1536 × 1024 mit drei Spalten und zwei Reihen. Erste Reihe: Shadepi mit seinem tatsächlich passenden Stuhl, dann Raven beim Griff und beim abgefangenen Handgelenk. Zweite Reihe: Raven sitzend am Bett, schlafend und aufwachend. Die Regionen/Anker stehen in `scripts/sanctuary_tableau.gd`; wegen einer leicht über die nominelle Zelle ragenden Haarsträhne wird die Schlafregion gezielt als 544 Pixel breiter Ausschnitt gelesen. Keine PNG-Pixel wurden nachträglich umgeschrieben.

Die Quelle enthält weiche Alpha-Reste außerhalb der Figuren. `pixel_cutout.gdshader` verwirft diese beim Darstellen und erhält harte Pixelkanten. Die Schlaf-/Sitzskalierung richtet sich nach Körperlänge beziehungsweise Haltung. Der Stuhl ist Teil der Sitz- und Kontaktposen, statt als zweite unpassende Grafik darunterzuliegen.

Aktive Raumquellen: `assets/world/painted/chamber-connected.png` mit integrierter Tür und `compensator-clear.png` ohne eingebrannten Stuhl. Die Originale bleiben erhalten. Die neuen Grafiken beziehen sich auf die vorhandenen Spielquellen und die konkreten Screenshots aus Fehlerbericht 8.

## Erhaltene Quellgruppe v0.29.0 · CodexAI

`poses.png`: originales transparentes HQ-Pixel-Quellblatt, 1536 × 1024, 2 × 2 Zellen à 768 × 512; keine nachträgliche Bildbearbeitung.

| Zelle | Pose | Anker in Quellpixeln | Maßstab |
| --- | --- | --- | --- |
| 0 | Shadepi sitzend, allein | 421, 491 | 0,14 |
| 1 | Raven greift nach der Maske | 330, 491 | 0,14 |
| 2 | Shadepi hält ihr Handgelenk | 330, 491 | 0,14 |
| 3 | Raven schlafend | 372, 476 | 0,105 |

Die ersten drei Anker beziehen sich auf Shadepis Stiefel am Sessel. Die kleinere Schlafskalierung richtet sich nach Körperlänge statt liegender Höhe. So wird eine liegende Figur nicht übergroß. Das Blatt wird direkt per AtlasTexture angezeigt, ohne neue bearbeitete Ableitungen. Runtime: `scripts/sanctuary_tableau.gd`.

Raum: `assets/world/painted/compensator.png`, 1585 × 992. Gestaltungsreferenzen sind das vorhandene `chamber.png` und die tatsächlichen Shadepi-/Raven-Spielfiguren. Das im Nutzertext erwähnte weitere Raumbild lag nicht vor. Weiße Übertragung aus dem bereits vorhandenen `assets/memories/legacy/transfer.png` wiederverwendet.
