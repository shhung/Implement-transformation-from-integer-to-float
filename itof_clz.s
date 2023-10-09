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
    jal itof
    
    jal exit

# ====== subroutines ======
# cast int64 to double
# input uint64[a0, a1] 
# output double[a0, a1]
itof:
    addi sp, sp, -4
    sw ra, 0(sp)
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
    addi sp, sp, -8
    sw a0, 0(sp)
    sw a1, 4(sp)
    call clz
    addi a2, a0, -11
    lw a0, 0(sp)
    lw a1, 4(sp)
    addi sp, sp 8
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
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
clz:
# input int64[a0, a1]
# iutput int32[a0]
# x |= (x >> {1, 2, 4, 8, 16})
    addi sp, sp, -4
    sw ra, 0(sp)
    
	addi t1, x0, 0x1
Loop1:
	addi t2, x0, 32
    srl t0, a0, t1
    or a0, a0, t0
    srl t0, a1, t1
    or a1, a1, t0
	sub t2, t2, t1
    sll t0, a0, t2
    or a1, a1, t0
	slli t1, t1, 1
	addi t2, x0, 32
	bgt t2, t1, Loop1
# x |= (x >> 32)
    or a1, a1, a0
# x -= ((x >> 1) & 0x5555555555555555);
    la t6, mask    
    srli t0, a0, 1
    lw t5, 0(t6)
    and t0, t0, t5 # t0 = (a0 >> 1) & 0x55555555
    srli t1, a1, 1
    slli t2, a0, 31
    or t1, t1, t2
    and t1, t1, t5 # t1 = (a1 >> 1) & 0x55555555
    sub a0, a0, t0
    sltu t3, a1, t1
    bne t3, x0, Borrow
    sub a1, a1, t1
    j Done
Borrow:
    addi a0, a0, -1
    sub a1, t1, a1
    addi t3, x0, -1
    sub a1, t3, a1
Done:
# x = ((x >> 2) & 0x3333333333333333) + (x & 0x3333333333333333)
    lw t5, 4(t6)
    srli t0, a0, 2
    srli t1, a1, 2
    slli t2, a0, 30
    or t1, t1, t2
# [t0, t1] = x >> 2
    and t0, t0, t5
    and t1, t1, t5
    and a0, a0, t5
    and a1, a1, t5
    mv a2, t0
    mv a3, t1
    jal ra, Add64
# ((x >> 4) + x) & 0x0f0f0f0f0f0f0f0f
    srli t0, a0, 4
    srli t1, a1, 4
    slli t2, a0, 28
    or t1, t1, t2
    mv a2, t0
    mv a3, t1
    jal ra, Add64
    lw t5, 8(t6)
    and a0, a0 ,t5
    and a1, a1 ,t5
# x += (x >> 8)
    srli t0, a0, 8
    srli t1, a1, 8
    slli t2, a0, 24
    or t1, t1, t2
    mv a2, t0
    mv a3, t1
    jal ra, Add64
# x += (x >> 16)
    srli t0, a0, 16
    srli t1, a1, 16
    slli t2, a0, 16
    or t1, t1, t2
    mv a2, t0
    mv a3, t1
    jal ra, Add64 
# x += (x >> 32)
    mv a2, x0
    mv a3, a0
    jal ra, Add64
# return (64 - (x & 0x7f))
    andi a0, a1, 0x7f
    addi a1, x0, 64
    sub a0, a1, a0
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
Add64:
    add a0, a0, a2
    add a1, a1, a3
    sltu s0, a1, a3
    bne s0, x0, Carry
    ret
Carry:
    addi a0, a0, 1
    ret

exit:
    # Exit program
    li a7, 10
    ecall
