# Kino-/Fahransichten · v0.65.0 · CodexAI

`gallery.gd` spielt isolierte native QA-Aufbauten im echten Godot-Renderer ab. Ausgabe ausschließlich nach `/tmp/shadepi-v065-*`. Erfordert Desktop und `XDG_DATA_HOME=/tmp/shadepi-…`; `-- --garage-only` nimmt nur die beiden Torzustände auf, `-- --outbound-only` nur Wüstenflug und Seeanflug. Kein Asset-Generator und keine Arbeit an normalen Spielständen.

`sources.json` hält SHA-256 und Herkunft der zwei neuen, unverändert übernommenen Bildgenerator-Ausgaben fest. Die aktive Wüstenquelle liegt unter `assets/story/outbound/desert.png`, der neue Überschlagsatlas unter `assets/vehicles/pursuit/rollover.png`. Vor Erstellung wurden die vorhandenen Welt-/Fahrzeugquellen und Figurenkarten gesichtet; nur der Wagenatlas wurde als Bildreferenz an das Grafikwerkzeug übermittelt. Die anderen Quellen dienten dem gesichteten Stilbriefing. Keine Rohbildduplikate allein für die Doku gespeichert.

Registrierung über `scripts/pursuit_car_art.gd` und `tools/sprites/atlas_regions.py`. [Arbeitsnachweis](../../docs/arbeiten/cinema-v065.md) · [Spielbilder und Tests](../../docs/fahrt-flug-v065.md). Nicht beim normalen Setup ausführen. Historische Hersteller für `wreck.png` erzeugen den neuen Atlas nicht.
