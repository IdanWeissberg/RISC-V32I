# Verification Plan: Branch Comparator (RV32I)

## 1. Goal
To verify that the `branch_comparator` correctly evaluates all six conditional branch types defined in the RV32I ISA, handling both signed and unsigned 32-bit integer comparisons across boundary conditions.

## 2. Test Strategy
The unit is verified using a **Direct Testbench** (`branch_comparator_tb`). Each test case drives `rs1`, `rs2`, and a mock `instruction` word (constructed via concatenation) to validate the `branch_decision` output.

## 3. Test Cases & Coverage

### 3.1 Basic Equality
* **BEQ (Equal):** Verified with identical positive values. Expected: `1`.
* **BEQ (Not Equal):** Verified with different positive values. Expected: `0`.
* **BNE (Not Equal):** Verified with different values. Expected: `1`.

### 3.2 Signed Comparisons (Corner Cases)
* **BLT/BGE (Positive vs. Positive):** Standard integer comparison.
* **BLT (Negative vs. Positive):** `32'hFFFF_FFFF` (-1) vs `32'h0000_0001`. Verified that `$signed` casting correctly identifies -1 as the smaller value.
* **BGE (Negative vs. Negative):** Verified equality and order with Two's Complement values.
* **Boundary Test:** Max Positive (`32'h7FFFFFFF`) vs Min Negative (`32'h80000000`).

### 3.3 Unsigned Comparisons (Corner Cases)
* **BLTU/BGEU (MSB Check):** `32'hFFFF_FFFF` is treated as a very large unsigned number ($2^{32}-1$).
* **Test Case:** `0xFFFFFFFF < 0x00000001`. Expected: `0` (False).
* **Test Case:** `0x00000001 < 0xFFFFFFFF`. Expected: `1` (True).

## 4. Pass/Fail Criteria
* Each `branch_decision` must stabilize within 1ns of input change (combinatorial).
* All tests must match the expected Boolean result.
* The `default` case must be exercised to ensure `branch_decision = 0` for non-branch instructions.