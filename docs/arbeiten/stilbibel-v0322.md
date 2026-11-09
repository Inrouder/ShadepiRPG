# Arbeitsnachweis · Gesamtspiel-Stilbibel · v0.32.2 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

Ausgefülltes Beispiel zur [Arbeitsvorlage](../vorlagen/konsistenz-auftrag.md).

## Auftrag und Grundlage

- **Nutzerziel:** Konsistenzvorlage für das gesamte Spiel, mit Bildern der einzelnen Figuren und der Art-Richtung; die vorherige Heiligtum-Gewichtung korrigieren.
- **Ausgang:** `2938d836f7e80b23f246c3fdcd8801b16d1f6777`, Spielversion v0.32.1. Alle Remote-Branches abgerufen und Versions-/Änderungsstände verglichen; `main` enthielt den neuesten Stand. Arbeitsverzeichnis anfangs sauber.
- **Umfang:** Projektdokumentation, Quellenindex, reproduzierbare Referenztafeln und Versionsfelder. Keine Gameplay-Assets neu zeichnen oder austauschen.
- **Referenzen:** Aktive Helden-/NPC-Blätter; Kontakt- und Erinnerungsmetadaten; `Painted.ART`, zusätzliche aktive Räume/Erinnerungskulissen; `PropArt`, Fahrzeugatlas, UI-Skins und FX. Bestätigte Merkmale nach Universumsarchiv und aktuellen Projektregeln.

## Umsetzung

| Teil | Ergebnis / Beleg |
| --- | --- |
| Gesamter Figurenbestand | [23 Figuren-/Typenkarten](../stilbibel/figuren.md), jeweils bestehende Ansichten und Weltmaßstab ×1. Fehlende Meister-/Digitalansichten werden nicht erfunden. |
| Art und Welt | [Material-/Licht-/Animationsregeln](../stilbibel/artdirection.md); [20 Kulissenquellen über alle Kapitel](../stilbibel/welten.md). |
| Fahrzeuge und Objekte | [Fahrzeugtafel sowie neun Requisitentypen in drei Zuständen](../stilbibel/fahrzeuge-requisiten.md). Bei den Props steht Raven im selben Maßstab daneben. |
| UI, FX und Ton | [Sechs UI-Familien, fünf Hackarten, Menü/HUD, Effektframes und Musikzuordnung](../stilbibel/oberflaechen-effekte.md). |
| Aktive Quellen | [Figurenindex mit Ausgangscommit](../stilbibel/figuren.json) und Quellenlinks bei den einzelnen Karten. |
| Darstellung | [Godot-Renderer](../../tools/style_bible_gallery.gd), 31 PNG-Tafeln; neutraler Dokumentationshintergrund. Originalpixel und aktive Anker/Skalen wiederverwendet. |
| Gemeinsamer Einstieg | KONSISTENZ, AGENTS, CLAUDE, CONTRIBUTING, README, Arbeits- und PR-Vorlage verweisen auf die Gesamtspiel-Stilbibel. |

## Prüfung und Grenzen

- Vollständiger Referenzlauf mit Godot 4.7.2 und tatsächlichem OpenGL-Renderer; anschließend gezielter Neuaufbau der Weltübersicht nach Erhalt der Quellseitenverhältnisse. Keine Script-/Ladefehler im Renderprotokoll.
- Alle 31 PNGs auf Lesbarkeit als Datei, Mindestabmessungen und Vollständigkeit der 23 Figuren-IDs geprüft. Figurenübersicht und repräsentative Einzelkarten, Props, Welt-/Fahrzeug-/UI-/FX-Tafeln visuell gesichtet.
- Lokale Markdown-Links, Figuren-Metadaten, Quellregionen, Versionsfelder und `git diff --check` geprüft. Godot-Editorimport erfolgreich; Tafeln liegen hinter `.gdignore`, Dokumentation/Werkzeuge sind von den bestehenden Exportprofilen ausgeschlossen.
- Neue Controller-, Kampf-, Speicher- oder Pausentests: **nicht betroffen**, da keine entsprechende Spiellogik geändert wurde. Keine früheren Gameplay-Prüfzahlen als neue Ergebnisse ausgegeben.
- Sichtbare Bestandsabweichungen sind dokumentiert: Aerodyne-Ansichten, Figurenschärfe, Unterschiede einzelner Kontaktposen und kleine Atlas-Nachbarfragmente. Ihre Korrektur wird durch die Dokumentation nicht als erledigt behauptet.

**Ergebnis:** Bebilderter Projektstandard für das gesamte Spiel erstellt. Quellenbilder bleiben unverändert; historische oder fehlerhafte Bestandsmerkmale werden nicht zum gewünschten Stil erklärt. Sichtprüfung: CodexAI, 8. November 2026.
