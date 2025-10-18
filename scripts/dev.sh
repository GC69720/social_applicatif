#!/usr/bin/env bash
# Dev helper (Windows Git Bash) — start/stop backend (Django), frontend (Vite) & mobile (Expo)
# Usage:
#   scripts/dev.sh start [back|front|mobile|all]
#   scripts/dev.sh stop  [back|front|mobile|all]
#   scripts/dev.sh restart [back|front|mobile|all]
#   scripts/dev.sh status
#   scripts/dev.sh logs [back|front|mobile]

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT_DIR/scripts/logs"
mkdir -p "$LOG_DIR"

DJANGO_PORT="${DJANGO_PORT:-8000}"
VITE_PORT="${VITE_PORT:-5173}"
# Expo/Metro ports
EXPO_PORT="${EXPO_PORT:-19000}"   # Expo dev server
EXPO_WS_PORT="${EXPO_WS_PORT:-19001}"
EXPO_WEB_PORT="${EXPO_WEB_PORT:-19002}"
METRO_PORT="${METRO_PORT:-8081}"  # React Native Metro bundler

msg() { printf "[dev] %s\n" "$*"; }

kill_port() {
  local port="$1"
  local pids
  mapfile -t pids < <(netstat -ano | grep -E "LISTENING|ESTABLISHED|TIME_WAIT|CLOSE_WAIT" | grep ":${port}\b" | awk '{print $NF}' | sort -u)
  if [[ "${#pids[@]}" -eq 0 ]]; then
    msg "rien à tuer sur le port ${port}"
    return 0
  fi
  for pid in "${pids[@]}"; do
    [[ "$pid" =~ ^[0-9]+$ ]] || continue
    cmd.exe /c taskkill /F /PID "$pid" >/dev/null 2>&1 || true
  done
  msg "killed processes on port ${port}: ${pids[*]}"
}

status_port() { netstat -ano | grep ":${1}\b" || true; }

ensure_backend_env() {
  if [[ ! -f "$ROOT_DIR/backend/manage.py" ]]; then
    msg "ERREUR: backend/manage.py introuvable."
    exit 1
  fi
  if [[ ! -f "$ROOT_DIR/backend/.venv/Scripts/activate" ]]; then
    msg "ERREUR: venv introuvable (backend/.venv)."
    msg "  python -m venv backend/.venv && source backend/.venv/Scripts/activate && pip install Django"
    exit 1
  fi
}

ensure_front_dir() {
  if [[ ! -f "$ROOT_DIR/frontend/package.json" ]]; then
    msg "front web absent (frontend/package.json introuvable) → ignoré"
    return 1
  fi
  return 0
}

ensure_mobile_dir() {
  if [[ ! -f "$ROOT_DIR/mobile/package.json" ]]; then
    msg "mobile absent (mobile/package.json introuvable) → ignoré"
    return 1
  fi
  return 0
}

backend_start() {
  ensure_backend_env
  msg "→ stop backend (port ${DJANGO_PORT})"
  kill_port "$DJANGO_PORT"
  msg "→ start backend Django"
  ( cd "$ROOT_DIR/backend" \
    && source .venv/Scripts/activate \
    && python manage.py runserver "127.0.0.1:${DJANGO_PORT}" \
  ) >"$LOG_DIR/backend.log" 2>&1 &
  sleep 1
  msg "backend lancé (logs: scripts/logs/backend.log)"
}

backend_stop() { msg "→ stop backend (port ${DJANGO_PORT})"; kill_port "$DJANGO_PORT"; }

frontend_start() {
  if ! ensure_front_dir; then return 0; fi
  msg "→ stop frontend (port ${VITE_PORT})"
  kill_port "$VITE_PORT"
  msg "→ start frontend (Vite)"
  ( cd "$ROOT_DIR/frontend" && npm run dev ) >"$LOG_DIR/frontend.log" 2>&1 &
  sleep 1
  msg "frontend lancé (logs: scripts/logs/frontend.log)"
}

frontend_stop() { msg "→ stop frontend (port ${VITE_PORT})"; kill_port "$VITE_PORT"; }

