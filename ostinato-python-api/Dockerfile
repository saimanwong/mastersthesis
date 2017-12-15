# docker build -t saimanwong/ostinato-python-api .
# docker run --rm -d \
#   --name host-python \
#   --network host \
#   saimanwong/ostinato-python-api \
#   <DRONE_IP> \
#   <SRC_INTERFACE> \
#   <SRC_MAC> \
#   <DST_MAC> \
#   <SRC_IP> \
#   <DST_IP> \
#   <PACKET_SIZE> \
#   <NUM_BURST> \
#   <PACKET_PER_BURST> \
#   <BURST_PER_SECOND>

FROM ubuntu:xenial
LABEL maintainer "Sai Man Wong <smwong@kth.se>"

WORKDIR /

# Change software repository according to your geographical location
# COPY china.sources.list /etc/apt/sources.list

COPY docker-entrypoint.py /

RUN apt-get update && apt-get install -y --no-install-recommends \
    python \
    python-pip \
    wget && \
    pip install --upgrade pip && \
    pip install setuptools && \
    wget https://pypi.python.org/packages/fb/e3/72a1f19cd8b6d8cf77233a59ed434d0881b35e34bc074458291f2ddfe305/python-ostinato-0.8.tar.gz && \
    pip install python-ostinato-0.8.tar.gz && \
    apt-get purge -y python-pip && \
    rm -rf /var/lib/apt/lists/* \
    python-ostinato-0.8.tar.gz

ENTRYPOINT ["./docker-entrypoint.py"]
