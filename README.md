This is my work to make a basic functioning CPU with system verilog that follows the RISC-V acitecture

In the verilog files folder is all of the system verilog files that were used to design the architeure of the CPU.

In the custom assemebler folder has the code for a custom asembler that turns the basic fucntions the CPU can do into machine code that can be simulated and run.

The simulations were all done and tested on Vivado softwere.

This implemntaion cuentlly only implemnts RV32I base integer instuction set, this will hopefully be expanted apon later.

The curent functinality has the instuctions: 

Load upper imidiate: LUI
Add Upper Immediate to pc: AUIPC
Jump and Link: JAL
Jump and Link Regester: JALR
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

Add with imidiate: ADDI
Set less than with imidiate: SLTI
Set less than with imidiate unsigned:SLTIU
Bitwise Exlusive or with imidiate: XORI
Bitwise Or with imidiate: ORI
Bitwise And with imidiate: ANDI
Logical Left Shift with imidiate: SLLI
Logical Right Shift with imidiate: SRLI
Arethmetic Right Shift with imidiate:SRAI

Add: ADD
Subtract: SUB
Logical Left Shift: SLL
Set less than: SLT
Set less than Unsigned: SLTU
Bitwise Exlusive or: XOR
Logical Right Shift: SRL
Arethmetic Right Shift: SRA
Bitwise Or: OR
Bitwise And: AND

FENCE
FENCE.TSO
PAUSE
ECALL
BREAK
