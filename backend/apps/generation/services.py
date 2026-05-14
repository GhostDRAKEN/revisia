import json
import re

from django.conf import settings
from groq import Groq

try:
    from groq import APITimeoutError
except ImportError:
    APITimeoutError = TimeoutError

from apps.documents.models import Document
from apps.generation.models import Quiz, Summary
from apps.generation.prompts import build_quiz_prompt, build_summary_prompt


GROQ_MODEL = 'llama-3.3-70b-versatile'
GROQ_TIMEOUT = 15


class GenerationError(Exception):
    pass


class ServerGenerationError(Exception):
    pass


class DocumentNotFoundError(Exception):
    pass


class GroqTimeoutError(Exception):
    pass


def generate_quiz(document_id, question_count, user):
    document = _get_user_document(document_id, user)
    prompt = build_quiz_prompt(document.extracted_text, question_count)
    payload = _call_groq(prompt)
    quiz_items = _validate_quiz_payload(payload, question_count)

    quiz = Quiz.objects.create(
        document=document,
        title=f'Quiz — {document.title}',
        question_count=question_count,
        quiz=quiz_items,
    )

    return quiz


def generate_summary(document_id, user):
    document = _get_user_document(document_id, user)
    prompt = build_summary_prompt(document.extracted_text)
    try:
        payload = _call_groq(prompt)
    except Exception as exc:
        import traceback
        traceback.print_exc()
        raise
    summary_data = _validate_summary_payload(payload)
    full_summary = summary_data['full_summary'].strip()

    summary = Summary.objects.create(
        document=document,
        title=summary_data['title'].strip(),
        key_points=summary_data['key_points'],
        full_summary=full_summary,
        word_count=_count_words(full_summary),
    )

    return summary


def _get_user_document(document_id, user):
    pk = _parse_prefixed_id(document_id, 'doc_')

    if not pk:
        raise DocumentNotFoundError("Document non trouvé")

    try:
        return Document.objects.get(id=pk, owner=user)
    except Document.DoesNotExist as exc:
        raise DocumentNotFoundError("Document non trouvé") from exc


def _parse_prefixed_id(value, prefix):
    if not isinstance(value, str) or not value.startswith(prefix):
        return None

    raw_id = value.removeprefix(prefix)

    if not raw_id.isdigit():
        return None

    return int(raw_id)


def _call_groq(prompt):
    if not settings.GROQ_API_KEY:
        raise ServerGenerationError("Une erreur est survenue, réessayez")

    client = Groq(api_key=settings.GROQ_API_KEY)

    try:
        response = client.chat.completions.create(
    model=GROQ_MODEL,
    messages=[
    {
        'role': 'system',
        'content': 'Tu réponds uniquement en JSON valide, sans texte autour.',
    },
    {
        'role': 'user',
        'content': prompt,
    },
],
    temperature=0.2,
    timeout=GROQ_TIMEOUT,
)
    except APITimeoutError as exc:
        raise GroqTimeoutError("La génération a pris trop de temps") from exc
    except TimeoutError as exc:
        raise GroqTimeoutError("La génération a pris trop de temps") from exc
    except Exception as exc:
    
        raise ServerGenerationError("Une erreur est survenue, réessayez") from exc

    try:
        content = response.choices[0].message.content
    except (AttributeError, IndexError) as exc:
        raise ServerGenerationError("Une erreur est survenue, réessayez") from exc

    try:
        return json.loads(content)
    except (json.JSONDecodeError, TypeError) as exc:
        raise GenerationError("Erreur de génération, réessayez") from exc


def _validate_quiz_payload(payload, question_count):
    quiz = payload.get('quiz') if isinstance(payload, dict) else None

    if not isinstance(quiz, list) or len(quiz) == 0:
        raise GenerationError("Erreur de génération, réessayez")
    validated_items = []

    for index, item in enumerate(quiz, start=1):
        if not isinstance(item, dict):
            raise GenerationError("Erreur de génération, réessayez")

        required_fields = {'id', 'question', 'options', 'answer', 'explanation'}

        if not required_fields.issubset(item.keys()):
            raise GenerationError("Erreur de génération, réessayez")

        options = item['options']

        if not isinstance(options, list) or len(options) != 4:
            raise GenerationError("Erreur de génération, réessayez")

        if not item['question'] or not item['answer'] or not item['explanation']:
            raise GenerationError("Erreur de génération, réessayez")

        cleaned_options = [str(option).strip() for option in options]
        cleaned_answer = str(item['answer']).strip()

        if any(not option for option in cleaned_options):
            raise GenerationError("Erreur de génération, réessayez")

        if cleaned_answer not in cleaned_options:
            raise GenerationError("Erreur de génération, réessayez")

        try:
            item_id = int(item.get('id') or index)
        except (TypeError, ValueError) as exc:
            raise GenerationError("Erreur de génération, réessayez") from exc

        validated_items.append({
            'id': item_id,
            'question': str(item['question']).strip(),
            'options': cleaned_options,
            'answer': cleaned_answer,
            'explanation': str(item['explanation']).strip(),
        })

    return validated_items


def _validate_summary_payload(payload):
    summary = payload.get('summary') if isinstance(payload, dict) else None

    if not isinstance(summary, dict):
        raise GenerationError("Erreur de génération, réessayez")

    required_fields = {'title', 'key_points', 'full_summary'}

    if not required_fields.issubset(summary.keys()):
        raise GenerationError("Erreur de génération, réessayez")

    title = str(summary['title']).strip()
    key_points = summary['key_points']
    full_summary = str(summary['full_summary']).strip()

    if not title or not full_summary:
        raise GenerationError("Erreur de génération, réessayez")

    if not isinstance(key_points, list) or not 5 <= len(key_points) <= 10:
        raise GenerationError("Erreur de génération, réessayez")

    cleaned_key_points = [str(point).strip() for point in key_points]

    if any(not point for point in cleaned_key_points):
        raise GenerationError("Erreur de génération, réessayez")

    if not 50 <= _count_words(full_summary) <= 600:
        raise GenerationError("Erreur de génération, réessayez")

    return {
        'title': title[:255],
        'key_points': cleaned_key_points,
        'full_summary': full_summary,
    }


def _count_words(text):
    return len(re.findall(r'\b\w+\b', text, flags=re.UNICODE))
