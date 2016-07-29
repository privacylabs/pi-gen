#!/bin/bash -e

on_chroot sh -e - <<EOF
echo ${IMG_DATE} > /etc/build_date
if [ ! -d oasis ]; then
git clone https://github.com/privacylabs/oasis --recursive
fi

if [ ! -d /run/shm ]; then
mkdir /run/shm
fi
mount /run/shm
cd oasis && ansible-playbook -i inventory image.yml --tags "packages"
EOF
