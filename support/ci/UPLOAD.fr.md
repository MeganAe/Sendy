# Mettre à jour le dépôt existant MeganAe/Sendy

L’archive `Sendy-0.1.1-source.zip` contient les **sources**, pas un installateur déjà compilé. Aucune compilation locale n’est nécessaire. Elle inclut le dossier caché `.github` et les ressources de `support/build`, sans SDK, clé privée ou historique Git.

## Si vous avez déjà une copie Git du dépôt

1. Sauvegarder vos éventuelles modifications locales et faire `git pull`.
2. Décompresser l’archive dans un autre dossier.
3. Copier **le contenu du dossier `sendy`** extrait dans votre copie du dépôt `MeganAe/Sendy`, en remplaçant les fichiers existants. Inclure les fichiers cachés, notamment `.github`. Ne pas placer le dossier `sendy` entier comme sous-dossier du dépôt. Ne pas supprimer votre dossier `.git`.
4. Dans le terminal de cette copie Git :

```bash
git status
git add .
git commit -m "Sendy 0.1.1: isolated settings, Yaru and diagnostics"
git push
```

## Si vous n’avez pas encore de copie Git

Avec Git ou GitHub Desktop, cloner **le dépôt existant** `https://github.com/MeganAe/Sendy`, puis suivre les étapes de copie ci-dessus. Il n’est pas nécessaire de créer un autre dépôt ou de forcer un push.

```bash
git clone https://github.com/MeganAe/Sendy.git
cd Sendy
```

Ne pas envoyer simplement le ZIP dans GitHub : les workflows ont besoin des fichiers extraits à la racine. GitHub demande l’authentification dans votre outil Git ; ne jamais partager vos identifiants, tokens ou clés privées dans une conversation.

## Compilation

1. Faire réussir **Sendy — Source checks** dans Actions. Si cela échoue, transmettre le premier message d’erreur et les lignes voisines.
2. Lancer **Sendy — Build installers**. Pour tester l’isolation rapidement, sélectionner Windows seul : l’APK Android actuellement installé peut rester inchangé.
3. Télécharger le nouvel installateur dans les artefacts. Lire [les précautions Windows](SENDY-0.1.1-CORRECTIFS.fr.md) avant son installation.
4. Tester LocalSend et Sendy en parallèle, puis un transfert vers votre Android.

**macOS reste à diagnostiquer.** Fournir les lignes de l’erreur dans **Build macOS** de l’exécution existante, ou télécharger le nouvel artefact `sendy-macos-build-log-<architecture>` après une reconstruction avec ce workflow. La collecte du log n’est pas une correction du compilateur.

Les sources dans cette archive ne sont pas automatiquement publiées sur votre GitHub.
