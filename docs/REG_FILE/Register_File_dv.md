# Verification Plan: `register_file`

## 1. Objective
To verify the functional correctness of the RISC-V Register File (RV32I), ensuring it supports dual-port asynchronous reads, single-port synchronous writes, and strict enforcement of the hardwired zero register (x0).

## 2. Critical Functionality Tests

### TC_01: Basic Synchronous Write & Read
* **Description:** Enable `reg_write`, provide a non-zero address to `write_reg` (e.g., `5`), and provide data to `write_data`. Observe the result on the next `posedge clk`.
* **Expected Result:** The data must be stored in the internal array and become visible on the corresponding `read_data` port once the address is requested.

### TC_02: Dual-Port Independent Reads
* **Description:** Write two different values to two different registers (e.g., x1 and x2). Request `read_reg_1 = 1` and `read_reg_2 = 2` simultaneously.
* **Expected Result:** Both `read_data_1` and `read_data_2` must output their respective stored values independently without interference.

### TC_03: Asynchronous Combinatorial Read Timing
* **Description:** Change the addresses `read_reg_1` or `read_reg_2` during the simulation without waiting for a clock edge.
* **Expected Result:** The outputs `read_data_1` and `read_data_2` must update immediately (propagation delay only). This confirms compatibility with the single-cycle ALU execution.

### TC_04: Write Enable (`reg_write`) Validation
* **Description:** Attempt to write a new value to a register while `reg_write` is set to `0`.
* **Expected Result:** The internal register value must remain unchanged despite the `posedge clk`.

---

## 3. Corner Cases & Data Integrity

### TC_05: Register x0 Hardwired Zero (Write Prevention)
* **Description:** Attempt to write a non-zero value (e.g., `32'hFFFF_FFFF`) to `write_reg = 0` with `reg_write = 1`.
* **Expected Result:** The write must be ignored. Internal logic should prevent the value from being stored in the array.

### TC_06: Register x0 Hardwired Zero (Read Forcing)
* **Description:** Set `read_reg_1 = 0` and `read_reg_2 = 0`.
* **Expected Result:** Both `read_data_1` and `read_data_2` must return `32'h0000_0000`, regardless of any previous write attempts or initial uninitialized states.

### TC_07: Read-After-Write (RAW) in Single-Cycle
* **Description:** In the same clock cycle, set `write_reg = 10` and `read_reg_1 = 10`. Pulse the clock.
* **Expected Result:** Since reads are combinatorial and writes are sequential, the output `read_data_1` should show the **old** value before the clock edge and update to the **new** value immediately after the clock edge (or according to the internal array update).

### TC_08: Asynchronous Data Integrity
* **Description:** Change `write_data` or `write_reg` while `clk` is stable (no edge) and `reg_write` is active.
* **Expected Result:** No change should occur in the internal register file. This confirms the design is purely synchronous for write operations.