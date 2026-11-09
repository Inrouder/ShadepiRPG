# Handführung am See · v0.36.1 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

## Auftrag und Referenzen

- **Nutzerziel:** Raven hebt Shadepis Maske mit ihrer eigenen rechten Hand; ihre eigene linke Hand berührt sein Gesicht und verdeckt weiterhin dessen Züge. Diese Zuordnung muss über Maskenabnahme und Kuss konsistent bleiben.
- **Ausgang:** `1b72906`, v0.36.0. Lokaler Stand sauber und gleich GitHub `main`; alle Remote-Branches erneut abgerufen. Die älteren Entwicklungsbranches haben keine neuere Arbeit erhalten. Keine fremden Änderungen offen.
- **Aktive Quellen gesichtet:** Bisheriger `assets/story/lake/poses.png`, normale Figurenkarten `docs/stilbibel/bilder/figur-raven.png` und `figur-shadepi.png`, Art Direction und See-Szenenvertrag. Die korrigierten Zellen ersetzen den Handfehler der v0.36.0, nicht den etablierten Figurenstil.
- **Erhalten:** Raven 160 cm und ihr schwarzer Cyan-Anzug, rote Schulterzeichen, schwarze/blaue Haare; Shadepis breiter Kasa, dunkle Weste, Stoffbahnen und verdeckte Gesichtszüge. Kein neuer Zentimeterwert für Shadepi, keine neue Gesichtsidentität. Comic nicht lokal vorhanden.
- **Umfang:** Gezielte Bildbearbeitung des vorhandenen Atlas durch das Grafikwerkzeug. Keine neuen Szenen, kein Austausch von Kulisse, Flug, Drachenquelle oder normaler Figurenanimation. Quellgenerierung erhalten; keine programmgesteuerte Bemalung der PNG.

## Grafikvertrag

Vier Zellen à 768×512 im transparenten 1536×1024-Atlas; bestehender Fußanker `(300,488)` und Maßstab `0.125`. Maskenabnahme und Kuss zeigen Ravens linke Hand von ihrer nahen Schulter am Gesicht Shadepis, während ihre rechte Hand die abgenommene Maske angehoben hält. Die Zuordnung bezieht sich auf Ravens Anatomie, nicht auf die Bildschirmseiten. Hand, Kasa und Kopfwendung verbergen Shadepis Gesicht durchgehend. Händehalten und Schlussumarmung bleiben dieselben Aktionen; die normale lineare Abtastung und Kontakt-/Bodenschatten bleiben erhalten.

## Abnahme

**Sichtprüfung: CodexAI, 9. November 2026, Godot 4.7.2, tatsächlicher OpenGL-Renderer.**

| Prüffeld | Tatsächliches Ergebnis / Beleg |
| --- | --- |
| Arme und Handkontakt | Maskenabnahme und Kuss im Quellblatt und in Spielgröße einzeln gesichtet. Naher linker Arm führt von Ravens Schulter mit sichtbarem rotem Emblem zur verdeckenden Hand; rechte Hand hält die Maske angehoben. Keine zusätzliche Hand, kein vollständiges Gesicht. [Maskenabnahme](../previews/see-maske-v0361.png), [Kuss](../previews/see-kuss-v0361.png) |
| Stil, Größe, Füße, Transparenz | Bestehende Maße und Anker funktionieren weiter. Schlussumarmung neben normalen Raven-/Shadepi-Sprites bei gleicher Kamera verglichen; Figuren und Kostüme konsistent. Alpha-Ränder und Körperdeckkraft in allen vier Zellen geprüft. |
| Ganze Animation / Rückkehr | Finale ohne Überspringen durchlaufen, einschließlich Händehalten, Maskenabnahme, Kuss, Drachenschatten, Umarmung und Abschluss. 178 tatsächliche Renderer-Frames über etwa 23,25 Sekunden aufgenommen; [durchgehender Film](../previews/see-finale-v0361.webp). |
| Controller, Pause, Skip, Laden, Abbruch | Vorhandene 32 Seeprüfungen mit neuer Quelle erneut bestanden, darunter rohes Controller-B, Pause von Licht/Uhr, vollständiger Anflug/Finale, Legacy-Spielstände und Rücksetzung der Figuren beim Kapitelwechsel. Tastatur-/Ton-/Bildstilimplementierung unverändert; native Aufnahme mit Dummy-Audio, keine neue akustische Abnahme. |
| Export | Linux-PCK gebaut, tatsächlich gestartet und Kontaktpose mit den gepackten Ressourcen gerendert und gesichtet. Acht zusätzliche Prüfungen bestanden: Szenenstart/-abschluss, Skip, Kontrollpunkt, beide HQ-Quellen, Shader und Kapitelwechsel. Keine native Windows-Prüfung. |
| Version / Sicherung | Spielversion 0.36.1, Windows-Datei-/Produktversion 0.36.1.0, beide READMEs, CHANGELOG und neue Hinweise mit CodexAI. Quellbild, Spielaufnahmen, Galerieoptionen und Dokumentation gemeinsam im Git-Commit; Sicherungsziel `origin/main`. Keine Cloud-Veröffentlichung. |

Reproduzierbare Sichtprüfung nur des betroffenen Finales:

```sh
godot --audio-driver Dummy --script res://tools/lake_gallery.gd -- --film --finale-only --out=/tmp/shadepi-lake-v0361
godot --headless --script res://tests/lake_sequence.gd
```

**Ergebnis:** Handkorrektur fertig. 32 gezielte Szenenprüfungen und acht zusätzliche Exportprüfungen, jeweils 0 Fehler. Automatische Prüfungen ersetzen nicht die oben dokumentierte anatomische Sichtprüfung. Die 920 Prüfungen der Einführungsversion wurden für diese reine Grafikänderung nicht pauschal wiederholt.
