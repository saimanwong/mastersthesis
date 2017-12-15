#! /usr/bin/env python

import os
import time
import sys
import json
import binascii
import socket
import signal
from pprint import pprint


from ostinato.core import ost_pb, DroneProxy
from ostinato.protocols.mac_pb2 import mac
from ostinato.protocols.ip4_pb2 import ip4, Ip4
from ostinato.protocols.udp_pb2 import udp

print(sys.argv)
host_name = sys.argv[1]
iface = sys.argv[2]
mac_src = "0x" + sys.argv[3].replace(":", "")
mac_dst = "0x" + sys.argv[4].replace(":", "")
ip_src = "0x" + binascii.hexlify(socket.inet_aton(sys.argv[5])).upper()
ip_dst = "0x" + binascii.hexlify(socket.inet_aton(sys.argv[6])).upper()
frame_len = int(sys.argv[7])
num_bursts = int(sys.argv[8])
packets_per_burst = int(sys.argv[9])
bursts_per_sec = int(sys.argv[10])

def setup_stream(id):
    stream_id = ost_pb.StreamIdList()
    stream_id.port_id.CopyFrom(tx_port.port_id[0])
    stream_id.stream_id.add().id = 1
    drone.addStream(stream_id)
    return stream_id

def stream_config():
    stream_cfg = ost_pb.StreamConfigList()
    stream_cfg.port_id.CopyFrom(tx_port.port_id[0])
    return stream_cfg

def stream(stream_cfg):
    s = stream_cfg.stream.add()
    s.stream_id.id = 1
    s.core.is_enabled = True
    s.control.unit = 1
    s.control.num_bursts = num_bursts
    s.control.packets_per_burst = packets_per_burst
    s.control.bursts_per_sec = bursts_per_sec

    s.core.frame_len = frame_len + 4
    return s

drone = DroneProxy(host_name)
drone.connect()

port_id_list = drone.getPortIdList()
port_config_list = drone.getPortConfig(port_id_list)

print('Port List')
print('---------')
for port in port_config_list.port:
    print('%d.%s (%s)' % (port.port_id.id, port.name, port.description))
    if iface == port.name:
        print("IFACE: " + iface)
        iface = port.port_id.id

tx_port = ost_pb.PortIdList()
tx_port.port_id.add().id = int(iface)

stream_id = setup_stream(1)
stream_cfg = stream_config()
s = stream(stream_cfg)

p = s.protocol.add()
p.protocol_id.id = ost_pb.Protocol.kMacFieldNumber
p.Extensions[mac].src_mac = int(mac_src, 16)
p.Extensions[mac].dst_mac = int(mac_dst, 16)
p = s.protocol.add()
p.protocol_id.id = ost_pb.Protocol.kEth2FieldNumber

p = s.protocol.add()
p.protocol_id.id = ost_pb.Protocol.kIp4FieldNumber
ip = p.Extensions[ip4]
ip.src_ip = int(ip_src, 16)
ip.dst_ip = int(ip_dst, 16)

p = s.protocol.add()
p.protocol_id.id = ost_pb.Protocol.kUdpFieldNumber

s.protocol.add().protocol_id.id = ost_pb.Protocol.kPayloadFieldNumber

drone.modifyStream(stream_cfg)

drone.clearStats(tx_port)

drone.startTransmit(tx_port)

# wait for transmit to finish
try:
    time.sleep(1000)
except KeyboardInterrupt:
    drone.stopTransmit(tx_port)
    drone.stopCapture(tx_port)

    stats = drone.getStats(tx_port)

    print(stats)

    drone.deleteStream(stream_id)
    drone.disconnect()
