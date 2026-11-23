# Spiel-Icon und Plattformvarianten · v0.69.2 · CodexAI

- `../../icon.png`: aktive 1024×1024-PNG für Projekt-/Fenster- und Mac-Icon, aus der unverändert archivierten Bildwerkzeugquelle per Lanczos verkleinert.
- `game-icon.ico`: sechs echte Windows-Größen, 16/32/48/64/128/256 Pixel. Exportpreset zeigt auf diese Datei. Die bestehende Windows-Einstellung `application/modify_resources=false` bleibt erhalten: der Linux-Exporter schreibt damit das Explorer-Icon des EXE-Templates nicht um. Das laufende Fenster verwendet das Projekt-PNG. Vor einem Windows-Release ist die PE-Einbettung separat nötig; die ICO-Datei lässt sich bereits direkt für Verknüpfungen verwenden.
- `android-main.png`: 192×192, vollständige Legacy-Icon-Fläche.
- `android-foreground.png`: 432×432 RGBA mit zentrierter 224px-Farbquelle und transparentem Außenraum. Die sichtbare 72dp-Zone liegt im mittleren 288px-Bereich; der Drache passt auch in runde Masken.
- `android-background.png`: dunkle 432px-Unterlage.
- `android-monochrome.png`: direkt aus dem **Original-SVG** gerasterte weiße OS-Themenmaske, zentriert mit 178×210px-Motiv und transparentem Sicherheitsrand. Dies ist eine technische Launcher-Maske, keine neue einfache Vektor-Spielgrafik.

Erstellung: Bildwerkzeug anhand des tatsächlich betrachteten Nutzer-SVG; weißer, nach links blickender Drache mit S-Kurve, spitzer Mähne, offenem Maul und eingerolltem Schwanz. HQ-Pixeltextur mit perlmutt-/silberfarbenen Schuppen, Cyan-/Magenta-Kanten und kleinem roten Augenlicht. Mechanische Format-/Größenableitungen mit Godot/ImageMagick, keine nachträgliche Bemalung oder erfundene Symbolgeschichte.

[Original-SVG, unveränderte generierte Quelle und Fingerabdrücke](../../../docs/branding/game-icon-v0692/sources.json). [Bisheriges Icon als bytegleiche Sicherung](../../../docs/archiv/assets/game-icon-bis-v0691.png). [Sichtprüfung und Plattformnachweise](../../../docs/game-icon-v0692.md).
