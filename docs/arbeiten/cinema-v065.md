# Konsistenzauftrag / Arbeitsnachweis · v0.65.0 · CodexAI

## Auftrag und Ausgangspunkt

- Nutzerauftrag 16. November 2026: mehr Fahrzeug-Voraussicht, sichtbarer Überschlag vor Explosion/Herausfahren, feststehende Straße hinter dem Garagentor, Flucht über Mondschein-Wüste/Nomaden und Dialog/Zeitsprung zum See.
- Basis `6853378`, v0.64.0; alle Remote-Branches abgerufen, main neuer als die ClaudeHelper-Zweige. Arbeitskopie zu Beginn sauber; keine fremde Arbeit ersetzt. Signatur ist ausdrücklich kein Arbeitsziel.
- Neue Spielversion 0.65.0, Windows-Felder 0.65.0.0, Android 6500; Versionshinweise und Commit-Vermerke CodexAI.

## Tatsächlich gesichtete Referenzen

| Quelle | Verwendung / Erhalten |
| --- | --- |
| `KONSISTENZ.md`, AGENTS, Stilbibel Art Direction und Fahrzeug-/Objektseite | HQ-Pixelmaterialien, Anker, gemeinsame Fahrzeugidentität, ursprüngliche Heldensprites. |
| Figurenkarten Shadepi/Raven unter `docs/stilbibel/bilder/` | Schwarzer Kasa/geschlossene Maske, Ravens schwarze/blauen Haare und Cyan-Anzug; Raven 160 cm. Keine Figurenquelle neu gezeichnet oder ersetzt. |
| `assets/vehicles/pursuit/car.png` | Tatsächlich übermittelte Bildreferenz für die neue Überschlagsfolge: gleiche Panzerung, Dachwaffe, Scheibe und Rückleuchten. |
| `assets/world/painted/airspace.png`, `lakeside.png`, `garage.png`, `industry.png` | Raum-/Nachtlichtfamilie, Mondstimmung, reale Toröffnung und brauchbarer fester Straßenausschnitt. |
| `aerodyne_art.gd`, `cinematic_aerodyne.gd`, `tower_escape.gd` und `lake_sequence.gd` | Derselbe registrierte Rumpf und gleiche Düsen; Start vom Landeplatz, Fangmanöver, bestehende trockene See-Landung erhalten. |
| Universumsarchiv Teil 4 und neues Nutzerbriefing Teil 8 | Bestehender Storyanschluss und die ausdrücklich beauftragte neue Gesprächs-/Zeitfolge. Kein fehlender Comic als gesichtete Datei ausgegeben. |

## Grafik / Registrierung

Zwei notwendige neue Bildgenerator-Ausgaben, keine einfachen Vektorersatzgrafiken. Die aktiven Dateien sind die unveränderten Ausgaben, einschließlich ihrer tatsächlichen Abmessungen. [Quellfingerabdrücke](../../tools/cinema-v065/sources.json).

- Wüstenkulisse 1672×941: Megastadt links fern, Vollmond rechts, Fels/Sand und drei kleine Nomadenlager mit Autos, Zelten und Personen. Keine Hauptfiguren oder Flugzeuge eingebrannt. Bild erst zur Szene laden. Feueranker in Quellpixeln (721,691), (1013,755), (1332,647); Licht-/Flammenpixel folgen derselben Hintergrundtransformation.
- Wagenatlas 1536×1024, 3×2, sechs 512er-Zellen. Seiten-/Unterbodenphasen statt einer gedrehten Draufsicht. Weltzeichenfläche 112×96, individuelle Kontaktanker in `pursuit_car_art.gd`. Gleiche Grundlänge, freie Außenräume; Atlasprüfung registriert.
- Kein Nachzeichnen, Freistellen oder kreatives Umfärben per Python. Dokumentationswerkzeuge lesen reale Godot-Frames und fassen/verkleinern sie ausschließlich zu Vorschaufilmen. Keine neuen Bilder allein für die Doku erzeugt.
- Ursprünglicher Einzelwrack-Stand bleibt als Referenz, ausgeschlossen vom Export. Historischer FX-Generator darf neue Überschlagsquellen nicht überschreiben.

## Laufzeit / Abnahme

`vehicle_view.gd`: gemeinsame 0,8-Projektion von Welt, Objekten und FX, Feld −80/−90/800/450; HUD normal, Landung wieder Originalprojektion. Der Mittelteil hält Straße und Kollisionskorridor fest; seitliche Kulisse wird kontinuierlich erweitert. Keine gespiegelten Schriftzüge oder durchscheinenden Helden. Neue Hindernisse bei Y −130.

Tor: fester vollständiger Außen-Quellbereich, sichtbare Teilfläche abhängig von der Öffnung. Asphalt, Wand und Regen wandern nicht mit der Torunterkante. Siegfahrt: sechs Sekunden, lesbarer Überschlag bis 1,6 s, dann Hauptdetonation, anschließend automatische Herausfahrt. Drei Etappen bleiben bestehen.

Outbound: derselbe Aerodyne wird umgehängt und von der neuen Szene gesteuert. Stadt → Lager → Raven → Shadepi → dunkle Zeitkarte → bisheriger See-Anflug. Pause stoppt Zeit/FX; Generation wird nach jedem asynchronen Schritt geprüft. Kein Kapitel-Enum geändert. Szenentausch/Laden/Überspringen setzen den Ablauf sicher zurück.

[Spielbilder, Filme, vollständiger Prüfnachweis und Grenzen](../fahrt-flug-v065.md). Sichtprüfung umfasst beide Projektionen, echte Überschlags-/Explosionsframes, feststehenden Torhintergrund, Mond-/Lageransicht und tatsächlich sichtbare Zeitsprung-Pixel. Windows-/Linux-/Android-Exporte samt Fingerabdrücken sind im maschinenlesbaren Nachweis ergänzt; exportiertes Linux-Spiel ohne Scriptfehler gestartet; kein physischer Handytest behauptet.
