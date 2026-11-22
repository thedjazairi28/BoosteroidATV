# BoosteroidATV — Mémoire technique et état courant

> **Document canonique du projet.** Toujours consulter ce fichier sur la branche **`main`**, avant toute modification, diagnostic ou publication.
> Ce fichier est une mémoire *versionnée* et vérifiable, pas une garantie de suivi en arrière-plan. Toute nouvelle intervention doit le mettre à jour immédiatement, à partir de résultats observés, avec références GitHub et tests matériels.
> **Référence initiale : 22 novembre 2026 (Europe/Paris)** — historique conservé intégralement ci-dessous. Dépôt public : **aucun secret, adresse personnelle, identifiant Apple ni token ici**.

## 0 — Situation actuelle (dernière vérification : 22 novembre 2026)

| Élément | État attesté | Reste à démontrer |
|---|---|---|
| Dépôt | [`thedjazairi28/BoosteroidATV`](https://github.com/thedjazairi28/BoosteroidATV), **public**, branche principale `main` | Passage éventuel à la distribution privée |
| Base de code déployée | **V2.4.6**, version installée relevée `2026.11.22.13` sur atvloadly ; rapport GitHub créé depuis Apple TV | Version effectivement installée **après** premier cycle d'auto-update |
| Release actuelle | [`v2026.11.22.16`](https://github.com/thedjazairi28/BoosteroidATV/releases/tag/v2026.11.22.16), IPA non signée `BoosteroidATV-2026.11.22.16.ipa`, issue de `feature/v2.4.6-keychain-reliability` | Ne pas supposer cette Release déjà installée |
| Automatisation Fedora | Conteneur Docker `atvloadly` actif, interface locale `127.0.0.1:5533`, Apple TV appairée ; **source GitHub et `auto_update=true` confirmés par l'utilisateur** après `GET /api/apps` | Installation autonome, stratégie de renouvellement, persistance après mise à jour, sauvegarde Docker |
| Keychain et GitHub Issues | Jeton lisible dans Keychain sur Apple TV ; envoi réel confirmé : [Issue #4](https://github.com/thedjazairi28/BoosteroidATV/issues/4) et [Issue #5](https://github.com/thedjazairi28/BoosteroidATV/issues/5) | Maintien de l'accès après changement de signature ou réinstallation ; ancien PAT publié à révoquer si non fait |
| Crash Call of Duty | Issue #5 : sélection de la fiche `Call of Duty: Modern Warfare (Xbox)` à 15:10:32 UTC, redémarrage menu à 15:10:35 UTC, **avant `Jouer` et WebRTC** | Cause racine (SwiftUI, chargement médias, Jetsam ou autre) |
| Test ciblé | [V2.4.8 — mode léger Xbox](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.4.8-xbox-card-safe-mode), [build GitHub Actions réussi](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45037087776), [PR #6](https://github.com/thedjazairi28/BoosteroidATV/pull/6) | Test Apple TV **non réalisé**, ne pas diffuser en release automatique |
| Sécurité | Code `main` non fusionné avec les branches expérimentales ; publication de Release **manuelle** avec `PUBLISH` | Vérifier que les versions réellement validées seules sont publiées |

### Priorités courantes
1. **Préserver la stabilité** : ne pas désinstaller `BoosteroidTV`, changer son bundle ID/Team ID, recréer le volume Docker ou publier une branche expérimentale non validée.
2. **Prouver l'auto-update** : relever `GET /api/apps`, version avant/après, identité de signature, accès Keychain et éventuel renouvellement à échéance.
3. **Résoudre la fiche COD** : tester V2.4.8 sur matériel sans la publier comme release automatique ; récupérer un nouveau rapport GitHub et, si besoin, le crash natif tvOS/Jetsam.
4. Ensuite seulement : revoir anciens échecs Comptes/saisie iPhone/réglages, manette/pointeur, V2.5 « Mes jeux ».

## Protocole obligatoire de maintenance documentaire

**Avant chaque tâche :** relire `docs/PROJECT_STATE.md` depuis **`main`**, vérifier les branches/PR/Issues, la dernière Release, le dernier build Actions et les informations terrain nouvelles. Ne pas se fonder uniquement sur une conversation ChatGPT ou un état mis en cache.

**Après chaque tâche qui change la réalité :**
- Mettre à jour le tableau **« Situation actuelle »** avec date, versions, SHA et preuves.
- Ajouter une entrée datée au **« Journal des interventions »** ci-dessous : problème, décision, fichiers modifiés, branche/commit, statut compilation, test réel, liens vers PR, Issues, Releases, régression/rollback.
- Mettre les anciennes observations en **historique**, jamais les effacer ; corriger explicitement les données dépassées.
- Distinguer rigoureusement **codé**, **compilé**, **installé**, **testé**, **fonctionnel**, **publié** et **mis à jour automatiquement**. Une preuve de compilation n'est pas une preuve tvOS.
- Après chaque Release, vérifier que `release_version`, `source_ref`, l'IPA et les mises à jour atvloadly se correspondent. **Ne jamais confondre GitHub Actions Artifacts et GitHub Releases.**
- Lors d'un échec réseau/crash, obtenir un rapport sur l'appareil et ne jamais prétendre disposer de logs natifs non collectés.
- Publier les changements de ce fichier dans `main` ; des branches d'expérimentation anciennes peuvent ne pas contenir les règles documentaires ajoutées plus tard.
- Ne jamais insérer de jetons, mots de passe, cookies, identifiants de comptes ou données familiales/personnelles ; le dépôt est actuellement **public**.
- La mise à jour est exécutée **pendant** l'intervention de développement ; aucun assistant n'assure une veille ou des écritures en arrière-plan sans automatisation explicitement configurée.

**Convention pour une entrée :**
`YYYY-MM-DD HH:mm Europe/Paris | Statut confirmé | Changement | Branch/SHA | Tests | Liens | Prochaine action`.

### Journal des interventions — append-only

- **2026-11-22 (initialisation)** — Dossier de transmission du projet importé sur GitHub comme source de vérité. Le contenu historique ci-dessous reste accessible et n'est plus seulement une pièce jointe ChatGPT. Aucun changement de code de streaming ni d'installation Apple TV. Prochaine action : validation terrain du premier update atvloadly et du mode léger Xbox V2.4.8.

---

## Historique consolidé au 22 novembre 2026

**Instantané : 22 novembre 2026, heure de Paris.** Ce document synthétise la conversation, le `CHANGELOG.md` du fork, les GitHub Issues, Releases et branches consultés le même jour. Les états peuvent changer. Ne jamais considérer les cases « non testé » comme validées automatiquement. Aucun mot de passe, compte Apple personnel ni token n'est reproduit.

## 1 — Mission, fonctionnement, périmètre

- Construire, améliorer et maintenir un client **natif Swift/SwiftUI tvOS** (fork de `luizhdramos/BoosteroidATV`) pour accéder aux jeux Boosteroid sur Apple TV via WebRTC. Application non officielle, abonnement Boosteroid personnel requis.
- Objectifs utilisateur : catalogue Steam/Xbox/Epic/Rockstar, accès Bibliothèque, fiches enrichies en français, vidéos de présentation silencieuses facultatives, commande à la manette Xbox/PlayStation y compris pointeur pour launcher PC, stabilité/qualité streaming, diagnostics et remontées GitHub, mises à jour aussi automatiques que possible sans sideload manuel.
- Priorité actuelle : **stabilité et simplicité d'exploitation**. Pas de marketing, pas d'affirmation de compatibilité non prouvée.

## 2 — Dépôts, structure et références

- Fork personnel : `https://github.com/thedjazairi28/BoosteroidATV` — **public** au 22/11/2026.
- Projet source : `https://github.com/luizhdramos/BoosteroidATV`.
- `main` : base logicielle + journal de suivi et workflows de publication ajoutés ; **les branches expérimentales ne sont pas fusionnées dans `main`**.
- `CHANGELOG.md` sur `main` : historique technique détaillé (des cellules d'état y sont parfois devenues obsolètes ; privilégier les résultats GitHub Actions et les essais utilisateur plus récents).
- Documents : `docs/atvloadly-auto-updates.md` sur `main` ; `docs/diagnostics-github-issues.md` sur les branches de diagnostic (dont `feature/v2.4.6-keychain-reliability`).
- Workflows : `.github/workflows/build-unified-catalog.yml` sur branches d'essai ; `.github/workflows/publish-apple-tv.yml` sur `main` pour publier uniquement après validation.
- Source Swift : `BoosteroidATV/UI/`, `BoosteroidATV/Diagnostics/DiagnosticGitHubReporter.swift`, `BoosteroidATV/Session/`, `BoosteroidATV/Streaming/`, `BoosteroidATV/Auth/`, `BoosteroidATV/Security/`, projet Xcode.
- PR ouvertes relevées : [#1 V2.4.4](https://github.com/thedjazairi28/BoosteroidATV/pull/1), [#2 V2.4.5](https://github.com/thedjazairi28/BoosteroidATV/pull/2), [#3 V2.4.6](https://github.com/thedjazairi28/BoosteroidATV/pull/3), [#6 V2.4.8](https://github.com/thedjazairi28/BoosteroidATV/pull/6), essentiellement en mode expérimental/draft. D'autres numéros (4 et 5) sont des **Issues de diagnostic**, pas des PR.

## 3 — Matériel et distribution actuelle

### Apple TV

- Appareil « **Salon** », déjà appairé via atvloadly ; adresse IP locale volontairement omise du dépôt public ; tvOS relevé dans les logs **27.2.1**.
- Manette utilisée pour piloter l'Apple TV/jeu ; iPhone également disponible pour la Télécommande et la saisie.
- Nom vu dans atvloadly : **BoosteroidTV** ; paquet/projet GitHub : **BoosteroidATV**. Ne pas conclure que ce sont deux applications différentes.
- Version **2026.11.22.13** observée dans atvloadly après installation de V2.4.6, avant activation du suivi automatique. L'utilisateur n'a PAS encore confirmé qu'une mise à jour automatique a réellement remplacé cette version.

### Fedora / Docker / atvloadly

- Machine Fedora, service Docker opérationnel (`sudo systemctl enable --now docker` déjà exécuté).
- `sudo docker ps -a` a montré :
  - conteneur : `atvloadly` ; image : `bitxeno/atvloadly:latest` ; commande `/entrypoint.sh` ; conteneur actif depuis environ 44 h lors du contrôle ; port `127.0.0.1:5533->80/tcp`.
- Interface : **http://localhost:5533**, accessible depuis Fedora uniquement ; **ne pas ouvrir le port à Internet**.
- Utilisateur ajouté au groupe `docker` via `sudo usermod -aG docker "$USER"`, suivi de `newgrp docker` (attention : le groupe Docker accorde des privilèges équivalents à root).
- Commande de redémarrage recommandée : `sudo docker update --restart unless-stopped atvloadly`. Sa bonne application effective et le montage `/data` restent à **vérifier** sur la machine :

  ```bash
  docker inspect atvloadly --format '{{.HostConfig.RestartPolicy.Name}}'
  docker inspect atvloadly --format '{{range .Mounts}}{{println .Destination .Source}}{{end}}'
  ```

- Ne jamais supprimer/recréer le conteneur ni son volume sans sauvegarde des éléments d'appairage et des identités de signature.
- atvloadly affiche une identité de signature Apple valide, sans reproduire ici l'adresse e-mail. Utiliser la même identité pour mises à jour et renouvellements.
- Dans atvloadly, l'app affichait encore **6 jours** de validité (profil de développement gratuit : durée typique de **7 jours**, renouvellement nécessaire et distinct des nouvelles versions).

### Suivi automatique déjà configuré

1. GitHub Releases a d'abord été vide : `Fetch` renvoyait `no matching build: no release with an IPA for this device (code: -1)`.
2. Création d'un workflow manuel `Publish approved Apple TV release` ; publication réussie de la première Release :
   - Tag : **`v2026.11.22.16`**
   - Lien : https://github.com/thedjazairi28/BoosteroidATV/releases/tag/v2026.11.22.16
   - Fichier : **`BoosteroidATV-2026.11.22.16.ipa`**, ~6,35 Mo, **non signé**.
   - Source confirmée par le texte de Release : `feature/v2.4.6-keychain-reliability`, commit `1a087daf7f8b58e490d5bea75714a120e092ca20`.
   - GitHub Actions de publication : run https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45038683269.
   - C'est une **Release publique**, pas une publication App Store. Toute personne peut télécharger l'IPA, mais elle n'a pas le compte Apple personnel ni le PAT tvOS.
3. Après publication, `Fetch` dans atvloadly a trouvé cette IPA, marquée `Recommended`. Source : `thedjazairi28/BoosteroidATV`, option *Include pre-releases* OFF.
4. L'utilisateur a ouvert la page principale d'atvloadly. L'app installée `BoosteroidTV` 2026.11.22.13 était visible. Dans « More », il n'a vu que `Reinstall` et `Delete`. **Ne pas utiliser Delete**, et ne pas confondre `Refresh` (renouvellement) avec la gestion des Releases.
5. Pour éviter de réinstaller, la configuration a été liée à l'app existante via l'API REST **locale** :

   `POST http://127.0.0.1:5533/api/apps/{ID}/source`

   Corps JSON :

   ```json
   {
     "kind": "github",
     "url": "thedjazairi28/BoosteroidATV",
     "filter": "^BoosteroidATV-[0-9.]+\\.ipa$",
     "prerelease": false,
     "auto_update": true,
     "installed_build_id": ""
   }
   ```

   Attention : la réponse atvloadly de succès est `{"code":200,"msg":"success", ...}`, **pas `code:0`**. Le premier script affichait « Erreur : success » à cause d'un contrôle `!= 0` erroné alors que l'opération réussissait ; ensuite un `GET /api/apps` a confirmé la source et `auto_update=True`, validation utilisateur « c'est ok ».
6. État validé : **source GitHub associée à l'installation existante, suivi automatique activé**. état non confirmé : premier remplacement automatique effectif, signature et Keychain après remplacement, planification nocturne, renouvellement à J+7, comportement lorsque Fedora est éteint.
7. La page d'accueil d'atvloadly indiquait que les applications liées à une source sont vérifiées en arrière-plan et que les mises à jour automatiques sont installées pendant la fenêtre de maintenance généralement entre 3 h et 6 h. Ne pas garantir un horaire précis sans vérifier la configuration.

### Commandes locales de contrôle non destructrices

```bash
sudo docker ps -a
sudo docker inspect atvloadly --format '{{.HostConfig.RestartPolicy.Name}}'
sudo docker inspect atvloadly --format '{{range .Mounts}}{{println .Destination .Source}}{{end}}'
python3 - <<'PY'
import json, urllib.request
with urllib.request.urlopen('http://127.0.0.1:5533/api/apps') as r:
    d = json.load(r)
assert d.get('code') == 200, d.get('msg')
for a in d['data']:
    if 'boosteroid' in (str(a.get('ipa_name','')) + str(a.get('custom_name',''))).lower():
        s = a.get('source') or {}
        print('Application:', a.get('ipa_name'))
        print('Version installée:', a.get('version'))
        print('Source:', s.get('url'))
        print('Type:', s.get('kind'))
        print('Auto-update:', s.get('auto_update'))
        print('Dernière version connue:', s.get('latest_version'))
        print('Erreur source:', s.get('check_error'))
PY
```

## 4 — Publication GitHub et politique de diffusion

- `.github/workflows/publish-apple-tv.yml` sur `main` : déclenchement **manuel** depuis GitHub Actions → **Publish approved Apple TV release** → Run workflow ; paramètres `source_ref` (branche `feature/...` ou SHA complet), `release_version` au format `YYYY.MM.DD.N`, `confirmation` exactement `PUBLISH`.
- GitHub Actions macOS compile via `scripts/build-ipa.sh` et `xcodebuild`, **CODE_SIGNING_ALLOWED=NO**, produit un IPA. Le runner n'a pas besoin des identifiants Apple personnels.
- Le workflow utilise le `GITHUB_TOKEN` temporaire du job avec permission `contents: write` pour joindre l'IPA à une Release ; il refuse de publier si le tag existe déjà. **Pas de PAT personnel dans le workflow**.
- Les builds de branches expérimentales créent surtout des **Artifacts** ZIP (`.github/workflows/build-unified-catalog.yml`) qui expirent typiquement après 7 jours ; ils ne sont pas détectables via GitHub Releases tant qu'ils ne sont pas publiés comme assets.
- **La branche `main` n'inclut pas le code des fonctionnalités expérimentales** : pour une nouvelle Release, indiquer explicitement la branche ou le SHA validé. Ne pas publier une Release depuis `main` par erreur.
- La publication `v2026.11.22.16` a été autorisée alors qu'elle correspond à V2.4.6, dont le Keychain et l'envoi d'Issues ont été testés sur Apple TV. **Le crash Call of Duty est toujours présent** ; donc « publiée » n'est pas équivalent à « complètement stable ».
- Si besoin de distribution strictement privée : créer une vraie chaîne avec dépôt privé distinct, token lecture seule compatible avec atvloadly, ne pas présumer que les Releases d'un dépôt public peuvent être secrètes. Éviter de changer le dépôt suivi tant que ce chantier n'est pas organisé.

## 5 — Diagnostics GitHub / Keychain tvOS

- Sous BoosteroidATV → **Réglages → Diagnostics** : journal de lancement à l'écran activable, 80 derniers événements conservés localement, bouton « Effacer », checkpoint, bouton **« Envoyer un rapport d'erreur »**.
- V2.4.4 introduit un `DiagnosticGitHubReporter` et une zone de configuration `owner/repo` + PAT fine-grained dans le Keychain. Les rapports sont **déclenchés manuellement** par l'utilisateur, jamais en arrière-plan.
- V2.4.5 inscrit la sélection de la fiche avant son affichage, le clic Jouer avant fermeture, les étapes de transition et un dernier checkpoint dans `UserDefaults`.
- V2.4.6 sécurise le remplacement de token (`SecItemUpdate` au lieu de `delete`+`add`), lit le Keychain pour confirmation et ajoute **« Vérifier le Keychain »**. Sur le matériel, l'utilisateur a obtenu « **Jeton présent** ».
- V2.4.7 ajoute un retour d'interface immédiat (alerte tvOS) sur l'opération et les codes d'erreur Keychain non sensibles. Branche compilée ; pas de test utilisateur attesté sur V2.4.7.
- Le PAT est une autorisation fine-grained limitée au dépôt et à `Issues: Read and write`. Son contenu **ne doit jamais apparaître** dans les prompts, captures, fichiers sources, Repositories, journaux ou fichiers de Release.
- Un ancien PAT a été écrit en clair dans une conversation : **considérer qu'il doit être révoqué et régénéré** ; la révocation n'est pas confirmée par les données disponibles. Le jeton présent dans le Keychain peut être un autre jeton ; vérifier selon besoin sans jamais demander sa valeur.
- Un premier essai d'envoi renvoyait **HTTP 410**, parce que le dépôt GitHub public avait `has_issues=false`. Activation des Issues dans `Settings → General → Features` a résolu le problème.
- L'utilisateur a confirmé **l'envoi réel** de rapports sur GitHub :
  - https://github.com/thedjazairi28/BoosteroidATV/issues/4 — simple ouverture menu, pas de crash.
  - https://github.com/thedjazairi28/BoosteroidATV/issues/5 — incident Call of Duty, voir ci-dessous.
- Un rapport contient version de l'app, tvOS, checkpoint, et jusqu'à 80 événements applicatifs préfiltrés, sans mots de passe ni payloads API bruts. Repo public = données du ticket publiques ; rester vigilant.
- **Limitation importante :** un traceur Swift ne capture pas un crash `EXC_BAD_ACCESS`, une exception non interceptée ou un `JetsamEvent` de tvOS. Obtenir les logs natifs via les outils développeur Apple si le journal est insuffisant.
- La persistance Keychain entre versions suppose un **bundle ID cohérent**, une signature/équipe Apple et des droits Keychain compatibles ; à vérifier lors de la première mise à jour automatique.

## 6 — Crash prioritaire : Call of Duty: Modern Warfare (Xbox)

### Éléments prouvés

- V2.4.6 testée, version `2026.11.22.13` sur **tvOS 27.2.1**.
- Ticket de référence https://github.com/thedjazairi28/BoosteroidATV/issues/5 :

  ```text
  2026-11-22T15:04:42Z [INFO] Application ouverte : menu principal
  2026-11-22T15:10:32Z [INFO] Fiche sélectionnée (Catalogue) : Call of Duty: Modern Warfare (Xbox)
  2026-11-22T15:10:35Z [INFO] Application ouverte : menu principal
  ```

- Aucun événement **« Bouton Jouer pressé »**, aucune ouverture de session Boosteroid, aucun message WebRTC pour ce cas. L'utilisateur décrit un retour brutal à l'écran Apple TV à l'ouverture de la fiche. La séquence indique une interruption près de la **présentation de la fiche Catalogue**, non une panne démontrée du flux WebRTC.
- Le rapport n'enregistre pas le motif natif de la fermeture ni Jetsam. `Lancement interrompu sans fermeture normale : non` et `Dernière étape : Aucune tentative enregistrée` sont cohérents avec l'absence de clic Jouer.

### Comparaison avec Red Dead Redemption 2

- Un journal antérieur (sans issue COD correspondante) a vu **RDR2 / Rockstar** passer par attribution machine, vidéo WebRTC active (~15:41:27), ICE connecté (~15:41:34) et fermeture de la vue de streaming enregistrée normalement (~15:41:37).
- Cela prouve qu'au moins une partie de la pile réseau/WebRTC a fonctionné à un instant donné, mais **ne prouve pas** une session RDR2 stable en jeu pendant longtemps.
- Attention : fermeture normale de l'écran de streaming ≠ preuve de terminaison de la session cloud Boosteroid distante.

### Correctif expérimental V2.4.8

- Branche `feature/v2.4.8-xbox-card-safe-mode`, PR https://github.com/thedjazairi28/BoosteroidATV/pull/6, Actions **#45037087776** : compilation **réussie**, pas de test matériel attesté.
- Mode `boosteroid.xboxCardSafeMode` **ON par défaut** uniquement pour les fiches Xbox. Dans ces fiches : image héro plein écran remplacée par un fond léger, pas de recherche publique Steam ni requête de détails Boosteroid facultative au moment de l'ouverture, mais titre, résumé existant, boutique et boutons Jouer/Favoris conservés.
- Préférence « **Mode léger des fiches Xbox** » dans Réglages → Sécurité du lancement pour activer/désactiver sans changement d'IPA.
- Traces supplémentaires : checkpoint avant `selectedGame = game`, `onAppear` de la fiche, début/fin des tâches facultatives, `onDisappear`, étapes de réseau ignorées en mode léger.
- Hypothèses : pression mémoire de l'image héro, appel facultatif ou cycle SwiftUI ; aucune cause racine démontrée. Si le mode léger corrige le cas, isoler ensuite par essais contrôlés le sous-composant fautif.
- **Ne pas publier V2.4.8 automatiquement avant test**. Préserver le streaming qui fonctionne parfois.

## 7 — Inventaire des évolutions par version

Les branches ci-dessous existent réellement à la date de l'instantané. La majorité ont compilé, mais plusieurs n'ont pas été validées sur matériel. Ne pas assimiler « branche disponible » à « fonctionnalité active dans l'app actuellement installée ».

| Version | Branche / fonction | Fait et statut |
|---|---|---|
| Base | `main` | Client BoosteroidTV natif tvOS, streaming WebRTC. Base testée sur Apple TV, autres modifications conservées séparément. |
| V1 | `feature/unified-catalog-v1` | Catalogue unifié (collections Boosteroid + bibliothèque), recherche et filtres Steam / Xbox / Epic, fiches « prêt à jouer » / « installation nécessaire ». Compilé. |
| V2 | `feature/v2-smart-experience` | Gestion de comptes Steam/Xbox/Epic/Rockstar stockés localement en Keychain, remplissage manuel des champs distants, profil SmartStreamOptimizer réactivité/qualité. Compilé, pas d'auto-login ni MFA. |
| V2.1 | `feature/v2.1-stability` | Limitation API HTTP 429, délai de scan de 5 minutes, catalogue après bibliothèque, onglet Comptes, corrections FR. Test Apple TV : lancement/catal. OK, mais enregistrement comptes, saisie iPhone et paramètres optimisations KO ; ligne rouge disparue sans causalité établie. |
| V2.2 | `feature/v2.2-multi-store-filters` | Filtres multi-boutiques, fiches enrichies, traduction UI française ; descriptions manquantes non inventées. Compilé, fonctions non exhaustivement validées. |
| V2.3 | `feature/v2.3-french-trailers` | Bandes-annonces muettes auto en fond de fiche, métadonnées Steam publiques, AVFoundation, résumé FR si disponible ; première version vidéo en échec sur appareil. |
| V2.3.1 | `feature/v2.3.1-video-diagnostics` | Diagnostics clips/Steam/AVPlayer, relance manuelle, ID public Steam 1174180 pour RDR2, en-têtes plus compatibles. |
| V2.3.2 | `feature/v2.3.2-hls-trailers` | Lecture HLS Steam H.264 `.m3u8` dans AVPlayer, secours MP4 ; retour utilisateur : HLS fonctionnait. |
| V2.3.3 | `feature/v2.3.3-clean-game-cards` | Suppression des diagnostics bruts/IDs Steam de l'affichage dans les fiches ; bouton « Réessayer » seulement si utile. |
| V2.4 | `feature/v2.4-gamepad-pointer` | Joystick droit comme souris en mode Pointeur, A/Croix = clic gauche, B/Rond = quitter, Start+Select = menu ; ne pas propager ces entrées au jeu. Compilé, tests matériel à préciser. |
| V2.4.1 | `feature/v2.4.1-launch-stability` | Transition avec libération lecteur HLS, prévention du double lancement. **Régression KO** signalée : retour brutal sur chaque jeu ; exclue des bases sûres. |
| V2.4.2 | `feature/v2.4.2-safe-launch` | Repart de V2.4 sans V2.4.1 ; vidéos d'aperçu OFF par défaut, guard de double lancement, checkpoints persistants. |
| V2.4.3 | `feature/v2.4.3-live-logs` | Journal live et persistant de 80 événements non sensibles, overlay, écran Diagnostics. |
| V2.4.4 | `feature/v2.4.4-github-reports` | Création manuelle de GitHub Issues via PAT Keychain sur Apple TV ; envoi de logs whitelistés. Validé fonctionnellement plus tard avec V2.4.6. |
| V2.4.5 | `feature/v2.4.5-prelaunch-trace` | Sélection fiche Catalogue/Accueil, clic Jouer et transitions enregistrés **avant** initialisation du stream ; nécessaire pour capturer crash pré-lecture. |
| V2.4.6 | `feature/v2.4.6-keychain-reliability` | Remplacement sécurisé PAT, lecture Keychain et vérification. **Installée/testée** sur Apple TV en version 2026.11.22.13 ; envoi Issues fonctionnel. Source de la Release .16. |
| V2.4.7 | `feature/v2.4.7-keychain-feedback` | Confirmation visuelle immédiate et statuts d'erreur Keychain explicites (alerte) ; compilée, non validée sur matériel. |
| V2.4.8 | `feature/v2.4.8-xbox-card-safe-mode` | Mode léger fiches Xbox, meilleurs diagnostics du crash Call of Duty ; compilation réussie #45037087776, **non testée sur Apple TV**. |
| V2.5 | `feature/v2.5-my-games-home` | Projet d'accueil « Mes jeux » (Reprendre, favoris, récent, possession manuelle) **indépendant** ; ne pas mélanger avec correctifs de crash. Les licences multi-store ne sont pas automatiquement vérifiées. |

### Historique des essais et idées explicitement non validées

- Un système d'auto-login des lanceurs n'a **pas** été démontré ; l'envoi est sur demande et peut être limité à des caractères ASCII selon le mode d'entrée, sans automatisation CAPTCHA/MFA.
- Les métadonnées souhaitées pour plus tard : année de sortie, genre, PEGI, modes solo/multi/coop, compatibilité manette, durée de campagne (source nécessaire). Ne pas inventer de données.
- Les optimisations dites « intelligentes » ne changent pas le GPU distant, le codec ou les FPS réellement négociés ; elles modifient les préférences demandées (par exemple 1080p pour FPS compétitif).
- Le catalogue n'est pas garanti exhaustif. L'API Boosteroid est susceptible de 429 et ses endpoints privés/non documentés doivent être traités prudemment.
- Les jeux « Installer et jouer » n'ont pas une procédure d'installation cloud pilotée séparément dans ces modifications : le client fait la demande de session habituelle.

## 8 — Architecture technique utile au diagnostic

- `MainTabView.swift` possède `selectedGame: GameInfo?` (fiche `GameOverviewView`), `pendingGameToPlay: GameInfo?`, `gameToPlay: GameInfo?` (StreamView), et des `.fullScreenCover` SwiftUI. Le clic Jouer sur la fiche mémorise le jeu et ferme la fiche, puis `onDismiss` appelle `launch(game)`.
- La V2.4.5 trace la sélection avant de présenter la fiche pour couvrir le cas Call of Duty, qui survient en amont de `launch()`.
- `GameOverviewView` dans `UI/HomeView.swift` peut déclencher à l'ouverture des `.task` facultatives : `loadGameDetails` (Boosteroid) et `loadPublicMedia` (Steam). Le fond peut être `AsyncImage` d'un grand visuel ou un trailer AVPlayer si activé. V2.4.8 neutralise ces activités pour les fiches Xbox.
- `GamesViewModel` : bibliothèques, catalogues, métadonnées, accès aux préférences de région et stream, chargeur médias publics, appels séquencés, protection anti-429.
- `LaunchTrace` dans `StreamView.swift` : tampon circulaire d'événements, encodés `UserDefaults`, persistance accélérée pour les jalons ; `DiagnosticGitHubReporter.swift` : création d'Issue à la demande via `POST /repos/{owner}/{repo}/issues` avec PAT local.
- `StreamView`, `BoosteroidClient`, `BoosteroidRealtimeClient`, `StreamController`, `SignalingClient`, `VideoSurfaceView` : chaîne source Boosteroid → création/attribution session → signaling/ICE WebRTC → flux vidéo/son → commandes manette/pointeur.
- `SmartStreamOptimizer` adapte les préférences de profil par catégorie de jeu ; éviter de modifier WebRTC tant que le crash observé se déroule avant la session.
- Une fermeture d'une vue SwiftUI peut arrêter l'affichage local sans arrêter la machine distante ; vérifier le bouton « Déconnecter », les appels de fin de session et l'état serveur.

## 9 — Risques et sécurité à garder visibles

1. **Confidentialité publique** : fork et Releases sont publics, ainsi que les rapports des Issues #4 et #5. Si l'utilisateur choisit un dépôt privé, organiser la migration proprement et vérifier accès atvloadly (token lecture seule), sans casser le suivi actif.
2. **Jetons** : l'ancien PAT GitHub a été exposé en clair dans un échange ; ne jamais le recopier ici, il doit être considéré compromis tant que sa révocation n'est pas démontrée. Ne pas mettre de PAT dans une IPA ou un secret GitHub Actions pour le besoin actuel.
3. **Keychain** : même équipe Apple/identité, bundle ID et entitlements ; risque de perdre l'accès à l'entrée après changement de signature, de Team ID, ou de mode de sideload. Ne pas désinstaller.
4. **Docker** : sauvegarder `/data` et état du conteneur avant opérations invasives ; interface localhost seulement, pas d'exposition externe.
5. **tvOS/crash** : `JetsamEvent`, pression mémoire, erreur Swift/AVFoundation hypothétiques ; ce qui compte est le rapport natif. Ne pas promettre une correction sans preuve.
6. **Cloud** : risque 429, files de sessions, redémarrages, session orpheline, latence. Conserver tests reproductibles et une version de retour arrière.
7. **Déploiement** : ne pas pousser toutes les compilations en Releases ; certaines branches sont KO/non testées. Risque de mise à jour automatique vers une version régressive pendant la nuit.

## 10 — Plan d'action recommandé à reprendre

**Priorité 1. Sécuriser le fonctionnement existant.** Sur Fedora, contrôler `docker ps`, politique restart, volume `/data`; utiliser l'API `/api/apps` pour vérifier source GitHub et version effectivement installée ; sur Apple TV, vérifier « Jeton présent » et un envoi Issue après première mise à jour automatique. Si la version a changé, conserver la preuve (captures et résultat d'API).

**Priorité 2. Diagnostiquer Call of Duty.** Tester V2.4.8 sur Apple TV sans diffuser en Release automatique au préalable (branche expérimentale avec build Actions) ; ouvrir « Call of Duty: Modern Warfare (Xbox) » depuis le catalogue ; si fermeture, ouvrir Réglages/Diagnostics et envoyer Issue ; regarder si `onAppear` de fiche a été atteint. Si pas suffisamment concluant, obtenir les logs tvOS natifs/Jetsam.

**Priorité 3. Stabiliser les parcours.** Tester un jeu Bibliothèque et un jeu « Installer et jouer », RDR2 et COD, avec et sans bande-annonce, mêmes conditions réseau et signature ; confirmer flux WebRTC et fin de session cloud réelle.

**Priorité 4. Contrôler distribution continue.** Une fois une version sûre validée, publier la branche testée via le workflow manuel avec version strictement croissante et constater sur atvloadly la détection, l'installation et la continuité du Keychain. La preuve d'un premier cycle autonome manque encore.

**Priorité 5. Reprendre les fonctions ensuite.** Comptes de jeux et saisie iPhone (anciens tests KO), commandes manette/pointeur, interface et métadonnées, V2.5 « Mes jeux » après stabilisation.

## 11 — URLs indispensables

- Fork : https://github.com/thedjazairi28/BoosteroidATV
- Source : https://github.com/luizhdramos/BoosteroidATV
- Releases : https://github.com/thedjazairi28/BoosteroidATV/releases
- Release actuelle : https://github.com/thedjazairi28/BoosteroidATV/releases/tag/v2026.11.22.16
- Workflow publication : https://github.com/thedjazairi28/BoosteroidATV/actions/workflows/publish-apple-tv.yml
- Workflow compilation branches (par chemin) : https://github.com/thedjazairi28/BoosteroidATV/blob/feature/v2.4.8-xbox-card-safe-mode/.github/workflows/build-unified-catalog.yml
- Crash COD : https://github.com/thedjazairi28/BoosteroidATV/issues/5
- Test diagnostic simple : https://github.com/thedjazairi28/BoosteroidATV/issues/4
- PR V2.4.8 : https://github.com/thedjazairi28/BoosteroidATV/pull/6
- PR V2.4.6 : https://github.com/thedjazairi28/BoosteroidATV/pull/3
- atvloadly amont : https://github.com/bitxeno/atvloadly
- atvloadly local **sur Fedora seulement** : http://localhost:5533

## 12 — Règle de mise à jour de ce dossier

Après chaque modification significative, ajouter à ce dossier : date, nouvelle branche/SHA, changement, compilation/run, test Apple TV oui/non, nouveau rapport ou ticket, Release publiable ou non, procédures de rollback, incidence signature/Keychain/atvloadly. Corriger les valeurs observées périmées en les marquant comme historiques plutôt qu'en les effaçant.