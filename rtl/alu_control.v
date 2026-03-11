`include "riscv_defs.vh"
module alu_control (
    input wire [1:0] alu_op,
    input wire [2:0] funct_3,
    input wire [6:0] funct_7,
    output reg [3:0] alu_op_output
);
always @(*) begin
    alu_op_output=4'b0000;
    case (alu_op)
        `ALUOP_BRANCH:begin
            alu_op_output=`ALU_CTRL_SUB;
        end
        `ALUOP_MEM : begin
            alu_op_output=`ALU_CTRL_ADD;
        end
        `ALUOP_R_TYPE : begin
            case (funct_3)
                `FUNCT3_ADD_SUB: begin
                    if (funct_7==`FUNCT7_NORMAL)
                        alu_op_output=`ALU_CTRL_ADD;
                    else  
                        alu_op_output=`ALU_CTRL_SUB;
                end
            endcase
        end
    
        `ALUOP_I_TYPE : begin
            alu_op_output=`ALU_CTRL_ADD;
        end
    endcase
end
   
endmodule