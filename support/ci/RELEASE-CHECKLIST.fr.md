# Sendy — checklist avant distribution

Une case non cochée signifie « non vérifié », pas « fonctionne forcément ».

## Code et packaging local

- [x] Thème clair/sombre, logo vectoriel et icônes natifs Sendy.
- [x] Identifiants d'installation séparés de LocalSend ; clé Windows et SendTo séparés.
- [x] Réception : actions accepter/refuser conservées.
- [x] Transfert : progression réelle ; erreurs et annulations distinctes de la réussite.
- [x] Tests ciblés : 19 réussis.
- [x] Analyse ciblée des composants : aucun problème.
- [x] Contrôles des identifiants, XML, icônes et versions : réussis.
- [x] Packaging Linux sur fixtures x64/ARM64 : réussi.
- [x] Syntaxe des workflows vérifiée avec actionlint.
- [x] Licences et attributions conservées ; anciens workflows désactivés.

## À effectuer dans votre dépôt

- [ ] Créer le dépôt et pousser l'ensemble des fichiers, dossier `.github` inclus.
- [ ] Faire réussir `Sendy — Source checks`.
- [ ] Faire réussir `Sendy — Build installers` pour toutes les plateformes voulues.
- [ ] Télécharger les artefacts et vérifier leurs empreintes SHA-256.
- [ ] Configurer la clé Android durable avant toute distribution.

## Essais sur appareils

- [ ] Installer/désinstaller Windows ; vérifier raccourcis, démarrage automatique et archive portable.
- [ ] Installer DMG et PKG sur Intel et Apple Silicon ; vérifier permissions et comportement Gatekeeper.
- [ ] Installer les DEB x64/ARM64 sur les distributions visées ; tester le bundle TAR.GZ.
- [ ] Installer chaque APK sur une architecture compatible ; tester une mise à jour avec la même clé.
- [ ] Envoyer dans les deux sens entre deux appareils réels : fichiers, photos, dossiers, texte.
- [ ] Tester refus, annulation, destinataire occupé, permission refusée, réseau perdu, disque plein et fichier trop gros.
- [ ] Vérifier qu'une erreur ou annulation ne déclenche pas la coche de réussite.
- [ ] Vérifier la destination des fichiers, l'historique des réceptions et les actions ouvrir/supprimer de l'historique.
- [ ] Vérifier le mode sombre, le texte agrandi, le clavier, les lecteurs d'écran et le réglage système de réduction des animations en cours d'exécution.
- [ ] Tester sur réseau local avec pare-feu. Deux applications utilisant le même port sur une machine peuvent nécessiter un réglage de port : coexistence d'installation ne signifie pas coexistence réseau simultanée garantie.

## Avant diffusion publique

- [ ] Vérifier la disponibilité de Sendy comme nom et marque.
- [ ] Définir votre dépôt officiel, vos coordonnées de support et votre propre politique de confidentialité.
- [ ] Remplacer les coordonnées de mainteneur Linux de démonstration par les vôtres.
- [ ] Décider d'assumer explicitement les avertissements Windows/Mac ou configurer les certificats nécessaires.
- [ ] Vérifier les licences des dépendances distribuées et joindre leurs mentions requises.

Ne pas annoncer une version « prête pour la production » tant que les essais et les obligations de distribution ne sont pas satisfaits.
