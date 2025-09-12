import net, os, strutils, times
import crypto/speck
import crypto/lfsr64

type EncSocket = object
    socket: Socket,
    host: string,
    port: int,
    key: array[2, uint64]

let EPOCH = getTime().toUnix()
var IVGEN = LFSR64(EPOCH)

# Packet structure
# [length (2 bytes)] || [IV (4 bytes)] || [data]
proc send(self:EncSocket, data:array[256,uint8]) =
    var packet: array[280,uint8]
    packet[0] = data.len shr 8
    packet[1] = data.len and 0xFF
    
    let IV: uint64 = IVGEN.next
    var crypt = speck_ctr(self.key, IV)
    # encode key in packet
    for i in 0..<4:
        packet[2 + i] = IV shr (i shl 3)
    var data_index = 0
    for c in crypt:
        if data_index == data.len:
            break
        packet[6 + data_index] = data[data_index] xor c
        data_index += 1
    self.socket.send(packet)
    

proc recv(self:EncSocket):  =

