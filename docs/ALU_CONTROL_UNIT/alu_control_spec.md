# ALU Control Unit Specification (RV32I)

## 1. Overview
The **ALU Control Unit** serves as a secondary, localized decoder within the execution stage of the single-cycle RISC-V processor. Its primary role is to translate broad operation categories provided by the Main Control Unit (`alu_op`) into a precise 4-bit execution command (`alu_op_output`) that directly drives the Arithmetic Logic Unit (ALU). It achieves this by evaluating the `funct_3` and `funct_7` fields embedded within the instruction.

## 2. Design Hierarchy
This module is a strictly **Combinatorial Leaf Module**. It operates entirely independently of the system clock and resides functionally between the Main Control Unit, the Instruction Decode bus, and the ALU. By isolating this logic from the Main Control Unit, the processor design adheres to a modular, two-tier decoding architecture, significantly simplifying the main controller's state machine.

## 3. Port Map (Interface)

| Port Name       | Direction | Width | Type  | Description                                                                 |
| :-------------- | :-------- | :---- | :---- | :-------------------------------------------------------------------------- |
| `alu_op`        | Input     | 2     | Wire  | Broad operation category issued by the Main Control (e.g., Mem, Branch, R/I-Type). |
| `funct_3`       | Input     | 3     | Wire  | The 3-bit function code extracted from instruction bits [14:12].            |
| `funct_7`       | Input     | 7     | Wire  | The 7-bit function code extracted from instruction bits [31:25].            |
| `lui`           | Input     | 1     | Wire  | LUI override signal from Main Control. When high, forces `ALU_CTRL_LUI` output regardless of `alu_op`. |
| `alu_op_output` | Output    | 4     | Reg   | The specific 4-bit command routed to the ALU Unit to execute the operation. |

## 4. Internal Logic & Implementation

### Two-Tier Decoding Strategy
The unit utilizes a nested combinatorial structure (`case` statements) to determine the exact ALU operation:

1. **Fixed Operations (`ALUOP_MEM`, `ALUOP_BRANCH`)**: 
   For Memory operations (Load/Store/JALR), the unit forces an `ADD` operation for address calculation, strictly ignoring the `funct` fields. For Branch operations, it forces a `SUB` operation to facilitate register comparison (e.g., `rs1 - rs2`).
   
2. **R-Type Operations (`ALUOP_R_TYPE`)**: 
   The logic sweeps the `funct_3` field to identify the base operation (ADD, XOR, SLL, etc.). It crucially evaluates bit 30 (within `funct_7`) to differentiate between standard and alternative operations—specifically distinguishing `ADD` from `SUB`, and Logical Right Shift (`SRL`) from Arithmetic Right Shift (`SRA`).

3. **I-Type Operations (`ALUOP_I_TYPE`)**: 
   Similar to R-Type, it uses `funct_3` for base operation decoding. However, it explicitly **ignores** `funct_7` for standard arithmetic (preventing a non-existent `SUBI` instruction). As a specific RISC-V ISA exception, it **evaluates** `funct_7` solely during Shift operations to distinguish between `SRLI` and `SRAI`.

4. **LUI Override (`lui`)**:
   When the `lui` signal is asserted by the Main Control Unit, the entire `case` decoding is bypassed. The output is immediately and unconditionally forced to `ALU_CTRL_LUI`, directing the ALU to pass the immediate operand through unchanged. This is required because LUI is a U-Type instruction — it has no `funct_3`/`funct_7` fields and no applicable `alu_op` category.

### Latch Prevention & Safety Routing
To ensure robust synthesis and prevent the inference of unwanted memory elements (Latches), the module employs a **Pre-assignment Strategy**. At the beginning of the `always @(*)` block, `alu_op_output` is defaulted to `ALU_CTRL_ADD` (`4'b0000`). This guarantees a defined state even if an unsupported or corrupted `alu_op` is received, favoring a non-destructive add operation over unpredictable ALU behavior.

## 5. Synchronization & Timing
* **Combinatorial Delay**: As an unclocked, purely combinational circuit, the outputs react asynchronously to input changes. 
* **Critical Path**: The timing delay of this module is part of the processor's critical execution path. The output `alu_op_output` must stabilize, and the subsequent ALU Unit must finish its mathematical computation, all well within a single clock cycle before the next rising edge captures the result.