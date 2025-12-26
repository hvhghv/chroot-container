HOST_NAME="ubuntu-local"
DNS="223.5.5.5"
UNSHARE_NAMESPACES="--pid"
NSENTER_NAMESPACES="--pid"
PID_FILE="./_chroot.pid"
CONTAINER_STOP_PID_FILE="./_container-stop.pid"
ENTRY_PROGRAM="/bin/bash"
USE_SUDO=false