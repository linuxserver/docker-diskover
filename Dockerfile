FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.12

# set version label
ARG BUILD_DATE
ARG VERSION
ARG DISKOVER_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	composer \
	curl \
	gcc \
	musl-dev \
	python3-dev && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	grep \
	ncurses \
	php7-curl \
	php7-phar \
	py3-pip \
	python3 && \
 echo "**** install diskover ****" && \
 mkdir -p /app/diskover && \
 if [ -z ${DISKOVER_VERSION+x} ]; then \
	DISKOVER_VERSION=$(curl -sX GET "https://api.github.com/repos/alex-phillips/diskover/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/diskover.tar.gz -L \
	"https://github.com/alex-phillips/diskover/archive/${DISKOVER_VERSION}.tar.gz" && \
 tar xf \
 /tmp/diskover.tar.gz -C \
	/app/diskover/ --strip-components=1 && \
 echo "**** install diskover-web ****" && \
 mkdir -p /app/diskover-web && \
 DISKOVER_WEB_VERSION=$(curl -sX GET "https://api.github.com/repos/alex-phillips/diskover-web/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 if [ "${DISKOVER_VERSION}" !=  "${DISKOVER_WEB_VERSION}" ] || [ -z ${DISKOVER_VERSION+x} ]; then \
	DISKOVER_VERSION=$(curl -sX GET "https://api.github.com/repos/alex-phillips/diskover-web/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/diskover-web.tar.gz -L \
	"https://github.com/alex-phillips/diskover-web/archive/${DISKOVER_VERSION}.tar.gz" && \
 tar xf \
 /tmp/diskover-web.tar.gz -C \
	/app/diskover-web/ --strip-components=1 && \
 echo "**** install pip packages ****" && \
 cd /app/diskover && \
 pip3 install --no-cache-dir -r requirements.txt && \
 pip3 install rq-dashboard && \
 echo "**** install composer packages ****" && \
 cd /app/diskover-web && \
 composer install && \
 echo "**** fix logrotate ****" && \
 sed -i "s#/var/log/messages {}.*# #g" /etc/logrotate.conf && \
 echo "**** symlink python3 ****" && \
 ln -s /usr/bin/python3 /usr/bin/python && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8000
VOLUME /config
