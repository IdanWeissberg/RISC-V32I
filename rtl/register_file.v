module register_file (
    input wire clk,
    input wire reg_write,
    input wire [4:0] read_reg_1,
    input wire [4:0] read_reg_2,
    input wire [4:0] write_reg,
    input wire [31:0] write_data,
    output reg [31:0] read_data_1,
    output reg [31:0] read_data_2
);
reg [31:0] reg_file [0:31];
always @(*) begin
    if (read_reg_1==0)
        read_data_1=32'b0;
    else read_data_1=reg_file[read_reg_1];
    if (read_reg_2==0)
        read_data_2=32'b0;
    else read_data_2=reg_file[read_reg_2]; 
          
end
always @(posedge clk) begin
    if (reg_write==1 && (write_reg!=0) )                          
        reg_file[write_reg]<=write_data;
end
endmodule