mobile_start() {
  if ! ensure_mobile_dir; then return 0; fi
  msg "→ stop mobile (ports ${EXPO_PORT}/${EXPO_WS_PORT}/${EXPO_WEB_PORT}/${METRO_PORT})"
  kill_port "$EXPO_PORT"; kill_port "$EXPO_WS_PORT"; kill_port "$EXPO_WEB_PORT"; kill_port "$METRO_PORT"
  msg "→ start mobile (Expo)"
  # Expo affiche un QR code; consulte 'scripts/dev.sh logs mobile' pour le voir.
  ( cd "$ROOT_DIR/mobile" && npm run start ) >"$LOG_DIR/mobile.log" 2>&1 &
  sleep 2
  msg "mobile lancé (logs: scripts/logs/mobile.log)"
}

mobile_stop() {
  msg "→ stop mobile (ports ${EXPO_PORT}/${EXPO_WS_PORT}/${EXPO_WEB_PORT}/${METRO_PORT})"
  kill_port "$EXPO_PORT"; kill_port "$EXPO_WS_PORT"; kill_port "$EXPO_WEB_PORT"; kill_port "$METRO_PORT"
}

show_status() {
  msg "Backend (${DJANGO_PORT}):";  status_port "$DJANGO_PORT" || true
  msg "Frontend (${VITE_PORT}):";  status_port "$VITE_PORT" || true
  msg "Mobile Expo (${EXPO_PORT}, ${EXPO_WS_PORT}, ${EXPO_WEB_PORT}) & Metro (${METRO_PORT}):"
  status_port "$EXPO_PORT" || true; status_port "$EXPO_WS_PORT" || true; status_port "$EXPO_WEB_PORT" || true; status_port "$METRO_PORT" || true
  msg "(si aucune ligne, rien n'écoute ces ports)"
}

tail_logs() {
  case "${1:-back}" in
    back|backend)   msg "Logs backend:";  tail -n +1 -f "$LOG_DIR/backend.log" ;;
    front|frontend) msg "Logs frontend:"; tail -n +1 -f "$LOG_DIR/frontend.log" ;;
    mobile)         msg "Logs mobile:";   tail -n +1 -f "$LOG_DIR/mobile.log" ;;
    *) msg "Choisis 'back' | 'front' | 'mobile'"; exit 1 ;;
  esac
}

ACTION="${1:-help}"
TARGET="${2:-all}"

case "$ACTION" in
  start)
    case "$TARGET" in
      back|backend)   backend_start ;;
      front|frontend) frontend_start ;;
      mobile)         mobile_start ;;
      all)            backend_start; frontend_start; mobile_start ;;
      *) msg "start [back|front|mobile|all]"; exit 1 ;;
    esac
    ;;
  stop)
    case "$TARGET" in
      back|backend)   backend_stop ;;
      front|frontend) frontend_stop ;;
      mobile)         mobile_stop ;;
      all)            backend_stop; frontend_stop; mobile_stop ;;
      *) msg "stop [back|front|mobile|all]"; exit 1 ;;
    esac
    ;;
  restart)
    case "$TARGET" in
      back|backend)   backend_stop; backend_start ;;
      front|frontend) frontend_stop; frontend_start ;;
      mobile)         mobile_stop; mobile_start ;;
      all)            backend_stop; frontend_stop; mobile_stop; backend_start; frontend_start; mobile_start ;;
      *) msg "restart [back|front|mobile|all]"; exit 1 ;;
    esac
    ;;
  status) show_status ;;
  logs)   tail_logs "${2:-back}" ;;
  help|--help|-h)
    cat <<EOF
Usage:
  scripts/dev.sh start [back|front|mobile|all]
  scripts/dev.sh stop  [back|front|mobile|all]
  scripts/dev.sh restart [back|front|mobile|all]
  scripts/dev.sh status
  scripts/dev.sh logs [back|front|mobile]

Env:
  DJANGO_PORT (def: 8000)
  VITE_PORT   (def: 5173)
  EXPO_PORT   (def: 19000), EXPO_WS_PORT (19001), EXPO_WEB_PORT (19002)
  METRO_PORT  (def: 8081)
Logs:
  scripts/logs/backend.log, frontend.log, mobile.log
EOF
    ;;
  *) msg "Commande inconnue: $ACTION (essaie: help)"; exit 1 ;;
esac
