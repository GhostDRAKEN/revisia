from django.urls import path
from apps.documents.views import DocumentUploadView

urlpatterns = [
    path('upload/', DocumentUploadView.as_view(), name='document-upload'),
]