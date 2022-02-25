FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.14

# set version label
ARG BUILD_DATE
ARG VERSION
ARG DISKOVER_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    gcc \
    py3-pip \
    python3-dev \
    composer \
    curl \
    git \
    jq \
    nodejs \
    npm && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache  \
    libldap \
    ncurses \
    php7-curl \
    php7-ldap \
    php7-sqlite3 \
    py3-requests \
    py3-urllib3 \
    py3-xxhash \
    python3 && \
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
  pip3 install --no-cache-dir -r requirements.txt && \
  sed -i 's@;clear_env = no@clear_env = no@' "/etc/php7/php-fpm.d/www.conf" && \
  echo "**** overlay-fs workaround ****" && \
  mv /app/diskover /app/diskover-tmp && \
  mv /app/diskover-web /app/diskover-web-tmp && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    /root/.cache

# add local files
COPY ./root/ /
