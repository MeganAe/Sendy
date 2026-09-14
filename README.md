> **État actuel :** les libellés À propos/paramètres sont corrigés. **Les cinq fonctions ne sont pas toutes terminées.** Consulter [le tableau d’avancement exact](support/features/ETAT-LIVRAISON.fr.md). 46 tests ciblés passent ; validation complète sur GitHub et appareils encore nécessaire.

> **BRANCHE DE DÉVELOPPEMENT — fonctionnalités en cours.** Ce lot ajoute une première bibliothèque de colis et la confirmation de réception par défaut. Les cinq fonctionnalités demandées ne sont pas encore terminées. Ne pas distribuer comme une version stable. Voir [le périmètre et l’état réel](support/features/SENDY-0.2-PLAN.fr.md).

> **Mise à jour macOS :** les journaux ont identifié un SDK Xcode trop ancien. Le workflow sélectionne maintenant Xcode 26.3. [Diagnostic et correction](support/ci/MACOS-SDK-FIX.fr.md). Les mentions « cause inconnue » ci-dessous décrivent l’état précédent ; la nouvelle compilation reste à confirmer sur GitHub.

# Sendy

**Partage de fichiers entre appareils — développé par Metoushela Walker.**

Thème par défaut : **Yaru**. Identité visuelle Sendy conservée.

> **Correctif important 0.1.1 :** données Windows et portable isolées de LocalSend, port HTTP dédié et diagnostic local. Lire [le guide de mise à jour et de récupération](support/ci/SENDY-0.1.1-CORRECTIFS.fr.md) avant de remplacer une installation 0.1.0.


Version de travail : **0.1.1+2**. Application Flutter indépendante basée sur [LocalSend](https://github.com/localsend/localsend), sous licence Apache-2.0. Sendy n'est pas une version officielle du projet d'origine.

## Statut honnête

Le code du design, les icônes et les installateurs sont préparés. **Cette révision 0.1.1 reste à compiler sur GitHub et à tester sur appareils. Les builds 0.1.0 Windows/Linux/Android ont réussi sur GitHub ; les builds Mac ont échoué et nécessitent leur journal détaillé.** Les composants ciblés passent 31 tests ciblés. La compilation du graphe complet doit être validée par le workflow GitHub, l'environnement local étant limité en mémoire.

Ce dépôt n'est donc pas encore une version de production certifiée.

## Compiler sans ordinateur puissant

1. Mettre **tout le contenu de ce projet**, notamment `.github/`, `support/` et `packages/`, dans votre dépôt GitHub.
2. Ouvrir **Actions → Sendy — Build installers → Run workflow**.
3. Choisir les plateformes. Pour le premier essai Android, laisser `android_signing: test`.
4. Attendre la réussite de `Validate Sendy UI`, puis des jobs de compilation.
5. Télécharger les résultats dans **Artifacts** (conservation : 14 jours).

| Plateforme | Livrables prévus |
|---|---|
| Windows x64 | EXE Inno Setup, ZIP portable |
| macOS Intel / Apple Silicon | DMG et PKG par architecture |
| Linux x64 / ARM64 | DEB et TAR.GZ |
| Android ARMv7 / ARM64 / x86_64 | APK par architecture |

Les workflows standards s'exécutent sur les machines GitHub ; les quotas, la disponibilité des runners et les coûts éventuels dépendent du compte et du type de dépôt. Vérifier ces limites avant de lancer toutes les plateformes.

**Mode Android test :** clé temporaire, application `app.sendy.transfer.test`. **Mode release :** clé durable à configurer dans les secrets, application `app.sendy.transfer`. Ne pas distribuer les APK test publiquement.

Windows n'est pas signé par un certificat éditeur. macOS utilise une signature ad hoc, sans notarisation ; Gatekeeper peut bloquer l'installation. Aucun certificat payant n'est requis pour préparer ces builds d'essai, mais cela ne supprime pas les avertissements du système.

## Documentation

- [Guide complet GitHub et signature Android](support/ci/README.fr.md)
- [État d'implémentation et limites restantes](SENDY-IMPLEMENTATION.md)
- [Checklist de validation avant distribution](support/ci/RELEASE-CHECKLIST.fr.md)
- [Identité de packaging](support/branding/sendy.json)
- [Documentation originale LocalSend](support/UPSTREAM-README.md)

Les anciens workflows de publication LocalSend sont conservés dans `support/upstream-workflows/`, **désactivés**. Utiliser uniquement les workflows Sendy actifs.

## Développement

Flutter **3.41.9**, Rust selon `rust-toolchain.toml`. Les noms internes Dart/Rust `localsend_app` et `localsend_isolates`, ainsi que les canaux de plateforme et routes du protocole, sont conservés intentionnellement : ils ne déterminent pas l'identité visible d'installation.

```bash
flutter pub get
cd app
flutter test --concurrency=1 test/widget/sendy
flutter run
```

Contrôles rapides, sans Flutter :

```bash
python3 support/ci/check_branding.py
python3 support/ci/test_linux_packaging.py  # Linux, dpkg-deb nécessaire
```

La disponibilité juridique du nom Sendy, de ses domaines et de ses identifiants dans les stores n'a pas été vérifiée. Les identifiants du projet sont distincts de ceux de LocalSend ; cela ne constitue pas une réservation de marque.

## Licence et crédits

Voir [LICENSE](LICENSE), [NOTICE](NOTICE), les crédits dans l'application et la documentation originale. Ne pas retirer les attributions des auteurs et des dépendances.
