#!/bin/bash -e

install -m 644 files/hosts			${ROOTFS_DIR}/etc/
install -m 755 files/resize_data_partition	${ROOTFS_DIR}/usr/local/sbin/
