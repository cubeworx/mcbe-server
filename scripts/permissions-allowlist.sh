# These functions generate the permissions.json & allowlist.json files
# Because permissions can update allowlist.json too, need to process allowlist first

check_allowlist() {
  #Check allowlist mode
  if [[ "x${ALLOWLIST_MODE,,}" == "xstatic" ]] || [[ "x${ALLOWLIST_MODE,,}" == "xdynamic" ]]; then
    #If static, overwrite file at start
    if [[ "x${ALLOWLIST_MODE,,}" == "xstatic" ]] && [[ "x${SERVER_INITIALIZED}" == "xfalse" ]] ; then
      echo "[]" > $ALLOWLIST_FILE
    elif [[ "x${ALLOWLIST_MODE,,}" == "xstatic" ]] && [[ "x${SERVER_INITIALIZED}" == "xtrue" ]] ; then
      cat $SERVER_PATH/allowlist.json.cached > $ALLOWLIST_FILE
    #If dynamic, create file in data directory if doesn't exist
    elif [[ "x${ALLOWLIST_MODE,,}" == "xdynamic" ]] && [ ! -f "${ALLOWLIST_FILE}" ]; then
      echo "[]" > $ALLOWLIST_FILE
    fi
  else
    echo "ERROR: Invalid option for ALLOWLIST_MODE!"
    echo "Options are: 'static' or 'dymamic'"
    exit 1
  fi
  #If allowlist is enabled check usernames
  #Because allowlist.json is case sensitive prefer to verify gamertag
  if [[ "x${ALLOWLIST_ENABLE,,}" == "xtrue" ]]; then
    #If ALLOWLIST_USERS not empty and not already initialized
    if [[ "x${ALLOWLIST_USERS}" != "x" ]] && [[ "x${SERVER_INITIALIZED}" == "xfalse" ]]; then
      #If lookup enabled verify from api
      if [[ "x${ALLOWLIST_LOOKUP,,}" == "xtrue" ]]; then
        for USER in $(echo $ALLOWLIST_USERS | sed "s/,/ /g"); do
          playerdb_lookup $USER
        done
      #If lookup disabled write values from env vars
      elif [[ "x${ALLOWLIST_LOOKUP,,}" == "xfalse" ]]; then
        jq -n --arg users "${ALLOWLIST_USERS}" '$users | split(",") | map({"name": .})' > $ALLOWLIST_FILE
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
  if [[ "x${PERMISSIONS_MODE,,}" == "xstatic" ]] || [[ "x${PERMISSIONS_MODE,,}" == "xdynamic" ]]; then
    #If static, overwrite file at start
    if [[ "x${PERMISSIONS_MODE,,}" == "xstatic" ]] && [[ "x${SERVER_INITIALIZED}" == "xfalse" ]] ; then
      echo "[]" > $PERMISSIONS_FILE
    elif [[ "x${PERMISSIONS_MODE,,}" == "xstatic" ]] && [[ "x${SERVER_INITIALIZED}" == "xtrue" ]] ; then
      cat $SERVER_PATH/permissions.json.cached > $PERMISSIONS_FILE
    #If dynamic, create file in data directory if doesn't exist
    elif [[ "x${PERMISSIONS_MODE,,}" == "xdynamic" ]] && [ ! -f "${PERMISSIONS_FILE}" ]; then
      echo "[]" > $PERMISSIONS_FILE
    fi
  else
    echo "ERROR: Invalid option for PERMISSIONS_MODE!"
    echo "Options are: 'static' or 'dymamic'"
    exit 1
  fi
  #If environment variables aren't empty then update permissions if not intialized
  if [[ "x${OPERATORS}" != "x" ]] || [[ "x${MEMBERS}" != "x" ]] || [[ "x${VISITORS}" != "x" ]]; then
    if [[ "x${SERVER_INITIALIZED}" == "xfalse" ]]; then
      #If lookup enabled verify from api
      if [[ "x${PERMISSIONS_LOOKUP,,}" == "xtrue" ]]; then
        check_permission_levels operator $OPERATORS
        check_permission_levels member $MEMBERS
        check_permission_levels visitor $VISITORS
      #If lookup disabled write values from env vars
      elif [[ "x${PERMISSIONS_LOOKUP,,}" == "xfalse" ]]; then
        jq -n --arg operators "$OPERATORS" --arg members "$MEMBERS" --arg visitors "$VISITORS" '[
        [$operators | split(",") | map({permission: "operator", xuid:.})],
        [$members   | split(",") | map({permission: "member", xuid:.})],
        [$visitors  | split(",") | map({permission: "visitor", xuid:.})]
        ]| flatten' > $PERMISSIONS_FILE
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
  if [[ "x${PERMISSIONS_LEVEL_STRING}" != "x" ]]; then
    for PLAYERID in $(echo $PERMISSIONS_LEVEL_STRING | sed "s/,/ /g"); do
      playerdb_lookup $PLAYERID $PERMISSIONS_LEVEL_NAME
    done
  fi
}

