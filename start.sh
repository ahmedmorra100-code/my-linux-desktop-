#!/usr/bin/env bash

set -Eeuo pipefail

export DISPLAY=:1
export HOME=/root
export USER=root
export LOGNAME=root

SCREEN_SIZE="${XRES:-1280x800x24}"
WEB_PORT="${PORT:-6080}"

cleanup() {
    kill 0 2>/dev/null || true
}

trap cleanup EXIT INT TERM

echo "Starting virtual display..."
Xvfb :1 -screen 0 "$SCREEN_SIZE" -ac +extension GLX +render -noreset &
sleep 2

echo "Starting D-Bus..."
if command -v dbus-daemon >/dev/null 2>&1; then
    dbus-daemon --system --fork || true
fi

echo "Starting VNC server without password..."
x11vnc \
    -display :1 \
    -forever \
    -shared \
    -nopw \
    -rfbport 5900 \
    -listen 127.0.0.1 \
    -xkb \
    -noxrecord \
    -noxfixes \
    -noxdamage \
    -repeat \
    -permitfiletransfer \
    -tightfilexfer &

sleep 2

echo "Starting XFCE desktop as root..."
dbus-launch --exit-with-session startxfce4 >/tmp/xfce.log 2>&1 &

sleep 5

echo "Starting noVNC on port ${WEB_PORT}..."
/usr/share/novnc/utils/novnc_proxy \
    --web /usr/share/novnc \
    --listen "0.0.0.0:${WEB_PORT}" \
    --vnc localhost:5900 &

echo "Linux XFCE desktop is running."
echo "Port: ${WEB_PORT}"
echo "User: root"

wait -n
