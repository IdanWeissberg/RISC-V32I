# Specification: RISC-V RV32I Register File

## 1. Overview
The Register File is a key component of the RISC-V (RV32I) Datapath. It contains 32 general-purpose registers (x0-x31), each 32 bits wide. It supports dual-port asynchronous reads and a single-port synchronous write.

## 2. Interface signals
| Signal Name   | Direction | Width  | Description |
|--------------|-----------|--------|-------------|
| `clk`         | Input     | 1      | System clock (Positive-edge triggered) |
| `reg_write`   | Input     | 1      | Write Enable signal (Active High) |
| `read_reg_1`  | Input     | 5      | Address for Source Register 1 (rs1) |
| `read_reg_2`  | Input     | 5      | Address for Source Register 2 (rs2) |
| `write_reg`   | Input     | 5      | Address for Destination Register (rd) |
| `write_data`  | Input     | 32     | Data to be written to `write_reg` |
| `read_data_1` | Output    | 32     | Content of `read_reg_1` |
| `read_data_2` | Output    | 32     | Content of `read_reg_2` |

## 3. Functional Requirements
1. **Register x0:** Register 0 (zero) must be hardwired to `32'h00000000`. Any attempts to write to x0 shall be ignored, and any read from x0 must always return zero.
2. **Read Operations:** The module must support two simultaneous combinational (asynchronous) reads. Outputs `read_data_1` and `read_data_2` should update immediately when their respective addresses change.
3. **Write Operation:** Writing to the registers must be synchronous (Sequential). Data from `write_data` is stored in `write_reg` on the rising edge of `clk`, provided that `reg_write` is asserted.
4. **Register Storage:** The internal storage consists of 32 registers, each 32-bit wide.

## 4. Timing Characteristics
- **Read Path:** Combinational (Propagation Delay from Address to Data).
- **Write Path:** Sequential (Setup/Hold timing relative to `posedge clk`).

## 5. Implementation Notes
- The design uses **Non-blocking assignments** (`<=`) for the sequential write block.
- The design uses **Blocking assignments** (`=`) or Ternary operators for the combinational read logic.