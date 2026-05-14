from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken

from apps.users.serializers import RegisterSerializer, LoginSerializer, UserSerializer


def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'token': str(refresh.access_token),
        'refresh': str(refresh),
    }


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)

        if not serializer.is_valid():
            return Response({
                'success': False,
                'error': serializer.errors,
                'code': 'VALIDATION_ERROR'
            }, status=status.HTTP_400_BAD_REQUEST)

        user = serializer.save()
        tokens = get_tokens_for_user(user)

        return Response({
            'success': True,
            'data': {
                'token': tokens['token'],
                'user': UserSerializer(user).data
            },
            'message': 'Compte créé avec succès'
        }, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)

        if not serializer.is_valid():
            return Response({
                'success': False,
                'error': serializer.errors,
                'code': 'AUTH_ERROR'
            }, status=status.HTTP_401_UNAUTHORIZED)

        user = serializer.validated_data['user']
        tokens = get_tokens_for_user(user)

        return Response({
    'success': True,
    'data': {
        'token': tokens['token'],
        'refresh': tokens['refresh'],
        'user': UserSerializer(user).data
    },
    'message': 'Connexion réussie'
}, status=status.HTTP_200_OK)

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get('refresh')
            token = RefreshToken(refresh_token)
            token.blacklist()

            return Response({
                'success': True,
                'data': {},
                'message': 'Déconnexion réussie'
            }, status=status.HTTP_200_OK)

        except Exception:
            return Response({
                'success': False,
                'error': 'Token invalide ou déjà expiré',
                'code': 'TOKEN_ERROR'
            }, status=status.HTTP_400_BAD_REQUEST)