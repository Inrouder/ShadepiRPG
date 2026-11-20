# macOS-Paketierung · v0.67.1 · CodexAI

`prepare.py <game-root> vX.Y.Z` ergänzt/erneuert nur das Mac-Preset. Tag muss zur Spielversion passen; gemeinsame Exportfilter stammen aus dem Zielspiel, Versionen werden geerbt. Universal, Ad-hoc-Signatur: Linux Built-in, Mac Apples codesign mit Identität `-`. Kein Developer-ID-Zertifikat und keine Notarisierung.

`verify.py <zip> X.Y.Z --output <json>` prüft ZIP, Bundle-ID/Version, ausführbare Datei, beide echten Mach-O-Architekturen samt Signaturkommandos, PCK und Bundle-Signatur. `test_tools.py` prüft Tag-Verwechslung, Preset-/Notiz-/Download-Erhalt und idempotente Ergänzungen.

Workflow `.github/workflows/macos.yml`: manueller Start mit vorhandenem `release_tag` oder expliziter Hilfstag **macos-v0.67.1** (bei nötigem Wiederholungsbuild optional `-r2`). Builderwerkzeuge stammen aus dem Hilfstag, **Spielcode ausschließlich aus dem unveränderten ursprünglichen Release-Tag**. Das ist kein neuer Spielversions-Tag. Native Ad-hoc-Signatur und Headless-Start auf macOS müssen vor dem Upload bestehen. `release_files.py` ergänzt bestehende Notizen per eindeutiger Markierung und erhält alle bisherigen Download-Prüfsummen. Original-Release-Tag nicht verschieben. Neue Hilfstags nur im ausdrücklich beauftragten Release-/Nachtrag-Umfang erstellen.

Zum lokalen Linux-Export mit vorhandener offizieller `macos.zip`:

```sh
python3 tools/macos/prepare.py . v0.67.1
godot --headless --export-release macOS build/macos/ShadepiRPG-macOS.zip
python3 tools/macos/verify.py build/macos/ShadepiRPG-macOS.zip 0.67.1
python3 tools/macos/test_tools.py
```

Die lokale ZIP-Datei ist ein Strukturtest; der Release-Workflow ergänzt Anleitung/Lizenzen und liefert einen eigenen Paketfingerabdruck. [Nutzeranleitung und Grenzen](../../docs/macos-v0671.md). Keine Spielgrafik-Generatoren erforderlich.
