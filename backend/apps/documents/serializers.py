from django.conf import settings
from rest_framework import serializers


class DocumentUploadSerializer(serializers.Serializer):
    file = serializers.FileField(
        required=True,
        error_messages={
            'required': 'Aucun fichier détecté',
            'empty': 'Aucun fichier détecté',
            'invalid': 'Aucun fichier détecté',
        },
    )

    def validate_file(self, value):
        if value.size > settings.MAX_UPLOAD_SIZE:
            raise serializers.ValidationError("Le fichier dépasse la limite de 10 MB")

        filename = value.name.lower()
        content_type = getattr(value, 'content_type', '')

        if not filename.endswith('.pdf') or 'pdf' not in content_type:
            raise serializers.ValidationError("Seuls les fichiers PDF sont acceptés")

        header = value.read(2048)
        value.seek(0)

        if not header.startswith(b'%PDF'):
            raise serializers.ValidationError("Seuls les fichiers PDF sont acceptés")

        return value