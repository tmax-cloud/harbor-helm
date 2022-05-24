#!/bin/bash
set -e


REG="docker.io/tmaxcloudck"
IMGS=( "kraken-agent" "kraken-build-index" "kraken-origin" "kraken-proxy" "kraken-testfs" "kraken-tracker")
CLIENT=${CLI:=podman}

function usage() {
  echo "[Usage]: CLI=<registry_client(default: podman)> ./kraken-download.sh <save_dir>(default: downloads)"
  echo "    ex): CLI=docker ./kraken-download.sh archive"
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

TAG=v0.1.4
SAVEDIR=${1=downloads}

check_client
check_savedir

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

for IMG in "${IMGS[@]}"; do
  echo -e  "${BLUE}Pulling image ${REG}/${IMG}:${TAG}${NC}"
  ${CLIENT} pull "${REG}/${IMG}:${TAG}"
  ${CLIENT} save "${REG}/${IMG}:${TAG}" -o "${SAVEDIR}/${IMG}_${TAG}.tar"
  echo -e  "${RED}Saved to ${SAVEDIR}/${IMG}_${TAG}.tar${NC}"
done
