#!/bin/bash
IFACE=$1
COUNT=$2
FRAME_LEN=$(($3-42))
SRC_MAC=$4
DST_MAC=$5
SRC_IP=$6
DST_IP=$7
PROTOCOL=$8

./mausezahn $IFACE \
    -c $COUNT \
    -p $FRAME_LEN \
    -a $SRC_MAC \
    -b $DST_MAC \
    -A $SRC_IP \
    -B $DST_IP \
    -t $PROTOCOL
