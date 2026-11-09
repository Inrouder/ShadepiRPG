# Konsistenzauftrag · v0.35.0 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

## Auftrag und Ausgangslage

- **Aufgabe:** Ravens sichtbarer Eintritt und Annäherung an Kenzō, Shadepis späterer Lauf zum Eingreifen; glaubhafte kontinuierliche Aerodyne-Flucht ohne Ansichtswechsel im Fall; freie Laufwege und sichtbares Einsteigen im Hangar.
- **Ausgang:** `e829071`, v0.34.0, sauberer Branch `work`, identisch mit GitHub `main`. Alle Remote-Branches vor Beginn abgerufen, Versionen verglichen; andere Entwicklungsbranches bis v0.21.3. Keine neuere fremde Arbeit zu übernehmen.
- **Version:** v0.35.0 · CodexAI. Bestehende Vollbild-/Anzeigeoptionen, Kontrollpunkte und Tower-Extraktion erhalten.
- **Betroffen:** `tower_story.gd`, `tower_escape.gd`, `hangar_departure.gd`, gemeinsame filmische Fahrzeug-/Bewegungshelfer, gezielte Tests und Bildnachweise.

## Tatsächlich gesichtete Quellen

| Referenz | Übernahme |
| --- | --- |
| `KONSISTENZ.md`, Stilbibel, Art Direction, Arbeitsvorlage | HQ-Pixelmaterialien, vollständige Silhouetten und echte Kontaktsichtprüfung. |
| Bildkarten `figur-shadepi.png`, `figur-raven.png`, `figur-kenzo.png`; aktive Helden-/Kenzō-Sprites | Dieselben Figuren, Masken, Kostüme und Laufanimationen. Raven bleibt 160 cm; keine neue Größenangabe für Shadepi. |
| `suite.png`, `painted_world.gd` SOLIDS/Verdeckung | Sessel nicht als Spawnpunkt; freie Gangflächen zwischen Einrichtung. |
| `hangar-empty.png`, Hangar-Kollisionen und `HANGAR_BRAND` | Bestehender Raum und KOBAN-TEC; Ankunft auf freiem Boden und Weg vor/um Geräte. |
| `tower/exterior.png`, `world/hq/vehicles.png`, `memories/attack/props-fx.png` | Ein zusammenhängender Flucht-Bildausschnitt, unveränderte Schiffsgrafik und vorhandene texturierte FX. |
| `docs/universum/teil-6/README.md` | Kenzō packt Raven vor Shadepis Eingreifen; Extraktion, offene Hintergründe, Abrechnung und knappe Flucht bleiben erhalten. |

**Keine neue Grafikgenerierung erforderlich:** Fahrzeug, Figuren und Kulissen vorhanden. Triebwerksflammen werden aus dem vorhandenen Flammenbereich texturiert, in Cyan umgesetzt und fest an tatsächlichen Düsenankern transformiert; keine Holz-/Trümmerbilder als Strahl. Historische Bilder bleiben Vergleichsmaterial, keine neue Stilvorgabe.

## Animationsbriefing

- Kenzō ist vom ersten Bild an neben dem Sessel sichtbar; Raven betritt den Raum und nähert sich zu Fuß. Shadepi bleibt bis zum festgelegten Dialog verborgen und läuft dann sichtbar vom Eingang zum Griffpaar. Körpergröße und vollständige Silhouetten bleiben erhalten.
- Hangar: Beginn auf freier unterer Gangfläche, an der Einrichtung vorbei zum Schiff; Figuren steigen nacheinander ein, bevor die Cockpitaufnahme folgt. Keine gedrehte Standpose als Ersatzanimation.
- Tower: Rennen, Einsteigen, schleichender Schubverlust, Kippen, beschleunigter Fall, Hochfahren des Schubs, Abfangen und Wegflug vor der Explosion. Dieselbe Kulisse und dasselbe Fahrzeugobjekt; stetige Positionsgeschwindigkeit zwischen Flugphasen.
- Engine-FX und Körper verwenden dieselbe Projektions-/Rolltransformation. Quelle sind isolierte Flammenpixel, Bildwechsel werden überblendet. Szenenuhr statt Shader-`TIME`, damit Pause alles anhält. Feste Zeichenbudgets.
- Überspringen muss den kompletten Ablauf sicher bis zum nächsten Kontrollpunkt auflösen. Abbruch/Szenenwechsel darf keine wartende alte Coroutine, Pose, Verdeckung oder FX zurücklassen.

## Umsetzung und Abnahme

