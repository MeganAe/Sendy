# Mise à jour 0.1.1 — état actuel

Le bilan 0.1.0 ci-dessous est conservé comme historique. **Son affirmation d’isolation des réglages Windows était incomplète et incorrecte** : le chemin `%APPDATA%\LocalSend` et la migration héritée restaient actifs. Le défaut a été confirmé puis corrigé en 0.1.1.

Voir [le rapport 0.1.1](support/ci/SENDY-0.1.1-CORRECTIFS.fr.md) pour le stockage séparé, le nouveau fichier portable, le port HTTP 53318 / UDP 53317, Yaru par défaut, l’auteur Metoushela Walker, le diagnostic et les sauvegardes de réglages.

**31 tests ciblés passent.** Compilation complète et coexistence réelle restent à tester. L’échec macOS n’est pas encore diagnostiqué ; seul son emplacement `Build macOS` est connu.

---

# Sendy 0.1.0 — état de finalisation

## Résultat

Le code de cette première version Sendy, son identité native et son pipeline d'installateurs sont finalisés **pour une première compilation sur GitHub**. Ce n'est pas encore une version de production validée : les builds natifs et les essais entre appareils restent à effectuer.

## Application

- Thème bleu nuit/ivoire, variantes claire et sombre, cartes et contrôles arrondis.
- Logo vectoriel Flutter reconstruit à partir de la direction approuvée ; lettrage via la typographie de l'application, pas une police de marque exclusive.
- Envoyer : sélection de fichiers réellement reliée à `PickFileAction`, autres sélecteurs conservés selon la plateforme, glisser-déposer et disposition à deux colonnes sur grande fenêtre.
- Appareils : cartes, gestion des noms longs et apparition en fondu de 220 ms. Aucune liste d'appareils fictifs n'a été ajoutée.
- Recevoir : identité Sendy, état réseau, explication de la réception automatique ; page de consentement avec les actions accepter/refuser et la vérification de l'appareil conservées. Contrôles adaptés pour se réorganiser lorsque l'espace manque.
- Transfert : résumé central, anneau de progression fondé sur les compteurs réels, statut, appareil distant et quantité transférée. Les détails, annulations, reprises et erreurs existants restent disponibles.
- Réussite : coche tracée en 360 ms, **uniquement** pour `SessionStatus.finished`. Les erreurs partielles, refus et annulations ne sont jamais convertis en succès.
- Historique : accès direct à l'historique existant des **réceptions** et état vide Sendy. Aucun nouvel historique persistant des envois n'est annoncé.
- Réduction des animations : contrôles locaux et mise à jour du fournisseur d'animations lors d'un changement du réglage système. Un essai global sur appareils reste nécessaire.
- Nom Sendy dans toutes les entrées de traduction `appName`. Les anciens textes d'attribution ne sont pas remplacés aveuglément.
- Dons et initialisation d'achats désactivés : aucun compte commercial Sendy n'a été configuré. Les crédits et liens du projet d'origine sont identifiés comme tels.

## Identité d'installation

| Élément | Identité Sendy |
|---|---|
| Android durable | `app.sendy.transfer` |
| Android de test CI | `app.sendy.transfer.test` |
| macOS | `app.sendy.transfer` |
| PKG macOS | `app.sendy.transfer.installer` |
| Application GTK | `app.sendy.transfer` |
| Windows/Linux | `sendy.exe` / `sendy` |
| DEB | `sendy` |
| Inno AppId | `7C94B8D3-9ED5-44C0-AE62-6470E0943496` |
| Démarrage automatique et SendTo Windows | `Sendy` |

Les identifiants sont indépendants de LocalSend, mais ne constituent pas une réservation dans les stores ni une vérification juridique du nom Sendy. La namespace technique Kotlin, les noms internes Dart/Rust et les canaux entre Dart et le code natif sont volontairement conservés : les renommer n'est pas nécessaire pour distinguer l'application et risquerait de casser les intégrations.

