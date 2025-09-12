

import net, os, strutils
import job


let PARENT_HOST: string = "127.0.0.1"
let PARENT_PORT: int = 3301
let DEBUG: bool = true

let SOCKET_KEY: array[2, uint64] = [0xdeadbeef13371337, 0xdeadbeef33013301]


let client: Socket = newSocket()


type DebugLevel = enum
    INFO = 0
    SUCCESS = 1
    WARNING = 2
    ERROR = 3

proc debug(message: string, level: DebugLevel) = 
    let prefixes = ["i", "*", "!", "x"]
    if DEBUG:
        echo "[ ", prefixes[level], " ] ", message


proc main() = 
    echo "lol"
    # send request to parent node
    debug("Calling parent host...", DebugLevel.INFO)

    # command loop
    debug("Command loop initiated!", DebugLevel.INFO)
    while true:
        echo "lol"





