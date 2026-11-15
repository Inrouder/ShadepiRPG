# Konsistenzauftrag: Touch-HUD und WLAN-Menü · v0.63.0 · CodexAI

**Ausgang:** `7cb916d`, v0.62.0; alle Remote-Branches vor Arbeit abgerufen und verglichen, Main ist aktuell, Arbeitskopie sauber. Nutzer bestätigt Android-Start und rudimentären Koop und wünscht WLAN im regulären Menü sowie ein sehr transparentes kreisförmiges Analog-HUD mit Bildtasten nach seiner Screenshotreferenz.

**Quellen:** AGENTS, KONSISTENZ, gesamte Stilbibel und UI-/FX-Karte; v0.62.0-WLAN-/Touch-Spielansichten tatsächlich angesehen. Raven-Pixelrahmen und Schriften bleiben für Menüs; neues Overlay verwendet generierte Silber-/Stahlpixel mit wenig Cyan. Die Referenz bestimmt Anordnung/Transparenz, keine Übernahme von Logos oder fremden Spielassets. Figuren, Story, Welten und Fuß-/Handanker sind nicht betroffen und bleiben unverändert.

**Grafik:** [Unveränderte Bildausgabe und Zuschnitte](../../tools/mobile-ui-v063/README.md). Transparente PNGs, keine glatten Vektorgrafiken; keine Skalierung von Figuren. Analogknopf folgt kontinuierlicher Fingerbewegung innerhalb des Kreises, Totzone und begrenzte Auslenkung erhalten. Aktionsringe und Glyphen werden im Ruhezustand gedämpft, beim Drücken deutlicher. Feste Kreis-Hitflächen bleiben auf dem 640×360-Raster. Root-only-Ebene wird weiterhin nicht ins HQ-Ziel gespiegelt.

**Menü:** Gemeinsamer `hud.gd`-Eintrag für alle Kapitel, dynamische Reihenhöhe bei voller Freischaltung, Verbindungshinweis. WLAN-Fenster gibt den Fokus zurück. Kein zusätzlicher Launcher über dem Spiel. Lokale Menüs/Hacks verdecken keine Touch-Bildtasten; Android-Zurück erlaubt dem Client seine eigene Verbindung zu verwalten.

**Prüfung / Aufnahmen / Export:** folgt nach Abschluss; nur isolierte `shadepi-…`-Datenverzeichnisse. Nutzerbestätigung von v0.62.0 bleibt getrennt von neuer Abnahme. Version in Projekt, Windows-/Android-Exporten, README, Spieleranleitung, Manifest und Changelog fortlaufend v0.63.0 · CodexAI. APKs und Schlüssel außerhalb Git, finale Quellen/Doku gemäß bestehender Erlaubnis auf GitHub sichern. Keine Cloud-Veröffentlichung.
