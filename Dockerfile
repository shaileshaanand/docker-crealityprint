FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# set version label
ARG BUILD_DATE
ARG VERSION
ARG PRUSASLICER_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="shaileshaanand"

# title
ENV TITLE=PrusaSlicer \
  SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
  firefox-esr jq && \
  # gstreamer1.0-alsa \
  # gstreamer1.0-gl \
  # gstreamer1.0-gtk3 \
  # gstreamer1.0-libav \
  # gstreamer1.0-plugins-bad \
  # gstreamer1.0-plugins-base \
  # gstreamer1.0-plugins-good \
  # gstreamer1.0-plugins-ugly \
  # gstreamer1.0-pulseaudio \
  # gstreamer1.0-qt5 \
  # gstreamer1.0-tools \
  # gstreamer1.0-x \
  # libgstreamer1.0 \
  # libgstreamer-plugins-bad1.0 \
  # libgstreamer-plugins-base1.0 \
  # libwebkit2gtk-4.0-37 \
  # libwx-perl && \
  echo "**** install prusaslicer from appimage ****" && \
  if [ -z ${PRUSASLICER_VERSION+x} ]; then \
  PRUSASLICER_VERSION=$(curl -sX GET "https://api.github.com/repos/prusa3d/PrusaSlicer/releases/latest" \
  | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  cd /tmp && \
  echo "**** install prusaslicer version ${PRUSASLICER_VERSION} ****" && \
  curl -o \
  /tmp/prusa.app -L \
  $(curl -L "https://api.github.com/repos/prusa3d/PrusaSlicer/releases/tags/${PRUSASLICER_VERSION}" | jq -r '.assets[] | select (.name | test("linux-x64-GTK3-.*\\.AppImage"))|.browser_download_url') && \
  chmod +x /tmp/prusa.app && \
  ./prusa.app --appimage-extract && \
  mv squashfs-root /opt/prusaslicer && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
  /config/.cache \
  /config/.launchpadlib \
  /var/lib/apt/lists/* \
  /var/tmp/* \
  /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config
