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
        update_permissions $PERMISSIONS_LEVEL_NAME $STRING
      else
        XUID=$(curl -fsSL -A "cubeworx/mcbe-server" -H "accept-language:*" $XUID_LOOKUP_ENDPOINT/xuid | jq -r '.xuid')
        if [[ "x${XUID}" != "x" ]] && [[ "${XUID}" =~ ^[0-9]+$ ]]; then
          update_permissions $PERMISSIONS_LEVEL_NAME $XUID
        fi
      fi
    done
  fi
}

update_permissions() {
  PERMISSIONS_LEVEL_NAME=$1
  PERMISSIONS_XUID=$2
  echo "Adding ${PERMISSIONS_LEVEL_NAME} ${PERMISSIONS_XUID} to ${SERVER_PERMISSIONS}"
  PERMISSIONS_INFO="{\"permission\": \"${PERMISSIONS_LEVEL_NAME}\", \"xuid\": \"${PERMISSIONS_XUID}\" }"
  jq ". |= . + [${PERMISSIONS_INFO}]" $SERVER_PERMISSIONS > "${SERVER_PERMISSIONS}.tmp"
  mv "${SERVER_PERMISSIONS}.tmp" $SERVER_PERMISSIONS
}

update_whitelist() {
  if [[ "x${WHITELIST_USERS}" != "x" ]] && [[ "x${WHITELIST_ENABLE,,}" == "xtrue" ]]; then
    jq -n --arg users "${WHITELIST_USERS}" '$users | split(",") | map({"name": .})' > $SERVER_PATH/$WHITELIST_FILE
  fi
}

