# Reflexion unter den Menüfüßen · v0.44.1 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

## Auftrag, Stand und Referenzen
Nutzer beanstandet die helle Bodenlichtspur unter den Stiefeln. Ausgang `96d4c97`, v0.44.0, sauberer Arbeitsbaum; alle Branches erneut abgerufen und Versionsfelder verglichen. Main aktuell, andere Branches höchstens v0.21.3. AGENTS, Konsistenz-/UI-/FX-Vorgaben sowie vorhandene Arbeitsvorlage berücksichtigt. Tatsächlich betrachtete aktuelle Referenz: `docs/previews/menue-hauptscreen-v044.png`, aktiver Stadt-/Kontaktshader und dieselben fest verankerten Figuren. Keine Figuren-/Loreänderung; Raven 160 cm und Shadepis geschlossene Maske erhalten.

## Umfang
Die helle Spur ist Teil der vorhandenen Stadttextur und wird zusätzlich animiert. Im Stadtmaterial die örtliche Glanzenergie im Fuß-/Standbereich reduzieren, mit denselben Sohlenankern und korrekter UV→Menü-Transformation. Dunkle Bodenstruktur erhalten, vor der Dachkante begrenzen, auch im reduzierten Stil. Bestehende Kontaktschatten, Bedienung, Hintergrund-PNG und Figuren unverändert. Keine neue Bildgenerierung nötig.

## Abnahme und Nachweise

- `menu_city.gdshader`: örtliche Glanzbegrenzung aus vier Standbereichen, ursprüngliche dunkle Farben/Materialdetails bleiben erhalten. UV→Menü berücksichtigt die bestehende Stadtgröße 660×372 und den Versatz −10/−6. Begrenzung vor der Dachkante. Unabhängig von der Nässeanimations-Stärke, daher auch bei Reduziert aktiv.
- `start_menu_backdrop.gd` übermittelt denselben Ankersatz an Stadt- und Kontaktmaterial. Figurenmeshes, Mouse-/Windverhalten, Pixel-UI und Speicherfunktionen unverändert. Keine neue Grafikdatei und keine Bildgenerierung; vorhandene Hintergrund-PNG bleibt erhalten.
- Native Sichtabnahme durch CodexAI am 9. November 2026: normale und reduzierte Darstellung, eingefrorener Vorher-/Nachher-Vergleich. Die eingemalte Lichtspur ist unmittelbar unter/um die Sohlen gedämpft, Bodenkontakt bleibt lesbar. Höfe, Städte und andere Spielkulissen nicht betroffen.
- 13 bestehende Prüfungen aus `tests/menu_navigation.gd` im nativen Renderer erfolgreich, einschließlich Controller-Navigation und tatsächlichem Desktop-Exit. 73 Prüfungen aus `tests/display_settings.gd` erfolgreich. **86 / 0 Fehler**; keine zusätzliche Implementierung spiegelnde Testsuite erstellt.
- Linux-Ressourcenexport `/tmp/shadepi-v0.44.1.pck` erfolgreich. Externer nativer Prüfer `/tmp/shadepi-v0441-reflection-check.gd` aus dem leeren Verzeichnis `/tmp/shadepi-v0441-packed` lädt das gepackte Menü und die neue Shaderressource. Keine Skript-/Shader-/Exportfehler. Die finalen Vergleichsbilder stammen direkt aus diesem Paket.
- Fixierter Full-HD-Bildtakt: 18.225 veränderte Pixel in der linken Menüansicht, **0 Änderungen außerhalb des Bodenbereichs y865–980**. Die Diagnose schaltet ausschließlich die neue Reflexionskorrektur ab; Kontaktschatten bleiben in beiden Aufnahmen aktiv. Quellpixel werden nicht verformt. Aufnahmen unter `/tmp/shadepi-reflection-v0441/`, reproduzierbar mit `tools/menu_reflection_gallery.gd`; dafür nativen Renderer verwenden.
- [Aktueller Bildvergleich](../menue-kontrollpunkte.md). Direkte PNG-Vorschauen in Root-README und zentraler Doku-Galerie erneuert. Der dort verlinkte Bedienfilm bleibt als v0.44.0-Aufnahme gekennzeichnet; keine neue Bewegungsanimation erforderlich. Dummy-Audio, keine neue Tonbewertung.
- Version 0.44.1, Windows 0.44.1.0 und CodexAI-Änderungshinweise konsistent. Vor Sicherung alle Remote-Branches erneut vergleichen; GitHub main ist Sicherungsziel. Keine Cloud-Veröffentlichung oder Release-Tag.

**Ergebnis:** Lokale Bodenlichtkorrektur fertig und im tatsächlichen Export gesichtet. Keine Änderungen an den Menüfunktionen oder weiteren Storyabschnitten.
