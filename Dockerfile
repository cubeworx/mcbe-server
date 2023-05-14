FROM debian:10-slim

ARG BUILD_DATE

LABEL cbwx.announce.enable="true"
LABEL cbwx.announce.type="mcbe"
LABEL manymine.enable="true"
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
    curl -sL https://github.com/itzg/mc-monitor/releases/download/0.11.2/mc-monitor_0.11.2_linux_amd64.tar.gz -o mc-monitor.tar.gz && \
    mkdir /itzg-mc-monitor && \
    tar -xzvf mc-monitor.tar.gz --directory=/itzg-mc-monitor && \
    rm -rf mc-monitor.tar.gz && \
    chmod +x /itzg-mc-monitor/mc-monitor && \
    mkdir -p $DATA_PATH

WORKDIR $MCBE_HOME

ADD entrypoint.sh /
ADD scripts/ $MCBE_HOME/scripts/
ADD seeds.txt $MCBE_HOME/
ADD versions.txt $MCBE_HOME/

EXPOSE $SERVER_PORT/udp
EXPOSE $SERVER_PORTV6/udp
VOLUME $DATA_PATH

HEALTHCHECK --start-period=1m CMD /itzg-mc-monitor/mc-monitor status-bedrock --host 127.0.0.1 --port $SERVER_PORT

ENTRYPOINT ["/entrypoint.sh"]