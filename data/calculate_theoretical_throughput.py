import sys

link_speed = float(sys.argv[1]) # In Mbit
packet_size = float(sys.argv[2]) # In Bytes

PREAMBLE = 7.0
START_OF_FRAME_DELIMITER = 1.0
INTERFRAME_GAP = 12.0

packet_and_overhead = packet_size + PREAMBLE + START_OF_FRAME_DELIMITER + INTERFRAME_GAP
packets_per_sec = float( (link_speed) / (packet_and_overhead*8) )

print(sys.argv[2] + " " + str(round(packets_per_sec*packet_size*8,2)) + " 0")
