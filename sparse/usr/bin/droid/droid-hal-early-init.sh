#!/bin/bash

# Custom Partitions mounted
modem_part=/data/.stowaways/firmware/modem.img
dsp_part=/data/.stowaways/firmware/dsp.img
bluetooth_part=/data/.stowaways/firmware/bluetooth.img
metadata_part=/data/.stowaways/firmware/metadata.img

# custom patches
lipstick_patch=/data/.stowaways/patches/lipstick-jolla-home-qt5/statusarea/StatusArea.qml

mount -v -o loop,ro,shortname=lower,uid=1000,gid=1000,dmask=227,fmask=337 -t vfat $modem_part  /vendor/firmware_mnt
mount -v -o loop,ro,nosuid,nodev,barrier=1 -t ext4 $dsp_part /vendor/dsp
mount -v -o loop,ro,shortname=lower,uid=1002,gid=3002,dmask=227,fmask=337 -t vfat $bluetooth_part /vendor/bt_firmware
mount -v -o loop,ro,noatime,nosuid,nodev,discard -t ext4 $metadata_part /metadata

# bind custom patches
mount --bind $lipstick_patch /usr/share/lipstick-jolla-home-qt5/statusarea/StatusArea.qml

echo -1000 > /proc/self/oom_score_adj
