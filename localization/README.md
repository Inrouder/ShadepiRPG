# Sprachen · v0.70.0 · CodexAI

Deutsch ist die unveränderte Quellfassung. Englisch steht im Haupt- und Pausenmenü unter **Optionen → Sprache / Language → English** zur Verfügung. Die Auswahl wird sofort angewendet und in `user://shadepi-language.cfg` gespeichert; Spielstände enthalten keine Spracheinstellung.

`game.en.po` ist der aktive UTF-8-Katalog: Storydialoge aller Kapitel und Erinnerungen, Ziele, Menüs, Start-/Gesundheitshinweise, Steuerung, Hacks samt Handbuch, Arcade, Kontrollpunktwahl, WLAN-Meldungen und Abspann. Eigennamen, Hexbytes und die sechs gleich langen Decoder-Passwörter bleiben unverändert. In bestehende Illustrationen eingebackene Logos/Beschriftungen sind Teil der Originalgrafik, keine neue Text-/Figurenvorlage.

## Bei neuen Texten

- Den deutschen Volltext als `msgid` und die englische Fassung als `msgstr` ergänzen. Zahl, Reihenfolge und Typ aller `%d`/`%s`/`%.1f`-Platzhalter sowie `%%` erhalten. Ganze Sätze übersetzen, keine Wörterbuch-Ersetzungen in Prosa.
- Godots native Labels, Buttons, Listen und Tooltips übersetzen ihre deutschen Quelltexte bei jedem Sprachwechsel. Keine Spiel-/Speicher-/Netzwerk-IDs übersetzen oder deutsche Logikvergleiche durch englische Texte ersetzen.
- `game_translation.gd` erkennt zusätzlich formatierte HUD-Vorlagen und zusammengesetzte Rand-/Menüfragmente anhand des Katalogs; aufwendige Treffer werden begrenzt zwischengespeichert. Der Adapter verändert nur die Anzeige. Unbekannte Texte bleiben lesbar in der Quellfassung.
- Bei selbst gezeichneter Schrift `GameText.t(source)` **vor** Zeichnen, Breitenmessung, Kürzen oder Glitch anwenden. Dialoge vor dem Seitenumbruch übersetzen. Der Wechsel während eines Gesprächs beginnt nur die aktuelle Sprechzeile neu; Aktionen und Cutscene-Coroutinen werden nicht wiederholt.
- Alle sichtbaren Texte im selben Katalog pflegen. Der lesende Audit meldet fehlende Prosa-/UI-Literale und veränderte Platzhalter. Neue kurze Einzelwörter und zusammengesetzte Anzeigefälle zusätzlich im Spiel prüfen.

```sh
python3 tools/localization/audit.py
godot --headless --script res://tests/localization.gd
```

[Bilder, Grenzen und Prüfnachweise](../docs/sprachen-v070.md) · [Native QA-Aufnahme](../tools/localization/README.md).
