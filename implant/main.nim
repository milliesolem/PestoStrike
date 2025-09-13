

import net, os, strutils
import job
import encrypted_socket

let PARENT_HOST: string = "127.0.0.1"
let PARENT_PORT: int = 3301
let DEBUG: bool = true

let SOCKET_KEY: array[2, uint64] = [0xdeadbeef13371337, 0xdeadbeef33013301]


let client: EncSocket = EncSocket(
    host: PARENT_HOST,
    port: PARENT_PORT,
    key: SOCKET_KEY
)


type DebugLevel = enum
    INFO = 0
    SUCCESS = 1
    WARNING = 2
    ERROR = 3

proc debug(message: string, level: DebugLevel) = 
    let prefixes = ["i", "*", "!", "x"]
    if DEBUG:
        echo "[ ", prefixes[level], " ] ", message


# serialized job data structure:
# [total data length 2 bytes] || [job type 1 byte] || [job id 36 bytes]
# [first exec 4 bytes] || [repeat 1 byte] || [interval exec time 2 bytes]
# [report back bool 1 byte] || [report back port 2 bytes] || [data remaining bytes]
# header is 49 bytes
proc main() = 
    # send request to parent node
    debug("Calling parent host...", DebugLevel.INFO)
    var socket: EncSocket = EncSocket()
    # command loop
    debug("Command loop initiated!", DebugLevel.INFO)
    while true:
        echo "lol"





