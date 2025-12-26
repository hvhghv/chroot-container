#!/bin/sh

se-boot boot


. /etc/chroot-init/_config.sh
echo $$ > "$CONTAINER_STOP_PID_FILE"

while [ true ]; do
    sleep 99999999
done