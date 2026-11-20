# Konsistenzauftrag / Arbeitsnachweis · v0.67.1 · CodexAI

**Auftrag:** Weitere Fehler beheben und anschließend die neueste Spielversion als GitHub-Release mit Downloads veröffentlichen. Der Nutzer autorisiert diese Veröffentlichung ausdrücklich am 20. November 2026.

**Ausgangslage:** `e6ea283a4346354e0f7ab62df0febd042200644c`, v0.67.0; saubere Arbeitskopie. Alle Remote-Branches abgerufen und Versionen/Inhalte verglichen; main aktuell, ClaudeHelper zuletzt v0.60.3. `git merge --ff-only origin/main`: bereits aktuell. Öffentliche Actions-Seite bestätigt den erfolgreichen vorherigen Lauf 44169237971; zuletzt öffentliches Release v0.60.3. Direkte GitHub-API im Cloud-Netz gesperrt, Git und öffentliche HTML-Seiten erreichbar; vorhandener Tag-/Actions-Release-Weg wird genutzt.

**Umfang:** Bestätigte Arcade-Fehler bei langen Renderbildern, altem CPU-Plan und Hintergrundwechsel; Release-Paketierung mit Android, Prüfsummen, passenden Versionsnotizen. Keine Kampagnen-/Storyänderung, keine neuen Spielgrafiken. Neue Version 0.67.1 · CodexAI, Windows 0.67.1.0, Android 6701.

**Referenzen:** AGENTS, KONSISTENZ, Repository-Status, Stilbibel-Art-Direction, aktiver Arcade-Quellvertrag und v0.67.0-Steuerung. Tatsächliche neue native Ansichten mit Raven/Shadepi im bestehenden Dachbild geprüft. Vorhandene HQ-Atlanten, Hand-/Fußanker, Materialien und Figurenmerkmale vollständig übernommen, keine Generierung oder Stauchung. Raven 160 cm, schwarz-blau/Cyan; Shadepis schwarze Ausrüstung, segmentierte Maske und Kasa unverändert. Referenzfilm aus v0.67.0 ausdrücklich datiert wiederverwendet.

**Technik:** Angriffstasten nur im ersten Simulationsschritt, gehaltene Richtungen weiterhin in jedem Schritt; maximale Nachholzeit 250 ms. Bestehender Motion-/Charge-Parser und unveränderte Schadensfenster. CPU-Plan vollständig beim Rundenstart leeren. Hintergrundmeldung verwendet dieselbe Arcade-Pause wie Esc/Start. Keine neuen Spielstandfelder oder Kapitel-Enums.

**Nachweise:** Fehler vor Korrektur tatsächlich reproduziert (fünf rote Checks), anschließend neue Regressionen grün. Native PNGs aus echtem Godot/X11/llvmpipe, 1280×720; Fokus-/App-Meldung programmgesteuert, kein physischer Geräteversuch. Release-Shell lokal mit Testartefakten ausgeführt, Notizen/ZIPs/Prüfsummen kontrolliert, Workflow-Blöcke syntaktisch geprüft. [Bericht](../release-v0671.md) und [Prüf-/Paketnachweis](../pruefungen/v0671/ergebnisse.json).

**Grenzen / Sicherung:** Signaturarbeit beim Nutzer, keine neue Schlüsselverwaltung. Tests und lokale Exportstarts getrennt von tatsächlicher GitHub-Veröffentlichung ausweisen. GitHub-Tag nicht verschieben/überschreiben; bei fehlgeschlagenem Push vollständige Projektkopie außerhalb des Repos sichern. Datum 20. November 2026; CodexAI.
