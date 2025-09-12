ROR = lambda x,r: ((x >> r) | (x << (64 - r)))%(2**64)
ROL = lambda x,r: ((x << r) | (x >> (64 - r)))%(2**64)
ROUNDS = 32

def speck_encrypt(pt, K):
    y,x = pt
    a,b = K

    x = (ROR(x, 8) + y) ^ b
    y = ROL(y, 3) ^ x
    for i in range(ROUNDS):
        print(a,b,x,y)
        a = ((ROR(a, 8) + b) ^ i)%(2**64)
        b = (ROL(b, 3) ^ a)%(2**64)
        x = ((ROR(x, 8) + y) ^ b)%(2**64)
        y = (ROL(y, 3) ^ x)%(2**64)
    return y%(2**64),x%(2**64)

def speck_ctr(key, iv):
    block_iteration = speck_encrypt([iv, 0], key)
    i = 1
    while True:
        block_iteration = speck_encrypt([iv, i], key)
        print(block_iteration)
        for j in range(4):
            yield (block_iteration[0]>>(8*(3-j)))&255
        for j in range(4):
            yield (block_iteration[1]>>(8*(3-j)))&255
        i += 1


