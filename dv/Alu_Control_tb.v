`include "riscv_defs.vh"
`timescale 1ns/1ps
module alu_control_tb ();
reg [1:0] alu_op_tb;
reg [2:0] funct_3_tb;
reg  [6:0] funct_7_tb;
wire [3:0] alu_op_output_tb;
alu_control uut(
    .alu_op (alu_op_tb),
    .funct_3 (funct_3_tb),
    .funct_7 (funct_7_tb),
    .alu_op_output (alu_op_output_tb)
);
integer errors;
task check_alu_out;
    input [1:0] alu_op_c;
    input [2:0] funct_3_c;
    input [6:0] funct_7_c;
    input [3:0] alu_op_output_excepted;
    input [8*32-1:0] test_name;
    begin
        alu_op_tb=alu_op_c;
        funct_3_tb=funct_3_c;
        funct_7_tb=funct_7_c;
        #1;

    if (alu_op_output_tb==alu_op_output_excepted) begin
        $display("PASS %s , Result : %b",test_name,alu_op_output_tb);
    end
    else begin
        $display("FAIL %s Expected: %b, Got: %b", test_name, alu_op_output_excepted, alu_op_output_tb);
            errors=errors+1;
    end
    end
endtask
initial begin
    errors=0;
//ALUOP_BRANCH test
check_alu_out(`ALUOP_BRANCH,3'b000,7'b0000000,`ALU_CTRL_SUB,"ALUOP_BRANCH test");
//ALUOP_MEM_test
check_alu_out(`ALUOP_MEM,3'b101,7'b1101111,`ALU_CTRL_ADD,"ALUOP_MEM test");
//R-TYPE
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_ADD_SUB,`FUNCT7_NORMAL,`ALU_CTRL_ADD,"ALUOP_RTYPE ADD test");
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_ADD_SUB,`FUNCT7_ALT,`ALU_CTRL_SUB,"ALUOP_RTYPE SUB test");
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_SLL,7'b0000000,`ALU_CTRL_SLL,"ALUOP_RTYPE SLL test");
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_SLT,7'b0000000,`ALU_CTRL_SLT,"ALUOP_RTYPE SLT test");
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_SLTU,7'b0000000,`ALU_CTRL_SLTU,"ALUOP_RTYPE SLTU test");
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_XOR,7'b0000000,`ALU_CTRL_XOR,"ALUOP_RTYPE XOR test");
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_SRL_SRA,`FUNCT7_NORMAL,`ALU_CTRL_SRL,"ALUOP_RTYPE SRL test");
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_SRL_SRA,`FUNCT7_ALT,`ALU_CTRL_SRA,"ALUOP_RTYPE SRA test");
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_OR,7'b0000000,`ALU_CTRL_OR,"ALUOP_RTYPE OR test");
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_AND,7'b0000000,`ALU_CTRL_AND,"ALUOP_RTYPE AND test");
//I-TYPE
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_ADD_SUB,7'b1100011,`ALU_CTRL_ADD,"ALUOP_RTYPE ADDI test");
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_SLL,7'b0000000, `ALU_CTRL_SLL,"ALUOP_RTYPE SLLI test");
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_SLT,7'b0000000,`ALU_CTRL_SLT,"ALUOP_RTYPE SLTI test");
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_SLTU,7'b0000000,`ALU_CTRL_SLTU,"ALUOP_RTYPE SLTUI test");
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_XOR,7'b0000000,`ALU_CTRL_XOR,"ALUOP_RTYPE XORI test");
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_SRL_SRA,`FUNCT7_NORMAL,`ALU_CTRL_SRL,"ALUOP_RTYPE SRLI test");
check_alu_out(`ALUOP_I_TYPE, `FUNCT3_SRL_SRA, `FUNCT7_ALT, `ALU_CTRL_SRA, "ALUOP_RTYPE SRAI test");
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_OR,7'b0000000, `ALU_CTRL_OR,"ALUOP_RTYPE ORI test");
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_AND,7'b0000000, `ALU_CTRL_AND,"ALUOP_RTYPE ANDI test");

$display("-Tests Finished- ,Number of Errors: %d",errors);
$finish;
    

end

    
endmodule