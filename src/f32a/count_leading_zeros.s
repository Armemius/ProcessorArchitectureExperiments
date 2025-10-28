    .data

input_addr:      .word  0x80
output_addr:     .word  0x84
const_high_bit:  .word  0x80000000

    .text

input_subroutine:
    @p input_addr a! @
    ;

_start:
    input_subroutine
    dup
    if zero                  \ Edge case: input = 0 -> result = 32
    lit 0 a!                 \ A <- 0

loop:
    dup lit -1 xor           \ [a] -> [a, ~a]
    @p const_high_bit and    \ [a, ~a] -> [a, b = ~a & const_high_bit]
    if end                   \ [a, b] -> [a], if (b == 0) end
    lit 1 a + a!             \ A <- A + 1
    2*                       \ [a] -> [a = a << 2]
    loop ;

zero:
    lit 32 a!                \ [] -> [32]
end:
    a @p output_addr a! !
    drop
    halt



