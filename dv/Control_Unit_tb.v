`include "riscv_defs.vh"
`timescale 1ns/1ps
module control_unit_tb ();

reg  [6:0] op_code_tb;
wire       mem_read_tb;
wire       branch_tb;
wire [1:0] mem_to_reg_tb;
wire       mem_write_tb;
wire       alu_src_tb;
wire       reg_write_tb;
wire [1:0] alu_op_tb;
wire       jal_branch_mux_tb;
wire       jalr_tb;
wire       lui_tb;

control_unit uut(
    .op_code        (op_code_tb),
    .mem_read       (mem_read_tb),
    .branch         (branch_tb),
    .mem_to_reg     (mem_to_reg_tb),
    .mem_write      (mem_write_tb),
    .alu_src        (alu_src_tb),
    .reg_write      (reg_write_tb),
    .alu_op         (alu_op_tb),
    .jal_branch_mux (jal_branch_mux_tb),
    .jalr           (jalr_tb),
    .lui            (lui_tb)
);

// Schema: { Opcode[6:0], MemRead, Branch, MemToReg[1:0], MemWrite, ALUSrc, RegWrite, ALUOp[1:0], jal_branch_mux, jalr, lui }
// Bit positions (excl. opcode): [11]=mem_read [10]=branch [9:8]=mem_to_reg [7]=mem_write
//                                [6]=alu_src   [5]=reg_write [4:3]=alu_op [2]=jal_branch_mux [1]=jalr [0]=lui
reg [18:0] test_vector [0:9];
reg [18:0] golden_vector;
reg [8*10:1] test_name;
integer i;

initial begin
    // 0. R-Type
    test_vector[0] = { `OPCODE_R_TYPE, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 2'b10, 1'b0, 1'b0, 1'b0 };
    // 1. Load
    test_vector[1] = { `OPCODE_LOAD,   1'b1, 1'b0, 2'b01, 1'b0, 1'b1, 1'b1, 2'b00, 1'b0, 1'b0, 1'b0 };
    // 2. Store
    test_vector[2] = { `OPCODE_STORE,  1'b0, 1'b0, 2'b00, 1'b1, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0 };
    // 3. Branch
    test_vector[3] = { `OPCODE_BRANCH, 1'b0, 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, 1'b0 };
    // 4. I-Type
    test_vector[4] = { `OPCODE_I_TYPE, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1, 1'b1, 2'b11, 1'b0, 1'b0, 1'b0 };
    // 5. JAL
    test_vector[5] = { `OPCODE_JAL,    1'b0, 1'b1, 2'b10, 1'b0, 1'b0, 1'b1, 2'b01, 1'b0, 1'b0, 1'b0 };
    // 6. JALR
    test_vector[6] = { `OPCODE_JALR,   1'b0, 1'b0, 2'b10, 1'b0, 1'b1, 1'b1, 2'b00, 1'b0, 1'b1, 1'b0 };
    // 7. LUI
    test_vector[7] = { `OPCODE_LUI,    1'b0, 1'b0, 2'b00, 1'b0, 1'b1, 1'b1, 2'b00, 1'b0, 1'b0, 1'b1 };
    // 8. AUIPC
    test_vector[8] = { `OPCODE_AUIPC,  1'b0, 1'b0, 2'b11, 1'b0, 1'b0, 1'b1, 2'b00, 1'b0, 1'b0, 1'b0 };
    // 9. Invalid Opcode (Safety)
    test_vector[9] = { 7'b1111111,     1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 1'b0 };

    for (i = 0; i <= 9; i = i + 1) begin
        golden_vector = test_vector[i];
        op_code_tb    = golden_vector[18:12];
        case (op_code_tb)
            `OPCODE_R_TYPE: test_name = "R-TYPE  ";
            `OPCODE_LOAD:   test_name = "LOAD    ";
            `OPCODE_STORE:  test_name = "STORE   ";
            `OPCODE_BRANCH: test_name = "BRANCH  ";
            `OPCODE_I_TYPE: test_name = "I-TYPE  ";
            `OPCODE_JAL:    test_name = "JAL     ";
            `OPCODE_JALR:   test_name = "JALR    ";
            `OPCODE_LUI:    test_name = "LUI     ";
            `OPCODE_AUIPC:  test_name = "AUIPC   ";
            default:        test_name = "INVALID ";
        endcase
        #10;
        if ({mem_read_tb, branch_tb, mem_to_reg_tb, mem_write_tb, alu_src_tb, reg_write_tb, alu_op_tb, jal_branch_mux_tb, jalr_tb, lui_tb} == golden_vector[11:0])
            $display("Test %0d [%s]: Opcode=%b PASS", i, test_name, op_code_tb);
        else
            $display("Test %0d [%s]: Opcode=%b FAIL -- Got: mem_read=%b branch=%b mem_to_reg=%b mem_write=%b alu_src=%b reg_write=%b alu_op=%b jal_branch_mux=%b jalr=%b lui=%b",
                i, test_name, op_code_tb,
                mem_read_tb, branch_tb, mem_to_reg_tb, mem_write_tb,
                alu_src_tb, reg_write_tb, alu_op_tb,
                jal_branch_mux_tb, jalr_tb, lui_tb);
    end

    $finish;
end

endmodule