
FROM debian:10-slim

ARG VERSION
ENV VERSION=$VERSION \
    ZIP_FILE="bedrock-server-${VERSION}.zip" \
    MCBE_HOME="/mcbe" \
    DATA_PATH="/mcbe/data" \
    LEVEL_NAME="Bedrock-Level" \
    SERVER_NAME="CubeWorx-MCBE" \
    SERVER_PATH="/mcbe/server" \
    SERVER_PORT=19132 \
    SERVER_PORTV6=19133

RUN apt-get update && \
    apt-get -y install jq libcurl4 unzip zip && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p $DATA_PATH $SERVER_PATH

WORKDIR $MCBE_HOME

ADD $ZIP_FILE /
ADD entrypoint.sh /
ADD seeds.txt $MCBE_HOME/

EXPOSE $SERVER_PORT/udp
EXPOSE $SERVER_PORTV6/udp
VOLUME $DATA_PATH

ENTRYPOINT ["/entrypoint.sh"]