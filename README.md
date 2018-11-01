[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)](https://linuxserver.io)

The [LinuxServer.io](https://linuxserver.io) team brings you another container release featuring :-

 * regular and timely application updates
 * easy user mappings (PGID, PUID)
 * custom base image with s6 overlay
 * weekly base OS updates with common layers across the entire LinuxServer.io ecosystem to minimise space usage, down time and bandwidth
 * regular security updates

Find us at:
* [Discord](https://discord.gg/YWrKVTn) - realtime support / chat with the community and the team.
* [IRC](https://irc.linuxserver.io) - on freenode at `#linuxserver.io`. Our primary support channel is Discord.
* [Blog](https://blog.linuxserver.io) - all the things you can do with our containers including How-To guides, opinions and much more!
* [Podcast](https://anchor.fm/linuxserverio) - on hiatus. Coming back soon (late 2018).

# PSA: Changes are happening

From August 2018 onwards, Linuxserver are in the midst of switching to a new CI platform which will enable us to build and release multiple architectures under a single repo. To this end, existing images for `arm64` and `armhf` builds are being deprecated. They are replaced by a manifest file in each container which automatically pulls the correct image for your architecture. You'll also be able to pull based on a specific architecture tag.

TLDR: Multi-arch support is changing from multiple repos to one repo per container image.

# [linuxserver/diskover](https://github.com/linuxserver/docker-diskover)
[![](https://images.microbadger.com/badges/version/linuxserver/diskover.svg)](https://microbadger.com/images/linuxserver/diskover "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/linuxserver/diskover.svg)](https://microbadger.com/images/linuxserver/diskover "Get your own version badge on microbadger.com")
![Docker Pulls](https://img.shields.io/docker/pulls/linuxserver/diskover.svg)
![Docker Stars](https://img.shields.io/docker/stars/linuxserver/diskover.svg)

[Diskover](https://github.com/shirosaidev/diskover) is a file system crawler, disk space usage, file search engine and file system analytics powered by Elasticsearch

[![diskover](https://raw.githubusercontent.com/shirosaidev/diskover/master/docs/diskover.png)](https://github.com/shirosaidev/diskover)

## Supported Architectures

Our images support multiple architectures such as `X86-64`, `arm64` and `armhf`. We utilise the docker manifest for multi-platform awareness. More information is available from docker [here](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list). 

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| X86-64 | amd64-latest |
| arm64 | arm64v8-latest |
| armhf | arm32v6-latest |

## Usage

Here are some example snippets to help you get started creating a container.

### docker

```
docker create \
  --name=diskover \
  -e PUID=1001 \
  -e PGID=1001 \
  -e TZ=Europe/London \
  -e REDIS_HOST=redis \
  -e REDIS_PORT=6379 \
  -e ES_HOST=elasticsearch \
  -e ES_PORT=6379 \
  -e ES_USER=elasticsearch \
  -e ES_PASS=changeme \
  -e INDEX_NAME=diskover- \
  -e DISKOVER_OPTS= \
  -e WORKER_OPTS= \
  -e RUN_ON_START=true \
  -e USE_CRON=true \
  -p 80:80 \
  -p 9181:9181 \
  -p 9999:9999 \
  -v </path/to/diskover/config>:/config \
  -v </path/to/diskover/data>:/data \
  linuxserver/diskover
```


### docker-compose

Compatible with docker-compose v2 schemas.

```
version: '2'
services:
  diskover:
    image: linuxserver/diskover
    container_name: diskover
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - ES_HOST=elasticsearch
      - ES_PORT=6379
      - ES_USER=elasticsearch
      - ES_PASS=changeme
      - RUN_ON_START=true
      - USE_CRON=true
    volumes:
      - </path/to/diskover/config>:/config
      - </path/to/diskover/data>:/data
    ports:
      - 80:80
      - 9181:9181
      - 9999:9999
    mem_limit: 4096m
    restart: unless-stopped
  elasticsearch:
    container_name: elasticsearch
    image: docker.elastic.co/elasticsearch/elasticsearch:5.6.9
    volumes:
      - ${DOCKER_HOME}/elasticsearch/data:/usr/share/elasticsearch/data
    environment:
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms2048m -Xmx2048m"
    ulimits:
      memlock:
        soft: -1
        hard: -1
  redis:
    container_name: redis
    image: redis:alpine
    volumes:
      - ${HOME}/docker/redis:/data

```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 80` | diskover Web UI |
| `-p 9181` | rq-dashboard web UI |
| `-p 9999` | diskover socket server |
| `-e PUID=1001` | for UserID - see below for explanation |
| `-e PGID=1001` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London |
| `-e REDIS_HOST=redis` | Redis host (optional) |
| `-e REDIS_PORT=6379` | Redis port (optional) |
| `-e ES_HOST=elasticsearch` | ElasticSearch host (optional) |
| `-e ES_PORT=6379` | ElasticSearch port (optional) |
| `-e ES_USER=elasticsearch` | ElasticSearch username (optional) |
| `-e ES_PASS=changeme` | ElasticSearch password (optional) |
| `-e INDEX_NAME=diskover-` | Index name prefix (optional) |
| `-e DISKOVER_OPTS=` | Optional arguments to pass to the diskover crawler (optional) |
| `-e WORKER_OPTS=` | Optional argumens to pass to the diskover bots launcher (optional) |
| `-e RUN_ON_START=true` | Initiate a crawl every time the container is started (optional) |
| `-e USE_CRON=true` | Run a crawl on as a cron job (optional) |
| `-v /config` | Persistent config files |
| `-v /data` | Default mount point to crawl |

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1001` and `PGID=1001`, to find yours use `id user` as below:

```
  $ id username
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

&nbsp;
## Application Setup

- Once running the URL will be `http://<host-ip>/`.
- Basics are, edit the `diskover.cfg` file to alter any configurations including tagging, threads, etc.



## Support Info

* Shell access whilst the container is running: `docker exec -it diskover /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f diskover`
* container version number 
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' diskover`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' linuxserver/diskover`

## Versions

* **27.09.17:** - Initial Release.
