FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV XRES=1280x800x24
ENV LANG=en_US.UTF-8

# 1. تثبيت سطح المكتب XFCE وأدوات النظام و noVNC
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    python3-dev \
    ca-certificates \
    supervisor \
    xserver-xorg \
    xvfb \
    x11vnc \
    dbus-x11 \
    xfce4 \
    xfce4-terminal \
    novnc \
    net-tools \
    tmux \
    nano \
    locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

# 2. تثبيت مكتبات البايثون ومحرك Chromium لـ Playwright مع حزم النظام التابعة له مسبقاً
RUN pip3 install --no-cache-dir --break-system-packages playwright curl_cffi nest_asyncio \
    && playwright install chromium \
    && playwright install-deps chromium

# 3. توجيه الدخول التلقائي في noVNC بالباسورد الافتراضي
RUN echo '<!DOCTYPE html><html><head><meta http-equiv="refresh" content="0; url=/vnc_auto.html?autoconnect=true&password=12345678"></head><body></body></html>' > /usr/share/novnc/index.html

# 4. إنشاء المستخدم وضبط مجلد العمل
RUN useradd -m -s /bin/bash user && echo "user:password" | chpasswd

WORKDIR /home/user

# نسخ ملف البوت وملف التشغيل تلقائياً داخل الحاوية
COPY run.py /home/user/run.py
COPY start.sh /usr/local/bin/start-desktop

RUN chmod +x /usr/local/bin/start-desktop \
    && chown -R user:user /home/user

EXPOSE 6080

ENTRYPOINT ["/usr/local/bin/start-desktop"]
