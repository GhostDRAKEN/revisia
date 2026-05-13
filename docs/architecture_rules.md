# Architecture Rules — Revisia

> Ce document définit les conventions techniques obligatoires du projet.
> Toute contribution doit respecter ces règles.

---

## 1. Structure générale du projet

```text
revisia/
├── docs/              → documentation produit et technique
├── backend/           → API Django REST Framework
├── frontend/          → application Flutter
└── README.md
```

---

## 2. Conventions Backend (Django)

### Structure des dossiers

```text
backend/
├── config/            → settings, urls, wsgi
├── apps/
│   ├── users/         → authentification
│   ├── documents/     → upload et traitement PDF
│   └── generation/    → logique IA (résumés, quiz)
├── utils/             → fonctions utilitaires partagées
├── requirements.txt
└── .env.example
```

### Règles générales
- Python 3.11+
- Une app Django par domaine fonctionnel
- Jamais de logique métier dans les views → utiliser des services
- Chaque app a son propre `urls.py`

### Nommage
- Fichiers : `snake_case`
- Classes : `PascalCase`
- Variables et fonctions : `snake_case`
- Constantes : `UPPER_SNAKE_CASE`

### API REST
- Préfixe global : `/api/v1/`
- Format de réponse : toujours JSON
- Toujours retourner un message explicite en cas d'erreur

### Format de réponse standard

```json
{
  "success": true,
  "data": {},
  "message": "Opération réussie"
}
```

### Format d'erreur standard

```json
{
  "success": false,
  "error": "Description claire de l'erreur",
  "code": "ERROR_CODE"
}
```

### Sécurité
- Les clés API ne sont jamais dans le code
- Toutes les variables sensibles dans `.env`
- `.env` toujours dans `.gitignore`

---

## 3. Conventions Frontend (Flutter)

### Structure des dossiers

```text
frontend/
└── lib/
    ├── main.dart
    ├── core/
    │   ├── constants/     → couleurs, textes, dimensions
    │   ├── theme/         → thème global de l'app
    │   └── utils/         → fonctions utilitaires
    ├── data/
    │   ├── models/        → modèles de données
    │   └── services/      → appels API
    └── presentation/
        ├── screens/       → écrans principaux
        └── widgets/       → composants réutilisables
```

### Règles générales
- Dart 3.0+
- Séparation stricte UI / logique / données
- Pas de logique métier dans les widgets

### Nommage
- Fichiers : `snake_case`
- Classes : `PascalCase`
- Variables : `camelCase`
- Constantes : `UPPER_SNAKE_CASE`

---

## 4. Conventions IA

### Format de réponse quiz (JSON strict)

```json
{
  "quiz": [
    {
      "question": "Question ici ?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "answer": "Option A",
      "explanation": "Explication courte ici."
    }
  ]
}
```

### Format de réponse résumé (JSON strict)

```json
{
  "summary": {
    "title": "Titre du cours",
    "key_points": [
      "Point clé 1",
      "Point clé 2"
    ],
    "full_summary": "Résumé complet ici."
  }
}
```

### Règles prompts
- Les prompts sont définis dans des fichiers dédiés
- Jamais de prompt écrit directement dans une view
- Toujours demander une réponse JSON à l'IA
- Toujours valider le JSON reçu avant de l'envoyer au frontend

---

## 5. Conventions Git

### Format des commits

```text
type: description courte en minuscules
```

### Types de commits autorisés

| Type | Usage |
|---|---|
| `feat` | Nouvelle fonctionnalité |
| `fix` | Correction de bug |
| `docs` | Documentation |
| `config` | Configuration |
| `refactor` | Amélioration du code |
| `test` | Ajout de tests |
| `chore` | Tâches diverses |

### Exemples

```text
feat: add PDF upload endpoint
fix: correct quiz JSON parsing error
docs: update architecture rules
config: add cors settings to Django
```

### Branches

| Branche | Usage |
|---|---|
| `main` | Code stable uniquement |
| `dev` | Développement en cours |
| `feat/nom` | Nouvelle fonctionnalité |
| `fix/nom` | Correction de bug |

---

## Historique des versions

| Version | Date | Changement |
|---|---|---|
| 1.0 | 2025-05 | Création initiale |