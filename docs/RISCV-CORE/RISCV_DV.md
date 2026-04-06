# Verification Plan: `riscv_core` (Top-Level Integration)

## 1. Objective
To verify the correct **end-to-end integration** of all sub-modules within the single-cycle RV32I processor.
Since individual units (ALU, Control Unit, Branch Comparator, etc.) are verified separately, this plan focuses on **integration scenarios** — multi-instruction programs that stress the connections between units and validate the full datapath under real execution conditions.

---

## 2. Verification Strategy

### Structure
- **One testbench** (`Riscv_Core_tb.v`) containing all test cases
- **One `.hex` file per test** stored in a `tests/` folder
- Between each test: instruction memory is reloaded and the processor is reset
- Each test checks specific register values after a fixed number of clock cycles

### Pass/Fail Mechanism
The testbench directly reads internal register file state via hierarchical reference:
```verilog
uut.u_register_file.reg_file[N]
```

### Timing
- Clock period: 10ns
- Reset held for 20ns, then deasserted
- Each test runs for enough cycles to complete its program before checking

---

## 3. Test Cases

---

### TC_01: Sequential Data Dependency
**Goal:** Verify that the result of one instruction correctly feeds into the next.
If the register file write and read are not properly timed, this will fail.

**Program:**
```
addi x1, x0, 3     # x1 = 3
add  x2, x1, x1    # x2 = x1 + x1 = 6
addi x3, x2, 10    # x3 = x2 + 10 = 16
```

**Checks:**
| Register | Expected |
|----------|----------|
| x1 | 0x00000003 |
| x2 | 0x00000006 |
| x3 | 0x00000010 |
| x0 | 0x00000000 (never changes) |

---

### TC_02: Memory Store then Load (SW → LW)
**Goal:** Verify the full memory datapath — ALU computes address, data is written to memory, then read back correctly.

**Program:**
```
addi x1, x0, 42    # x1 = 42
sw   x1, 0(x0)     # mem[0] = 42
lw   x2, 0(x0)     # x2 = mem[0] = 42
```

**Checks:**
| Register | Expected |
|----------|----------|
| x1 | 0x0000002A (42) |
| x2 | 0x0000002A (42) — must match x1 |

---

### TC_03: Branch Not Taken
**Goal:** Verify that when branch condition is false, execution continues sequentially (PC = PC+4).

**Program:**
```
addi x1, x0, 5     # x1 = 5
addi x2, x0, 3     # x2 = 3
beq  x1, x2, +8    # condition FALSE (5 != 3) → not taken
addi x3, x0, 1     # must execute → x3 = 1
```

**Checks:**
| Register | Expected | Meaning |
|----------|----------|---------|
| x3 | 0x00000001 | Instruction after branch executed → PC was sequential |

---

### TC_04: Loop (Branch Taken — Backward Jump)
**Goal:** Verify branch taken with a negative offset. Tests the branch comparator result feeding back into the PC correctly over multiple cycles.

**Program:**
```
addi x1, x0, 0     # x1 = 0  (counter)
addi x2, x0, 3     # x2 = 3  (limit)
addi x1, x1, 1     # x1++         ← loop start (PC=8)
bne  x1, x2, -4    # if x1 != 3, jump back to PC=8
addi x3, x0 , -5   # must execute → x3 = -5
```

**Checks:**
| Register | Expected | Meaning |
|----------|----------|---------|
| x1 | 0x00000003 | Loop executed exactly 3 times |
| x2 | 0x00000003 | Unchanged |

---

### TC_05: Function Call (JAL + JALR)
**Goal:** Verify JAL saves correct return address (PC+4) and JALR jumps back to it correctly.

**Program:**
```
PC=0:  jal  x1, +12      # jump to PC=12, save return addr x1=4
PC=4:  addi x2, x0, 50   # executes after return → x2=50
PC=8:  addi x2, x0, 99   # never executes (skipped by loop end)
PC=12: addi x3, x0, 7    # function body → x3=7
PC=16: jalr x0, x1, 0    # return to x1=4
```

**Checks:**
| Register | Expected | Meaning |
|----------|----------|---------|
| x1 | 0x00000004 | Correct return address saved by JAL |
| x3 | 0x00000007 | Function body executed |
| x2 | 0x00000032 | Post-return instruction (PC=4) executed |

---

### TC_06: LUI and AUIPC
**Goal:** Verify upper-immediate instructions. LUI loads a constant, AUIPC adds it to the current PC.

**Program:**
```
PC=0: lui   x1, 0x12345   # x1 = 0x12345000
PC=4: auipc x2, 0x1       # x2 = PC + 0x00001000 = 4 + 0x1000 = 0x00001004
```

**Checks:**
| Register | Expected | Meaning |
|----------|----------|---------|
| x1 | 0x12345000 | Upper 20 bits loaded, lower 12 = 0 |
| x2 | 0x00001004 | PC(=4) + imm(=0x1000) |

