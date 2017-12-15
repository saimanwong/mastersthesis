# docker build -t saimanwong/iperf .
# docker run --rm -d \
#   --name host-iperf \
#   --privileged \
#   --network host \
#   saimanwong/iperf \
#   <PACKET_SIZE> \
#   <BANDWIDTH_IN_MBPS> \
#   <THREADS> \
#   <SRC_IP> \
#   <DST_IP>

FROM ubuntu:xenial
LABEL maintainer "Sai Man Wong <smwong@kth.se>"

WORKDIR /

# Change software repository according to your geographical location
# COPY china.sources.list /etc/apt/sources.list

COPY docker-entrypoint.sh /

RUN apt-get update && apt-get install -y \
    wget --no-install-recommends && \
    wget --no-check-certificate -O /usr/bin/iperf https://iperf.fr/download/ubuntu/iperf_2.0.9 && \
    chmod +x /usr/bin/iperf && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["./docker-entrypoint.sh"]
