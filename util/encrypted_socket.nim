import net, os, strutils, times
from crypto/speck import speck_ctr
from crypto/lfsr64 import LFSR64, generate, setSeed

let EPOCH = getTime().toUnix().uint64
var IVGEN = LFSR64()
IVGEN.setSeed(EPOCH)

type EncSocket = object
    socket: Socket
    host: string
    port: int
    key: array[2, uint64]

proc newEncSocket(host: string, port:int, key: array[2, uint64]): EncSocket =
    var socket = newSocket()
    var res = EncSocket(socket: socket, host: host, port: port, key: key)
    return res

proc connect(self:var EncSocket) =
    self.socket.connect(self.host, Port(self.port))

proc listen(self:var EncSocket): EncSocket =
    socket.bindAddr(Port(self.port))
    socket.listen()
    var client: Socket
    var address = ""
    socket.acceptAddr(client, address)
    return EncSocket(socket: client, host:self.host, port:self.port, key:self.key)

# Packet structure
# [length (2 bytes)] || [IV (8 bytes)] || [data (length bytes)]
proc send(self:EncSocket, data:seq[uint8]) =
    var packet: array[1024,uint8]
    packet[0] = (data.len shr 8).uint8
    packet[1] = (data.len and 0xFF).uint8
    
    let IV: uint64 = IVGEN.generate()
    # encode IV in packet
    for i in 0..<8:
        packet[2 + i] = ((IV shr (56 - i*8)) and 0xFF).uint8
    var data_index = 0
    for c in speck_ctr(self.key, IV):
        if data_index == data.len:
            break
        packet[10 + data_index] = data[data_index] xor c
        data_index += 1
    var packetString = newString(packet.len)
    copyMem(packetString[0].addr, packet[0].unsafeAddr, data.len + 10)
    self.socket.send(packetString)

proc recv(self:EncSocket): seq[uint8] =
    var sizeBuffer: string = ""
    var ivBuffer: string = ""
    var dataBuffer: string = ""
    var yolo: int
    
    yolo = self.socket.recv(sizeBuffer, 2)
    var size: int = int((sizeBuffer[0].int shl 8) or sizeBuffer[1].int)
    yolo = self.socket.recv(ivBuffer, 8)
    var iv: uint64 = 0
    for i in 0..<8:
        iv = (iv shl 8.uint64) or uint64(ivBuffer[i])
    yolo = self.socket.recv(dataBuffer, size)

    var res: seq[uint8] = @[]
    var data_index: int = 0
    for c in speck_ctr(self.key, iv):
        if data_index == size:
            break
        res.add(c xor uint8(dataBuffer[data_index]))
        data_index += 1
    return res



#let key: array[2, uint64] = [uint64(0xdeadbeef13371337), uint64(0xdeadbeef33013301)]
#let msg: seq[uint8] = @[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255]
#var lol = newEncSocket("127.0.0.1", 7777, key)
#lol.connect()

#lol.send(msg)

#var answer: seq[uint8] = lol.recv()
#echo answer

#let msg2: seq[uint8] = @[0x41, 0x41, 0x42, 0x42]
#lol.send(msg2)

#answer = lol.recv()
#echo answer

