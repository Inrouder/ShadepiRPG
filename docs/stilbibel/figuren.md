# Figurenkatalog · v0.32.2 · CodexAI

**Aktueller Stand v0.46.1 · CodexAI:** Originalhelden wieder aktiv; beide Karten und die vollständige Übersicht zeigen wieder diese Quellen. [Spielansicht und Rückkehr](../original-helden.md). Der folgende v0.45.0-Eintrag dokumentiert die inzwischen verworfene Zwischenfassung.

**Aktualisierung v0.45.0 · CodexAI:** Heldenkarten und vollständige 23-Figuren-Übersicht aus den aktiven Gameplay-Quellen erneuert. [Neue Quellen und Anker](../../assets/sprites/heroes/gameplay/README.md), [Originale als Backup](../../assets/sprites/heroes/backup-v0441/README.md), [Spielvergleich](../fehlerbericht-v045.md).

**Aktualisierung v0.39.0 · CodexAI:** [Plattformfahrt und Hangarentdeckung](../hangar-entdeckung.md), vier eigene Shadepi-Schalterposen, sechs Entriegelungsbilder und texturierter Schacht. Fahrt mit den tatsächlichen Figuren; danach identischer Aerodyne in normaler Erkundung und Film. [Aktive Quellen und Kontaktanker](../../assets/story/hangar-discovery/README.md).

**Aktualisierung v0.38.0 · CodexAI:** [Eisbad und Kryospray-Rettung](../eisbad.md) mit acht eigenen HQ-Kontaktposen für Raven/Shadepi. Reale Weltgröße, unterschiedliche Zuschnitte der Paarposen und volle Kopf-/Haar-/Hutsilhouette beachten; normale Figurensätze bleiben gültig.

**Handkorrektur v0.36.1 · CodexAI:** Im [See-Finale](../see-finale.md) hebt Raven die Maske mit ihrer **rechten** Hand; ihre **linke** berührt und verdeckt Shadepis Gesicht. Diese Zuordnung gilt für Maskenabnahme und Kuss, jeweils aus Ravens eigener Sicht.

[Stilbibel](README.md) · [Art Direction](artdirection.md) · [Welt und Kulissen](welten.md)

**23 aktive Figuren beziehungsweise visuell eigenständige Typen.** Jede Karte zeigt vorhandene Quellpixel, keine neu generierten Ansichten. Körper-/Masken-/Kleidungsmerkmale erhalten; Stil und Darstellungsmaßstab zusätzlich nach der [Art Direction](artdirection.md) abgleichen. Storyangaben dienen Mitwirkenden als Kontinuitätsreferenz.

![Gesamte Figurenübersicht](bilder/figuren-uebersicht.png)

Die Übersicht passt die Vergrößerung zur Erkennbarkeit an. Auf jeder Einzelkarte stehen der Ansichtsmaßstab und rechts dieselbe Figur im **Weltmaßstab ×1** ohne Kamera-Zoom. Bei normalen Figuren: Vorder-/Seiten-/Rückansicht und Aktions- oder Gehpose. Der Meister besitzt keine separaten vollständigen Drehansichten; seine Karte zeigt nur die tatsächlich vorhandenen Szenenposen. Bei digitalen Gegnern ist nur eine schwebende Form vorhanden.

## Schnellzugriff

