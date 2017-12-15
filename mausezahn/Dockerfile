# docker build -t saimanwong/mausezahn .
# docker run --rm -d \
#   --name host-mausezahn \
#   --privileged \
#   --network host \
#   saimanwong/mausezahn \
#   <SRC_INTERFACE> \
#   0 \
#   <PACKET_SIZE> \
#   <SRC_MAC> \
#   <DST_MAC> \
#   <SRC_IP> \
#   <DST_IP> \
#   udp

FROM ubuntu:xenial
LABEL maintainer "Sai Man Wong <smwong@kth.se>"

WORKDIR /

# Change software repository according to your geographical location
# COPY china.sources.list /etc/apt/sources.list

COPY docker-entrypoint.sh /mausezahn/docker-entrypoint.sh


RUN apt-get update && apt-get install -y git && \
    apt-get install -y --no-install-recommends \
    gcc ccache flex bison libnl-3-dev \
    libnl-genl-3-dev libnl-route-3-dev libgeoip-dev \
    libnetfilter-conntrack-dev libncurses5-dev liburcu-dev \
    libnacl-dev libpcap-dev zlib1g-dev libcli-dev libnet1-dev && \
    git clone https://github.com/netsniff-ng/netsniff-ng && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /netsniff-ng
RUN ./configure && make mausezahn && mv mausezahn/* /mausezahn

WORKDIR /mausezahn
RUN rm -rf /netsniff-ng && chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
