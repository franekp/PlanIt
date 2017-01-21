from django.contrib.auth.models import User
from rest_framework import serializers
from .models import Card


class CardSerializer(serializers.ModelSerializer):
    class Meta:
        model = Card
        fields = ('id', 'text', 'created',)
        read_only_fields = ('id', 'created',)
