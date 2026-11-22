# Journal des mises à jour — BoosteroidATV (fork personnel)

> **Mémoire technique canonique :** [docs/PROJECT_STATE.md](docs/PROJECT_STATE.md) — état courant, historique complet, décisions, tests, incidents et procédure de mise à jour. Les consignes applicables aux assistants se trouvent dans [AGENTS.md](AGENTS.md). Toujours consulter ces deux documents sur `main` avant d'agir.


**Dépôt :** [thedjazairi28/BoosteroidATV](https://github.com/thedjazairi28/BoosteroidATV)  
**Dernière mise à jour de ce journal :** 22 novembre 2026  
**Projet d'origine :** [luizhdramos/BoosteroidATV](https://github.com/luizhdramos/BoosteroidATV)  
**Statut :** fork expérimental ; les builds GitHub Actions ne constituent pas une validation fonctionnelle sur Apple TV.

> Ce document suit les modifications **propres au fork**, leurs versions, les compilations, les tests terrain et les problèmes restant à résoudre. Il ne prétend pas que chaque fonction compilée a été testée sur un appareil.

## État des versions

| Version de travail | Branche | Révision | Compilation | Essais Apple TV |
| --- | --- | --- | --- | --- |
| Base d'origine | `main` | `623c42b` | Version amont disponible | **Testée** : installation et streaming sur Apple TV |
| V1 — Catalogue unifié | `feature/unified-catalog-v1` | `a788071` | **Réussie** le 20/11/2026 | **Non confirmé** |
| V2 — Smart Experience | `feature/v2-smart-experience` | `fd60053` | **Réussie** le 20/11/2026 | **Non confirmé** |
| V2.4.8 — Mode léger des fiches Xbox (expérimental) | `feature/v2.4.8-xbox-card-safe-mode` | `ec9792a` | [Actions #45037087776](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45037087776) — en cours | **Non testé sur Apple TV** |
| V2.4.6 — Keychain fiable pour les rapports GitHub (expérimental) | `feature/v2.4.6-keychain-reliability` | `1a087da` | **Réussie** — [Actions #45035783886](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45035783886) | **Non testé sur Apple TV** |
| V2.4.5 — Traces de clic avant streaming (expérimental) | `feature/v2.4.5-prelaunch-trace` | `8220a93` | **Réussie** — [Actions #45034634363](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45034634363) | **Non testé sur Apple TV** |
| V2.4.4 — Envoi des diagnostics GitHub (expérimental) | `feature/v2.4.4-github-reports` | `4b1eec8` | **Réussie** — [Actions #45033742386](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45033742386) | **Non testé sur Apple TV** |
| V2.4.3 — Journal de lancement en direct (expérimental) | `feature/v2.4.3-live-logs` | `f0935be` | **Réussie** — [#45032820450](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45032820450) | **Non testé sur Apple TV** |
| V2.4.2 — Démarrage sécurisé (expérimental) | `feature/v2.4.2-safe-launch` | `baa8aa4` | **Réussie** — [#45032408808](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45032408808) | **Non testé sur Apple TV** |
| V2.4.1 — Stabilité du lancement (expérimental) | `feature/v2.4.1-launch-stability` | `3f16bd9` | **Réussie** — [#45030927237](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45030927237) | ❌ **KO : fermeture de l'application au lancement de tout jeu signalée** (22/11/2026) |
| V2.4 — Souris virtuelle avec manette (expérimental) | `feature/v2.4-gamepad-pointer` | `fd7d78a` | **Réussie** — [#45026265985](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45026265985) | **Non testé sur Apple TV** |
| V2.3.3 — Fiches épurées (expérimental) | `feature/v2.3.3-clean-game-cards` | `98a809c` | **En cours** — compilation GitHub Actions | **Non testé sur Apple TV** |
| V2.3.2 — Lecteur HLS Steam (expérimental) | `feature/v2.3.2-hls-trailers` | `b95d82a` | **Réussie** — [#45024722519](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45024722519) | **Non testé sur Apple TV** |
| V2.3.1 — Diagnostic des aperçus vidéo (expérimental) | `feature/v2.3.1-video-diagnostics` | `dcc7ac6` | **Réussie** le 22/11/2026 — [#45024136324](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45024136324) | **Non testé sur Apple TV** |
| V2.3 — Vidéo silencieuse automatique et résumé FR (expérimental) | `feature/v2.3-french-trailers` | `244fc60` | **Réussie** le 22/11/2026 | **Non testé sur Apple TV** |
| V2.2 — Filtres et fiches enrichies, interface FR (expérimental) | `feature/v2.2-multi-store-filters` | `e4b1ba3` | **Réussie** le 22/11/2026 | **Non testé sur Apple TV** |
| V2.1 — Stability | `feature/v2.1-stability` | `17df76b` | **Réussie** le 20/11/2026 | **3 OK, 3 KO** — 22/11/2026 (ligne rouge disparue, origine inconnue) |

**Important :** V2 inclut V1, V2.1 inclut V1 + V2, V2.2 part de V2.1 et V2.3 part de V2.2. La branche `main` conserve le code de base : **aucune des branches expérimentales n'est fusionnée dans `main`** à la date de ce journal.

## 22 novembre 2026 — V2.4.8 « Fiches Xbox mode léger » (expérimental)

**Incident vérifié :** [rapport tvOS #5](https://github.com/thedjazairi28/BoosteroidATV/issues/5), version 2026.11.22.13 sur tvOS 27.2.1 : 15:10:32Z sélection de « Call of Duty: Modern Warfare (Xbox) » dans le Catalogue ; 15:10:35Z réouverture du menu principal ; **pas de clic Jouer, pas de session Boosteroid, aucun message WebRTC**. Le rapport ne contient pas la cause du crash natif/Jetsam.

**Code :** [PR #6](https://github.com/thedjazairi28/BoosteroidATV/pull/6), branche `feature/v2.4.8-xbox-card-safe-mode` basée sur V2.4.7.  
**Compilation :** [Actions #45037087776](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45037087776).  
**État des tests :** non vérifié sur l'Apple TV.

### Contournement mesurable

- Mode léger par défaut **sur les fiches Xbox seulement** : désactive image arrière-plan plein écran, chargement facultatif de détails Boosteroid et recherches facultatives de médias Steam **pendant l'ouverture de la fiche**.
- Préserve le titre, les informations du catalogue, les commandes « Jouer » et « Favoris », et la grille des affiches du catalogue.
- Possibilité de désactiver dans Réglages → Sécurité du lancement → **Mode léger des fiches Xbox**, afin de tester séparément si nécessaire.
- Instrumentation de la fiche : sélection, `onAppear`, début/fin des tâches facultatives, `onDisappear` et checkpoint « Ouverture de fiche ».

**Interprétation :** si Call of Duty s'ouvre en mode léger, cela incrimine le chemin des données/media facultatifs ou l'image de fond, **sans identifier encore le composant exact**. Si le crash persiste, investigation du composant SwiftUI et du crash natif tvOS/Jetsam. Le moteur WebRTC et le démarrage de session ne sont pas modifiés.

## 22 novembre 2026 — V2.4.6 « Sécurisation de l'enregistrement du jeton » (expérimental)

**Branche :** [feature/v2.4.6-keychain-reliability](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.4.6-keychain-reliability) ; base V2.4.5.  
**PR de revue :** [#3](https://github.com/thedjazairi28/BoosteroidATV/pull/3).  
**Build :** [GitHub Actions #45035783886](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45035783886) — **réussie** ; artifact `BoosteroidATV-v2-4-6-keychain-reliability-unsigned`, disponible jusqu'au **29 novembre 2026**.  
**Apple TV :** non testé.

### Modifications

- Conservation du jeton GitHub **uniquement dans le Keychain de l'Apple TV**, saisi une fois par l'utilisateur via le champ `SecureField` de Réglages → Diagnostics. Aucune clé intégrée à l'IPA ou au code source.
- Mise à jour atomique via `SecItemUpdate` : ne supprime plus l'ancien jeton avant un remplacement ; éviter la perte du secret encore valide en cas d'échec de remplacement.
- Vérification de relecture Keychain après sauvegarde et bouton **« Vérifier le Keychain »** pour un contrôle post-mise-à-jour.
- Documentation de l'usage du clavier iPhone, de la suppression du jeton, de la rotation d'un jeton publié, et des conditions de conservation entre installations (`bundle ID` et identité de signature).
- **La V2.4.6 ne corrige pas le crash Call of Duty.** Elle prépare l'envoi des rapports en conservant les traces de la V2.4.5.

### Essais attendus

- [ ] Enregistrer un **nouveau** PAT fine-grained (ancien exposé dans le chat à révoquer) dans le Keychain de tvOS.
- [ ] Tester « Vérifier le Keychain », quitter/rouvrir BoosteroidATV puis revérifier.
- [ ] Envoyer un rapport d'erreur via GitHub Issues et contrôler le numéro du ticket.
- [ ] Comparer les derniers jalons Red Dead Redemption 2 et Call of Duty, puis récupérer un crash natif tvOS/Jetsam si nécessaire.

## 22 novembre 2026 — V2.4.5 « Diagnostic de transition de fiche » (expérimental)

**Symptôme observé :** Red Dead Redemption 2 (Rockstar) a atteint un flux WebRTC actif sur Apple TV : lancement 15:41:12, flux reçu à 15:41:27, connexion ICE établie 15:41:34, fermeture de l'écran de streaming enregistrée normalement à 15:41:37. Après une tentative de lancement de Call of Duty, l'utilisateur signale une fermeture brutale de l'application. Sa capture montre « Application ouverte » à 15:42:38, mais **aucun événement de clic ou de lancement Call of Duty**. La capture n'établit donc pas la cause de cette fermeture.

**Branche :** [feature/v2.4.5-prelaunch-trace](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.4.5-prelaunch-trace) (base V2.4.4).  
**Pull request :** [#2](https://github.com/thedjazairi28/BoosteroidATV/pull/2).  
**Build :** [Actions #45034634363](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45034634363) — compilation réussie ; artifact `BoosteroidATV-v2-4-5-prelaunch-trace-unsigned` disponible jusqu'au **29 novembre 2026**.  
**Test Apple TV :** non effectué.

### Correction du trou d'observabilité

La V2.4.4 appelait `LaunchTrace.record("Lancement demandé")` uniquement dans `MainTabView.launch()`, exécuté **après** la fermeture de la fiche SwiftUI `GameOverviewView`. Un crash durant l'ouverture de fiche, le clic ou la fermeture du panneau pouvait donc survenir sans aucune trace du jeu sélectionné.

- Enregistrement persistant de la sélection d'une fiche (Catalogue/Accueil).
- Enregistrement du clic « Jouer » **avant** `selectedGame = nil`.
- Checkpoint de transition avant et après fermeture de la fiche, puis lancement standard.
- Signalement d'une demande bloquée par la protection anti-double-lancement.
- Aucune modification du démarrage WebRTC, de la création de session Boosteroid, du lecteur HLS ou des jetons ; l'objectif est l'investigation, pas une correction non démontrée.

### Test prioritaire

1. Installer la V2.4.5 par-dessus l'installation existante, sans effacer les données locales.
2. Laisser le journal activé et les aperçus vidéo désactivés.
3. Depuis l'application fraîchement ouverte, sélectionner Call of Duty puis « Jouer ». Si retour au menu tvOS, rouvrir BoosteroidATV → Réglages → Diagnostics et **envoyer le rapport** ou photographier le journal.
4. Identifier la dernière étape atteinte : sélection de fiche, clic Jouer, transition de fiche, écran de streaming, authentification, session ou WebRTC.
5. Comparer au parcours Red Dead Redemption 2, puis tester le même Call of Duty avant/après fermeture normale d'un autre jeu seulement si nécessaire.

**Limite :** pas de preuve de la cause sans journal d'exécution correspondant à Call of Duty ou rapport de crash/Jetsam. Une fermeture de la vue SwiftUI n'établit pas que la session cloud distante a été terminée.

## 22 novembre 2026 — V2.4.4 « Rapports GitHub depuis l'Apple TV » (diagnostic expérimental)

**Branche :** [feature/v2.4.4-github-reports](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.4.4-github-reports) — dérivée de V2.4.3, sans reprendre la V2.4.1 KO.  
**Pull request de revue :** [#1](https://github.com/thedjazairi28/BoosteroidATV/pull/1).  
**Compilation :** [GitHub Actions #45033742386](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45033742386) — **réussie**. Artifact `BoosteroidATV-v2-4-4-github-reports-unsigned` (ZIP avec IPA), expire le **29 novembre 2026**.  
**Essai terrain :** à réaliser sur Apple TV.

### Fonctionnement

- **Réglages → Diagnostics → Envoyer un rapport d'erreur** : action manuelle qui crée une Issue GitHub dans un dépôt configurable.
- Conservation du mode V2.4.3 : journal des 80 événements persistants et checkpoint après fermeture de l'application ; l'envoi reprend ces événements pour permettre un diagnostic à distance.
- L'Apple TV conserve le jeton GitHub **fine-grained**, restreint à **Issues: Read and write**, dans son **Keychain**, jamais dans le dépôt ni dans UserDefaults.
- Le rapport contient la date, la version de l'application, tvOS, le dernier checkpoint et les événements applicatifs filtrés, avec masquage additionnel des URL et champs suspects.
- Affichage sur l'Apple TV du numéro et de l'URL de l'Issue créée, ou d'un diagnostic d'erreur HTTP (401/403/404).
- Documentation d'installation : [docs/diagnostics-github-issues.md](https://github.com/thedjazairi28/BoosteroidATV/blob/feature/v2.4.4-github-reports/docs/diagnostics-github-issues.md).

**Limites :** dépôt public = Issues publiques (préférer un dépôt privé) ; un envoi nécessite un jeton configuré et un réseau fonctionnel ; les logs d'application ne remplacent pas un rapport tvOS de crash natif ou Jetsam. **La V2.4.4 ne corrige pas encore le crash** ; elle facilite son investigation. La compilation est réussie ; **l'envoi depuis l'Apple TV reste à valider**.

## 22 novembre 2026 — V2.4.3 « Journal de lancement en direct » (diagnostic expérimental)

**Demande utilisateur :** lors d'un retour brutal au menu de l'Apple TV au lancement de n'importe quel jeu, afficher des **logs à l'écran** pour identifier le dernier jalon de démarrage atteint avant l'arrêt de l'application.

**Branche :** [feature/v2.4.3-live-logs](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.4.3-live-logs)  
**Comparaison :** [V2.4.2 → V2.4.3](https://github.com/thedjazairi28/BoosteroidATV/compare/feature/v2.4.2-safe-launch...feature/v2.4.3-live-logs)  
**Build :** [GitHub Actions #45032820450](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45032820450) — **compilation réussie** ; artifact `BoosteroidATV-v2-4-3-live-logs-unsigned` (ZIP contenant l'IPA), expiration **29 novembre 2026**.  
**Tests sur Apple TV :** non réalisés.

### Fonctionnalité

- Affichage, **activé par défaut**, d'une boîte de diagnostic transparente aux interactions, pendant le chargement, l'attente d'une machine, la connexion, le jeu et les écrans d'erreur.
- Journal horodaté à la seconde indiquant uniquement des événements **whitelistés** dans le code : lancement demandé, vérification de l'authentification, demande de session, attribution, ouverture du canal de commandes, négociation WebRTC, état ICE, démarrage des images, erreurs interceptées, fermeture normale.
- Conservation des **80 derniers événements** dans les préférences locales de l'application, pour pouvoir les retrouver après un arrêt brutal : **Réglages → Diagnostics → Journal des événements**.
- Interrupteur **« Journal de lancement à l'écran »** pour masquer/afficher l'overlay ; bouton **« Effacer »** dans la page Diagnostics.
- **Confidentialité :** le journal ne copie aucun mot de passe, courriel, cookie, jeton, URL d'API, ID de session ou réponse HTTP brute. Il n'enregistre que des libellés techniques rédigés et le titre du jeu sélectionné (tronqué).
- Le mode « Aperçus vidéo animés » reste désactivé par défaut, comme sur la V2.4.2.

### Validation et limites

- [ ] Vérifier que le journal est visible dès l'écran de démarrage d'un jeu, sans bloquer les commandes.
- [ ] En cas de fermeture brutale : **relancer l'application puis ouvrir Réglages → Diagnostics**, photographier les dernières lignes et l'étape de lancement.
- [ ] Vérifier qu'aucun secret de compte n'est présent dans les événements.
- [ ] Comparer un jeu de la Bibliothèque et un jeu « Installer et jouer » du Catalogue.
- **Ce journal applicatif ne peut pas intercepter un crash natif, un signal fatal ou un JetsamEvent** ; la dernière entrée écrite avant la disparition peut être incomplète. Un rapport de crash tvOS reste nécessaire pour prouver la cause racine.
- La compilation ne vaut pas validation fonctionnelle sur l'Apple TV.

## 22 novembre 2026 — V2.4.2 « Démarrage sécurisé » (correctif expérimental)

**Contexte :** le correctif V2.4.1 n'a pas résolu les fermetures au lancement et l'utilisateur signale que la fermeture concerne désormais **tous les jeux**. La V2.4.1 est considérée comme **KO** et n'est pas une base sûre.

**Base :** [V2.4](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.4-gamepad-pointer) — la V2.4.1 est **exclue** de cette branche.  
**Nouvelle branche :** [feature/v2.4.2-safe-launch](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.4.2-safe-launch)  
**Diff :** [V2.4 → V2.4.2](https://github.com/thedjazairi28/BoosteroidATV/compare/feature/v2.4-gamepad-pointer...feature/v2.4.2-safe-launch)  
**Compilation :** [GitHub Actions #45032408808](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45032408808) — **réussie**. Artifact : `BoosteroidATV-v2-4-2-safe-launch-unsigned` (ZIP contenant l'IPA), expiration **29 novembre 2026**.  
**Test Apple TV :** non effectué.

### Modifications ciblées

1. Désactivation **par défaut** des aperçus vidéo HLS dans les fiches des jeux et le carrousel de la Bibliothèque, afin d'éliminer leur décodeur AVPlayer du parcours de lancement WebRTC. Les images fixes, descriptions, fiches, filtres et souris à la manette restent présents.
2. Nouveau réglage **« Aperçus vidéo animés (expérimental) »** pour réactiver manuellement les bandes-annonces si l'on souhaite comparer les comportements sans changer d'IPA. Valeur initiale OFF.
3. Protection contre les demandes de lancement multiples dans `MainTabView.launch`.
4. Ajout d'un **checkpoint de lancement non sensible**, conservé localement : ouverture de la vue, authentification, attente du serveur, connexion WebRTC et flux actif. La dernière étape est affichée dans **Réglages → Diagnostics**, avec un avertissement si la tentative n'a pas enregistré de fermeture normale.
5. Les clés et données d'authentification, les mots de passe, les jetons et les identifiants de session ne sont jamais écrits dans ces checkpoints.

### Limites et test prioritaire

- **La cause réelle du retour à l'accueil tvOS n'est pas démontrée** : si le processus est tué (Jetsam ou crash Swift), la gestion des erreurs réseau Swift ne pourra pas le rattraper. Le nouveau réglage teste l'hypothèse de la concurrence AVPlayer/WebRTC sans la présenter comme certaine.
- [ ] Installer l'IPA V2.4.2, conserver les aperçus vidéo **désactivés**.
- [ ] Essayer « Jouer » sur un jeu précédemment fonctionnel, puis « Installer et jouer » sur un autre.
- [ ] Si l'app se ferme : la rouvrir, consulter **Réglages → Diagnostics**, relever la « Dernière étape de lancement ».
- [ ] Si le problème subsiste, récupérer le rapport tvOS de type **JetsamEvent** ou rapport de crash et isoler la pile fautive avant une autre modification du moteur de streaming.
- [ ] Ne pas fusionner les travaux V2.5 « Mes jeux » avant la stabilisation du lancement.

## 22 novembre 2026 — V2.4.1 « Stabilité du lancement » (correctif expérimental)

**Symptôme rapporté :** sélectionner **« Installer et jouer »** dans le catalogue ferme immédiatement ou rapidement l'application, avec retour à l'accueil de l'Apple TV. **Aucun journal de crash tvOS n'a été fourni : la cause exacte n'est pas confirmée.**

**Branche :** [feature/v2.4.1-launch-stability](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.4.1-launch-stability)  
**Diff :** [V2.4 → V2.4.1](https://github.com/thedjazairi28/BoosteroidATV/compare/feature/v2.4-gamepad-pointer...feature/v2.4.1-launch-stability)  
**Build :** [GitHub Actions #45030927237](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45030927237) — **réussi**. Artifact : `BoosteroidATV-v2-4-1-launch-stability-unsigned` (ZIP contenant un IPA), disponible jusqu'au **29 novembre 2026**.  
**Test Apple TV :** **KO selon retour utilisateur (22/11/2026)** : après essai, l'application se ferme pour chaque jeu tenté, et pas seulement « Installer et jouer ». Le caractère systématique et la cause exacte restent à confirmer par logs et test de retour arrière. **Ne pas présenter cette version comme un correctif validé.**

### Régression critique signalée lors des essais

- **Nouveau constat utilisateur : « tout se coupe peu importe le jeu »**, après le signalement initial limité à « Installer et jouer ». Retour à l'accueil tvOS évoqué dans le même contexte ; **crash système non prouvé sans rapport**.
- **Décision : déconseiller V2.4.1 jusqu'au diagnostic**, revenir à [V2.4 — build #45026265985](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45026265985) pour tester la régression, puis à V2.3.2 si nécessaire.
- Comparaison de code V2.4 → V2.4.1 : seuls `HomeView.swift` (logique différée de lancement / démontage du lecteur HLS) et le workflow de compilation ont changé. **Corrélation temporelle ≠ preuve de causalité.**
- **Diagnostic souhaité :** version IPA réellement installée, point exact de fermeture, et éventuel rapport de crash/Jetsam de tvOS.
- **Ne pas fusionner la branche V2.4.1 ni ajouter V2.5 « Mes jeux » avant d'avoir rétabli le lancement.**

### Hypothèse technique et mitigation

- La V2.4 peut afficher un **trailer HLS (AVPlayer)** dans une fiche au moment où l'utilisateur lance une session **WebRTC**. Deux moteurs de décodage vidéo peuvent se chevaucher brièvement lors des transitions SwiftUI, et déclencher une pression mémoire sur tvOS (**hypothèse, non démontrée sans logs / JetsamEvent**).
- Quand l'utilisateur appuie sur **Jouer** ou **Installer et jouer**, l'application **supprime d'abord le lecteur d'aperçu HLS**, attend brièvement un cycle de rendu avant d'ouvrir le flux de jeu et bloque les doubles pressions.
- La même protection est appliquée au carrousel de la Bibliothèque, qui ferme déjà la fiche avant d'ouvrir la session.
- **Le code ne modifie pas le protocole Boosteroid d'installation**. Les jeux marqués « Installer et jouer » utilisent la même demande d'ouverture de session que les autres jeux, et l'installation effective sur la machine cloud n'est pas pilotée explicitement par cette mitigation.

### Vérifications nécessaires

- [ ] Lancer un jeu **Jouer** connu fonctionnel, depuis la Bibliothèque.
- [ ] Lancer un jeu **Installer et jouer** depuis le Catalogue et observer si l'application reste ouverte, même si Boosteroid refuse la session.
- [ ] Relancer un jeu dont l'aperçu vidéo HLS a réellement démarré (à contrôler pour exclure le chevauchement des décodeurs).
- [ ] Si le retour à l'accueil Apple TV persiste : récupérer le **rapport de crash ou JetsamEvent tvOS** et noter le titre précis du jeu, sa boutique et le moment de la sortie. Sans ces données, ne pas présenter l'hypothèse mémoire comme un diagnostic définitif.

### Évolution « Mes jeux » (projet indépendant)

Une branche **`feature/v2.5-my-games-home`** a été créée pour une future page d'accueil : « Reprendre », favoris, historique récent et jeux **marqués manuellement comme possédés**. La vérification de licences multi-comptes EA/Steam/Epic/Xbox n'est **pas disponible** à ce stade. **Ne pas regrouper cette évolution visuelle avec le correctif de crash avant validation.**

## 22 novembre 2026 — V2.4 « Souris virtuelle avec manette » (expérimental)

**Demande :** piloter le pointeur dans Steam et les lanceurs directement avec la manette Xbox/PlayStation, sans recourir à la surface tactile de la Siri Remote.

**Branche :** [feature/v2.4-gamepad-pointer](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.4-gamepad-pointer)  
**Comparaison :** [V2.3.3 → V2.4](https://github.com/thedjazairi28/BoosteroidATV/compare/feature/v2.3.3-clean-game-cards...feature/v2.4-gamepad-pointer)  
**Compilation :** [GitHub Actions #45026265985](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45026265985) — **réussie**. Artifact : `BoosteroidATV-v2-4-gamepad-pointer-unsigned` (archive ZIP contenant l'IPA), expiration **29/11/2026**.  
**Tests Apple TV :** non effectués sur la V2.4.

### Fonctionnement

- Le mode **« Pointeur »** de la barre d'options accepte désormais aussi le **joystick droit** d'une manette compatible pour déplacer le curseur.
- **A (Xbox) / Croix (PlayStation)** déclenche un **clic gauche** envoyé séquentiellement au PC distant.
- **B (Xbox) / Rond (PlayStation)** permet de **quitter le mode Pointeur** et de reprendre les contrôles du jeu.
- Le joystick droit applique une **zone morte** et une **vitesse progressive** adaptée à la résolution du flux ; les coordonnées restent celles du bureau distant.
- Les boutons et axes de la manette sont **neutralisés et non transmis au jeu en mode Pointeur** afin d'éviter mouvements de caméra et actions involontaires.
- À la sortie du mode, l'état des boutons tenus est pris en compte pour que B/Rond ne déclenche pas une action non voulue en jeu.
- **Start + Select** reste utilisable pour ouvrir/fermer la barre d'options.
- Le mode existant avec la **Siri Remote** reste disponible et inchangé. Hors mode Pointeur, la manette continue à piloter le jeu normalement.
- L'aide intégrée en français décrit les nouvelles commandes.

### À valider sur Apple TV

- [ ] Ouvrir un jeu Boosteroid, afficher le menu avec Start + Select, puis activer « Pointeur ».
- [ ] Vérifier le mouvement du curseur avec le joystick droit, y compris vers les bords et en diagonale.
- [ ] Vérifier qu'A/Croix clique sans déclencher d'action dans le jeu distant.
- [ ] Vérifier que B/Rond sort du mode Pointeur sans agir dans le jeu.
- [ ] Vérifier l'absence de « stuck buttons » ou de mouvement involontaire au retour au contrôle normal.
- [ ] Vérifier l'accès à la barre d'options et la compatibilité de la Siri Remote.
- [ ] Tester au minimum Steam et un jeu actif, avec une manette Xbox ; PlayStation est prévu mais pas encore validé.

**Limite :** nouveau routage des entrées `GameController` vers le protocole souris Boosteroid ; le fonctionnement réel, notamment la prise en charge des clics, doit être validé sur matériel. Compilation réussie ≠ test fonctionnel.

## 22 novembre 2026 — V2.3.3 « Fiches de jeu épurées » (correctif expérimental)

**Retour utilisateur (Apple TV, V2.3.2) :** la lecture HLS fonctionne bien, mais la fiche affiche inutilement un message comme « 2 vidéos trouvées pour l'ID 1174180 ». Ce message est un diagnostic de développement, pas une information utile au joueur.

**Branche :** [feature/v2.3.3-clean-game-cards](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.3.3-clean-game-cards)  
**Diff :** [V2.3.2 → V2.3.3](https://github.com/thedjazairi28/BoosteroidATV/compare/feature/v2.3.2-hls-trailers...feature/v2.3.3-clean-game-cards)  
**Compilation :** GitHub Actions déclenché par push ; résultat et lien d'Artifact à confirmer.  
**Test Apple TV V2.3.3 :** non effectué.

### Correction appliquée

- Suppression sur les fiches de jeu et sur le carrousel de l'affichage des **compteurs de vidéos, identifiants Steam, formats MP4/HLS et messages de découverte**.
- Conservation des diagnostics dans la logique de récupération des médias, sans affichage systématique dans l'interface.
- Le bouton **« Réessayer la vidéo »** n'apparaît que si une recherche terminée n'a trouvé aucune vidéo exploitable ; aucun bouton parasite pendant le chargement initial ou lorsqu'une vidéo joue.
- Le lecteur HLS silencieux, la description française et les actions « Jouer » / « Favoris » sont inchangés.

### Informations envisagées, sans implémentation pour l'instant

Priorité : **année de sortie, genre, mode solo/multijoueur/coopération, classification PEGI ou équivalent selon la région, boutiques réellement compatibles et compatibilité manette**. En second : durée de campagne (source externe fiable nécessaire) et dernière partie jouée (donnée locale).

**Ne pas afficher de données inventées :** les métadonnées disponibles varient selon les jeux et les plateformes ; il faudra vérifier les sources et la pertinence sur tvOS avant d'ajouter chaque rubrique.

## 22 novembre 2026 — V2.3.2 « Lecture HLS » (correctif expérimental)

**Motif :** sur Apple TV, la fiche **Red Dead Redemption 2 (Rockstar)** affichait « 2 vidéo(s) listée(s), mais aucune URL MP4 compatible (ID 1174180) » dans la V2.3.1. C'est un **test KO pour l'aperçu vidéo** ; le descriptif français et la fiche de jeu sont visibles.

**Branche :** [feature/v2.3.2-hls-trailers](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.3.2-hls-trailers)  
**Diff :** [V2.3.1 → V2.3.2](https://github.com/thedjazairi28/BoosteroidATV/compare/feature/v2.3.1-video-diagnostics...feature/v2.3.2-hls-trailers)  
**Compilation :** [GitHub Actions #45024722519](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45024722519) — **réussie**. Artifact : `BoosteroidATV-v2-3-2-hls-trailers-unsigned` (ZIP contenant l'IPA), expiration **29/11/2026**.  
**Tests Apple TV :** non exécutés sur V2.3.2.

### Corrections

- Steam renvoie désormais pour de nombreux titres une URL de playlist **HLS H.264** (champs `hls_h264` ou `hls`), alors que l'application n'acceptait que les anciens liens `mp4.max` et `mp4.480`.
- Les extraits HLS `.m3u8` sont sélectionnés en priorité pour les bandes-annonces ; si aucun HLS reconnu n'existe, les liens MP4 traditionnels restent acceptés.
- La vérification HTTPS et la liste de domaines Steam autorisés sont conservées.
- Sur tvOS, les HLS sont confiés à **AVPlayer**, sans transcodage ; la répétition s'effectue au terme du clip avec `seek(to: .zero)` plutôt qu'avec `AVPlayerLooper`, afin d'éviter les téléchargements concurrents des morceaux HLS. Les MP4 conservent le lecteur en boucle initial.
- La lecture reste **muette**, sans commandes d'interaction, et s'arrête à la fermeture de la fiche.
- Diagnostic mis à jour pour distinguer les URL HLS ou MP4 trouvées des vidéos dépourvues de source compatible.

### Validation et limites

- [ ] Confirmer qu'une vidéo démarre dans la fiche Red Dead Redemption 2 sur Apple TV.
- [ ] Vérifier silence, redémarrage en boucle, fermeture propre et navigation entre deux fiches.
- [ ] Tester un jeu ne fournissant qu'un ancien MP4 et un jeu sans source.
- [ ] Si le lecteur reste vide, examiner les erreurs AVPlayer et la disponibilité effective de la playlist HLS depuis le réseau de l'Apple TV.
- Le correctif se fonde sur les champs de métadonnées Steam connus et sur la prise en charge HLS d'AVFoundation. **La réussite de la compilation ne prouve pas la lecture réelle**.

## 22 novembre 2026 — V2.3.1 « Diagnostic des vidéos » (correctif expérimental)

**Motif :** retour de test Apple TV : **aucune vidéo ne démarre à l'ouverture d'une fiche de jeu dans la V2.3**. Cause réelle non encore identifiée.  
**Branche :** [feature/v2.3.1-video-diagnostics](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.3.1-video-diagnostics)  
**Diff :** [V2.3 → V2.3.1](https://github.com/thedjazairi28/BoosteroidATV/compare/feature/v2.3-french-trailers...feature/v2.3.1-video-diagnostics)  
**Builds :** [#45024010277](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45024010277) — **réussi** ; [#45024136324](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45024136324) — **réussi**, incluant entêtes HTTP de compatibilité Steam. Artifact : `BoosteroidATV-v2-3-1-video-diagnostics-unsigned` (ZIP contenant l'IPA), expiration **29/11/2026**.  
**Tests sur Apple TV :** non exécutés sur cette version.

### Corrections / diagnostics

- La V2.3 ne remontait pas les erreurs de recherche Steam ni l'absence de sources : le fond statique masquait tout échec. Affichage du **statut précis dans la fiche**, en français.
- **Bouton « Réessayer la vidéo »** pour rejouer une recherche lorsqu'aucune source n'a été trouvée.
- Pour le cas de référence **Red Dead Redemption 2**, accès direct à l'ID Steam public connu `1174180` pour éviter que l'échec de la recherche par titre bloque la récupération du trailer.
- Distinction des cas : recherche Steam indisponible, jeu non retrouvé, réponse `appdetails` refusée/non conforme, absence de clips, sources MP4 non reconnues.
- Ajout d'en-têtes HTTP de navigateur / préférence de langue française sur les requêtes Steam publiques pour réduire les rejets liés au client intégré.
- Remontée d'une erreur lorsque le lecteur AVQueuePlayer passe à l'état `failed`.
- Nettoyage des ressources de lecture à la fermeture sans manipuler la file d'attente de l'AVPlayerLooper encore active.

### Limites

- Le fonctionnement réel de l'API Steam sur **cette Apple TV et ce réseau** n'a pas été observé : il reste possible qu'un jeu ne fournisse pas de MP4 utilisable.
- Un build réussi confirme la compilation, **pas** l'accès au catalogue Steam ni le décodage vidéo.
- **Prochain test demandé :** installer la V2.3.1, ouvrir la fiche Red Dead Redemption 2, lire le message de diagnostic visible, observer si la vidéo est animée ou statique.

## 22 novembre 2026 — V2.3 « Aperçus animés silencieux » (expérimental)

**Branche :** [feature/v2.3-french-trailers](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.3-french-trailers)  
**Comparaison avec V2.2 :** [diff V2.2 → V2.3](https://github.com/thedjazairi28/BoosteroidATV/compare/feature/v2.2-multi-store-filters...feature/v2.3-french-trailers)  
**Compilation :** [GitHub Actions #45023302268](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45023302268) — **réussie** ; [build final #45023434107](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45023434107) — **réussi** avec IPA `BoosteroidATV-v2-3-silent-autoplay-unsigned` (Artifact disponible jusqu'au **29/11/2026**).  
**Tests sur Apple TV :** non effectués.

### Demande utilisateur et réalisation

- **Un aperçu vidéo démarre automatiquement à l'ouverture de la fiche** lorsque la vidéo publique d'un jeu est disponible, **sans son**, **en boucle**, derrière le texte et les boutons. Il ne s'agit pas d'un bouton pour lancer YouTube ou Twitch ni d'une rangée de vidéos sous le descriptif.
- Lecture intégrée via **AVFoundation** (`AVQueuePlayer`, `AVPlayerLooper`, `AVPlayerLayer`), sans compte YouTube, Twitch ou Steam. Le lecteur ne comporte aucune commande visible.
- Recherche des clips du jeu dans les métadonnées publiques du magasin Steam, en privilégiant une vidéo nommée « Gameplay » ; à défaut, première bande-annonce disponible.
- **Retour sur une image fixe** si Steam ne référence pas le titre avec correspondance exacte ou ne renvoie pas de vidéo MP4 HTTPS compatible.
- Lecture stoppée à la fermeture de la fiche, et changement de clip lors du passage à un autre jeu. Correctif de transition : fermeture du carrousel avant de lancer le streaming pour éviter que la vidéo du fond continue pendant la partie.
- La récupération des vidéos est limitée aux fiches ouvertes ; un délai de 450 ms limite les requêtes lors des changements rapides de jeu.
- En complément, la fiche affiche une **description en français issue des données publiques Steam**, si présente et reconnue comme française, ou une mention d'indisponibilité. Les résumés anglais ne sont pas volontairement affichés à sa place.

### Limites connues et vérifications

- **Compilation réussie ne veut pas dire lecture validée** : tester Red Dead Redemption 2 sur Apple TV, en particulier lecture, boucle, silence et arrêt de lecture à la fermeture.
- La disponibilité des vidéos varie selon le jeu, le catalogue Steam et le format CDN. **Ce n'est pas du streaming Twitch/YouTube** ni une garantie d'extraits de gameplay pour tous les titres.
- La recherche Steam par intitulé peut ne pas trouver certaines éditions ou des jeux non présents dans Steam.
- La lecture automatique peut consommer de la bande passante ; aucun téléchargement permanent ni préchargement de toute la bibliothèque.
- Cette branche reste indépendante et **ne corrige pas les trois tests KO de V2.1** (comptes, saisie iPhone et réglages).

## 22 novembre 2026 — V2.2 « Filtres multiples, fiches de jeux et français » (développement)

**Branche :** [feature/v2.2-multi-store-filters](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.2-multi-store-filters)  
**Comparaison avec V2.1 :** [diff V2.1 → V2.2](https://github.com/thedjazairi28/BoosteroidATV/compare/feature/v2.1-stability...feature/v2.2-multi-store-filters)  
**Compilation :** [premier build des filtres #45020911625](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45020911625) — **réussi** ; [build initial avec traduction et fiches #45021265100](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45021265100) — **réussi** ; [refonte des fiches et récupération des détails #45021832418](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45021832418) — **réussi** ; [compilation de la dernière modification, limitant les requêtes en navigation rapide #45021937836](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45021937836) — **à vérifier**. Artifact attendu : `BoosteroidATV-v2-2-multi-store-filters-unsigned` (ZIP contenant l'IPA). Les artifacts sont temporaires.  
**Tests tvOS :** non effectués sur cette version.

### Ajouté

- Les boutiques du catalogue ne sont plus exclusives : sélection multiple par **cases indépendantes**.
- Boutiques disponibles : **Steam**, **Xbox**, **Epic Games**, **Autres** (jeux sans boutique parmi les trois précédentes reconnue).
- Bouton **« Tout cocher »** pour afficher toutes les boutiques et les jeux dont la boutique est inconnue.
- Les filtres se combinent en **OU** : choisir Steam + Xbox affiche les jeux identifiés sur l'une ou l'autre boutique.
- La recherche par nom reste active et se combine aux boutiques cochées, sans nouvel appel réseau au changement de filtre.
- Si aucune boutique n'est cochée, un message explicite est affiché au lieu de prétendre qu'il n'existe aucun résultat.

### Fiche de jeu enrichie

- Ajout d'une section **« À propos du jeu »** dans les fiches, ainsi que dans le carrousel de la bibliothèque.
- Affichage du résumé **réel fourni par les métadonnées Boosteroid**, s'il existe. À défaut, message honnête indiquant qu'aucun résumé détaillé n'est disponible.
- Ajout ou meilleure visibilité des **genres, boutiques, développeur, éditeur et classification**, selon les champs disponibles.
- Bouton **« Détails du jeu »** dans le bandeau d'accueil pour ouvrir la fiche plutôt que lancer immédiatement un jeu.
- Traduction française des principaux intitulés de genres courants.

### Refonte après retour terrain (photo de Red Dead Redemption 2, version installée V2.1)

- La capture montre un **fond générique dominant**, avec le titre, les boutons et des données de jeu tassés en bas de l'écran. Il s'agit du **carrousel de la bibliothèque V2.1**, pas d'un rendu V2.2.
- Refonte du carrousel : **jaquette dédiée si disponible**, présentation en deux colonnes, panneau à contraste renforcé, titre, synopsis, genres, boutiques, studio, éditeur, classification et boutons « Jouer » / « Favoris ».
- Requête facultative de **détails uniquement lorsqu'une fiche est ouverte**, mise en cache par identifiant et différée de **450 ms lors des changements de sélection** pour éviter de reproduire les centaines de requêtes à l'origine des erreurs HTTP 429.
- Le décodage des détails accepte deux formes possibles de réponse (application seule ou objet `data`) ; le format de cet endpoint restant non validé en conditions réelles, **son enrichissement n'est pas garanti**.
- Si le service ne fournit pas de synopsis, un message explicite apparaît. Aucun synopsis inventé ou dépendance à une API de traduction externe.
- **Statut : code soumis ; validation Apple TV et comportement réel de l'API à contrôler après compilation.**

### Interface en français

- Traduction des **libellés de l'accueil, de la bibliothèque, de la connexion, des paramètres et des commandes de streaming**.
- Réécriture de la page **Aide** en français, y compris l'explication du mode pointeur avec la Siri Remote.
- Traduction des principaux messages d'erreur d'authentification et des états de préparation visibles.
- **Limite de périmètre :** les noms de jeux, les résumés d'origine renvoyés par Boosteroid (éventuellement en anglais), les noms de boutiques et l'interface du PC distant (Steam / lanceurs / jeux) ne sont **pas traduits automatiquement**. Aucune API de traduction externe n'a été ajoutée.


### Limitations et validation nécessaire

- Vérifier l'ouverture des nouvelles fiches de jeu, les résumés et le rendu sans débordement sur Apple TV.
- Vérifier spécialement **Red Dead Redemption 2 (Rockstar)** : récupération éventuelle d'un résumé via les détails à la demande, couverture, navigation du carrousel et fluidité. Les données manquantes doivent rester signalées.
- Vérifier les libellés et la navigation en français sur les écrans d'accueil, bibliothèque, connexion, aide, streaming et paramètres.
- Les résumés fournis par Boosteroid peuvent être absents ou rédigés en anglais. **Pas d'invention ni de traduction automatique de ces textes.**
- Le rattachement à une boutique dépend des métadonnées Boosteroid, avec des correspondances textuelles comme en V2.1 ; les jeux mal renseignés peuvent apparaître dans « Autres ».
- **Aucune confirmation de bon fonctionnement sur Apple TV** tant qu'un IPA V2.2 n'a pas été compilé, installé et testé.
- Cette version **ne corrige pas** les trois tests KO de V2.1 : enregistrement des comptes, saisie iPhone, accès aux paramètres de streaming.

## 22 novembre 2026 — Tests réels sur Apple TV (V2.1)

**Version :** V2.1 — `feature/v2.1-stability`. Résultats rapportés après installation sur Apple TV. **Une compilation GitHub Actions réussie ne signifie pas que les fonctionnalités fonctionnent.**

| Test fonctionnel | Verdict | Constat |
| --- | --- | --- |
| Démarrage de l'application | ✅ **OK** | L'application démarre sans erreur |
| Affichage du catalogue Steam / Xbox / Epic Games | ✅ **OK** | Jeux des trois boutiques affichés ; exhaustivité et lancement non validés |
| Enregistrement des identifiants des comptes de jeux | ❌ **KO** | Fonction non opérationnelle dans le test utilisateur ; erreur exacte / cause à diagnostiquer |
| Saisie de texte depuis l'iPhone | ❌ **KO** | Fonction non opérationnelle dans le test utilisateur ; cause à diagnostiquer |
| Accès aux paramètres d'optimisation et de streaming | ❌ **KO** | Fonction non opérationnelle dans le test utilisateur ; cause à diagnostiquer |
| Ligne rouge en bas de l'écran | ✅ **Disparue** | Absente lors du test V2.1 ; l'utilisateur suspecte un bug d'affichage de la TV. **Aucun lien causal avec une modification du code n'est établi.** |

**Bilan V2.1 : 3 observations positives (dont disparition de la ligne rouge), 3 tests KO. Version non validée pour diffusion stable.**

### Priorités de correction

1. Reproduire et isoler les trois échecs **Comptes**, **Saisie iPhone** et **Paramètres de streaming**, avec captures et étapes précises.
2. Surveiller une éventuelle réapparition de la ligne rouge ; ne pas attribuer sa disparition au logiciel sans preuve.
3. Corriger chaque anomalie dans une branche dédiée, compiler, puis refaire les tests sur Apple TV.
4. Ne publier une version « stable » qu'après validation effective ; conserver les builds expérimentaux séparés.

## 20 novembre 2026 — V2.1 « Stability »

**Branche :** [feature/v2.1-stability](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.1-stability)  
**Comparaison avec V2 :** [diff V2 → V2.1](https://github.com/thedjazairi28/BoosteroidATV/compare/feature/v2-smart-experience...feature/v2.1-stability)  
**Build :** [GitHub Actions #44839880457](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/44839880457) — **succès**

### Modifications

- Réduction du risque de limitation **HTTP 429** : limitation du rythme des requêtes au catalogue, nombre de pages et collections plafonné, temporisation et quelques nouvelles tentatives bornées.
- Chargement du catalogue différé jusqu'à la fin du chargement initial de la bibliothèque ; délai de **5 minutes** entre deux tentatives de scan, y compris après un clic sur Actualiser.
- Conservation des jeux déjà chargés en cas d'échec du rafraîchissement et messages d'erreur plus lisibles.
- Ajout d'un onglet **« Comptes »** directement accessible ; ajustement de son comportement de fermeture.
- Traduction en français de plusieurs onglets, paramètres de streaming, messages et niveaux d'intensité des vibrations.
- Mise à jour du workflow GitHub Actions pour compiler cette branche et produire son IPA non signé.

### Limites / état

- **Tests Apple TV du 22/11/2026 : échecs confirmés** pour la gestion des identifiants, la saisie iPhone et l'accès aux paramètres d'optimisation/streaming. Voir le rapport ci-dessus. Le démarrage et l'affichage du catalogue sont validés.
- Le catalogue n'est pas garanti exhaustif ; la protection contre les 429 limite volontairement le volume des recherches.

## 20 novembre 2026 — V2 « Smart Experience »

**Branche :** [feature/v2-smart-experience](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2-smart-experience)  
**Comparaison avec V1 :** [diff V1 → V2](https://github.com/thedjazairi28/BoosteroidATV/compare/feature/unified-catalog-v1...feature/v2-smart-experience)  
**Build :** [GitHub Actions #44836464798](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/44836464798) — **succès**

### Ajouts

- Gestion locale des comptes de jeux **Rockstar, Steam, Epic Games et Xbox**.
- Stockage local des identifiants dans le **Keychain de l'Apple TV**, avec possibilité de supprimer un compte enregistré.
- Panneau d'envoi manuel de l'identifiant ou du mot de passe vers le champ déjà sélectionné dans le PC distant.
- Option **« Profil automatique par jeu »** : choix conservateur entre réactivité, qualité et équilibré selon les métadonnées du jeu.
- Pour les jeux classés compétitifs, possibilité de ramener une demande de résolution 1440p/4K à **1080p** et d'utiliser le débit automatique ; les FPS et codecs ne sont pas augmentés artificiellement.
- Ajouts liés à l'affichage / au suivi des diagnostics du streaming.

### Limites

- **Pas d'auto-login transparent** : il faut sélectionner le champ distant puis déclencher explicitement l'envoi de l'identifiant ou du mot de passe.
- L'envoi de texte est limité aux **caractères ASCII** dans l'implémentation actuelle ; MFA/captcha ne sont pas automatisés.
- Le stockage Keychain protège les données au niveau local, mais la fonction ne vaut pas un gestionnaire de mots de passe avec déverrouillage biométrique.
- L'optimisation dite « intelligente » ajuste la **demande de flux**, pas le GPU du serveur Boosteroid ni la qualité du réseau domestique.

## 20 novembre 2026 — V1 « Catalogue unifié »

**Branche :** [feature/unified-catalog-v1](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/unified-catalog-v1)  
**Comparaison avec la base :** [diff main → V1](https://github.com/thedjazairi28/BoosteroidATV/compare/main...feature/unified-catalog-v1)  
**Build :** [GitHub Actions #44825820586](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/44825820586) — **succès**

### Ajouts

- Vue **« Catalogue »** regroupant les jeux récupérables depuis les collections Boosteroid prises en charge et la bibliothèque de l'utilisateur.
- **Recherche** par titre et filtres par boutique : **Tous, Steam, Xbox, Epic Games**.
- Fiches de jeu indiquant « prêt à jouer » ou « installer et jouer » selon les métadonnées disponibles.
- Champ de **saisie de texte native tvOS**, pouvant utiliser le clavier de l'iPhone via l'application Télécommande Apple TV.
- Envoi du texte saisi au PC distant et gestion améliorée de certains caractères nécessitant **Shift** (dont `@`).
- Navigation entre les onglets avec **LB/RB** d'une manette compatible.
- Workflow GitHub Actions produisant un **IPA non signé** utilisable dans un outil de sideload.

### Limites

- Le « catalogue unifié » repose sur des collections et API observées ; il **ne garantit pas** de représenter l'intégralité du catalogue commercial Boosteroid.
- Le filtrage par boutique repose en partie sur les métadonnées / intitulés disponibles et peut être imparfait.
- La saisie de texte ne constitue pas une prise en charge universelle de tous les caractères Unicode.

## Tests terrain déjà effectués — application de base

Ces essais concernent l'application BoosteroidATV installée **avant validation des branches V1/V2/V2.1**, sauf indication contraire.

- **Fedora 44** : Docker installé et opérationnel (test `hello-world` réussi), Avahi fonctionnel.
- **atvloadly** : interface web accessible sur Fedora ; appairage avec l'Apple TV réussi.
- **Installation tvOS** : signature / installation de l'IPA réussie via atvloadly (« installation succeeded »).
- **Streaming Boosteroid** : démarrage d'une session et accès à l'interface Steam observés.
- **Navigation dans Steam** : le mode « Pointer » fonctionne avec la **surface tactile de la Siri Remote** et un clic central, pas avec le stick de la manette Xbox.
- **Anomalie auparavant observée** : **fine ligne rouge en bas du flux vidéo**. Signalée disparue lors des essais V2.1 du 22/11/2026. Origine indéterminée (l'utilisateur soupçonne un défaut temporaire d'affichage) ; ne pas présenter V2.1 comme un correctif.

## Fichiers compilés et récupération

Les téléchargements GitHub Actions se trouvent dans la rubrique **Artifacts** de chaque exécution. Ils sont fournis sous forme d'archives ZIP contenant un IPA **non signé**.

| Version | Artifact | Exécution |
| --- | --- | --- |
| V1 | `BoosteroidATV-unified-catalog-unsigned` | [#44825820586](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/44825820586) |
| V2 | `BoosteroidATV-v2-unsigned` | [#44836464798](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/44836464798) |
| V2.1 | `BoosteroidATV-v2-1-stability-unsigned` | [#44839880457](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/44839880457) |
| V2.2 | `BoosteroidATV-v2-2-multi-store-filters-unsigned` | [#45021265100](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45021265100) |
| V2.3 | `BoosteroidATV-v2-3-silent-autoplay-unsigned` | [#45023434107](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45023434107) |
| V2.3.1 | `BoosteroidATV-v2-3-1-video-diagnostics-unsigned` | [#45024136324](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45024136324) |

**Expiration annoncée par GitHub : 27 novembre 2026 pour V1/V2/V2.1 ; 29 novembre 2026 pour V2.2 et V2.3.** Après expiration, relancer un build ou publier un fichier dans **Releases** pour disposer d'un téléchargement plus durable. Aucun Release propre à ce fork n'a été trouvé lors de la rédaction.

## À faire / à valider

- [x] Installer l'IPA **V2.1** sur l'Apple TV et confirmer le démarrage de l'application (OK, 22/11/2026).
- [x] Vérifier que le catalogue V2.1 affiche Steam / Xbox / Epic (OK, 22/11/2026).
- [ ] Vérifier séparément la navigation LB/RB et les onglets Bibliothèque / Comptes (non documentés par les tests transmis).
- [ ] **KO le 22/11/2026 :** diagnostiquer et corriger la saisie depuis l'iPhone, puis refaire les tests.
- [ ] **KO le 22/11/2026 :** diagnostiquer la fonction d'enregistrement des identifiants, puis tester leur envoi sans publier d'identifiants ou de secrets dans GitHub.
- [ ] Tester la protection HTTP 429 et la stabilité du catalogue au fil des sessions.
- [ ] **KO le 22/11/2026 :** diagnostiquer l'accès aux paramètres d'optimisation et de streaming ; mesurer ensuite la latence et l'effet des profils.
- [x] Confirmer la disparition de la **ligne rouge en bas de l'image** sur le test V2.1 du 22/11/2026 ; **cause non établie**, surveiller si l'anomalie revient.
- [ ] Publier une version validée dans **GitHub Releases** (IPA non signé) avec des notes de version permanentes.

## Convention pour les prochaines modifications

À chaque nouvelle version, **ajouter une section en haut** de ce document avec :

1. **Date, nom de version, branche, commit et lien de comparaison**.
2. **Ajouté / Modifié / Corrigé / Retiré** : uniquement les changements visibles dans le code ou les commits.
3. **Compilation** : succès, échec ou non exécutée, avec lien vers le build.
4. **Validation sur Apple TV** : testé, non testé ou problème reproduit.
5. **Limitations et régressions connues**, ainsi que le lien vers le téléchargement si disponible.

**Ne jamais confondre « code ajouté », « build réussi » et « testé en conditions réelles ».**
