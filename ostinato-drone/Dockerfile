# docker build -t saimanwong/ostinato-drone .
# docker run --rm -d \
#   --name host-drone \
#   --privileged \
#   --network host \
#   saimanwong/ostinato-drone

FROM ubuntu:xenial
LABEL maintainer "Sai Man Wong <smwong@kth.se>"

WORKDIR /

# Change software repository according to your geographical location
# COPY china.sources.list /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    gdebi-core \
    wget && \
    wget http://security.ubuntu.com/ubuntu/pool/main/p/protobuf/libprotobuf10_3.0.0-9ubuntu2_amd64.deb && \
    wget http://cz.archive.ubuntu.com/ubuntu/pool/universe/o/ostinato/ostinato_0.8-1build1_amd64.deb && \
    echo y | gdebi libprotobuf10_3.0.0-9ubuntu2_amd64.deb && \
    echo y | gdebi ostinato_0.8-1build1_amd64.deb && \
    apt-get purge -y wget gdebi-core && \
    rm -rf /var/lib/apt/lists/* \
    libprotobuf10_3.0.0-9ubuntu2_amd64.deb \
    ostinato_0.8-1build1_amd64.deb

ENTRYPOINT [ "drone" ]
