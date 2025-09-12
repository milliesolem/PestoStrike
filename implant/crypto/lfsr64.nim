
# this bad boy has a hella long period and is very cheap
iterator LFSR64(seed: uint64): uint64 =
    while true:
        var next: uint64 = 0
        for _ in 0..<8:
            next = (next shl 8) or (seed and 0xFF)
            seed = (seed shr 8) or ((seed shr 7 and 0xff) xor (seed shr 13 and 0xff) xor (seed shr 50 and 0xff))
        yield next
