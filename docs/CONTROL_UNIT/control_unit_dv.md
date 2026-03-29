# Verification Plan: Main Control (Decoder)

## 1. Objective
To verify the correct decoding of RISC-V Opcodes into control signals (`ALUOp`, `RegWrite`, `MemRead`, `MemWrite`, `Branch`, `ALUSrc`, `MemtoReg`, `jal_branch_mux`, `jalr`, `lui`).
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
    * `lui = 0`, `jalr = 0`, `jal_branch_mux = 0`

### TC_02: Load Instruction (LW)
* **Input:** `Opcode = 7'b0000011`
* **Description:** Load Word from memory to register. This is the most complex control path.
* **Expected Result:**
    * `ALUSrc   = 1` (Address calculation: Reg + Immediate)
    * `MemRead  = 1` (Reading from Data Memory)
    * `MemtoReg = 2'b01` (Data comes from Memory, not ALU)
    * `RegWrite = 1` (Write to register)
    * `MemWrite = 0`
    * `ALUOp    = 2'b00` (Force ADD for address calc)
    * `lui = 0`, `jalr = 0`, `jal_branch_mux = 0`

### TC_03: Store Instruction (SW)
* **Input:** `Opcode = 7'b0100011`
* **Description:** Store Word from register to memory.
* **Expected Result:**
    * `MemWrite = 1` (The only time memory is written)
    * `RegWrite = 0` (CRITICAL: Must NOT corrupt register file)
    * `ALUSrc   = 1` (Address calculation)
    * `MemRead  = 0`
    * `ALUOp    = 2'b00` (Force ADD for address calc)
    * `lui = 0`, `jalr = 0`, `jal_branch_mux = 0`

### TC_04: Branch Instruction (BEQ/BNE/BLT/BGE/BLTU/BGEU)
* **Input:** `Opcode = 7'b1100011`
* **Description:** Conditional Branch. The specific branch type (BEQ, BNE, etc.) is resolved by the `branch_comparator` unit using `funct3` — the control unit only enables the branch path.
* **Expected Result:**
    * `Branch         = 1` (Enables PC jump when condition is met)
    * `jal_branch_mux = 1` (Selects branch_comparator result, not unconditional)
    * `ALUOp          = 2'b01`
    * `RegWrite = 0` (Comparisons don't save results)
    * `MemWrite = 0`, `MemRead = 0`
    * `lui = 0`, `jalr = 0`

### TC_05: I-Type Arithmetic (ADDI)
* **Input:** `Opcode = 7'b0010011`
* **Description:** Arithmetic with Immediate.
* **Expected Result:**
    * `ALUSrc   = 1` (Second operand is Immediate)
    * `RegWrite = 1`
    * `ALUOp    = 2'b11` (Defined as `ALUOP_ITYPE`)
    * `MemtoReg = 2'b00` (Result comes from ALU)
    * `lui = 0`, `jalr = 0`, `jal_branch_mux = 0`

### TC_06: JAL (Jump and Link)
* **Input:** `Opcode = 7'b1101111`
* **Description:** Unconditional jump. Writes PC+4 return address to rd.
* **Expected Result:**
    * `Branch         = 1` (Jump is always taken)
    * `jal_branch_mux = 0` (Unconditional: bypasses comparator, forces jump)
    * `MemtoReg       = 2'b10` (Write PC+4 to rd)
    * `RegWrite = 1`
    * `MemRead  = 0`, `MemWrite = 0`
    * `ALUOp    = 2'b01`
    * `lui = 0`, `jalr = 0`

### TC_07: JALR (Jump and Link Register)
* **Input:** `Opcode = 7'b1100111`
* **Description:** Indirect jump via register + immediate. Writes PC+4 to rd.
* **Expected Result:**
    * `jalr     = 1` (Selects ALU result as jump target via JALR path in fetch unit)
    * `Branch   = 0` (Uses separate jalr path, not the branch path)
    * `ALUSrc   = 1` (rs1 + immediate for target address)
    * `ALUOp    = 2'b00` (Force ADD)
    * `MemtoReg = 2'b10` (Write PC+4 to rd)
    * `RegWrite = 1`
    * `lui = 0`, `jal_branch_mux = 0`

### TC_08: LUI (Load Upper Immediate)
* **Input:** `Opcode = 7'b0110111`
* **Description:** Loads a 20-bit immediate into the upper bits of rd. Lower 12 bits are zero.
* **Expected Result:**
    * `lui      = 1` (Overrides ALU control to pass-through the immediate)
    * `ALUSrc   = 1` (Feed immediate into ALU)
    * `MemtoReg = 2'b00` (ALU pass-through result → rd)
    * `RegWrite = 1`
    * `MemRead  = 0`, `MemWrite = 0`, `Branch = 0`
    * `jalr = 0`, `jal_branch_mux = 0`

### TC_09: AUIPC (Add Upper Immediate to PC)
* **Input:** `Opcode = 7'b0010111`
* **Description:** Computes PC + upper immediate and writes result to rd.
* **Expected Result:**
    * `MemtoReg = 2'b11` (Selects `jump_add_c` = PC + imm as writeback value)
    * `RegWrite = 1`
    * `MemRead  = 0`, `MemWrite = 0`, `Branch = 0`
    * `lui = 0`, `jalr = 0`, `jal_branch_mux = 0`

---

## 3. Corner Cases & Robustness

### TC_10: Invalid Opcode (Safety Check)
* **Input:** `Opcode = 7'b1111111` (Or any undefined opcode)
* **Description:** Simulating a bug in the software or uninitialized instruction memory.
* **Expected Result:**
    * `RegWrite = 0` (Must NOT write to register)
    * `MemWrite = 0` (Must NOT write to memory)
    * `Branch   = 0`
    * `lui = 0`, `jalr = 0`
    * (Values of `ALUSrc` or `ALUOp` are "Don't Care" as long as state is safe).
