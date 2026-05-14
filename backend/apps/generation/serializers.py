from rest_framework import serializers


class QuizGenerationSerializer(serializers.Serializer):
    document_id = serializers.CharField(
        required=True,
        error_messages={
            'required': 'Identifiant du document requis',
            'blank': 'Identifiant du document requis',
            'null': 'Identifiant du document requis',
        },
    )
    question_count = serializers.IntegerField(required=False, min_value=1, max_value=50, default=10)


class SummaryGenerationSerializer(serializers.Serializer):
    document_id = serializers.CharField(
        required=True,
        error_messages={
            'required': 'Identifiant du document requis',
            'blank': 'Identifiant du document requis',
            'null': 'Identifiant du document requis',
        },
    )


class QuizSerializer(serializers.Serializer):
    quiz_id = serializers.SerializerMethodField()
    title = serializers.CharField()
    question_count = serializers.IntegerField()
    quiz = serializers.JSONField()

    def get_quiz_id(self, obj):
        return f'quiz_{obj.id}'


class SummarySerializer(serializers.Serializer):
    summary_id = serializers.SerializerMethodField()
    title = serializers.CharField()
    key_points = serializers.JSONField()
    full_summary = serializers.CharField()
    word_count = serializers.IntegerField()

    def get_summary_id(self, obj):
        return f'sum_{obj.id}'
