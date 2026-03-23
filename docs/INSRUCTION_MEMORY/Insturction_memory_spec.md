# Instruction Memory Unit Specification (RV32I)

## 1. Overview
The **Instruction Memory (IMEM)** is a vital component of the RISC-V processor, responsible for storing the machine code (instructions). In this single-cycle design, the IMEM acts as a **ROM** (Read-Only Memory). It provides a 32-bit instruction to the decoder immediately upon receiving an address from the Program Counter (PC).

## 2. Design Hierarchy
The unit is implemented as a standalone module to ensure modularity and ease of software updates:
* **`instruction_memory`**: A dedicated module containing a 2D register array that simulates the memory space. By isolating the memory, we can load different programs (`.hex` files) without modifying the processor's core logic or timing.

## 3. Port Map (Interface)

| Port Name     | Direction | Width | Type  | Description                                                                 |
| :------------ | :-------- | :---- | :---- | :-------------------------------------------------------------------------- |
| `addr`        | Input     | 32    | Wire  | 32-bit byte address provided by the Program Counter (PC).                   |
| `instruction` | Output    | 32    | Reg/Wire | 32-bit RISC-V instruction fetched from the addressed memory location.     |



## 4. Internal Logic & Implementation

### Memory Organization
* **Depth**: 1024 words (equivalent to 4KB of addressable space).
* **Width**: 32-bit words, matching the RV32I standard instruction size.
* **Indexing (Word Alignment)**: The memory is accessed using **word-aligned** addressing. The internal array is indexed using `addr[11:2]`. This logic ignores the 2 least significant bits (byte offset) because RISC-V instructions are 4-byte aligned.

### Read Mechanism
* **Asynchronous Read**: The memory performs a purely combinatorial read operation. There is no clock dependency for fetching instructions. As soon as the `addr` changes, the corresponding `instruction` is driven to the output after a minimal propagation delay. This is a requirement for the single-cycle data-path.



## 5. Initialization Strategy
* **Mechanism**: The module utilizes the built-in Verilog system task **`$readmemh`**.
* **File Source**: Machine code is loaded from an external text file named `program.hex`.
* **Timing**: The loading process occurs exactly once at **Time 0** inside an `initial` block.
* **Storage**: Defined internally as `reg [31:0] mem [0:1023]`.

## 6. Constraints & Limitations
* **Address Range**: Addresses exceeding `1023` (word index) or `4095` (byte address) are out of bounds and will return undefined values.
* **Write Access**: This module does not support write operations. The memory content can only be modified by updating the `program.hex` file prior to simulation.