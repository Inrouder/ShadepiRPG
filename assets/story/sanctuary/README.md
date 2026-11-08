# Heiligtum-Posen · v0.29.0 · CodexAI

`poses.png`: originales transparentes HQ-Pixel-Quellblatt, 1536 × 1024, 2 × 2 Zellen à 768 × 512; keine nachträgliche Bildbearbeitung.

| Zelle | Pose | Anker in Quellpixeln | Maßstab |
| --- | --- | --- | --- |
| 0 | Shadepi sitzend, allein | 421, 491 | 0,14 |
| 1 | Raven greift nach der Maske | 330, 491 | 0,14 |
| 2 | Shadepi hält ihr Handgelenk | 330, 491 | 0,14 |
| 3 | Raven schlafend | 372, 476 | 0,105 |

Die ersten drei Anker beziehen sich auf Shadepis Stiefel am Sessel. Die kleinere Schlafskalierung richtet sich nach Körperlänge statt liegender Höhe. So wird eine liegende Figur nicht übergroß. Das Blatt wird direkt per AtlasTexture angezeigt, ohne neue bearbeitete Ableitungen. Runtime: `scripts/sanctuary_tableau.gd`.

Raum: `assets/world/painted/compensator.png`, 1585 × 992. Gestaltungsreferenzen sind das vorhandene `chamber.png` und die tatsächlichen Shadepi-/Raven-Spielfiguren. Das im Nutzertext erwähnte weitere Raumbild lag nicht vor. Weiße Übertragung aus dem bereits vorhandenen `assets/memories/legacy/transfer.png` wiederverwendet.
