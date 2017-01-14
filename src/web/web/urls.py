from django.conf.urls import url
from web.views import hello_world

urlpatterns = [
    url(r'^$', hello_world),
]
