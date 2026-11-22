# Journal des mises à jour — BoosteroidATV (fork personnel)

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
| V2.2 — Filtres et fiches enrichies, interface FR (expérimental) | `feature/v2.2-multi-store-filters` | `e4b1ba3` | **Réussie** le 22/11/2026 | **Non testé sur Apple TV** |
| V2.1 — Stability | `feature/v2.1-stability` | `17df76b` | **Réussie** le 20/11/2026 | **3 OK, 3 KO** — 22/11/2026 (ligne rouge disparue, origine inconnue) |

**Important :** V2 inclut V1, V2.1 inclut V1 + V2, et V2.2 part de V2.1. La branche `main` conserve le code de base : **aucune des branches expérimentales n'est fusionnée dans `main`** à la date de ce journal.

## 22 novembre 2026 — V2.2 « Filtres multiples, fiches de jeux et français » (développement)

**Branche :** [feature/v2.2-multi-store-filters](https://github.com/thedjazairi28/BoosteroidATV/tree/feature/v2.2-multi-store-filters)  
**Comparaison avec V2.1 :** [diff V2.1 → V2.2](https://github.com/thedjazairi28/BoosteroidATV/compare/feature/v2.1-stability...feature/v2.2-multi-store-filters)  
**Compilation :** [premier build des filtres #45020911625](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45020911625) — **réussi** ; [build complet des filtres, fiches et français #45021265100](https://github.com/thedjazairi28/BoosteroidATV/actions/runs/45021265100) — **réussi**. Artifact : `BoosteroidATV-v2-2-multi-store-filters-unsigned` (ZIP contenant l'IPA) ; expiration GitHub **29 novembre 2026**.  
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

### Interface en français

- Traduction des **libellés de l'accueil, de la bibliothèque, de la connexion, des paramètres et des commandes de streaming**.
- Réécriture de la page **Aide** en français, y compris l'explication du mode pointeur avec la Siri Remote.
- Traduction des principaux messages d'erreur d'authentification et des états de préparation visibles.
- **Limite de périmètre :** les noms de jeux, les résumés d'origine renvoyés par Boosteroid (éventuellement en anglais), les noms de boutiques et l'interface du PC distant (Steam / lanceurs / jeux) ne sont **pas traduits automatiquement**. Aucune API de traduction externe n'a été ajoutée.


### Limitations et validation nécessaire

- Vérifier l'ouverture des nouvelles fiches de jeu, les résumés et le rendu sans débordement sur Apple TV.
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

**Expiration annoncée par GitHub : 27 novembre 2026 pour V1/V2/V2.1 ; 29 novembre 2026 pour V2.2.** Après expiration, relancer un build ou publier un fichier dans **Releases** pour disposer d'un téléchargement plus durable. Aucun Release propre à ce fork n'a été trouvé lors de la rédaction.

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
