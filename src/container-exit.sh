#!/bin/sh

. /etc/chroot-init/_config.sh

if [ -f "$CONTAINER_STOP_PID_FILE" ]; then
PID=$(cat "$CONTAINER_STOP_PID_FILE")
kill $PID
else
"PID文件未找到，退出"
fi