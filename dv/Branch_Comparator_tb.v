`include "riscv_defs.vh"
`timescale 1ns/1ps
module branch_comparator_tb ();
reg [31:0] rs_1_tb;              // First source register value
reg [31:0] rs_2_tb;              // Second source register value
reg [31:0] instruction_tb;       // 32-bit instruction encoding (to extract
wire branch_decision_tb;         // Output from branch_comparator indicating whether to branch
branch_comparator uut(            // Instantiate Unit Under Test
    .rs_1(rs_1_tb),
    .rs_2(rs_2_tb),
    .instruction(instruction_tb),
    .branch_decision(branch_decision_tb)
);
integer errors;                  // Counts how many test cases failed
task check_branch_decision;
input [31:0] rs1;              // Value to drive into rs_1
input [31:0] rs2;              // Value to drive into rs_2
input [31:0] instr;            // Instruction encoding to drive
input expected_decision;        // Expected branch decision (0 or 1)
input [8*32-1:0] test_name;    // Test label string (up to 32 chars)
begin
    rs_1_tb=rs1;                // Drive rs_1
    rs_2_tb=rs2;                // Drive rs_2
    instruction_tb=instr;        // Drive instruction encoding
    #1;                          // Wait 1ns for combinational logic to settle
    if(branch_decision_tb==expected_decision) begin
        $display("PASS %s , Branch Decision: %b",test_name,branch_decision_tb);
    end else begin
        $display("FAIL %s Expected: %b , Got: %b", test_name, expected_decision, branch_decision_tb);
        errors=errors+1;
    end
end
endtask
initial begin
    errors=0;     // Initialize error counter
    $display("STARTING BRANCH COMPARATOR TESTS");
    // Test BEQ (Branch if Equal)
    check_branch_decision(32'h0000_0005, 32'h0000_0005, {17'b0,`FUNCT3_BEQ,5'b0,`OPCODE_BRANCH}, 1, "BEQ Equal");          // rs1 == rs2 → branch
    check_branch_decision(32'h0000_0005, 32'h0000_0006, {17'b0,`FUNCT3_BEQ,5'b0,`OPCODE_BRANCH}, 0, "BEQ Not Equal");      // rs1 != rs2 → no branch
    // Test BNE (Branch if Not Equal)
    check_branch_decision(32'h0000_0005, 32'h0000_0006, {17'b0,`FUNCT3_BNE,5'b0,`OPCODE_BRANCH}, 1, "BNE Not Equal");      // rs1 != rs2 → branch
    check_branch_decision(32'h0000_0005, 32'h0000_0005, {17'b0,`FUNCT3_BNE,5'b0,`OPCODE_BRANCH}, 0, "BNE Equal");          // rs1 == rs2 → no branch
    // Test BLT (Branch if Less Than)
    check_branch_decision(32'hFFFF_FFFF, 32'h0000_0001, {17'b0,`FUNCT3_BLT,5'b0,`OPCODE_BRANCH}, 1, "BLT Signed Less");   // -1 < 1 signed → branch
    check_branch_decision(32'h0000_0001, 32'hFFFF_FFFF, {17'b0,`FUNCT3_BLT,5'b0,`OPCODE_BRANCH}, 0, "BLT Signed Greater"); // 1 < -1 signed → no branch
    // Test BGE (Branch if Greater or Equal)
    check_branch_decision(32'hFFFF_FFFF, 32'hFFFF_FFFF, {17'b0,`FUNCT3_BGE,5'b0,`OPCODE_BRANCH}, 1, "BGE Signed Equal");   // -1 >= -1 signed → branch
    check_branch_decision(32'h0000_0001, 32'hFFFF_FFFF, {17'b0,`FUNCT3_BGE,5'b0,`OPCODE_BRANCH}, 1, "BGE Signed Greater"); // 1 >= -1 signed → branch
    check_branch_decision(32'hFFFF_FFFF, 32'h0000_0001, {17'b0,`FUNCT3_BGE,5'b0,`OPCODE_BRANCH}, 0, "BGE Signed Less");     // -1 >= 1 signed → no branch
    // Test BLTU (Branch if Less Than Unsigned)
    check_branch_decision(32'hFFFF_FFFF, 32'h0000_0001, {17'b0,`FUNCT3_BLTU,5'b0,`OPCODE_BRANCH}, 0, "BLTU Unsigned Less");   // 0xFFFFFFFF < 1 unsigned → no branch
    check_branch_decision(32'h0000_0001, 32'hFFFF_FFFF, {17'b0,`FUNCT3_BLTU,5'b0,`OPCODE_BRANCH}, 1, "BLTU Unsigned Greater"); // 1 < 0xFFFFFFFF unsigned → branch
    // Test BGEU (Branch if Greater or Equal Unsigned)
    check_branch_decision(32'hFFFF_FFFF, 32'hFFFFFFFF, {17'b0,`FUNCT3_BGEU,5'b0,`OPCODE_BRANCH}, 1, "BGEU Unsigned Equal");   // 0xFFFFFFFF >= 0xFFFFFFFF unsigned → branch
    check_branch_decision(32'h0000_0001, 32'hFFFFFFFF, {17'b0,`FUNCT3_BGEU,5'b0,`OPCODE_BRANCH}, 0, "BGEU Unsigned Less");     // 1 >= 0xFFFFFFFF unsigned → no branch
    $display("BRANCH COMPARATOR TESTS COMPLETED with %d errors", errors);
    $finish;   // End simulation
end
endmodule
