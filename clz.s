.data
num:        .dword        0xBBFFFFFFFF, 0x84f2, 0x811111111
maskclz:    .word        0x55555555, 0x33333333, 0x0f0f0f0f
.text
    la t0, num
    lw a0, 4(t0) 
    lw a1, 0(t0)
    call clz
    call exit
clz:
# input int64[a0, a1]
# output int32[a0]
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
    la t6, maskclz    
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