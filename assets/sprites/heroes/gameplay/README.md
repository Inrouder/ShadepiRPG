# Verworfene Gameplay-Variante · v0.45.0 · CodexAI

**Seit v0.46.1 · CodexAI auf ausdrücklichen Nutzerwunsch nicht mehr aktiv.** Die Originale `assets/sprites/heroes/raven.png` und `shadepi.png` sind wieder Standard. Diese Dateien bleiben nur zur Nachvollziehbarkeit erhalten; keine automatische Wiederaktivierung.

Die neuen PNGs sind unveränderte Bildwerkzeugquellen vom 9. November 2026. Raven: **1247×1261**, Shadepi: **1263×1245**. Pro Figur 64 Posen: acht Richtungen mit Bereitschaft, vier Gehphasen, Ausholen, Auslösen und Trefferreaktion. Eigene Charge-/Kick-/Handblitzbilder bleiben zusätzlich eingebunden.

**Kein blindes 8×8-Raster zuschneiden:** Die nominalen Zellen besitzen ungleichmäßige Abstände. `poses.json` enthält pro Pose den tatsächlich vermessenen vollständigen Ausschnitt, Bodenanker, sichtbare Höhe, Maßstab und Pistolenaustritt. Ermittelt an den zusammenhängenden Körper-Silhouetten der unveränderten PNGs. `hero_art.gd` wählt einen registrierten `AtlasTexture`-Ausschnitt je Figur; normaler Körper und Schatten teilen diese Quelle. Metadaten werden je Actor geladen, ohne dauerhaften globalen Ressourcencache.

Die Quellreihen sind Süd / Nord / Ost / West / Südwest / Südost / Nordwest / Nordost. `HeroArt.ROWS` überführt die bisherige Spielrichtungsfolge. Bereitschaft und Gehen sind auf rund 58 sichtbare Weltpixel kalibriert; der Collider bleibt unverändert. Trefferposen behalten ihren gebeugten Körper. Nearest erhält die Pixelcluster und verhindert wechselndes Weichzeichnen nach Sonderaktionen. Mündungsanker bleiben in Quellpixeln innerhalb der tatsächlichen Region.

Identität: Raven 160 cm, schwarze Haare mit blauen Enden, rote Augen, goldener Septumhinweis soweit im kleinen Maßstab sichtbar, Cyan-Linien/Kragen und rote Raben-Schulterzeichen. Shadepi geschlossene segmentierte Maske mit roten Linsen, schwarzer Kasa, Schal/Weste/Protektoren und Stoffbahnen sowie rotes Katana. Keine bestätigte Körpergröße für Shadepi erfinden.

Originale der Generierung außerhalb des Repos: `/workspace/generated_images/exec-678fc370-a6ca-4f5d-a641-f9d1290d74a7.png` (Raven), `exec-55d82d0b-b962-44f3-8f58-1822529267eb.png` (Shadepi). Referenzen: aktive Figurenkarten und Kapitel-1-Kontaktposen; keine neue Figurenidentität. Die Dateien wurden kopiert, nicht per Skript übermalt oder nachträglich verpixelt.

[Vorherige Sprites als Backup](../backup-v0441/README.md) · [Spielvergleich und Bericht](../../../../docs/fehlerbericht-v045.md).
