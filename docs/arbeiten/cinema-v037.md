# Musik, Objektanimation und Filmpotenzial · v0.37.0 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

## Auftrag und Ausgang

- **Nutzerziel:** `assets/music/menu.mp3` für Kapitel 7; anschließend das ganze Spiel auf Möglichkeiten für mehr Story und filmische Inszenierung prüfen. Gegenstände sollen echte zusätzliche Spritebilder erhalten, besonders der Aerodyne.
- **Basis:** `08ccc02`, v0.36.1, lokal sauber und gleich `origin/main`. Alle Remote-Branches abgerufen und Versionen/Änderungsstände verglichen; übrige Entwicklungsbranches unverändert bis v0.21.3, keine neuere fremde Arbeit offen.
- **Umfang:** Beide Kapitel-7-Musikslots umstellen. Als erste konkrete Spriteverbesserung sechs HQ-Rumpfzustände für den vorhandenen Aerodyne und sichtbare Kabinenöffnung/-schließung. Gesamtspiel-Bericht mit Quellen, Prioritäten und konkreten Spritebedarfen. Weitere große Szenenumbauten bleiben als klar gekennzeichnete Vorschläge im Bericht.
- **Version:** 0.37.0 · CodexAI; Windows-Felder 0.37.0.0. Autorisierter Git-Push nach Abnahme, keine Cloud-Veröffentlichung.

## Referenzen und Grafikvertrag

Gesichtet: `KONSISTENZ.md`, Art Direction, Fahrzeuge/Requisiten, normale Fahrzeugtafel, aktiver `assets/world/hq/vehicles.png`, sämtliche Kapitelabläufe und die bestehenden Inszenierungsberichte. Der neue Rumpfatlas verwendet ausdrücklich nur das bestehende zweisitzige, stark gebrauchte bronze-/gunmetallene Fluggerät als Identitätsreferenz. Auto, Motorrad und Drohne aus derselben alten Datei werden nicht ersetzt. Figuren inklusive Ravens Handkorrektur unverändert.

Neuer transparenter 1536×1024-Atlas, sechs Zellen à 512×512: geschlossen, Öffnungsbeginn, halb offen, offen, Triebwerksphase A/B. Einmalige gezielte Generierung, keine programmgesteuerte Bemalung. Gemessene Zellanker gleichen unterschiedliche transparente Ränder aus; Nase, Cockpit und beide Düsen bleiben im Renderer fest. Gemeinsamer Maßstab und Düsenanker, echte Drehung der mechanischen Details statt ausschließlich Verschieben desselben Bildes. Kabinenbewegung zeitlich an Ein-/Aussteigen gebunden; laufende Maschinerie stoppt bei Pause und Abschalten.

## Abnahme

**Sichtprüfung: CodexAI, 9. November 2026, Godot 4.7.2 im tatsächlichen OpenGL-Renderer.**

