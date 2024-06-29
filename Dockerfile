# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.19

# set version label
ARG BUILD_DATE
ARG VERSION
ARG DISKOVER_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

# environment settings
ENV DISKOVERDIR=/config/diskover.conf.d/diskover/
ENV DATABASE=/config/diskoverdb.sqlite3
ENV ES_HOST=elasticsearch

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    cargo \
    git \
    nodejs \
    npm \
    python3-dev && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    ncurses \
    php83-sqlite3 \
    python3 && \
  echo "**** configure php-fpm to pass env vars ****" && \
  sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php83/php-fpm.d/www.conf && \
  grep -qxF 'clear_env = no' /etc/php83/php-fpm.d/www.conf || echo 'clear_env = no' >> /etc/php83/php-fpm.d/www.conf && \
  echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php83/php-fpm.conf && \
  echo "**** install diskover ****" && \
  if [ -z ${DISKOVER_RELEASE+x} ]; then \
    DISKOVER_RELEASE=$(curl -sX GET "https://api.github.com/repos/diskoverdata/diskover-community/releases" \
    | jq -r '.[0] | .tag_name'); \
  fi && \
  curl -o \
    /tmp/diskover.tar.gz -L \
    "https://github.com/diskoverdata/diskover-community/archive/${DISKOVER_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/diskover.tar.gz -C \
    /app/ --strip-components=1 && \
  cd /app/diskover && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.19/ \
    -r requirements.txt && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.cargo

# add local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config
