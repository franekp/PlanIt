from datetime import date, datetime
import time

from rest_framework.reverse import reverse
from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework.decorators import api_view

from PlanIt.serializers import CardSerializer
from PlanIt.models import Card


class CardsByDayViewSet(viewsets.ModelViewSet):
    serializer_class = CardSerializer
    pagination_class = None

    def get_queryset(self):
        day = datetime.strptime(self.kwargs['day'], '%Y-%m-%d').date()
        return Card.objects.filter(user=self.request.user, day=day)

    def perform_create(self, serializer):
        day = datetime.strptime(self.kwargs['day'], '%Y-%m-%d').date()
        serializer.save(user=self.request.user, day=day)

    def perform_update(self, serializer):
        day = datetime.strptime(self.kwargs['day'], '%Y-%m-%d').date()
        serializer.save(user=self.request.user, day=day)


class CardsInParkingLotViewSet(viewsets.ModelViewSet):
    serializer_class = CardSerializer
    pagination_class = None

    def get_queryset(self):
        return Card.objects.filter(user=self.request.user, day=None)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user, day=None)

    def perform_update(self, serializer):
        serializer.save(user=self.request.user, day=None)


@api_view(['GET'])
def api_root(request, format=None):
    return Response({
        'cards-by-day': reverse(
            'cards-by-day-list', request=request, format=format,
            kwargs=dict(day=datetime.now().strftime('%Y-%m-%d'))),
        'cards-in-parking-lot': reverse(
            'cards-in-parking-lot-list', request=request, format=format)
    })
