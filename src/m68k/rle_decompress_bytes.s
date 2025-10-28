    .data
input_addr:      .word  0x80
output_addr:     .word  0x84
stack_top_pos:   .word  0x1000

    .text
    .org     0x100

_start:
    ; Setup stack pointer
    movea.l  stack_top_pos, A7               ; int* stack_top_pos
    movea.l  (A7), A7                        ; SP = *stack_top_pos

    ; Setup pointers
    movea.l  result_length, A6               ; A6 = result_length
    movea.l  result_bytes, A5                ; A5 = result_bytes

    ; Read input
    movea.l  input_addr, A0                  ; int** input_addr
    movea.l  (A0), A0                        ; int*  input_port = *input_addr
    move.l   (A0), D7                        ; int   bytes = *input_port

    ; D1 = bytes_left
    move.l   D7, D1
    cmp.l    0, D1
    ble      zero                            ; if (bytes_left == 0) zero()

    asr.l    1, D7                           ; int   cycles = bytes / 2

    ; // cycles = D7
    ; // data = D6
    ; // it = D5
    move.l   0, D5                           ; for (int it = 0; it < cycles; ++it) {
loop:
    cmp.l    D7, D5
    bge      output

    move.l   D5, D0
    and.l    1, D0
    cmp.l    0, D0
    bne      process
    movea.l  input_addr, A0
    movea.l  (A0), A0
    move.l   (A0), D6                        ;     if (it % 2 == 0) data = *input_port

    sub.l    2, D1
    cmp.l    1, D1                           ;     bytes_left -= 2
    beq      fail                            ;     if (bytes_left == 1) fail()

process:
    ; repeat_count = D4
    ; byte = D3
    move.l   D6, D4
    asr.l    16, D4
    move.b   D4, D3                          ; int byte = (data >> 16) & 0xFF
    asr.l    8, D4                           ; int repeat_count = data >> 24

    cmp.l    0, D4
    beq      fail

    add.l    D4, (A6)                        ; *result_length += repeat_count

    ; jt = D2
    move.l   0, D2
write_loop:
    cmp.l    D4, D2
    beq      write_loop_end
    move.b   D3, -(A5)
    add.l    1, D2
    jmp      write_loop


write_loop_end:
    asl.l    16, D6                          ; data = data << 16
    add.l    1, D5
    jmp      loop                            ; }

    ; it = D4
output:
    move.l   (A6), D4
    movea.l  output_addr, A1
    movea.l  (A1), A1
    move.l   D4, (A1)
    movea.l  result_bytes, A5

output_loop:
    cmp.l    0, D4                           ; while (it > 0) {
    ble      end
    move.l   -(A5), (A1)                     ;     *output_port = *(--result_bytes))
    sub.l    4, D4                           ;     it -= 4
    jmp      output_loop                     ; }

end:
    halt

    ; Subroutine to display zero bytes input
zero:
    movea.l  output_addr, A1
    movea.l  (A1), A1
    move.l   0, (A1)
    halt

    ; Subroutine to display failure
fail:
    movea.l  output_addr, A1
    movea.l  (A1), A1
    move.l   -1, (A1)
    halt

    ; Output results
    .data
.org             0x400
result_bytes:    .word  0
result_length:   .word  0
