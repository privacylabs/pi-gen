#!/bin/bash -e

on_chroot sh -e - <<EOF
pip install markupsafe
pip install cryptography --upgrade
pip install boto
pip install ansible==2.1.2.0
systemctl enable healthcheck
EOF
