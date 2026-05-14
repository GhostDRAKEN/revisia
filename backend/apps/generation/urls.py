from django.urls import path
from apps.generation.views import QuizGenerationView, SummaryGenerationView

urlpatterns = [
    path('quiz/', QuizGenerationView.as_view(), name='generate-quiz'),
    path('summary/', SummaryGenerationView.as_view(), name='generate-summary'),
]