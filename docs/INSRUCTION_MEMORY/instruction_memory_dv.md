# Verification Plan: `instruction_memory`

## 1. Objective
To verify the functional correctness of the Instruction Memory (ROM) module, ensuring proper initialization via hexadecimal files, correct word-alignment logic, and stable asynchronous data retrieval.

## 2. Critical Functionality Tests

### TC_01: Memory Initialization ($readmemh)
* **Description:** Verify that the system correctly loads the `program.hex` file into the internal memory array at simulation start (Time 0).
* **Expected Result:** The first instructions in the memory array must match the first entries in the hex file exactly.

### TC_02: Asynchronous Combinatorial Read
* **Description:** Change the `addr` input and observe the `instruction` output without a clock edge.
* **Expected Result:** The output must update immediately (combinatorially). This confirms the memory is compatible with a single-cycle data-path.

### TC_03: Word-Alignment Logic (Byte-to-Word)
* **Description:** Apply byte addresses `32'h0`, `32'h1`, `32'h2`, and `32'h3` sequentially.
* **Expected Result:** All four addresses must return the same 32-bit word. This verifies that the internal logic correctly ignores bits `[1:0]` of the address.

### TC_04: Sequential Addressing (PC+4)
* **Description:** Increment the address by 4 for several cycles (e.g., `0, 4, 8, 12`).
* **Expected Result:** The output must display the instructions in the correct sequence as defined in the program file.

---

## 3. Corner Cases & Data Integrity

### TC_05: Boundary Access (Min/Max)
* **Description:** Access the absolute minimum address (`32'h0`) and the absolute maximum address within the 1024-word range (`32'h00000FFC`).
* **Expected Result:** Both addresses must return valid data from the first and last slots of the memory array.

