# Verification Plan: `alu_unit`

## 1. Objective
To verify the complete mathematical and logical operation of the Arithmetic Logic Unit (ALU). The plan validates **Functional Correctness** across all defined operations, verifies the generation of the **Zero Flag**, and rigorously tests **Corner Cases** using explicitly defined binary and hexadecimal stimulus vectors.

---

## 2. Functional Correctness (Standard Vectors)
Tests for basic arithmetic and logical operations with standard 32-bit values.

### TC_01: Basic Arithmetic (ADD)
* **Inputs:** * `alu_op_in` = `4'b0010` (`ALU_CTRL_ADD`)
  * `read_data_1` = `32'h0000_0064` (100 in Dec)
  * `alu_mux` = `32'h0000_0032` (50 in Dec)
* **Expected Output:** `alu_result` = `32'h0000_0096` (150 in Dec), `zero` = `1'b0`

### TC_02: Basic Arithmetic (SUB)
* **Inputs:** * `alu_op_in` = `4'b0110` (`ALU_CTRL_SUB`)
  * `read_data_1` = `32'h0000_0064` (100)
  * `alu_mux` = `32'h0000_0032` (50)
* **Expected Output:** `alu_result` = `32'h0000_0032` (50), `zero` = `1'b0`

### TC_03: Bitwise Logic (AND, OR, XOR)
* **Inputs:** `read_data_1` = `32'hAAAA_AAAA`, `alu_mux` = `32'h5555_5555` (Alternating bit masks)
* **Test A (AND):** `alu_op_in` = `4'b0000` -> **Expected:** `alu_result` = `32'h0000_0000`, `zero` = `1'b1`
* **Test B (OR):** `alu_op_in` = `4'b0001` -> **Expected:** `alu_result` = `32'hFFFF_FFFF`, `zero` = `1'b0`
* **Test C (XOR):** `alu_op_in` = `4'b0011` -> **Expected:** `alu_result` = `32'hFFFF_FFFF`, `zero` = `1'b0`

### TC_04: Logical Shifts (SLL, SRL)
* **Inputs:** `read_data_1` = `32'h0000_000F`, `alu_mux` = `32'h0000_0004` (Shift by 4)
* **Test A (SLL):** `alu_op_in` = `4'b0100` -> **Expected:** `alu_result` = `32'h0000_00F0`, `zero` = `1'b0`
* **Test B (SRL):** `alu_op_in` = `4'b0101` -> **Expected:** `alu_result` = `32'h0000_0000`, `zero` = `1'b1`

### TC_05: Pass-Through (LUI)
* **Inputs:** * `alu_op_in` = `4'b1111` (`ALU_CTRL_LUI`)
  * `read_data_1` = `32'hDEAD_BEEF` (Should be ignored)
  * `alu_mux` = `32'h1234_5000`
* **Expected Output:** `alu_result` = `32'h1234_5000`, `zero` = `1'b0`

---

## 3. Corner Cases & Isolation Testing
Tests designed to stress the ALU's bit-masking rules, sign extensions, and zero-flag triggers.

### TC_06: Shift Over-Masking (Shift amount >= 32)
* **Inputs:** * `alu_op_in` = `4'b0100` (`ALU_CTRL_SLL`)
  * `read_data_1` = `32'h0000_0001`
  * `alu_mux` = `32'h0000_0021` (33 in Dec. Lower 5 bits `5'b00001` = Shift by 1)
* **Expected Output:** `alu_result` = `32'h0000_0002`, `zero` = `1'b0`
* **Description:** Verifies the `alu_mux[4:0]` constraint.

### TC_07: Shift by Zero
* **Inputs:**
  * `alu_op_in` = `4'b0100` (`ALU_CTRL_SLL`)
  * `read_data_1` = `32'h8765_4321`
  * `alu_mux` = `32'h0000_0000`
* **Expected Output:** `alu_result` = `32'h8765_4321`, `zero` = `1'b0`

### TC_08: Signed vs. Unsigned Comparison (SLT vs. SLTU)
* **Inputs:** `read_data_1` = `32'hFFFF_FFFF` (-1 Signed, Max Unsigned), `alu_mux` = `32'h0000_0001` (1)
* **Test A (SLT - Signed):** `alu_op_in` = `4'b1000` -> **Expected:** `alu_result` = `32'h0000_0001`, `zero` = `1'b0` (-1 is less than 1)
* **Test B (SLTU - Unsigned):** `alu_op_in` = `4'b1001` -> **Expected:** `alu_result` = `32'h0000_0000`, `zero` = `1'b1` (0xFFFFFFFF is NOT less than 1)

### TC_09: SRA Sign Extension Propagation
* **Inputs:** * `alu_op_in` = `4'b0111` (`ALU_CTRL_SRA`)
  * `read_data_1` = `32'h8000_0000` (Negative, MSB=1)
  * `alu_mux` = `32'h0000_0004` (Shift by 4)
* **Expected Output:** `alu_result` = `32'hF800_0000`, `zero` = `1'b0`
* **Description:** Ensures MSB is replicated (`1111_1000...`) instead of zero-filled.

### TC_10: Zero Flag Triggering (Branch Equality)
* **Inputs:** * `alu_op_in` = `4'b0110` (`ALU_CTRL_SUB`)
  * `read_data_1` = `32'hABCD_1234`
  * `alu_mux` = `32'hABCD_1234`
* **Expected Output:** `alu_result` = `32'h0000_0000`, **`zero` = `1'b1`**

### TC_11: Undefined Operation Safety (Default Case)
* **Inputs:** * `alu_op_in` = `4'b1110` (Undefined Opcode)
  * `read_data_1` = `32'h1111_1111`
  * `alu_mux` = `32'h2222_2222`
* **Expected Output:** `alu_result` = `32'h0000_0000`, `zero` = `1'b1`
* **Description:** Ensures the `default` statement correctly outputs zero to prevent latches.