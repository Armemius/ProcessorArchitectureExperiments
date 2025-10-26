    .data
input_addr:      .word  0x80
output_addr:     .word  0x84
max_value:       .word  67999
failure_code:    .word  0xCCCCCCCC

    .text
_start:
    lui      t0, %hi(input_addr)
    addi     t0, t0, %lo(input_addr)
    lw       t0, 0(t0)                       ; int* input_port = *input_addr
    lw       t0, 0(t0)                       ; int n = *input_port

    lui      a0, %hi(max_value)
    addi     a0, a0, %lo(max_value)
    lw       a0, 0(a0)                       ; int max_value = *max_value

    ; // t0 = n
    ; // a0 = max_value = 67999
    ble      t0, zero, negative_or_zero      ; if (n <= 0) negative_or_zero
    ble      a0, t0, overflow                ; if (67999 < n) overflow


    mv       t1, t0                          ; // t1 = t0
    addi     t1, t1, 1                       ; // t1 = t1 + 1
    mul      t1, t1, t0                      ; // t1 = t1 * t0
    addi     t2, t2, 2                       ; // t2 = 1
    div      t1, t1, t2                      ; int result = t0 * t1 / t2 = n * (n + 1) / 2
    j        end

overflow:
    lui      t1, %hi(failure_code)
    addi     t1, t1, %lo(failure_code)
    lw       t1, 0(t1)                       ; int result = *failure_code;
    j        end
negative_or_zero:
    addi     t1, t1, -1                      ; int result = -1
    j        end                             ; Just for aesthetics :)
end:
    lui      t0, %hi(output_addr)
    addi     t0, t0, %lo(output_addr)
    lw       t0, 0(t0)                       ; int* output_addr_const = &output_addr
    sw       t1, 0(t0)                       ; *output_addr_const = result
    halt
