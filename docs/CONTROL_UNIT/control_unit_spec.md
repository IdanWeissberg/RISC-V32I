# Main Control Unit Specification (RV32I)

## 1. Overview
The **Main Control Unit** is the primary decoder of the processor, located in the Instruction Decode (ID) stage. It accepts the 7-bit `op_code` from the instruction and generates the necessary control signals to orchestrate the Data Path. These signals determine how data flows through the ALU, Memory, and Register File.

## 2. Design Hierarchy
* **Type**: Purely Combinatorial Logic.
* **Input**: 7-bit `op_code` (Instruction bits [6:0]).
* **Outputs**: Various control lines for Muxes, Enables, and the ALU Control unit.

## 3. Port Map (Interface)

| Port Name          | Direction | Width | Type  | Description                                                                 |
| :----------------- | :-------- | :---- | :---- | :-------------------------------------------------------------------------- |
| `op_code`          | Input     | 7     | Wire  | The opcode field of the current instruction.                                |
| `jal_branch_mux`   | Output    | 1     | Reg   | Selects between PC+Imm (Branch/JAL) and ALU result for the next PC.         |
| `jalr`             | Output    | 1     | Reg   | Specific override for JALR instructions.                                   |
| `mem_read`         | Output    | 1     | Reg   | Enables reading from Data Memory.                                           |
| `branch`           | Output    | 1     | Reg   | Signals a potential branch or jump operation.                               |
| `mem_to_reg`       | Output    | 2     | Reg   | Selects the data source for the Register File write-back (ALU/Mem/PC+4/PC+Imm).|
| `mem_write`        | Output    | 1     | Reg   | Enables writing to Data Memory.                                             |
| `alu_src`          | Output    | 1     | Reg   | Selects second ALU operand: 0 for `rs2`, 1 for Immediate.                   |
| `reg_write`        | Output    | 1     | Reg   | Enables writing the result to the Register File.                            |
| `alu_op`           | Output    | 2     | Reg   | Operation category sent to the ALU Control Unit.                            |
| `lui`              | Output    | 1     | Reg   | Load Upper Immediate override signal.                                       |

## 4. Control Signals Truth Table
The module implements the following logic (simplified view):

| Instruction | `reg_write` | `alu_src` | `mem_read` | `mem_write` | `alu_op` | `mem_to_reg` |
| :---        | :---:       | :---:     | :---:      | :---:       | :---:    | :---:        |
| **R-Type** | 1           | 0         | 0          | 0           | 2'b10    | 2'b00 (ALU)  |
| **I-Type** | 1           | 1         | 0          | 0           | 2'b11    | 2'b00 (ALU)  |
| **Load** | 1           | 1         | 1          | 0           | 2'b00    | 2'b01 (Mem)  |
| **Store** | 0           | 1         | 0          | 1           | 2'b00    | 2'b00        |
| **Branch** | 0           | 0         | 0          | 0           | 2'b01    | 2'b00        |
| **JAL/JALR**| 1           | X         | 0          | 0           | 2'b01/00 | 2'b10 (PC+4) |
| **AUIPC** | 1           | 0         | 0          | 0           | 2'b00    | 2'b11 (PC+Imm)|
| **LUI** | 1           | 1         | 0          | 0           | 2'b00    | 2'b00 (ALU)  |

## 5. Functional Implementation Details
* **ALU Op Coding**: 
    * `2'b00`: Force ADD (Loads/Stores/LUI/AUIPC).
    * `2'b01`: Force SUB (Branches/JAL).
    * `2'b10/11`: Detailed decoding based on `funct` fields (R-Type/I-Type).
* **Write-Back Mux (`mem_to_reg`)**:
    * `2'b00`: ALU Result.
    * `2'b01`: Data Memory Output.
    * `2'b10`: PC + 4 (Return address for jumps).
    * `2'b11`: AUIPC result (PC + Immediate).
* **Default/Safety State**: To prevent unintended side effects (like accidental memory writes or register corruption) on invalid opcodes, the module defaults all output signals to `0` (Disabled).
