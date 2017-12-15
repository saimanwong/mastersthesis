#!/bin/bash
DURATION=$1
IFACE=$2
PROTOCOL=$3

tcpdump -B 16110 -G $DURATION -W 1 -i $IFACE -w /tmp/tmp.pcap $PROTOCOL > /dev/null 2>&1
