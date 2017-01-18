from django.contrib import admin
from PlanIt.models import Card


class CardAdmin(admin.ModelAdmin):
    list_display = ('created', 'day', 'text', 'user')


admin.site.register(Card, CardAdmin)
