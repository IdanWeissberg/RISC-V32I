# Verification Plan: `fetch_unit` (Integration Test)

## 1. Objective
To verify the integrated logic of the Fetch Stage, ensuring correct Program Counter (PC) updates, proper addition of the offset (+4), and accurate selection between sequential execution and jump/branch targets.

## 2. Critical Functionality Tests

### TC_01: System Reset (Global)
* **Description:** Assert `rst_n = 0` while `pc_sel = 1` and `jump_add` is a non-zero value.
* **Expected Result:** `current_pc` must settle at `32'h00000000`. This proves that Reset has the highest priority over the Mux selection.

### TC_02: Sequential Execution (PC + 4)
* **Description:** Set `pc_sel = 0` and allow the clock to run for 5 consecutive cycles.
* **Expected Result:** The `current_pc` should increment by 4 in every cycle: `0 -> 4 -> 8 -> C -> 10`. This verifies the Adder and the feedback loop.

### TC_03: Jump/Branch Selection
* **Description:** Set `jump_add = 32'h12345678` and toggle `pc_sel = 1` for one clock cycle.
* **Expected Result:** On the next `posedge clk`, `current_pc` must update to `32'h12345678`, ignoring the Adder's value.

### TC_04: Return to Sequential Flow
* **Description:** Immediately after a jump (TC_03), set `pc_sel = 0`.
* **Expected Result:** The PC should resume incrementing from the jump target: `32'h12345678 -> 32'h1234567C -> 32'h12345680`.

---

## 3. Corner Cases & Robustness

### TC_05: Mid-Cycle Jump Target Change
* **Description:** Set `pc_sel = 1` and change the `jump_add` value multiple times within a single clock period.
* **Expected Result:** The `current_pc` must only capture the value that was stable at the moment of the rising clock edge (Setup/Hold integrity).

### TC_06: PC Overflow (Roll-over)
* **Description:** Force the PC to `32'hFFFFFFFC` and set `pc_sel = 0`.
* **Expected Result:** On the next clock edge, the PC should wrap around to `32'h00000000` (assuming 32-bit adder wrap-around).

### TC_07: Back-to-Back Jumps
* **Description:** Apply different `jump_add` values with `pc_sel = 1` for 3 consecutive cycles.
* **Expected Result:** The PC should update to a new jump target every cycle, never performing a `+4` increment during this window.