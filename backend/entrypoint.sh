#!/usr/bin/env bash
set -euo pipefail

echo "[entrypoint] 🐍 Initialisation du container Django..."

# --------------------------------------------------------------------
# 1️⃣  Attente optionnelle de la base de données (Postgres)
# --------------------------------------------------------------------
if command -v pg_isready >/dev/null 2>&1; then
  echo "[entrypoint] Vérification de la disponibilité de la base de données..."
  until pg_isready -h "${POSTGRES_HOST:-db}" -p "${POSTGRES_PORT:-5432}" -U "${POSTGRES_USER:-postgres}" >/dev/null 2>&1; do
    echo "[entrypoint] ⏳ DB non prête, nouvel essai dans 3s..."
    sleep 3
  done
  echo "[entrypoint] ✅ Base de données accessible."
fi

# --------------------------------------------------------------------
# 2️⃣  Migrations Django
# --------------------------------------------------------------------
echo "[entrypoint] 🚀 Application des migrations Django..."
python manage.py migrate --noinput

# --------------------------------------------------------------------
# 3️⃣  Collecte des fichiers statiques (si activée)
# --------------------------------------------------------------------
if [ "${RUN_COLLECTSTATIC:-0}" = "1" ]; then
  echo "[entrypoint] 📦 Collecte des fichiers statiques..."
  python manage.py collectstatic --noinput
fi

# --------------------------------------------------------------------
# 4️⃣  Lancement du serveur uWSGI
# --------------------------------------------------------------------
if [ -f /etc/uwsgi/uwsgi.ini ]; then
  echo "[entrypoint] ▶️  Lancement via fichier de config uWSGI (/etc/uwsgi/uwsgi.ini)..."
  exec uwsgi --ini /etc/uwsgi/uwsgi.ini
else
  echo "[entrypoint] ▶️  Lancement uWSGI par défaut (http-socket:8000)..."
  exec uwsgi \
    --http-socket :8000 \
    --module social_applicatif.wsgi \
    --master \
    --processes 4 \
    --threads 2 \
    --enable-threads \
    --vacuum \
    --harakiri 60 \
    --max-requests 5000 \
    --disable-logging
fi
