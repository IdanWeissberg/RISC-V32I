# Verification Plan: Main Control (Decoder)

## 1. Objective
To verify the correct decoding of RISC-V Opcodes into control signals (`ALUOp`, `RegWrite`, `MemRead`, `MemWrite`, `Branch`, `ALUSrc`, `MemtoReg`).
The goal is to ensure **Functional Correctness** (correct logic) and **Safety** (no accidental writes).

## 2. Critical Functionality Tests (The "Golden Vectors")

### TC_01: R-Type Instruction (ADD, SUB, XOR...)
* **Input:** `Opcode = 7'b0110011`
* **Description:** Standard arithmetic operation between two registers.
* **Expected Result:**
    * `RegWrite = 1` (Must write result back)
    * `ALUSrc   = 0` (Second operand is Register, NOT Immediate)
    * `MemRead  = 0`, `MemWrite = 0` (No memory access)
    * `Branch   = 0`
    * `ALUOp    = 2'b10` (Delegates operation choice to ALU Control)

### TC_02: Load Instruction (LW)
* **Input:** `Opcode = 7'b0000011`
* **Description:** Load Word from memory to register. This is the most complex control path.
* **Expected Result:**
    * `ALUSrc   = 1` (Address calculation: Reg + Immediate)
    * `MemRead  = 1` (Reading from Data Memory)
    * `MemtoReg = 1` (Data comes from Memory, not ALU)
    * `RegWrite = 1` (Write to register)
    * `MemWrite = 0`
    * `ALUOp    = 2'b00` (Force ADD for address calc)

### TC_03: Store Instruction (SW)
* **Input:** `Opcode = 7'b0100011`
* **Description:** Store Word from register to memory.
* **Expected Result:**
    * `MemWrite = 1` (The only time memory is written)
    * `RegWrite = 0` (CRITICAL: Must NOT corrupt register file)
    * `ALUSrc   = 1` (Address calculation)
    * `MemRead  = 0`
    * `ALUOp    = 2'b00` (Force ADD for address calc)

### TC_04: Branch Instruction (BEQ)
* **Input:** `Opcode = 7'b1100011`
* **Description:** Conditional Branch.
* **Expected Result:**
    * `Branch   = 1` (Tells PC logic to prepare for jump)
    * `ALUOp    = 2'b01` (Force SUB for comparison)
    * `RegWrite = 0` (Comparisons don't save results)
    * `MemWrite = 0`, `MemRead = 0`

### TC_05: I-Type Arithmetic (ADDI)
* **Input:** `Opcode = 7'b0010011`
* **Description:** Arithmetic with Immediate.
* **Expected Result:**
    * `ALUSrc   = 1` (Second operand is Immediate)
    * `RegWrite = 1`
    * `ALUOp    = 2'b11` (Defined as `ALUOP_ITYPE`)
    * `MemtoReg = 0` (Result comes from ALU)

---

## 3. Corner Cases & Robustness

### TC_06: Invalid Opcode (Safety Check)
* **Input:** `Opcode = 7'b1111111` (Or any undefined opcode)
* **Description:** Simulating a bug in the software or uninitialized instruction memory.
* **Expected Result:**
    * `RegWrite = 0` (Must NOT write to register)
    * `MemWrite = 0` (Must NOT write to memory)
    * `Branch   = 0`
    * (Values of `ALUSrc` or `ALUOp` are "Don't Care" as long as state is safe).
