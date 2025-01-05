# These functions generate the permissions.json & allowlist.json files
# Because permissions can update allowlist.json too, need to process allowlist first

check_allowlist() {
  #Check allowlist mode
  if [[ "${ALLOWLIST_MODE,,}" == "static" ]] || [[ "${ALLOWLIST_MODE,,}" == "dynamic" ]]; then
    #If static, overwrite file at start
    if [[ "${ALLOWLIST_MODE,,}" == "static" ]] && [[ "${SERVER_INITIALIZED}" == "false" ]] ; then
      echo "[]" > "${ALLOWLIST_FILE}"
    elif [[ "${ALLOWLIST_MODE,,}" == "static" ]] && [[ "${SERVER_INITIALIZED}" == "true" ]] ; then
      cat "${SERVER_PATH}/allowlist.json.cached" > "${ALLOWLIST_FILE}"
    #If dynamic, create file in data directory if doesn't exist
    elif [[ "${ALLOWLIST_MODE,,}" == "dynamic" ]] && [ ! -f "${ALLOWLIST_FILE}" ]; then
      echo "[]" > "${ALLOWLIST_FILE}"
    fi
  else
    echo "ERROR: Invalid option for ALLOWLIST_MODE!"
    echo "Options are: 'static' or 'dymamic'"
    exit 1
  fi
  #If allowlist is enabled check usernames
  #Because allowlist.json is case sensitive prefer to verify gamertag
  if [[ "${ALLOWLIST_ENABLE,,}" == "true" ]]; then
    #If ALLOWLIST_USERS not empty and not already initialized
    if [[ -n $ALLOWLIST_USERS ]] && [[ "${SERVER_INITIALIZED}" == "false" ]]; then
      #If lookup enabled verify from api
      if [[ "${ALLOWLIST_LOOKUP,,}" == "true" ]]; then
        # shellcheck disable=SC2001
        for USER in $(echo "${ALLOWLIST_USERS}" | sed "s/,/ /g"); do
          playerdb_lookup "${USER}"
        done
      #If lookup disabled write values from env vars
      elif [[ "${ALLOWLIST_LOOKUP,,}" == "false" ]]; then
        jq -n --arg users "${ALLOWLIST_USERS}" '$users | split(",") | map({"name": .})' > "${ALLOWLIST_FILE}"
      else
        echo "ERROR: Invalid option for ALLOWLIST_LOOKUP!"
        echo "Options are: 'true' or 'false'"
        exit 1
      fi
    fi
  fi
}

check_permissions() {
  #Check permissions mode
  if [[ "${PERMISSIONS_MODE,,}" == "static" ]] || [[ "${PERMISSIONS_MODE,,}" == "dynamic" ]]; then
    #If static, overwrite file at start
    if [[ "${PERMISSIONS_MODE,,}" == "static" ]] && [[ "${SERVER_INITIALIZED}" == "false" ]] ; then
      echo "[]" > "${PERMISSIONS_FILE}"
    elif [[ "${PERMISSIONS_MODE,,}" == "static" ]] && [[ "${SERVER_INITIALIZED}" == "true" ]] ; then
      cat "${SERVER_PATH}/permissions.json.cached" > "${PERMISSIONS_FILE}"
    #If dynamic, create file in data directory if doesn't exist
    elif [[ "${PERMISSIONS_MODE,,}" == "dynamic" ]] && [ ! -f "${PERMISSIONS_FILE}" ]; then
      echo "[]" > "${PERMISSIONS_FILE}"
    fi
  else
    echo "ERROR: Invalid option for PERMISSIONS_MODE!"
    echo "Options are: 'static' or 'dymamic'"
    exit 1
  fi
  #If environment variables aren't empty then update permissions if not intialized
  if [[ -n $OPERATORS ]] || [[ -n $MEMBERS ]] || [[ -n $VISITORS ]]; then
    if [[ "${SERVER_INITIALIZED}" == "false" ]]; then
      #If lookup enabled verify from api
      if [[ "${PERMISSIONS_LOOKUP,,}" == "true" ]]; then
        check_permission_levels operator "${OPERATORS}"
        check_permission_levels member "${MEMBERS}"
        check_permission_levels visitor "${VISITORS}"
      #If lookup disabled write values from env vars
      elif [[ "${PERMISSIONS_LOOKUP,,}" == "false" ]]; then
        jq -n --arg operators "$OPERATORS" --arg members "$MEMBERS" --arg visitors "$VISITORS" '[
        [$operators | split(",") | map({permission: "operator", xuid:.})],
        [$members   | split(",") | map({permission: "member", xuid:.})],
        [$visitors  | split(",") | map({permission: "visitor", xuid:.})]
        ]| flatten' > "${PERMISSIONS_FILE}"
      else
        echo "ERROR: Invalid option for PERMISSIONS_LOOKUP!"
        echo "Options are: 'true' or 'false'"
        exit 1
      fi
    fi
  fi
}

