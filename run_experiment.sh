#!/bin/bash

# ./send_receive_packets.sh
#   <ENV | host, vm> \
#   <TG_NAME | ostinato, mausezahn, iperf> \
#   <ITERATION> \
#   <FRAME_LEN> \
#   <CAPTURE DURATION> \
#   <LOG_DIR>

packet_size=(64 128 256 512 768 1024 1280 1408 1664 2048 3072 4096)

for i in "${packet_size[@]}"
do
    echo ./send_receive_packets.sh host ostinato 100 $i 10 ./data/data_host
    ./send_receive_packets.sh host ostinato 100 $i 10 ./data/data_host
    echo ./send_receive_packets.sh host mausezahn 100 $i 10 ./data/data_host
    ./send_receive_packets.sh host mausezahn 100 $i 10 ./data/data_host
    echo ./send_receive_packets.sh host iperf 100 $i 10 ./data/data_host
    ./send_receive_packets.sh host iperf 100 $i 10 ./data/data_host
done
