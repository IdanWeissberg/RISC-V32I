# Verification Plan: `alu_control`

## 1. Objective
To verify the correct decoding of the main controller's `alu_op` signal, combined with the instruction's `funct_3` and `funct_7` fields, into the specific 4-bit `alu_op_output`. 
The verification is designed to validate **Functional Correctness** for all R-Type and I-Type instructions, while simultaneously testing **Isolation (Robustness)** against noisy "Don't Care" bits in specific formats.

---

## 2. Test Cases (Aligned with Testbench)

### TC_01: Branch Condition Evaluation
* **Inputs:** `alu_op = ALUOP_BRANCH` (01), `funct_3 = 000`, `funct_7 = 0000000`
* **Expected Output:** `alu_op_output = ALU_CTRL_SUB`
* **Description:** Verifies that branch operations trigger a subtraction for comparison.

### TC_02: Memory Access & Isolation (Combined Test)
* **Inputs:** `alu_op = ALUOP_MEM` (00), `funct_3 = 101` (Random), `funct_7 = 1101111` (Random)
* **Expected Output:** `alu_op_output = ALU_CTRL_ADD`
* **Description:** Address calculation for memory operations always requires addition. This test deliberately injects "noise" into `funct_3` and `funct_7` to prove the controller strictly ignores them when `ALUOP_MEM` is active.

### TC_03: R-Type Instructions (Full Sweep)
* **Inputs:** `alu_op = ALUOP_R_TYPE` (10), sweeping through all defined `funct_3` and `funct_7` combinations.
* **Expected Output:** The corresponding `ALU_CTRL_*` signals.
* **Description:** Systematically verifies all Register-to-Register operations. 
  * Specifically validates that `funct_7` correctly distinguishes between `ADD`/`SUB` and between `SRL`/`SRA`.
  * Validates logic operations: `SLL`, `SLT`, `SLTU`, `XOR`, `OR`, `AND`.

### TC_04: I-Type Arithmetic & Isolation (ADDI)
* **Inputs:** `alu_op = ALUOP_I_TYPE` (11), `funct_3 = FUNCT3_ADD_SUB`, `funct_7 = 1100011` (Random Noise)
* **Expected Output:** `alu_op_output = ALU_CTRL_ADD`
* **Description:** Evaluates an I-Type addition. Injects random noise into the `funct_7` field (simulating bits of an immediate value) to guarantee it does not accidentally trigger a subtraction (`SUBI` does not exist).

### TC_05: I-Type Logic & Shifts
* **Inputs:** `alu_op = ALUOP_I_TYPE` (11), sweeping through the remaining `funct_3` codes (`SLL`, `SLT`, `SLTU`, `XOR`, `OR`, `AND`, `SRL_SRA`).
* **Expected Output:** The corresponding `ALU_CTRL_*` signals.
* **Description:** Verifies all I-Type immediate logic operations.
  * Crucially checks the RISC-V exception where I-Type shifts (`SRLI` vs `SRAI`) *do* rely on `funct_7` (bit 30) for differentiation.

### TC_06: LUI Override (Priority Check)
* **Inputs:** `lui = 1`, `alu_op = ALUOP_R_TYPE` (10), `funct_3 = 000`, `funct_7 = 0000000` (would normally decode to ADD)
* **Expected Output:** `alu_op_output = ALU_CTRL_LUI` (4'b1111)
* **Description:** Verifies that asserting `lui` unconditionally overrides the `alu_op` case decode. Even with inputs that would normally produce `ALU_CTRL_ADD`, the output must be `ALU_CTRL_LUI`. Tests the priority of the `if (lui)` guard over the `case` statement.