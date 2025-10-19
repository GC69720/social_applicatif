#!/usr/bin/env bash
set -euo pipefail

# Optionnel : collecte des statiques si tu utilises Django collectstatic
if [ "${RUN_COLLECTSTATIC:-0}" = "1" ]; then
  echo "[entrypoint] collectstatic…"
  python manage.py collectstatic --noinput
fi

echo "[entrypoint] migrations…"
python manage.py migrate --noinput

# Si un fichier uWSGI ini est monté (prod), on l’utilise
if [ -f /etc/uwsgi/uwsgi.ini ]; then
  echo "[entrypoint] starting uWSGI via ini…"
  exec uwsgi --ini /etc/uwsgi/uwsgi.ini
else
  echo "[entrypoint] starting uWSGI (fallback http-socket:8000)…"
  exec uwsgi --http :8000 --wsgi-file config/wsgi.py --master --processes 4 --threads 2 --die-on-term
fi
