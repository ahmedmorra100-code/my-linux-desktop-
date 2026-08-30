FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0
ENV RESOLUTION=1280x800x24

# تثبيت الأدوات وكافة مكتبات Chromium الـ 15 بحساب Root المباشر
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash sudo curl wget git python3 python3-pip ca-certificates \
    xserver-xorg xvfb x11vnc novnc net-tools dbus-x11 xfce4 xfce4-terminal \
    libnspr4 libnss3 libgbm1 libatk1.0-0 libatk-bridge2.0-0 libatspi0 libcups2 \
    libdrm2 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libpango-1.0-0 \
    libasound2 libx11-xcb1 libdbus-1-3 libxkbcommon0 libxcb-dri3-0 \
    && rm -rf /var/lib/apt/lists/*

# تثبيت Playwright والمتصفح داخل صورة السيرفر
RUN pip3 install --no-cache-dir --break-system-packages playwright asyncio
RUN python3 -m playwright install chromium

WORKDIR /root

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 6080

CMD ["/start.sh"]
