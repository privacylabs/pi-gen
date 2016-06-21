#!/bin/bash -e

on_chroot sh -e - <<EOF
if [ ! -d oasis ]; then
git clone https://github.com/privacylabs/oasis --recursive
cd oasis && git checkout -b dev origin/dev && cd ..
cd oasis && git submodule update --recursive && cd ..
fi

if [ ! -d /run/shm ]; then
mkdir /run/shm
fi
mount /run/shm
cd oasis && ansible-playbook -i inventory image.yml --tags "packages"
EOF
