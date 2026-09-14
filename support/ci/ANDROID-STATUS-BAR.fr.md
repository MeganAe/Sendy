# Correctif de contraste de la barre d’état Android

La barre d’état est la zone système qui affiche heure, batterie, réseau et notifications. Sur la capture fournie, plusieurs éléments sont sombres sur un fond sombre.

Le correctif définit explicitement le style de superposition de l’AppBar, notamment pour Yaru, et ajoute une région réactive au thème pour les écrans sans AppBar. La couleur des icônes est choisie selon le contraste avec la surface de fond réelle. La barre reste transparente et les marges système existantes restent inchangées. Aucun forçage du mode clair/sombre de l’application ni changement du thème Yaru.

## Installation dans les sources

Ce correctif se superpose aux sources Sendy 0.1.1 et au lot de développement des colis. Copier le contenu de l’archive à la racine du dépôt existant, en respectant les sous-dossiers. Les trois fichiers d’exécution nécessaires sont :

- `app/lib/config/sendy/sendy_system_bars.dart` (nouveau) ;
- `app/lib/config/theme.dart` ;
- `app/lib/main.dart`.

Les tests et ce guide sont également fournis. Enregistrer les modifications dans GitHub, faire réussir les contrôles, puis lancer une nouvelle compilation Android et installer l’APK produit. Aucun correctif de source ne modifie l’APK déjà installé.

Ne pas désinstaller l’ancienne application à l’aveugle si Android signale une signature incompatible : conserver les données et vérifier d’abord la configuration des clés de signature.

## Validation

- 5 tests ciblés réussis : surfaces claires/sombres, Yaru, surfaces personnalisées, changement de thème et AppBar explicite.
- Analyse ciblée du composant et de ces tests : aucun problème.
- Test supplémentaire du vrai `getTheme` ajouté à la suite d’intégration exécutée sur GitHub ; non exécuté localement car il charge le graphe applicatif complet.
- Aucun essai sur le téléphone de l’utilisateur n’a encore été réalisé. Vérifier Envoyer, Recevoir, Réglages et le retour du sélecteur de fichiers, en mode clair et sombre. Tester également le passage automatique au mode sombre.

Le système peut conserver ses propres couleurs d’alerte, par exemple pour une batterie faible. Le correctif concerne le contraste demandé par Sendy, pas le remplacement des icônes Android.
