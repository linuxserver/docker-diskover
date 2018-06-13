[linuxserverurl]: https://linuxserver.io
[forumurl]: https://forum.linuxserver.io
[ircurl]: https://www.linuxserver.io/irc/
[podcasturl]: https://www.linuxserver.io/podcast/
[appurl]: www.example.com
[hub]: https://hub.docker.com/r/example/example/


[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png?v=4&s=4000)][linuxserverurl]


## Contact information

| Type | Address/Details |
| :---: | --- |
| Forum | [Linuserver.io forum][forumurl] |
| IRC | freenode at `#linuxserver.io` more information at [IRC][ircurl] |
| Podcast | Covers everything to do with getting the most from your Linux Server plus a focus on all things Docker and containerisation! [Linuxserver.io Podcast][podcasturl] |


The [LinuxServer.io][linuxserverurl] team brings you another image release featuring easy user mapping and based on alpine linux with s6 overlay.

# alexphillips/diskover

[diskover](https://github.com/shirosaidev/diskover) is a file system crawler, disk space usage, file search engine and file system analytics powered by Elasticsearch

&nbsp;

## Usage

```
docker create \
  --name=diskover \
  -v <path to config>:/config \
  -v <path to data>:/data \
  -v <path to crontab file>:/etc/crontabs/abc \
  -e PGID=<gid> -e PUID=<uid>  \
  -e REDIS_HOST=<REDIS_HOST> \
  -e REDIS_PORT=<REDIS_PORT> \
  -e ES_HOST=<ES_HOST> \
  -e ES_PORT=<ES_PORT> \
  -e ES_USER=<ES_USER> \
  -e ES_PASS=<ES_PASS> \
  -e INDEX_NAME=<INDEX_NAME> \
  -e DISKOVER_OPTS=<DISKOVER_OPTS> \
  -e WORKER_OPTS=<WORKER_OPTS> \
  alexphillips/diskover
```

&nbsp;

## Parameters

`The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side.
For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container.
So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080
http://192.168.x.x:8080 would show you what's running INSIDE the container on port 80.`

| Parameter | Function |
| :---: | --- |
| `-p 1234` | the port(s) |
| `-v /config` | diskover config |
| `-v /data` | data directory to scan |
| `-v /etc/crontabs/abc` | crontab file to run dispatcher in cron |
| `-e PGID` | for GroupID, see below for explanation |
| `-e PUID` | for UserID, see below for explanation |
| `-e REDIS_HOST` | Redis host [default: redis] |
| `-e REDIS_PORT` | Redis port [default: 6379] |
| `-e ES_HOST` | ElasticSearch host [default: elasticsearch] |
| `-e ES_PORT` | ElasticSearch port [default: 9200] |
| `-e ES_USER` | ElasticSearch username [default: elastic] |
| `-e ES_PASS` | ElasticSearch password [default: changeme] |
| `-e INDEX_PREFIX` | ElasticSearch index prefix [default: 'diskover-'] |
| `-e INDEX_NAME` | ElasticSearch index name [default: $INDEX_PREFIX-TIMESTAMP] |
| `-e DISKOVER_OPTS` | Arguments to pass to the dispatcher [default: '-a -i $INDEX_NAME'] |
| `-e WORKER_OPTS` | Arguments to pass to the bot launcher [default: ''] |

&nbsp;

## User / Group Identifiers

Sometimes when using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and it will "just work" &trade;.

In this instance `PUID=1001` and `PGID=1001`, to find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

&nbsp;

## Setting up the application

The diskover workers will autmoatically start running and scan the data located at `/data`.


&nbsp;

## Container access and information.

| Function | Command |
| :--- | :--- |
| Shell access (live container) | `docker exec -it diskover /bin/bash` |
| Realtime container logs | `docker logs -f diskover` |
| Container version number | `docker inspect -f '{{ index .Config.Labels "build_version" }}' diskover` |
| Image version number |  `docker inspect -f '{{ index .Config.Labels "build_version" }}' diskover` |

&nbsp;

## Versions

|  Date | Changes |
| :---: | --- |
| 06.06.18 |  Initial Release. |
