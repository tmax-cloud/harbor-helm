#!/usr/bin/env bash
set -e

REG="bitnami"
IMGS=( "postgresql-repmgr_13.3.0-debian-10-r53" "pgpool_4.2.3-debian-10-r50" "postgres-exporter_0.10.0-debian-10-r4" "bitnami-shell_10-debian-10-r131")



function usage() {
  echo "[Usage]: CLI=<registry_client(default: podman)> ./postgres-upload.sh <archive_dir_path> <registry_domain>"
  echo "    ex): CLI=docker ./postgres-upload.sh ./postgres-downloads 172.22.11.2:5000"
}

if [ -z ${1} ];
then
  echo "[ERROR]: saved directory specified."
  usage
  exit 1
fi

if [ -z ${2} ];
then
  echo "[ERROR]: target registry not specified."
  usage
  exit 1
fi

CLIENT=${CLI:=podman}
SAVEDIR=${1}
TARGETREG=${2}

function check_client() {
  if [ ! -e "$(which ${CLIENT})" ]
  then
    echo "[ERROR]: ${CLIENT} is not installed."
    usage
    exit 1
  fi
}

function check_savedir() {
  if [ ! -d $SAVEDIR ]
  then
    echo "[ERROR]: no save directory(${SAVEDIR}) found."
    usage
    exit 1
  fi
}

check_client
check_savedir

for IMG in "${IMGS[@]}"; do
  echo "Load image from ${SAVEDIR}/${IMG}_${TAG}.tar"
  ${CLIENT} load < ${SAVEDIR}/${IMG}_${TAG}.tar

  echo "Tag image ${REG}/${IMG/_/:} to ${TARGETREG}/${IMG/_/:}"
  ${CLIENT} tag ${REG}/${IMG/_/:} ${TARGETREG}/${IMG/_/:}

  echo "Push image ${TARGETREG}/${IMG/_/:}"
  ${CLIENT} push ${TARGETREG}/${IMG/_/:}
done
