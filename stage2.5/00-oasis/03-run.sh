#!/bin/bash -e

on_chroot sh -e - <<EOF
echo ${IMG_DATE} > /etc/build_date
if [ ! -d oasis ]; then
git clone -b dev --single-branch https://github.com/privacylabs/oasis --recursive
fi

if [ ! -d /run/shm ]; then
mkdir /run/shm
fi
mount /run/shm
dpkg-divert --local --rename --add /usr/bin/newaliases
ln -s /bin/true /usr/bin/newaliases
cd oasis && ansible-playbook -i inventory image.yml --tags "packages"
rm -f /usr/bin/newaliases
dpkg-divert --local --rename --remove /usr/bin/newaliases
pkill -9 slapd
pkill -9 ntpd
umount /run/shm
EOF
