module fetch_unit (
    input wire clk,
    input wire rst_n,
    input wire [1:0] pc_sel,
    input wire [31:0] alu_res,
    input wire [31:0] jump_add,
    output wire [31:0] pc_out,
    output wire [31:0]pc_plus_4
);
reg [31:0]pc_next;
assign pc_plus_4=pc_out+4; // Byte-Addressability
always @(*) begin
    case (pc_sel)
        2'b00: pc_next = pc_plus_4;
        2'b01: pc_next = {alu_res[31:1], 1'b0};   // JALR: clear LSB
        2'b10: pc_next = jump_add;                  // branch / JAL
        default: pc_next = pc_plus_4;
    endcase
end
pc_unit u_program_counter(
    .clk  (clk),
    .rst_n (rst_n),
    .next_pc (pc_next),
    .current_pc (pc_out)
);

endmodule