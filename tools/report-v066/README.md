# Fehlerbericht-Aufnahmen · v0.66.0 · CodexAI

`gallery.gd` nimmt echte Godot-Szenen ausschließlich nach `/tmp/shadepi-v066-*` auf, mit isoliertem `XDG_DATA_HOME=/tmp/shadepi-…`. Desktop nötig. Modi: ohne Argument Jackal/Abgang, `-- --garage`, `-- --digital`, `-- --bridge`, `-- --tower`. Bestätigt Dialoge automatisch, beschleunigt Szenen und schützt die Boss-Testfigur; kein normaler Spielstand wird geöffnet. Kein Bildgenerator oder Nachzeichnen von Spielgrafiken. Vorschaufilme werden nur aus diesen Aufnahmen kodiert.

[Spielbericht](../../docs/fehlerkorrekturen-v066.md) · [Konsistenznachweis](../../docs/arbeiten/fehlerkorrekturen-v066.md). Native Tor-Maskenprüfung in `tests/regressions_v066.gd` rendert den echten Ankunftssprite/Shader zusätzlich in ein sauberes transparentes SubViewport.
