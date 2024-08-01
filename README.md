This is my work to make a basic functioning CPU with System Verilog that follows the RISC-V architecture

In the Verilog files folder is all of the system Verilog files that were used to design the architeure of the CPU.

In the custom assembler folder has the code for a custom assembler that turns the basic functions the CPU can do into machine code that can be simulated and run.

The simulations were all done and tested on Vivado software.

This implementation currently only implements RV32I base integer instruction set, this will hopefully be expanded upon later.

The current functionality has the instructions: 

Load upper immediate: LUI
Add Upper Immediate to pc: AUIPC
Jump and Link: JAL
Jump and Link Register: JALR
Branch if Equal: BEQ
Branch if Not Equal: BNE
Branch if Less Than: BLT
Branch if Greater Than or Equal: BGE
Branch if Less Than Unsigned: BLTU
Branch if Greater Than or Equal Unsigned: BGEU

Load Bit: LB
Load Half: LH
Load Whole: LW
Load Bit Unsigned: LBU
Load Half Unsigned: LHU
Save Bit: SB
Save Half: SH
Save Whole: SW

Add with immediate: ADDI
Set less than with immediate: SLTI
Set less than with immediate unsigned: SLTIU
Bitwise Exclusive or with immediate: XORI
Bitwise Or with immediate: ORI
Bitwise And with immediate: ANDI
Logical Left Shift with immediate: SLLI
Logical Right Shift with immediate: SRLI
Arithmetic Right Shift with immediate: SRAI

Add: ADD
Subtract: SUB
Logical Left Shift: SLL
Set less than: SLT
Set less than Unsigned: SLTU
Bitwise Exclusive or: XOR
Logical Right Shift: SRL
Arithmetic Right Shift: SRA
Bitwise Or: OR
Bitwise And: AND

FENCE
FENCE.TSO
PAUSE
ECALL
BREAK
