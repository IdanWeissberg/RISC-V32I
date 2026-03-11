module pc_unit (
    input wire clk,
    input wire rst_n,
    input wire [31:0] next_pc,
    output reg [31:0] current_pc
);
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        current_pc<=32'b0;
    end  else begin
        current_pc<=next_pc;
    end 
end

endmodule