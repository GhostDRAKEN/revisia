from django.conf import settings
from django.db import models


class Document(models.Model):
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='documents',
    )
    title = models.CharField(max_length=255)
    page_count = models.PositiveIntegerField(default=0)
    word_count = models.PositiveIntegerField(default=0)
    extracted_text = models.TextField()
    original_filename = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title