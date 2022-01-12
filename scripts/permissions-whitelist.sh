# These functions generate the permissions.json & whitelist.json files
# Because permissions can update whitelist.json too, need to process whitelist first

check_whitelist() {
  #Check whitelist mode
  if [[ "x${WHITELIST_MODE,,}" == "xstatic" ]] || [[ "x${WHITELIST_MODE,,}" == "xdynamic" ]]; then
    #If static, overwrite file at start
    if [[ "x${WHITELIST_MODE,,}" == "xstatic" ]] && [[ "x${SERVER_INITIALIZED}" == "xfalse" ]] ; then
      echo "[]" > $WHITELIST_FILE
    elif [[ "x${WHITELIST_MODE,,}" == "xstatic" ]] && [[ "x${SERVER_INITIALIZED}" == "xtrue" ]] ; then
      cat $SERVER_PATH/whitelist.json.cached > $WHITELIST_FILE
    #If dynamic, create file in data directory if doesn't exist
    elif [[ "x${WHITELIST_MODE,,}" == "xdynamic" ]] && [ ! -f "${WHITELIST_FILE}" ]; then
      echo "[]" > $WHITELIST_FILE
    fi
  else
    echo "ERROR: Invalid option for WHITELIST_MODE!"
    echo "Options are: 'static' or 'dymamic'"
    exit 1
  fi
  #If whitelist is enabled check usernames
  #Because whitelist.json is case sensitive prefer to verify username
  if [[ "x${WHITELIST_ENABLE,,}" == "xtrue" ]]; then
    #If WHITELIST_USERS not empty and not already initialized
    if [[ "x${WHITELIST_USERS}" != "x" ]] && [[ "x${SERVER_INITIALIZED}" == "xfalse" ]]; then
      #If lookup enabled verify from api
      if [[ "x${WHITELIST_LOOKUP,,}" == "xtrue" ]]; then
        for USER in $(echo $WHITELIST_USERS | sed "s/,/ /g"); do
          lookup_player_profile $USER
        done
      #If lookup disabled write values from env vars
      elif [[ "x${WHITELIST_LOOKUP,,}" == "xfalse" ]]; then
        jq -n --arg users "${WHITELIST_USERS}" '$users | split(",") | map({"name": .})' > $WHITELIST_FILE
      else
        echo "ERROR: Invalid option for WHITELIST_LOOKUP!"
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
  PERMISSIONS_LEVEL_PLAYERS=$2
  if [[ "x${PERMISSIONS_LEVEL_PLAYERS}" != "x" ]]; then
    for PLAYER in $(echo PERMISSIONS_LEVEL_PLAYERS | sed "s/,/ /g"); do
      lookup_player_profile $PLAYER $PERMISSIONS_LEVEL_NAME
    done
  fi
}

lookup_player_profile() {
  $PLAYER=$1
  PERMISSIONS_LEVEL_NAME=$2
  #Make call to get player profile data
  PLAYER_PROFILE_DATA=$(curl -fsSL -A "cubeworx/mcbe-server:${VERSION}" -H "accept-language:*" $PLAYER_LOOKUP_URL/$PLAYER)
  #If receive proper data update permissions, otherwise fail silently
  if [[ $(echo $PLAYER_PROFILE_DATA | grep "player.found" | wc -l) -ne 0 ]]; then
    PLAYER_USERNAME=$(echo $PLAYER_PROFILE_DATA | jq -r '.data.player.username')
    PLAYER_XUID=$(echo $PLAYER_PROFILE_DATA | jq -r '.data.player.id')
    if [[ "x${PERMISSIONS_LEVEL_NAME}" != "x" ]]; then
      update_permissions $PLAYER_USERNAME $PLAYER_XUID $PERMISSIONS_LEVEL_NAME
    fi
    #Update whitelist too
    if [[ "x${WHITELIST_ENABLE,,}" == "xtrue" ]]; then
      update_whitelist $PLAYER_USERNAME $PLAYER_XUID $PERMISSIONS_LEVEL_NAME
    fi
  fi
}

update_whitelist() {
  WHITELIST_NAME=$1
  WHITELIST_XUID=$2
  PERMISSIONS_LEVEL_NAME=$3
  #Enable operators to join game even if max players limit reached
  if [[ "x${PERMISSIONS_LEVEL_NAME}" == "xoperator" ]]; then
    WHITELIST_INFO="{\"name\": \"${WHITELIST_NAME}\", \"xuid\": \"${WHITELIST_XUID}\", \"ignoresPlayerLimit\": true }"
  else
    WHITELIST_INFO="{\"name\": \"${WHITELIST_NAME}\", \"xuid\": \"${WHITELIST_XUID}\" }"
  fi
  if [[ $(cat $WHITELIST_FILE | jq --arg XUID "${WHITELIST_XUID}" -r '.[]|select(.xuid == $XUID)' | wc -l) -eq 0 ]]; then
    echo "Adding ${WHITELIST_NAME} ${WHITELIST_XUID} to ${WHITELIST_FILE}"
    jq ". |= . + [${WHITELIST_INFO}]" $WHITELIST_FILE > "${WHITELIST_FILE}.tmp"
    mv "${WHITELIST_FILE}.tmp" $WHITELIST_FILE
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
  #Create copies of whitelist.json & permissions.json at init if modes are static
  if [[ "x${WHITELIST_MODE,,}" == "xstatic" ]] && [[ "x${SERVER_INITIALIZED}" == "xfalse" ]] ; then
    cp $WHITELIST_FILE $SERVER_PATH/whitelist.json.cached
  fi
  if [[ "x${PERMISSIONS_MODE,,}" == "xstatic" ]] && [[ "x${SERVER_INITIALIZED}" == "xfalse" ]] ; then
    cp $PERMISSIONS_FILE $SERVER_PATH/permissions.json.cached
  fi
}