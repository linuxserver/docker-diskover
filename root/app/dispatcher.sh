#!/usr/bin/with-contenv bash

. /config/.env

# define array for input values
declare -A DISKOVER_ARRAY
DISKOVER_ARRAY[TODAY]=$(date +%Y-%m-%d)
DISKOVER_ARRAY[INDEX_PREFIX]=${INDEX_PREFIX:-diskover-}
DISKOVER_ARRAY[INDEX_NAME]=${INDEX_NAME:-$INDEX_PREFIX$TODAY}
DISKOVER_ARRAY[DISKOVER_OPTS]=${DISKOVER_OPTS:-"-d /data -a"}

DISKOVER_OPTS="$DISKOVER_OPTS -i $INDEX_NAME"

cd /app/diskover || exit

# killing existing workers before starting new ones
echo "killing existing workers..."
if [ -f "/tmp/diskover_bot_pids" ]; then
    /bin/bash /app/diskover/diskover-bot-launcher.sh -k > /dev/null 2>&1
    sleep 3
fi

# empty existing redis queue
echo "emptying current redis queues..."
rq empty -u redis://$REDIS_HOST:$REDIS_PORT diskover_crawl
sleep 3
rq empty -u redis://$REDIS_HOST:$REDIS_PORT failed
sleep 3

echo "killing dangling workers..."
/bin/bash /app/diskover/diskover-bot-launcher.sh -k > /dev/null 2>&1
sleep 3

echo "starting workers with following options: ${DISKOVER_ARRAY[WORKER_OPTS]}"
/bin/bash /app/diskover/diskover-bot-launcher.sh ${DISKOVER_ARRAY[WORKER_OPTS]}

echo "starting crawler with following options: ${DISKOVER_ARRAY[DISKOVER_OPTS]}"
/usr/bin/python3 ./diskover.py ${DISKOVER_ARRAY[DISKOVER_OPTS]}
