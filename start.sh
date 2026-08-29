#!/usr/bin/env bash
set -e

VNC_PASS="${VNC_PASSWORD:-12345678}"
mkdir -p /run /home/user/.vnc
x11vnc -storepasswd "$VNC_PASS" /run/vnc.pass >/dev/null 2>&1 || true
chmod 600 /run/vnc.pass || true

echo "Starting Xvfb..."
Xvfb :1 -screen 0 ${XRES:-1280x800x24} &
sleep 1

echo "Starting XFCE Desktop..."
export DISPLAY=:1
export USER=user
export HOME=/home/user
su - user -c "DISPLAY=:1 startxfce4" &
sleep 2

echo "Starting x11vnc..."
x11vnc -display :1 -repeat -forever -shared -rfbauth /run/vnc.pass -rfbport 5900 &
sleep 1

echo "Starting noVNC on port ${PORT:-6080}..."
exec /usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen ${PORT:-6080}
