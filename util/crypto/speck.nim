
func ROR(x: uint64, r: uint64): uint64 =
    return ((x shr r) or (x shl (64 - r)))
func ROL(x: uint64, r: uint64): uint64 =
    return ((x shl r) or (x shr (64 - r)))
let ROUNDS = 32

proc speck_encrypt(pt: array[2, uint64], K: array[2, uint64]): array[2, uint64] =
    var y: uint64 = uint64(pt[0])
    var x: uint64 = uint64(pt[1])
    var a: uint64 = uint64(K[0])
    var b: uint64 = uint64(K[1])

    x = (ROR(x, 8) + y) xor b
    y = ROL(y, 3) xor x
    for i in 0..<ROUNDS:
        a = (ROR(a, 8) + b) xor uint64(i)
        b = ROL(b, 3) xor uint64(a)
        x = (ROR(x, 8) + y) xor b
        y = ROL(y, 3) xor x
    let res: array[2, uint64] = [y, x]
    return res

iterator speck_ctr(key: array[2, uint64], iv: uint64): uint8 =
    var block_iteration = speck_encrypt([iv, 0], key)
    var i: uint64 = 1
    while true:
        block_iteration = speck_encrypt([iv, i], key)
        for j in 0..<4:
            yield uint8((block_iteration[0] shr (8*(3-j))) and 255)
        for j in 0..<4:
            yield uint8((block_iteration[1] shr (8*(3-j))) and 255)
        i+=1

export speck_ctr