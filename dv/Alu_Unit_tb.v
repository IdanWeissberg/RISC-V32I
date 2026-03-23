`include "riscv_defs.vh"
`timescale 1ns/1ps
module alu_unit_tb ();
reg  [31:0] read_data_1_tb;
reg  [31:0] alu_mux_tb;
reg [3:0] alu_op_in_tb;
wire zero_tb;
wire [31:0] alu_result_tb;

alu_unit uut(
    .read_data_1(read_data_1_tb),
    .alu_mux (alu_mux_tb),
    .alu_op_in (alu_op_in_tb),
    .zero (zero_tb),
    .alu_result (alu_result_tb)
);
integer errors;
task check_alu_res;
input [31:0] A;
input [31:0] B;
input [3:0] ctrl;
input expected_zero;
input [31:0] expected_res;
input [8*32-1:0] test_name;
begin
    read_data_1_tb=A;
    alu_mux_tb=B;
    alu_op_in_tb=ctrl;
    #1;
    if((alu_result_tb==expected_res) && (zero_tb==expected_zero))begin
        $display("PASS %s , ALU_RESULT: %h , ZERO : %b",test_name,alu_result_tb,zero_tb);
    end
    else if((alu_result_tb!=expected_res) && (zero_tb!=expected_zero))begin
        $display("FAIL *Both* %s Expected Result: %h , Got: %h--Expected Zero:%b Got:%b ,", test_name,expected_res , alu_result_tb,expected_zero,zero_tb);
        errors=errors+1;
    end else if ((alu_result_tb!=expected_res)) begin
        $display("FAIL *ALU RESULT* %s Expected Result: %h , Got: %h--Expected Zero:%b Got:%b ,", test_name,expected_res , alu_result_tb,expected_zero,zero_tb);
        errors=errors+1;
    end
    else begin
         $display("FAIL *ZERO RESULT* %s Expected Result: %h , Got: %h--Expected Zero:%b Got:%b ,", test_name,expected_res , alu_result_tb,expected_zero,zero_tb);
        errors=errors+1;
    end
end
endtask

initial begin
    errors=0;
    $display("**START WITH A BASIC FUNCTION TESTS");
    //Basic Arithmetic (ADD)
    check_alu_res(32'h0000_0064,32'h0000_0032,`ALU_CTRL_ADD,1'b0,32'h0000_0096,"Basic Arithmetic (ADD)");
    //Basic Arithmetic (SUB)
    check_alu_res(32'h0000_0064,32'h0000_0032,`ALU_CTRL_SUB,1'b0,32'h0000_0032,"Basic Arithmetic (SUB)");
    //Bitwise Logic (AND, OR, XOR)
    check_alu_res(32'hAAAA_AAAA,32'h5555_5555,`ALU_CTRL_AND,1'b1,32'h0000_0000,"Bitwise Logic (AND)");
    check_alu_res(32'hAAAA_AAAA,32'h5555_5555,`ALU_CTRL_OR,1'b0,32'hFFFF_FFFF,"Bitwise Logic (OR)");
    check_alu_res(32'hAAAA_AAAA,32'h5555_5555,`ALU_CTRL_XOR,1'b0,32'hFFFF_FFFF,"Bitwise Logic (XOR)");
    //Logical Shifts (SLL, SRL)
    check_alu_res(32'h0000_000F,32'h0000_0004,`ALU_CTRL_SLL,1'b0,32'h0000_00F0,"Logical Shifts (SLL)"); 
    check_alu_res(32'h0000_000F,32'h0000_0004,`ALU_CTRL_SRL,1'b1,32'h0000_0000,"Logical Shifts (SRL)");
    // Pass-Through (LUI)
    check_alu_res(32'hDEAD_BEEF,32'h1234_5000,`ALU_CTRL_LUI,1'b0,32'h1234_5000,"Pass-Through (LUI)");
    $display("Corner Cases & Isolation Testing");
    //Shift Over-Masking (Shift amount >= 32) Verifies the alu_mux[4:0] constraint
    check_alu_res(32'h0000_0001,32'h0000_0021,`ALU_CTRL_SLL,1'b0,32'h0000_0002,"Shift Over-Masking (Shift amount >= 32)");
    //Shift by Zero
    check_alu_res(32'h8765_4321,32'h0000_0000,`ALU_CTRL_SLL,1'b0,32'h8765_4321,"Shift by Zero");
    //Signed vs. Unsigned Comparison (SLT vs. SLTU)
    check_alu_res(32'hFFFF_FFFF,32'h0000_0001,`ALU_CTRL_SLT,1'b0,32'h0000_0001,"Signed SLT check");
    check_alu_res(32'hFFFF_FFFF,32'h0000_0001,`ALU_CTRL_SLTU,1'b1,32'h0000_0000,"Unsigned SLTU check");
    //SRA Sign Extension Propagation
    check_alu_res(32'h8000_0000,32'h0000_0004,`ALU_CTRL_SRA,1'b0,32'hF800_0000,"SRA Sign Extension Propagation");
    //Zero Flag Triggering (Branch Equality)
    check_alu_res(32'hABCD_1234,32'hABCD_1234,`ALU_CTRL_SUB,1'b1,32'h0000_0000,"Zero Flag Triggering (Branch Equality)");
    //Undefined Operation Safety (Default Case)
    check_alu_res(32'h1111_1111,32'hABCD_1234,4'b1110,1'b1,32'h0000_0000,"Undefined Operation Safety (Default Case)");

    if (errors==0)
        $display("All tests PASSED!!");
    else
        $display("NUMBER OF FAIL TESTS : %d",errors);
    $finish;

end

endmodule
