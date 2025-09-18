

def lfsr64(seed):
    while True:
        next = 0
        for _ in range(8):
            next = (next << 8) | (seed & 0xFF)
            seed = (seed << 8) | ((seed >> 7 & 0xff) ^ (seed >> 13 & 0xff) ^ (seed >> 50 & 0xff))
        yield next



