from rest_framework import status
from rest_framework.exceptions import AuthenticationFailed, NotAuthenticated
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.generation.serializers import (
    QuizGenerationSerializer,
    QuizSerializer,
    SummaryGenerationSerializer,
    SummarySerializer,
)
from apps.generation.services import (
    DocumentNotFoundError,
    GenerationError,
    GroqTimeoutError,
    ServerGenerationError,
    generate_quiz,
    generate_summary,
)


class AuthenticatedAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def handle_exception(self, exc):
        if isinstance(exc, (AuthenticationFailed, NotAuthenticated)):
            return Response({
                'success': False,
                'error': 'Authentification requise',
                'code': 'AUTHENTICATION_REQUIRED'
            }, status=status.HTTP_401_UNAUTHORIZED)

        return super().handle_exception(exc)


class QuizGenerationView(AuthenticatedAPIView):
    def post(self, request):
        serializer = QuizGenerationSerializer(data=request.data)

        if not serializer.is_valid():
            return _validation_error_response(serializer.errors)

        try:
            quiz = generate_quiz(
                document_id=serializer.validated_data['document_id'],
                question_count=serializer.validated_data['question_count'],
                user=request.user,
            )
        except DocumentNotFoundError as exc:
            return _error_response(str(exc), 'DOCUMENT_NOT_FOUND', status.HTTP_404_NOT_FOUND)
        except GroqTimeoutError as exc:
            return _error_response(str(exc), 'GROQ_TIMEOUT', status.HTTP_408_REQUEST_TIMEOUT)
        except GenerationError as exc:
            return _error_response(str(exc), 'GENERATION_ERROR', status.HTTP_400_BAD_REQUEST)
        except ServerGenerationError as exc:
            return _error_response(str(exc), 'SERVER_ERROR', status.HTTP_500_INTERNAL_SERVER_ERROR)
        except Exception:
            return _error_response('Une erreur est survenue, réessayez', 'SERVER_ERROR', status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response({
            'success': True,
            'data': QuizSerializer(quiz).data,
            'message': 'Quiz généré avec succès'
        }, status=status.HTTP_200_OK)


class SummaryGenerationView(AuthenticatedAPIView):
    def post(self, request):
        serializer = SummaryGenerationSerializer(data=request.data)

        if not serializer.is_valid():
            return _validation_error_response(serializer.errors)

        try:
            summary = generate_summary(
                document_id=serializer.validated_data['document_id'],
                user=request.user,
            )
        except DocumentNotFoundError as exc:
            return _error_response(str(exc), 'DOCUMENT_NOT_FOUND', status.HTTP_404_NOT_FOUND)
        except GroqTimeoutError as exc:
            return _error_response(str(exc), 'GROQ_TIMEOUT', status.HTTP_408_REQUEST_TIMEOUT)
        except GenerationError as exc:
            return _error_response(str(exc), 'GENERATION_ERROR', status.HTTP_400_BAD_REQUEST)
        except ServerGenerationError as exc:
            return _error_response(str(exc), 'SERVER_ERROR', status.HTTP_500_INTERNAL_SERVER_ERROR)
        except Exception:
            return _error_response('Une erreur est survenue, réessayez', 'SERVER_ERROR', status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response({
            'success': True,
            'data': SummarySerializer(summary).data,
            'message': 'Résumé généré avec succès'
        }, status=status.HTTP_200_OK)


def _validation_error_response(errors):
    return _error_response(_format_serializer_error(errors), 'VALIDATION_ERROR', status.HTTP_400_BAD_REQUEST)


def _error_response(error, code, response_status):
    return Response({
        'success': False,
        'error': error,
        'code': code
    }, status=response_status)


def _format_serializer_error(errors):
    document_errors = errors.get('document_id')

    if document_errors:
        return str(document_errors[0])

    first_errors = next(iter(errors.values()), None)

    if first_errors:
        return str(first_errors[0])

    return 'Identifiant du document requis'
