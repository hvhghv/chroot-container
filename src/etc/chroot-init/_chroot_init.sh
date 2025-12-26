#!/bin/sh

. $PWD/etc/chroot-init/_config.sh

mount -t devpts devpts ./dev/pts
mount -t proc proc ./proc

chroot . /bin/env -i /etc/chroot-init/_init.sh

rm $CONTAINER_STOP_PID_FILE

umount -f ./dev/pts
umount -f ./proc





