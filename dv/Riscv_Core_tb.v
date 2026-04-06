`timescale 1ns/1ps
module riscv_core_tb ();
reg clk_tb;                    // Clock signal for synchronization
reg rst_n_tb;                 // Reset signal to initialize the core
riscv_core uut(                // Instantiate Unit Under Test
    .clk(clk_tb),
    .rst_n(rst_n_tb)
);
// ──────────────────────────────────────────────────────────────────
// Waveform Probes — critical signals only
// ──────────────────────────────────────────────────────────────────
wire [31:0] probe_PC              = uut.fetch_to_imem;          // Current PC
wire [31:0] probe_instruction     = uut.i_mem_to_decode;        // Raw instruction word
wire  [1:0] probe_pc_sel          = uut.pc_sel_c;               // Next-PC decision (00=+4, 01=JALR, 10=branch/JAL)
wire [31:0] probe_alu_result      = uut.alu_res_to_d_mem;       // ALU output (also memory address)
wire        probe_branch_decision = uut.branch_decision_c;      // Branch condition result
wire        probe_reg_write       = uut.reg_write_c;            // Register file write enable
wire [31:0] probe_wb_data         = uut.alu_mem_to_reg;         // Value written to rd
wire        probe_mem_read        = uut.mem_read_c;             // Load active
wire        probe_mem_write       = uut.mem_write_c;            // Store active
wire [31:0] probe_mem_rdata       = uut.d_mem_to_alu_mem_to_reg; // Data loaded from memory
wire [31:0] probe_immiediate      = uut.imm_gen_to_alu_mux;       // Immediate value generated from instruction
// ──────────────────────────────────────────────────────────────────
integer error_count;            // Counter to track number of failed tests
task reset;
begin
    rst_n_tb = 0;              // Assert reset (active low)
    #20;                      // Hold reset for 20ns
    rst_n_tb = 1;             // Deassert reset to start the core
end
endtask
task check_registers(input [4:0] reg_num, input [31:0] expected_value,input [12*20:1] test_name);
begin
    @(posedge clk_tb) ;          // Wait for the next clock edge to allow core to execute instructions
    #1;
    if(uut.u_register_file.reg_file[reg_num] === expected_value)
        $display("PASS: %s - Register x%0d correctly updated to 0x%08X", test_name, reg_num, expected_value);
    else begin
        $display("FAIL: %s - Register x%0d expected 0x%08X, got 0x%08X", test_name, reg_num, expected_value, uut.u_register_file.reg_file[reg_num]);
        error_count = error_count + 1;
    end
end
endtask
initial begin
    clk_tb = 0;                // Initialize clock
    forever #5 clk_tb = ~clk_tb; // Toggle clock every 5ns (10ns period)
end

initial begin
    error_count = 0;            // Initialize error count
    $display("==============================================");
    $display("  RISCV Core Testbench Starting");
    $display("==============================================");

    // TC_01: Sequential Data Dependency
    $display("\n --- TC_01: Sequential Data Dependency STARTED ---");
    reset();
    $readmemh("test_programs/program_01.hex", uut.u_instruction_memory.mem);
    check_registers(0001, 32'h00000003, "TC_01: ADDI x1, x0, 3");     // Check if x1 = 3 after ADDI
    check_registers(0002, 32'h00000006, "TC_01: ADD x2, x1, x1");     // Check if x2 = 6 after ADD
    check_registers(0003, 32'h00000010, "TC_01: ADDI x3, x2, 10");    // Check if x3 = 16 after ADDI
    $display("--- TC_01: Sequential Data Dependency DONE ---");

    // TC_02: Memory Store then Load (SW → LW)
    $display("\n--- TC_02: Memory Store then Load (SW -> LW) STARTED ---");
    reset();
    $readmemh("test_programs/program_02.hex", uut.u_instruction_memory.mem);
    check_registers(0001, 32'h0000002A, "TC_02: ADDI x1, x0, 42");    // Check if x1 = 42 after ADDI
    @(posedge clk_tb) ;        // Wait for SW to write 42 to memory[0]
    #1;
    check_registers(0002, 32'h0000002A, "TC_02: LW x2, 0(x0)");       // Check if x2 = 42 after LW
    $display("--- TC_02: Memory Store then Load (SW -> LW) DONE ---");

    // TC_03: Branch Not Taken
    $display("\n--- TC_03: Branch Not Taken STARTED ---");
    reset();
    $readmemh("test_programs/program_03.hex", uut.u_instruction_memory.mem);
    check_registers(0001, 32'h00000005, "TC_03: ADDI x1, x0, 5");     // Check if x1 = 5 after ADDI
    check_registers(0002, 32'h00000003, "TC_03: ADDI x2, x0, 3");     // Check if x2 = 3 after ADDI
    @(posedge clk_tb);         // Wait for BEQ to not-take the branch
    #1;
    check_registers(0003, 32'h00000001, "TC_03: ADDI x3, x0, 1");     // Check if x3 = 1 (executed, not skipped)
    $display("--- TC_03: Branch Not Taken DONE ---");

    // TC_04: Loop (Branch Taken — Backward Jump)
    $display("\n--- TC_04: Loop (Branch Taken - Backward Jump) STARTED ---");
    reset();
    $readmemh("test_programs/program_04.hex", uut.u_instruction_memory.mem);
    check_registers(0001, 32'h00000000, "TC_04: ADDI x1, x0, 0");     // Check if x1 = 0 after ADDI
    check_registers(0002, 32'h00000003, "TC_04: ADDI x2, x0, 3");     // Check if x2 = 3 after ADDI
    check_registers(0001, 32'h00000001, "TC_04: ADDI x1, x1, 1");     // Check if x1 = 1 after first loop iteration
    @(posedge clk_tb);
    #1;
    check_registers(0001, 32'h00000002, "TC_04: ADDI x1, x1, 1");     // Check if x1 = 2 after second loop iteration
    @(posedge clk_tb);
    #1;
    check_registers(0001, 32'h00000003, "TC_04: ADDI x1, x1, 1");     // Check if x1 = 3 after third loop iteration
    @(posedge clk_tb);
    #1;
    check_registers(0003, 32'hFFFFFFFB, "TC_04: ADDI x3, x0, -5");    // Check if x3 = -5 after loop exits
    $display("--- TC_04: Loop (Branch Taken - Backward Jump) DONE ---");

    // TC_05: Function Call (JAL + JALR)
    $display("\n--- TC_05: Function Call (JAL + JALR) STARTED ---");
    reset();
    $readmemh("test_programs/program_05.hex", uut.u_instruction_memory.mem);
    check_registers(0001, 32'h00000004, "TC_05: JAL x1, +12");                                           // Check if x1 = 4 (PC+4) after JAL
    check_registers(0003, 32'h00000007, "TC_05: ADDI x3, x0, 7");                                        // Check if x3 = 7 (function body executed)
    @(posedge clk_tb);
    #1;
    check_registers(0002, 32'h00000032, "TC_05: ADDI x2, x0, 50 (executed after JALR return to PC=4)");  // Check if x2 = 50 after return
    $display("--- TC_05: Function Call (JAL + JALR) DONE ---");

    // TC_06: LUI and AUIPC
    $display("\n--- TC_06: LUI and AUIPC STARTED ---");
    reset();
    $readmemh("test_programs/program_06.hex", uut.u_instruction_memory.mem);
    check_registers(0001, 32'h12345000, "TC_06: LUI x1, 0x12345");    // Check if x1 = 0x12345000 after LUI
    check_registers(0002, 32'h00001004, "TC_06: AUIPC x2, 0x1");      // Check if x2 = 0x00001004 (PC=4 + 0x1000) after AUIPC
    $display("--- TC_06: LUI and AUIPC DONE ---");

    // TC_07: ALU Overflow and Negative Arithmetic
    $display("\n--- TC_07: ALU Overflow and Negative Arithmetic STARTED ---");
    reset();
    $readmemh("test_programs/program_07.hex", uut.u_instruction_memory.mem);
    check_registers(0001, 32'hFFFFFFFF, "TC_07: ADDI x1, x0, -1");    // Check if x1 = 0xFFFFFFFF after ADDI
    check_registers(0002, 32'h00000001, "TC_07: ADDI x2, x0, 1");     // Check if x2 = 1 after ADDI
    check_registers(0003, 32'h00000000, "TC_07: ADD x3, x1, x2");     // Check if x3 = 0 (overflow wrap)
    check_registers(0004, 32'h00000002, "TC_07: SUB x4, x2, x1");     // Check if x4 = 2 (two's complement wrap)
    $display("--- TC_07: ALU Overflow and Negative Arithmetic DONE ---");

    // TC_08: SLT vs SLTU — Signed vs Unsigned Comparison
    $display("\n--- TC_08: SLT vs SLTU (Signed vs Unsigned) STARTED ---");
    reset();
    $readmemh("test_programs/program_08.hex", uut.u_instruction_memory.mem);
    check_registers(0001, 32'hFFFFFFFF, "TC_08: ADDI x1, x0, -1");    // Check if x1 = 0xFFFFFFFF after ADDI
    check_registers(0002, 32'h00000001, "TC_08: ADDI x2, x0, 1");     // Check if x2 = 1 after ADDI
    check_registers(0003, 32'h00000001, "TC_08: SLT x3, x1, x2");     // Check if x3 = 1 (signed: -1 < 1)
    check_registers(0004, 32'h00000000, "TC_08: SLTU x4, x1, x2");    // Check if x4 = 0 (unsigned: 0xFFFFFFFF > 1)
    $display("--- TC_08: SLT vs SLTU (Signed vs Unsigned) DONE ---");

    // TC_09: Shift Edge Cases (SLL by 31, SRL, SRA Sign Extension)
    $display("\n--- TC_09: Shift Edge Cases STARTED ---");
    reset();
    $readmemh("test_programs/program_09.hex", uut.u_instruction_memory.mem);
    check_registers(0001, 32'h00000001, "TC_09: ADDI x1, x0, 1");     // Check if x1 = 1 after ADDI
    check_registers(0005, 32'h0000001F, "TC_09: ADDI x5, x0, 31");    // Check if x5 = 31 (shift amount)
    check_registers(0002, 32'h80000000, "TC_09: SLL x2, x1, x5");     // Check if x2 = 0x80000000 (1 << 31)
    check_registers(0003, 32'hFFFFFFFF, "TC_09: ADDI x3, x0, -1");    // Check if x3 = 0xFFFFFFFF after ADDI
    check_registers(0006, 32'h00000004, "TC_09: ADDI x6, x0, 4");     // Check if x6 = 4 (shift amount)
    check_registers(0004, 32'hFFFFFFFF, "TC_09: SRA x4, x3, x6");     // Check if x4 = 0xFFFFFFFF (arithmetic shift, sign fills)
    check_registers(0005, 32'h0FFFFFFF, "TC_09: SRL x5, x3, x6");     // Check if x5 = 0x0FFFFFFF (logical shift, zero fills)
    $display("--- TC_09: Shift Edge Cases DONE ---");

    // TC_10: BEQ Taken (Forward Jump)
    $display("\n--- TC_10: BEQ Taken (Forward Jump) STARTED ---");
    reset();
    $readmemh("test_programs/program_10.hex", uut.u_instruction_memory.mem);
    check_registers(0001, 32'h00000005, "TC_10: ADDI x1, x0, 5");     // Check if x1 = 5 after ADDI
    check_registers(0002, 32'h00000005, "TC_10: ADDI x2, x0, 5");     // Check if x2 = 5 after ADDI
    @(posedge clk_tb);         // Wait for BEQ to take the branch
    #1;
    check_registers(0003, 32'h00000001, "TC_10: ADDI x3, x0, 1");     // Check if x3 = 1 (x3=99 was skipped)
    $display("--- TC_10: BEQ Taken (Forward Jump) DONE ---");

    // TC_11: BLT and BGE (Signed Branch)
    $display("\n--- TC_11: BLT and BGE (Signed Branch) STARTED ---");
    reset();
    $readmemh("test_programs/program_11.hex", uut.u_instruction_memory.mem);
    check_registers(0001, 32'hFFFFFFFD, "TC_11: ADDI x1, x0, -3");    // Check if x1 = -3 after ADDI
    check_registers(0002, 32'h00000005, "TC_11: ADDI x2, x0, 5");     // Check if x2 = 5 after ADDI
    $display($time);
    @(posedge clk_tb);         // Wait for BLT to take the branch
    #1;
    check_registers(0003, 32'h00000001, "TC_11: ADDI x3, x0, 1");     // Check if x3 = 1 (BLT taken: -3 < 5)
    @(posedge clk_tb);         // Wait for BGE to take the branch
    #1;
    check_registers(0004, 32'h00000001, "TC_11: ADDI x4, x0, 1");     // Check if x4 = 1 (BGE taken: 5 >= -3)
    $display("--- TC_11: BLT and BGE (Signed Branch) DONE ---");

    // TC_12: BLTU and BGEU (Unsigned Branch)
    $display("\n--- TC_12: BLTU and BGEU (Unsigned Branch) STARTED ---");
    reset();
    $readmemh("test_programs/program_12.hex", uut.u_instruction_memory.mem);
    check_registers(0001, 32'h00000001, "TC_12: ADDI x1, x0, 1");     // Check if x1 = 1 after ADDI
    check_registers(0002, 32'hFFFFFFFF, "TC_12: ADDI x2, x0, -1");    // Check if x2 = 0xFFFFFFFF after ADDI
    @(posedge clk_tb);         // Wait for BLTU to take the branch
    #1;
    check_registers(0003, 32'h00000001, "TC_12: ADDI x3, x0, 1");     // Check if x3 = 1 (BLTU taken: 1 < 0xFFFFFFFF unsigned)
    @(posedge clk_tb);         // Wait for BGEU to take the branch
    #1;
    check_registers(0004, 32'h00000001, "TC_12: ADDI x4, x0, 1");     // Check if x4 = 1 (BGEU taken: 0xFFFFFFFF >= 1 unsigned)
    $display("--- TC_12: BLTU and BGEU (Unsigned Branch) DONE ---");

    // TC_13: JALR LSB Clearing
    $display("\n--- TC_13: JALR LSB Clearing STARTED ---");
    reset();
    $readmemh("test_programs/program_13.hex", uut.u_instruction_memory.mem);
    check_registers(0001, 32'h00000009, "TC_13: ADDI x1, x0, 9");     // Check if x1 = 9 (odd, intentional)
    check_registers(0002, 32'h00000008, "TC_13: JALR x2, 0(x1)");     // Check if x2 = 8 (return addr = PC+4; LSB of 9 cleared → jumped to 8)
    check_registers(0003, 32'h0000002A, "TC_13: ADDI x3, x0, 42");    // Check if x3 = 42 (instruction at PC=8 executed)
    $display("--- TC_13: JALR LSB Clearing DONE ---");

    // TC_14: LUI + ADDI — 32-bit Constant Loading
    $display("\n--- TC_14: LUI + ADDI 32-bit Constant Loading STARTED ---");
    reset();
    $readmemh("test_programs/program_14.hex", uut.u_instruction_memory.mem);
    check_registers(0001, 32'hDEADB000, "TC_14: LUI x1, 0xDEADB");        // Check if x1 = 0xDEADB000 after LUI
    check_registers(0001, 32'hDEADB7EF, "TC_14: ADDI x1, x1, 0x7EF");    // Check if x1 = 0xDEADB7EF after ADDI
    $display("--- TC_14: LUI + ADDI 32-bit Constant Loading DONE ---");

    // TC_15: SW/LW at Non-Zero Address with Negative Offset
    $display("\n--- TC_15: SW/LW Non-Zero Address and Negative Offset STARTED ---");
    reset();
    $readmemh("test_programs/program_15.hex", uut.u_instruction_memory.mem);
    check_registers(0001, 32'h00000008, "TC_15: ADDI x1, x0, 8");     // Check if x1 = 8 after ADDI
    check_registers(0002, 32'h0000002A, "TC_15: ADDI x2, x0, 42");    // Check if x2 = 42 after ADDI
    @(posedge clk_tb);         // Wait for SW x2, 0(x1) → mem[8] = 42
    #1;
    @(posedge clk_tb);         // Wait for SW x2, -4(x1) → mem[4] = 42
    #1;
    check_registers(0003, 32'h0000002A, "TC_15: LW x3, 0(x1)");       // Check if x3 = 42 (loaded from mem[8])
    check_registers(0004, 32'h0000002A, "TC_15: LW x4, -4(x1)");      // Check if x4 = 42 (loaded from mem[4] via negative offset)
    $display("--- TC_15: SW/LW Non-Zero Address and Negative Offset DONE ---");

    $display("\n==============================================");
    $display("  Testbench completed with %0d errors", error_count);
    $display("==============================================");
    $finish;
end
endmodule
