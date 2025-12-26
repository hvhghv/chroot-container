#!/bin/sh

. $PWD/etc/chroot-init/_config.sh

unshare --fork $UNSHARE_NAMESPACES ./etc/chroot-init/_chroot_init.sh &
sleep 0.1
pgrep -o -P $! > $PID_FILE
wait $!