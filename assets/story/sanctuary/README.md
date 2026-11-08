# Heiligtum-Posen · v0.32.0 · CodexAI

Aktiv ist **`poses-game.png`**: 1536 × 1024 mit drei Spalten und zwei Reihen. Erste Reihe: Shadepi mit Kompensatorstuhl, dann Raven beim Griff und beim abgefangenen Handgelenk. Zweite Reihe: Raven sitzend am Bett, schlafend und aufwachend. Die Regionen/Anker stehen in `scripts/sanctuary_tableau.gd`; der Schlafausschnitt ist 552 Pixel breit, um das links über die nominelle Zelle reichende Haar vollständig zu erhalten, während die Sitzregion vor dieser Nachbarfigur endet.

**Gestaltungsreferenz v0.32.0 · CodexAI:** Die tatsächlichen v0.31.0-Helden aus `assets/sprites/heroes/shadepi.png` und `raven.png`, per Godot als Vorder-/Seitenansichten gerendert (`tools/sanctuary_reference.gd`), bestimmen Palette, Proportionen und Materialwirkung. Das alte Blatt dient nur als Posen-/Layoutreferenz. Neues Blatt mit Bildgenerierung erstellt; unveränderte generierte Quelle, keine nachträgliche PNG-Bearbeitung. Merkmale gemäß Universumsarchiv Teil 1–3, Raven verbindlich 160 cm. [Vergleich und Prüfung](../../../docs/heiligtum-figuren-v032.md).

Ruhige dunkle Pixelcluster ersetzen die vorherige körnige Bronze-/Weißtextur. Die Quelle besitzt echten transparenten Außenraum; der alte Shader, der schwache Alpha-Werte verwarf und alle übrigen Pixel undurchsichtig machte, wird hier **nicht mehr verwendet**. Lineare Verkleinerung wie bei den normalen `PixelActor`-Helden statt abweichender scharfer Unterabtastung. Sitz-/Schlafmaßstab richtet sich nach Körperlänge und Haltung. Der Stuhl bleibt Teil der zusammen passenden Kontaktgrafiken.

Aktive Raumquellen: `assets/world/painted/chamber-connected.png` mit integrierter Tür und `compensator-clear.png` ohne eingebrannten Stuhl. Die Originale bleiben erhalten. Die neuen Grafiken beziehen sich auf die vorhandenen Spielquellen und die konkreten Screenshots aus Fehlerbericht 8.

## Erhaltene Quellgruppe v0.30.0 · CodexAI

`poses-seated.png` bleibt als historische Quelle erhalten, wird im Spiel aber durch das neue Blatt ersetzt. Es hatte dieselben sechs Posen mit gröberer Textur und grauem Alpha-Hintergrund; die frühere Laufzeit verwendete dafür `pixel_cutout.gdshader`. `tools/sanctuary_pose_gallery.gd --before` rekonstruiert nur für Vergleichsbilder diese alte Darstellung.

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
