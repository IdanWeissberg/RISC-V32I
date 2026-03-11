`include "riscv_defs.vh"
`timescale 1ns/1ps
module alu_control_tb ();
reg [1:0] alu_op;
reg [2:0] funct_3;
reg  [6:0] funct_7;
wire [3:0] alu_op_output;
alu_control uut(
    .alu_op (alu_op),
    .funct_3 (funct_3),
    .funct_7 (funct_7),
    .alu_op_output (alu_op_output)
);
initial begin
    alu_op=`ALUOP_BRANCH;
    funct_3=3'b000;
    funct_7=7'b0000000;
    #5 if (alu_op_output==`ALU_CTRL_SUB)
            $display("ALUOP_BRANCH test pass");
        else
            $display("ALUOP_BRANCH test fail. Got : %b",alu_op_output);
    alu_op=`ALUOP_MEM;
    #5 if (alu_op_output==`ALU_CTRL_ADD)
            $display("ALUOP_MEM test pass");
        else
            $display("ALUOP_MEM test fail.Got : %b",alu_op_output);
    alu_op=`ALUOP_I_TYPE;
    #5 if (alu_op_output==`ALU_CTRL_ADD)
            $display("ALUOP_I_TYPE test pass");
        else
            $display("ALUOP_I_TYPE test failGot : %b",alu_op_output);
   alu_op= `ALUOP_R_TYPE;
   funct_3=`FUNCT3_ADD_SUB;
   funct_7=`FUNCT7_NORMAL;
   #5 if (alu_op_output==`ALU_CTRL_ADD)
            $display("ALU_OP_R_TYPE ADD SELECTION test pass");
        else
            $display("ALU_OP_R_TYPE ADD SELECTION test fail .Got : %b",alu_op_output);
    funct_7=`FUNCT7_ALT;
    #5 if (alu_op_output==`ALU_CTRL_SUB)
            $display("ALU_OP_R_TYPE SUB SELECTION test pass");
        else
            $display("ALU_OP_R_TYPE SUB SELECTION test fail Got : %b",alu_op_output);
    funct_3=3'b001;
    #5 if (alu_op_output==4'b0000)//defult
            $display("Defult selection test pass");
        else
            $display("Defult selection test fail Got : %b",alu_op_output);
    alu_op=`ALUOP_BRANCH;
    #5;
    funct_3=`FUNCT3_ADD_SUB;
    funct_7=`FUNCT7_NORMAL;
    if (alu_op_output==`ALU_CTRL_SUB)//defult
            $display("Isolation Test (BRANCH) pass");
    else
            $display("Isolation Test (BRANCH) FAIL (Got %b)", alu_op_output);
    $display("-Tests Finished-");
    $finish;
    

end

    
endmodule