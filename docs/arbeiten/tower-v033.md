# Arbeitsnachweis · Tower und KOBAN-TEC · v0.33.0 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

## Auftrag und Ausgang

- **Ziel:** Kenzō packt Raven vor Shadepis Eingreifen; nach der Niederlage sichtbarer schwer verletzter, gelähmter Kenzō auf den Knien. Geschützte Datenextraktion, Wiederholung nach mehreren Raven-Treffern, erst danach endgültige Vernichtung. Inszenierung bestätigt, Motiv/Auftraggeber offen; gemeinsame weitere Suche. Sichtbarer knapper Abflug und Penthouse-Explosion. Hangarzeichen gegen KOBAN-TEC tauschen.
- **Ausgangscommit:** `4852a9c35662c0d00023163539c50cae67bc34e5`, v0.32.2. Alle Remote-Branches abgerufen und verglichen; `main` enthielt die neueste Version, Arbeitsverzeichnis sauber.
- **Referenzen:** [Kenzō](../stilbibel/bilder/figur-kenzo.png), [Raven](../stilbibel/bilder/figur-raven.png), normaler Shadepi; aktuelle Suite, Dach und Hangar; vorhandene Fahrzeug-/FX-Atlanten. Archiv Teil 3–4 für KOBAN-TEC. [Aktuelles Nutzerbriefing](../universum/teil-6/README.md).
- **Bewusste Umsetzung:** Drei Treffer, mindestens 24 aktive Sekunden und drei vorhandene Wachwellen; keine neue dritte Verbündete oder Auflösung des unbekannten Auftraggebers erfunden.

## Umsetzung und Konsistenz

| Bereich | Ergebnis / Beleg |
| --- | --- |
| Griff und Verletzung | Eigene Pixelposen nach den echten normalen Figuren; [Quelle und Anker](../../assets/story/tower/README.md). Paar-Fußpunkte, Knieboden, Raven-Handkontakt und Liegekörperlänge getrennt kalibriert; lineare Abtastung wie bei den normalen Nachbarfiguren. |
| Kampf und Lebenszustand | [TowerKenzo](../../scripts/tower_kenzo.gd) endet kampfunfähig ohne generischen Tod/Fall. Ein getrenntes lebendes Szenenobjekt bleibt bis zur gesicherten Extraktion bestehen. |
| Verteidigung | [TowerExtraction](../../scripts/tower_extraction.gd): fester Raven-Standpunkt, tatsächlicher Angriffspunkt, Treffer-Unverwundbarkeit, Gegnerzielwahl im Einzelspieler, drei Treffer und vollständiger Neustart. Countdown und Escape-Konsolen erst danach. |
| Daten und weitere Suche | [TowerStory](../../scripts/tower_story.gd) bestätigt Kenzōs Inszenierung, hält Motiv/Auftraggeber offen und führt erst nach Datenabschluss in die Vernichtung/Flucht. |
| Flucht | [TowerEscape](../../scripts/tower_escape.gd) animiert Originalfiguren/Fahrzeug/FX über Dach und neue Außenkulisse. Fall/Abfangen laufen ohne wartenden Textdialog; im sichtbaren Letterbox-Ausschnitt gehalten. |
| Hangar | Lokaler opaker KOBAN-TEC-Ausschnitt wird in normaler und Abflugansicht über die alte Wandquelle gelegt. Kein Umzeichnen des ganzen Raums oder Verschieben von Konsolen/Kollisionen. |
| Herkunft | Drei mit Bildgenerierung erstellte unveränderte Quellen; restliche Spielgrafiken wiederverwendet. KOBAN-TEC ist aus Archivbeschreibung rekonstruiert, nicht als lokale Kopie des fehlenden Chat-Originals ausgegeben. |
| Bedienung | Bestehende Tastatur-/Controller-Kampfaktionen und Hacks bleiben wirksam. HUD nennt Transfer, Treffer und Wachwelle; Ravens Hack ist während ihrer Extraktion gesperrt. |
| Speichern / Abbruch | Vier gespeicherte Tower-Phasen; Treffer und Schutzwellen beginnen bei Retry/Load fair neu, gewonnener Boss bleibt erledigt. Nach Datenabschluss nur Abschlussdialog, nach begonnenem Abflug nur diese Sequenz wiederholen. Alte Spielstände ohne neues Feld bleiben kompatibel. |

## Prüfung und Sicherung

- **1.628 Prüfungen ohne Fehler in zehn Prüfreihen:** Gameplay 383; Arcade-Wellen 246; neue Tower-Reihe 42; Story 206; Fehlerbericht 8 / Hangar-Abflug 21; Atmosphäre 134; Kampfbewegungen 68; Raven/Gegnerkampf 292; Aerodyne-Flug 50; Terminal-Controller 186.
- Neue Tower-Reihe kontrolliert echte Treffer inklusive Immunitätsfenster, dritte-Treffer-Retry, feste Extraktion, ungelöste Hintergrundfragen, lebenden Gefangenen bis zur Datensicherung, Speichern/Laden, alte Spielstände und Reihenfolge von Rennen bis Explosion. Im GitHub-Workflow ergänzt.
- Tatsächliche Godot-Galerie und aufgezeichnete Flucht gesichtet; [Bild-/Filmbericht](../tower-extraktion.md). Film aus 95 unveränderten Godot-Frames, keine nachträgliche Bildmontage.
- Aktive Quellen, lokale Links, Versionsfelder und `git diff --check` geprüft. Exportpaket erfolgreich gestartet: neue Posen, KOBAN-TEC, Schutzphase, Schadenscallback, Abflugkulisse und Abbruchbereinigung geladen/geprüft. Zwischenstand und Endstand im Git-Verlauf gesichert; Zielbranch ist GitHub `main`.
- Bekannte allgemeine Aerodyne-Silhouettenabweichung zwischen ursprünglicher Hangarquelle und Flugatlas bleibt als Bestandsabweichung in der Stilbibel dokumentiert; diese Aufgabe erstellt keinen neuen gemeinsamen Fahrzeugatlas.

**Ergebnis:** Gewünschter Ablauf implementiert; keine Motiv-/Auftraggeber-Auflösung vorweggenommen. Sichtprüfung: CodexAI, 8. November 2026.
