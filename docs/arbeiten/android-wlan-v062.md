# Android und gemeinsamer WLAN-Koop · v0.62.0 · CodexAI

**15. November 2026.** Ausgang `4c10014`, sauberer v0.61.0-Stand; alle GitHub-Branches abgerufen und verglichen, keine neuere Entwicklungsarbeit. Nutzer beauftragt Android zusätzlich zu Windows/Linux und WLAN-Mehrspieler, bestätigt **gemeinsame Kamera und Partie**.

Die erste WLAN-Fassung benutzt bewusst **Remote-Koop**: ein autoritativer Host führt die vorhandene Story, der native Client empfängt JPEG-Spielbilder und PCM-Ton und liefert Spieler-2-Gamepadzustände zurück. Damit bleiben alle bestehenden Szenen und Regeln eine einzige Simulation. Es gibt keine unabhängige zweite Story-Simulation oder eigene Kamera. Diese Ausführung wurde dem Nutzer im Arbeitsverlauf ausdrücklich erklärt.

Betroffen: Android-Export, Querformat, sparsame HQ-Grenze, Multitouch-Gamepad, zentrale Gerätezuordnung, ENet-Verbindung, WLAN-Oberfläche und Lebenszyklus. Bestehende Figuren, Grafikquellen, Story, Speicherstand-Enums und Desktop-Tasten bleiben erhalten. UI nutzt vorhandene Pixelrahmen/Schriften aus `UiSkin`; keine neue Spielgrafik erforderlich. Referenzen: AGENTS, KONSISTENZ, Oberflächen-Stilbibel, bestehende Controller-/Terminal-/Koop-Verträge und Quellcode.

Neue Plattform-/Netzwerkfunktionen werden mit isolierten Spielständen geprüft: mehrere Finger, gehaltene Ladeaktionen, Hintergrund/Abbruch, zwei echte Prozesse, authentifizierter Verbindungsaufbau, Bild-/Toneingang, Rollenbindung, Szenenfolge und Freigabe bei Verbindungsverlust. APK und Windows/Linux müssen dieselbe Versionsinfo tragen. Debug-Signierschlüssel bleibt lokal außerhalb des Repositorys. Der Android-Emulator läuft ohne KVM und dient als tatsächlicher Android-Start-/Bediennachweis; physische Handy-/Routerleistung wird nicht als bereits getestet ausgegeben.

Ergebnisse und bebilderte Belege folgen nach den abschließenden Prüfungen.
