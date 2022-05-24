#!/bin/bash
set -e


REG="docker.io/bitnami"
IMGS=( "postgresql-repmgr:13.3.0-debian-10-r53" "pgpool:4.2.3-debian-10-r50" "postgres-exporter:0.10.0-debian-10-r4" "bitnami-shell:10-debian-10-r131")
CLIENT=${CLI:=podman}

function usage() {
  echo "[Usage]: CLI=<registry_client(default: podman)> ./postgres-download.sh <save_dir>(default: downloads)"
  echo "    ex): CLI=docker ./postgres-download.sh archive"
}

function check_client() {
  if [ ! -e "$(which ${CLIENT})" ]
  then
    echo "${CLIENT} is not installed."
    exit 1
  fi
}

function check_savedir() {
  if [ ! -e $SAVEDIR ]
  then
    echo "no save directory found. create new one... "
    mkdir $SAVEDIR
  fi
}

SAVEDIR=${1=downloads}

check_client
check_savedir

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

for IMG in "${IMGS[@]}"; do
  echo -e  "${BLUE}Pulling image ${REG}/${IMG}${NC}"
  ${CLIENT} pull "${REG}/${IMG}"
  ${CLIENT} save "${REG}/${IMG}" -o "${SAVEDIR}/${IMG/:/_}.tar"
  echo -e  "${RED}Saved to ${SAVEDIR}/${IMG/:/_}.tar${NC}"
done
