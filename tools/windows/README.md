# Windows-Release-Paket · v0.69.2 · CodexAI

Der Linux-Exporter kann bei `application/modify_resources=false` keine Explorer-Icons/PE-Versionsfelder umschreiben. `export.py` bereitet deshalb **vor** Godots Export eine Kopie des gepinnten Windows-Templates vor:

1. `prepare.py` ersetzt die sechs ICO-Bilder und Versionsressourcen mit LIEF **0.17.1**.
2. Alle ausführbaren Template-Abschnitte und der leere Godot-PCK-Abschnitt werden gegen das Original verglichen. Keine nachträgliche Manipulation eines bereits eingebetteten Spielpakets.
3. Nur während des Exports wird `custom_template/release` auf die temporäre Datei gesetzt. `export_presets.cfg` wird im `finally`-Block bytegleich zurückgesetzt, auch bei Exportfehlern.
4. Das fertige EXE wird erneut geparst: Iconbytes, Versionsdaten, PCK-Abschnitt mit gültigem Dateioffset sowie GDPC-Kopf und -Fuß. Der Bericht liegt neben dem EXE als `.verification.json`.

Kein Wine/RCEdit nötig. Es wird keine Authenticode-Signatur erzeugt; Signaturverwaltung bleibt beim Nutzer. Native Ausführung/Grafiktest unter Windows wird durch diese strukturelle Prüfung nicht behauptet. Die eigentlichen Spieltests laufen im bestehenden GitHub-Workflow.

```sh
python3 -m venv /tmp/shadepi-windows-tools
/tmp/shadepi-windows-tools/bin/pip install 'lief==0.17.1'
/tmp/shadepi-windows-tools/bin/python tools/windows/export.py \
  --template "$HOME/.local/share/godot/export_templates/4.7.2.stable/windows_release_x86_64.exe" \
  --output build/windows/Shadepi-Echos-in-Neon.exe
```
