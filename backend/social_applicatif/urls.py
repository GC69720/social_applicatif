from django.contrib import admin
from django.urls import path
from .health import health

urlpatterns = [
    path("admin/", admin.site.urls),
    path("health", health),        # pour les healthchecks sur :8000/health
    path("api/health", health),    # accessible via NGINX sur /api/health
]
