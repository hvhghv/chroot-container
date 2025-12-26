#!/bin/sh

# 配置参数
. $PWD/etc/chroot-init/_config.sh

if [ "$USE_SUDO" = true ]; then
SUDO="sudo"
else
SUDO=""
fi

if [ -z "$DNS" ]; then
    if [ -e /etc/resolv.conf ]; then
        $SUDO cp /etc/resolv.conf ./etc/resolv.conf
    else
        $SUDO echo 'nameserver 223.5.5.5' > ./etc/resolv.conf
    fi
else
echo "nameserver $DNS" > ./etc/resolv.conf 
fi

$SUDO echo "$HOST_NAME" > ./etc/hostname

# 挂载必要的文件系统
$SUDO mount --bind /dev ./dev
$SUDO mount -t tmpfs tmpfs ./tmp
$SUDO mount -t sysfs sysfs ./sys

# 创建新的命名空间并启动 chroot
$SUDO ./etc/chroot-init/_create_container.sh

$SUDO umount -f ./dev
$SUDO umount -f ./tmp
$SUDO umount -f ./sys
$SUDO rm -f "$PID_FILE"