---

### TC_07: ALU Overflow and Negative Arithmetic
**Goal:** Verify that arithmetic wraps correctly at 32-bit boundaries and that negative immediates are handled properly.

**Program:**
```
addi x1, x0, -1    # x1 = 0xFFFFFFFF
addi x2, x0, 1     # x2 = 1
add  x3, x1, x2    # x3 = 0xFFFFFFFF + 1 = 0x00000000 (overflow wraps)
sub  x4, x2, x1    # x4 = 1 - 0xFFFFFFFF = 2 (wraps in two's complement)
```

**Checks:**
| Register | Expected | Meaning |
|----------|----------|---------|
| x1 | 0xFFFFFFFF | ADDI sign-extends -1 correctly |
| x3 | 0x00000000 | ADD wraps at 32-bit boundary |
| x4 | 0x00000002 | SUB also wraps correctly |

---

### TC_08: SLT vs SLTU — Signed vs Unsigned Comparison
**Goal:** Verify that SLT treats operands as signed and SLTU treats them as unsigned. With the same bit pattern (MSB set), the two instructions must produce different results.

**Program:**
```
addi x1, x0, -1    # x1 = 0xFFFFFFFF (signed: -1, unsigned: 4294967295)
addi x2, x0, 1     # x2 = 1
slt  x3, x1, x2    # signed: -1 < 1 → x3 = 1
sltu x4, x1, x2    # unsigned: 0xFFFFFFFF > 1 → x4 = 0
```

**Checks:**
| Register | Expected | Meaning |
|----------|----------|---------|
| x3 | 0x00000001 | SLT: -1 is less than 1 (signed) |
| x4 | 0x00000000 | SLTU: 0xFFFFFFFF is NOT less than 1 (unsigned) |

---

### TC_09: Shift Edge Cases (SLL by 31, SRL, SRA Sign Extension)
**Goal:** Verify shifts at boundary amounts (0 and 31) and that SRA fills with the sign bit while SRL fills with zeros.

**Program:**
```
addi x1, x0, 1     # x1 = 1
addi x5, x0, 31    # shift amount = 31
sll  x2, x1, x5    # x2 = 1 << 31 = 0x80000000
addi x3, x0, -1    # x3 = 0xFFFFFFFF
addi x6, x0, 4     # shift amount = 4
sra  x4, x3, x6    # x4 = 0xFFFFFFFF >>> 4 = 0xFFFFFFFF (sign bit fills)
srl  x5, x3, x6    # x5 = 0xFFFFFFFF >> 4  = 0x0FFFFFFF (zero fills)
```

**Checks:**
| Register | Expected | Meaning |
|----------|----------|---------|
| x2 | 0x80000000 | SLL by 31 sets only the MSB |
| x4 | 0xFFFFFFFF | SRA preserves sign (arithmetic shift) |
| x5 | 0x0FFFFFFF | SRL fills with zeros (logical shift) |

---

### TC_10: BEQ Taken (Forward Jump)
**Goal:** Verify that when BEQ condition is true, PC jumps forward and the skipped instruction does NOT execute.

**Program:**
```
addi x1, x0, 5     # x1 = 5
addi x2, x0, 5     # x2 = 5
beq  x1, x2, +8    # condition TRUE → taken, skip next instruction
addi x3, x0, 99    # must NOT execute
addi x3, x0, 1     # must execute → x3 = 1
```

**Checks:**
| Register | Expected | Meaning |
|----------|----------|---------|
| x3 | 0x00000001 | Branch was taken; x3=99 instruction was skipped |

---

### TC_11: BLT and BGE (Signed Branch)
**Goal:** Verify signed comparison branches using negative values where MSB is set.

**Program:**
```
addi x1, x0, -3    # x1 = -3
addi x5, x0, 5     # x5 = 5
blt  x1, x5, +8    # signed: -3 < 5 → taken, skip next
addi x3, x0, 0     # must NOT execute
addi x3, x0, 1     # x3 = 1
bge  x5, x1, +8    # signed: 5 >= -3 → taken, skip next
addi x4, x0, 0     # must NOT execute
addi x4, x0, 1     # x4 = 1
```

**Checks:**
| Register | Expected | Meaning |
|----------|----------|---------|
| x1 | 0xFFFFFFFD | ADDI sign-extends -3 correctly |
| x5 | 0x00000005 | Limit register |
| x3 | 0x00000001 | BLT taken: -3 < 5 (signed) |
| x4 | 0x00000001 | BGE taken: 5 >= -3 (signed) |

---

### TC_12: BLTU and BGEU (Unsigned Branch)
**Goal:** Verify unsigned comparison branches. Uses 0xFFFFFFFF which is negative in signed interpretation but the largest unsigned value — the branch outcome must reflect unsigned semantics.

