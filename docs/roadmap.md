# Roadmap — Revisia

> Ce document définit les phases de développement du projet.
> L'objectif est de livrer un MVP fonctionnel avant d'ajouter des fonctionnalités.

---

## Statut actuel

🟡 **Phase 1 — Structuration** (en cours)

---

## Phase 1 — Structuration
> Objectif : poser des bases solides avant de coder

- [x] Création du repo GitHub
- [x] Structure des dossiers
- [x] README.md
- [x] Cahier des charges
- [x] Contexte produit
- [x] Architecture rules
- [x] Roadmap
- [ ] Spécifications features (auth, pdf, quiz, résumé)

---

## Phase 2 — Backend Core
> Objectif : avoir une API fonctionnelle qui génère des quiz et résumés

- [ ] Initialisation projet Django
- [ ] Configuration environnement conda
- [ ] Endpoint upload PDF
- [ ] Extraction texte depuis PDF
- [ ] Intégration Groq API
- [ ] Génération résumé (JSON)
- [ ] Génération quiz (JSON)
- [ ] Authentification utilisateur
- [ ] Tests endpoints avec Postman

---

## Phase 3 — Flutter MVP
> Objectif : interface mobile connectée au backend

- [ ] Initialisation projet Flutter
- [ ] Écran d'accueil
- [ ] Écran upload PDF
- [ ] Écran résumé
- [ ] Écran quiz interactif
- [ ] Connexion au backend (API calls)
- [ ] Authentification mobile

---

## Phase 4 — Tests utilisateurs
> Objectif : valider que de vrais étudiants trouvent l'outil utile

- [ ] Recruter 5 à 10 étudiants testeurs
- [ ] Recueillir les retours
- [ ] Identifier les frictions principales
- [ ] Prioriser les corrections

---

## Phase 5 — Publication
> Objectif : rendre le projet visible publiquement

- [ ] Déploiement backend (Railway ou Render)
- [ ] README final soigné
- [ ] Post LinkedIn de lancement
- [ ] GitHub propre et documenté

---

## Phase 6 — Itération V2
> Objectif : améliorer avec les retours réels

- [ ] Flashcards automatiques
- [ ] Questions probables d'examen
- [ ] Historique des cours traités
- [ ] Mode hors ligne partiel
- [ ] Support iOS

---

## Ce qui n'est PAS dans le MVP

Ces fonctionnalités sont volontairement exclues de la V1 :

- Flashcards
- Partage entre étudiants
- Mode hors ligne
- Support iOS
- Tableau de bord statistiques
- Notifications

---

## Historique des versions

| Version | Date | Changement |
|---|---|---|
| 1.0 | 2025-05 | Création initiale |