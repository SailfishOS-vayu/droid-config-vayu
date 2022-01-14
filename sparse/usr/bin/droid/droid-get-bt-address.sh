#!/bin/bash
echo "droid-get-bt-address: Setting up bluetooth address"
B=$(xxd -e -g 8 /data/vendor/mac_addr/bt.mac | grep -oiE "([a-f0-9]{12})")
echo "BT MAC: $B"

if [ ! -z "$B" ] ; then
    bt_mac=${B:0:2}:${B:2:2}:${B:4:2}:${B:6:2}:${B:8:2}:${B:10:2}
    echo $bt_mac > /var/lib/bluetooth/board-address
fi
