import std/sysrand
import strutils


proc uuid4(): string =
    let bytes: seq[byte] = urandom(16)
    var hex = ""
    for b in bytes:
        hex.add(toHex(b))
    let uuid: string = (hex[0..7]) & '-' & (hex[8..11]) & "-4" & (hex[14..16]) & '-' & (hex[17..20]) & '-' & (hex[21..31])
    return uuid

export uuid4




