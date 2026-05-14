from rest_framework import status
from rest_framework.exceptions import AuthenticationFailed, NotAuthenticated
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.documents.serializers import DocumentUploadSerializer
from apps.documents.services import PdfProcessingError, process_uploaded_pdf


class DocumentUploadView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def handle_exception(self, exc):
        if isinstance(exc, (AuthenticationFailed, NotAuthenticated)):
            return Response({
                'success': False,
                'error': 'Authentification requise',
                'code': 'AUTHENTICATION_REQUIRED'
            }, status=status.HTTP_401_UNAUTHORIZED)

        return super().handle_exception(exc)

    def post(self, request):
        serializer = DocumentUploadSerializer(data=request.data)

        if not serializer.is_valid():
            return Response({
                'success': False,
                'error': _format_serializer_error(serializer.errors),
                'code': 'VALIDATION_ERROR'
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            document = process_uploaded_pdf(
                uploaded_file=serializer.validated_data['file'],
                user=request.user,
            )
        except PdfProcessingError as exc:
            return Response({
                'success': False,
                'error': str(exc),
                'code': 'PDF_EXTRACTION_ERROR'
            }, status=status.HTTP_400_BAD_REQUEST)
        except Exception:
            return Response({
                'success': False,
                'error': 'Une erreur est survenue, réessayez',
                'code': 'SERVER_ERROR'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response({
            'success': True,
            'data': {
                'document_id': f'doc_{document.id}',
                'title': document.title,
                'page_count': document.page_count,
                'word_count': document.word_count,
                'extracted_text': document.extracted_text,
            },
            'message': 'Document traité avec succès'
        }, status=status.HTTP_200_OK)


def _format_serializer_error(errors):
    file_errors = errors.get('file')

    if file_errors:
        return str(file_errors[0])

    return "Aucun fichier détecté"
