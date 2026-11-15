# Konsistenzauftrag: Touch-HUD und WLAN-Menü · v0.63.0 · CodexAI

**Ausgang:** `7cb916d`, v0.62.0; alle Remote-Branches vor Arbeit abgerufen und verglichen, Main ist aktuell, Arbeitskopie sauber. Nutzer bestätigt Android-Start und rudimentären Koop und wünscht WLAN im regulären Menü sowie ein sehr transparentes kreisförmiges Analog-HUD mit Bildtasten nach seiner Screenshotreferenz.

**Quellen:** AGENTS, KONSISTENZ, gesamte Stilbibel und UI-/FX-Karte; v0.62.0-WLAN-/Touch-Spielansichten tatsächlich angesehen. Raven-Pixelrahmen und Schriften bleiben für Menüs; neues Overlay verwendet generierte Silber-/Stahlpixel mit wenig Cyan. Die Referenz bestimmt Anordnung/Transparenz, keine Übernahme von Logos oder fremden Spielassets. Figuren, Story, Welten und Fuß-/Handanker sind nicht betroffen und bleiben unverändert.

**Grafik:** [Unveränderte Bildausgabe und Zuschnitte](../../tools/mobile-ui-v063/README.md). Transparente PNGs, keine glatten Vektorgrafiken; keine Skalierung von Figuren. Analogknopf folgt kontinuierlicher Fingerbewegung innerhalb des Kreises, Totzone und begrenzte Auslenkung erhalten. Aktionsringe und Glyphen werden im Ruhezustand gedämpft, beim Drücken deutlicher. Feste Kreis-Hitflächen bleiben auf dem 640×360-Raster. Root-only-Ebene wird weiterhin nicht ins HQ-Ziel gespiegelt.

**Menü:** Gemeinsamer `hud.gd`-Eintrag für alle Kapitel, dynamische Reihenhöhe bei voller Freischaltung, Verbindungshinweis. WLAN-Fenster gibt den Fokus zurück. Kein zusätzlicher Launcher über dem Spiel. Lokale Menüs/Hacks verdecken keine Touch-Bildtasten; Android-Zurück erlaubt dem Client seine eigene Verbindung zu verwalten.

## Prüfung und Sichtabnahme

- **18 mobile Checks:** echte Touch-Ereignisse für kontinuierliche diagonale Achsen, Totzone, sichtbaren Knopfversatz, unabhängige Finger, Laden mit zwei Fingern, Kreis-Hitflächen, Fokusverlust und Android-Zurück-Signal (automatisches SceneTree-Beenden dafür abgeschaltet). TextureRect-Größen werden zusätzlich geprüft, damit intrinsische PNG-Mindestgrößen die Bilder nicht aus dem sichtbaren Feld drücken.
- **16 Menüchecks:** echter Controller öffnet den integrierten WLAN-Eintrag; B schließt die Verbindungseinstellung und gibt den Fokus zurück. Bestehende Kapitel-/Kontrollpunkt-Popups, Hauptmenü-/Pausenumfang und Desktop-Ende bleiben geprüft.
- **262 Mondsee-/Menüchecks**, **64 HQ-Popupchecks**, **186 Terminal-Controllerchecks**, jeweils ohne Fehler. Alle betroffenen Kapitel und Ausgabegrößen bleiben im Menürahmen. Kein vollständiger erneuter Storydurchlauf für diese UI-Änderung behauptet.
- **18 Zwei-Prozess-WLAN-Checks** und **5 native Stream-/Touch-Checks** ohne Fehler; der tatsächliche zweite Renderer empfängt 17 Spielbilder und bewegt Raven mit dem neuen Kreisstick. Vorhandene 15-FPS-Obergrenze unverändert.
- Native Linux/Godot-Sichtabnahme am 15. November 2026 in isolierten `shadepi-…`-Datenverzeichnissen: transparentes Ruhesymbol, gedrückter Ring, Knopfauslenkung, Hand-/Katana-/Pistolenglyphen, freie Bildschirmmitte, Menü bei voller Freischaltung und Verbindungsfenster tatsächlich angesehen. [PNG und kurzer Film](../touch-hud-v063.md). Frühere Bildtexte sind als v0.62.0 erhalten; neue Bilder sind keine Telefonfotos.
- Erstimport der neuen Autoload-PNGs wurde auf Laufzeitladung umgestellt; der nachfolgende Editorimport und die Spieltests melden keine Parser-/Laufzeitfehler. Quellen wurden nicht erneut generiert. Heros, Kampfposen und Kulissen sind gegenüber dem Ausgang unverändert.

## Export und Sicherung

Nur isolierte `shadepi-…`-Datenverzeichnisse. Nutzerbestätigung von v0.62.0 bleibt getrennt von neuer Abnahme. Version in Projekt, Windows-/Android-Exporten, README, Spieleranleitung, Manifest und Changelog fortlaufend v0.63.0 · CodexAI. APKs und Schlüssel außerhalb Git, finale Quellen/Doku gemäß bestehender Erlaubnis auf GitHub sichern. Keine Cloud-Veröffentlichung.


**Exportnachweis:** Finale Android-APK signaturgeprüft, Version 0.63.0 / Code 6300. Alle neun Touch-Texturzuordnungen sind im APK enthalten; die Generatorquelle unter `tools/` ist ausgeschlossen. Windows und Linux als Release exportiert; Linux-Paket startet mit Touch-Autoload über 90 headless Frames ohne Fehler. Windows wurde exportiert, nicht auf einem Windows-Rechner ausgeführt. Die neue APK wurde hier nicht auf einem physischen Handy installiert; Nutzerbestätigung betrifft weiterhin v0.62.0.

**Sicherung:** Repository-Audit, Versions-/Linkprüfung und `git diff --check` ohne Fehler. Lokaler Zwischenstand `aab28a6`, anschließend Prüfnachweis und Zurücktasten-Korrektur gesichert. Alle Remote-Branches erneut geprüft, keine neuere fremde Arbeit. Finale Übertragung auf GitHub `main`; keine Cloud-Veröffentlichung und kein Release-Tag.
