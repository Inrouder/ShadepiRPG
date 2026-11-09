# Fehlerbericht und Heldenqualität · v0.45.0 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

Ausgang `810cce8`, v0.44.1. Alle Remote-Branches abgerufen; bekannte Entwicklungsbranches unverändert höchstens v0.21.3. Lokaler Stand sauber. Nutzerbericht vom 9. November 2026 (Europe/Berlin). AGENTS/KONSISTENZ, Art Direction, UI-/Weltvorgaben und Auftragsvorlage gelten.

Tatsächlich gesichtete Figurenkarten: Raven, Shadepi, Jackal; aktive Kapitel-1-Kontaktposen als Materialreferenz. Raven 160 cm, schwarz-blaue Haare, Cyan/Rot; Shadepis geschlossene Maske, Kasa, Weste/Stoff; Jackals massive Magenta-Arme erhalten. Keine Storyretcons. Zwei neue 64-Posen-Gameplayquellen plus acht Reaktionsbilder; Originaldateien bleiben als Backup. Aktive Quelle, tatsächliche Regionen und Anker werden dokumentiert, Original-PNGs unverändert kopiert.

## Berichtspunkte
- [x] Heldenqualität, stabiler Maßstab/Filter, Backups
- [x] Elektroverteiler bei Beschädigung maßhaltig
- [x] Kapitel 1 Raven fällt und liegt
- [x] Kapitel 1 Jackal stirbt sichtbar
- [x] Kapitel 2 Weg um Wagen
- [x] Kapitel 3 Schützen-Kontaktmaßstab
- [x] Kapitel 3 Verfolgung nur bei echtem Ausgang, sichtbarer Übergang
- [x] Kapitel 4 Garageneinfahrt mit Hintergrund
- [x] Kapitel 4 Werkbank/Plattform ohne Rücklauf
- [x] Kapitel 5 Raven nach Osten stabil
- [x] Kapitel 5 körperliche Rückkehr aus Erinnerung
- [x] Kapitel 7 Blickkontakt am See

## Umsetzung und Sichtprüfung

Alle zwölf Punkte umgesetzt; [bebilderter Bericht und Film](../fehlerbericht-v045.md). Tatsächliche native Godot-Aufnahmen: neue/alte Figuren bei derselben Kamera, vier Ost-Gehphasen, lebende Raven-Bodenpose, Jackal nach dem letzten Treffer, beide Schützen im Angriff, intakter/beschädigter Verteiler, Garageneinfahrt und Blickkontakt am See. Der Film zeigt 705 native Einzelaufnahmen mit ihren tatsächlichen Aufnahmeabständen. QA bereitet Kapitel/Kampfausgang vor und löst im Aufnahmeprogramm den Garagendecoder; kein vollständig manuell erspielter Durchlauf, Dummy-Audio ohne akustische Abnahme.

Die neue Quelle ist kein gleichmäßiges Raster. Vollständige Silhouetten wurden als Einzelregionen registriert, mit drei Pixeln Rand und eigenem Sohlenanker. Nearest, rund 58 Weltpixel Stand-/Gehhöhe, bestehende Sonderbewegungen erhalten. Pro Actor eigener Atlas/Metadaten statt statischem Texturcache. Ersatzreaktionen unterdrücken Körper und beide Schatten und lösen sich bei Abbruch idempotent. Ravens Weg wird gegen die tatsächlichen Weltkollisionen in jedem Physikschritt geprüft, nicht nur anhand der Wegpunkte.

## Regression und Export

Godot 4.7.2; isolierte `XDG_DATA_HOME`-Verzeichnisse, keine echten Spielstände als Fixtures. Alle folgenden Läufe ohne Fehler und nach den abschließenden Metadaten-/Rendereranpassungen:

| Suite | Prüfungen |
| --- | ---: |
| Kern `run.gd` | 383 |
| Fehlerbericht `bug_report_v045.gd` | 228 |
| Kampfbewegungen | 68 |
| Raven-/Gegnerkampf | 292 |
| Fahraktion | 60 |
| Hangarentdeckung | 38 |
| Technikobjekte | 55 |
| Szenenatmosphäre | 134 |
| Heiligtumgrafiken | 18 |
| Seefinale | 32 |
| Storyaudit | 206 |
| Kapitel-1-Auftakt | 52 |
| Menü-/Testkontrollpunkte | 205 |
| Eisbad | 49 |
| Heiligtumstory | 27 |
| Szenenwege | 50 |
| **Summe Regression** | **1.897** |
| **Exportpaket, gesondert** | **20** |

Der bestehende Heiligtumgrafiktest wurde vom alten festen 128×160-Ausschnitt auf die tatsächlich eingebundene Atlasregion umgestellt; keine Bildzugriffe außerhalb der neuen Region. Der Kampfbewegungstest prüft nach Sonderaktionen den tatsächlichen aktiven Atlas samt Rohquelle. Die neue CI-Regression deckt Richtungen, Größen, Kontaktpunkte, Backups, Trefferzustände, Reaktionsbereinigung, Kollisionsweg und Szenenfortschritt ab.

Editorimport und Pack-Export ohne Skriptfehler: `/tmp/shadepi-v0.45.0.pck`. Das Paket wurde aus einem leeren Arbeitsverzeichnis mit externem Testprogramm geöffnet und im nativen OpenGL-Renderer geprüft: Version, beide importierten Quellen/Anker, Original-/Backupgleichheit, Raven/Jackal-Reaktionen, Garagendecoder, See-Blickkontakt. `PACKED REPORT: 20 checks, 0 failures`. Prüfprotokolle dieser Sitzung unter `/tmp/shadepi-v045-*.log` (temporär).

## Grenzen und Sicherung

Vier echte Gehphasen je Richtung statt der acht historischen Phasen. Die neuen 64-Posen-Banken sind kein vollständiger Ersatz sämtlicher Sonder-/Szenenatlanten. Individuelle NPC-/Custom-Maßstäbe bleiben erhalten; bestehende alte Kunst ist nicht pauschal neu gezeichnet. Hero-Originale unverändert und zusätzlich bytegleich gesichert; [Rückweg](../../assets/sprites/heroes/backup-v0441/README.md).

Vor Beginn und vor Abschluss alle Remote-Branches abgeglichen: `main` weiterhin `810cce8`, bekannte weitere Branches höchstens v0.21.3; fremde Arbeit unverändert erhalten. Zwischenstand `c80fe54`, Abschluss enthält die danach geprüften Registrierungs-/Atlasverfeinerungen und Dokumentation. Version 0.45.0, Windows 0.45.0.0, CodexAI-Vermerk und PNG-Vorschauen konsistent. Sicherung auf GitHub `main`; keine Veröffentlichung der Cloud-Umgebung und kein Release-Tag.
