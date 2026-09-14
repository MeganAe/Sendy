# Correction du build macOS — SDK Xcode

Les deux journaux fournis montrent la même erreur bloquante : `NWPath` ne contient pas `isUltraConstrained` dans le SDK macOS 15.5 livré avec Xcode 16.4. `connectivity_plus 7.3.1` référence une API du SDK macOS 26. Le test Swift `#available` vérifie la disponibilité à l’exécution, pas l’existence de cette déclaration dans un ancien SDK.

Le job macOS choisit maintenant explicitement Xcode **26.3** via `DEVELOPER_DIR`, pour toutes ses étapes et pour les deux architectures. Un contrôle affiche Xcode, Swift et le SDK, puis refuse un SDK inférieur à 26. Les manifestes actuels des runners Intel et ARM64 listent Xcode 26.3 :

- https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md
- https://github.com/actions/runner-images/blob/main/images/macos/macos-15-arm64-Readme.md

Aucun changement des dépendances, des jobs Windows/Android/Linux ou de la version minimale macOS de l’application. Compiler avec un SDK récent ne signifie pas imposer macOS 26 aux utilisateurs. La compatibilité réelle de l’application reste à tester sur les systèmes pris en charge.

Les messages sur les 94 paquets plus récents, les API dépréciées et l’optionalité Swift sont des avertissements, pas la cause de cet arrêt. Les avertissements sur le manifeste de confidentialité méritent une vérification distincte avant distribution.

## Appliquer

Remplacer `.github/workflows/build-installers.yml` dans le dépôt existant par le fichier corrigé, puis créer un commit. Lancer une **nouvelle exécution** de Sendy — Build installers sur la branche mise à jour, avec macOS activé et les autres plateformes désactivées si inutile. Ne pas simplement relancer l’ancienne exécution : elle utilise son ancien commit.

La correction cible précisément l’erreur fournie. La syntaxe du workflow est validée localement ; la compilation Xcode ne peut être exécutée dans cet environnement Linux et son succès reste à confirmer sur GitHub. Les journaux de build restent conservés en artefacts.
