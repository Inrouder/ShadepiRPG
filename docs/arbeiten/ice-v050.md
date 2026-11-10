# Konsistenzauftrag und Arbeitsnachweis: ICE-Kampf

**v0.50.0 · CodexAI · 10. November 2026.** [Bilder und Film](../ice-kampf-v050.md) · [Vorlage](../vorlagen/konsistenz-auftrag.md).

## Auftrag und Ausgangslage

- **Nutzerziel:** größere ICE-Arena, animierter Boss, ausweichbare Kugelsalven, Deckung und wiederholte Vorstöße mit nahen Treffern.
- **Ausgang:** `43c30ea`, v0.49.0. Arbeitsbaum sauber. Alle Remote-Branches vor Arbeit abgerufen, `origin/main` identisch; Entwicklungsbranches bis ClaudeHelper v0.48.0 enthalten keinen neueren Spielstand. Vor Sicherung erneut vergleichen.
- **Erhalten:** normale Originalhelden, bisherige Virenwellen, vollständige Eisbad-/Storyabfolge, fremde Tower-/Menü-/Seeänderungen und alte kompatible Relais-Spielstände.
- **Betroffen:** Kapitel 2, Datenknoten 3; `chapter_two.gd`, Kapitel-HUD, eigener Wächter/Kugeln und Musikslot. Keine neue Lore.

## Referenzen und unveränderte Merkmale

| Zweck | Tatsächlich gesichtet | Übernommen |
| --- | --- | --- |
| Wächter | `assets/sprites/npcs/ice-guardian.png`, Figurenkarte ICE | sechs gepanzerte Spitzen, violetter Kristall, cyanfarbene Iris/Schaltungen |
| Spielumgebung | `assets/world/painted/dive.png` | HQ-Metall-/Kristalltexturen, violette/Cyan-Farbfamilie, feste Datenwände |
| Raven | Stilbibelkarte `figur-raven.png`, aktive Originalquelle und Laufzeitdarstellung | 160 cm bleibt Kanon; normale Silhouette und Handimpulsanker bleiben |
| Welt-/Kontakt-/UI-Regeln | KONSISTENZ, Art Direction, Figurenkatalog, Arbeitsvorlage, AGENTS | Grafik und Kollision gemeinsam transformieren; lesbare Phasen, keine flachen Ersatzkörper |

Verworfene v0.45-Helden sind keine Referenz und bleiben archiviert. Kein Comic und keine nicht vorhandene Nutzerdatei als gesichtet ausgegeben. Die konkrete Bossmechanik und das neue Raster sind Umsetzungsentscheidungen.

## Grafik und Animation

- **Quelle:** ImageGen-Bild `exec-877530ce-7c03-4391-9f43-bfc29dc3ae63.png`, anhand zweier tatsächlich gelieferter Bildreferenzen erzeugt und unverändert als `ice-guardian-combat.png` kopiert. Keine Python-Bildbearbeitung. Python wurde ausschließlich für Alpha-/Maßanalyse und Dokument-/Codebearbeitung genutzt.
- **Atlas:** 1774×887, 4×2; tatsächliche Metall-/Kernphasen. Fester Mittelpunkt und Skalierung 88 / Zellbreite, lineare Verkleinerung. Opake Körperteile aller acht Zellen haben Abstand zum Rand; sichtbare Körperhöhe etwa 75–79 Weltpixel. Feinste transparente Randpixel nicht als Körpermaß verwenden.
- **Kontakt:** Bossposition ist logischer Trefferanker, Kern-/Geschossdarstellung etwa 18 Pixel darüber. Geschossprüfung auf der Bodenebene entspricht Ravens bestehendem Fuß-/Kollisionssystem. Handblitze aus den bestehenden Handankern, keine neue Pistolenquelle im Netz.
- **Bewegung:** schwebende leichte Pendelbewegung und Schussrückstoß; echte Phasen statt bloßer Farbumtönung. Keine Veränderung an Haaren, Ausrüstung oder Standardraster der Helden.
- **Arena:** Quelle, Wände, Masken, Requisiten und Relais gemeinsam Faktor 1,5. Keine neue flache Kartenzeichnung; normale Raumgrößen bei Rückkehr wiederhergestellt.

## Umsetzung und Nachweis

| Prüffeld | Ergebnis / Beleg |
| --- | --- |
| Spielgröße, Textur und Lesbarkeit | Native Godot-Aufnahmen in [Bericht](../ice-kampf-v050.md); Avatartransparenz nach Sichtprüfung von 0,56 auf 0,95 erhöht. |
| Vollständiger Kampf | Automatische Lauf-/Ausweich-/Angriffssteuerung in echter nativer Szene; alle vier Öffnungen und Sieg ohne Schaden aufgenommen. Keine manuelle Gesamtspiel-Abnahme behauptet. |
| Kontakt/Deckung | Bewegte Kugeln mit Segmentprüfung, Wände vor Zielkontakt; nahe Rückkante ebenfalls geschützt. Keine Blut-FX für digitale Wesen. |
| Controller/Tastatur | Bestehende Hauptsteuerung für Raven; eigene Regression mit echten B-/X-Gamepadereignissen. |
| Pause/Ton/Bildstil | Phasen und Geschosse pausieren mit `is_busy`; vorhandene Ton-/Grafikeinstellungen weiterverwendet. |
| Abbruch/Laden | Sibling-Geschosse beim Bossausstieg entfernt; freier Start mit vollen Werten; Relais-Saveformat erhalten; Kamera/Masken/Kollisionen zurückgesetzt. |
| Automatische Prüfungen | Laufende Ergebnisse werden vor Abschluss ergänzt. |
| Export | Paketprüfung wird vor Abschluss ergänzt. |
| Version/Sicherung | Alle aktuellen Versionsfelder v0.50.0 · CodexAI; Git-Sicherung nach Prüfung. |

**Sichtprüfung:** CodexAI, 10. November 2026, Godot 4.7.2 mit nativer OpenGL-Kompatibilitätsdarstellung. Film zeitlich verdichtet, unter 5 MB. Die Balance wurde durch einen gesteuerten vollständigen Sieg und gezielte Regressionen geprüft; individuelles Spielgefühl bleibt eine Spieltestfrage.
