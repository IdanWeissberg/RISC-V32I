`include "riscv_defs.vh"
`timescale 1ns/1ps

module imm_gen_tb ();
reg [31:0] instruction_tb;
wire [31:0] immediate_tb;

imm_gen uut(
    .instruction (instruction_tb),
    .immediate (immediate_tb)
);
integer errors;
task check_imm;
        input [31:0] inst;
        input [31:0] expected_imm;
        input [8*32-1:0] test_name;
    begin
        instruction_tb=inst;
        #1
        if(immediate_tb==expected_imm) begin
            $display("PASS %s, Result : %h",test_name,immediate_tb);
        end
        else begin
            $display("FAIL %s Expected: %h, Got: %h", test_name, expected_imm, immediate_tb);
            errors=errors+1;
        end
    end
endtask
initial begin
    errors=0;
    //Critical Functionality Tests
    check_imm(32'h0040A283,32'h00000004,"I-Type Positive");
    check_imm(32'hFFF0A283,32'hFFFFFFFF,"I-Type Negative");
    check_imm(32'h0050A223,32'h00000004,"S-Type");
    check_imm(32'h00000463,32'h00000008,"B-Type");
    check_imm(32'h000012B7,32'h00001000,"U-Type");
    check_imm(32'h00C000EF,32'h0000000C,"J-Type");
    //Corner Cases & Data Integrity
    check_imm(32'h7FF0A283,32'h000007FF,"Sign-Bit Boundary (Positive)");
    check_imm(32'h8000A283,32'hFFFFF800,"Sign-Bit Boundary (Negative)");
    check_imm(32'h007302B3,32'h00000000,"R-Type Instruction (Isolation Test)");
    if (errors==0)
        $display("ALL OF THE TESTS PASSED");
    else
        $display("FAILD WITH %d ERRORS",errors);
    $finish;
end  
endmodule