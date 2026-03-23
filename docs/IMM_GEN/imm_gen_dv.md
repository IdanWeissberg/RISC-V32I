# Verification Plan: `imm_gen` (Immediate Generator)

## 1. Objective
To verify the functional correctness of the Immediate Generator module, ensuring accurate bit extraction, proper sign extension for 2's complement arithmetic, and correct reconstruction of all RISC-V (RV32I) immediate formats (I, S, B, U, J).

---

## 2. Critical Functionality Tests

### TC_01: I-Type Extraction & Sign Extension
* **Description:** Apply I-type instructions (e.g., `ADDI`, `LW`) with both positive and negative values to verify the 20-bit sign extension.
* **Test Vectors:** * Positive: `32'h0040A283` (LW x5, 4(x1)) -> **Expected:** `32'h00000005`
    * Negative: `32'hFFF0A283` (LW x5, -1(x1)) -> **Expected:** `32'hFFFFFFFF`
* **Result:** Confirms that bit `inst[31]` is correctly replicated to the upper 20 bits.

### TC_02: S-Type Split-Bit Assembly (Store)
* **Description:** Apply a Store instruction (e.g., `SW`) to verify the merging of split immediate fields `inst[31:25]` and `inst[11:7]`.
* **Test Vector:** `32'h0050A223` (SW x5, 4(x1))
* **Expected Result:** `32'h00000004`. 
* **Validation:** Verify that the bits from `rs2` (the data to be stored) are ignored and only the split immediate bits are used.

### TC_03: B-Type Scrambling & Alignment
* **Description:** Apply a Branch instruction (e.g., `BEQ`) to verify the complex bit mapping and the mandatory `1'b0` LSB (multiples of 2 bytes).
* **Test Vector:** `32'h00000463` (BEQ, Offset = +8)
* **Expected Result:** `32'h00000008`.
* **Validation:** Ensure the hardware correctly places `inst[7]` as bit 11 and adds the zero padding at bit 0.

### TC_04: U-Type Upper Placement (LUI/AUIPC)
* **Description:** Apply an `LUI` instruction to verify that the 20-bit immediate is placed in the upper bits `[31:12]`.
* **Test Vector:** `32'h000012B7` (LUI x5, 0x1)
* **Expected Result:** `32'h00001000`.
* **Validation:** Ensure the lower 12 bits are zero-filled (`12'h000`) and no sign extension occurs on the top.

### TC_05: J-Type Long-Range Jump (JAL)
* **Description:** Apply a `JAL` instruction to verify the 21-bit reconstruction (scrambled bits `[31, 19:12, 20, 30:21]`).
* **Test Vector:** `32'h00C000EF` (JAL, Offset = +12)
* **Expected Result:** `32'h0000000C`.
* **Validation:** Verify that the maximum negative and positive jumps work correctly within the 21-bit range.

---

## 3. Corner Cases & Data Integrity

### TC_06: Sign-Bit Boundary (Positive/Negative Flip)
* **Description:** Apply instructions at the exact boundary of the 12-bit immediate range.
    * **Boundary Positive:** `12'h7FF` (2047) 
    * **Boundary Negative:** `12'h800` (-2048)
* **Expected Result:** * For `7FF`: Output must be `32'h000007FF` (Upper bits are 0).
    * For `800`: Output must be `32'hFFFFF800` (Upper bits are 1).

### TC_07: R-Type Instruction (Isolation Test)
* **Description:** Apply an R-type instruction (e.g., `ADD x5, x6, x7` -> `32'h007302B3`).
* **Expected Result:** `32'h00000000`.
* **Validation:** Ensures that the `imm_gen` correctly defaults to zero for instructions that do not contain an immediate, preventing "ghost" values in the ALU.

