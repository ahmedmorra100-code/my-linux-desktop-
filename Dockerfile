FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV XRES=1280x800x24
ENV LANG=en_US.UTF-8

# تثبيت XFCE وسطح المكتب وأدوات VNC والبايثون
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
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

# جعل noVNC يفتح الصفحة الرئيسية تلقائياً
RUN ln -s /usr/share/novnc/vnc_auto.html /usr/share/novnc/index.html

# إنشاء مستخدم عادي
RUN useradd -m -s /bin/bash user && echo "user:password" | chpasswd

WORKDIR /home/user

EXPOSE 6080

COPY start.sh /usr/local/bin/start-desktop
RUN chmod +x /usr/local/bin/start-desktop

ENTRYPOINT ["/usr/local/bin/start-desktop"]
