FROM lsiobase/alpine.nginx:3.7

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache \
	grep \
	logrotate \
	ncurses \
	php7 \
	php7-curl \
	php7-json \
	php7-mbstring \
	php7-openssl \
	php7-phar \
	php7-session \
	python3 && \
 apk add --no-cache --virtual=build-dependencies \
 	curl \
	gcc \
	musl-dev \
	python3-dev \
	py3-pip && \
 # fix logrotate
 sed -i "s#/var/log/messages {}.*# #g" /etc/logrotate.conf && \
 echo "**** symlinking python ****" && \
 ln -s /usr/bin/python3 /usr/bin/python && \
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
 echo "**** install pip packages ****" && \
 cd /app/diskover && \
 pip3 install --no-cache-dir -r requirements.txt && \
 pip3 install rq-dashboard && \
 echo "**** install composer ****" && \
 php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
 php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
 php composer-setup.php && \
 php -r "unlink('composer-setup.php');" && \
 mv composer.phar /usr/bin/composer && \
 /usr/bin/composer self-update && \
 echo "**** install diskover-web ****" && \
 mkdir -p /app/diskover-web && \
 if [ -z ${DISKOVER_WEB_RELEASE+x} ]; then \
        DISKOVER_WEB_RELEASE=$(curl -sX GET "https://api.github.com/repos/shirosaidev/diskover-web/releases/latest" \
        | awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/diskover-web.tar.gz -L \
        "https://github.com/shirosaidev/diskover-web/archive/${DISKOVER_WEB_RELEASE}.tar.gz" && \
 tar xf \
 /tmp/diskover-web.tar.gz -C \
        /app/diskover-web/ --strip-components=1 && \
 echo "**** install composer packages ****" && \
 cd /app/diskover-web && \
 /usr/bin/composer install && \
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
