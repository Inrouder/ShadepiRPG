# Mobiles Touch-HUD · v0.63.0 · CodexAI

Generierte transparente Pixel-PNGs für Kreisstick und Aktionstasten. Silber-/Stahlflächen mit dezenten Cyanpixeln folgen der Raven-UI-Familie. Herkunft und tatsächliche Zuschnitte: [Quelle und Registrierung](../../../tools/mobile-ui-v063/regions.json), [unveränderte Generatorausgabe](../../../tools/mobile-ui-v063/source.png), [Packer](../../../tools/mobile-ui-v063/pack.py). Kein Gameplay-Sprite wird ersetzt.

Die neun PNGs sind 384×384 mit transparentem Rand und zentrierter sichtbarer Silhouette. Der Runtime-Code verwendet Nearest. Transparenz und gedrückter Zustand entstehen in [MobileControls](../../../scripts/mobile_controls.gd), nicht durch undurchsichtige Rechtecke. Kreis-Hitflächen sind von der sichtbaren Alphaform getrennt; der Stick liefert analoge Achsen und setzt seinen Knopf beim Loslassen zurück. Mehrere Finger halten unabhängige Tasten; Hintergrund, Menü und Hackfenster lösen sie sicher.

[Anleitung und Aufnahmen](../../../docs/touch-hud-v063.md).
