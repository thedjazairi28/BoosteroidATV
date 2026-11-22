# Rapports d'erreur BoosteroidATV v2.4.4 — GitHub Issues

## Objectif

Lorsqu'une session ferme l'application et revient au menu tvOS, les événements
du journal V2.4.3 subsistent dans les préférences locales. La V2.4.4 permet
de **les envoyer volontairement** sous forme d'Issue GitHub, lisible via la
connexion GitHub de ChatGPT. Aucun serveur personnel n'est nécessaire.

## Préparer la destination (une seule fois)

1. **Recommandé :** créer un dépôt GitHub **privé** (ex. `thedjazairi28/boosteroidatv-diagnostics`) et activer les Issues. Alternative : utiliser `thedjazairi28/BoosteroidATV`, mais **les rapports y seront publics**.
2. Dans GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens, créer un jeton limité **uniquement** au dépôt de destination, avec la permission Repository permissions → **Issues: Read and write**. Choisir une durée de validité courte. Ne pas donner `Contents: write`, administration ou accès global.
3. Depuis l'Apple TV : BoosteroidATV → **Réglages → Diagnostics** → saisir le dépôt au format `propriétaire/nom`, coller le jeton via le clavier distant/iPhone, puis sélectionner **Enregistrer le jeton**. Le jeton est stocké dans le Keychain de l'Apple TV et non dans les préférences.
4. Dans Diagnostics, vérifier que **Journal de lancement à l'écran** est activé, et laisser **Aperçus vidéo animés** désactivé pour les premiers essais.

## Après la fermeture d'un jeu

1. Relancer BoosteroidATV sur l'Apple TV.
2. Ouvrir Réglages → Diagnostics ; noter le checkpoint affiché et les derniers événements.
3. Appuyer sur **Envoyer un rapport d'erreur**. L'application transmet les 80 derniers événements, la version/build, la version tvOS et le checkpoint, sans données d'authentification Boosteroid.
4. Si tout fonctionne, le numéro et le lien du ticket GitHub s'affichent. Donner son numéro dans le chat (« Analyse l'Issue #NN du dépôt … »), ou demander l'analyse des dernières Issues. ChatGPT ne surveille pas le dépôt en permanence ; une demande dans le chat déclenche la lecture.
5. Répéter séparément avec un jeu **Jouer** (Bibliothèque) et un jeu **Installer et jouer** (Catalogue). Comparer les dernières étapes.

## Limitations de sécurité et de diagnostic

- **Jamais de mot de passe GitHub dans le code ni de token Boosteroid dans les rapports.** Le jeton GitHub utilisé par l'Apple TV est un PAT personnel et non un secret embarqué dans le dépôt.
- Le journal existant n'enregistre que les jalons prédéfinis et un titre de jeu tronqué. L'envoi masque aussi les URL, courriels et champs suspects. Vérifier néanmoins le contenu des événements avant envoi. GitHub conserve les Issues jusqu'à suppression ; si le dépôt est public, le contenu est public.
- La permission `Issues: Read and write` ne doit être accordée qu'à un dépôt de diagnostic ; malgré la sauvegarde en Keychain, un client modifié/compromis peut utiliser le jeton local. Révoquer le PAT après diagnostic.
- **L'envoi est manuel**, pas automatique : il ne fonctionne pas si l'Apple TV est hors réseau ou si GitHub est indisponible. L'application conserve les logs jusqu'au prochain envoi/effacement.
- Un crash natif `EXC_BAD_ACCESS` ou un `JetsamEvent` ne peut pas être attrapé par du Swift : l'absence de la dernière ligne n'est pas une preuve de la cause. Récupérer les rapports système via Xcode → Devices and Simulators → View Device Logs ou les analytics tvOS si accessibles.
- Cette version fournit de l'observabilité ; **elle n'affirme pas corriger** les fermetures du moteur WebRTC.
- Une compilation GitHub Actions réussie ne suffit pas : tester la création réelle d'Issue depuis tvOS.
