module data_mem #(
    parameter DEPTH = 1024,
    parameter DATA_WIDTH =32
)(
    input wire clk,
    input wire [31:0] add_in,
    input wire [31:0] write_data,
    input wire mem_write,
    input wire mem_read,
    output reg [31:0 ] read_data
);
reg [DATA_WIDTH-1:0] d_mem [0:DEPTH-1];
initial begin
        d_mem[0] = 32'h00000000;
        d_mem[1] = 32'h000D0001;
        d_mem[2] = 32'hA0000002;
        d_mem[3] = 32'h00B00003;
    end

always @(*) begin
    if (mem_read==1)
        read_data=d_mem[add_in[$clog2(DEPTH)+1:2]];
    else
        read_data=32'b0;
    
end
always @(posedge clk ) begin
    if (mem_write==1)
        d_mem[add_in[$clog2(DEPTH)+1:2]]<=write_data;
end
endmodule