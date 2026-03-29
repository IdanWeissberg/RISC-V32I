`include "riscv_defs.vh"
`timescale 1ns/1ps               // Time unit: 1ns, precision: 1ps
module alu_unit_tb ();
reg  [31:0] read_data_1_tb;      // First ALU operand (rs1)
reg  [31:0] alu_mux_tb;          // Second ALU operand (rs2 or immediate, after mux)
reg [3:0] alu_op_in_tb;          // 4-bit ALU control signal from alu_control unit
wire [31:0] alu_result_tb;       // 32-bit ALU output result

alu_unit uut(                    // Instantiate Unit Under Test
    .read_data_1(read_data_1_tb),
    .alu_mux (alu_mux_tb),
    .alu_op_in (alu_op_in_tb),
    .alu_result (alu_result_tb)
);
integer errors;                  // Counts how many test cases failed
task check_alu_res;
input [31:0] A;                  // First operand to drive (read_data_1)
input [31:0] B;                  // Second operand to drive (alu_mux)
input [3:0] ctrl;                // ALU control signal to drive
input [31:0] expected_res;       // Expected ALU result
input [8*32-1:0] test_name;      // Test label string (up to 32 chars)
begin
    read_data_1_tb=A;            // Drive operand A
    alu_mux_tb=B;                // Drive operand B
    alu_op_in_tb=ctrl;           // Drive ALU control
    #1;                          // Wait 1ns for combinational logic to settle
    if(alu_result_tb==expected_res) begin
        $display("PASS %s , ALU_RESULT: %h",test_name,alu_result_tb);
    end else begin
        $display("FAIL %s Expected: %h , Got: %h", test_name, expected_res, alu_result_tb);
        errors=errors+1;
    end
end
endtask

initial begin
    errors=0;                    // Initialize error counter
    $display("**START WITH A BASIC FUNCTION TESTS");
    //Basic Arithmetic (ADD)
    check_alu_res(32'h0000_0064,32'h0000_0032,`ALU_CTRL_ADD,32'h0000_0096,"Basic Arithmetic (ADD)");           // 100 + 50 = 150
    //Basic Arithmetic (SUB)
    check_alu_res(32'h0000_0064,32'h0000_0032,`ALU_CTRL_SUB,32'h0000_0032,"Basic Arithmetic (SUB)");           // 100 - 50 = 50
    //Bitwise Logic (AND, OR, XOR)
    check_alu_res(32'hAAAA_AAAA,32'h5555_5555,`ALU_CTRL_AND,32'h0000_0000,"Bitwise Logic (AND)");              // Alternating bits AND = 0
    check_alu_res(32'hAAAA_AAAA,32'h5555_5555,`ALU_CTRL_OR,32'hFFFF_FFFF,"Bitwise Logic (OR)");               // Alternating bits OR = all 1s
    check_alu_res(32'hAAAA_AAAA,32'h5555_5555,`ALU_CTRL_XOR,32'hFFFF_FFFF,"Bitwise Logic (XOR)");             // Alternating bits XOR = all 1s
    //Logical Shifts (SLL, SRL)
    check_alu_res(32'h0000_000F,32'h0000_0004,`ALU_CTRL_SLL,32'h0000_00F0,"Logical Shifts (SLL)");            // 0xF << 4 = 0xF0
    check_alu_res(32'h0000_000F,32'h0000_0004,`ALU_CTRL_SRL,32'h0000_0000,"Logical Shifts (SRL)");            // 0xF >> 4 = 0
    // Pass-Through (LUI)
    check_alu_res(32'hDEAD_BEEF,32'h1234_5000,`ALU_CTRL_LUI,32'h1234_5000,"Pass-Through (LUI)");              // LUI passes B directly, A ignored
    $display("Corner Cases & Isolation Testing");
    //Shift Over-Masking (Shift amount >= 32) Verifies the alu_mux[4:0] constraint
    check_alu_res(32'h0000_0001,32'h0000_0021,`ALU_CTRL_SLL,32'h0000_0002,"Shift Over-Masking (Shift amount >= 32)"); // 0x21=33, masked to 1 → 1<<1=2
    //Shift by Zero
    check_alu_res(32'h8765_4321,32'h0000_0000,`ALU_CTRL_SLL,32'h8765_4321,"Shift by Zero");                   // Shifting by 0 leaves value unchanged
    //Signed vs. Unsigned Comparison (SLT vs. SLTU)
    check_alu_res(32'hFFFF_FFFF,32'h0000_0001,`ALU_CTRL_SLT,32'h0000_0001,"Signed SLT check");                // -1 < 1 signed → result=1
    check_alu_res(32'hFFFF_FFFF,32'h0000_0001,`ALU_CTRL_SLTU,32'h0000_0000,"Unsigned SLTU check");            // 0xFFFFFFFF > 1 unsigned → result=0
    //SRA Sign Extension Propagation
    check_alu_res(32'h8000_0000,32'h0000_0004,`ALU_CTRL_SRA,32'hF800_0000,"SRA Sign Extension Propagation");  // MSB=1, sign bit propagates right
    //SUB to Zero (used for BEQ branch equality check)
    check_alu_res(32'hABCD_1234,32'hABCD_1234,`ALU_CTRL_SUB,32'h0000_0000,"SUB to Zero (Branch Equality)");   // A==B → SUB=0
    //Undefined Operation Safety (Default Case)
    check_alu_res(32'h1111_1111,32'hABCD_1234,4'b1110,32'h0000_0000,"Undefined Operation Safety (Default Case)"); // Invalid opcode → default output = 0

    if (errors==0)
        $display("All tests PASSED!!");     // All test cases passed
    else
        $display("NUMBER OF FAIL TESTS : %d",errors); // Print count of failed tests
    $finish;                     // End simulation

end

endmodule
