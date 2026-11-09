# Unveränderte Helden-Backups · v0.45.0 · CodexAI

`raven.png` und `shadepi.png` sind bytegleiche Sicherungen der bis v0.44.1 verwendeten Originale (1024×5120, 8 Richtungen, 8 Bilder je Animationsreihe). Auch die bisherigen Dateien eine Ebene darüber bleiben unverändert erhalten; `SpriteAssets.resolve()` wählt standardmäßig die neuen Gameplayquellen.

Zum bewussten Rückfall können diese PNGs in den vorhandenen Ordner `assets/custom/` unter den Namen `raven.png` beziehungsweise `shadepi.png` kopiert werden. Eigene Dateien haben weiter Vorrang. Bestehende eigene Figuren zuerst sichern. Zum erneuten Verwenden der neuen Standards die betreffenden eigenen Ersatzdateien wieder entfernen. Spielstände sind davon unabhängig.

Der Regressionstest vergleicht Original und Backup per SHA-256; das Exportpaket wird zusätzlich auf identische decodierte Bilddaten geprüft. [Neue Quelle und Metadaten](../gameplay/README.md).
