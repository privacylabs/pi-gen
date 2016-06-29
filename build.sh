#!/bin/bash -e

run_sub_stage()
{
	log "Begin ${SUB_STAGE_DIR}"
	pushd ${SUB_STAGE_DIR} > /dev/null
	for i in {00..99}; do
		if [ -f ${i}-debconf ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-debconf"
			on_chroot sh -e - << EOF
debconf-set-selections <<SELEOF
`cat ${i}-debconf`
SELEOF
EOF
		log "End ${SUB_STAGE_DIR}/${i}-debconf"
		fi
		if [ -f ${i}-packages-nr ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-packages-nr"
			PACKAGES=`cat $i-packages-nr | tr '\n' ' '`
			if [ -n "$PACKAGES" ]; then
				on_chroot sh -e - << EOF
apt-get install --no-install-recommends -y $PACKAGES
EOF
			fi
			log "End ${SUB_STAGE_DIR}/${i}-packages-nr"
		fi
		if [ -f ${i}-packages ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-packages"
			PACKAGES=`cat $i-packages | tr '\n' ' '`
			if [ -n "$PACKAGES" ]; then
				on_chroot sh -e - << EOF
apt-get install -y $PACKAGES
EOF
			fi
			log "End ${SUB_STAGE_DIR}/${i}-packages"
		fi
		if [ -d ${i}-patches ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-patches"
			pushd ${STAGE_WORK_DIR} > /dev/null
			if [ "${CLEAN}" = "1" ]; then
				rm -rf .pc
				rm -rf *-pc
			fi
			QUILT_PATCHES=${SUB_STAGE_DIR}/${i}-patches
			mkdir -p ${i}-pc
			ln -sf ${i}-pc .pc
			if [ -e ${SUB_STAGE_DIR}/${i}-patches/EDIT ]; then
				echo "Dropping into bash to edit patches..."
				bash
			fi
			quilt upgrade
			RC=0
			quilt push -a || RC=$?
			case "$RC" in
				0|2)
					;;
				*)
					false
					;;
			esac
			popd > /dev/null
			log "End ${SUB_STAGE_DIR}/${i}-patches"
		fi
		if [ -x ${i}-run.sh ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-run.sh"
			./${i}-run.sh
			log "End ${SUB_STAGE_DIR}/${i}-run.sh"
		fi
		if [ -f ${i}-run-chroot ]; then
			log "Begin ${SUB_STAGE_DIR}/${i}-run-chroot"
			on_chroot sh -e - < ${i}-run-chroot
			log "End ${SUB_STAGE_DIR}/${i}-run-chroot"
		fi
	done
	popd > /dev/null
	log "End ${SUB_STAGE_DIR}"
}

run_stage(){
	log "Begin ${STAGE_DIR}"
	STAGE=$(basename ${STAGE_DIR})
	pushd ${STAGE_DIR} > /dev/null
	unmount ${WORK_DIR}/${STAGE}
	STAGE_WORK_DIR=${WORK_DIR}/${STAGE}
	ROOTFS_DIR=${STAGE_WORK_DIR}/rootfs
	if [ ! -f SKIP ]; then
		if [ -f ${STAGE_DIR}/EXPORT_IMAGE ]; then
			EXPORT_DIRS="${EXPORT_DIRS} ${STAGE_DIR}"
		fi
		if [ "${CLEAN}" = "1" ]; then
			if [ -d ${ROOTFS_DIR} ]; then
				rm -rf ${ROOTFS_DIR}
			fi
		fi
		if [ -x prerun.sh ]; then
			log "Begin ${STAGE_DIR}/prerun.sh"
			./prerun.sh
			log "End ${STAGE_DIR}/prerun.sh"
		fi
		for SUB_STAGE_DIR in ${STAGE_DIR}/*; do
			if [ -d ${SUB_STAGE_DIR} ] &&
			   [ ! -f ${SUB_STAGE_DIR}/SKIP ]; then
				run_sub_stage
			fi
		done
	fi
	unmount ${WORK_DIR}/${STAGE}
	PREV_STAGE=${STAGE}
	PREV_STAGE_DIR=${STAGE_DIR}
	PREV_ROOTFS_DIR=${ROOTFS_DIR}
	popd > /dev/null
	log "End ${STAGE_DIR}"
}

if [ "$(id -u)" != "0" ]; then
	echo "Please run as root" 1>&2
	exit 1
fi

if [ -f config ]; then
	source config
fi


OPTS=`getopt -o h:p: --long hostname:,password: -n 'build-pi-image' -- "$@"`
eval set -- "$OPTS"

while true; do
  case "$1" in
    -h | --hostname )
      HOSTNAME="$2";
      echo "HOSTNAME = ${HOSTNAME}";
      shift; shift;;
    -p | --password )
      PASSWORD="$2";
      echo "PASSWORD = ${PASSWORD}";
      shift; shift;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ ! -z "${HOSTNAME}" ]; then
  echo "writing ${HOSTNAME} to hostname file"
  echo ${HOSTNAME} > ./stage1/02-net-tweaks/files/hostname
fi

if [ ! -z "${PASSWORD}" ]; then
  echo "PASSWORD TEST ${PASSWORD}"
fi

export IMG_PASSWORD="${PASSWORD}"
export IMG_NAME="oasis"
export IMG_DATE=${IMG_DATE:-"$(date -u +%Y-%m-%d)"}

export BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR="${BASE_DIR}/scripts"
export WORK_DIR="${BASE_DIR}/work/${IMG_DATE}-${IMG_NAME}"
export DEPLOY_DIR="${BASE_DIR}/deploy"
export LOG_FILE="${WORK_DIR}/build.log"

export HOSTNAME
export CLEAN
export IMG_NAME
export APT_PROXY="http://localhost:3142/archive.raspbian.org/raspbian"

export STAGE
export STAGE_DIR
export STAGE_WORK_DIR
export PREV_STAGE
export PREV_STAGE_DIR
export ROOTFS_DIR
export PREV_ROOTFS_DIR
export IMG_SUFFIX
export EXPORT_DIR
export EXPORT_ROOTFS_DIR

export QUILT_PATCHES
export QUILT_NO_DIFF_INDEX=1
export QUILT_NO_DIFF_TIMESTAMPS=1
export QUILT_REFRESH_ARGS="-p ab"

source ${SCRIPT_DIR}/common

mkdir -p ${WORK_DIR}
log "Begin ${BASE_DIR}"

for STAGE_DIR in ${BASE_DIR}/stage*; do
	run_stage
done

CLEAN=1
for EXPORT_DIR in ${EXPORT_DIRS}; do
	STAGE_DIR=${BASE_DIR}/export-image
	IMG_SUFFIX=$(cat ${EXPORT_DIR}/EXPORT_IMAGE)
	EXPORT_ROOTFS_DIR=${WORK_DIR}/$(basename ${EXPORT_DIR})/rootfs
	run_stage
	if [ -e ${EXPORT_DIR}/EXPORT_NOOBS ]; then
		STAGE_DIR=${BASE_DIR}/export-noobs
		run_stage
	fi
done

log "End ${BASE_DIR}"
