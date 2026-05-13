# Feature — Génération de Quiz

> Ce document décrit le fonctionnement complet de la génération
> de quiz / QCM par IA dans Revisia.

---

## 1. Objectif

Transformer automatiquement le texte extrait d'un cours PDF
en un quiz interactif prêt à utiliser pour la révision active.

---

## 2. Flux utilisateur

1. Le texte du cours est disponible après upload PDF
2. L'utilisateur appuie sur "Générer un quiz"
3. L'application affiche un indicateur de chargement
4. Le backend envoie le texte à l'API Groq
5. L'IA génère un quiz structuré en JSON
6. L'application affiche le quiz question par question
7. L'utilisateur répond à chaque question
8. L'application affiche le score final et les corrections

---

## 3. Contraintes techniques

- Nombre de questions par défaut : 10
- Nombre de choix par question : 4 (A, B, C, D)
- Temps de génération cible : moins de 15 secondes
- Format de réponse IA : JSON strict
- Langue : français

---

## 4. Endpoint API

### Génération du quiz

```http
POST /api/v1/generation/quiz/
```

**Headers :**
```http
Authorization: Bearer <token>
Content-Type: application/json
```

**Body :**
```json
{
  "document_id": "doc_123",
  "question_count": 10
}
```

**Réponse succès (200) :**
```json
{
  "success": true,
  "data": {
    "quiz_id": "quiz_456",
    "title": "Quiz — Titre du cours",
    "question_count": 10,
    "quiz": [
      {
        "id": 1,
        "question": "Question ici ?",
        "options": [
          "Option A",
          "Option B",
          "Option C",
          "Option D"
        ],
        "answer": "Option A",
        "explanation": "Explication courte ici."
      }
    ]
  },
  "message": "Quiz généré avec succès"
}
```

---

## 5. Logique backend

### Étapes de traitement

1. Réception du document_id
2. Récupération du texte extrait depuis la base
3. Construction du prompt IA
4. Envoi du prompt à l'API Groq
5. Réception de la réponse JSON
6. Validation stricte du format JSON
7. Sauvegarde du quiz en base
8. Retour du quiz au frontend

### Prompt IA (structure)

```text
Tu es un assistant pédagogique spécialisé en révision universitaire.

À partir du cours suivant, génère exactement {question_count} questions
de type QCM en français.

Règles strictes :
- Chaque question a exactement 4 options (A, B, C, D)
- Une seule bonne réponse par question
- Ajoute une explication courte pour chaque réponse
- Réponds UNIQUEMENT en JSON valide
- Respecte exactement ce format :

{
  "quiz": [
    {
      "id": 1,
      "question": "...",
      "options": ["...", "...", "...", "..."],
      "answer": "...",
      "explanation": "..."
    }
  ]
}

Cours :
{texte_du_cours}
```

### Validation JSON

Avant d'envoyer au frontend, vérifier :

- La clé `quiz` existe
- Le nombre de questions correspond à `question_count`
- Chaque question a `id`, `question`, `options`, `answer`, `explanation`
- `options` contient exactement 4 éléments
- `answer` est bien dans `options`

---

## 6. Erreurs possibles

| Code | Situation | Message |
|---|---|---|
| 400 | document_id manquant | "Identifiant du document requis" |
| 400 | JSON IA invalide | "Erreur de génération, réessayez" |
| 401 | Token manquant | "Authentification requise" |
| 404 | Document introuvable | "Document non trouvé" |
| 408 | Timeout Groq API | "La génération a pris trop de temps" |
| 500 | Erreur serveur | "Une erreur est survenue, réessayez" |

---

## 7. UI attendue

### Écran génération
- Bouton "Générer un quiz"
- Indicateur de chargement avec message rassurant
- Affichage question par question
- 4 choix de réponse sous forme de boutons
- Feedback immédiat après chaque réponse (correct / incorrect)
- Explication affichée après chaque réponse
- Écran de score final avec nombre de bonnes réponses

---

## 8. Dépendances techniques

### Backend
- `groq` — client Python pour l'API Groq
- `json` — validation et parsing JSON

### Frontend
- `dio` — appels API
- Gestion d'état locale pour le quiz en cours

---

## Historique des versions

| Version | Date | Changement |
|---|---|---|
| 1.0 | 2025-05 | Création initiale |