**Program:**
```
addi x1, x0, 1     # x1 = 1 (small unsigned)
addi x2, x0, -1    # x2 = 0xFFFFFFFF (large unsigned)
bltu x1, x2, +8    # unsigned: 1 < 0xFFFFFFFF → taken
addi x3, x0, 0     # must NOT execute
addi x3, x0, 1     # x3 = 1
bgeu x2, x1, +8    # unsigned: 0xFFFFFFFF >= 1 → taken
addi x4, x0, 0     # must NOT execute
addi x4, x0, 1     # x4 = 1
```

**Checks:**
| Register | Expected | Meaning |
|----------|----------|---------|
| x3 | 0x00000001 | BLTU taken: 1 < 0xFFFFFFFF (unsigned) |
| x4 | 0x00000001 | BGEU taken: 0xFFFFFFFF >= 1 (unsigned) |

---

### TC_13: JALR LSB Clearing
**Goal:** Verify that JALR forces bit 0 of the computed target address to 0, as required by the spec. A target with an odd address must be rounded down to the next even address.

**Program:**
```
PC=0:  addi x1, x0, 9    # x1 = 9 (intentionally odd)
PC=4:  jalr x2, x1, 0    # target = 9 & ~1 = 8; x2 = PC+4 = 8
PC=8:  addi x3, x0, 42   # executes because JALR jumped here → x3 = 42
```

**Checks:**
| Register | Expected | Meaning |
|----------|----------|---------|
| x1 | 0x00000009 | Odd base address |
| x2 | 0x00000008 | Return address = PC+4 correctly saved |
| x3 | 0x0000002A | Jumped to address 8 (LSB of 9 was cleared); 42 = 0x2A |

---

### TC_14: LUI + ADDI — 32-bit Constant Loading
**Goal:** Verify the standard two-instruction sequence for loading a full 32-bit constant. LUI sets bits [31:12] and ADDI adds the lower 12 bits (using a positive lower part to avoid sign-extension compensation).

**Program:**
```
lui  x1, 0xDEADB    # x1 = 0xDEADB000
addi x1, x1, 0x7EF  # x1 = 0xDEADB000 + 0x7EF = 0xDEADB7EF
```

**Checks:**
| Register | Expected | Meaning |
|----------|----------|---------|
| x1 | 0xDEADB7EF | Full 32-bit constant assembled correctly |

---

### TC_15: SW/LW at Non-Zero Address with Negative Offset
**Goal:** Verify that the memory address is computed correctly when using a non-zero base register and a negative immediate offset (sign-extended from 12-bit field).

**Program:**
```
addi x1, x0, 8     # x1 = 8 (base address)
addi x2, x0, 42    # x2 = 42 (data)
sw   x2, 0(x1)     # mem[8] = 42
sw   x2, -4(x1)    # mem[4] = 42  (negative offset)
lw   x3, 0(x1)     # x3 = mem[8] = 42
lw   x4, -4(x1)    # x4 = mem[4] = 42
```

**Checks:**
| Register | Expected | Meaning |
|----------|----------|---------|
| x3 | 0x0000002A | LW from base address correct |
| x4 | 0x0000002A | LW with negative offset sign-extended correctly |

---

## 4. x0 Hardwired Zero (Safety Check)
**Embedded in TC_01** — after all writes, verify `reg_file[0] == 0`.
Any instruction that accidentally targets x0 must not corrupt it.
`JALR x0` in TC_05 and TC_13 provide additional implicit checks.

---

## 5. Test Summary

| TC | Name | Instructions Exercised | Cycles Needed |
|----|------|----------------------|---------------|
| 01 | Sequential Dependency | ADDI, ADD | 3 |
| 02 | Store → Load | ADDI, SW, LW | 3 |
| 03 | Branch Not Taken | ADDI, BEQ (not taken) | 4 |
| 04 | Loop (Branch Taken Backward) | ADDI, BNE | 6+ |
| 05 | Function Call | JAL, JALR, ADDI | 6 |
| 06 | Upper Immediate | LUI, AUIPC | 2 |
| 07 | ALU Overflow & Negative Arithmetic | ADDI, ADD, SUB | 4 |
| 08 | SLT vs SLTU | ADDI, SLT, SLTU | 4 |
| 09 | Shift Edge Cases | ADDI, SLL, SRA, SRL | 7 |
| 10 | BEQ Taken | ADDI, BEQ (taken) | 5 |
| 11 | BLT and BGE | ADDI, BLT, BGE | 8 |
| 12 | BLTU and BGEU | ADDI, BLTU, BGEU | 8 |
| 13 | JALR LSB Clearing | ADDI, JALR, ADDI | 3 |
| 14 | LUI + ADDI 32-bit Constant | LUI, ADDI | 2 |
| 15 | SW/LW Non-Zero Address + Negative Offset | ADDI, SW, LW | 6 |
