# Konsistenzauftrag: Begleiter und Arcade · v0.61.0 · CodexAI

**15. November 2026.** Nutzerauftrag: aktuellen verlängerten Spielstand prüfen, Koop-Begleiter neu generieren, für alle wählbaren Arcade-Kämpfer eigene Kampfposen einbauen und einfache Vektor-Assets durch passende HQ-Pixelquellen ersetzen.

Ausgang: sauberer Stand `cdefd39`; alle GitHub-Branches abgerufen. Aktuellster gemeinsamer Stand `4f35af7`, v0.60.3, per Fast-forward übernommen; alle neuen ClaudeHelper-Branches bis v0.60.3 verglichen. Bestehende längere Etappen, Durchgangsräume und Tower-Korrekturen bleiben erhalten.

Gesichtete Quellen: AGENTS, KONSISTENZ, Art Direction, Figurenkarten aller zehn Arcade-IDs, aktive Front-/Seitenzellen, Begleiter-Spielaufnahme v0.53, Arcade-Code und Bedienung, aktuelle Fahrhindernisse. Originalhelden werden nicht ersetzt. Die verworfenen v0.45-Sprites sind keine Quelle. Keine neue Lore oder Figuren ergänzt.

Neue Quellen entstehen mit dem Bildgenerator: separate 4×4-Arcade-Posenblätter pro Figur, Drohnen-/Nanitenphasen und Requisiten/FX. Originalausgaben bleiben als Herstellungsquellen in `tools/art-v061/sources/`, außerhalb des Spieleexports. Anschließende Verarbeitung beschränkt sich auf Ausschnitte, transparente Ränder, Registrierung und Atlasbau, keine programmatisch gezeichneten Ersatzkörper.

Zu erhalten: Shadepis Kasa, geschlossene rote Linsenmaske und dunkle Taktikausrüstung; Raven mit schwarzen/blauen Haaren, Cyan-Nähten, roten Schulterzeichen und 160-cm-Identität; individuelle Haarfarben, Kostüme und Cyberglieder aller Gegner. Begleiter bleibt kompakte schwarze Cyan-Drohne beziehungsweise weißer, beim Angriff roter Nanitenschwarm. Kampagnenmaßstab, Eingaben, Solo-Passivität und Koop-Zuordnung erhalten.

Geplant: echte Block-/Sprung-/Treffer-/K.O.-Bilder; Faust-, Kick- und Spezialposen mit zeitlich passendem Kontakt; registrierte Fußbasis und gespiegelt korrekte Mündungs-/Handanker. Arcade nutzt eigene größere Darstellung. Kein Drehen eines stehenden Sprites als Niederschlag. Bei Abbruch gehen Eingabe, Begleiter und Mission unverändert zurück.

Nachweise werden nach Implementierung ergänzt: Atlasränder, native Spielszenen und Film, Controller/Tastatur, Solo/Koop, Pause/Abbruch, relevante Suiten, exportierte Ressourcen und GitHub-Sicherung. Neue Filmdateien unter 5 MB. Kein vollständiger manueller Storydurchlauf behauptet.
