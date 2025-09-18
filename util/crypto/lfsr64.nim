# this bad boy has a hella long period and is very cheap

#iterator LFSR64_iterator(seed: uint64): uint64 =
#    while true:
#        var next: uint64 = 0
#        var internal_state = seed
#        for _ in 0..<8:
#            next = (next shl 8) or (internal_state and 0xFF)
#            internal_state = (internal_state shl 8) or ((internal_state shr 7 and 0xff) xor (internal_state shr 13 and 0xff) xor (internal_state shr 50 and 0xff))
#        yield next

# nim doesn't allow me to store an iterator instance so i gotta do it the
# object orientated way :((
type LFSR64 = object
    seed: uint64

proc setSeed(self: var LFSR64, seed: uint64) =
    self.seed = seed

proc generate(self: var LFSR64): uint64 =
    var next: uint64 = 0
    var internal_state: uint64 = self.seed
    for _ in 0..<8:
        next = (next shl 8) or (internal_state and 0xFF)
        internal_state = (internal_state shl 8) or ((internal_state shr 7 and 0xff) xor (internal_state shr 13 and 0xff) xor (internal_state shr 50 and 0xff))
    self.seed = internal_state
    return next

export LFSR64, generate, setSeed