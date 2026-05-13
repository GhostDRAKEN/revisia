# Feature — Upload PDF

> Ce document décrit le fonctionnement complet de l'upload
> et du traitement des fichiers PDF dans Revisia.

---

## 1. Objectif

Permettre à un étudiant d'importer un fichier PDF de cours
et d'en extraire automatiquement le texte pour analyse IA.

---

## 2. Flux utilisateur

1. L'utilisateur appuie sur "Importer un cours"
2. Il sélectionne un fichier PDF depuis son téléphone
3. Il appuie sur "Analyser"
4. L'application affiche un indicateur de chargement
5. Le backend reçoit le fichier, extrait le texte
6. Le texte extrait est transmis au service IA
7. L'utilisateur est redirigé vers l'écran des résultats

---

## 3. Contraintes techniques

- Taille maximale du fichier : 10 MB
- Format accepté : PDF uniquement (V1)
- Nombre de pages recommandé : 1 à 50 pages
- Langue du contenu : français en priorité
- Le fichier est supprimé après extraction du texte

---

## 4. Endpoint API

### Upload et extraction

```http
POST /api/v1/documents/upload/
```

**Headers :**
```http
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Body :**
```
file: <fichier PDF>
```
**Réponse succès (200) :**
```json
{
  "success": true,
  "data": {
    "document_id": "doc_123",
    "title": "Titre détecté du cours",
    "page_count": 12,
    "word_count": 4200,
    "extracted_text": "Texte extrait ici..."
  },
  "message": "Document traité avec succès"
}
```

---

## 5. Logique backend

### Étapes de traitement

1. Réception du fichier PDF
2. Validation du format et de la taille
3. Extraction du texte avec `pdfplumber`
4. Nettoyage du texte extrait
5. Détection du titre (première ligne significative)
6. Suppression du fichier temporaire
7. Retour du texte extrait au frontend

### Nettoyage du texte

Le texte extrait doit être nettoyé :

- Suppression des caractères spéciaux inutiles
- Suppression des espaces multiples
- Suppression des lignes vides excessives
- Conservation de la structure paragraphes

---

## 6. Erreurs possibles

| Code | Situation | Message |
|---|---|---|
| 400 | Aucun fichier envoyé | "Aucun fichier détecté" |
| 400 | Format invalide | "Seuls les fichiers PDF sont acceptés" |
| 400 | Fichier trop lourd | "Le fichier dépasse la limite de 10 MB" |
| 400 | PDF vide ou illisible | "Impossible d'extraire le texte de ce PDF" |
| 401 | Token manquant | "Authentification requise" |
| 500 | Erreur serveur | "Une erreur est survenue, réessayez" |

---

## 6. Sécurité

- Vérification stricte du type MIME
- Nom de fichier aléatoire côté serveur
- Suppression immédiate après extraction
- Aucun fichier stocké de manière permanente
- Taille limitée côté backend et frontend

---

## 7. UI attendue

### Écran upload
- Bouton "Importer un cours"
- Aperçu du fichier sélectionné (nom, taille)
- Bouton "Analyser"
- Indicateur de progression pendant le traitement
- Message d'erreur clair si problème

---

## 8. Dépendances techniques

### Backend
- `pdfplumber` — extraction texte depuis PDF
- `python-magic` — validation type MIME

### Frontend
- `file_picker` — sélection fichier sur mobile
- `dio` — envoi multipart/form-data

---

## Historique des versions

| Version | Date | Changement |
|---|---|---|
| 1.0 | 2025-05 | Création initiale |