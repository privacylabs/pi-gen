#!/bin/bash -e

install -m 644 files/hosts			${ROOTFS_DIR}/etc/
install -m 755 files/resize_data_partition	${ROOTFS_DIR}/usr/local/sbin/
install -m 755 files/oasis-update		${ROOTFS_DIR}/etc/cron.hourly/
install -m 755 files/initramfs/oasis.script	${ROOTFS_DIR}/etc/initramfs-tools/scripts/init-top/oasis
install -m 755 files/initramfs/oasis.hook	${ROOTFS_DIR}/etc/initramfs-tools/hooks/oasis
install -m 755 files/initramfs.gz		${ROOTFS_DIR}/boot/initramfs.gz
