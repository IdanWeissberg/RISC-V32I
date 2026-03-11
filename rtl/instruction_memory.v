module instruction_memory (
    input wire [31:0] addr,
    output reg [31:0] instruction
);
reg [31:0] mem [0:1023];
always @(*) begin
    instruction=mem[addr[11:2]]; 
end
initial begin
    $readmemh("program.hex", mem);
end
endmodule