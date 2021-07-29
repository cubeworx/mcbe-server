# These functions generate the permissions.json & whitelist.json files

check_permissions() {
  if [[ "x${OPERATORS}" != "x" ]] || [[ "x${MEMBERS}" != "x" ]] || [[ "x${VISITORS}" != "x" ]]; then
    #Check permissions mode
    if [[ "x${PERMISSIONS_MODE,,}" == "xstatic" ]] || [[ "x${PERMISSIONS_MODE,,}" == "xdynamic" ]]; then
      #If static, overwrite file every start
      if [[ "x${PERMISSIONS_MODE,,}" == "xstatic" ]]; then
        SERVER_PERMISSIONS=$SERVER_PATH/$PERMISSIONS_FILE
      #If dynamic, use file in data directory
      elif [[ "x${PERMISSIONS_MODE,,}" == "xdynamic" ]]; then
        SERVER_PERMISSIONS=$DATA_PATH/$PERMISSIONS_FILE
        #Create file in data directory if doesn't exist
        if [ ! -f "${SERVER_PERMISSIONS}" ]; then
          echo "[]" > $SERVER_PERMISSIONS
        fi
        #If file in server directory exists, delete and create symlink
        if [ -f "${SERVER_PATH}/${PERMISSIONS_FILE}" ] && [ ! -L "${SERVER_PATH}/${PERMISSIONS_FILE}" ]; then
          rm -rf $SERVER_PATH/$PERMISSIONS_FILE
          echo "Creating symlink ${SERVER_PATH}/${PERMISSIONS_FILE} to ${DATA_PATH}/${PERMISSIONS_FILE}"
          ln -s $DATA_PATH/$PERMISSIONS_FILE $SERVER_PATH/$PERMISSIONS_FILE
        fi
      fi
      check_permission_levels operator $OPERATORS
      check_permission_levels member $MEMBERS
      check_permission_levels visitor $VISITORS 
    else
      echo "ERROR: Invalid option for PERMISSIONS_MODE!"
      echo "Options are: 'static' or 'dymamic'"
      exit 1
    fi
  fi
}

check_permission_levels() {
  PERMISSIONS_LEVEL_NAME=$1
  PERMISSIONS_LEVEL_STRING=$2
  if [[ "x${PERMISSIONS_LEVEL_STRING}" != "x" ]]; then
    for STRING in $(echo $PERMISSIONS_LEVEL_STRING | sed "s/,/ /g"); do
      #Determine if value is xuid or gamertag, not reliable if gamertag is just numbers
      if [[ "${STRING}" =~ ^[0-9]+$ ]]; then
        LOOKUP="xuid"
      else
        LOOKUP="gamertag"
      fi
      lookup_xbl_profile $LOOKUP $STRING
    done
  fi
}

lookup_xbl_profile() {
  XBL_LOOKUP=$1
  XBL_STRING=$2
  #Make call to get xbl profile data
  XBL_PROFILE_DATA=$(curl -fsSL -A "cubeworx/mcbe-server" -H "accept-language:*" $XBL_LOOKUP_URL/$XBL_LOOKUP/$XBL_STRING)
  if [[ $(echo $XBL_PROFILE_DATA | grep hostId | grep Gamertag | wc -l) -ne 0 ]]; then
    XBL_GAMERTAG=$(echo $XBL_PROFILE_DATA | jq -r '.profileUsers[].settings[]|select(.id == "Gamertag").value')
    XBL_XUID=$(echo $XBL_PROFILE_DATA | jq -r '.profileUsers[].id')
    #If values are valid then update permissions
    update_permissions $PERMISSIONS_LEVEL_NAME $XBL_GAMERTAG $XBL_XUID
  fi
}

update_permissions() {
  PERMISSIONS_LEVEL_NAME=$1
  PERMISSIONS_NAME=$2
  PERMISSIONS_XUID=$3
  PERMISSIONS_INFO="{\"name\": \"${PERMISSIONS_NAME}\", \"permission\": \"${PERMISSIONS_LEVEL_NAME}\", \"xuid\": \"${PERMISSIONS_XUID}\" }"
  if [[ $(cat $SERVER_PERMISSIONS | jq --arg XUID "${PERMISSIONS_XUID}" -r '.[]|select(.xuid == $XUID)' | wc -l) -eq 0 ]]; then
    echo "Adding ${PERMISSIONS_NAME} ${PERMISSIONS_XUID} ${PERMISSIONS_LEVEL_NAME} to ${SERVER_PERMISSIONS}"
    jq ". |= . + [${PERMISSIONS_INFO}]" $SERVER_PERMISSIONS > "${SERVER_PERMISSIONS}.tmp"
    mv "${SERVER_PERMISSIONS}.tmp" $SERVER_PERMISSIONS
  fi
}

update_whitelist() {
  if [[ "x${WHITELIST_USERS}" != "x" ]] && [[ "x${WHITELIST_ENABLE,,}" == "xtrue" ]]; then
    jq -n --arg users "${WHITELIST_USERS}" '$users | split(",") | map({"name": .})' > $SERVER_PATH/$WHITELIST_FILE
  fi
}

