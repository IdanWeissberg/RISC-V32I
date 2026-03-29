module  riscv_core(
    input wire  clk,                  // System clock
    input wire rst_n                  // Active-low async reset
);
//Instrction Fetch
wire [31:0] fetch_to_imem;            // Current PC → instruction memory address
wire [31:0] i_mem_to_decode;          // Fetched instruction (32-bit)
wire [31:0]read_data_1_to_alu;        // Register rs1 value → ALU operand A
wire [31:0] read_data_2_c ;           // Register rs2 value → ALU operand B or store data
wire [31:0] alu_res_to_d_mem;         // ALU result → data memory address or writeback
wire branch_decision_c;                          // ALU zero flag (1 when result==0, used for branches)
wire [31:0] d_mem_to_alu_mem_to_reg;  // Data memory read output → writeback mux
// all the control lines
wire mem_read_c,branch_c,mem_write_c,alu_src_c,reg_write_c,lui_c; // control lines
wire [1:0] mem_to_reg_c;              // Writeback select: 00=ALU, 01=MEM, 10=PC+4 (JAL)
wire [1:0] alu_op_c;                  // ALU operation group from control unit
wire [3:0] alu_control_to_alu;        // Final 4-bit ALU operation code
wire [1:0] pc_sel_c;                        // PC select: 0=PC+4, 1=jump address
wire [31:0] alu_mem_to_reg;           // Writeback data selected by mem_to_reg mux
wire [31:0] jump_add_c;               // Branch/jump target = PC + immediate
wire [31:0] alu_src_mux ;             // ALU second operand after mux (rs2 or immediate)
wire [31:0] imm_gen_to_alu_mux;       // Sign-extended immediate from instruction
wire jal_or_branch_c;                 // CU output: 1=conditional branch, 0=unconditional JAL
wire [31:0] pc_plus_4_c;             // PC+4 value from fetch unit → JAL return address writeback
wire jal_branch_mux_c ,jalr_c;
assign jal_branch_mux_c=(jal_or_branch_c)? branch_decision_c : 1'b1; // Branch: use zero flag; JAL: always 1
assign pc_sel_c={jal_branch_mux_c & branch_c,jalr_c};    // Take jump only when branch signal and condition both active
assign jump_add_c = fetch_to_imem + imm_gen_to_alu_mux;    // Compute branch/jump target address
always @(*) begin
    case (mem_to_reg_c)
        2'b00: alu_mem_to_reg = alu_res_to_d_mem;        // R-type / I-type: write ALU result
        2'b01: alu_mem_to_reg = d_mem_to_alu_mem_to_reg; // Load: write memory data
        2'b10: alu_mem_to_reg = pc_plus_4_c;             // JAL: write return address (PC+4)
        2'b11: alu_mem_to_reg = jump_add_c;
        default: alu_mem_to_reg = alu_res_to_d_mem;      // Default: ALU result
    endcase

end
fetch_unit u_fetch_unit(
    .clk (clk),
    .rst_n (rst_n),
    .pc_out (fetch_to_imem),          // Current PC output
    .pc_sel (pc_sel_c),               // 0=sequential, 1=jump
    .jump_add (jump_add_c),            // Target address for branch/jump
    .pc_plus_4 (pc_plus_4_c),         // PC+4 output for JAL return address
    .alu_res (alu_res_to_d_mem)
);
instruction_memory u_instruction_memory (
    .addr (fetch_to_imem),            // PC as instruction address
    .instruction (i_mem_to_decode)    // 32-bit instruction output
);
branch_comparator u_branch_comparator(
    .rs_1 (read_data_1_to_alu),
    .rs_2 (read_data_2_c),
    .instruction (i_mem_to_decode),
    .branch_decision (branch_decision_c  )
);
control_unit u_control_unit(
    .op_code (i_mem_to_decode[6:0]),  // Instruction opcode bits [6:0]
    .mem_read (mem_read_c),           // 1 = load instruction
    .branch (branch_c),               // 1 = branch or jump instruction
    .mem_to_reg (mem_to_reg_c),       // Writeback source select (2-bit)
    .mem_write (mem_write_c),         // 1 = store instruction
    .alu_src (alu_src_c),             // 1 = use immediate, 0 = use rs2
    .reg_write (reg_write_c),         // 1 = write result to register file
    .alu_op (alu_op_c),               // ALU operation group (2-bit)
    .jal_branch_mux (jal_or_branch_c), // 1 = conditional branch, 0 = JAL
    .jalr (jalr_c),
    .lui (lui_c)
);
register_file u_register_file(
    .clk (clk),
    .reg_write (reg_write_c),         // Write enable
    .read_reg_1 (i_mem_to_decode[19:15]), // rs1 index from instruction
    .read_reg_2 (i_mem_to_decode[24:20]), // rs2 index from instruction
    .write_reg (i_mem_to_decode[11:7]),   // rd index from instruction
    .read_data_1 (read_data_1_to_alu),    // rs1 value output
    .read_data_2 (read_data_2_c),         // rs2 value output
    .write_data (alu_mem_to_reg)          // Data to write into rd
);
alu_control u_alu_control (
    .alu_op (alu_op_c),               // Operation group from control unit
    .funct_3 (i_mem_to_decode[14:12]),// funct3 field from instruction
    .funct_7 (i_mem_to_decode[31:25]),// funct7 field from instruction
    .lui (lui_c),                     // LUI pass-through override
    .alu_op_output (alu_control_to_alu)// 4-bit ALU control signal
);
imm_gen u_imm_gen(
    .immediate (imm_gen_to_alu_mux),  // Sign-extended immediate output
    .instruction (i_mem_to_decode)    // Full instruction input
);
assign alu_src_mux= (alu_src_c)? imm_gen_to_alu_mux : read_data_2_c; // ALU B operand: immediate or rs2
alu_unit u_alu_unit(
    .alu_op_in (alu_control_to_alu),  // 4-bit operation select
    .alu_mux (alu_src_mux),           // Operand B (rs2 or immediate)
    .read_data_1 (read_data_1_to_alu),// Operand A (rs1)
    .alu_result (alu_res_to_d_mem)    // Result output
);
data_mem u_data_memory(
    .clk (clk),
    .add_in (alu_res_to_d_mem),       // Memory address from ALU result
    .write_data (read_data_2_c),      // Store data from rs2
    .mem_write (mem_write_c),         // Write enable (SW)
    .mem_read (mem_read_c),           // Read enable (LW)
    .read_data (d_mem_to_alu_mem_to_reg) // Loaded data output
);

endmodule