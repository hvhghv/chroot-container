#!/bin/sh

/bin/busybox ip rule add to 10.8.0.0/24 lookup main priority 18002
/sbin/openvpn --config /etc/openvpn/client/client.ovpn