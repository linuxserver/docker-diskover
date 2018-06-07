#!/usr/bin/with-contenv bash

TODAY=$(date +%Y-%m-%d)
INDEX_PREFIX=${INDEX_PREFIX:-diskover-}
INDEX_NAME=${INDEX_NAME:-$INDEX_PREFIX$TODAY}
DISPATCH_OPTS=${DISPATCH_OPTS:-"-a -i $INDEX_NAME"}
WORKER_OPTS=${WORKER_OPTS:-""}

sleep 10

cd /app/diskover || exit

# Run the workers
/bin/bash ./diskover-bot-launcher.sh $WORKER_OPTS > /dev/null 2>&1

/usr/bin/python3 ./diskover.py -d /data $DISPATCH_OPTS && \
    sleep 10 && \
    echo "dispatcher is done, killing off workers..." && \
    /bin/bash ./diskover-bot-launcher.sh -k
