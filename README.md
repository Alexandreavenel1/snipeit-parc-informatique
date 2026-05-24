\# Snipe-IT - Suivi du parc informatique



Déploiement local de test de Snipe-IT via Docker Desktop Windows.



\## Objectif



Mettre en place un référentiel de suivi du matériel informatique :

\- PC portables

\- PC fixes

\- téléphones

\- tablettes

\- écrans

\- stations d’accueil

\- imprimantes

\- accessoires



\## Démarrage



```powershell

cd C:\\snipeit-test

docker compose up -d



\# Déploiement production Snipe-IT



\## Objectif



Ce dépôt contient la configuration nécessaire pour déployer Snipe-IT sur un serveur de production.



Il ne contient pas :

\- le fichier `.env` réel ;

\- les mots de passe ;

\- l'APP\_KEY réelle ;

\- les sauvegardes ;

\- les dumps SQL ;

\- les données du parc informatique.



Ces éléments doivent être stockés séparément, de manière sécurisée.



\---



\## Architecture cible production



```text

Serveur Debian de production

├── Docker Engine

├── Docker Compose Plugin

├── Snipe-IT

├── MariaDB / MySQL

├── reverse proxy HTTPS

├── sauvegardes automatisées

└── accès sécurisé SSH

