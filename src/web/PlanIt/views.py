from django.contrib.auth.models import User, Group
from rest_framework import viewsets
from PlanIt.serializers import UserSerializer, GroupSerializer
from django.views.decorators.csrf import csrf_exempt
from rest_framework.renderers import JSONRenderer
from rest_framework.parsers import JSONParser
from .models import Snippet
from .serializers import SnippetSerializer
from rest_framework import status
from rest_framework.decorators import APIView
from rest_framework.response import Response
from .serializers import UserSerializer
from rest_framework import generics
from rest_framework import permissions
from rest_framework import mixins
from .permissions import IsOwnerOrReadOnly
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.reverse import reverse
from rest_framework import renderers
from rest_framework.response import Response
from django.http import HttpResponse
import json

class SnippetHighlight(generics.GenericAPIView):
    queryset = Snippet.objects.all()
    renderer_classes = (renderers.StaticHTMLRenderer,)

    def get(self, request, *args, **kwargs):
        snippet = self.get_object()
        return Response(snippet.highlighted)


class UserList(generics.ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer


class UserDetail(generics.RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

class UserViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows users to be viewed or edited.
    """
    queryset = User.objects.all().order_by('-date_joined')
    serializer_class = UserSerializer


@api_view(['GET'])
def api_root(request, format=None):
    return Response({
        'users': reverse('user-list', request=request, format=format),
        'snippets': reverse('snippet-list', request=request, format=format)
    })

class GroupViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows groups to be viewed or edited.
    """
    queryset = Group.objects.all()
    serializer_class = GroupSerializer

class SnippetList(APIView):

    permission_classes = (permissions.IsAuthenticated,)
    queryset = Snippet.objects.all()
    serializer_class = SnippetSerializer
    def get(self, request):
        serializer = UserSerializer(request.user)
        queryset = Snippet.objects.filter(owner=request.user)
        result = []
        for q in queryset:
            result.append(q.title)
        return Response(result)

class SnippetDetail(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,
                      IsOwnerOrReadOnly,)
    queryset = Snippet.objects.all()
    serializer_class = SnippetSerializer


def notatki(request):
    print(request.user)
    queryset = Snippet.objects.filter(owner=request.user)
    serializer_class = SnippetSerializer
    return HttpResponse(queryset)

