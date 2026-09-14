> Mise à jour : consulter [les correctifs 0.1.1](SENDY-0.1.1-CORRECTIFS.fr.md), notamment avant de remplacer Sendy sur Windows.

# Sendy — construire les installateurs sur GitHub

## Démarrer

Ce projet est prêt à être envoyé dans votre propre dépôt GitHub pour une première compilation. Il n'est pas encore publié et aucune exécution GitHub n'a été lancée depuis ce workspace.

Dans votre dépôt : **Actions → Sendy — Build installers → Run workflow**. Les cases Windows, macOS, Linux et Android permettent de limiter les builds aux plateformes nécessaires.

Le job `Validate Sendy UI` vérifie les identifiants, teste la structure du packaging Linux, analyse l'application Flutter et exécute les tests Sendy. Les installateurs ne sont produits qu'après sa réussite. Chaque build doit également réussir ; la présence du fichier de sommes de contrôle ne garantit pas que toutes les plateformes ont réussi.

Les artefacts expirent après 14 jours. Ils ne sont pas publiés automatiquement sur un store ou dans GitHub Releases. Les noms commencent par `Sendy-0.1.1-…`.

## Ce qui est produit

- Windows x64 : installateur Inno Setup par utilisateur dans `%LOCALAPPDATA%\Programs\Sendy`, désinstallation incluse ; archive portable distincte avec son propre `sendy-settings.json`.
- macOS Intel et Apple Silicon : DMG avec raccourci Applications, PKG installé dans `/Applications`.
- Linux x64 et ARM64 : DEB sous `/opt/sendy`, raccourci `sendy`, entrée de menu et icône ; TAR.GZ contenant le bundle Flutter complet.
- Android : APK séparés ARMv7, ARM64 et x86_64.
- Empreintes SHA-256 regroupées dans un artefact supplémentaire.

Linux vise les distributions compatibles avec les dépendances Ubuntu 22.04+. Le TAR.GZ n'est pas une AppImage autonome : GTK, AppIndicator et les autres bibliothèques système restent nécessaires. Les recettes RPM/AppImage originales ne sont pas activées dans cette première version Sendy. Windows ARM64 natif, iOS et les stores ne sont pas inclus.

## Signature Android

### Test — sans secrets

Choisir `android_signing: test`. Une clé temporaire est créée, puis supprimée. L'application utilise `app.sendy.transfer.test`, distinct de la version durable, pour ne pas remplacer cette dernière.

Une nouvelle exécution crée une nouvelle clé : pour installer un nouveau test, il peut être nécessaire de désinstaller le précédent, ce qui peut supprimer ses données. Ne jamais publier ces APK comme une version durable. Le nom affiché est Sendy dans les deux variantes ; se référer à l'identifiant et au nom du fichier pour les distinguer.

### Release — clé privée durable

Créer et conserver une clé sur une machine de confiance avec Java :

```bash
keytool -genkeypair -v -keystore sendy-release.jks -storetype JKS \
  -alias sendy -keyalg RSA -keysize 2048 -validity 10000
```

Ne pas ajouter cette clé au dépôt. Sauvegarder le fichier et les mots de passe de manière privée et sécurisée. Ne pas les transmettre dans une conversation.

Dans **Settings → Secrets and variables → Actions**, ajouter :

| Secret | Valeur |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Contenu base64 du JKS |
| `ANDROID_KEYSTORE_PASSWORD` | Mot de passe du keystore |
| `ANDROID_KEY_ALIAS` | Alias de clé, par exemple `sendy` |
| `ANDROID_KEY_PASSWORD` | Mot de passe de la clé |

Linux/macOS : `base64 < sendy-release.jks`.

PowerShell : `[Convert]::ToBase64String([IO.File]::ReadAllBytes('sendy-release.jks'))`.

Relancer avec `android_signing: release`. L'identifiant sera `app.sendy.transfer`. Si un secret manque, le workflow échoue sans utiliser une clé de test en remplacement. Incrémenter le numéro après `+` dans `app/pubspec.yaml` pour les futures mises à jour Android. Le projet conserve la numérotation par ABI héritée du protocole de packaging original : distribuer à un appareil la même variante d'architecture à chaque mise à jour.

## Windows et Mac sans budget de certification

- Windows : aucun certificat éditeur configuré. Les avertissements SmartScreen sont possibles. Le helper MSIX signé de LocalSend n'est ni embarqué ni enregistré. L'intégration « Envoyer vers » classique reste indépendante sous le nom Sendy.
- macOS : signature ad hoc, pas de Developer ID et pas de notarisation. Gatekeeper peut bloquer l'ouverture. Ne pas désactiver globalement les protections de l'ordinateur.
- L'extension de partage macOS est exclue des paquets ad hoc, car elle nécessite votre propre groupe applicatif Apple. Le code de l'application utilise un stockage standard lorsqu'aucune équipe Apple n'est configurée. Le glisser-déposer dans la fenêtre principale reste une fonction distincte.
- Les circuits payants de signature Windows et Developer ID/notarisation Apple ne sont pas configurés. Ils ne peuvent pas être remplacés par une astuce dans le workflow.

## Identité et limites

Les identifiants, noms natifs, icônes, AppId Inno, raccourcis et chemins actifs sont adaptés à Sendy. Le fichier `support/branding/sendy.json` les récapitule. La disponibilité du nom/de la marque dans le commerce et les stores reste à vérifier avant publication.

Les noms internes de packages, certains fichiers techniques et les URL de protocole restent ceux de LocalSend pour préserver le fonctionnement. Les scripts/workflows originaux et les métadonnées de stores historiques sont des références **non activées**. Ne pas les utiliser pour publier Sendy.

La politique de confidentialité du projet d'origine est présentée comme telle dans les réglages, pas comme une politique Sendy validée. Une politique propre et des coordonnées de support devront être définies avant une distribution publique. Aucun compte de paiement Sendy n'est configuré ; l'entrée de dons et l'initialisation des achats ont été désactivées pour cette version.

## Contrôles locaux et validation finale

Les 19 tests ciblés passent et les nouveaux composants ne présentent pas de problème d'analyse ciblée. Le packaging DEB/TAR a été vérifié avec un **faux exécutable de test**, pas avec une application compilée. La validation du graphe Flutter complet a épuisé la mémoire du sandbox ; le log est conservé pour transparence. Elle doit réussir sur GitHub avant de considérer les builds valides.

Voir `RELEASE-CHECKLIST.fr.md` pour les essais sur appareils.
