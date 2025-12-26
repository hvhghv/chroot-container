#!/bin/sh

# 配置参数

. /$PWD/etc/chroot-init/_config.sh

# 检查是否已经存在命名空间
if [ -f "$PID_FILE" ]; then
    echo "Chroot 命名空间已存在，正在进入..."
    PID=$(cat "$PID_FILE")
    $SUDO nsenter -t "$PID" $NSENTER_NAMESPACES ./etc/chroot-init/_entry_container.sh
    exit 0
fi

echo "未找到PID文件"