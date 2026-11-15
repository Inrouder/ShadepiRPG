# Generierte Pixelquellen · v0.61.0 · CodexAI

15. November 2026. `sources/` enthält die **13 unveränderten Bildgenerator-Ausgaben**: zehn Kämpfer, ein gemeinsames Begleiterblatt, Material-/FX-Blatt und Automat. Keine Fremdgrafiken oder Franchise-Figuren übernommen. „Street Fighter / Tekken / Dragon Ball“ bezeichnet die vom Nutzer gewünschte Dynamik, nicht die Herkunft der Grafiken.

Die Referenzen waren die aktiven Figurenkarten in `docs/stilbibel/bilder/figur-<id>.png`, die tatsächlichen Front-/Seitenbilder der Originalatlanten, die Begleiter-Spielaufnahme `docs/previews/begleiter-v053.png`, Requisitentafel 2 und die vorhandene Dachbühne. Alle Quellen wurden vor dem Generieren angesehen. Der Automat verwendet seine alte Quelle zusätzlich als Perspektiv-/Proportionsreferenz. Originalhelden bleiben unangetastet.

Gemeinsames Briefing: detaillierte Cyberpunk-HQ-Pixelart mit materialgerechten Stoff-/Metallschatten und klaren Pixelclustern; echte Transparenz, keine Vektorformen oder glatten Illustrationen, keine Beschriftung oder Rasterlinien, vollständige Silhouetten und freie Zellränder. Kämpfer als 4×4-Blatt nach rechts: Bereitschaft, Atmen, zwei Gehbilder; Sprung, Block, Treffer, liegender K.O.; Faust ausholen/treffen, Kick anziehen/treffen; Spezial ausholen/auslösen, Sieg, Landung. Figurenmerkmale aus jeweiliger Karte ausdrücklich im Prompt, Spezialaktionen gemäß Arcade-Roster. Der Automat trägt bewusst seinen NEON-KOMBAT-Schriftzug. Begleiter: vier Rotor- und vier Feuerphasen, vier weiße und vier rote Nanitenformen. Requisiten-/FX-Zellen sind in der aktiven [Quellbeschreibung](../../assets/arcade/README.md) beschrieben.

`pack.py` **zeichnet keine Figuren**. Es findet leere Quelltrenner, schneidet die vorhandenen Pixel aus und setzt sie mit einheitlichem Maßstab pro Figur in einen transparenten Atlas. Bodenkontakt wird über die unteren Sohlenpixel registriert. Körperhöhe bleibt innerhalb eines Blatts konstant; Hocken, Springen und Liegen werden nicht auf Standhöhe gestreckt. Alle Ausschnitte, Platzierungen, Faktoren und Emissionsanker stehen in `assets/arcade/fighters/atlas.json`. Pixelinhalt wird nur mit Lanczos verkleinert und positioniert, keine Farbumzeichnung.

Bewusst schreibender Aufruf, benötigt Pillow/numpy:

```sh
python3 tools/art-v061/pack.py
python3 tools/sprites/audit_atlases.py
```

Nicht beim Setup ausführen. Quellen sind durch `.gdignore` vom normalen Import und `tools/*` vom Spieleexport ausgeschlossen. `gallery.gd` und `film.gd` sind versionsbezogene Aufnahmeaufbauten: explizit per `godot --script res://tools/art-v061/…` auf einem nativen Display mit isoliertem `XDG_DATA_HOME=/tmp/shadepi-…` starten. Sie schreiben nur `/tmp/shadepi-v061-world` und `/tmp/shadepi-v061-film`, keine Spielstände des Nutzers.
