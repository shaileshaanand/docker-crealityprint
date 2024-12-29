FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CREALITYPRINT_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="shaileshaanand"

# title
ENV TITLE=CrealityPrint \
  SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
  firefox-esr jq \
  libwebkit2gtk-4.1-0 &&\
  echo "**** install CrealityPrint from appimage ****" && \
  if [ -z ${CREALITYPRINT_VERSION+x} ]; then \
  CREALITYPRINT_VERSION=$(curl -sX GET "https://api.github.com/repos/CrealityOfficial/CrealityPrint/releases/latest" \
  | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  cd /tmp && \
  echo "**** install CrealityPrint version ${CREALITYPRINT_VERSION} ****" && \
  curl -o \
  /tmp/crealityprint.app -L \
  $(curl -L "https://api.github.com/repos/CrealityOfficial/CrealityPrint/releases/tags/${CREALITYPRINT_VERSION}" | jq -r '.assets[] | select (.name | test("Creality_Print.*\\.AppImage"))|.browser_download_url') && \
  chmod +x /tmp/crealityprint.app && \
  ./crealityprint.app --appimage-extract && \
  mv squashfs-root /opt/CrealityPrint && \
  KLIPPER_ESTIMATOR_VERSION=$(curl -sX GET "https://api.github.com/repos/Annex-Engineering/klipper_estimator/releases/latest" \
  | awk '/tag_name/{print $4;exit}' FS='[""]') && \
  echo "**** install klipper_estimator version ${KLIPPER_ESTIMATOR_VERSION} ****" && \
  curl -o \
  /usr/bin/klipper_estimator -L "https://github.com/Annex-Engineering/klipper_estimator/releases/download/${KLIPPER_ESTIMATOR_VERSION}/klipper_estimator_linux" && \
  chmod +x /usr/bin/klipper_estimator && \
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
