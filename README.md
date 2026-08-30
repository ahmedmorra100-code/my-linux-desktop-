FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV XRES=1280x800x24
ENV LANG=en_US.UTF-8

# 1. تثبيت سطح المكتب وأدوات النظام و sudo
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    sudo \
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

# 2. تثبيت المكتبات وتنزيل متصفح Chromium بملفاته كاملة أثناء البناء
RUN pip3 install --no-cache-dir --break-system-packages playwright curl_cffi nest_asyncio \
    && playwright install chromium \
    && playwright install-deps chromium

# 3. توجيه الدخول التلقائي في noVNC بالباسورد
RUN echo '<!DOCTYPE html><html><head><meta http-equiv="refresh" content="0; url=/vnc_auto.html?autoconnect=true&password=12345678"></head><body></body></html>' > /usr/share/novnc/index.html

# 4. [السر هنا]: إنشاء المستخدم ومنحه صلاحيات الـ Root و Sudo كاملة بدون طلب أي كلمة سر
RUN useradd -m -s /bin/bash -G sudo user \
    && echo "user:password" | chpasswd \
    && echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/user

COPY run.py /home/user/run.py
COPY start.sh /usr/local/bin/start-desktop

RUN chmod +x /usr/local/bin/start-desktop \
    && chown -R user:user /home/user

EXPOSE 6080

ENTRYPOINT ["/usr/local/bin/start-desktop"]
