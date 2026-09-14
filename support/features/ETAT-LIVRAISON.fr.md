# État exact du projet regroupé

Cette archive contient les sources complètes du projet à cet instant. Elle n'est PAS une livraison finale des cinq fonctionnalités demandées.

## Correctifs présents

- Installation/réglages indépendants de LocalSend, port HTTP 53318 et découverte UDP 53317.
- Yaru par défaut, identité Sendy et développeur Metoushela Walker.
- Correctifs macOS : Xcode 26.3 explicitement sélectionné et arguments de `lipo` remis dans le bon ordre.
- Contraste de la barre d'état Android.
- Diagnostic et protection du stockage fichier.
- Correction des captures les plus récentes : titre et entrée des paramètres « À propos de Sendy », pied de page « Développé par Metoushela Walker ».
- Auteur et copyright du projet original conservés dans la page de crédits, et notices de licence conservées.

## Fonctionnalités nouvelles : état réel

| Fonction demandée | État |
| --- | --- |
| Colis par références | Première implémentation : enregistrer, vérifier, recharger, supprimer la liste ; suivi par destinataire et remplacement guidé des références non terminés |
| Classement automatique | Non implémenté |
| Contrôle de réception enrichi | Non implémenté ; confirmation par défaut et sélection de fichiers existante conservées |
| Connexion par QR | Non implémentée |
| Reprise des transferts interrompus | Non implémentée |

Une compilation de ces sources ne peut pas faire apparaître les fonctions manquantes. Elles nécessitent encore du code et des tests, notamment l'évolution sécurisée du protocole de reprise.

## Validation

46 tests ciblés passent localement. Analyse ciblée des nouvelles règles de libellés : aucun problème. Ces résultats ne valident pas l'intégralité du graphe Flutter, les installateurs ni tous les systèmes d'exploitation. Les contrôles complets doivent être exécutés sur GitHub, puis des essais sur appareils restent nécessaires.

## Mettre à jour

Sauvegarder le projet actuel. Copier tout le contenu du dossier `sendy` extrait dans la copie du dépôt, sans créer un sous-dossier `sendy`. Inclure `.github` et conserver `.git`. Enregistrer un nouveau commit, lancer Source checks puis une nouvelle compilation, et installer le nouvel artefact. Ne pas distribuer ce lot comme la version finale aux cinq fonctions.
