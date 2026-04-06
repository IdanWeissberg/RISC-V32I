# Module: riscv_core (Top Level)

## 1. Description
The `riscv_core` module serves as the Top-Level entity for the RV32I single-cycle processor. It integrates the complete Data Path and Control Path. The core connects all internal sub-modules starting from the Instruction Fetch (IF) stage down to the Write Back (WB) stage.

## 2. Interface (Ports)
| Port Name | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | Input | 1-bit | System clock signal. |
| `rst_n` | Input | 1-bit | Active-low asynchronous reset. |

*(Note: In a typical SoC wrapper, you might also expose Instruction/Data Memory interfaces, but here they are instantiated internally).*

## 3. Sub-Modules (Components)
The core instantiates the following hardware components:
1. **fetch_unit**: Manages the Program Counter (PC) and computes the next PC (PC+4 or Branch/Jump target).
2. **instruction_memory**: ROM containing the program code.
3. **control_unit**: Decodes the `opcode` and generates main control signals (e.g., `mem_read`, `alu_src`, `reg_write`).
4. **register_file**: 32x32-bit registers, supporting two asynchronous reads and one synchronous write.
5. **imm_gen**: Sign-extends the immediate field from the instruction based on the instruction type.
6. **branch_comparator**: Evaluates branch conditions (e.g., BEQ, BNE) directly from `rs1` and `rs2`.
7. **alu_control**: Decodes `funct3`, `funct7`, and the main `alu_op` to generate a specific 4-bit ALU operation.
8. **alu_unit**: Performs arithmetic and logical operations.
9. **data_memory**: RAM for Load/Store instructions.

## 4. Key Data Path Flow
* **IF Stage**: PC fetches the instruction from `instruction_memory`. 
* **ID Stage**: `instruction` is split. The `control_unit` generates signals. The `register_file` reads `rs1` and `rs2`. `imm_gen` creates the 32-bit immediate.
* **EX Stage**: The `alu_unit` receives operands based on `alu_src` (either `rs2` or `imm_gen`). The `jump_add_c` is calculated.
* **MEM Stage**: `data_memory` is accessed if `mem_read` or `mem_write` are asserted.
* **WB Stage**: A Multiplexer (`mem_to_reg_c`) selects the data to write back to the `register_file` (`rd`). Options include ALU Result, Memory Read Data, PC+4 (for JAL/JALR), or Jump Address.

## 5. Branch & Jump Resolution (Combinational)
The program flow is altered using `pc_sel_c`, which is determined by:
* The `branch_decision` from the `branch_comparator`.
* The `branch` and `jal_or_branch` control signals.
* The `jalr` control signal.