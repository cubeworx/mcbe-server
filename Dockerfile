
FROM debian:10-slim

ARG VERSION
ENV VERSION=$VERSION \
    ZIP_FILE="bedrock-server-${VERSION}.zip" \
    MCBE_HOME="/mcbe" \
    DATA_PATH="/mcbe/data" \
    SERVER_NAME="CubeWorx" \
    SERVER_PATH="/mcbe/server" \
    SERVER_PORT=19132

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
VOLUME $DATA_PATH

ENTRYPOINT ["/entrypoint.sh"]