# Verification Plan: `pc_unit`

## 1. Objective
To verify the functional correctness of the 32-bit Program Counter register, ensuring reliable state management, correct reset behavior, and data integrity across all 32 bits.

## 2. Critical Functionality Tests

### TC_01: Power-On Reset
* **Description:** Apply `rst_n = 0` at the very beginning of the simulation (Time 0).
* **Expected Result:** The `current_pc` output must immediately settle at `32'h00000000`. This ensures the processor starts from a valid reset vector.

### TC_02: Asynchronous Reset Behavior (Mid-Cycle)
* **Description:** Toggle `rst_n` from 1 to 0 in the middle of a clock cycle (when `clk` is stable at '1' or '0').
* **Expected Result:** Since the reset is asynchronous, `current_pc` must drop to `0` immediately upon the falling edge of `rst_n`, without waiting for the next rising edge of the clock.

### TC_03: Basic Synchronous Load
* **Description:** Apply a valid 32-bit address to `next_pc` (e.g., `32'h00000004`) and trigger a rising edge of the clock.
* **Expected Result:** On the `posedge clk`, the value of `current_pc` must update to match `next_pc`.

### TC_04: Reset Recovery
* **Description:** Release the reset (`rst_n = 1`) and provide a new value to `next_pc`.
* **Expected Result:** The module must resume normal operation and correctly sample the input on the first clock edge following the reset release.

---

## 3. Corner Cases & Data Integrity

### TC_05: Full-Range Bit Toggle (32-bit Integrity)
* **Description:** Sequence the input `next_pc` through `32'hAAAAAAAA` followed by `32'h55555555`.
* **Expected Result:** This verifies that every single bit (0 to 31) can transition from 0 to 1 and 1 to 0. It ensures there are no "stuck-at" bits or bus-width mismatches.

### TC_06: Maximum Address Stability
* **Description:** Load the maximum possible 32-bit value (`32'hFFFFFFFF`) into the register.
* **Expected Result:** The register must hold the full 32-bit value without truncation or overflow errors in the output.

### TC_07: Hold & Stability Test
* **Description:** Maintain a constant value on `next_pc` for multiple clock cycles.
* **Expected Result:** `current_pc` must remain perfectly stable at that value. There should be no glitches or unexpected changes between clock cycles.

