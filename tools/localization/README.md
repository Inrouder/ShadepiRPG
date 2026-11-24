# Sprachprüfung · v0.70.0 · CodexAI

`audit.py` liest den PO-Katalog und die sichtbaren Skriptliterale. Prüft vollständige Übersetzungseinträge, identische printf-Platzhalter und unveränderte Decoder-Codes. Python-Standardbibliothek, keine Downloads und keine Dateiänderungen.

`gallery.gd` nimmt Hauptmenü, Optionen, Sprachliste, Routing-Hack, Handbuch und Gesundheitshinweise nativ als 1280×720-PNGs auf. Es benötigt ein vorhandenes X11-Display und isolierte Nutzerdaten unter `/tmp/shadepi-…`; andere Datenpfade werden abgelehnt. Ausgabe ausschließlich nach `/tmp/shadepi-language-gallery/`. Keine Bildgenerierung und keine produktiven Spielstände.

```sh
python3 tools/localization/audit.py
XDG_DATA_HOME=/tmp/shadepi-language-check godot --headless --script res://tests/localization.gd
DISPLAY=:96 LIBGL_ALWAYS_SOFTWARE=1 XDG_DATA_HOME=/tmp/shadepi-language-native godot --audio-driver Dummy --script res://tools/localization/gallery.gd
```

Displaynummer an ein tatsächlich verfügbares Testdisplay anpassen. [Sprachvertrag](../../localization/README.md) · [Dokumentation und Bilder](../../docs/sprachen-v070.md).
