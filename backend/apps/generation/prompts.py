def build_quiz_prompt(text, question_count):
    return f"""Tu es un assistant pédagogique spécialisé en révision universitaire.

À partir du cours suivant, génère exactement {question_count} questions de type QCM en français.

Règles strictes :
- Chaque question a exactement 4 options
- Une seule bonne réponse par question
- Ajoute une explication courte pour chaque réponse
- Réponds UNIQUEMENT en JSON valide
- Respecte exactement ce format :

{{
  "quiz": [
    {{
      "id": 1,
      "question": "...",
      "options": ["...", "...", "...", "..."],
      "answer": "...",
      "explanation": "..."
    }}
  ]
}}

Cours :
{text}"""


def build_summary_prompt(text):
    return f"""Tu es un assistant pédagogique spécialisé en révision universitaire.

À partir du cours suivant, génère en français :
- un résumé clair et structuré de 150 à 300 mots,
- une liste de 5 à 10 points clés essentiels à retenir.

Règles strictes :
- Réponds UNIQUEMENT en JSON valide
- Respecte exactement ce format :

{{
  "summary": {{
    "title": "Titre détecté du cours",
    "key_points": [
      "Point clé 1",
      "Point clé 2"
    ],
    "full_summary": "Résumé complet ici."
  }}
}}

Cours :
{text}"""