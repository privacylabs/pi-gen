#!/bin/bash -e

on_chroot sh -e - <<EOF
mkdir -p /etc/oasis
EOF

install -m 644 files/hosts			${ROOTFS_DIR}/etc/
install -m 755 files/resize_data_partition	${ROOTFS_DIR}/usr/local/sbin/
install -m 755 files/healthcheck		${ROOTFS_DIR}/usr/local/sbin/
install -m 644 files/healthcheck.service	${ROOTFS_DIR}/etc/systemd/system/