playerdb_lookup() {
  PLAYERID=$1
  PERMISSIONS_LEVEL_NAME=$2
  #Make call to get xbl profile data
  PLAYERDB_PROFILE_DATA=$(curl -fsSL -A "cubeworx/mcbe-server:${VERSION}" -H "accept-language:*" $PLAYERDB_LOOKUP_URL/$PLAYERID)
  #If receive proper data update permissions, otherwise fail silently
  if [[ $(echo $PLAYERDB_PROFILE_DATA | grep -i success | grep found | wc -l) -ne 0 ]]; then
    PLAYER_USERNAME=$(echo $PLAYERDB_PROFILE_DATA | jq -r '.data.player.username')
    PLAYER_XUID=$(echo $PLAYERDB_PROFILE_DATA | jq -r '.data.player.id')
    if [[ "x${PERMISSIONS_LEVEL_NAME}" != "x" ]]; then
      update_permissions $PLAYER_USERNAME $PLAYER_XUID $PERMISSIONS_LEVEL_NAME
    fi
    #Update allowlist too
    if [[ "x${ALLOWLIST_ENABLE,,}" == "xtrue" ]]; then
      update_allowlist $PLAYER_USERNAME $PLAYER_XUID $PERMISSIONS_LEVEL_NAME
    fi
  fi
}

update_allowlist() {
  ALLOWLIST_NAME=$1
  ALLOWLIST_XUID=$2
  PERMISSIONS_LEVEL_NAME=$3
  #Enable operators to join game even if max players limit reached
  if [[ "x${PERMISSIONS_LEVEL_NAME}" == "xoperator" ]]; then
    ALLOWLIST_INFO="{\"name\": \"${ALLOWLIST_NAME}\", \"xuid\": \"${ALLOWLIST_XUID}\", \"ignoresPlayerLimit\": true }"
  else
    ALLOWLIST_INFO="{\"name\": \"${ALLOWLIST_NAME}\", \"xuid\": \"${ALLOWLIST_XUID}\" }"
  fi
  if [[ $(cat $ALLOWLIST_FILE | jq --arg XUID "${ALLOWLIST_XUID}" -r '.[]|select(.xuid == $XUID)' | wc -l) -eq 0 ]]; then
    echo "Adding ${ALLOWLIST_NAME} ${ALLOWLIST_XUID} to ${ALLOWLIST_FILE}"
    jq ". |= . + [${ALLOWLIST_INFO}]" $ALLOWLIST_FILE > "${ALLOWLIST_FILE}.tmp"
    mv "${ALLOWLIST_FILE}.tmp" $ALLOWLIST_FILE
  fi
}

update_permissions() {
  PERMISSIONS_NAME=$1
  PERMISSIONS_XUID=$2
  PERMISSIONS_LEVEL_NAME=$3
  PERMISSIONS_INFO="{\"name\": \"${PERMISSIONS_NAME}\", \"permission\": \"${PERMISSIONS_LEVEL_NAME}\", \"xuid\": \"${PERMISSIONS_XUID}\" }"
  if [[ $(cat $PERMISSIONS_FILE | jq --arg XUID "${PERMISSIONS_XUID}" -r '.[]|select(.xuid == $XUID)' | wc -l) -eq 0 ]]; then
    echo "Adding ${PERMISSIONS_NAME} ${PERMISSIONS_XUID} ${PERMISSIONS_LEVEL_NAME} to ${PERMISSIONS_FILE}"
    jq ". |= . + [${PERMISSIONS_INFO}]" $PERMISSIONS_FILE > "${PERMISSIONS_FILE}.tmp"
    mv "${PERMISSIONS_FILE}.tmp" $PERMISSIONS_FILE
  fi
}

create_cache_files() {
  #Create copies of allowlist.json & permissions.json at init if modes are static
  if [[ "x${ALLOWLIST_MODE,,}" == "xstatic" ]] && [[ "x${SERVER_INITIALIZED}" == "xfalse" ]] ; then
    cp $ALLOWLIST_FILE $SERVER_PATH/allowlist.json.cached
  fi
  if [[ "x${PERMISSIONS_MODE,,}" == "xstatic" ]] && [[ "x${SERVER_INITIALIZED}" == "xfalse" ]] ; then
    cp $PERMISSIONS_FILE $SERVER_PATH/permissions.json.cached
  fi
}