#!/usr/bin/with-contenv bash

# killing existing workers before starting new ones
echo "killing existing workers..."
if [ -f "/tmp/diskover_bot_pids" ]; then
    /bin/bash /app/diskover/diskover-bot-launcher.sh -k > /dev/null 2>&1
    sleep 3
fi

# empty existing redis queue
echo "emptying current redis queues..."
rq empty -u redis://${DISKOVER_ARRAY[REDIS_HOST]}:${DISKOVER_ARRAY[REDIS_PORT]} diskover_crawl diskover diskover_calcdir failed
sleep 3

echo "killing dangling workers..."
/bin/bash /app/diskover/diskover-bot-launcher.sh -k > /dev/null 2>&1
sleep 3
