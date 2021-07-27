update_server_properties() {
  #ALLOW_CHEATS
  if [[ "x${ALLOW_CHEATS}" != "x" ]]; then
    if [[ "x${ALLOW_CHEATS,,}" == "xtrue" ]] || [[ "x${ALLOW_CHEATS,,}" == "xfalse" ]]; then
      sed -i "s/allow-cheats=.*/allow-cheats=${ALLOW_CHEATS}/" $SERVER_PROPERTIES
    else
      echo "ERROR: Invalid option for ALLOW_CHEATS!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #COMPRESSION_THRESHOLD
  if [[ "x${COMPRESSION_THRESHOLD}" != "x" ]]; then
    if [[ "${COMPRESSION_THRESHOLD}" -gt 0 ]] && [[ "${COMPRESSION_THRESHOLD}" -lt 65536 ]]; then
      sed -i "s/compression-threshold=.*/compression-threshold=${COMPRESSION_THRESHOLD}/" $SERVER_PROPERTIES
    else
      echo "ERROR: COMPRESSION_THRESHOLD must be a number between 1-65535!"
      exit 1
    fi
  fi
  #CONTENT_LOG_FILE_ENABLED
  if [[ "x${CONTENT_LOG_FILE_ENABLED}" != "x" ]]; then
    if [[ "x${CONTENT_LOG_FILE_ENABLED,,}" == "xtrue" ]] || [[ "x${CONTENT_LOG_FILE_ENABLED,,}" == "xfalse" ]]; then
      sed -i "s/content-log-file-enabled=.*/content-log-file-enabled=${CONTENT_LOG_FILE_ENABLED}/" $SERVER_PROPERTIES
    else
      echo "ERROR: Invalid option for CONTENT_LOG_FILE_ENABLED!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #CORRECT_PLAYER_MOVEMENT
  if [[ "x${CORRECT_PLAYER_MOVEMENT}" != "x" ]]; then
    if [[ "x${CORRECT_PLAYER_MOVEMENT,,}" == "xtrue" ]] || [[ "x${CORRECT_PLAYER_MOVEMENT,,}" == "xfalse" ]]; then
      sed -i "s/correct-player-movement=.*/correct-player-movement=${CORRECT_PLAYER_MOVEMENT}/" $SERVER_PROPERTIES
    else
      echo "ERROR: Invalid option for CORRECT_PLAYER_MOVEMENT!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #DEFAULT_PLAYER_PERMISSION_LEVEL
  if [[ "x${DEFAULT_PLAYER_PERMISSION_LEVEL}" != "x" ]]; then
    if [[ "x${DEFAULT_PLAYER_PERMISSION_LEVEL,,}" == "xvisitor" ]] || [[ "x${DEFAULT_PLAYER_PERMISSION_LEVEL,,}" == "xmember" ]] || [[ "x${DEFAULT_PLAYER_PERMISSION_LEVEL,,}" == "xoperator" ]]; then
      sed -i "s/default-player-permission-level=.*/default-player-permission-level=${DEFAULT_PLAYER_PERMISSION_LEVEL}/" $SERVER_PROPERTIES
    else
      echo "ERROR: Invalid option for DEFAULT_PLAYER_PERMISSION_LEVEL!"
      echo "Options are: 'visitor', 'member', or 'operator'"
      exit 1
    fi
  fi
  #DIFFICULTY
  if [[ "x${DIFFICULTY}" != "x" ]]; then
    if [[ "x${DIFFICULTY,,}" == "xpeaceful" ]] || [[ "x${DIFFICULTY,,}" == "xeasy" ]] || [[ "x${DIFFICULTY,,}" == "xnormal" ]] || [[ "x${DIFFICULTY,,}" == "xhard" ]]; then
      sed -i "s/difficulty=.*/difficulty=${DIFFICULTY}/" $SERVER_PROPERTIES
    else
      echo "ERROR: Invalid option for DIFFICULTY!"
      echo "Options are: 'peaceful', 'easy', 'normal', or 'hard'"
      exit 1
    fi
  fi
  #FORCE_GAMEMODE
  if [[ "x${FORCE_GAMEMODE}" != "x" ]]; then
    if [[ "x${FORCE_GAMEMODE,,}" == "xtrue" ]] || [[ "x${FORCE_GAMEMODE,,}" == "xfalse" ]]; then
      sed -i "s/force-gamemode=.*/force-gamemode=${FORCE_GAMEMODE}/" $SERVER_PROPERTIES
    else
      echo "ERROR: Invalid option for FORCE_GAMEMODE!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #GAME_MODE
  if [[ "x${GAME_MODE}" != "x" ]]; then
    if [[ "x${GAME_MODE,,}" == "xsurvival" ]] || [[ "x${GAME_MODE,,}" == "xcreative" ]] || [[ "x${GAME_MODE,,}" == "xadventure" ]]; then
      sed -i "s/gamemode=.*/gamemode=${GAME_MODE}/" $SERVER_PROPERTIES
    else
      echo "ERROR: Invalid option for GAME_MODE!"
      echo "Options are: 'survival', 'creative', or 'adventure'"
      exit 1
    fi
  fi
  #LEVEL_NAME
  if [[ "x${LEVEL_NAME}" != "x" ]]; then
    sed -i "s/level-name=.*/level-name=${LEVEL_NAME}/" $SERVER_PROPERTIES
    #TODO: Add logic to check for legal file names
  fi
  #LEVEL_SEED
  if [[ "x${LEVEL_SEED}" != "x" ]] || [ -f "${DATA_PATH}/seed.txt" ]; then
    #If seed.txt exists, use its value instead of ENV
    if [ -f "${DATA_PATH}/seed.txt" ]; then
      echo "Using seed from existing world's seed.txt file!"
      LEVEL_SEED=$(cat $DATA_PATH/seed.txt)
    #If ENV is random then choose one from list
    elif [[ "x${LEVEL_SEED,,}" == "xrandom" ]]; then
      echo "Choosing random seed from integrated seeds list."
      LEVEL_SEED=$(sort $SEEDS_FILE -uR | head -n 1)
    fi
    echo $LEVEL_SEED > $DATA_PATH/seed.txt
    sed -i "s/level-seed=.*/level-seed=${LEVEL_SEED}/" $SERVER_PROPERTIES
  fi
  #LEVEL_TYPE
  if [[ "x${LEVEL_TYPE}" != "x" ]]; then
    if [[ "x${LEVEL_TYPE,,}" == "xdefault" ]] || [[ "x${LEVEL_TYPE,,}" == "xflat" ]] || [[ "x${LEVEL_TYPE,,}" == "xlegacy" ]]; then
      sed -i "s/level-type=.*/level-type=${LEVEL_TYPE^^}/" $SERVER_PROPERTIES
      #level-type missing from recent downloads, insert if env var exists
      if [[ $(cat $SERVER_PROPERTIES | grep "level-type" | wc -l) -eq 0 ]]; then
        echo "" >> $SERVER_PROPERTIES
        echo "level-type="${LEVEL_TYPE^^} >> $SERVER_PROPERTIES
      fi
    else
      echo "ERROR: Invalid option for LEVEL_TYPE!"
      echo "Options are: 'default', 'flat', or 'legacy'"
      exit 1
    fi
  fi
  #MAX_PLAYERS
  if [[ "x${MAX_PLAYERS}" != "x" ]]; then
    if [[ "${MAX_PLAYERS}" =~ ^[0-9]+$ ]]; then
      sed -i "s/max-players=.*/max-players=${MAX_PLAYERS}/" $SERVER_PROPERTIES
    else
      echo "ERROR: MAX_PLAYERS must be a number!"
      exit 1
    fi
  fi
  #MAX_THREADS
  if [[ "x${MAX_THREADS}" != "x" ]]; then
    if [[ "${MAX_THREADS}" =~ ^[0-9]+$ ]]; then
      sed -i "s/max-threads=.*/max-threads=${MAX_THREADS}/" $SERVER_PROPERTIES
    else
      echo "ERROR: MAX_THREADS must be a positive number!"
      exit 1
    fi
  fi
  #ONLINE_MODE
  if [[ "x${ONLINE_MODE}" != "x" ]]; then
    if [[ "x${ONLINE_MODE,,}" == "xfalse" ]] || [[ "x${WHITELIST_ENABLE,,}" == "xtrue" ]]; then
      echo "ERROR: ONLINE_MODE can't be 'false' when WHITELIST_ENABLE is 'true'!"
      exit 1
    elif [[ "x${ONLINE_MODE,,}" == "xtrue" ]] || [[ "x${ONLINE_MODE,,}" == "xfalse" ]]; then
      sed -i "s/online-mode=.*/online-mode=${ONLINE_MODE}/" $SERVER_PROPERTIES
    else
      echo "ERROR: Invalid option for ONLINE_MODE!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #PLAYER_IDLE_TIMEOUT
  if [[ "x${PLAYER_IDLE_TIMEOUT}" != "x" ]]; then
    if [[ "${PLAYER_IDLE_TIMEOUT}" =~ ^[0-9]+$ ]]; then
      sed -i "s/player-idle-timeout=.*/player-idle-timeout=${PLAYER_IDLE_TIMEOUT}/" $SERVER_PROPERTIES
    else
      echo "ERROR: PLAYER_IDLE_TIMEOUT must be a positive number!"
      exit 1
    fi
  fi
  #PLAYER_MOVEMENT_DISTANCE_THRESHOLD
  if [[ "x${PLAYER_MOVEMENT_DISTANCE_THRESHOLD}" != "x" ]]; then
    sed -i "s/player-movement-distance-threshold=.*/player-movement-distance-threshold=${PLAYER_MOVEMENT_DISTANCE_THRESHOLD}/" $SERVER_PROPERTIES
  fi
  #PLAYER_MOVEMENT_DURATION_THRESHOLD_IN_MS
  if [[ "x${PLAYER_MOVEMENT_DURATION_THRESHOLD_IN_MS}" != "x" ]]; then
    if [[ "${PLAYER_MOVEMENT_DURATION_THRESHOLD_IN_MS}" =~ ^[0-9]+$ ]]; then
      sed -i "s/player-movement-duration-threshold-in-ms=.*/player-movement-duration-threshold-in-ms=${PLAYER_MOVEMENT_DURATION_THRESHOLD_IN_MS}/" $SERVER_PROPERTIES
    else
      echo "ERROR: PLAYER_MOVEMENT_DURATION_THRESHOLD_IN_MS must be a number!"
      exit 1
    fi
  fi
  #PLAYER_MOVEMENT_SCORE_THRESHOLD
  if [[ "x${PLAYER_MOVEMENT_SCORE_THRESHOLD}" != "x" ]]; then
    if [[ "${PLAYER_MOVEMENT_SCORE_THRESHOLD}" =~ ^[0-9]+$ ]]; then
      sed -i "s/player-movement-score-threshold=.*/player-movement-score-threshold=${PLAYER_MOVEMENT_SCORE_THRESHOLD}/" $SERVER_PROPERTIES
    else
      echo "ERROR: PLAYER_MOVEMENT_SCORE_THRESHOLD must be a number!"
      exit 1
    fi
  fi
  #SERVER_AUTHORITATIVE_BLOCK_BREAKING
  if [[ "x${SERVER_AUTHORITATIVE_BLOCK_BREAKING}" != "x" ]]; then
    if [[ "x${SERVER_AUTHORITATIVE_BLOCK_BREAKING,,}" == "xtrue" ]] || [[ "x${SERVER_AUTHORITATIVE_BLOCK_BREAKING,,}" == "xfalse" ]]; then
      sed -i "s/server-authoritative-block-breaking=.*/server-authoritative-block-breaking=${SERVER_AUTHORITATIVE_BLOCK_BREAKING}/" $SERVER_PROPERTIES
    else
      echo "ERROR: Invalid option for SERVER_AUTHORITATIVE_BLOCK_BREAKING!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #SERVER_AUTHORITATIVE_MOVEMENT
  if [[ "x${SERVER_AUTHORITATIVE_MOVEMENT}" != "x" ]]; then
    if [[ "x${SERVER_AUTHORITATIVE_MOVEMENT,,}" == "xclient-auth" ]] || [[ "x${SERVER_AUTHORITATIVE_MOVEMENT,,}" == "xserver-auth" ]] || [[ "x${SERVER_AUTHORITATIVE_MOVEMENT,,}" == "server-auth-with-rewind" ]]; then
      sed -i "s/server-authoritative-movement=.*/server-authoritative-movement=${SERVER_AUTHORITATIVE_MOVEMENT}/" $SERVER_PROPERTIES
    else
      echo "ERROR: Invalid option for SERVER_AUTHORITATIVE_MOVEMENT!"
      echo "Options are: 'client-auth', 'server-auth', or 'server-auth-with-rewind'"
      exit 1
    fi
  fi
  #SERVER_NAME
  if [[ "x${SERVER_NAME}" != "x" ]]; then
    sed -i "s/server-name=.*/server-name=${SERVER_NAME}/" $SERVER_PROPERTIES
  fi
  #SERVER_PORT
  if [[ "x${SERVER_PORT}" != "x" ]]; then
    if [[ "${SERVER_PORT}" -gt 0 ]] && [[ "${SERVER_PORT}" -lt 65536 ]]; then
      sed -i "s/server-port=.*/server-port=${SERVER_PORT}/" $SERVER_PROPERTIES
    else
      echo "ERROR: SERVER_PORT must be a number between 1-65535!"
      exit 1
    fi
  fi
  #SERVER_PORTV6
  if [[ "x${SERVER_PORTV6}" != "x" ]]; then
    if [[ "${SERVER_PORTV6}" -gt 0 ]] && [[ "${SERVER_PORTV6}" -lt 65536 ]]; then
      sed -i "s/server-portv6=.*/server-portv6=${SERVER_PORTV6}/" $SERVER_PROPERTIES
    else
      echo "ERROR: SERVER_PORTV6 must be a number between 1-65535!"
      exit 1
    fi
  fi
  #TEXTUREPACK_REQUIRED
  if [[ "x${TEXTUREPACK_REQUIRED}" != "x" ]]; then
    if [[ "x${TEXTUREPACK_REQUIRED,,}" == "xtrue" ]] || [[ "x${TEXTUREPACK_REQUIRED,,}" == "xfalse" ]]; then
      sed -i "s/texturepack-required=.*/texturepack-required=${TEXTUREPACK_REQUIRED}/" $SERVER_PROPERTIES
    else
      echo "ERROR: Invalid option for TEXTUREPACK_REQUIRED!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #TICK_DISTANCE
  if [[ "x${TICK_DISTANCE}" != "x" ]]; then
    if [[ "${TICK_DISTANCE}" -gt 3 ]] && [[ "${TICK_DISTANCE}" -lt 13 ]]; then
      sed -i "s/tick-distance=.*/tick-distance=${TICK_DISTANCE}/" $SERVER_PROPERTIES
    else
      echo "ERROR: TICK_DISTANCE must be a number between 4 and 12!"
      exit 1
    fi
  fi
  #VIEW_DISTANCE
  if [[ "x${VIEW_DISTANCE}" != "x" ]]; then
    if [[ "${VIEW_DISTANCE}" -gt 4 ]] && [[ "${VIEW_DISTANCE}" =~ ^[0-9]+$ ]]; then
      sed -i "s/view-distance=.*/view-distance=${VIEW_DISTANCE}/" $SERVER_PROPERTIES
    else
      echo "ERROR: VIEW_DISTANCE must be a positive number greater than 4!"
      exit 1
    fi
  fi
  #WHITELIST_ENABLE
  if [[ "x${WHITELIST_ENABLE}" != "x" ]]; then
    if [[ "x${WHITELIST_ENABLE,,}" == "xtrue" ]] || [[ "x${WHITELIST_ENABLE,,}" == "xfalse" ]]; then
      if [[ "x${WHITELIST_ENABLE,,}" == "xtrue" ]] && [[ "x${WHITELIST_USERS}" == "x" ]]; then
        echo "ERROR: If WHITELIST_ENABLE is true then WHITELIST_USERS cannot be empty!"
        exit 1
      else
        sed -i "s/white-list=.*/white-list=${WHITELIST_ENABLE}/" $SERVER_PROPERTIES
      fi
    else
      echo "ERROR: Invalid option for WHITELIST_ENABLE!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
}