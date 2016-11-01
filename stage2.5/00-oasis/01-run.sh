#!/bin/bash -e

on_chroot sh -e - <<EOF
mkdir -p /etc/oasis
EOF

install -m 644 files/hosts			${ROOTFS_DIR}/etc/
install -m 755 files/resize_data_partition	${ROOTFS_DIR}/usr/local/sbin/
install -m 755 files/oasis-update		${ROOTFS_DIR}/etc/cron.daily/
install -m 755 files/initramfs/oasis.script	${ROOTFS_DIR}/etc/initramfs-tools/scripts/init-top/oasis
install -m 755 files/initramfs/overlay.script	${ROOTFS_DIR}/etc/initramfs-tools/scripts/init-bottom/overlay
install -m 755 files/initramfs/oasis.hook	${ROOTFS_DIR}/etc/initramfs-tools/hooks/oasis
install -m 755 files/initramfs/overlay.hook	${ROOTFS_DIR}/etc/initramfs-tools/hooks/overlay
install -m 755 files/initramfs.gz		${ROOTFS_DIR}/boot/initramfs.gz
install -m 644 files/oasis-configurator_armhf.deb	${ROOTFS_DIR}/etc/oasis/
install -m 755 files/healthcheck		${ROOTFS_DIR}/usr/local/sbin/
install -m 644 files/healthcheck.service	${ROOTFS_DIR}/etc/systemd/system/
install -m 755 files/upgradefs			${ROOTFS_DIR}/usr/local/sbin/
install -m 644 files/upgradefs.service		${ROOTFS_DIR}/etc/systemd/system/
#install -m 644 files/privacylabs-test.pub	${ROOTFS_DIR}/etc/privacylabs.pub
install -m 644 files/privacylabs.pub		${ROOTFS_DIR}/etc/privacylabs.pub
tar xvf files/modules.tar -C ${ROOTFS_DIR}/lib
