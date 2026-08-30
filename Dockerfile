FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0
ENV RESOLUTION=1280x800x24

# 1. تثبيت واجهة XFCE4 والتطبيقات وكافة مكتبات Chromium الـ 15 المفقودة
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    sudo \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    ca-certificates \
    xserver-xorg \
    xvfb \
    x11vnc \
    novnc \
    net-tools \
    dbus-x11 \
    xfce4 \
    xfce4-terminal \
    libnspr4 \
    libnss3 \
    libgbm1 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libatspi0 \
    libcups2 \
    libdrm2 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libpango-1.0-0 \
    libasound2 \
    libx11-xcb1 \
    libdbus-1-3 \
    libxkbcommon0 \
    libxcb-dri3-0 \
    && rm -rf /var/lib/apt/lists/*

# 2. إنشاء المستخدم وإعطائه صلاحيات Sudo كاملة وبدون كلمة سر (Full Root Privilege)
RUN useradd -m -s /bin/bash user && \
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 3. تثبيت Playwright ومتصفح Chromium
RUN pip3 install --no-cache-dir --break-system-packages playwright asyncio

USER user
WORKDIR /home/user

RUN python3 -m playwright install chromium

# 4. نسخ ملف التشغيل وتحديد الأذونات
COPY --chown=user:user start.sh /home/user/start.sh
RUN chmod +x /home/user/start.sh

EXPOSE 6080

CMD ["/home/user/start.sh"]

