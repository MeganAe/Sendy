# Identité Sendy

`sendy.json` récapitule les identifiants d'installation et la palette. `sendy-icon.svg` et `sendy-mark.svg` sont les masters vectoriels exportables. Les icônes générées sont déjà intégrées au projet ; aucun service externe n'est nécessaire au lancement de l'application.

Pour régénérer les icônes depuis la racine du dépôt :

```bash
python3 -m pip install -r support/branding/requirements.txt
python3 support/branding/generate_icons.py
python3 support/ci/check_branding.py
```

Environnement de référence : Linux avec Cairo et DejaVu Sans Bold (bannière Android TV). Sur un autre système, installer Cairo si nécessaire ; une police de repli est utilisée pour la bannière si DejaVu est absente. Le symbole est dessiné en vectoriel et ne dépend pas de cette police.

Les chemins du dessin sont reproduits dans `app/lib/widget/sendy/sendy_logo.dart` pour un rendu Flutter sans image bitmap. Si le dessin change, synchroniser ces chemins avec le script et les SVG.

Modifier uniquement `sendy.json` ne réécrit pas automatiquement tous les fichiers natifs : adapter également les fichiers ciblés par `support/ci/check_branding.py`. Ce contrôle signale les incohérences.

La disponibilité juridique du nom et de ses identifiants commerciaux n'a pas été vérifiée. Les icônes ne confèrent aucun droit sur les marques LocalSend ou Xender.
