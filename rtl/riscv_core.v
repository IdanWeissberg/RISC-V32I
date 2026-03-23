module  riscv_core(
    input wire  clk,
    input wire rst_n
);
//Instrction Fetch
wire [31:0] fetch_to_imem;//fetch to I mem 
wire [31:0] i_mem_to_decode;// instruction
wire [31:0]read_data_1_to_alu;
wire [31:0] read_data_2_c ;
wire [31:0] alu_res_to_d_mem;
wire zero_c;
wire [31:0] d_mem_to_alu_mem_to_reg;
// all the control lines
wire mem_read_c,branch_c,mem_to_reg_c,mem_write_c,alu_src_c,reg_write_c;//control line
wire [1:0] alu_op_c;//control line
wire [3:0] alu_control_to_alu;//alu control line
wire pc_sel_c;
wire [31:0] alu_mem_to_reg;
wire [31:0] jump_add_c;
wire [31:0] alu_src_mux ;
assign pc_sel_c=(zero_c & branch_c);
assign alu_mem_to_reg=(mem_to_reg_c)?d_mem_to_alu_mem_to_reg:alu_res_to_d_mem;
assign jump_add_c=fetch_to_imem + i_mem_to_decode[31:0];
fetch_unit u_fetch_unit(
    .clk (clk),
    .rst_n (rst_n),
    .pc_out (fetch_to_imem),
    .pc_sel (pc_sel_c),
    .jump_add (jump_add_c)
);
instruction_memory u_instruction_memory (
    .addr (fetch_to_imem),
    .instruction (i_mem_to_decode)
);
control_unit u_control_unit(
    .op_code (i_mem_to_decode[6:0]),
    .mem_read (mem_read_c),
    .branch (branch_c),
    .mem_to_reg (mem_to_reg_c),
    .mem_write (mem_write_c),
    .alu_src (alu_src_c),
    .reg_write (reg_write_c),
    .alu_op (alu_op_c)
);
register_file u_register_file(
    .clk (clk),
    .reg_write (reg_write_c),
    .read_reg_1 (i_mem_to_decode[19:15]),
    .read_reg_2 (i_mem_to_decode[24:20]),
    .write_reg (i_mem_to_decode[11:7]),
    .read_data_1 (read_data_1_to_alu),
    .read_data_2 (read_data_2_c),
    .write_data (alu_mem_to_reg)
);
alu_control u_alu_control (
    .alu_op (alu_op_c),
    .funct_3 (i_mem_to_decode[14:12]),
    .funct_7 (i_mem_to_decode[31:25]),
    .alu_op_output (alu_control_to_alu)
);
assign alu_src_mux= (alu_src_c)? i_mem_to_decode : read_data_2_c;
alu_unit u_alu_unit(
    .alu_op_in (alu_control_to_alu),
    .alu_mux (alu_src_mux),
    .read_data_1 (read_data_1_to_alu),
    .alu_result (alu_res_to_d_mem),
    .zero (zero_c)   
);
data_memory u_data_memory(
    .clk (clk),
    .add_in (alu_res_to_d_mem),
    .write_data (read_data_2_c),
    .mem_write (mem_write_c),
    .mem_read (mem_read_c),
    .read_data (d_mem_to_alu_mem_to_reg)
);

endmodule