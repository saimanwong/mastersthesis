#!/bin/bash
FRAME_LEN=$(($1-42))
BW=$2
THREADS=$3
SRC_IP=$4
DST_IP=$5

iperf -l $FRAME_LEN \
    -B $SRC_IP \
    -c $DST_IP \
    -t 1000 \
    -b ${BW}m \
    -P $THREADS \
    -u