Les icônes Android (legacy/adaptatives/monochromes/tuile rapide/TV), Windows ICO, macOS et les ressources communes Linux sont générées depuis le même dessin. Des ressources iOS/web ont également été adaptées, sans promettre de build iOS/web dans ce workflow. Masters et script : `support/branding/`.

## Packaging et CI

- Installateur Windows Inno **propre à Sendy**, sans l'identité MSIX de LocalSend, installation par utilisateur et ZIP portable séparé.
- DMG + PKG macOS, test de présence de l'architecture demandée avec `lipo`, signature ad hoc.
- DEB + TAR.GZ x64 et ARM64, raccourci de menu et notices de licence.
- APK par ABI, clé temporaire de test ou clé durable via quatre secrets GitHub. Aucun secret privé n'est inclus dans le code.
- `LICENSE` et `NOTICE` copiés dans les livrables par les scripts actifs.
- Deux workflows actifs : `Sendy — Source checks` et `Sendy — Build installers`.
- Les anciennes automatisations de publication LocalSend sont archivées dans `support/upstream-workflows/` et ne s'exécutent plus.
- Vérification d'identité, test de structure Linux, analyse Flutter et tests Sendy avant les jobs d'installateurs.

Les recettes historiques AppImage/RPM et métadonnées de stores conservées dans le dépôt sont des références, pas les scripts actifs de Sendy. Les formats AppImage, RPM, Windows ARM64 natif et iOS ne font pas partie de cette première chaîne.

## Vérifications locales

- **19 tests ciblés Flutter réussis** : palettes, contraste, logo accessible, sélection de fichiers, largeurs 320/390/1100 px, texte agrandi à 200 %, mode sombre, classification de chaque statut de session, pourcentage réel, état d'attente, erreur à 100 %, fin de l'animation et changement de réduction des animations.
- Analyse ciblée des nouveaux composants et tests : **aucun problème**.
- Slang et formatage Dart : exécutés.
- Identifiants, versions, fichiers XML Android, dimensions PNG, signatures ICO et présence des licences : vérifiés.
- DEB/TAR : test de structure réussi pour x64 et ARM64 avec un **exécutable factice de test**. Ceci ne prouve pas qu'un binaire natif fonctionne.
- Workflows : validation avec actionlint.
- Rendu Flutter isolé des composants de transfert exporté avec données d'exemple ; il ne simule pas une session réelle dans l'application.

Logs : `support/ci/reports/`.

### Limite rencontrée

Le test important `sendy_integration_compile_test.dart`, qui importe le graphe complet de l'application, n'a pas abouti dans le sandbox de 2 Go. Une tentative avec limite de heap pour éviter de bloquer l'environnement s'est terminée avec **Out of Memory**. Le compilateur est ensuite rétabli ; aucune modification du SDK n'est livrée.

La compilation complète n'est donc **pas validée localement**. Le workflow la vérifie sur GitHub avant de produire les installateurs. Aucun build natif ni transfert entre deux appareils n'a été testé dans cette session.

## Restant dépendant du propriétaire / des appareils

1. Créer le dépôt GitHub et y pousser les sources, `.github` compris.
2. Faire réussir les contrôles et les builds sur GitHub.
3. Configurer une clé Android durable et la sauvegarder en privé.
4. Tester installation, mise à jour, désinstallation, transferts et scénarios d'erreur sur les appareils visés.
5. Vérifier le nom/marque, définir le dépôt officiel, une politique de confidentialité propre, des coordonnées de support et un mainteneur Linux réel avant publication.
6. Accepter et expliquer les limites des builds Windows/macOS non signés par un éditeur, ou fournir les certificats nécessaires ultérieurement.

L'extension de partage macOS est exclue du packaging ad hoc ; le compte Apple, la signature Developer ID et la notarisation ne sont pas configurés. Le code de stockage Apple dispose d'un repli pour fonctionner sans le groupe applicatif de l'équipe d'origine.

Consulter `support/ci/RELEASE-CHECKLIST.fr.md`. Le mot « finalisé » décrit ici le lot de code et de packaging livré, pas une certification de fonctionnement ni une publication effective.
