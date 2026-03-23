# Module: imm_gen (Immediate Generator)

## 1. Overview
The `imm_gen` module is a combinational block responsible for extracting and reconstructing the 32-bit immediate value from a given RISC-V 32-bit instruction. It handles sign extension and bit-reordering as defined by the RV32I ISA.

## 2. Interface
| Signal      | Direction | Width  | Description                                      |
|-------------|-----------|--------|--------------------------------------------------|
| instruction | Input     | [31:0] | Full 32-bit instruction fetched from Memory.     |
| immediate   | Output    | [31:0] | Sign-extended 32-bit immediate value for the ALU.|

## 3. Supported Instruction Types
The module decodes the opcode (`inst[6:0]`) and generates the immediate based on the following formats:

### I-Type (Immediate/Load/JALR)
* **Target:** `ADDI`, `LW`, `JALR`, etc.
* **Structure:** Bits `[31:20]` are extracted and sign-extended (20 bits of `inst[31]`).
* **Logic:** `{{20{inst[31]}}, inst[31:20]}`

### S-Type (Store)
* **Target:** `SW`, `SH`, `SB`.
* **Structure:** Split between `[31:25]` and `[11:7]`. Sign-extended (20 bits).
* **Logic:** `{{20{inst[31]}}, inst[31:25], inst[11:7]}`

### B-Type (Conditional Branch)
* **Target:** `BEQ`, `BNE`, `BLT`, etc.
* **Structure:** Immediate represents a signed offset in multiples of 2 bytes. LSB (bit 0) is always `0`.
* **Logic:** `{{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}`

### U-Type (Upper Immediate)
* **Target:** `LUI`, `AUIPC`.
* **Structure:** 20-bit immediate placed in the upper bits `[31:12]`. Lower 12 bits are zero-filled.
* **Logic:** `{inst[31:12], 12'b0}`

### J-Type (Jump and Link)
* **Target:** `JAL`.
* **Structure:** Signed offset in multiples of 2 bytes. Scrambled bits in instruction.
* **Logic:** `{{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}`

## 4. Design Details
- **Implementation:** Combinational `always @(*)` block with a `case` statement.
- **Pre-assignment:** `immediate` is defaulted to `32'b0` to prevent unintended latches and handle R-type instructions.
- **Sign Extension:** All types (except U-type) utilize bit `inst[31]` for sign extension to maintain 2's complement consistency.

## 5. Bit Mapping Reference (RV32I)