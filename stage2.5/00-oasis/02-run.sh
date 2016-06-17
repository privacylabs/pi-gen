#!/bin/bash -e

on_chroot sh -e - <<EOF
pip install markupsafe
pip install cryptography --upgrade
pip install boto
pip install ansible --upgrade
if [ ! -d oasis ]; then
#git clone ssh://dirk@shockley.trustedether.com/git/oasis --recursive
git clone https://github.com/privacylabs/oasis --recursive
cd oasis && git checkout -b dev origin/dev && cd ..
fi

if [ ! -d /run/shm ]; then
mkdir /run/shm
mount /run/shm
fi
cd oasis && ansible-playbook -i inventory image.yml
EOF
