from django.db import models
from django.conf import settings


class Card(models.Model):
    created = models.DateTimeField(auto_now_add=True)
    day = models.DateField(blank=True, null=True)
    text = models.TextField(max_length=200, blank=True)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, related_name='cards', on_delete=models.CASCADE)
    position_in_list = models.IntegerField(blank=True, null=True)

    class Meta:
        ordering = ('created',)
