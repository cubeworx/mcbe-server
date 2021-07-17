FROM debian:10-slim

ARG BUILD_DATE

LABEL cbwx.mcbe-announce.enable=true
LABEL manymine.enable=true
LABEL org.opencontainers.image.authors="Cory Claflin"
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.licenses='MIT'
LABEL org.opencontainers.image.source='https://github.com/cubeworx/mcbe-server'
LABEL org.opencontainers.image.title="CubeWorx Minecraft Bedrock Edition Server Image"
LABEL org.opencontainers.image.vendor='CubeWorx'

ENV MCBE_HOME="/mcbe" \
    DATA_PATH="/mcbe/data" \
    LEVEL_NAME="Bedrock-Level" \
    SERVER_NAME="CubeWorx-MCBE" \
    SERVER_PORT=19132 \
    SERVER_PORTV6=19133 \
    TZ="UTC" \
    VERSION="LATEST"

RUN apt-get update && \
    apt-get -y install curl jq libcurl4 unzip zip && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p $DATA_PATH

WORKDIR $MCBE_HOME

ADD entrypoint.sh /
ADD seeds.txt $MCBE_HOME/
ADD versions.txt $MCBE_HOME/

EXPOSE $SERVER_PORT/udp
EXPOSE $SERVER_PORTV6/udp
VOLUME $DATA_PATH

ENTRYPOINT ["/entrypoint.sh"]