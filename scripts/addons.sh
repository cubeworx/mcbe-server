check_addons() {
  echo "Checking for .mcaddon, .mcpack, or .zip files in ${ADDONS_PATH}."
  if [ ! -d "${ADDONS_PATH}" ]; then
    mkdir -p $ADDONS_PATH
  fi
  if [ ! -f "${ADDONS_PATH}/readme.txt" ]; then
    echo "Place .mcaddon, .mcpack, or .zip files here for them to be added to the server" > $ADDONS_PATH/readme.txt
  fi
  for EXT_TYPE in mcaddon mcpack zip ; do
    EXT_CHECK=$(ls -alh $ADDONS_PATH 2> /dev/null | grep ".${EXT_TYPE}" | wc -l)
    if [[ $EXT_CHECK -ne 0 ]]; then
      for FNAME in $ADDONS_PATH/*.$EXT_TYPE ; do
        TMP_DIR=$(mktemp -d -t addon-XXXX --tmpdir=$MCBE_HOME)
        echo "Unzipping ${FNAME}"
        unzip -q "${FNAME}" -d $TMP_DIR
        #If manifest.json exists then file is a pack
        if [ -f "${TMP_DIR}/manifest.json" ]; then
          move_pack "${TMP_DIR}"
        else
          #Check TMP_DIR for compressed files again
          for EXT_TYPE2 in mcaddon mcpack zip ; do
            EXT_CHECK2=$(ls -alh "${TMP_DIR}" 2> /dev/null | grep ".${EXT_TYPE2}" | wc -l)
            if [[ $EXT_CHECK2 -ne 0 ]]; then
              for FNAME2 in ${TMP_DIR}/*.${EXT_TYPE2} ; do
                echo "Unzipping ${FNAME2}"
                unzip -q "${FNAME2}" -d $TMP_DIR
                rm -rf "${FNAME2}"
              done
            fi
          done
          #If folders exist, loop through looking for manifest.json
          for DIR in $TMP_DIR/*/ ; do
            if [ -f "${DIR}/manifest.json" ]; then
              move_pack "${DIR}"
            fi
          done
        fi
        #Delete temporary directory if it exists
        if [ -d "${TMP_DIR}" ]; then
          rm -rf $TMP_DIR
        fi
        rm -rf "${FNAME}"
      done
    fi
  done
}

move_pack() {
  PACK_TMP_PATH=$1
  PACK_UUID=$(cat "${PACK_TMP_PATH}/manifest.json" | jq -cr '.header.uuid')
  PACK_TYPE=$(cat "${PACK_TMP_PATH}/manifest.json" | jq -cr '.modules[].type')
  if [[ "x${PACK_TYPE,,}" == "xdata" ]] || [[ "x${PACK_TYPE,,}" == "xresources" ]]; then
    if [[ "x${PACK_TYPE,,}" == "xdata" ]]; then
      PACK_TYPE_FOLDER="behavior_packs"
    elif [[ "x${PACK_TYPE,,}" == "xresources" ]]; then
      PACK_TYPE_FOLDER="resource_packs"
    fi
    if [ ! -d "${ADDONS_PATH}/${PACK_TYPE_FOLDER}" ]; then
      echo "Creating directory ${ADDONS_PATH}/${PACK_TYPE_FOLDER}"
      mkdir $ADDONS_PATH/$PACK_TYPE_FOLDER
    fi
    mv "${PACK_TMP_PATH}" "${ADDONS_PATH}/${PACK_TYPE_FOLDER}/${PACK_UUID}"
  fi
}

check_pack_type() {
  PACK_TYPE=$1
  echo "Checking ${ADDONS_PATH} for ${PACK_TYPE}."
  if [ -d "${ADDONS_PATH}/${PACK_TYPE}" ]; then
    #Get world name
    LEVEL_NAME=$(cat $SERVER_PROPERTIES | grep "^level-name=" | awk -F 'level-name=' '{print $2}')
    WORLD_PATH=$DATA_PATH/worlds/$LEVEL_NAME
    if [ ! -d "${WORLD_PATH}" ]; then
      echo "Creating directory ${WORLD_PATH}"
      mkdir -p "${WORLD_PATH}"
    fi
    echo "Creating ${WORLD_PATH}/world_${PACK_TYPE}.json"
    echo "[]" > "${WORLD_PATH}/world_${PACK_TYPE}.json"
    #If folders exist, loop through looking for manifest.json
    for PACK_DIR in $ADDONS_PATH/$PACK_TYPE/*/ ; do
      if [ -f "${PACK_DIR}/manifest.json" ]; then
        PACK_NAME=$(cat "${PACK_DIR}/manifest.json" | jq -cr '.header.name')
        PACK_UUID=$(basename $PACK_DIR)
        PACK_VERSION=$(cat "${PACK_DIR}/manifest.json" | jq -cr '.header.version')
        PACK_SERVER_PATH=$SERVER_PATH/$PACK_TYPE/$PACK_UUID
        #Create symlink if not exists
        if [ ! -L "${SERVER_PATH}/${PACK_TYPE}/${PACK_UUID}" ]; then
          echo "Creating symlink ${PACK_SERVER_PATH} to ${PACK_DIR}"
          ln -s $PACK_DIR $PACK_SERVER_PATH
        fi
        #Add uuid & version to world pack
        echo "Adding ${PACK_NAME} uuid & version to ${WORLD_PATH}/world_${PACK_TYPE}.json"
        PACK_INFO="{\"pack_id\": \"${PACK_UUID}\", \"version\": ${PACK_VERSION} }"
        jq ". |= . + [${PACK_INFO}]" "${WORLD_PATH}/world_${PACK_TYPE}.json" > "${WORLD_PATH}/world_${PACK_TYPE}.tmp"
        mv "${WORLD_PATH}/world_${PACK_TYPE}.tmp" "${WORLD_PATH}/world_${PACK_TYPE}.json"
      fi
    done
  fi
}