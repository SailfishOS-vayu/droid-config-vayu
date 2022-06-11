#!/bin/bash
# Verbose script for mounting dynamic partitions
 
# Edit partitions according to your fixup-mountpoints, fstab and dynamic partitions layout
super_part=/dev/sda23
# Partitions mounted in /vendor/*
modem_part=/dev/sde52
dsp_part=/dev/sde48
bluetooth_part=/dev/sde27

# Partition Metadata
metadata_part=/dev/sda19
 
dmesg_info() {
    echo "[mount-partitions.sh] $@" > /dev/kmsg
}
 
dmesg_info "Map dynamic partitions"
dmsetup create --concise "$(/usr/bin/parse-android-dynparts $super_part)"
 
dmesg_info "Dynamic partitions: $(ls /dev/mapper/dynpart-*)"
 
dmesg_info "Mount dynamic partitions"
mkdir -p /system_root /system_ext /vendor /odm2 /product /mnt /metadata
 
dmesg_info "$(mount -v -o ro /dev/mapper/dynpart-system  /system_root)"
dmesg_info "$(mount --bind /system_root/system /system)"
dmesg_info "$(mount -v -o ro /dev/mapper/dynpart-system_ext /system_ext)"
dmesg_info "$(mount -v -o ro /dev/mapper/dynpart-vendor  /vendor)"
dmesg_info "$(mount -v -o ro /dev/mapper/dynpart-odm   /odm2)"
dmesg_info "$(mount -v -o ro /dev/mapper/dynpart-product /product)"
 
dmesg_info "Mount /vendor/*"
dmesg_info "$(mount -v $modem_part      /vendor/firmware_mnt)"
dmesg_info "$(mount -v $dsp_part        /vendor/dsp)"
dmesg_info "$(mount -v $bluetooth_part  /vendor/bt_firmware)"

dmesg_info "Mount metadata*"
dmesg_info "$(mount -v $metadata_part   /metadata)"
 
# comment out when everything works
dmesg_info "$(findmnt)"
