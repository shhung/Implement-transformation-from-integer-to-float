# Implement-transformation-from-integer-to-float
It's assignment 1 of lecture [Computer Architecture](http://wiki.csie.ncku.edu.tw/arch/schedule)

## About
The first goal is to implementation count leading zero as shown in c code from [quiz 1](https://hackmd.io/@sysprog/arch2023-quiz1-sol) with RV32I.
After implementing CLZ, it was then utilized to optimize the conversion from integers to floating-point format.

Detailed explanations can be found in the development notes [Assignment1: RISC-V Assembly and Instruction Pipeline](https://hackmd.io/@shhung/HkLDYvfea)

## Undo
This project only implements the conversion for 64-bit unsigned integers and outputs a 64-bit IEEE 754 standard double-precision floating-point representation