| Prüffeld | Tatsächliches Ergebnis / Beleg |
| --- | --- |
| Kapitel-7-Musik | Beide Slots lösen auf die vorhandene kleingeschriebene `menu.mp3` auf. Hauptmenü bleibt `Level.mp3`. Tatsächlich zugewiesener MP3-Stream und Länge auch im exportierten Paket geprüft; keine MP3-Kopien. |
| Quelle und Material | Neuer Atlas einmalig anhand der bestehenden Fahrzeugquelle generiert. Sechs vollständige Zellen mit Alpha-Guttern; Cockpit und beide gemessenen Düsenpunkte in jeder Zelle auf dem tatsächlichen deckenden Rumpf geprüft. Alte/neue Darstellung bei gleicher Kamera verglichen. |
| Registrierung und ganze Mechanik | Zellanker korrigieren Quellversatz von 12/24 Pixeln horizontal und 2 Pixeln vertikal. Filmische und unmittelbar gezeichnete Flugansichten verwenden denselben Ankervertrag. Alle sechs Zustände im Renderer gesichtet; [Technikfilm](../previews/aerodyne-bilder-v037.webp) aus 130 echten Frames. Keine nachträgliche Bemalung oder Verzerrung der Quelle. |
| Szenen und Kontakt | Tower-Ankunft, Griff, Flucht vom tatsächlichen Landeplatz, Fall am tieferen Balkon vorbei, Hangar-Laufweg, Kabinenöffnung, Einsteigen und Start vollständig im Renderer durchlaufen. 19 markierte Ansichten; offene Luke und Start gesichtet. See-Ankunft und Finale mit neuer Quelle in den Ablaufprüfungen vollständig durchlaufen; tatsächliche See-Ankunft zusätzlich im Gesamtspiel-Galerielauf erfasst. |
| Storyprüfung | `tools/cinema_review.gd` durchläuft tatsächliche Szenenmethoden der Kapitel 1–7 und speicherte 119 Renderer-Stichproben. Repräsentative Bilder aller sieben Kapitel gesichtet. Ressourcen/Abläufe der drei Erinnerungen ergänzend im Code und anhand bestehender Abnahmen geprüft. [Gesamter Bericht mit Prioritäten](../cinema-roadmap.md). |
| Controller, Pause, Skip, Abbruch, Laden | Neue Tür-/Motorbilder an pausierbare Szenenuhren gebunden. Vorhandene Controller-B-, Sichtbarkeits-, kontrollierte Flug-/Landungs-, Skip-/Checkpoint-/Legacy- und Abbruchprüfungen bestanden. Keine Eingaben neu belegt. |
| Aktuelle automatisierte Prüfungen | **811 Fälle, 0 Fehler:** Hauptsuite 383, neue Rumpf-/Kabinenprüfung 30, filmische Laufwege/Flucht 50, Flug 50, See 32, Fahraktion 60, Storyaudit 206. Nach der letzten Anpassung der gemeinsamen Flug-/Düsenanker Flug und Fahraktion gezielt erneut geprüft; keine Doppelzählung. |
| Export | Linux-PCK gebaut, im tatsächlichen Renderer gestartet; **11 zusätzliche Fälle, 0 Fehler**. Neue Rumpfquelle, offene/geschlossene Kabine, Motorphasen, beide Kapitel-7-Musikslots, Kontrollpunkt, maskierte Schlussumarmung, Menüzuordnung und spielbare Flugansicht aus dem Paket geprüft. Flugbild gesichtet. |
| Version / Sicherung | 0.37.0 in Projekt und aktuellen READMEs, 0.37.0.0 in beiden Windows-Feldern, CHANGELOG und neue Hinweise mit CodexAI. Geänderte lokale Dokumentationslinks und `git diff --check` geprüft. Sicherungsziel des gemeinsamen Commits: `origin/main`; keine Cloud-Veröffentlichung oder neuen Release-Tags. |

Neue Fahrzeugprüfung im GitHub-Build. Reproduzierbare lokale Aufrufe:

```sh
godot --headless --editor --import --quit
godot --headless --script res://tests/aerodyne_art.gd
godot --audio-driver Dummy --script res://tools/aerodyne_art_gallery.gd
godot --audio-driver Dummy --script res://tools/cinema_review.gd
godot --audio-driver Dummy --script res://tools/cinematic_gallery.gd
```

**Grenzen:** Renderer-Aufnahmen mit Dummy-Audio; Musikdatei und Zuordnung technisch geprüft, keine neue akustische Abnahme. Kein nativer Windows-Programmstart. Galerie nutzt QA-Abkürzungen an Kampfübergängen, keine Behauptung eines vollständig manuell erspielten Gesamtdurchlaufs. Die drei Erinnerungen in dieser Runde nicht nochmals vollständig manuell gespielt. Die Roadmap ist zusätzlicher Bedarf, kein bereits eingebauter Umbau aller Szenen. Das eingemalte Erkundungs-Hangarschiff, Kurven-/Rollbilder und weitere Props bleiben klar benannte offene Arbeit.

**Ergebnis:** Beauftragte Musikzuordnung, erster konkreter Spriteausbau und projektweite Cinema-/Objektanalyse abgeschlossen und reviewbar.
