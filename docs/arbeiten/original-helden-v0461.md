# Originalhelden wiederherstellen · v0.46.1 · CodexAI

## Auftrag und Quellen

Nutzer wünscht die Original-Sprites zurück, da die neuen normalen Heldenbilder nicht gefallen. Ausgang `37fa48e`, v0.46.0; lokal sauber. Alle Remote-Branches abgerufen: main aktuell, übrige bekannte Branches unverändert höchstens v0.21.3. Keine fremden Änderungen zurückgesetzt. AGENTS, KONSISTENZ, Art Direction, Figurenkatalog und Arbeitsvorlage berücksichtigt. Gesichtet: Original-Spielvergleich `bericht-heroes-backup-v045.png` und aktueller nativer Vergleich v0.46.1. Keine neue Grafikgenerierung.

Aktive Originale `assets/sprites/heroes/raven.png` / `shadepi.png` sind unverändert und bytegleich zu `backup-v0441`. Wieder 1024×5120, acht Richtungen und acht Phasen je Reihe, 128×160-Zellen, Maßstab 0,5, Fußbasis 152 und Y-Versatz -36. Ravens bestätigte 160 cm und Shadepis geschlossene Maske bleiben erhalten; keine neue Gesichtsauslegung. Die zwei automatischen Umleitungen in `SpriteAssets.resolve` entfernt. Custom-Ersetzungen behalten Vorrang. Die verworfenen Bilder bleiben historisch erhalten, nicht als aktueller Stilstandard.

## Umfang und Kontaktprüfung

Normale Helden und deren Figurenkarten zurückgestellt, Heiligtum-Kontaktposen wieder mit passender linearer Verkleinerung. Nach Sonderposen wird auch der normale Körper-/Schattenfilter zurückgesetzt. Sonstige Reaktionen, Treffer-/Todesbilder, Kampfbewegungen, korrigierte Wege/Szenen und Blut-FX erhalten. Kein pauschaler Git-Revert der v0.45.0-/v0.46.0-Commits und keine Spielstandänderung.

| Prüffeld | Ergebnis |
| --- | --- |
| Originalquellen / Proportion | Bytegleichheit der beiden Originale und Backups geprüft; aktive Originalpfade, 8×32 Raster und Maßstab in allen acht Gehrichtungen/acht Phasen geprüft. |
| Anker / Schatten / Spezialbewegung | Originalfußbasis bleibt fest; Körper-/Schattenframe synchron. Aufladen, Kick, Hand-/Pistolenaustritte und Rückkehr zum Original geprüft. |
| Sichtprüfung | Aktuelle native Godot/OpenGL-Aufnahme bei derselben Kamera wie alter Vergleich. Film aus 130 echten Rendererframes: Stand, vier Richtungen, achtphasige Gehfolgen und Rückkehr. Beide Heldenkarten plus vollständige 23-Figuren-Übersicht erneuert. |
| Controller / Tastatur / Ton | Belegung, Spielregeln und Klänge nicht verändert; bestehende Kampf-/Kernprüfungen verwendet. Kein neuer manueller Controller-/Hörtest; Aufnahme mit Dummy-Audio. |
| Pause / Laden / Abbruch | Keine neue Effektuhr oder Speicherpflicht. Bestehende Ablauf-/Reaktionsprüfungen weiter aktiv und bestanden. |
| Export | Externes Prüfen aus leerem Arbeitsverzeichnis: tatsächliche Originaltexturen, Pixelgleichheit der importierten Backups, Raster/Skala/Anker, Sonderposen-Rückkehr und weiter enthaltene Blutquelle. Native Ansicht aus dem Paket aufgenommen. |
| Dokumentation | Aktuelle PNG-Vorschauen, Original- und verworfene Quellen klar gekennzeichnet; KONSISTENZ/Art Direction auf aktuelle Originale zurückgeführt. Historischer v0.45.0-Bericht erhält Hinweis. |

## Aktuelle Tests

Godot 4.7.2, isolierte `XDG_DATA_HOME`-Verzeichnisse, keine echten Spielstände als Fixtures.

| Suite | Prüfungen | Fehler |
| --- | ---: | ---: |
| Kern | 383 | 0 |
| Kampfbewegungen | 68 | 0 |
| Raven-/Gegnerkampf | 292 | 0 |
| Fehlerbericht / originale Heldenzyklen | 420 | 0 |
| Blut-FX | 29 | 0 |
| Heiligtumgrafiken | 18 | 0 |
| **Regression gesamt** | **1.210** | **0** |
| Export zusätzlich | 12 | 0 |

Tests erwarten wieder die tatsächliche Originaldarstellung; übrige Reportprüfungen erhalten. Editorimport und Pack-Export ohne Skriptfehler, `/tmp/shadepi-v0.46.1.pck`; `PACKED ORIGINALS: 12 checks, 0 failures`. Temporäre Protokolle `/tmp/shadepi-v0461-*.log`.

**Sichtprüfung:** CodexAI, 9. November 2026 (Europe/Berlin). [Aktuelle Spielansicht und Gehfilm](../original-helden.md). Die Aufnahme ist ein QA-Aufbau mit vorhandenen normalen Figuren, kein vollständig manuell erspielter Abschnitt. Historische Berichte behalten ihren damaligen Aufnahmestand. Verworfen bedeutet hier nicht aus der Git-Historie gelöscht.

**Sicherung:** Version 0.46.1 / Windows 0.46.1.0, CodexAI. Alle Remote-Branches vor Beginn und Abschluss abgeglichen; main weiterhin `37fa48e`, übrige Branches höchstens v0.21.3. Geprüften Stand auf GitHub main gesichert. Keine Cloud-Veröffentlichung oder Release-Erstellung.
