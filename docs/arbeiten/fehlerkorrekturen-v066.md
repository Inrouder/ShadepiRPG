# Konsistenzauftrag / Arbeitsnachweis · v0.66.0 · CodexAI

**Auftrag:** Sieben gemeldete Fehler: Jackals Nähe/Blickrichtung vor Shadepis Kampf, plausibler Shadepi-Abgang, festhängender Gegner und wirkungslose P2-Angriffe in der roten Netz-Ebene, beweglicher/aggressiverer Wächter, kontinuierlicher Wechsel Kapitel 2→3, Motorrad-Einfahrt ohne Erscheinen aus dem Nichts, richtige P2-Rolle im Tower.

**Basis:** `353936e` / v0.65.1, Arbeitskopie sauber. Alle Remote-Branches abgerufen und Versionen/Inhalte verglichen; main aktuell, ältere ClaudeHelper-Arbeit erhalten. Neue Version 0.66.0 · CodexAI, Windows 0.66.0.0, Android 6600. Kein neuer Kapitel-Enum und kein neues persistentes Spielstandfeld.

**Tatsächlich gesichtete Referenzen:** KONSISTENZ, AGENTS, Art Direction und Welt-/Fahrzeugregeln; aktive `alley.png`, `hideout.png`, `dive-core.webp`; echte Spielansichten mit Jackal/Raven/Shadepi, bestehendem Motorrad und ICE-Boss. Die Figurenkarten und originalen Heldensprites aus der bestehenden Zusammenarbeit bleiben die Identitätsreferenz. Vorhandene Reaktionen und acht Wächter-Grafikphasen wiederverwendet. Keine Grafikgenerierung, Umfärbung oder Vektorersatzgrafik. Der neue Shader beschneidet ausschließlich die vorhandene Motorrad-PNG an der Toröffnung.

**Feste Merkmale / Kontakt:** Raven 160 cm, schwarz-blaues Haar/Cyan-Ausrüstung; Shadepis geschlossene Maske, Kasa und schwarzer Stoff unverändert. Jackal behält seine Quelle und Sterbepose. Der Gassenausgang ist der sichtbare Spalt zwischen den Fassaden; kein Standpunkt auf der Wand. Motorrad an derselben Weltposition/Quelle über Außen-/Innenbereich, bestehender Parkplatz/Absteigen erhalten. Kapitelübergang endet exakt bei (437,427)/(410,441) statt dorthin zu versetzen.

**Technik / Rücksetzung:** Freie ICE-Startpunkte plus raumeigene, gepufferte AStarGrid2D-Wege; keine Änderung der Säulen-PNGs oder fremder Räume. Weltabhängige Begleitertreffer für digitale Gegner; vorhandene Schadenslogik normaler Gegner erhalten. Boss bewegt sich in echten erweiterten Arenagrenzen, nicht nur mit einem Sprite-Wackeln. Kernphase bleibt stationär und Nahkampffenster begrenzt. Pause, Abbruch, Überspringen und alte Kapitelstände werden mit den vorhandenen Generationen/Enums weiter behandelt. Neue Story-Waits prüfen ihre Generation.

**Koop:** Raven in Kenzō-Kampf und Tower-Rückweg; während Extraktion tatsächliche feste Raven-Pose und P2-Naniten. Solo kämpft Shadepi allein. Vorhandene Controller-/Touch-/Netzwerkzuordnung bleibt gemeinsam; reale Eingabeprüfungen und beide Begleiterklassen in der Regressionsfolge erhalten.

**Abnahme:** [Bildbericht mit Filmen](../fehlerkorrekturen-v066.md), [automatisierte Ergebnisse, native Pixel- und Paketnachweise](../pruefungen/v066/ergebnisse.json). Native Prüfung auf Linux/llvmpipe, 1280×720. Kein physischer Geräte-Durchlauf behauptet. Normale Helden und alte Bildquellen bytegleich. Datum 17. November 2026; CodexAI.
