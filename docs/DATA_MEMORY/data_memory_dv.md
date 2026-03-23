# Verification Plan: `data_mem` (Directed Testing)

## 1. Objective
To verify the functional correctness of the Data Memory RTL model using directed tests. The focus is on verifying hardcoded initialization, combinatorial read operations, synchronous write operations, and correct byte-to-word address translation.

## 2. Test Cases

### TC_01: Initialization & Combinatorial Read
* **Description:** Assert `mem_read = 1` and apply byte addresses `0`, `4`, `8`, `12`, and `16` consecutively, without generating a clock edge.
* **Expected Result:** `read_data` must update immediately (combinatorially) to `0`, `1`, `2`, `3`` respectively, verifying both the `initial` block and the read logic.

### TC_02: Disabled Read Behavior
* **Description:** Set `mem_read = 0` while applying valid addresses to `add_in`.
* **Expected Result:** `read_data` must strictly output `32'b0` regardless of the address or the contents of the memory.

### TC_03: Synchronous Write Operation
* **Description:** Apply a specific address (e.g., `32'h00000014`), provide `write_data` (e.g., `32'hDEADBEEF`), set `mem_write = 1`, and trigger a `posedge clk`. 
* **Expected Result:** The data must be successfully written to the internal memory array `d_mem` at the correct word index.

### TC_04: Write Enable Isolation (Disabled Write)
* **Description:** Apply a new `write_data` to a known address, but keep `mem_write = 0`. Trigger a `posedge clk`.
* **Expected Result:** The memory array `d_mem` must retain its previous value and not be overwritten. 
