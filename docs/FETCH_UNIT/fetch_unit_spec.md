# Instruction Fetch Unit Specification (RV32I)

## 1. Overview
The **Fetch Unit** is the primary stage of the single-cycle RISC-V processor. Its role is to manage the **Program Counter (PC)** and determine the address of the next instruction to be fetched from memory. It ensures that the processor flows sequentially through code or jumps to specific targets when commanded by the control logic.

## 2. Design Hierarchy
The design is partitioned into two distinct modules to improve code organization and enhance **Verification Monitoring**:

* **`pc_unit`**: A dedicated 32-bit register module. By isolating the PC as a standalone component, we can easily probe and monitor the architectural state of the processor during simulation. This separation allows for cleaner verification without the interference of the surrounding combinatorial logic.
* **`fetch_unit`**: The top-level wrapper for the fetch stage. It contains the combinatorial logic for address calculation and steering (Mux and Adder), instantiating the `pc_unit` within it.

## 3. Port Map (Interface)

### `fetch_unit` Ports
| Port Name  | Direction | Width | Type  | Description                                                                 |
| :--------- | :-------- | :---- | :---- | :-------------------------------------------------------------------------- |
| `clk`      | Input     | 1     | Wire  | Global System Clock (Rising edge triggered).                                |
| `rst_n`    | Input     | 1     | Wire  | **Active-Low** Asynchronous Reset. Sets PC to `0x00000000`.                 |
| `pc_sel`   | Input     | 1     | Wire  | Control signal: `0` for Sequential ($PC+4$), `1` for Jump/Branch (`jump_add`). |
| `jump_add` | Input     | 32    | Wire  | Target address provided by the Execution/Branch logic.                      |
| `pc_out`   | Output    | 32    | Wire  | Current Program Counter value (Address to Instruction Memory).              |

## 4. Internal Logic & Implementation

### Address Calculation
The unit implements a combinatorial path to determine the next PC value:
1. **Sequential Path (`pc_plus_4`)**: An internal adder increments the current `pc_out` by 4 bytes. This aligns with the RISC-V RV32I standard where all instructions are 32-bit (4-byte) aligned.
2. **Steering Logic (Mux)**: A 2-to-1 Multiplexer uses `pc_sel` to decide whether the next address (`pc_next`) will be the sequential increment(currunt pc + 4 ) or the provided jump target.


### Reset Strategy (`rst_n`)
The design utilizes an **Active-Low Asynchronous Reset**. This decision is based on industry standards for several technical reasons:
* **Noise Immunity**: Active-low signals are more robust against positive voltage spikes and noise, which are more common in digital circuits.
* **Safe Power-up State**: Using a pull-up resistor on the reset line ensures the system stays in a known reset state until the power rails are stable.
* **Component Compatibility**: Most standard-cell libraries and memory IP blocks are optimized for active-low reset signals.

## 5. Synchronization & Timing
* **State Update**: The PC register (`pc_unit`) samples the calculated `pc_next` only on the **rising edge** of the clock.
* **Combinatorial Path**: In this single-cycle design, the calculation of `pc_plus_4` and the Mux selection must stabilize within one clock period to ensure the correct value is ready for the next clock edge.