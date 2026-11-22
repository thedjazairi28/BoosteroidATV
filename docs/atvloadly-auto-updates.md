# BoosteroidATV — Mises à jour via GitHub Releases + atvloadly

## État actuel (22 novembre 2026)

- Le workflow [Publish approved Apple TV release](../.github/workflows/publish-apple-tv.yml) est disponible sur `main` via Actions → Run workflow.
- Il publie **uniquement à la demande** une version testée, jamais chaque commit expérimental.
- Le workflow compile l'IPA tvOS **non signée**, puis la joint à une GitHub Release. **Aucune identité Apple / mot de passe / PAT GitHub personnel n'est embarqué dans l'IPA**.
- Le conteneur atvloadly sur Fedora signe ensuite l'IPA et installe les mises à jour depuis GitHub Releases.
- Une compilation GitHub Actions réussie ne prouve pas le comportement de l'application sur Apple TV.

## 1. Vérifier Fedora, sans changer l'appairage existant

```bash
sudo systemctl enable --now docker
docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

Si le conteneur s'appelle `atvloadly` :

```bash
docker update --restart unless-stopped atvloadly
docker inspect atvloadly --format '{{range .Mounts}}{{println .Destination .Source}}{{end}}'
```

**Important** : le montage `/data` doit être persistant. Ne supprimez pas le conteneur ou son volume sans sauvegarde (comptes et appairage). Le conteneur doit être accessible sur le LAN local uniquement ; atvloadly n'a pas de connexion utilisateur/authentification propre.

## 2. Publier UNE version validée

Dans GitHub → **Actions** → **Publish approved Apple TV release** → **Run workflow** :

- `source_ref` : branche `feature/...` réellement testée sur Apple TV, ou SHA de commit sur 40 caractères.
- `release_version` : nouvelle version numérique, par exemple `2026.11.22.16`. Elle doit être unique et strictement plus grande que la version installée.
- `confirmation` : `PUBLISH`.

Le workflow valide les paramètres, compile, et publie une release publique avec un seul fichier `BoosteroidATV-<version>.ipa` non signé. Les builds précédents des branches GitHub Actions (Artifacts) ne sont **pas** des GitHub Releases et ne peuvent pas être suivis comme source.

**Ne publier que les versions approuvées.** Le crash de la fiche Call of Duty (Xbox) fait actuellement l'objet de l'[issue #5](https://github.com/thedjazairi28/BoosteroidATV/issues/5) et de la branche expérimentale V2.4.8 ; ne pas en faire une version automatique tant que le test matériel n'est pas satisfaisant.

## 3. Associer la source à l'app existante dans atvloadly

1. Ouvrir atvloadly sur Fedora (port souvent `5533`, à confirmer dans `docker ps`).
2. Sur la page d'accueil, retrouver l'application **BoosteroidATV** sous l'Apple TV déjà appairée.
3. Utiliser l'action **Track updates** sur l'application existante (plutôt que réinstaller une seconde application).
4. Choisir **GitHub Releases** comme source, avec le dépôt public :
   `https://github.com/thedjazairi28/BoosteroidATV`.
5. Laisser les préversions exclues par défaut ; activer **Install updates automatically** une fois la première release approuvée disponible. Activer séparément l'actualisation/renouvellement automatique des signatures Apple ID si cette option existe dans les réglages.
6. Vérifier au premier cycle que l'application mise à jour garde le même identifiant, la même identité de signature et l'accès au jeton GitHub stocké dans le Keychain tvOS.

Selon la version d'atvloadly, les libellés exacts peuvent varier. Référence : https://github.com/bitxeno/atvloadly ; https://github.com/bitxeno/atvloadly/blob/master/docs/external-certificate.md

## Limitations

- Fedora/Docker doit être allumé et l'Apple TV joignable pendant l'installation. Si Fedora est hors ligne, les mises à jour attendent la prochaine reprise du service.
- Une mise à jour tvOS ou un nouvel appairage peut nécessiter une intervention humaine.
- Pour les comptes Apple gratuits, les applications de développement doivent être régulièrement resignées. L'actualisation automatique est un mécanisme distinct du suivi des releases.
- Changer d'Apple ID/Team ID, de signature ou d'identifiant d'application peut rendre le Keychain précédent inaccessible et donc faire perdre le jeton GitHub.
- Ne jamais exposer atvloadly directement à Internet. Un accès distant doit passer par une solution privée avec contrôle d'accès.
