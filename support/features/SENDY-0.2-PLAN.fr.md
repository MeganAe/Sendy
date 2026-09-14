# Sendy — cinq fonctionnalités acceptées, développement par lots

## Choix confirmés

- Colis par références : ne pas recopier automatiquement les fichiers.
- Confirmation de réception par défaut, y compris pour les favoris. Aucune association QR ne vaut autorisation d’envoyer sans confirmation.
- Fonctionnement local sans abonnement ni serveur propriétaire obligatoire.
- Préserver le transfert classique avec LocalSend. Négocier explicitement les extensions entre deux Sendy compatibles.

## État de ce lot (sources de développement, pas une version publiée)

### Colis : première implémentation

- Bouton « Mes colis » dans Envoyer.
- Enregistrement de la sélection existante avec titre et note.
- Bibliothèque privée versionnée dans les préférences Sendy ; noms, chemins/URI et tailles, sans contenu binaire ni certificat.
- Liste persistante ; suppression du colis sans effacer les originaux.
- Avant rechargement : vérification des chemins locaux et de la taille accessible pour les URI Android ; blocage si une référence est inaccessible ; signalement des tailles modifiées.
- Confirmation : les versions actuelles des fichiers sont utilisées, puis ajout à la sélection actuelle, sans démarrer de transfert. La note est ajoutée comme texte.
- Une bibliothèque illisible ou de schéma inconnu n’est pas remplacée silencieusement par une bibliothèque vide.
- Migration unique du réglage de réception vers « confirmation » et valeur par défaut off pour l’acceptation automatique. Les options d’acceptation automatique restent disponibles, mais exigent une action explicite ultérieure.

### Limites explicites

Ce premier lot ne constitue PAS les cinq fonctions achevées. Il ne fournit pas encore :

- un historique d’accusés de réception par destinataire pour chaque colis ;
- le remplacement guidé d’une référence cassée (il faut actuellement resélectionner et recréer le colis) ;
- un instantané du contenu des fichiers : même taille ne signifie pas contenu identique ;
- une garantie de persistance des fichiers temporaires provenant d’un sélecteur ou des autorisations accordées par le système ;
- le classement automatique, le nouvel écran de contrôle de réception, le scanner QR ou la reprise du transfert.

L’interface de colis de ce lot est en français. Sa traduction, ses essais d’accessibilité et son intégration multi-plateforme restent à compléter.

## Lots à implémenter ensuite

### A. Terminer les colis et le classement

- Relier les résultats de sessions aux colis, sans considérer « envoyé » comme un accusé de réception validé.
- Permettre de retrouver/remplacer les références cassées.
- Règles de classement par type OU expéditeur/date, désactivées par défaut jusqu’au choix de l’utilisateur.
- Aperçu exact des destinations avant acceptation, avec noms d’expéditeurs nettoyés.
- Ne jamais écraser un fichier existant silencieusement ; gérer aussi deux transferts concurrents et la casse selon le système de fichiers.
- Respecter le dossier de réception autorisé et les URI Android ; refuser la traversée de répertoire et les liens symboliques sortants. Ne pas déplacer les anciens fichiers reçus.

### B. Contrôle de réception

- Conserver le choix de fichiers déjà présent dans le moteur, améliorer sa présentation plutôt que le recréer.
- Total sélectionné, espace réellement disponible lorsque le système l’expose, état « inconnu » sinon.
- Avertissements sur exécutables, noms trompeurs et collisions, sans prétendre effectuer une analyse antivirus.
- Confirmation avant toute acceptation et contrôle de l’espace à nouveau au moment de l’écriture.

### C. QR de connexion

- Contenu versionné et limité à une adresse locale, port, expiration et données de vérification nécessaires.
- Affichage PC, scanner téléphone avec permission caméra et alternative manuelle.
- Validation stricte des données scannées ; ne jamais ouvrir une URL arbitraire ou exécuter une commande.
- Vérification de l’identité et confirmation avant connexion/échange. Le QR ne contourne ni l’isolation Wi-Fi ni le pare-feu.
- Compatibilité protocolaire explicite ; ne pas faire passer le QR Sendy pour un format LocalSend pris en charge sans vérification.

### D. Reprise des transferts

- Négociation d’une capacité Sendy de reprise ; repli sur l’envoi classique si absente.
- Découpage, offsets contrôlés et intégrité par morceaux puis du fichier complet.
- Autorisation de reprise liée à l’expéditeur authentifié, au destinataire et au manifeste des fichiers ; pas à leur seul nom.
- Écriture partielle isolée, plafonds d’espace, expiration et suppression contrôlée des fragments abandonnés.
- Ne pas annoncer la réussite avant vérification et finalisation du fichier.
- Politique d’acceptation : une reprise de session déjà autorisée peut reprendre les fichiers autorisés pendant sa durée de validité ; au-delà ou si l’identité/contenu change, nouvelle confirmation requise. Ce comportement doit être présenté clairement à l’utilisateur.

## Validation requise avant une version 0.2

Les tests locaux du modèle des colis ne valident pas l’interface, le moteur Rust ou un transfert réel. Le graphe applicatif complet dépasse les ressources locales : validation complète sur GitHub, puis essais sur appareils.

Matrice minimale : Windows/Android, Linux/Android et macOS/Android ; Sendy/Sendy et transfert classique Sendy/LocalSend. Scénarios : annulation, refus, fichier déplacé, permission révoquée, disque plein, doublon, réseau coupé, redémarrage, mauvais destinataire, manifeste de reprise altéré et texte agrandi.

Ne pas distribuer ce lot comme une version terminée. Conserver le correctif Xcode 26.3 dans la branche de développement.
