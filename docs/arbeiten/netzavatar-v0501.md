# Konsistenzauftrag und Arbeitsnachweis: Ravens Netzavatar

**v0.50.1 · CodexAI · 10. November 2026.** [Bilder und Film](../netzavatar-v0501.md) · [Vorlage](../vorlagen/konsistenz-auftrag.md).

## Auftrag und Ausgangslage

- **Nutzerziel:** Raven im Netz als Gittersilhouette ihrer eigenen Figur zeigen.
- **Ausgang:** `31955cc`, v0.50.0, sauberer Arbeitsbaum. Alle Remote-Branches abgerufen und mit dem Stand der letzten Arbeit verglichen: `main` aktuell, keine neueren Entwicklungsstände. Keine fremden Änderungen überschrieben. Vor Sicherung erneut alle Branches abgerufen: unverändert `origin/main=31955cc`.
- **Umfang:** Netzshader und Darstellungsschaltung ausschließlich im Kapitel-2-Deep-Dive. Bossmechanik und normale Heldengrafiken bleiben erhalten. Neue Version v0.50.1 · CodexAI.

## Referenzen und unveränderte Merkmale

| Zweck | Tatsächlich gesichtet | Übernommen |
| --- | --- | --- |
| Raven | Stilbibelkarte `figur-raven.png`, Original `raven.png`, bestehender Renderer und Handposenmetadaten | vollständige Körper-/Haar-/Handkontur, Acht-Richtungs-Animation, ursprüngliche Poseanker; Raven bleibt 160 cm |
| Aktive Szene | `ice-kern-v050.png`, aktuelle Chapter-2-Szene, native Neuaufnahmen | virtuelle Cyan-/Violettfamilie, Spielgröße 640×360 und Bosskontakt |
| FX-/Stilregeln | KONSISTENZ, AGENTS, Art Direction und UI-/FX-Karte, Arbeitsvorlage | vorhandene HQ-Pixelquellen statt neu erfundener flacher Ersatzkörper |

Verworfene v0.45-Helden bleiben archiviert. Keine Lore geändert; Gitterabstand und Farbe sind Darstellungsentscheidungen. Keine neue Grafikquelle erzeugt und keine PNG-Bearbeitung ausgeführt. Die Vorschauen sind direkte Godot-Aufnahmen.

## Grafik und Animation

- `net_avatar.gdshader` maskiert Raster und Kontur mit der tatsächlichen Quelltransparenz jeder Pose. Abtastung am Zellrand verhindert Konturen fremder Atlaszellen.
- 4×4-Weltpixelraster am Fußanker; Handposen behalten ihren eigenen Maßstab und die vorhandenen Handanker. Raster läuft bei Bewegung mit der Figur, kein freischwebendes Rechteck.
- Ursprüngliche Körper- und Haaranimationen, Lade-/Angriffsphasen und Fußkontakt unverändert. Netzprojektion benötigt keinen physischen Schlagschatten.
- Eigene Effekt-Clock statt globalem Shader-TIME: Pause hält den Datenimpuls an. Rückkehr und Laden stellen den jeweiligen Darstellungskontext her.

## Prüfung und Nachweise

| Prüffeld | Ergebnis / Beleg |
| --- | --- |
| Aktive Quellen und Merkmale | Original-/Handzauber-PNGs unverändert; aktuelle Alphaform gibt jede Pose vor. |
| Sichtprüfung | Native OpenGL-Godot-Aufnahmen: normale Kampfansicht, Detail, acht Blickrichtungen, Gehen, Handangriff und physische Rückkehr. [Bilder](../netzavatar-v0501.md). |
| Pixelkontur | Zusätzlich native SubViewport-Prüfung mit transparentem Hintergrund: sichtbares Cyan-Gitter, transparente Zwischenräume und kein Gitterpixel außerhalb der tatsächlichen Original-Alphaform. |
| Kontakt und Abtastung | Fuß-/Handanker bleiben im vorhandenen Renderer; source-step wird an den jeweils aktiven Posemaßstab angepasst. |
| Controller/Tastatur | Keine Eingabebelegung verändert; bestehende ICE-/Kampfregressionen prüfen die Aktionen. |
| Pause / Laden / Rückkehr | Netzeffekt in allen drei Relais; Clock pausiert/resumiert; Haupt- und Handatlas behalten Material; physischer Shader und Schatten nach Rückkehr; Saveformat unverändert. |
| Ton / Überspringen | Keine neuen Ton- oder Filmabläufe; bestehende Eisbad-/Storytests relevant. |
| Automatische Prüfungen | 905 gezielte Headless-Checks ohne Fehler: Netzeffekt 52, ICE 41, Core 382, Kampfaktionen 68, Raven/Gegner 292, Eisbad 49, Fehlerbericht 21. Zusätzlich 56 native Checks einschließlich vier echter Pixelbildprüfungen ohne Fehler. |
| Export | Linux-PCK v0.50.1 erzeugt und nativ gestartet: 18 Prüfungen ohne Fehler zu Version, Ressourcen, Bosskampf, Netzshader und Wiederherstellung nach Rückkehr. Originalhelden und vorige Exportgrenzen erhalten. |
| Version / Sicherung | v0.50.1 · CodexAI in Versionsfeldern und Änderungsinfos. Nach erfolgreicher Prüfung auf `main` sichern; kein Cloud-Publish oder Release-Tag. |

**Sichtprüfung:** CodexAI, 10. November 2026, Godot 4.7.2, native OpenGL-Kompatibilitätsdarstellung. Film 64 Bilder / 142.704 Bytes. Kein neuer kompletter manueller Spieldurchlauf behauptet.


## Reproduktion

```sh
XDG_DATA_HOME=/tmp/shadepi-net-tests godot --headless --script res://tests/net_avatar.gd
# Für die vier zusätzlichen Pixelbildprüfungen denselben Test auf einem nativen Display starten:
XDG_DATA_HOME=/tmp/shadepi-net-native godot --audio-driver Dummy --script res://tests/net_avatar.gd
python3 tools/audit_repository.py
godot --headless --export-pack Linux /tmp/shadepi-v0.50.1.pck
```

Native Aufnahmen: `tools/net_avatar_gallery.gd`, eigener Xorg-Dummy-Server. Paketprüfer außerhalb der Repository-/Exportquellen unter `/tmp/shadepi501-pack.gd`. Original-Raven, Shadepi und Handzauber-PNGs sind gegenüber `31955cc` bytegleich. Die Shader-Funktion übergibt keine eingebauten Textursampler als Funktionsparameter; dadurch kompilieren der native und der Headless-Renderer ohne Shaderfehler.

**Ergebnis:** gewünschte Gittersilhouette umgesetzt, sichtgeprüft und exportgeprüft. Aufwändige neue Heldenquellen waren dafür nicht erforderlich.
