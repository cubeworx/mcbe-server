#!/bin/bash

set -e

EULA=${EULA:-""}
MCBE_HOME=${MCBE_HOME:-"/mcbe"}
ADDONS_PATH=${ADDONS_PATH:-"/mcbe/data/addons"}
ALLOWLIST_ENABLE=${ALLOWLIST_ENABLE:-"false"}
ALLOWLIST_FILE=${ALLOWLIST_FILE:-"/mcbe/data/allowlist.json"}
ALLOWLIST_LOOKUP=${ALLOWLIST_LOOKUP:-"true"}
ALLOWLIST_MODE=${ALLOWLIST_MODE:-"static"}
ARTIFACTS_PATH=${ARTIFACTS_PATH:-"/mcbe/data/artifacts"}
DATA_PATH=${DATA_PATH:-"/mcbe/data"}
DOWNLOAD_ENDPOINT=${DOWNLOAD_ENDPOINT:-"https://www.minecraft.net/bedrockdedicatedserver/bin-linux"}
EXEC_NAME="cbwx-mcbe-${SERVER_NAME// /-}-server"
PERMISSIONS_FILE=${PERMISSIONS_FILE:-"/mcbe/data/permissions.json"}
PERMISSIONS_LOOKUP=${PERMISSIONS_LOOKUP:-"true"}
PERMISSIONS_MODE=${PERMISSIONS_MODE:-"static"}
PLAYERDB_LOOKUP_URL=${PLAYERDB_LOOKUP_URL:-"https://playerdb.co/api/player/xbox"}
SEEDS_FILE=${SEEDS_FILE:-"/mcbe/seeds.txt"}
SERVER_PATH=${SERVER_PATH:-"/mcbe/server"}
SERVER_PROPERTIES=${SERVER_PROPERTIES:-"/mcbe/server/server.properties"}
VERSION=${VERSION:-"LATEST"}
VERSIONS_FILE=${VERSIONS_FILE:-"/mcbe/versions.txt"}

check_data_dir() {
  DIR_NAME=$1
  if [ ! -d "${DATA_PATH}/${DIR_NAME}" ]; then
    echo "Creating directory: ${DATA_PATH}/${DIR_NAME}"
    mkdir -p "${DATA_PATH}/${DIR_NAME}"
  fi
}

get_latest_version() {
  WEBSITE_DATA=$(curl -Ss -A "cubeworx/mcbe-server" -H "accept-language:*" "https://www.minecraft.net/en-us/download/server/bedrock")
  #Check if website curl worked, if not default to latest from versions.txt
  # shellcheck disable=SC2126
  if [[ $(echo "${WEBSITE_DATA}" | grep "${DOWNLOAD_ENDPOINT}" | wc -l) -ne 0 ]]; then
    LATEST_URL=$(echo "${WEBSITE_DATA}" | grep -o 'https://www.minecraft.net/bedrockdedicatedserver/bin-linux/[^"]*')
    VERSION=$(echo "${LATEST_URL}" | awk -F '-linux/' '{print $2}' | awk -F 'server-' '{print $2}' | awk -F '.zip' '{print $1}')
    echo "Latest version available is: ${VERSION}"
  else
    echo "ERROR: Unable to determine latest version, defaulting to latest in ${VERSIONS_FILE}"
    VERSION=$(head -n 1 "${VERSIONS_FILE}")
  fi
  if [ ! -f "${ARTIFACTS_PATH}/bedrock-server-${VERSION}.zip" ]; then
    download_file "${DOWNLOAD_ENDPOINT}/bedrock-server-${VERSION}.zip" "${ARTIFACTS_PATH}/bedrock-server-${VERSION}.zip"
  fi
}

download_file(){
  DOWNLOAD_URL=$1
  DOWNLOAD_FILE=$2
  echo "Downloading ${DOWNLOAD_URL} to ${DOWNLOAD_FILE}"
  curl -Ss  -A "cubeworx/mcbe-server" --http1.1 "${DOWNLOAD_URL}" -o "${DOWNLOAD_FILE}"
  if [ ! -f "${DOWNLOAD_FILE}" ]; then
    echo "ERROR: File failed to download!"
    exit 1
  fi
}

