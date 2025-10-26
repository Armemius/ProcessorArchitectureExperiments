    .data

buf:             .byte  '________________________________'
zone:            .word  0
buf_size:        .word  32

message:         .byte  'What is your name?\n\0'
message_size:    .word  19

greeting:        .byte  'Hello, \0'
greeting_size:   .word  7

i:               .word  0
j:               .word  0
ptr:             .word  0
ptr2:            .word  0
input_addr:      .word  0x80
output_addr:     .word  0x84

const_1:         .word  1
const_FF:        .word  0x000000FF
const_endline:   .word  0x5f5f5f0a         ; '\n___'
const_mask:      .word  0x5f5f5f00         ; '\0___'
const_ex_mark:   .word  0x5f5f5f21         ; '!___'
const_FFFFFF00:  .word  0xFFFFFF00
const_failure:   .word  0xCCCCCCCC

    .text
    .org         0x120
_start:
    load_imm     message
    store        ptr                         ; ptr <- message

    load         message_size
    store        i                           ; i <- *message_size

loop:
    beqz         loop_end                    ; while (i != 0) {

    load         ptr
    load_acc
    and          const_FF
    store_ind    output_addr                 ;     *output_addr <- *ptr & const_FF

    load         ptr
    add          const_1
    store        ptr                         ;     ptr <- ptr + const_1

    load         i
    sub          const_1
    store        i                           ;     i <- i - const_1

    jmp          loop                        ; }


loop_end:

    load_imm     buf
    add          const_1
    store        ptr                         ; ptr <- buf + 1

    load         const_1
    store        i                           ; i <- const_1

    load_imm     greeting
    store        ptr2                        ; ptr2 <- greeting

    load         greeting_size
    store        j                           ; j <- greeting_sizexrRw

read_pstr_prefix:
    beqz         read_pstr

    load         ptr2
    load_acc
    and          const_FF
    or           const_mask
    store_ind    ptr                         ;     *ptr <- *ptr2 & const_FF | const_mask

    load         ptr
    add          const_1
    store        ptr                         ;     ptr <- ptr + const_1

    load         ptr2
    add          const_1
    store        ptr2                        ;     ptr2 <- ptr2 + const_1

    load         i
    add          const_1
    store        i                           ;     i <- i + const_1

    load         j
    sub          const_1
    store        j                           ;     j <- j - const_1

    jmp          read_pstr_prefix            ; }


read_pstr:

    load         input_addr                  ; while(true) {
    load_acc
    and          const_FF
    or           const_mask
    store_ind    ptr                         ;     *ptr <- *input_addr & const_FF | const_mask

    sub          const_endline
    beqz         read_pstr_end               ;     if (*ptr == '\n') break

    load         i
    add          const_1
    store        i                           ;     i <- i + const_1

    add          const_1
    sub          buf_size
    beqz         fail                        ;     if (i - 1 == buf_size) fail

    load         ptr
    add          const_1
    store        ptr                         ;     ptr <- ptr + const_1

    jmp          read_pstr                   ; }

read_pstr_end:

    load         const_ex_mark
    store_ind    ptr                         ; *ptr <- const_ex_mark

    load         buf
    and          const_FFFFFF00
    or           i
    store        buf                         ; *buf <- (*buf & const_FFFFFF00) | i


    load_imm     buf
    add          const_1
    store        ptr                         ; ptr <- buf + 1

    load         buf
    and          const_FF
    store        i                           ; i <- *buf & const_FF

write_pstr:

    beqz         end                         ; while (i != 0) {

    load         ptr
    load_acc
    and          const_FF
    store_ind    output_addr                 ;     *output_addr <- *ptr & const_FF

    load         ptr
    add          const_1
    store        ptr                         ;     ptr <- ptr + const_1

    load         i
    sub          const_1
    store        i                           ;     i <- i - const_1

    jmp          write_pstr                  ; }

end:
    halt

fail:
    load         const_failure
    store_ind    output_addr                 ; *output_addr <- const_failure
    halt
