# Eisbad, Rückkehr und Kryospray · v0.38.0 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

## Auftrag und Ausgang

- **Ziel:** Ersten nächsten Block der autorisierten Cinema-Roadmap umsetzen: Ravens körperlichen Einstieg, die Deep-Dive-Rückkehr und Shadepis Rettung sichtbar erzählen. Das Holen des Kryosprays bleibt spielbar, die Datenspur und Enthüllungsreihenfolge bleiben erhalten.
- **Basis:** `cf6048b`, v0.37.0, lokal sauber und identisch mit `origin/main`. Alle Remote-Branches abgerufen, Versionen und unveränderte Entwicklungsstände bis v0.21.3 verglichen. Keine neuere fremde Arbeit offen.
- **Version:** v0.38.0 · CodexAI, Exportfelder 0.38.0.0. Geprüften Zwischenblock auf GitHub sichern; keine Cloud-Veröffentlichung.

## Quellen und Grafikbriefing

Tatsächlich gesichtet: aktive Figurenkarten Raven/Shadepi, `assets/world/painted/hideout.png`, Art Direction und Konsistenzvorlage; Roman Kapitel 2 und bestehender Kapitelablauf. Die neue Bekleidung bleibt die im Spiel etablierte taktische Ausrüstung; keine neue Figur oder unmaskierte Ansicht. Raven 160 cm, schwarz-blaue Haare, rotes Schulterzeichen/Cyan-Anzug; Shadepi mit breitem Kasa, geschlossener Maske, Weste/Schal/Stoffbahnen. Keine neue Zentimetergröße für Shadepi.

Neuer transparenter 1536×1024-Atlas mit acht 384×512-Zellen: Sitzen/Anschluss, Absenken, Zurücklehnen, angeschlossene Ruhe, Rückkehrreaktion, Erschöpfung am Rand, gestützte Spray-Anwendung, stabilisierte Sitzpose. Direkte HQ-Pixelgenerierung mit tatsächlichen Figuren- und Raumgrafiken als Bildreferenzen, keine programmatisch bemalten Pixel. Körpergröße und Kontaktanker pro Pose anhand der Quelle und später im Renderer abgleichen. Vorhandene Wanne und deren vorderer Wasser-/Randbereich als korrekt registrierte Verdeckung verwenden; kein zweiter Stuhl oder zweites Becken aus dem neuen Atlas.

Phasefolge: Annäherung → Rand/Anschluss → Absenken → Ruhe → Netzübergang → Rückkehr/Atemnot → spielbares Sprayholen → Stützen/Sprühen → Erholen/Aufstehen → bestehende Kenzō-Informationen. Kontaktpunkte, Maskenverdeckung, Pause, Controller, Skip, Laden und Export werden vor Abschluss geprüft.

## Abnahme

**Sichtprüfung: CodexAI, 9. November 2026, Godot 4.7.2, tatsächlicher OpenGL-Renderer.**

