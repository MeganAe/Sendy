> **Mise à jour macOS :** les journaux ont identifié un SDK Xcode trop ancien. Le workflow sélectionne maintenant Xcode 26.3. [Diagnostic et correction](MACOS-SDK-FIX.fr.md). Les mentions « cause inconnue » ci-dessous décrivent l’état précédent ; la nouvelle compilation reste à confirmer sur GitHub.

# Sendy 0.1.1 — isolation, auteur, Yaru et diagnostics

## Défaut confirmé dans la version 0.1.0

Malgré un installateur et des identifiants natifs distincts, le stockage Windows utilisait encore `%APPDATA%\LocalSend\settings.json`. L'ancien import du dossier `%APPDATA%\org.localsend` était également actif. Cela pouvait partager/modifier les réglages, certificats et jetons de détection d'instance avec LocalSend. Le fichier portable générique `settings.json` pouvait aussi être commun si deux exécutables étaient déposés dans le même dossier.

L'ancienne migration pouvait modifier ou supprimer un dossier de préférences hérité. Nous ne pouvons pas déterminer à distance si elle l'a fait sur votre PC, ni réparer des fichiers déjà modifiés sans les examiner. Les sources 0.1.1 ne touchent plus ces emplacements.

## Correction

- Exécutable installé dans `%LOCALAPPDATA%\Programs\Sendy`.
- Réglages Windows exclusivement dans `%APPDATA%\Sendy\settings.json`.
- Portable : `sendy-settings.json` à côté de l'exécutable.
- Aucun import automatique, déplacement ni suppression des préférences LocalSend.
- Nouvelle identité TLS et nouveau jeton générés dans le dossier Sendy neuf sur Windows. Les données du dossier partagé ne sont pas copiées, car leur propriétaire ne peut pas être déterminé de façon fiable.
- Serveur HTTP/TLS Sendy : **53318 par défaut**. Le multicast reste sur **UDP 53317**, indépendamment du port HTTP annoncé. Les appareils qui utilisent encore le port HTTP 53317 peuvent toujours être découverts par multicast. Cela doit être vérifié sur les appareils réels et leurs pare-feu.
- Réglage personnalisé de port conservé, sauf ancien 53317 sur desktop migré une fois vers 53318 pour la coexistence.
- Aides de pare-feu mises à jour pour distinguer TCP et UDP.
- Installation sans réutilisation d'un ancien chemin choisi. L'installateur refuse un dossier contenant `localsend_app.exe`.

## Auteur et apparence

L'écran À propos affiche **Développé par Metoushela Walker**, avec le dépôt `MeganAe/Sendy`. Le champ éditeur de l'installateur et les métadonnées Windows sont également adaptés. Les attributions et licences du moteur original restent dans une page de crédits séparée ; elles ne sont pas supprimées.

**Yaru devient le thème par défaut.** Le passage depuis l'ancienne palette Sendy est fait une seule fois. Les thèmes explicitement personnalisés, système et OLED sont conservés. Le logo garde sa couleur de marque. La suppression générale des références LocalSend est reportée, conformément à la demande ; les traductions existantes et les attributions sont conservées. Les règles de pare-feu utilisent des noms Sendy distincts.

## Nouvelles fonctions

Dans Réglages → **Diagnostic Sendy** :

- version, identifiant, ports, état réel de réception et emplacement des réglages quand disponible ;
- ouverture du dossier de données Sendy ;
- test TCP local explicite (il indique qu'un service répond, pas que son identité est authentifiée) ;
- copie d'un rapport limité à des champs autorisés, sans alias, IP, chemins personnels, noms de fichiers, PIN, jetons ou clés privées.

Le stockage fichier Windows/portable utilise une écriture temporaire suivie d'un renommage, avec sauvegarde du précédent état dans `.bak`. Un JSON malformé déclenche une erreur au lieu d'être remplacé silencieusement. **Ces fichiers et sauvegardes contiennent des informations privées, dont l'identité TLS : ne pas les publier.** La sauvegarde n'est pas un export chiffré et ne remplace pas une sauvegarde personnelle sécurisée.

## Avant installation sur le PC concerné

1. Terminer les transferts en cours.
2. Quitter entièrement Sendy 0.1.0 via la zone de notification. Fermer simplement la fenêtre peut la laisser active.
3. Sauvegarder en privé les dossiers `%APPDATA%\LocalSend` et `%APPDATA%\org.localsend` s'ils existent, sans les supprimer ni les écraser.
4. Essayer d'ouvrir LocalSend seul. S'il échoue encore, relever sa version et son message d'erreur avant toute réinitialisation. Les correctifs Sendy ne restaurent pas automatiquement des préférences précédemment modifiées.
5. Envoyer les sources 0.1.1 dans votre dépôt, faire réussir les contrôles et reconstruire Windows. L'APK Android actuel peut rester installé pour le premier essai.
6. Installer la nouvelle version Sendy après fermeture de l'ancienne. Vérifier le dossier dans Diagnostic Sendy et les deux applications ouvertes simultanément.

Ne pas installer une version portable dans le dossier de LocalSend. Ne pas copier automatiquement l'ancien `settings.json` partagé vers Sendy : cela réintroduirait son identité et ses réglages.

## macOS : reste à diagnostiquer

L'exécution GitHub `34783522684` montre un échec **Build macOS** sur Intel et Apple Silicon. Les annotations accessibles publiquement donnent seulement le code de sortie 1 ; le journal complet nécessite une connexion GitHub.

Aucune cause macOS précise n'est confirmée et cette version **ne prétend pas corriger cet échec**. Le workflow sauvegarde désormais `sendy-macos-build-log-<architecture>` même après un échec de compilation, lorsque le fichier de log existe.

Pour diagnostiquer l'exécution déjà échouée : ouvrir le job Mac, déplier **Build macOS**, copier le premier message d'erreur et les lignes qui l'entourent (pas seulement `Process completed with exit code 1`).

## Validation

31 tests locaux ciblés réussis, dont stockage isolé, portable, sauvegarde, corruption préservée et politique Yaru. Analyse ciblée des nouvelles règles et du stockage : aucun problème. Les contrôles de branding et le packaging Linux sur fixtures passent. La séparation du transport multicast et du port HTTP est codée dans le pont Rust, sans changer la signature FFI.

Les tests ne constituent pas une validation de coexistence sur votre PC. La compilation complète 0.1.1, le nouveau pont Rust, les essais réseau et les nouvelles pages doivent encore être validés sur GitHub puis sur appareils. Les succès GitHub précédents concernaient 0.1.0 après correction de l'import NavigateAction.
