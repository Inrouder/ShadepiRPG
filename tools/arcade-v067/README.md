# Arcade-Eingabe-Aufnahmen · v0.67.0 · CodexAI

`gallery.gd` nimmt echte Kampfzustände mit geskripteten Richtungen/Buttons nativ in 1280×720 auf. Ausschließlich `/tmp/shadepi-v067-gallery/`, keine Asset-Erzeugung. Benötigt einen Desktop und isolierte Daten, etwa:

```sh
XDG_DATA_HOME=/tmp/shadepi-arcade-gallery godot --audio-driver Dummy --script res://tools/arcade-v067/gallery.gd
```

PNG-Einzelbilder und 15-fps-Filmframes unter `frames/`. `-- --rest` setzt eine unterbrochene Aufnahme ab dem Charge-Teil fort und erhält vorhandene Frames. Mobilbild verwendet die tatsächliche kontextabhängige Touch-Ebene über dem Automaten. Keine Handyaufnahme. [Bedienung/Bilder/Film](../../docs/arcade-inputs-v067.md) · [Arbeitsnachweis](../../docs/arbeiten/arcade-inputs-v067.md). Vor normalen Spielstarts nicht ausführen.
