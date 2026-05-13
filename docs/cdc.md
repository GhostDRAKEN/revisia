# Cahier des charges — Revisia

> Version 1.0 — En cours de rédaction

---

## 1. Présentation du projet

**Nom du projet** : Revisia
**Type** : Application mobile intelligente
**Cible** : Étudiants francophones universitaires
**Statut** : MVP en développement

---

## 2. Problème ciblé

Les étudiants universitaires francophones font face à plusieurs difficultés
récurrentes lors de leurs révisions :

- Volumes de cours PDF importants et difficiles à exploiter rapidement
- Révisions souvent tardives (J-2, J-1 avant examen)
- Temps perdu à identifier les informations essentielles
- Utilisation désorganisée des outils IA généralistes
- Absence d'outils mobiles simples adaptés à leur réalité académique

---

## 3. Solution proposée

Revisia est une application mobile qui transforme automatiquement
un support de cours en matériel de révision structuré et exploitable.

L'utilisateur importe un PDF ou du texte.
L'IA analyse le contenu et génère automatiquement :

- un résumé structuré,
- les points clés du cours,
- un quiz / QCM prêt à utiliser.

---

## 4. Utilisateurs cibles

**Profil principal** :
- Étudiant francophone, université ou école supérieure
- 18 à 26 ans
- Utilise son smartphone comme outil principal
- Révise souvent en dernière minute
- Familier avec les outils numériques

**Profil secondaire** (V2) :
- Lycéens en prépa ou terminale
- Étudiants en formation professionnelle

---

## 5. Fonctionnalités V1 (MVP)

| Fonctionnalité | Priorité | Statut |
|---|---|---|
| Import PDF | Haute | À faire |
| Résumé automatique | Haute | À faire |
| Points clés | Haute | À faire |
| Quiz / QCM | Haute | À faire |
| Authentification | Moyenne | À faire |

---

## 6. Fonctionnalités V2 (post-MVP)

- Flashcards automatiques
- Questions probables d'examen
- Historique des cours traités
- Mode hors ligne partiel
- Partage de résumés entre étudiants

---

## 7. Stack technique

### Frontend
- Flutter (Android + iOS)
- Dart

### Backend
- Django REST Framework
- Python 3.11+

### Intelligence artificielle
- Groq API (LLaMA)
- Traitement PDF : PyMuPDF ou pdfplumber

### Infrastructure (V1)
- Déploiement backend : Railway ou Render
- Base de données : PostgreSQL

---

## 8. Contraintes

- Application gratuite en V1
- Temps de génération acceptable (< 15 secondes)
- Interface en français
- Compatible Android en priorité (iOS en V2)
- Respect des données utilisateurs (aucune revente)


---

## 9. Conformité et protection des données

Le projet respecte le Code du Numérique du Bénin (Loi n° 2017-20) :

- Collecte minimale des données utilisateurs
- Fichiers PDF supprimés après traitement
- Mots de passe hashés, jamais stockés en clair
- HTTPS obligatoire en production
- Politique de confidentialité documentée
- Consentement utilisateur intégré à l'inscription


---


## 10. Objectifs du projet

### Techniques
- Maîtriser une architecture client/serveur moderne
- Intégrer une API IA dans une application réelle
- Traiter des documents PDF programmatiquement

### Professionnels
- Construire un portfolio technique démontrable
- Développer une présence GitHub sérieuse
- Valoriser le projet pour stages et emploi

---

## 11. Ce que le projet n'est PAS

- Pas un clone de ChatGPT
- Pas une plateforme e-learning complète
- Pas un outil de triche académique
- Pas une IA généraliste

---

## Historique des versions

| Version | Date | Changement |
|---|---|---|
| 1.0 | 2025-05 | Création initiale |