extract_server_zip() {
  if [ ! -d "${SERVER_PATH}" ]; then
    mkdir -p "${SERVER_PATH}"
  fi
  echo "Unzipping ${ARTIFACTS_PATH}/bedrock-server-${VERSION}.zip to ${SERVER_PATH}"
  unzip -q "${ARTIFACTS_PATH}/bedrock-server-${VERSION}.zip" -d "${SERVER_PATH}"
  #If permissions.json in server directory exists, delete and create symlink to file in data dir
  if [ -f "${SERVER_PATH}/permissions.json" ] && [ ! -L "${SERVER_PATH}/permissions.json" ]; then
    rm -rf "${SERVER_PATH}/permissions.json"
    echo "Creating symlink ${SERVER_PATH}/permissions.json to ${PERMISSIONS_FILE}"
    ln -s "${PERMISSIONS_FILE}" "${SERVER_PATH}/permissions.json"
  fi
  #If allowlist.json in server directory exists, delete and create symlink to file in data dir
  if [ -f "${SERVER_PATH}/allowlist.json" ] && [ ! -L "${SERVER_PATH}/allowlist.json" ]; then
    rm -rf "${SERVER_PATH}/allowlist.json"
    echo "Creating symlink ${SERVER_PATH}/allowlist.json to ${ALLOWLIST_FILE}"
    ln -s "${ALLOWLIST_FILE}" "${SERVER_PATH}/allowlist.json"
  fi
  #If whitelist.json in server directory exists, delete and create symlink to file in data dir
  if [ -f "${SERVER_PATH}/whitelist.json" ] && [ ! -L "${SERVER_PATH}/whitelist.json" ]; then
    rm -rf "${SERVER_PATH}/whitelist.json"
    echo "Creating symlink ${SERVER_PATH}/whitelist.json to ${ALLOWLIST_FILE}"
    ln -s "${ALLOWLIST_FILE}" "${SERVER_PATH}/whitelist.json"
  fi
  compare_version
  echo "${VERSION}" > "${DATA_PATH}/version.txt"
  echo "Renaming bedrock_server to ${EXEC_NAME} for easier host process identification."
  mv "${SERVER_PATH}/bedrock_server" "${SERVER_PATH}/${EXEC_NAME}"
  chmod +x "${SERVER_PATH}/${EXEC_NAME}"
}

compare_version() {
  if [ -f "${DATA_PATH}/version.txt" ]; then
    OLD_VER=$(cat "${DATA_PATH}/version.txt")
    if [[ "${OLD_VER}" != "${VERSION}" ]]; then
      DATE_TIME=$(date +%Y%m%d%H%M%S)
      echo "Previous version was ${OLD_VER}, current version is ${VERSION}"
      echo "Creating backup of data before version change."
      echo "Backup file: ${DATA_PATH}/backups/${DATE_TIME}_${LEVEL_NAME// /-}_${OLD_VER}_to_${VERSION}.mcworld"
      zip -r "${DATA_PATH}/backups/${DATE_TIME}_${LEVEL_NAME// /-}_${OLD_VER}_to_${VERSION}.mcworld" "${DATA_PATH}/worlds"
    fi
  fi
}

check_symlinks() {
  LINK_NAME=$1
  if [ ! -L "${SERVER_PATH}/${LINK_NAME}" ]; then
    echo "Creating symlink ${SERVER_PATH}/${LINK_NAME} to ${DATA_PATH}/${LINK_NAME}"
    ln -s "${DATA_PATH}/${LINK_NAME}" "${SERVER_PATH}/${LINK_NAME}"
  fi
}

#Check EULA
if [[ "${EULA^^}" != "TRUE" ]]; then
  echo "ERROR: EULA variable must be TRUE!"
  echo "See https://minecraft.net/terms"
  exit 1
fi
#Check necessary data directories
for DIR_NAME in addons backups artifacts worlds ; do
  check_data_dir $DIR_NAME
done
#Check if already initialized
if [ ! -f "${SERVER_PATH}/${EXEC_NAME}" ]; then
  SERVER_INITIALIZED="false"
  echo "Initializing new container."
  #Determine download version
  if [[ "${VERSION^^}" == "LATEST" ]]; then
    echo "Checking https://www.minecraft.net for latest version number."
    get_latest_version
  else
    if [ ! -f "${ARTIFACTS_PATH}/bedrock-server-${VERSION}.zip" ]; then
      download_file "${LINK_NAME}/bedrock-server-${VERSION}.zip" "${ARTIFACTS_PATH}/bedrock-server-${VERSION}.zip"
    fi
  fi
  #Unzip server artifact if ${SERVER_PATH} doesn't exist
  if [ -f "${ARTIFACTS_PATH}/bedrock-server-${VERSION}.zip" ]; then
    extract_server_zip
  fi
else
  #If already initialized, need to read in version & not lookup users
  SERVER_INITIALIZED="true"
  echo "###########################################"
  echo "Already initialized. Did container restart?"
  VERSION=$(cat "${DATA_PATH}/version.txt")
fi
#Check necessary symlinks
for LINK_NAME in worlds Dedicated_Server.txt ; do
  check_symlinks $LINK_NAME
done
#Update server.properties
# shellcheck disable=SC1091
source "${MCBE_HOME}/scripts/server-properties.sh"
update_server_properties
#Check permissions & allowlist
# shellcheck disable=SC1091
source "${MCBE_HOME}/scripts/permissions-allowlist.sh"
check_allowlist
check_permissions
create_cache_files
#Check addons
# shellcheck disable=SC1091
source "${MCBE_HOME}/scripts/addons.sh"
check_addons
#Check pack directories
for PACK_TYPE in behavior_packs resource_packs ; do
  check_pack_type $PACK_TYPE
done

echo "Starting Minecraft Bedrock Server Version ${VERSION} with the following configuration:"
echo "########## SERVER PROPERTIES ##########"
grep "=" "${SERVER_PROPERTIES}" | grep -v "\#" | sort
echo "###############################"
echo ""
echo "########## PERMISSIONS ##########"
cat "${PERMISSIONS_FILE}"
echo "#################################"
echo ""
echo "########## ALLOWLIST ##########"
cat "${ALLOWLIST_FILE}"
echo "#################################"
cd "${SERVER_PATH}"/
export LD_LIBRARY_PATH=.
exec ./"${EXEC_NAME}"