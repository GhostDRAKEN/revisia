import os
import re
import tempfile
from pathlib import Path

import pdfplumber

from apps.documents.models import Document


class PdfProcessingError(Exception):
    pass


def process_uploaded_pdf(uploaded_file, user):
    temp_path = _save_temporary_pdf(uploaded_file)

    try:
        extraction = _extract_pdf_text(temp_path)
        cleaned_text = _clean_text(extraction['text'])

        if not cleaned_text:
            raise PdfProcessingError("Impossible d'extraire le texte de ce PDF")

        document = Document.objects.create(
            owner=user,
            title=_detect_title(cleaned_text),
            page_count=extraction['page_count'],
            word_count=_count_words(cleaned_text),
            extracted_text=cleaned_text,
            original_filename=uploaded_file.name,
        )

        return document
    finally:
        _delete_file(temp_path)


def _save_temporary_pdf(uploaded_file):
    with tempfile.NamedTemporaryFile(delete=False, suffix='.pdf') as temp_file:
        for chunk in uploaded_file.chunks():
            temp_file.write(chunk)
        return temp_file.name


def _extract_pdf_text(file_path):
    try:
        with pdfplumber.open(file_path) as pdf:
            pages_text = []

            for page in pdf.pages:
                text = page.extract_text() or ''
                pages_text.append(text)

            return {
                'text': '\n\n'.join(pages_text),
                'page_count': len(pdf.pages),
            }
    except Exception as exc:
        raise PdfProcessingError("Impossible d'extraire le texte de ce PDF") from exc


def _clean_text(text):
    text = re.sub(r'[^\w\s.,;:!?()\[\]{}"\'/%+-]', ' ', text, flags=re.UNICODE)
    text = re.sub(r'[ \t]+', ' ', text)
    text = re.sub(r'\n{3,}', '\n\n', text)

    lines = [line.strip() for line in text.splitlines()]
    return '\n'.join(line for line in lines if line).strip()


def _detect_title(text):
    for line in text.splitlines():
        if line.strip():
            return line.strip()[:255]
    return 'Document sans titre'


def _count_words(text):
    return len(re.findall(r'\b\w+\b', text, flags=re.UNICODE))


def _delete_file(file_path):
    path = Path(file_path)

    if path.exists() and path.is_file():
        os.remove(path)
