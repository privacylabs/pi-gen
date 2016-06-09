#!/bin/bash -e

install -d ${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d
install -m 644 files/noclear.conf ${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/noclear.conf
install -m 744 files/policy-rc.d ${ROOTFS_DIR}/usr/sbin/policy-rc.d #TODO: Necessary in systemd?
install -v -m 644 files/fstab ${ROOTFS_DIR}/etc/fstab

on_chroot sh -e - <<EOF
if ! id -u pi >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" pi
fi
echo "pi:${IMG_PASSWORD}" | chpasswd
echo "root:${IMG_PASSWORD}" | chpasswd
EOF


