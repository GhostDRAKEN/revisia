from rest_framework import serializers
from django.contrib.auth import authenticate
from apps.users.models import User


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['first_name', 'email', 'password']

    def validate_email(self, value):
        if User.objects.filter(email=value.lower()).exists():
            raise serializers.ValidationError("Un compte existe déjà avec cet email")
        return value.lower()

    def create(self, validated_data):
        return User.objects.create_user(
            email=validated_data['email'],
            first_name=validated_data['first_name'],
            password=validated_data['password']
        )


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        email = data.get('email').lower()
        password = data.get('password')

        user = authenticate(username=email, password=password)

        if not user:
            raise serializers.ValidationError("Email ou mot de passe incorrect")

        if not user.is_active:
            raise serializers.ValidationError("Ce compte est désactivé")

        data['user'] = user
        return data


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'first_name', 'email', 'created_at']