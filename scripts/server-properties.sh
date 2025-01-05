update_server_properties() {
  #ALLOW_CHEATS - Added 1.6.1
  if [[ -n ${ALLOW_CHEATS} ]]; then
    if [[ "${ALLOW_CHEATS,,}" == "true" ]] || [[ "${ALLOW_CHEATS,,}" == "false" ]]; then
      sed -i "s/allow-cheats=.*/allow-cheats=${ALLOW_CHEATS}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for ALLOW_CHEATS!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #ALLOW_INBOUND_SCRIPT_DEBUGGING
  if [[ -n ${ALLOW_INBOUND_SCRIPT_DEBUGGING} ]]; then
    if [[ "${ALLOW_INBOUND_SCRIPT_DEBUGGING,,}" == "true" ]] || [[ "${ALLOW_INBOUND_SCRIPT_DEBUGGING,,}" == "false" ]]; then
      sed -i "s/allow-inbound-script-debugging=.*/allow-inbound-script-debugging=${ALLOW_INBOUND_SCRIPT_DEBUGGING}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for ALLOW_INBOUND_SCRIPT_DEBUGGING!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #ALLOWLIST_ENABLE - Renamed in 1.18.10
  if [[ -n ${ALLOWLIST_ENABLE} ]]; then
    if [[ "${ALLOWLIST_ENABLE,,}" == "true" ]] || [[ "${ALLOWLIST_ENABLE,,}" == "false" ]]; then
      if [[ "${ALLOWLIST_ENABLE,,}" == "true" ]]; then
        if [[ "${ALLOWLIST_USERS}" == "" ]] && [[ "${OPERATORS}" == "" ]] && [[ "${MEMBERS}" == "" ]] && [[ "${VISITORS}" == "" ]]; then
          echo "ERROR: If ALLOWLIST_ENABLE is true then either ALLOWLIST_USERS, OPERATORS, MEMBERS, or VISITORS must not be empty!"
          exit 1
        fi
        sed -i "s/allow-list=.*/allow-list=${ALLOWLIST_ENABLE}/" "${SERVER_PROPERTIES}"
        sed -i "s/white-list=.*/white-list=${ALLOWLIST_ENABLE}/" "${SERVER_PROPERTIES}"
      fi
    else
      echo "ERROR: Invalid option for ALLOWLIST_ENABLE!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #ALLOW_OUTBOUND_SCRIPT_DEBUGGING
  if [[ -n ${ALLOW_OUTBOUND_SCRIPT_DEBUGGING} ]]; then
    if [[ "${ALLOW_OUTBOUND_SCRIPT_DEBUGGING,,}" == "true" ]] || [[ "${ALLOW_OUTBOUND_SCRIPT_DEBUGGING,,}" == "false" ]]; then
      sed -i "s/allow-outbound-script-debugging=.*/allow-outbound-script-debugging=${ALLOW_OUTBOUND_SCRIPT_DEBUGGING}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for ALLOW_OUTBOUND_SCRIPT_DEBUGGING!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #BLOCK_NETWORK_IDS_ARE_HASHES
  if [[ -n ${BLOCK_NETWORK_IDS_ARE_HASHES} ]]; then
    if [[ "${BLOCK_NETWORK_IDS_ARE_HASHES,,}" == "true" ]] || [[ "${BLOCK_NETWORK_IDS_ARE_HASHES,,}" == "false" ]]; then
      sed -i "s/block-network-ids-are-hashes=.*/block-network-ids-are-hashes=${BLOCK_NETWORK_IDS_ARE_HASHES}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for BLOCK_NETWORK_IDS_ARE_HASHES!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #CHAT_RESTRICTION
  if [[ -n ${CHAT_RESTRICTION} ]]; then
    if [[ "${CHAT_RESTRICTION}" == "None" ]] || [[ "${CHAT_RESTRICTION}" == "Dropped" ]] || [[ "${CHAT_RESTRICTION}" == "Disabled" ]]; then
      sed -i "s/chat-restriction=.*/chat-restriction=${CHAT_RESTRICTION}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for CHAT_RESTRICTION!"
      echo "Options are: 'None', 'Dropped', or 'Disabled'"
      exit 1
    fi
  fi
  #CLIENT_SIDE_CHUNK_GENERATION_ENABLED
  if [[ -n ${CLIENT_SIDE_CHUNK_GENERATION_ENABLED} ]]; then
    if [[ "${CLIENT_SIDE_CHUNK_GENERATION_ENABLED,,}" == "true" ]] || [[ "${CLIENT_SIDE_CHUNK_GENERATION_ENABLED,,}" == "false" ]]; then
      sed -i "s/client-side-chunk-generation-enabled=.*/client-side-chunk-generation-enabled=${CLIENT_SIDE_CHUNK_GENERATION_ENABLED}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for CLIENT_SIDE_CHUNK_GENERATION_ENABLED!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #COMPRESSION_ALGORITHM
  if [[ -n ${COMPRESSION_ALGORITHM} ]]; then
    if [[ "${COMPRESSION_ALGORITHM,,}" == "zlib" ]] || [[ "${COMPRESSION_ALGORITHM,,}" == "snappy" ]]; then
      sed -i "s/compression-algorithm=.*/compression-algorithm=${COMPRESSION_ALGORITHM}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for COMPRESSION_ALGORITHM!"
      echo "Options are: 'zlib' or 'snappy'"
      exit 1
    fi
  fi
  #COMPRESSION_THRESHOLD - Added 1.13.0
  if [[ -n ${COMPRESSION_THRESHOLD} ]]; then
    if [[ "${COMPRESSION_THRESHOLD}" -gt 0 ]] && [[ "${COMPRESSION_THRESHOLD}" -lt 65536 ]]; then
      sed -i "s/compression-threshold=.*/compression-threshold=${COMPRESSION_THRESHOLD}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: COMPRESSION_THRESHOLD must be a number between 1-65535!"
      exit 1
    fi
  fi
  #CONTENT_LOG_FILE_ENABLED - Added 1.12.0.28
  if [[ -n ${CONTENT_LOG_FILE_ENABLED} ]]; then
    if [[ "${CONTENT_LOG_FILE_ENABLED,,}" == "true" ]] || [[ "${CONTENT_LOG_FILE_ENABLED,,}" == "false" ]]; then
      sed -i "s/content-log-file-enabled=.*/content-log-file-enabled=${CONTENT_LOG_FILE_ENABLED}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for CONTENT_LOG_FILE_ENABLED!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #CORRECT_PLAYER_MOVEMENT - Added 1.13.0
  if [[ -n ${CORRECT_PLAYER_MOVEMENT} ]]; then
    if [[ "${CORRECT_PLAYER_MOVEMENT,,}" == "true" ]] || [[ "${CORRECT_PLAYER_MOVEMENT,,}" == "false" ]]; then
      sed -i "s/correct-player-movement=.*/correct-player-movement=${CORRECT_PLAYER_MOVEMENT}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for CORRECT_PLAYER_MOVEMENT!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #DEFAULT_PLAYER_PERMISSION_LEVEL - Added 1.7.0
  if [[ -n ${DEFAULT_PLAYER_PERMISSION_LEVEL} ]]; then
    if [[ "${DEFAULT_PLAYER_PERMISSION_LEVEL,,}" == "visitor" ]] || [[ "${DEFAULT_PLAYER_PERMISSION_LEVEL,,}" == "member" ]] || [[ "${DEFAULT_PLAYER_PERMISSION_LEVEL,,}" == "operator" ]]; then
      sed -i "s/default-player-permission-level=.*/default-player-permission-level=${DEFAULT_PLAYER_PERMISSION_LEVEL}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for DEFAULT_PLAYER_PERMISSION_LEVEL!"
      echo "Options are: 'visitor', 'member', or 'operator'"
      exit 1
    fi
  fi
  #DIFFICULTY - Added 1.6.1
  if [[ -n ${DIFFICULTY} ]]; then
    if [[ "${DIFFICULTY,,}" == "peaceful" ]] || [[ "${DIFFICULTY,,}" == "easy" ]] || [[ "${DIFFICULTY,,}" == "normal" ]] || [[ "${DIFFICULTY,,}" == "hard" ]]; then
      sed -i "s/difficulty=.*/difficulty=${DIFFICULTY}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for DIFFICULTY!"
      echo "Options are: 'peaceful', 'easy', 'normal', or 'hard'"
      exit 1
    fi
  fi
  #DISABLE_CUSTOM_SKINS
  if [[ -n ${DISABLE_CUSTOM_SKINS} ]]; then
    if [[ "${DISABLE_CUSTOM_SKINS,,}" == "true" ]] || [[ "${DISABLE_CUSTOM_SKINS,,}" == "false" ]]; then
      sed -i "s/disable-custom-skins=.*/disable-custom-skins=${DISABLE_CUSTOM_SKINS}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for DISABLE_CUSTOM_SKINS!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #DISABLE_PERSONA
  if [[ -n ${DISABLE_PERSONA} ]]; then
    if [[ "${DISABLE_PERSONA,,}" == "true" ]] || [[ "${DISABLE_PERSONA,,}" == "false" ]]; then
      sed -i "s/disable-persona=.*/disable-persona=${DISABLE_PERSONA}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for DISABLE_PERSONA!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #DISABLE_PLAYER_INTERACTION
  if [[ -n ${DISABLE_PLAYER_INTERACTION} ]]; then
    if [[ "${DISABLE_PLAYER_INTERACTION,,}" == "true" ]] || [[ "${DISABLE_PLAYER_INTERACTION,,}" == "false" ]]; then
      sed -i "s/disable-player-interaction=.*/disable-player-interaction=${DISABLE_PLAYER_INTERACTION}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for DISABLE_PLAYER_INTERACTION!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #ENABLE_LAN_VISIBILITY
  if [[ -n ${ENABLE_LAN_VISIBILITY} ]]; then
    if [[ "${ENABLE_LAN_VISIBILITY,,}" == "true" ]] || [[ "${ENABLE_LAN_VISIBILITY,,}" == "false" ]]; then
      sed -i "s/enable-lan-visibility=.*/enable-lan-visibility=${ENABLE_LAN_VISIBILITY}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for ENABLE_LAN_VISIBILITY!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #FORCE_GAMEMODE - Added 1.16.210
  if [[ -n ${FORCE_GAMEMODE} ]]; then
    if [[ "${FORCE_GAMEMODE,,}" == "true" ]] || [[ "${FORCE_GAMEMODE,,}" == "false" ]]; then
      sed -i "s/force-gamemode=.*/force-gamemode=${FORCE_GAMEMODE}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for FORCE_GAMEMODE!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #GAME_MODE - Added 1.6.1
  if [[ -n ${GAME_MODE} ]]; then
    if [[ "${GAME_MODE,,}" == "survival" ]] || [[ "${GAME_MODE,,}" == "creative" ]] || [[ "${GAME_MODE,,}" == "adventure" ]]; then
      sed -i "s/gamemode=.*/gamemode=${GAME_MODE}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for GAME_MODE!"
      echo "Options are: 'survival', 'creative', or 'adventure'"
      exit 1
    fi
  fi
  #LEVEL_NAME - Added 1.6.1
  if [[ -n ${LEVEL_NAME} ]]; then
    sed -i "s/level-name=.*/level-name=${LEVEL_NAME}/" "${SERVER_PROPERTIES}"
    #TODO: Add logic to check for legal file names
  fi
  #LEVEL_SEED - Added 1.6.1
  if [[ -n ${LEVEL_SEED} ]] || [ -f "${DATA_PATH}/seed.txt" ]; then
    #If seed.txt exists, use its value instead of ENV
    if [ -f "${DATA_PATH}/seed.txt" ]; then
      echo "Using seed from existing world's seed.txt file!"
      LEVEL_SEED=$(cat "${DATA_PATH}/seed.txt")
    #If ENV is random then choose one from list
    elif [[ "${LEVEL_SEED,,}" == "random" ]]; then
      echo "Choosing random seed from integrated seeds list."
      LEVEL_SEED=$(sort "${SEEDS_FILE}" -uR | head -n 1)
    fi
    echo "${LEVEL_SEED}" > "${DATA_PATH}/seed.txt"
    sed -i "s/level-seed=.*/level-seed=${LEVEL_SEED}/" "${SERVER_PROPERTIES}"
  fi
  #LEVEL_TYPE
  if [[ -n ${LEVEL_TYPE} ]]; then
    if [[ "${LEVEL_TYPE,,}" == "default" ]] || [[ "${LEVEL_TYPE,,}" == "flat" ]] || [[ "${LEVEL_TYPE,,}" == "legacy" ]]; then
      sed -i "s/level-type=.*/level-type=${LEVEL_TYPE^^}/" "${SERVER_PROPERTIES}"
      #level-type missing from recent downloads, insert if env var exists
      # shellcheck disable=SC2126
      if [[ $(grep "level-type" "${SERVER_PROPERTIES}" | wc -l) -eq 0 ]]; then
        echo "" >> "${SERVER_PROPERTIES}"
        # shellcheck disable=SC2086
        echo "level-type="${LEVEL_TYPE^^} >> "${SERVER_PROPERTIES}"
      fi
    else
      echo "ERROR: Invalid option for LEVEL_TYPE!"
      echo "Options are: 'default', 'flat', or 'legacy'"
      exit 1
    fi
  fi
  #MAX_PLAYERS - Added 1.6.1
  if [[ -n ${MAX_PLAYERS} ]]; then
    if [[ "${MAX_PLAYERS}" =~ ^[0-9]+$ ]]; then
      sed -i "s/max-players=.*/max-players=${MAX_PLAYERS}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: MAX_PLAYERS must be a number!"
      exit 1
    fi
  fi
  #MAX_THREADS - Added 1.6.1
  if [[ -n ${MAX_THREADS} ]]; then
    if [[ "${MAX_THREADS}" =~ ^[0-9]+$ ]]; then
      sed -i "s/max-threads=.*/max-threads=${MAX_THREADS}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: MAX_THREADS must be a positive number!"
      exit 1
    fi
  fi
  #ONLINE_MODE - Added 1.6.1
  if [[ -n ${ONLINE_MODE} ]]; then
    if [[ "${ONLINE_MODE,,}" == "false" ]] && [[ "${ALLOWLIST_ENABLE,,}" == "true" ]]; then
      echo "ERROR: ONLINE_MODE can't be 'false' when ALLOWLIST_ENABLE is 'true'!"
      exit 1
    elif [[ "${ONLINE_MODE,,}" == "true" ]] || [[ "${ONLINE_MODE,,}" == "false" ]]; then
      sed -i "s/online-mode=.*/online-mode=${ONLINE_MODE}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for ONLINE_MODE!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #PLAYER_IDLE_TIMEOUT - Added 1.6.1
  if [[ -n ${PLAYER_IDLE_TIMEOUT} ]]; then
    if [[ "${PLAYER_IDLE_TIMEOUT}" =~ ^[0-9]+$ ]]; then
      sed -i "s/player-idle-timeout=.*/player-idle-timeout=${PLAYER_IDLE_TIMEOUT}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: PLAYER_IDLE_TIMEOUT must be a positive number!"
      exit 1
    fi
  fi
  #PLAYER_MOVEMENT_ACTION_DIRECTION_THRESHOLD
  if [[ -n ${PLAYER_MOVEMENT_ACTION_DIRECTION_THRESHOLD} ]]; then
    sed -i "s/player-movement-action-direction-threshold=.*/player-movement-action-direction-threshold=${PLAYER_MOVEMENT_ACTION_DIRECTION_THRESHOLD}/" "${SERVER_PROPERTIES}"
  fi
  #PLAYER_POSITION_ACCEPTANCE_THRESHOLD
  if [[ -n ${PLAYER_POSITION_ACCEPTANCE_THRESHOLD} ]]; then
    sed -i "s/player-position-acceptance-threshold=.*/player-position-acceptance-threshold=${PLAYER_POSITION_ACCEPTANCE_THRESHOLD}/" "${SERVER_PROPERTIES}"
  fi
  #PLAYER_MOVEMENT_DISTANCE_THRESHOLD - Added 1.13.0
  if [[ -n ${PLAYER_MOVEMENT_DISTANCE_THRESHOLD} ]]; then
    sed -i "s/player-movement-distance-threshold=.*/player-movement-distance-threshold=${PLAYER_MOVEMENT_DISTANCE_THRESHOLD}/" "${SERVER_PROPERTIES}"
  fi
  #PLAYER_MOVEMENT_DURATION_THRESHOLD_IN_MS - Added 1.13.0
  if [[ -n ${PLAYER_MOVEMENT_DURATION_THRESHOLD_IN_MS} ]]; then
    if [[ "${PLAYER_MOVEMENT_DURATION_THRESHOLD_IN_MS}" =~ ^[0-9]+$ ]]; then
      sed -i "s/player-movement-duration-threshold-in-ms=.*/player-movement-duration-threshold-in-ms=${PLAYER_MOVEMENT_DURATION_THRESHOLD_IN_MS}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: PLAYER_MOVEMENT_DURATION_THRESHOLD_IN_MS must be a number!"
      exit 1
    fi
  fi
  #PLAYER_MOVEMENT_SCORE_THRESHOLD
  if [[ -n ${PLAYER_MOVEMENT_SCORE_THRESHOLD} ]]; then
    if [[ "${PLAYER_MOVEMENT_SCORE_THRESHOLD}" =~ ^[0-9]+$ ]]; then
      sed -i "s/player-movement-score-threshold=.*/player-movement-score-threshold=${PLAYER_MOVEMENT_SCORE_THRESHOLD}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: PLAYER_MOVEMENT_SCORE_THRESHOLD must be a number!"
      exit 1
    fi
  fi

  #SCRIPT_DEBUGGER_AUTO_ATTACH
  if [[ -n ${SCRIPT_DEBUGGER_AUTO_ATTACH} ]]; then
    if [[ "${SCRIPT_DEBUGGER_AUTO_ATTACH}" == "disabled" ]] || [[ "${SCRIPT_DEBUGGER_AUTO_ATTACH}" == "connect" ]] || [[ "${SCRIPT_DEBUGGER_AUTO_ATTACH}" == "listen" ]]; then
      sed -i "s/script-debugger-auto-attach=.*/script-debugger-auto-attach=${SCRIPT_DEBUGGER_AUTO_ATTACH}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for SCRIPT_DEBUGGER_AUTO_ATTACH!"
      echo "Options are: 'disabled', 'connect', or 'listen'"
      exit 1
    fi
  fi
  #SERVER_AUTHORITATIVE_BLOCK_BREAKING - Added 1.16.210
  if [[ -n ${SERVER_AUTHORITATIVE_BLOCK_BREAKING} ]]; then
    if [[ "${SERVER_AUTHORITATIVE_BLOCK_BREAKING,,}" == "true" ]] || [[ "${SERVER_AUTHORITATIVE_BLOCK_BREAKING,,}" == "false" ]]; then
      sed -i "s/server-authoritative-block-breaking=.*/server-authoritative-block-breaking=${SERVER_AUTHORITATIVE_BLOCK_BREAKING}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for SERVER_AUTHORITATIVE_BLOCK_BREAKING!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #SERVER_AUTHORITATIVE_MOVEMENT - Added 1.13.0
  if [[ -n ${SERVER_AUTHORITATIVE_MOVEMENT} ]]; then
    if [[ "${SERVER_AUTHORITATIVE_MOVEMENT,,}" == "client-auth" ]] || [[ "${SERVER_AUTHORITATIVE_MOVEMENT,,}" == "server-auth" ]] || [[ "${SERVER_AUTHORITATIVE_MOVEMENT,,}" == "server-auth-with-rewind" ]]; then
      sed -i "s/server-authoritative-movement=.*/server-authoritative-movement=${SERVER_AUTHORITATIVE_MOVEMENT}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for SERVER_AUTHORITATIVE_MOVEMENT!"
      echo "Options are: 'client-auth', 'server-auth', or 'server-auth-with-rewind'"
      exit 1
    fi
  fi
  #SERVER_NAME - Added 1.6.1
  if [[ -n ${SERVER_NAME} ]]; then
    sed -i "s/server-name=.*/server-name=${SERVER_NAME}/" "${SERVER_PROPERTIES}"
  fi
  #SERVER_PORT - Added 1.6.1
  if [[ -n ${SERVER_PORT} ]]; then
    if [[ "${SERVER_PORT}" -gt 0 ]] && [[ "${SERVER_PORT}" -lt 65536 ]]; then
      sed -i "s/server-port=.*/server-port=${SERVER_PORT}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: SERVER_PORT must be a number between 1-65535!"
      exit 1
    fi
  fi
  #SERVER_PORTV6 - Added 1.6.1
  if [[ -n ${SERVER_PORTV6} ]]; then
    if [[ "${SERVER_PORTV6}" -gt 0 ]] && [[ "${SERVER_PORTV6}" -lt 65536 ]]; then
      sed -i "s/server-portv6=.*/server-portv6=${SERVER_PORTV6}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: SERVER_PORTV6 must be a number between 1-65535!"
      exit 1
    fi
  fi
  #TEXTUREPACK_REQUIRED - Added 1.6.1
  if [[ -n ${TEXTUREPACK_REQUIRED} ]]; then
    if [[ "${TEXTUREPACK_REQUIRED,,}" == "true" ]] || [[ "${TEXTUREPACK_REQUIRED,,}" == "false" ]]; then
      sed -i "s/texturepack-required=.*/texturepack-required=${TEXTUREPACK_REQUIRED}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: Invalid option for TEXTUREPACK_REQUIRED!"
      echo "Options are: 'true' or 'false'"
      exit 1
    fi
  fi
  #TICK_DISTANCE - Added 1.6.1
  if [[ -n ${TICK_DISTANCE} ]]; then
    if [[ "${TICK_DISTANCE}" -gt 3 ]] && [[ "${TICK_DISTANCE}" -lt 13 ]]; then
      sed -i "s/tick-distance=.*/tick-distance=${TICK_DISTANCE}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: TICK_DISTANCE must be a number between 4 and 12!"
      exit 1
    fi
  fi
  #VIEW_DISTANCE - Added 1.6.1
  if [[ -n ${VIEW_DISTANCE} ]]; then
    if [[ "${VIEW_DISTANCE}" -gt 4 ]] && [[ "${VIEW_DISTANCE}" =~ ^[0-9]+$ ]]; then
      sed -i "s/view-distance=.*/view-distance=${VIEW_DISTANCE}/" "${SERVER_PROPERTIES}"
    else
      echo "ERROR: VIEW_DISTANCE must be a positive number greater than 4!"
      exit 1
    fi
  fi
}