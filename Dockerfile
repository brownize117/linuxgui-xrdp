FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

RUN useradd -m -s /bin/bash linux \
 && echo 'linux:linuxgui' | chpasswd \
 && mkdir -p /etc/sudoers.d \
 && usermod -aG sudo linux \
 && echo 'linux ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/linux \
 && chmod 440 /etc/sudoers.d/linux
RUN apt update -y && apt upgrade -y
RUN apt install xfce4 xfce4-terminal xfce4-goodies tigervnc-standalone-server -y
RUN apt install git wget curl python3 python3-pip autoconf automake build-essential sudo -y
RUN apt install freerdp2-x11 libssh2-1 libssl-dev libpango-1.0-0 libtelnet-dev libimlib2-dev libvncserver-dev pulseaudio libwebp-dev -y
RUN apt install -y python3-numpy
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && apt install -y ./google-chrome-stable_current_amd64.deb && rm -rf  ./google-chrome-stable_current_amd64.deb
WORKDIR /app/xrdp
RUN wget https://github.com/neutrinolabs/xrdp/releases/download/v0.10.5/xrdp-0.10.5.tar.gz \
 && tar xvzf xrdp-0.10.5.tar.gz && cd xrdp-0.10.5 && \
 wget https://raw.githubusercontent.com/neutrinolabs/xrdp/refs/heads/devel/scripts/install_xrdp_build_dependencies_with_apt.sh -O dec.sh && bash dec.sh
WORKDIR /app/xrdp/xrdp-0.10.5
RUN apt install libfuse3-dev libfdk-aac-dev libopus-dev libmp3lame-dev x264 libx264-dev libopenh264-dev -y
RUN ./bootstrap && \
 ./configure \
    --enable-ibus --enable-ipv6 --enable-jpeg --enable-fuse --enable-mp3lame \
    --enable-fdkaac --enable-opus --enable-rfxcodec --enable-painter \
    --enable-pixman --enable-utmp -with-imlib2 --with-freetype2 \
    --enable-tests --enable-x264 --enable-openh264 --enable-vsock
RUN make -j$(nproc) && \
 make install && \
 ln -s /usr/local/sbin/xrdp{,-sesman} /usr/sbin && \
 adduser --system --group --no-create-home --disabled-password --disabled-login --home /run/xrdp xrdp && \
 sed -i '/runtime_user=xrdp/ s/^[[:space:]]*#//; /runtime_group=xrdp/ s/^[[:space:]]*#//' /etc/xrdp/xrdp.ini && \
 sed -i '/^#SessionSockdirGroup=xrdp$/ s/^#//' /etc/xrdp/sesman.ini && \
 chmod 640 /etc/xrdp/rsakeys.ini && \
 chown root:xrdp /etc/xrdp/rsakeys.ini

RUN make-ssl-cert generate-default-snakeoil && \
 ln -sf /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/xrdp/cert.pem && \
 ln -sf /etc/ssl/private/ssl-cert-snakeoil.key /etc/xrdp/key.pem && \
 usermod -a -G ssl-cert xrdp


WORKDIR /app/xorgrdp
RUN wget https://github.com/neutrinolabs/xorgxrdp/releases/download/v0.10.5/xorgxrdp-0.10.5.tar.gz && \
 tar xvzf xorgxrdp-0.10.5.tar.gz && \
 mv xorgxrdp-0.10.5 xorgxrdp && cd xorgxrdp && \
 wget https://raw.githubusercontent.com/neutrinolabs/xorgxrdp/refs/heads/devel/scripts/install_xorgxrdp_build_dependencies_with_apt.sh && bash install_xorgxrdp_build_dependencies_with_apt.sh && \
 ./bootstrap && \
 ./configure --enable-glamor

RUN  cd xorgxrdp && make -j$(nproc) \
 && make install \
 && sed -i 's|^param=Xorg$|param=/usr/lib/xorg/Xorg|' /etc/xrdp/sesman.ini \
 && echo "startxfce4" > /etc/xrdp/startwm.sh \
 && chmod 777 /etc/xrdp/startwm.sh

RUN apt install dbus-x11 -y
WORKDIR /root
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh
CMD ["bash", "/app/start.sh"]
