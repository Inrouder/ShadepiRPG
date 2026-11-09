# Pixelblut · v0.46.0 · CodexAI

`atlas.png` ist die unverändert kopierte Bildwerkzeugquelle vom 9. November 2026: `/workspace/generated_images/exec-5c9452d9-ade2-410b-9230-e39c73b06bd6.png`. Tatsächlich **1774×887**, transparente PNG. Keine Skriptbemalung oder Vektor-Ersatzzeichnung.

Vier Spalten mit Quell-X 0 / 443 / 887 / 1330 und Breiten 443 / 444 / 443 / 444. Obere Reihe Y 0…442: vier nach rechts gerichtete Spritzphasen; Ursprünge innerhalb der Region `(54,270)`, `(50,270)`, `(52,270)`, `(61,270)`. Untere Reihe Y 443…886: kleine Tropfenansammlung, mittlere frische, große frische und dunkle gesetzte Lache; Bodenmitte jeweils lokal `(222,249)`. Eigene registrierte Tropfenregion `(115,645,100,96)`.

`scripts/blood_fx.gd` zeichnet mit Nearest und getrennten Boden-/Luftlagen. Bildgrößen nach tatsächlicher Weltkamera, keine universelle Sprite-Skalierung. Physische `Enemy`-Figuren einschließlich Cyberware-Träger bluten nur bei positivem ungeschütztem Schaden. Nicht auf digitale Gegner, Roboter, Kulissen oder Helden anwenden. Große Lache folgt 0,4 Sekunden dem tatsächlichen Leichenrutschen, danach ist sie ortsfest. Kleine Flecken werden örtlich zusammengeführt. Alle Blutspuren sind temporär, mengenbegrenzt und werden beim Laden/Abschnittswechsel entfernt.

[Bilder und Film](../../../docs/bluteffekte.md) · [Prüf-/Arbeitsnachweis](../../../docs/arbeiten/blut-v046.md).
