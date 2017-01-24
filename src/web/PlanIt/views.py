from datetime import date, datetime, timedelta
import time

from rest_framework.reverse import reverse
from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework.decorators import api_view
from django.shortcuts import get_object_or_404
from allauth.socialaccount.models import SocialAccount
import hashlib
from django.http import HttpResponse

from PlanIt.serializers import CardSerializer
from PlanIt.models import Card


class CardsByDayViewSet(viewsets.ModelViewSet):
    serializer_class = CardSerializer
    pagination_class = None

    def get_object(self):
        pk = int(self.kwargs['pk'])
        return get_object_or_404(Card.objects, user=self.request.user, pk=pk)

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

    def get_object(self):
        pk = int(self.kwargs['pk'])
        return get_object_or_404(Card.objects, user=self.request.user, pk=pk)

    def get_queryset(self):
        return Card.objects.filter(user=self.request.user, day=None)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user, day=None)

    def perform_update(self, serializer):
        serializer.save(user=self.request.user, day=None)


@api_view(['GET'])
def api_root(request, format=None):
    return Response({
        'cards-today': reverse(
            'cards-by-day-list', request=request, format=format,
            kwargs=dict(day=datetime.now().strftime('%Y-%m-%d'))),
        'cards-in-parking-lot': reverse(
            'cards-in-parking-lot-list', request=request, format=format)
    })

@api_view(['GET'])
def current_user(request, format=None):
    def get_profile_photo():
        fb_uid = SocialAccount.objects.filter(user_id=request.user.id, provider='facebook')
        if len(fb_uid):
            return "http://graph.facebook.com/{}/picture?width=40&height=40".format(fb_uid[0].uid)
        return "http://www.gravatar.com/avatar/{}?s=40".format(hashlib.md5(request.user.email.encode()).hexdigest())

    if request.user.is_authenticated:
        return Response({
            "authenticated": True,
            "profile_photo": get_profile_photo(),
            "username": request.user.get_username(),
            "full_name": request.user.get_full_name(),
        })
    else:
        return Response({"authenticated": False})

@api_view(['GET'])
def current_week(request, format=None):
    dates = [datetime.now() + timedelta(days=days) for days in range(7)]
    dates = [d.strftime('%Y-%m-%d') for d in dates]
    return Response({"days": dates})