| Prüffeld | Ergebnis und Beleg |
| --- | --- |
| Aktive Quellen / Merkmale | Normale HQ-Helden und Kenzō aus den gesichteten Karten; Griffquelle bleibt `kenzo-poses.png`. Keine Figuren- oder Fahrzeug-Assets neu generiert. |
| Weltgröße, Material, Abtastung | Originalquellen mit individueller Skalierung: Penthouse normale Weltgröße, filmische Figuren auf der Terrasse ×0,625, Hangar gesamter Raum ×0,625. Fahrzeug aus derselben 627×627-Zelle wie im bisherigen Flug, lineare Verkleinerung wie bei den HQ-Helden. |
| Silhouetten / Transparenz | Vollständige Figuren bei Eintritt, Lauf und Kontakt in tatsächlichen Renderer-Aufnahmen gesichtet. Keine neuen Atlaszellen oder Freistellungen. |
| Fuß-/Möbelkontakt | Kenzō startet `(675,340)` neben dem Sessel. Raven beginnt `(286,486)` am Eingang. Hangar-Ankunft `(232,514)` und `(266,526)` auf freiem Boden vor der Vorderwand. Wege mit 7-Pixel-Figurenradius gegen die tatsächlichen Raumkollisionen geprüft. |
| Fahrzeug / Düsen | Quellanker `(214,550)` und `(421,550)` aus der 627×627-Zelle; beide Strahlen und der Körper erben dieselbe Projektion und Drehung. Vorhandene Flammenpixel überblendet und in Cyan umgesetzt, ohne Holz oder Fremdfragmente. |
| Vollständige Bewegung | Galeriewerkzeug zeigt Eintritt, Annäherung, Griff, laufenden Shadepi, sämtliche Abflugphasen und Hangarweg/Einsteigen/Abheben. Positions- und Geschwindigkeitsübergänge numerisch an den tatsächlichen Flugschritten geprüft. |
| Vergleich und Film | Vorherige Galeriebilder des Ausgangscommits vor Änderungen unter `/tmp/shadepi-v035-before-images/` gesichert. Aktuelle Bilder in `docs/previews/*-v035.*`; neue Kadrage im Hangar ist ausdrücklich Teil der Korrektur. Fluchtfilm aus tatsächlichen Godot-Frames, mit Aufnahmezeitpunkten als Wiedergabezeit. Keine nachträglich zusammengesetzten Spielinhalte. |
| Controller / Tastatur | Bestehende Terminal-Controller-Prüfung: 186 Checks. Tower-/Fehlerbericht-8-Prüfungen erhalten Pause/Skip einschließlich Controller-B, Speichern/Laden, Wiederholung und Szenenwechsel. Keine Eingabebelegung geändert. |
| Pause, Bildstil, Ton | Neue Shader verwenden die anhaltbare Szenenuhr, kein ungebremstes Shader-`TIME`. Laufwege und Einstiegsschritte pausieren ebenfalls. Vorhandene Tonfunktionen/MP3-Zuordnungen und Qualitätsstufen erhalten; essentielle Düsen-/Explosionsanzeigen bleiben sichtbar. Atmosphärenprüfung 134 Checks. |
| Abbruch / Laden | Vorhandene Generationsprüfungen des Cutscene-Directors für sämtliche wartenden Schritte. Kapitelwechsel während des Anmarschs setzt normale Sichtbarkeit wiederher. Abflug laden beginnt weiterhin am Start dieser Szene; geschützte Datenextraktion bleibt davor abgeschlossen. |
| Aktuelle automatisierte Prüfungen | **1.132 ohne Fehler:** neue Szenenprüfung 37, Tower 42, Fehlerbericht 8 21, Gameplay/Saves 383, Story 206, Atmosphäre 134, Aerodyne-Flug 50, Terminal-Controller 186, Anzeige 73. Neue Prüfreihe im GitHub-Build. |
| Exportierte Ressourcen | `/tmp/shadepi-v0.35.0.pck` gebaut und außerhalb des Repositories im echten OpenGL-Renderer gestartet. **5 zusätzliche Paketprüfungen ohne Fehler:** Kenzō am korrekten Start, sichtbare Figuren nach Eingreifen, beide texturierten Düsen, Übergang zum See und Übergabe an den steuerbaren Flug. Tatsächlicher Renderframe `/tmp/shadepi-v035/export-render.png` gesichtet; kein fehlender Shader oder Scriptfehler. |
| Version / Sicherung | v0.35.0 · CodexAI in Projekt, Windows-Versionen, beiden READMEs und CHANGELOG. GitHub-Sicherung nach abschließendem Paketlauf; keine Cloud- oder Release-Veröffentlichung. |

**Sichtprüfung:** CodexAI, 9. November 2026 (Europe/Berlin), Godot 4.7.2, Linux/X11 mit OpenGL/Mesa. Gameplay-Basis 640×360, Bildschirmaufnahme ohne Hochskalieren einzelner Sprites.

**Verbleibende Einschränkungen:** Kein neues Charakter- oder Fahrzeugmodell; die bestehenden Quellgrafiken bestimmen weiterhin die Perspektive. Windows-Anzeigetreiber werden in dieser Linux-Umgebung nicht ausgeführt. Die generelle Fahrzeugdarstellung im steuerbaren Flug wurde nicht ausgetauscht.

**Ergebnis:** Die drei beanstandeten Szenen sind umgesetzt, im vollständigen Ablauf gesichtet, gezielt getestet und aus dem Ressourcenpaket ausgeführt. Sicherung erfolgt mit dem zugehörigen v0.35.0-CodexAI-Commit auf `origin/main`; keine Cloud-Veröffentlichung oder Release-Tags.
