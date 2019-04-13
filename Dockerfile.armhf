FROM lsiobase/nginx:arm32v7-3.9

# set version label
ARG BUILD_DATE
ARG VERSION
ARG DISKOVER_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	gcc \
	musl-dev \
	python3-dev \
	py3-pip && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	grep \
	ncurses \
	php7-curl \
	php7-phar \
	python3 && \
 echo "**** install composer ****" && \
 curl \
 	-sS https://getcomposer.org/installer \
	| php -- --install-dir=/usr/bin --filename=composer && \
 echo "**** install diskover ****" && \
 mkdir -p /app/diskover && \
 if [ -z ${DISKOVER_RELEASE+x} ]; then \
	DISKOVER_RELEASE=$(curl -sX GET "https://api.github.com/repos/shirosaidev/diskover/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/diskover.tar.gz -L \
	"https://github.com/shirosaidev/diskover/archive/${DISKOVER_RELEASE}.tar.gz" && \
 tar xf \
 /tmp/diskover.tar.gz -C \
	/app/diskover/ --strip-components=1 && \
 echo "**** install diskover-web ****" && \
 mkdir -p /app/diskover-web && \
 DISKOVER_WEB_RELEASE=$(curl -sX GET "https://api.github.com/repos/shirosaidev/diskover-web/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 if [ "${DISKOVER_RELEASE}" !=  "${DISKOVER_WEB_RELEASE}" ] || [ -z ${DISKOVER_RELEASE+x} ]; then \
	DISKOVER_RELEASE=$(curl -sX GET "https://api.github.com/repos/shirosaidev/diskover-web/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/diskover-web.tar.gz -L \
	"https://github.com/shirosaidev/diskover-web/archive/${DISKOVER_RELEASE}.tar.gz" && \
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
