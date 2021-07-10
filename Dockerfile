
FROM debian:10-slim

ARG VERSION
ENV VERSION=$VERSION \
    ZIP_FILE="bedrock-server-${VERSION}.zip" \
    CWRX_HOME="/cubeworx" \
    DATA_PATH="/cubeworx/data" \
    SERVER_NAME="CubeWorx" \
    SERVER_PATH="/cubeworx/server" \
    SERVER_PORT=19132

RUN apt-get update && \
    apt-get -y install jq libcurl4 unzip zip && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p $DATA_PATH $SERVER_PATH

WORKDIR $CWRX_HOME

ADD $ZIP_FILE /
ADD entrypoint.sh /
ADD seeds.txt $CWRX_HOME/

EXPOSE $SERVER_PORT/udp
VOLUME $DATA_PATH

ENTRYPOINT ["/entrypoint.sh"]