- [Shadepi](#shadepi)
- [Raven Black](#raven)
- [Chrome Jackal](#jackal)
- [Kenzō Moriyama](#kenzo)
- [Straßenkämpfer · roter Typ](#punk-1)
- [Straßenkämpfer · grüner Typ](#punk-2)
- [Straßenkämpfer · violetter Typ](#punk-3)
- [Straßenkämpfer · ockerfarbener Typ](#punk-4)
- [Schütze · Cyanvisier](#shooter-visor)
- [Schütze · Violettvisier](#shooter-violet)
- [Oni-Krieger](#oni)
- [Roboterkopf-Krieger](#robot)
- [Ly · weißer Ordenskrieger](#ly)
- [Schwerer MG-Krieger](#heavy)
- [Älterer Klosterbewohner](#elder)
- [Mönch](#monk)
- [Klosterbewohner](#resident)
- [Betreuungsperson](#caretaker)
- [Meister · Träger des Heiligtums](#master)
- [Angreifender Kampfbot](#bot)
- [Minotaurus · Mech-Hybrid](#minotaur)
- [Datenvirus](#dive-virus)
- [ICE-Wächter](#ice-guardian)

<a id="shadepi"></a>
## Shadepi

**Familie:** Helden · **technische ID:** `shadepi`

![Shadepi · vorhandene Ansichten und Weltgröße](bilder/figur-shadepi.png)

- Schwarzer Kasa, geschlossene segmentierte Maske, rote Linsen.
- Schal, taktische Weste und dunkle ausgefranste Stoffbahnen; rotes Laser-Katana.
- Keine bestätigte Zentimetergröße ergänzen. Körperbau anhand des normalen Sprites erhalten.

**Aktive Quellen und Darstellung:** [shadepi.png](../../assets/sprites/heroes/shadepi.png) · [pixel_actor.gd](../../scripts/pixel_actor.gd) · [sprite_assets.gd](../../scripts/sprite_assets.gd).

<a id="raven"></a>
## Raven Black

**Familie:** Helden · **technische ID:** `raven`

![Raven Black · vorhandene Ansichten und Weltgröße](bilder/figur-raven.png)

- Verbindlich 160 cm; schwarze Haare mit blauen Spitzen, rote Augen und goldenes Septum.
- Schwarzer Anzug mit schmalen Cyan-Linien, Cyan-Kragenmodule, rote Raben-Schulterzeichen.
- Pistole und Holster in der physischen Welt; offene Hand für Blitze im Deep Dive.

**Aktive Quellen und Darstellung:** [raven.png](../../assets/sprites/heroes/raven.png) · [pixel_actor.gd](../../scripts/pixel_actor.gd) · [sprite_assets.gd](../../scripts/sprite_assets.gd).

<a id="jackal"></a>
## Chrome Jackal

**Familie:** Gegner der Gegenwart · **technische ID:** `jackal`

![Chrome Jackal · vorhandene Ansichten und Weltgröße](bilder/figur-jackal.png)

- Breiter cybernetischer Nahkämpfer, kurze braune Haare, massive gepanzerte Unterarme.
- Schieferfarbene Rüstung und magentafarbene Cyberoptik; keine Kasa-/Rabenmerkmale übernehmen.

**Aktive Quellen und Darstellung:** [jackal.png](../../assets/sprites/npcs/jackal.png) · [pixel_actor.gd](../../scripts/pixel_actor.gd) · [sprite_assets.gd](../../scripts/sprite_assets.gd) · [contact-poses.json](../../assets/sprites/npcs/contact-poses.json) · [contact-poses.png](../../assets/sprites/npcs/contact-poses.png).

<a id="kenzo"></a>
## Kenzō Moriyama

**Familie:** Gegner der Gegenwart · **technische ID:** `kenzo`

![Kenzō Moriyama · vorhandene Ansichten und Weltgröße](bilder/figur-kenzo.png)

- Schwarze Haare, dunkle ärmellose Gewandung, sichtbare cybernetische Arme und Schultermechanik.
- Boss der Tower-Konfrontation; Aussehen und Körperbau nicht mit Jackal vertauschen.

**Aktive Quellen und Darstellung:** [kenzo.png](../../assets/sprites/npcs/kenzo.png) · [pixel_actor.gd](../../scripts/pixel_actor.gd) · [sprite_assets.gd](../../scripts/sprite_assets.gd) · [contact-poses.json](../../assets/sprites/npcs/contact-poses.json) · [contact-poses.png](../../assets/sprites/npcs/contact-poses.png).

<a id="punk-1"></a>
## Straßenkämpfer · roter Typ

**Familie:** Gegner der Gegenwart · **technische ID:** `punk-1`

![Straßenkämpfer · roter Typ · vorhandene Ansichten und Weltgröße](bilder/figur-punk-1.png)

- Orangefarbener Irokesenschnitt, roter Mantel, dunkle Rüstung und Schlagwaffe.
- Farbkennung und Haarform bleiben über Geh- und Kontaktposen erhalten.

**Aktive Quellen und Darstellung:** [punk-1.png](../../assets/sprites/npcs/punk-1.png) · [pixel_actor.gd](../../scripts/pixel_actor.gd) · [sprite_assets.gd](../../scripts/sprite_assets.gd) · [contact-poses.json](../../assets/sprites/npcs/contact-poses.json) · [contact-poses.png](../../assets/sprites/npcs/contact-poses.png).

<a id="punk-2"></a>
## Straßenkämpfer · grüner Typ

**Familie:** Gegner der Gegenwart · **technische ID:** `punk-2`

![Straßenkämpfer · grüner Typ · vorhandene Ansichten und Weltgröße](bilder/figur-punk-2.png)

- Mintfarbene seitlich gelegte Haare, grüner taktischer Mantel, dunkle Panzerung.
- Aktuelle Gegnerrolle und Bewaffnung aus dem aktiven NPC-Code übernehmen; alte Generierungsprompts sind kein Gameplay-Vertrag.

**Aktive Quellen und Darstellung:** [punk-2.png](../../assets/sprites/npcs/punk-2.png) · [pixel_actor.gd](../../scripts/pixel_actor.gd) · [sprite_assets.gd](../../scripts/sprite_assets.gd) · [contact-poses.json](../../assets/sprites/npcs/contact-poses.json) · [contact-poses.png](../../assets/sprites/npcs/contact-poses.png).

<a id="punk-3"></a>
## Straßenkämpfer · violetter Typ

**Familie:** Gegner der Gegenwart · **technische ID:** `punk-3`

![Straßenkämpfer · violetter Typ · vorhandene Ansichten und Weltgröße](bilder/figur-punk-3.png)

- Violette stachelige Haare, violette Panzerkleidung, markanter Unterarmschutz.
- Eigenständige Silhouette gegenüber den anderen Punktypen bewahren.

**Aktive Quellen und Darstellung:** [punk-3.png](../../assets/sprites/npcs/punk-3.png) · [pixel_actor.gd](../../scripts/pixel_actor.gd) · [sprite_assets.gd](../../scripts/sprite_assets.gd) · [contact-poses.json](../../assets/sprites/npcs/contact-poses.json) · [contact-poses.png](../../assets/sprites/npcs/contact-poses.png).

<a id="punk-4"></a>
## Straßenkämpfer · ockerfarbener Typ

**Familie:** Gegner der Gegenwart · **technische ID:** `punk-4`

![Straßenkämpfer · ockerfarbener Typ · vorhandene Ansichten und Weltgröße](bilder/figur-punk-4.png)

- Blonder seitlicher Undercut, ockerbrauner Mantel, dunkle Rüstung und Schlagwaffe.
- Keine weiße Hintergrundmatte aus älteren Quellstufen übernehmen.

**Aktive Quellen und Darstellung:** [punk-4.png](../../assets/sprites/npcs/punk-4.png) · [pixel_actor.gd](../../scripts/pixel_actor.gd) · [sprite_assets.gd](../../scripts/sprite_assets.gd) · [contact-poses.json](../../assets/sprites/npcs/contact-poses.json) · [contact-poses.png](../../assets/sprites/npcs/contact-poses.png).

<a id="shooter-visor"></a>
## Schütze · Cyanvisier

**Familie:** Gegner der Gegenwart · **technische ID:** `shooter-visor`

![Schütze · Cyanvisier · vorhandene Ansichten und Weltgröße](bilder/figur-shooter-visor.png)

- Geschlossener schwarzer Taktikhelm mit Cyanvisier; segmentierte schwarze Rüstung.
- Kompakte Schusswaffe, erkennbare Mündung und passende Schuss-/Erholungsphase.

**Aktive Quellen und Darstellung:** [shooter-visor.png](../../assets/sprites/npcs/shooter-visor.png) · [pixel_actor.gd](../../scripts/pixel_actor.gd) · [sprite_assets.gd](../../scripts/sprite_assets.gd) · [contact-poses.json](../../assets/sprites/npcs/contact-poses.json) · [contact-poses.png](../../assets/sprites/npcs/contact-poses.png).

<a id="shooter-violet"></a>
## Schütze · Violettvisier

**Familie:** Gegner der Gegenwart · **technische ID:** `shooter-violet`

![Schütze · Violettvisier · vorhandene Ansichten und Weltgröße](bilder/figur-shooter-violet.png)

- Graphitfarbener geschlossener Helm mit violettem Visier und Akzenten.
- Vom Cyan-Schützen über Farbkennung unterscheiden; gleiche plausible Waffenhaltung.

**Aktive Quellen und Darstellung:** [shooter-violet.png](../../assets/sprites/npcs/shooter-violet.png) · [pixel_actor.gd](../../scripts/pixel_actor.gd) · [sprite_assets.gd](../../scripts/sprite_assets.gd) · [contact-poses.json](../../assets/sprites/npcs/contact-poses.json) · [contact-poses.png](../../assets/sprites/npcs/contact-poses.png).

<a id="oni"></a>
## Oni-Krieger

**Familie:** Orden · **technische ID:** `oni`

![Oni-Krieger · vorhandene Ansichten und Weltgröße](bilder/figur-oni.png)

- Oni-Maske und Katana, dunkle Ordensausrüstung.
- Fällt in Erinnerung I, um Shadepi zu schützen. Kein bestätigter Eigenname.

**Aktive Quellen und Darstellung:** [warriors-ready.png](../../assets/memories/attack/warriors-ready.png) · [actors.json](../../assets/memories/attack/actors.json) · [combat.png](../../assets/memories/attack/combat.png) · [memory_actor.gd](../../scripts/memories/memory_actor.gd).

<a id="robot"></a>
## Roboterkopf-Krieger

**Familie:** Orden · **technische ID:** `robot`

![Roboterkopf-Krieger · vorhandene Ansichten und Weltgröße](bilder/figur-robot.png)

- Roboterkopf mit Dreadlocks aus Kabeln; Stab als bestätigte Bewaffnung.
- Überlebt Erinnerung I. Sein späteres Schicksal ist nicht festgelegt.

**Aktive Quellen und Darstellung:** [warriors-ready.png](../../assets/memories/attack/warriors-ready.png) · [actors.json](../../assets/memories/attack/actors.json) · [combat.png](../../assets/memories/attack/combat.png) · [memory_actor.gd](../../scripts/memories/memory_actor.gd).

<a id="ly"></a>
## Ly · weißer Ordenskrieger

**Familie:** Orden · **technische ID:** `ly`

![Ly · weißer Ordenskrieger · vorhandene Ansichten und Weltgröße](bilder/figur-ly.png)

- Shadepi-ähnliche geschlossene Maske, weiße Gewandung und Klinge.
- Überlebt Erinnerung I und opfert sich in Erinnerung II. Nicht als weiß eingefärbter Shadepi ohne eigenes Kostüm behandeln.

**Aktive Quellen und Darstellung:** [warriors-ready.png](../../assets/memories/attack/warriors-ready.png) · [actors.json](../../assets/memories/attack/actors.json) · [combat.png](../../assets/memories/attack/combat.png) · [memory_actor.gd](../../scripts/memories/memory_actor.gd).

<a id="heavy"></a>
## Schwerer MG-Krieger

**Familie:** Orden · **technische ID:** `heavy`

![Schwerer MG-Krieger · vorhandene Ansichten und Weltgröße](bilder/figur-heavy.png)

- Samurai-Maske, vollständige schwere Panzerung und großes MG.
- Fällt mit Oni in Erinnerung I zum Schutz Shadepis; Gewicht und Waffengröße sichtbar erhalten.

**Sichtbarer Altbestand:** Kleine abgetrennte Nachbarfragmente an den Bereitschaftszellen sind Atlasartefakte, keine zusätzlichen Waffen- oder Kostümteile. Neue Quellen sollen saubere Zellränder haben; die Bildkarte dokumentiert die unveränderte aktive Quelle.

**Aktive Quellen und Darstellung:** [warriors-ready.png](../../assets/memories/attack/warriors-ready.png) · [actors.json](../../assets/memories/attack/actors.json) · [combat.png](../../assets/memories/attack/combat.png) · [memory_actor.gd](../../scripts/memories/memory_actor.gd).

<a id="elder"></a>
## Älterer Klosterbewohner

**Familie:** Zivilfiguren · **technische ID:** `elder`

![Älterer Klosterbewohner · vorhandene Ansichten und Weltgröße](bilder/figur-elder.png)

- Älterer unbewaffneter Bewohner in traditioneller Kleidung.
- Eigenständige Zivilfigur, nicht mit dem Träger des Heiligtums gleichsetzen.

**Aktive Quellen und Darstellung:** [residents.png](../../assets/memories/attack/residents.png) · [actors.json](../../assets/memories/attack/actors.json) · [residents-walk.png](../../assets/memories/attack/residents-walk.png) · [memory_actor.gd](../../scripts/memories/memory_actor.gd).

<a id="monk"></a>
## Mönch

**Familie:** Zivilfiguren · **technische ID:** `monk`

![Mönch · vorhandene Ansichten und Weltgröße](bilder/figur-monk.png)

- Traditionelle Mönchskleidung, unbewaffnete zivile Silhouette.
- Flucht mit vier Gehbildern je Richtung; keine Kampfpose oder moderne Heldenrüstung hinzufügen.

**Aktive Quellen und Darstellung:** [residents.png](../../assets/memories/attack/residents.png) · [actors.json](../../assets/memories/attack/actors.json) · [residents-walk.png](../../assets/memories/attack/residents-walk.png) · [memory_actor.gd](../../scripts/memories/memory_actor.gd).

<a id="resident"></a>
## Klosterbewohner

**Familie:** Zivilfiguren · **technische ID:** `resident`

![Klosterbewohner · vorhandene Ansichten und Weltgröße](bilder/figur-resident.png)

- Unbewaffnete Alltagskleidung des Klosters; Haar- und Kleidungsfarben aus dem aktiven Blatt übernehmen.
- Die Karte zeigt den vorhandenen Typ, keinen neu benannten Storycharakter.

**Aktive Quellen und Darstellung:** [residents.png](../../assets/memories/attack/residents.png) · [actors.json](../../assets/memories/attack/actors.json) · [residents-walk.png](../../assets/memories/attack/residents-walk.png) · [memory_actor.gd](../../scripts/memories/memory_actor.gd).

<a id="caretaker"></a>
## Betreuungsperson

**Familie:** Zivilfiguren · **technische ID:** `caretaker`

![Betreuungsperson · vorhandene Ansichten und Weltgröße](bilder/figur-caretaker.png)

- Unbewaffnete zivile Klosterkleidung; eigene Kleidungs- und Haarsilhouette.
- Bezeichnung folgt der technischen ID caretaker; persönliche Biografie ist nicht bestätigt.

**Aktive Quellen und Darstellung:** [residents.png](../../assets/memories/attack/residents.png) · [actors.json](../../assets/memories/attack/actors.json) · [residents-walk.png](../../assets/memories/attack/residents-walk.png) · [memory_actor.gd](../../scripts/memories/memory_actor.gd).

<a id="master"></a>
## Meister · Träger des Heiligtums

**Familie:** Orden · **technische ID:** `master`

![Meister · Träger des Heiligtums · vorhandene Ansichten und Weltgröße](bilder/figur-master.png)

- Älterer Mann mit weißem Bart, gebundenem Haar und traditioneller bronze-/brauner Kampfausrüstung.
- Kein bestätigter Eigenname. Tod nach der Übertragung ist verbindlich; keine entspannte lebendige Nachherpose.
- Für fehlende Seiten-/Rückansichten keine erfundenen Ansichten als Original ausgeben. Die Tafel zeigt vorhandene Szenenposen.

**Aktive Quellen und Darstellung:** [characters.png](../../assets/memories/legacy/characters.png) · [master-death.png](../../assets/memories/legacy/master-death.png) · [actors.json](../../assets/memories/legacy/actors.json) · [legacy_figure.gd](../../scripts/memories/legacy_figure.gd).

<a id="bot"></a>
## Angreifender Kampfbot

**Familie:** Roboter und digitale Gegner · **technische ID:** `bot`

![Angreifender Kampfbot · vorhandene Ansichten und Weltgröße](bilder/figur-bot.png)

- Bewaffneter mechanischer Angreifer des Klosters mit klarer nichtmenschlicher Rüstung.
- Eigene Bereitschafts-, Geh-, Feuer-, Treffer- und Wrackzustände aus dem Bot-Atlas.

**Aktive Quellen und Darstellung:** [bots.png](../../assets/memories/attack/bots.png) · [actors.json](../../assets/memories/attack/actors.json) · [combat.png](../../assets/memories/attack/combat.png) · [memory_actor.gd](../../scripts/memories/memory_actor.gd).

<a id="minotaur"></a>
## Minotaurus · Mech-Hybrid

**Familie:** Roboter und digitale Gegner · **technische ID:** `minotaur`

![Minotaurus · Mech-Hybrid · vorhandene Ansichten und Weltgröße](bilder/figur-minotaur.png)

- Großer gepanzerter zweibeiniger Cyborg-/Mech-Hybrid mit Servomechanik und schwerer Bewaffnung.
- Beine und Lys konkrete Sprengtechnik sind dokumentierte Umsetzungsentscheidungen; kein neu bestätigtes Nutzerzitat.
- Ein Exemplar in Erinnerung II, zwei unabhängig besiegbare Exemplare in Erinnerung III. Gleicher Typ und gleiche Materialfamilie.

**Aktive Quellen und Darstellung:** [minotaur.png](../../assets/memories/sacrifice/minotaur.png) · [actors.json](../../assets/memories/sacrifice/actors.json) · [minotaur.gd](../../scripts/memories/minotaur.gd).

<a id="dive-virus"></a>
## Datenvirus

**Familie:** Roboter und digitale Gegner · **technische ID:** `dive-virus`

![Datenvirus · vorhandene Ansichten und Weltgröße](bilder/figur-dive-virus.png)

- Schwebende violette kristalline Digitalkugel mit Tentakeln und Cyan-Schaltlinien.
- Eigene virtuelle Form; nicht als physischer Kampfbot oder menschliche Figur darstellen.

**Aktive Quellen und Darstellung:** [dive-virus.png](../../assets/sprites/npcs/dive-virus.png) · [dive_threat.gd](../../scripts/dive_threat.gd).

<a id="ice-guardian"></a>
## ICE-Wächter

**Familie:** Roboter und digitale Gegner · **technische ID:** `ice-guardian`

![ICE-Wächter · vorhandene Ansichten und Weltgröße](bilder/figur-ice-guardian.png)

- Größere schwere digitale Wächterkugel mit dunklen gepanzerten Segmenten, violettem Kern und Cyan-Schaltlinien.
- Klar vom kleineren Virus unterscheiden; im Renderer größer, mit eigenem Strahl-/Verwundbarkeitsfenster.

**Aktive Quellen und Darstellung:** [ice-guardian.png](../../assets/sprites/npcs/ice-guardian.png) · [dive_threat.gd](../../scripts/dive_threat.gd).

## Zusätzliche Darstellungszustände der Hauptfiguren

**Nachtrag v0.33.0 · CodexAI:** [Neue Tower-Szenenposen](../../assets/story/tower/README.md) zeigen Kenzōs Griff nach Raven, den stark verletzten knienden Gefangenen, Raven am Extraktionsdeck und Kenzōs endgültigen Zusammenbruch. [Tatsächliche Spielansichten und Ablauf](../tower-extraktion.md). Dies sind Zustände der vorhandenen Figuren, keine neuen Identitäten; Kenzō lebt bis zur gesicherten Datenextraktion.

Die Identität bleibt bei Menü, normalem Spiel, Spezialangriffen und Szenenposen dieselbe. Die Formate und Abtastungen unterscheiden sich je Einsatz; nicht ungeprüft austauschen.

| Zustand | Sichtbarer Vergleich | Quellen und Vertrag |
| --- | --- | --- |
| Menü und ruhiger Wind | ![Menüfiguren auf der Plattform](../startmenue.png) | [Figuren-PNG](../../assets/menu/start-heroes-hq.png), [Menübeschreibung](../live-startmenue.md). Größere Menüansicht mit festen Füßen; keine Mausverschiebung. |
| Raven: virtuelle Blitze / physische Pistole | ![Blitz aus der Hand](../kampf-lightning.png) ![Pistole und Mündungsfeuer](../kampf-pistol.png) | [Handanker](../../assets/sprites/heroes/raven-hand-cast.json), [Kampfdetails](../raven-gegner-kampf.md). Keine Vertauschung von Hand und Mündung. |
| Aufgeladener Angriff und Kick | [Animierte Kampfbewegungen](../kampfbewegungen.md) | [Spezialposen](../../assets/sprites/heroes/combat-poses.png), [Player](../../scripts/player.gd). Zeilen: Shadepi laden, Knie anheben, Kick ausstrecken, Raven laden; Richtungen und Fußbasis erhalten. |
| Sitzen und Handkontakt | ![Heiligtum-Kontakt](../previews/heiligtum-v032-hand.png) | [Aktuelles Posenblatt](../../assets/story/sanctuary/poses-game.png); eigenständige Szenenpose, keine neue Figur. |
| Raven schläft | ![Seitliche Schlafpose](../previews/heiligtum-v032-schlaf.png) | Gleiches Blatt; Körperlänge gegen den normalen Sprite prüfen. |
| Heiligtumsübertragung und Aura | ![Shadepis Aura im Tempel](../vermaechtnis-aura.png) | [Aura-Atlas](../../assets/memories/legacy/shadepi-aura.png), [Auralaufzeit](../../scripts/memories/legacy_aura.gd). Goldweiß/Cyan, Körper und Maske nicht verformen. |

## Weitere Identitäten und Grenzen

- **ARToS-7** ist als Bord-KI, Stimme, Cockpit-/Terminaloberfläche dargestellt. Es liegt kein eigener menschlicher ARToS-Charaktersprite vor. Dafür keinen erfundenen Körper als bestehende Referenz hinzufügen.
- Der **weiße Drache** erscheint als mystisches Motiv der Stadt-/Menükulisse und in Ordenszeichen. Die vorhandenen Motive nicht mit einem bereits vorhandenen frei spielbaren Drachen-Sprite verwechseln.
- Hintergründe enthalten weitere gemalte Menschen-/Silhouettenmotive. Diese sind keine zusätzlichen einzeln animierbaren Charaktere im Katalog.
- Die zwölf ursprünglichen Chat-Figurenblätter bleiben im [Universumsarchiv](../universum/README.md) beschrieben; lokale Originalbilder fehlen. Diese Referenzkarten sichern den tatsächlich vorhandenen Spielbestand und ersetzen die Originaldossiers nicht.


**Kontaktposen v0.36.0 · CodexAI:** [Raven und Shadepi am See](../see-finale.md), [aktive Quelle](../../assets/story/lake/README.md). Händehalten, Maskenabnahme mit verdeckender Hand, privater Kuss und maskierte Umarmung sind Zustände der vorhandenen erwachsenen Figuren, keine neuen Identitäten. Normalen Weltmaßstab und Kontaktanker aus `lake_tableau.gd` beachten. In beiden maskenlosen Zellen bleibt Shadepis Gesicht verdeckt.
