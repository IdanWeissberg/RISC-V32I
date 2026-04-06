# Branch Comparator Specification (RV32I)

## 1. Overview
The **Branch Comparator** is a specialized combinatorial logic unit within the Instruction Decode (ID) or Execute (EX) stage. Its sole purpose is to evaluate the condition of B-type instructions (conditional branches) and output a single-bit decision (`branch_decision`). This decision determines whether the processor should take the branch (update PC to target address) or continue to the next sequential instruction (PC+4).

## 2. Design Hierarchy
* **Type**: Purely Combinatorial.
* **Placement**: Typically works in parallel with the ALU or within the Branch Logic to minimize branch latency.
* **Inputs**: Two 32-bit register values (`rs1`, `rs2`) and the current instruction Word.
* **Outputs**: A boolean flag (`branch_decision`).

## 3. Port Map (Interface)

| Port Name         | Direction | Width | Type  | Description                                                                 |
| :---------------- | :-------- | :---- | :---- | :-------------------------------------------------------------------------- |
| `rs_1`            | Input     | 32    | Wire  | Data from source register 1.                                               |
| `rs_2`            | Input     | 32    | Wire  | Data from source register 2.                                               |
| `instruction`     | Input     | 32    | Wire  | The full 32-bit instruction word (used to extract `funct3`).               |
| `branch_decision` | Output    | 1     | Reg   | Logic '1' if the branch condition is met, '0' otherwise.                   |

## 4. Supported Comparisons (B-Type)
The module extracts `funct3` (bits [14:12]) to identify the comparison type:

| Funct3 | Mnemonic | Comparison Logic (Verilog) | Description |
| :---   | :---     | :---                      | :---        |
| `3'b000` | **BEQ** | `rs_1 == rs_2`            | Branch if Equal |
| `3'b001` | **BNE** | `rs_1 != rs_2`            | Branch if Not Equal |
| `3'b100` | **BLT** | `$signed(rs_1) < $signed(rs_2)` | Branch if Less Than (Signed) |
| `3'b101` | **BGE** | `$signed(rs_1) >= $signed(rs_2)`| Branch if Greater or Equal (Signed) |
| `3'b110` | **BLTU** | `$unsigned(rs_1) < $unsigned(rs_2)`| Branch if Less Than (Unsigned) |
| `3'b111` | **BGEU** | `$unsigned(rs_1) >= $unsigned(rs_2)`| Branch if Greater or Equal (Unsigned) |

## 5. Implementation Details
* **Internal Decoding**: The module performs localized decoding of the `funct3` field, reducing the wiring load on the Main Control Unit.
* **Signedness Handling**: 
    * For `BLT` and `BGE`, operands are cast to `$signed` to correctly handle Two's Complement values.
    * For `BLTU` and `BGEU`, operands are explicitly cast to `$unsigned` (standard Verilog behavior, but made explicit for clarity).
* **Latch Prevention**: `branch_decision` is initialized to `0` at the start of the `always @(*)` block. Combined with a `default` case, this ensures the output is always driven, preventing the inference of unwanted memory elements (latches).

## 6. Timing & Integration
* **Critical Path**: The output of this module is often part of the PC-update logic, which is a timing-critical path. 
* **Control Interaction**: The `branch_decision` output is typically ANDed with the `branch` control signal from the Main Control Unit to determine the final PC source.