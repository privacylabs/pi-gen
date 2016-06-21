#!/bin/bash -e

on_chroot sh -e - <<EOF
pip install markupsafe
pip install cryptography --upgrade
pip install boto
pip install ansible --upgrade
EOF