| Prüffeld | Ergebnis / Beleg |
| --- | --- |
| Quelle, Zuschnitt und Alpha | Überarbeiteter Atlas verwendet; tatsächliche getrennte Ausschnitte für Einzel-/Paarposen statt blindem Raster. Sichtbare Nachbarfragmente ausgeschlossen, ganze Hüte/Umhänge/Haare erhalten. Alpha-Ränder aller acht Ausschnitte geprüft. [Quellenvertrag](../../assets/story/ice-bath/README.md) |
| Größe und Material | Neue Paarpose neben normalen Raven-/Shadepi-Sprites im Renderer verglichen. Sitz-/Kniehöhe und dunkle Ausrüstung passen; Raven behält ihr Kostüm, Shadepi seine geschlossene Maske. Quelle und Spielgröße gesichtet. |
| Kontakt und Zeichenrahmen | Sitz-/Hüft-/Kragenpunkte pro Pose; separater texturierter Schlauch bis zum Pumpenanschluss. Zeichenrahmen auf alle zurückgelehnten Kopf-/Haarpositionen erweitert und in acht Fällen gegen tatsächliche Spritegrenzen geprüft. Wannen-/Wasserverdeckung aus vorhandener Raumquelle; kein zweites Möbel. [Einstieg](../previews/eisbad-wasser-v038.png) |
| Ersatzfiguren und Schatten | Normale Körper, Figurenschatten und Licht-Occluder während Ersatzposen ausgeblendet; keine zusätzliche schwarze Kontakt-/Lichtschattenfläche unter dem alten stehenden Körper. Nach Aufstehen/Wechsel vollständige Wiederherstellung. [Behandlung](../previews/eisbad-spray-v038.png) |
| Vollständiger sichtbarer Ablauf | Letzte Aufnahme: 53 echte Renderer-Frames für den Einstieg und 186 für Rückkehr, tatsächliche Laufwege zum Spray und Behandlung. 17 markierte Ansichten; Finale erreicht regulär Kapitel-2-Ende. Beide Filme mit echten Aufnahmezeitpunkten erstellt. [Bilder und Filme](../eisbad.md) |
| Spieleraktion und Controller | Rohes Controller-A startet Anschluss, B überspringt korrekt. Das Sprayholen bleibt eine reguläre Interaktion; Behandlung beginnt erst beim Zurückbringen. Keine neue Tastenbelegung. |
| Pause / FX / Ton | Szenenuhr und Posenmischung bei Menüpause geprüft, einschließlich Atem-/Sprühshader. Vorhandene Ton-/Musikpfade bleiben erhalten; Renderer mit Dummy-Audio, keine neue akustische Qualitätsprüfung behauptet. Keine neue globale Bloom-/Partikeldichte. |
| Laden, Altstände und Abbruch | Drei laufende Szenenarten starten beim Laden sicher neu, Spray-Inventar bleibt erhalten. Alte oder fehlerhafte Felder fallen sicher zurück. Lade-/Endpunkte setzen beide Körper auf trockenen Boden. Generationstickets auch in den älteren Kapitel-2-Szenen unterbinden nachträgliche Kamera-/Titel-/Figurenänderungen nach Abbruch. |
| Aktuelle automatisierte Prüfungen | **792 Fälle, 0 Fehler:** neue Eisbadprüfung 49, Hauptsuite 383, Storyaudit 206, Ortsatmosphäre 134, Deep-Dive-Darstellung 20. Nach den letzten Kontrollpunktänderungen Eisbad, Hauptsuite und Storyaudit gezielt erneut geprüft, ohne doppelte Zählung. Neue Eisbadprüfung im GitHub-Build. |
| Exportierte Ressourcen | Linux-PCK exportiert und mit tatsächlichem Renderer gestartet: **neun zusätzliche Fälle, 0 Fehler**. Bildquelle, Shader, Kabel/Wannen-Vordergrund, Anschluss-/Behandlungsskip, Inventar-/Szenenladen, Netzübergang und normales Kapitelende geprüft. Wasser- und Behandlungsbild aus dem Paket gesichtet. |
| Version und Sicherung | Projekt und aktuelle READMEs 0.38.0, Windows-Datei-/Produktversion 0.38.0.0; CHANGELOG und neue Referenzhinweise CodexAI. Lokale Dokumentationslinks und `git diff --check` vor Commit prüfen. Sicherungsziel des vollständigen Blocks: `origin/main`; keine Cloud-Veröffentlichung. |

Reproduzierbare lokale Prüfungen:

```sh
godot --headless --editor --import --quit
godot --headless --script res://tests/ice_bath.gd
godot --headless --script res://tests/run.gd
godot --headless --script res://tests/story_audit.gd
godot --headless --script res://tests/scene_atmosphere.gd
godot --headless --script res://tests/npc_dive_visuals.gd
godot --audio-driver Dummy --script res://tools/ice_bath_gallery.gd
```

**Grenzen:** Die Netzmission zwischen den beiden Filmen wurde für die Galerie per QA-Aufruf abgeschlossen und nicht neu vollständig manuell gespielt. Holen/Zurückbringen des Sprays innerhalb des zweiten Films erfolgt über tatsächliche Laufwege/Interaktionen. Kein nativer Windows-Programmstart und keine neue Audio-Abnahme. Die acht Posen werden überblendet; zusätzliche gezeichnete Zwischenphasen wären eine spätere Verfeinerung. Kapitel 4 und die weiteren Fahrzeug-/Objektblöcke bleiben die folgenden Arbeiten der Roadmap.

**Ergebnis:** Erster nächster Cinema-Block vollständig umgesetzt, im Spiel und exportierten Paket gesichtet, gezielt geprüft und zur Git-Sicherung fertig.
