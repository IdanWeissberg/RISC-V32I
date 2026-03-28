`include "riscv_defs.vh"
module alu_unit (
    input wire [31:0] read_data_1,
    input wire [31:0] alu_mux,
    input wire [3:0] alu_op_in,
    output reg [31:0] alu_result
);

always @(*) begin
    alu_result=32'b0;
    case (alu_op_in)
        `ALU_CTRL_SUB:alu_result= read_data_1-alu_mux;
        `ALU_CTRL_ADD:alu_result= read_data_1+alu_mux;
        `ALU_CTRL_AND:alu_result= read_data_1 & alu_mux;
        `ALU_CTRL_OR :alu_result= read_data_1 | alu_mux;
        `ALU_CTRL_XOR:alu_result= read_data_1 ^ alu_mux;
        // Shift dont need to do more then 32 (2^5) moves
        `ALU_CTRL_SLL:alu_result= read_data_1 << alu_mux[4:0];
        `ALU_CTRL_SRL:alu_result= read_data_1 >> alu_mux[4:0];
        `ALU_CTRL_SRA:alu_result=$signed(read_data_1) >>> alu_mux[4:0];
        //
        `ALU_CTRL_SLT:alu_result=($signed(read_data_1) < $signed(alu_mux))?32'b1:32'b0; 
        `ALU_CTRL_SLTU:alu_result=($unsigned(read_data_1) < $unsigned(alu_mux))?32'b1:32'b0;
        `ALU_CTRL_LUI:alu_result=alu_mux;
    endcase
end

endmodule