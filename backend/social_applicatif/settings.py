"""
Django settings for social_applicatif project.
Optimisés pour env containerisés (Podman) + NGINX en reverse-proxy.

Django 5.2.x
"""

from pathlib import Path
import os
import environ

# -------------------------------------------------------------------
# Bases
# -------------------------------------------------------------------
BASE_DIR = Path(__file__).resolve().parent.parent  # .../backend

env = environ.Env(
    DEBUG=(bool, False),
    SECRET_KEY=(str, "dev-only-change-me"),
    ALLOWED_HOSTS=(list, []),
    CORS_ALLOWED_ORIGINS=(list, []),
    CSRF_TRUSTED_ORIGINS=(list, []),
    # DB
    POSTGRES_HOST=(str, ""),
    POSTGRES_PORT=(str, "5432"),
    POSTGRES_DB=(str, "app"),
    POSTGRES_USER=(str, "app"),
    POSTGRES_PASSWORD=(str, ""),
)

# Charge un .env local optionnel (utile hors conteneur)
env_file = BASE_DIR / ".env"
if env_file.exists():
    environ.Env.read_env(str(env_file))

DEBUG = env("DEBUG")
SECRET_KEY = env("SECRET_KEY")

# -------------------------------------------------------------------
# ALLOWED_HOSTS
# -------------------------------------------------------------------
# Récupère la variable d'env ou applique des valeurs sûres par défaut
ALLOWED_HOSTS = env.list(
    "DJANGO_ALLOWED_HOSTS",
    default=["localhost", "127.0.0.1", "api", "web", "nginx", "preprod.social_applicatif.com"]
)

# -------------------------------------------------------------------
# Applications
# -------------------------------------------------------------------
INSTALLED_APPS = [
    # Django
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    # Tiers
    "rest_framework",
    "corsheaders",
    # Apps projet (à ajouter au fil de l’eau)
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    # CORS en premier après Session
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "social_applicatif.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "social_applicatif.wsgi.application"

# -------------------------------------------------------------------
# Base de données
# -------------------------------------------------------------------
if env("POSTGRES_HOST"):
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.postgresql",
            "HOST": env("POSTGRES_HOST"),
            "PORT": env("POSTGRES_PORT"),
            "NAME": env("POSTGRES_DB"),
            "USER": env("POSTGRES_USER"),
            "PASSWORD": env("POSTGRES_PASSWORD"),
        }
    }
else:
    # Fallback dev local : SQLite (fichier déjà présent dans ton image)
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": BASE_DIR / "db.sqlite3",
        }
    }

# -------------------------------------------------------------------
# Mots de passe
# -------------------------------------------------------------------
AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

# -------------------------------------------------------------------
# i18n / L10n / TZ
# -------------------------------------------------------------------
LANGUAGE_CODE = "fr-fr"
TIME_ZONE = "Europe/Paris"
USE_I18N = True
USE_TZ = True

# -------------------------------------------------------------------
# Static / Media
# -------------------------------------------------------------------
STATIC_URL = "static/"
STATIC_ROOT = BASE_DIR / "static"   # utile si collectstatic en prod
MEDIA_URL = "/media/"
MEDIA_ROOT = env("MEDIA_ROOT", default=str(BASE_DIR / "media"))

# -------------------------------------------------------------------
# CORS / CSRF (derrière NGINX)
# -------------------------------------------------------------------
CORS_ALLOWED_ORIGINS = env.list("CORS_ALLOWED_ORIGINS", default=[
    "https://preprod.social_applicatif.com",
])
CSRF_TRUSTED_ORIGINS = env.list("CSRF_TRUSTED_ORIGINS", default=[
    "https://preprod.social_applicatif.com",
])

# Si NGINX en frontal : transmettre le schéma pour que Django sache qu'on est en HTTPS
USE_X_FORWARDED_HOST = True
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")

# -------------------------------------------------------------------
# DRF (par défaut minimal)
# -------------------------------------------------------------------
REST_FRAMEWORK = {
    "DEFAULT_RENDERER_CLASSES": ["rest_framework.renderers.JSONRenderer"],
    "DEFAULT_PARSER_CLASSES": ["rest_framework.parsers.JSONParser"],
}
