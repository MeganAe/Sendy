# Envoyer cette archive dans votre dépôt GitHub

L'archive `Sendy-0.1.0-source.zip` contient les sources, pas les installateurs compilés. Elle ne contient ni historique Git, ni SDK Flutter, ni clé privée. Elle inclut le dossier caché `.github` et les ressources nécessaires dans `support/build`.

1. Créer un nouveau dépôt sur votre compte GitHub, par exemple `sendy`.
2. Décompresser l'archive. Ouvrir un terminal dans le dossier `sendy` extrait.
3. Exécuter les commandes ci-dessous en remplaçant `TON_COMPTE` par votre compte. Git doit être installé, mais aucune compilation locale n'est nécessaire.

```bash
git init -b main
git add .
git commit -m "Sendy 0.1.0 - initial source"
git remote add origin https://github.com/TON_COMPTE/sendy.git
git push -u origin main
```

GitHub vous demandera de vous authentifier via votre outil Git. Ne collez jamais votre mot de passe, token ou clé privée dans une conversation. Si Git demande votre nom/email pour le commit, configurer ces informations avec les valeurs de votre choix avant de réessayer.

4. Ouvrir **Actions** et autoriser les workflows si demandé.
5. Faire réussir **Sendy — Source checks**.
6. Lancer **Sendy — Build installers** manuellement, en mode Android `test` pour commencer.

Les contrôles peuvent révéler des problèmes de toolchain ou de compilation que les tests ciblés locaux ne détectent pas. Dans ce cas, conserver le journal du premier job en échec pour le diagnostiquer avant de distribuer quoi que ce soit.
