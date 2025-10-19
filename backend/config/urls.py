from django.contrib import admin
from django.urls import path
from core.health import health

urlpatterns = [
    path("admin/", admin.site.urls),
    path("health", health),
]