check_permission_levels() {
  PERMISSIONS_LEVEL_NAME=$1
  PERMISSIONS_LEVEL_STRING=$2
  if [[ -n $PERMISSIONS_LEVEL_STRING ]]; then
    # shellcheck disable=SC2001
    for PLAYERID in $(echo "${PERMISSIONS_LEVEL_STRING}" | sed "s/,/ /g"); do
      playerdb_lookup "${PLAYERID}" "${PERMISSIONS_LEVEL_NAME}"
    done
  fi
}

playerdb_lookup() {
  PLAYERID=$1
  PERMISSIONS_LEVEL_NAME=$2
  #Make call to get xbl profile data
  PLAYERDB_PROFILE_DATA=$(curl -fsSL -A "cubeworx/mcbe-server:${VERSION}" -H "accept-language:*" "${PLAYERDB_LOOKUP_URL}/${PLAYERID}")
  #If receive proper data update permissions, otherwise fail silently
  #If receive proper data update files, otherwise fail silently
  # shellcheck disable=SC2086
  # shellcheck disable=SC2126
  if [[ $(echo $PLAYERDB_PROFILE_DATA | grep -i success | grep found | wc -l) -ne 0 ]]; then
    PLAYER_USERNAME=$(echo $PLAYERDB_PROFILE_DATA | jq -r '.data.player.username')
    PLAYER_XUID=$(echo $PLAYERDB_PROFILE_DATA | jq -r '.data.player.id')
    if [[ -n $PERMISSIONS_LEVEL_NAME ]]; then
      update_permissions "${PLAYER_USERNAME}" "${PLAYER_XUID}" "${PERMISSIONS_LEVEL_NAME}"
    fi
    #Update allowlist too
    if [[ "${ALLOWLIST_ENABLE,,}" == "true" ]]; then
      update_allowlist "${PLAYER_USERNAME}" "${PLAYER_XUID}" "${PERMISSIONS_LEVEL_NAME}"
    fi
  fi
}

update_allowlist() {
  ALLOWLIST_NAME=$1
  ALLOWLIST_XUID=$2
  PERMISSIONS_LEVEL_NAME=$3
  #Enable operators to join game even if max players limit reached
  if [[ "${PERMISSIONS_LEVEL_NAME}" == "operator" ]]; then
    ALLOWLIST_INFO="{\"name\": \"${ALLOWLIST_NAME}\", \"xuid\": \"${ALLOWLIST_XUID}\", \"ignoresPlayerLimit\": true }"
  else
    ALLOWLIST_INFO="{\"name\": \"${ALLOWLIST_NAME}\", \"xuid\": \"${ALLOWLIST_XUID}\" }"
  fi
  # shellcheck disable=SC2002
  if [[ $(cat "${ALLOWLIST_FILE}" | jq --arg XUID "${ALLOWLIST_XUID}" -r '.[]|select(.xuid == $XUID)' | wc -l) -eq 0 ]]; then
    echo "Adding ${ALLOWLIST_NAME} ${ALLOWLIST_XUID} to ${ALLOWLIST_FILE}"
    jq ". |= . + [${ALLOWLIST_INFO}]" "${ALLOWLIST_FILE}" > "${ALLOWLIST_FILE}.tmp"
    mv "${ALLOWLIST_FILE}.tmp" "${ALLOWLIST_FILE}"
  fi
}

update_permissions() {
  PERMISSIONS_NAME=$1
  PERMISSIONS_XUID=$2
  PERMISSIONS_LEVEL_NAME=$3
  PERMISSIONS_INFO="{\"name\": \"${PERMISSIONS_NAME}\", \"permission\": \"${PERMISSIONS_LEVEL_NAME}\", \"xuid\": \"${PERMISSIONS_XUID}\" }"
  # shellcheck disable=SC2002
  if [[ $(cat "${PERMISSIONS_FILE}" | jq --arg XUID "${PERMISSIONS_XUID}" -r '.[]|select(.xuid == $XUID)' | wc -l) -eq 0 ]]; then
    echo "Adding ${PERMISSIONS_NAME} ${PERMISSIONS_XUID} ${PERMISSIONS_LEVEL_NAME} to ${PERMISSIONS_FILE}"
    jq ". |= . + [${PERMISSIONS_INFO}]" "${PERMISSIONS_FILE}" > "${PERMISSIONS_FILE}.tmp"
    mv "${PERMISSIONS_FILE}.tmp" "${PERMISSIONS_FILE}"
  fi
}

create_cache_files() {
  #Create copies of allowlist.json & permissions.json at init if modes are static
  if [[ "${ALLOWLIST_MODE,,}" == "static" ]] && [[ "${SERVER_INITIALIZED}" == "false" ]] ; then
    cp "${ALLOWLIST_FILE}" "${SERVER_PATH}/allowlist.json.cached"
  fi
  if [[ "${PERMISSIONS_MODE,,}" == "static" ]] && [[ "${SERVER_INITIALIZED}" == "false" ]] ; then
    cp "${PERMISSIONS_FILE}" "${SERVER_PATH}/permissions.json.cached"
  fi
}