# Eigene Charaktergrafiken

Seit **v0.13.2** werden Spielgrafiken unmittelbar aus `assets/sprites/heroes/` und `assets/sprites/npcs/` geladen.

Kopiere die gewünschte Figur mit **unverändertem Dateinamen** nach `assets/custom/` und bearbeite die Kopie. Unterstützte Namen: `shadepi.png`, `raven.png`, `jackal.png`, `kenzo.png`, `punk-1.png` bis `punk-4.png`, `shooter-visor.png`, `shooter-violet.png`. Ohne eigene Datei bleibt die jeweilige HQ-Originalgrafik aktiv.

Unterstützte Atlasgrößen:

- **1024 × 5120 Pixel:** illustrierte HQ-Figuren, 128 × 160 Pixel pro Feld, acht Blickrichtungen.
- **384 × 2048 Pixel:** selbst erstellte ältere Pixel-Sprites mit acht Blickrichtungen.
- **384 × 1024 Pixel:** selbst erstellte ältere Pixel-Sprites mit vier Blickrichtungen.

Das Spiel erkennt gültige eigene Figuren beim Import und richtet Animation, Schatten und Fußpunkt am Raster aus. Ein ungültiges Raster wird unter Ausgabe einer Warnung ignoriert.

`npm run assets` erzeugt ausschließlich Licht und Basissounds; es überschreibt keine Charaktergrafiken.

[Figuren bearbeiten](../../docs/figuren-bearbeiten.md) · [HQ-Helden](../../docs/helden-sprites.md) · [NPCs](../../docs/npc-sprites.md)
