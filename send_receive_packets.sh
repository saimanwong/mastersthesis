#!/bin/bash

# PACKET
ENV=$1 # host, vm
TG_NAME=$2 # ostinato, mausezahn, iperf
ITER=$3
FRAME_LEN=$4
CAP_DUR=$5
DATA_DIR=$6

# Host
# SERVER1=192.168.42.3
# SERVER1_PORT=22
# SERVER1_TX=enp0s25
#
# SERVER2=192.168.42.2
# SERVER2_PORT=22
# SERVER2_RX=enp0s25

# VM settings
SERVER1=localhost
SERVER1_PORT=2223
SERVER1_TX=enp0s8

SERVER2=localhost
SERVER2_PORT=2224
SERVER2_RX=enp0s8

mkdir -p ${DATA_DIR}

SERVER1_IP=$(ssh -p ${SERVER1_PORT} root@${SERVER1} /sbin/ifconfig ${SERVER1_TX} | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}')
SERVER1_MAC=$(ssh -p ${SERVER1_PORT} root@${SERVER1} /sbin/ifconfig ${SERVER1_TX} | grep 'HWaddr' | awk '{print $5}')

SERVER2_IP=$(ssh -p ${SERVER2_PORT} root@${SERVER2} /sbin/ifconfig ${SERVER2_RX} | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}')
SERVER2_MAC=$(ssh -p ${SERVER2_PORT} root@${SERVER2} /sbin/ifconfig ${SERVER2_RX} | grep 'HWaddr' | awk '{print $5}')

function tcpdump () {
    sleep 5
    echo "[TCPDUMP@SERVER2] CAPTURING"
    ssh -p ${SERVER2_PORT} root@${SERVER2} "docker run --rm \
        --name host-tcpdump \
        --privileged \
        --network host \
        -v /tmp:/tmp \
        saimanwong/tcpdump-capinfos \
        $CAP_DUR \
        $SERVER2_RX \
        udp"
    echo "[TCPDUMP@SERVER2] CAPTURE DONE"

    capinfos host
}

function capinfos () {
    echo "[CAPINFOS@SERVER1] ANALYZING CAPTURE"
    ssh -p ${SERVER2_PORT} root@${SERVER2} "docker run --rm \
        -v /tmp:/tmp \
        --entrypoint capinfos \
        saimanwong/tcpdump-capinfos \
        /tmp/tmp.pcap" | tee /dev/stderr | \
        grep "Data bit rate:" | \
        awk '{print $4,$5}' >> ${DATA_DIR}/${ENV}_${TG_NAME}_${FRAME_LEN}_${ITER}.dat 2>&1
    echo "[CAPINFOS@SERVER1] ANALYSIS DONE"
}

function ostinato () {
    echo "[OSTINATO DRONE@SERVER1] STARTING"
    ssh -p $SERVER1_PORT root@${SERVER1} "docker run --rm -d \
        --name host-drone \
        --privileged \
        --network host \
        saimanwong/ostinato-drone" > /dev/null 2>&1
    echo "[OSTINATO DRONE@SERVER1] RUNNING"

    sleep 10

    echo "[OSTINATO PYTHON-API@SERVER1] STARTING"
    ssh -p $SERVER1_PORT root@${SERVER1} "docker run --rm -d \
        --name host-python \
        --network host \
        saimanwong/ostinato-python-api \
        $SERVER1 \
        $SERVER1_TX \
        $SERVER1_MAC \
        $SERVER2_MAC \
        $SERVER1_IP \
        $SERVER2_IP \
        $FRAME_LEN \
        1000000 \
        10 \
        50000" > /dev/null 2>&1
    echo "[OSTINATO PYTHON-API@SERVER1] RUNNING"

    tcpdump

    # CLEANUP
    echo CLEAN UP STARTED
    ssh -p ${SERVER1_PORT} root@${SERVER1} "docker rm -f host-drone host-python"
    echo CLEAN UP DONE
}
function mausezahn {
    echo "[MAUSEZAHN@SERVER1] STARTING"
    ssh -p $SERVER1_PORT root@${SERVER1} "docker run --rm -d \
        --name host-mausezahn \
        --privileged \
        --network host \
        saimanwong/mausezahn \
        $SERVER1_TX \
        0 \
        $FRAME_LEN \
        $SERVER1_MAC \
        $SERVER2_MAC \
        $SERVER1_IP \
        $SERVER2_IP \
        udp" > /dev/null 2>&1
    echo "[MAUSEZAHN@SERVER1] RUNNING"

    tcpdump

    # CLEANUP
    echo CLEAN UP STARTED
    ssh -p ${SERVER1_PORT} root@${SERVER1} "docker rm -f host-mausezahn"
    echo CLEAN UP DONE
}

function iperf () {
    echo "[IPERF@SERVER1] STARTING"
    ssh -p $SERVER1_PORT root@${SERVER1} "docker run --rm -d \
        --name host-iperf \
        --privileged \
        --network host \
        saimanwong/iperf \
        $FRAME_LEN \
        10000 \
        1 \
        $SERVER1_IP \
        $SERVER2_IP" > /dev/null 2>&1
    echo "[IPERF@SERVER1] RUNNING"

    tcpdump

    # CLEANUP
    echo CLEAN UP STARTED
    ssh -p ${SERVER1_PORT} root@${SERVER1} "docker rm -f host-iperf"
    echo CLEAN UP DONE
}

COUNTER=0
while [ $COUNTER -lt $ITER ]; do
    ${TG_NAME}
    let COUNTER=COUNTER+1
    sleep 5
done
