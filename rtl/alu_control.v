`include "riscv_defs.vh"

module alu_control (
    input wire [1:0] alu_op,
    input wire [2:0] funct_3,
    input wire [6:0] funct_7,
    output reg [3:0] alu_op_output
);

always @(*) begin
    alu_op_output = 4'b0000; // defult pre assignment

    case (alu_op)
        `ALUOP_BRANCH: begin
            alu_op_output = `ALU_CTRL_SUB;
        end
        
        `ALUOP_MEM: begin
            alu_op_output = `ALU_CTRL_ADD;
        end
        
    
        // R-Type Instructions (Register-Register)
     
        `ALUOP_R_TYPE: begin
            case (funct_3)
                `FUNCT3_ADD_SUB: begin
                    if (funct_7 == `FUNCT7_NORMAL)
                        alu_op_output = `ALU_CTRL_ADD;
                    else  
                        alu_op_output = `ALU_CTRL_SUB;
                end 
                
                `FUNCT3_SLL:  alu_op_output = `ALU_CTRL_SLL;
                `FUNCT3_SLT:  alu_op_output = `ALU_CTRL_SLT;
                `FUNCT3_SLTU: alu_op_output = `ALU_CTRL_SLTU;
                `FUNCT3_XOR:  alu_op_output = `ALU_CTRL_XOR;
                
                `FUNCT3_SRL_SRA: begin
                    if (funct_7 == `FUNCT7_NORMAL)
                        alu_op_output = `ALU_CTRL_SRL;
                    else
                        alu_op_output = `ALU_CTRL_SRA;
                end
                
                `FUNCT3_OR:   alu_op_output = `ALU_CTRL_OR;
                `FUNCT3_AND:  alu_op_output = `ALU_CTRL_AND;
                
                default: alu_op_output = `ALU_CTRL_ADD;
            endcase
        end
    
        // I-Type Instructions (Register-Immediate)
        
        `ALUOP_I_TYPE: begin
            case (funct_3)
                `FUNCT3_ADD_SUB: begin
                    alu_op_output = `ALU_CTRL_ADD;
                end
                
                `FUNCT3_SLL:  alu_op_output = `ALU_CTRL_SLL;
                `FUNCT3_SLT:  alu_op_output = `ALU_CTRL_SLT;
                `FUNCT3_SLTU: alu_op_output = `ALU_CTRL_SLTU;
                `FUNCT3_XOR:  alu_op_output = `ALU_CTRL_XOR;
                
                `FUNCT3_SRL_SRA: begin
                    if (funct_7 == `FUNCT7_NORMAL)
                        alu_op_output = `ALU_CTRL_SRL;
                    else
                        alu_op_output = `ALU_CTRL_SRA;
                end
                
                `FUNCT3_OR:   alu_op_output = `ALU_CTRL_OR;
                `FUNCT3_AND:  alu_op_output = `ALU_CTRL_AND;
                
                default: alu_op_output = `ALU_CTRL_ADD;
            endcase
        end
        
        default: alu_op_output = `ALU_CTRL_ADD;
    endcase
end
   
endmodule