#!/bin/bash

# 1. تشغيل الشاشة الوهمية
Xvfb :0 -screen 0 $RESOLUTION &
sleep 1

# 2. تشغيل واجهة سطح المكتب XFCE
startxfce4 &
sleep 1

# 3. تشغيل خادم VNC
x11vnc -display :0 -forever -shared -rfbport 5900 -nopw &
sleep 1

# 4. تشغيل خادم noVNC لعرض سطح المكتب في المتصفح
/usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 6080
