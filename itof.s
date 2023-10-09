# This example demonstrates how strings, integers, chars and floating point
# values may be printed to the console

.data
str:        .string      "A string"
newline:    .string      "\n"
delimiter:  .string      ", "
num:        .dword        0xBBFFFFFFFF, 0x84f2
mask:        .word        0xFFFFF

.text
    la t0, num
    lw a0, 12(t0)
    lw a1, 8(t0)
    lw a5, 4(t0)
    lw a6, 0(t0)
    
    jal itof
    
# -------- Float printing ----------
# Print an approximation of Pi (3.14159265359)
#    li a0, 0x40490FDB
#    li a7, 2
#    ecall

#    jal printNewline
    jal exit

# ====== Helper routines ======
# cast int64 to double
# input uint64[a0, a1] 
# output double[a0, a1]
itof:
    bnez a0, inrange
    bnez a1, inrange
    li t0, 1
    slli t0, t0, 21
    blt a0, t0, inrange
# overrange, set msb 1
    li t0, 1
    slli t0, t0, 31
    or a0, a0, t0
    ret
inrange:
    mv t1, a0
    li a2, 0
    li a3, 20
    li a4, 1
    slli a4, a4, 20
loopHigh: 
    and t0, t1, a4
    bnez t0, downLow
    slli t1, t1, 1
    addi a2, a2, 1
    addi a3, a3, -1
    bnez a3, loopHigh
downHigh:
    mv t1, a1
    li a3, 32
    addi a2, a2, 1
    li a4, 1
    slli a4, a4, 31
loopLow:
    and t0, t1, a4
    bnez t0, downLow
    slli t1, t1, 1
    addi a2, a2, 1
    addi a3, a3, -1
    bnez a3, loopLow
downLow:
    li a3, 32
    bge a2, a3, ge32
# lt32
    sub a3, a3, a2
    sll a0, a0, a2
    srl t0, a1, a3
    sll a1, a1, a2
    or a0, a0, t0
    j merged
ge32:
    sub a3, a2, a3
    sll a1, a1, a3
    mv a0, a1
    li a1, 0
# exponent = 1023 + 52 - shifts
merged:
    li a3, 1075
    sub a3, a3, a2
    slli a3, a3, 20
    la t0, mask
    lw t0, 0(t0)
    and a0, a0, t0
    or a0, a0, a3
    ret

printNewline:
    la a0, newline
    li a7, 4
    ecall
    jr x1

exit:
    # Exit program
    li a7, 10
    ecall
