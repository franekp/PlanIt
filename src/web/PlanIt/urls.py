from django.conf.urls import url, include
from rest_framework.urlpatterns import format_suffix_patterns
from rest_framework import routers
from PlanIt import views


router = routers.SimpleRouter()
router.register(
    'day/(?P<day>[0-9]{4}-[0-9]{2}-[0-9]{2})/cards',
    views.CardsByDayViewSet, base_name='cards-by-day')
router.register(
    'parking_lot/cards', views.CardsInParkingLotViewSet,
    base_name='cards-in-parking-lot')


urlpatterns = format_suffix_patterns([
    url(r'^', include(router.urls)),
    url(r'^$', views.api_root),
    url(r'^current_week/', views.current_week, name='current_week'),
    url(r'^profile_photo/', views.profile_photo, name='profile_photo'),
    url(
        r'^is_user_logged_in/', views.is_user_logged_in,
        name='is_user_logged_in',
    ),
])
