# Repository-Aufräumung · v0.46.2 · CodexAI

## Auftrag und Ausgang

Nutzerziel: Repository ordentlich aufräumen und Altlasten richtig markieren. Ausgang `0b0623e`, v0.46.1; lokal sauber. Alle Remote-Branches abgerufen und Versionen verglichen, main aktuell; übrige bekannte Branches unverändert höchstens v0.21.3. Keine fremde Arbeit überschrieben. AGENTS/KONSISTENZ, Art Direction und Arbeitsvorlage berücksichtigt. Keine neue Grafik oder Storyänderung.

## Bestand und Abgrenzung

- Verworfene Helden v0.45.0, ihr seit Wiederherstellung der Originale toter Renderer, frühere Comictafeln und GIF-Vorschauen nach `docs/archiv/` verschoben. Dateien und Herkunft im Git erhalten; keine Git-Historie gelöscht.
- Tote Felder/Verzweigungen des verworfenen Renderers aus PixelActor, Player, SpriteAssets und Mündungsaufruf entfernt. Dieselben Originalpfade, Raster, Fußanker, Sonderbewegungen und Schuss-/Handanker bleiben aktiv. Originalhelden, NPCs, Szenenposen und Blut-FX nicht neu gezeichnet.
- Historische Menü-/Heiligtum-Vergleichsblätter und gewünschte Original-Backups an stabilen Pfaden belassen, klar markiert und vom Spieleexport ausgeschlossen. Die Heiligtum-Vorher-Galerie darf ihre Vergleichsquelle weiterhin bewusst lesen.
- `legacy` in Erinnerung III bedeutet „Vermächtnis“ und bleibt aktiv. Das Universumsarchiv ist verbindliche Nutzerquelle und keine verworfene Altlast. Herstellungscompiler sind optionale schreibende Werkzeuge, kein notwendiger Import-/Setup-Schritt.
- README-Versionschronik, alte Anleitung und alte Implementierungsübersicht vollständig mit Herkunft/Nachfolgern archiviert. Aktuelle Einstiegsseiten und Architektur gekürzt/berichtigt; widersprüchliche Timing-, Tower- und Comic-Abläufe nur noch historisch. Versionsnachweise und frühere Aufnahmen als solche markiert, nicht in heutige Abnahmen umetikettiert.
- Alle relativen eingehenden Markdown-Links und Links innerhalb verschobener Dokumente auf reale neue Ziele umgestellt. Aktuelle PNG-Vorschauen bleiben direkt auf GitHub eingebettet; keine neuen Renderbilder für reine Dokumentationsarbeit erzeugt.

## Prüfung

Repository-Audit liest Statusmanifest, reale lokale Links, feste Ressourcenverweise, Versions-/Exportgrenzen und Git-Cachegrenzen. Dynamisch zusammengesetzte Ladepfade werden durch Godot-Regression/Export geprüft; Screenshot-Ausgabeziele sind keine Eingaberessourcen. Vergleich von Original-/verschobenen Quellbytes, Import, Regression und Exportnachweis folgen vor Abschluss.

Nicht betroffen: neue Figurenmerkmale/Posen, Dialoge, Eingaben oder Audioinhalte. Bestehende Controller-/Kampfpfade werden mit gezielten Regressionen geprüft; keine neue manuelle Controller-/Audioabnahme. Spielstände isoliert über `XDG_DATA_HOME`.

Version 0.46.2 / Windows 0.46.2.0, CodexAI. Aktive Standbilder bleiben Aufnahmestand v0.46.1 beziehungsweise der jeweils im Bericht genannten Version. Keine Veröffentlichung der Cloud-Umgebung und kein Release-Tag.
