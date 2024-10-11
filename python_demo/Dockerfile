FROM rust:1.79.0 AS builder

SHELL ["/usr/bin/bash", "-c"]
RUN apt-get update && apt-get install -y openssl libssl-dev git libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev  libgstreamer-plugins-bad1.0-dev
WORKDIR /src
RUN git clone https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs.git
WORKDIR /src/gst-plugins-rs
RUN cargo install cargo-c
RUN cargo build -p gst-plugin-webrtc
RUN cargo cbuild -p gst-plugin-webrtchttp

FROM ubuntu:24.10 AS builder2

WORKDIR /novathena/webrtc
#COPY --from=builder --chown=nobody:nogroup /src/gst-plugins-rs/target/ .
COPY --from=builder /src/gst-plugins-rs/target/ .
ENV GST_PLUGIN_PATH=/novathena/webrtc

SHELL ["/bin/bash", "-c"]
ENV LC_ALL=C.UTF-8
ENV LC_CTYPE=C.UTF-8

RUN <<EOF
apt update
apt -qy upgrade
# install gstreamer
apt -y --no-install-recommends install gobject-introspection*
apt -y --no-install-recommends install libgirepository*
apt -y --no-install-recommends install gstreamer*
apt -y --no-install-recommends install libgstreamer*
apt -y --no-install-recommends install libgstrtspserver-1.0-dev
apt -y --no-install-recommends install libges-1.0-dev
apt -y --no-install-recommends install gstreamer1.0-nice
apt -y --no-install-recommends install openssl
apt -y --no-install-recommends install ca-certificates
 install python runtime
apt -qy install --no-install-recommends python3-venv
apt -qy install --no-install-recommends python3-pip
apt -qy install --no-install-recommends python3-setuptools
apt -qy install --no-install-recommends python3-wheel
apt -qy install --no-install-recommends python3-poetry

apt install -y vim curl inetutils-ping ffmpeg sudo
EOF

RUN <<EOF
apt -qy autoremove
rm -rf /var/lib/apt/lists/*
rm -rf ~/.cache/pip
EOF

