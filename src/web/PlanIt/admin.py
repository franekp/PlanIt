from django.contrib import admin

from .models import Snippet

class SnippetAdmin(admin.ModelAdmin):
    list_display = ('created','title','data','owner')


admin.site.register(Snippet, SnippetAdmin)
# Register your models here.
