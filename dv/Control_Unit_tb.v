`include "riscv_defs.vh"
`timescale 1ns/1ps
module control_unit_tb ();
reg [6:0] op_code;
wire mem_read;
wire branch;
wire mem_to_reg;
wire mem_write;
wire alu_src;
wire reg_write;
wire [1:0] alu_op;

control_unit uut(
    .op_code (op_code),
    .mem_read (mem_read),
    .branch (branch),
    .mem_to_reg (mem_to_reg),
    .mem_write (mem_write),
    .alu_src (alu_src),
    .reg_write (reg_write),
    .alu_op (alu_op)
);
reg [14:0] test_vector [0:5];
reg [14:0] golden_vector;
reg [8*10:1] test_name;
integer i; 
initial begin
    // Scehma: { Opcode[6:0], MemRead, Branch, MemToReg, MemWrite, ALUSrc, RegWrite, ALUOp[1:0] }
    // 0. R-Type 
    test_vector[0] = { `OPCODE_R_TYPE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b10 };

    // 1. LW (Load Word) 
    test_vector[1] = { `OPCODE_LOAD,   1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 2'b00 };

    // 2. SW (Store Word) 
    test_vector[2] = { `OPCODE_STORE,  1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 2'b00 };

    // 3. BEQ (Branch) 
    test_vector[3] = { `OPCODE_BRANCH, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b01 };

    // 4. I-Type 
    test_vector[4] = { `OPCODE_I_TYPE, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 2'b11 };

    // 5. Invalid (Safety)-All zero
    test_vector[5] = { 7'b1111111, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00 };
    for (i =0 ;i<=5 ;i=i+1 ) begin
        golden_vector=test_vector[i];
        op_code=golden_vector[14:8];
        case (op_code)
        `OPCODE_R_TYPE: test_name = "R-TYPE";
        `OPCODE_LOAD:   test_name = "LOAD  "; 
        `OPCODE_STORE:  test_name = "STORE ";
        `OPCODE_BRANCH: test_name = "BRANCH";
        `OPCODE_I_TYPE: test_name = "I-TYPE";
        default:        test_name = "UNKNOWN";
        endcase
        #10;
        if ({mem_read, branch, mem_to_reg, mem_write, alu_src, reg_write, alu_op[1:0]}==golden_vector[7:0])
            $display("Test %0d [%s]: Opcode=%b PASS", i, test_name, op_code);
        else $display("Test %0d [%s]: Opcode=%b FAIL", i, test_name, op_code);
    end
    
    $finish;

end

    
endmodule