module fetch_unit (
    input wire clk,
    input wire rst_n,
    input wire pc_sel,
    input wire [31:0] jump_add,
    output wire [31:0] pc_out
);
wire [31:0]pc_next;
wire [31:0]pc_plus_4;
assign pc_plus_4=pc_out+4; // Byte-Addressability
assign pc_next=(pc_sel)? jump_add : pc_plus_4;
pc_unit u_program_counter(
    .clk  (clk),
    .rst_n (rst_n),
    .next_pc (pc_next),
    .current_pc (pc_out)
);

endmodule