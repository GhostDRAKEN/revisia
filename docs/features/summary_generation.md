# Feature — Génération de Résumé

> Ce document décrit le fonctionnement complet de la génération
> de résumé et de points clés par IA dans Revisia.

---

## 1. Objectif

Transformer automatiquement le texte extrait d'un cours PDF
en un résumé structuré et une liste de points clés
exploitables immédiatement pour la révision.

---

## 2. Flux utilisateur

1. Le texte du cours est disponible après upload PDF
2. L'utilisateur appuie sur "Générer un résumé"
3. L'application affiche un indicateur de chargement
4. Le backend envoie le texte à l'API Groq
5. L'IA génère un résumé structuré en JSON
6. L'application affiche le résumé et les points clés
7. L'utilisateur peut lire et réviser le contenu

---

## 3. Contraintes techniques

- Nombre de points clés : entre 5 et 10
- Longueur du résumé : 150 à 300 mots
- Temps de génération cible : moins de 15 secondes
- Format de réponse IA : JSON strict
- Langue : français

---

## 4. Endpoint API

### Génération du résumé

```http
POST /api/v1/generation/summary/
```

**Headers :**
```http
Authorization: Bearer <token>
Content-Type: application/json
```

**Body :**
```json
{
  "document_id": "doc_123"
}
```

**Réponse succès (200) :**
```json
{
  "success": true,
  "data": {
    "summary_id": "sum_789",
    "title": "Titre du cours",
    "key_points": [
      "Point clé 1",
      "Point clé 2",
      "Point clé 3",
      "Point clé 4",
      "Point clé 5"
    ],
    "full_summary": "Résumé complet du cours ici.",
    "word_count": 245
  },
  "message": "Résumé généré avec succès"
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
7. Sauvegarde du résumé en base
8. Retour du résumé au frontend

### Prompt IA (structure)

```text
Tu es un assistant pédagogique spécialisé en révision universitaire.

À partir du cours suivant, génère en français :
- un résumé clair et structuré de 150 à 300 mots,
- une liste de 5 à 10 points clés essentiels à retenir.

Règles strictes :
- Réponds UNIQUEMENT en JSON valide
- Respecte exactement ce format :

{
  "summary": {
    "title": "Titre détecté du cours",
    "key_points": [
      "Point clé 1",
      "Point clé 2"
    ],
    "full_summary": "Résumé complet ici."
  }
}

Cours :
{texte_du_cours}
```

### Validation JSON

Avant d'envoyer au frontend, vérifier :

- La clé `summary` existe
- Les clés `title`, `key_points`, `full_summary` existent
- `key_points` contient entre 5 et 10 éléments
- `full_summary` contient entre 150 et 300 mots
- Aucun champ vide

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

### Écran résumé
- Titre du cours affiché en haut
- Section "Points clés" avec liste visuelle
- Section "Résumé complet" avec texte structuré
- Bouton "Générer un quiz" pour enchaîner
- Possibilité de copier le résumé

---

## 8. Dépendances techniques

### Backend
- `groq` — client Python pour l'API Groq
- `json` — validation et parsing JSON

### Frontend
- `dio` — appels API
- `flutter_markdown` — affichage résumé formaté

---

## Historique des versions

| Version | Date | Changement |
|---|---|---|
| 1.0 | 2025-05 | Création initiale |