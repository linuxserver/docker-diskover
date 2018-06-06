FROM lsiobase/alpine:3.7

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache \
	ncurses \
	python3 && \
 apk add --no-cache --virtual=build-dependencies \
	gcc \
	git \
	musl-dev \
	python3-dev \
	py3-pip && \
 echo "**** symlinking python ****" && \
 ln -s /usr/bin/python3 /usr/bin/python && \
 echo "**** install healthchecks ****" && \
 git clone https://github.com/shirosaidev/diskover.git /app/diskover && \
 echo "**** install pip packages ****" && \
 cd /app/diskover && \
 pip3 install --no-cache-dir -r requirements.txt && \
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
