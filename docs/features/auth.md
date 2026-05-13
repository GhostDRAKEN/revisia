# Feature — Authentification

> Ce document décrit le fonctionnement complet de l'authentification dans Revisia.

---

## 1. Objectif

Permettre à un étudiant de créer un compte, se connecter,
et accéder à ses contenus de révision de manière sécurisée.

---

## 2. Flux utilisateur

### Inscription
1. L'utilisateur ouvre l'application
2. Il appuie sur "Créer un compte"
3. Il renseigne : prénom, email, mot de passe
4. Il appuie sur "S'inscrire"
5. Il reçoit un token d'accès
6. Il est redirigé vers l'écran d'accueil

### Connexion
1. L'utilisateur ouvre l'application
2. Il appuie sur "Se connecter"
3. Il renseigne : email, mot de passe
4. Il appuie sur "Se connecter"
5. Il reçoit un token d'accès
6. Il est redirigé vers l'écran d'accueil

### Déconnexion
1. L'utilisateur appuie sur "Se déconnecter"
2. Le token est supprimé localement
3. Il est redirigé vers l'écran de connexion

---

## 3. Endpoints API

### Inscription
```http
POST /api/v1/auth/register/
```

**Body :**
```json
{
  "first_name": "Jean",
  "email": "jean@example.com",
  "password": "motdepasse123"
}
```

**Réponse succès (201) :**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "user": {
      "id": 1,
      "first_name": "Jean",
      "email": "jean@example.com"
    }
  },
  "message": "Compte créé avec succès"
}
```

---

### Connexion
```http
POST /api/v1/auth/login/
```

**Body :**
```json
{
  "email": "jean@example.com",
  "password": "motdepasse123"
}
```

**Réponse succès (200) :**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "user": {
      "id": 1,
      "first_name": "Jean",
      "email": "jean@example.com"
    }
  },
  "message": "Connexion réussie"
}
```

---

### Déconnexion
```http
POST /api/v1/auth/logout/
```

**Headers :**
```http
Authorization: Bearer <token>
```

**Réponse succès (200) :**
```json
{
  "success": true,
  "data": {},
  "message": "Déconnexion réussie"
}
```

---

## 4. Erreurs possibles

| Code | Situation | Message |
|---|---|---|
| 400 | Champs manquants | "Tous les champs sont obligatoires" |
| 400 | Email déjà utilisé | "Un compte existe déjà avec cet email" |
| 401 | Mot de passe incorrect | "Email ou mot de passe incorrect" |
| 404 | Email inexistant | "Email ou mot de passe incorrect" |
| 500 | Erreur serveur | "Une erreur est survenue, réessayez" |

---

## 5. Règles de sécurité

- Mot de passe hashé avec bcrypt, jamais en clair
- Token JWT avec expiration 7 jours
- Refresh token en V2
- Email normalisé en minuscules à l'enregistrement
- Rate limiting sur les tentatives de connexion en V2

---

## 6. UI attendue

### Écran inscription
- Champ prénom
- Champ email
- Champ mot de passe (masqué)
- Bouton "S'inscrire"
- Lien "Déjà un compte ? Se connecter"

### Écran connexion
- Champ email
- Champ mot de passe (masqué)
- Bouton "Se connecter"
- Lien "Pas encore de compte ? S'inscrire"

---

## 7. Dépendances techniques

### Backend
- `djangorestframework-simplejwt` — gestion des tokens JWT
- `django-cors-headers` — autoriser les requêtes Flutter

### Frontend
- `flutter_secure_storage` — stocker le token localement
- `dio` — appels HTTP

---

## Historique des versions

| Version | Date | Changement |
|---|---|---|
| 1.0 | 2025-05 | Création initiale |