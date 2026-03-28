`include "riscv_defs.vh"          // Include ALU op codes, funct3/funct7 defines
`timescale 1ns/1ps               // Time unit: 1ns, precision: 1ps
module alu_control_tb ();
reg [1:0] alu_op_tb;             // ALU operation type driven by control unit (2-bit)
reg [2:0] funct_3_tb;            // funct3 field from instruction bits [14:12]
reg  [6:0] funct_7_tb;           // funct7 field from instruction bits [31:25]
wire [3:0] alu_op_output_tb;     // Resulting 4-bit ALU control signal output
alu_control uut(                 // Instantiate Unit Under Test
    .alu_op (alu_op_tb),
    .funct_3 (funct_3_tb),
    .funct_7 (funct_7_tb),
    .alu_op_output (alu_op_output_tb)
);
integer errors;                  // Counts how many test cases failed
task check_alu_out;
    input [1:0] alu_op_c;                // alu_op stimulus to apply
    input [2:0] funct_3_c;              // funct3 stimulus to apply
    input [6:0] funct_7_c;              // funct7 stimulus to apply
    input [3:0] alu_op_output_excepted; // Expected ALU control output
    input [8*32-1:0] test_name;         // Test label string (up to 32 chars)
    begin
        alu_op_tb=alu_op_c;             // Drive alu_op input
        funct_3_tb=funct_3_c;           // Drive funct3 input
        funct_7_tb=funct_7_c;           // Drive funct7 input
        #1;                             // Wait 1ns for combinational logic to settle

    if (alu_op_output_tb==alu_op_output_excepted) begin
        $display("PASS %s , Result : %b",test_name,alu_op_output_tb);                          // Test passed
    end
    else begin
        $display("FAIL %s Expected: %b, Got: %b", test_name, alu_op_output_excepted, alu_op_output_tb); // Mismatch detected
            errors=errors+1;            // Increment error counter
    end
    end
endtask
initial begin
    errors=0;                    // Initialize error counter
//ALUOP_BRANCH test
check_alu_out(`ALUOP_BRANCH,3'b000,7'b0000000,`ALU_CTRL_SUB,"ALUOP_BRANCH test");           // Branch uses SUB to evaluate condition (zero flag)
//ALUOP_MEM_test
check_alu_out(`ALUOP_MEM,3'b101,7'b1101111,`ALU_CTRL_ADD,"ALUOP_MEM test");                 // Memory address = base + offset, always ADD
//R-TYPE
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_ADD_SUB,`FUNCT7_NORMAL,`ALU_CTRL_ADD,"ALUOP_RTYPE ADD test");   // ADD:  funct7=0000000
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_ADD_SUB,`FUNCT7_ALT,`ALU_CTRL_SUB,"ALUOP_RTYPE SUB test");     // SUB:  funct7=0100000 distinguishes from ADD
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_SLL,7'b0000000,`ALU_CTRL_SLL,"ALUOP_RTYPE SLL test");          // SLL:  shift left logical by rs2[4:0]
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_SLT,7'b0000000,`ALU_CTRL_SLT,"ALUOP_RTYPE SLT test");          // SLT:  set rd=1 if rs1 < rs2 (signed)
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_SLTU,7'b0000000,`ALU_CTRL_SLTU,"ALUOP_RTYPE SLTU test");       // SLTU: set rd=1 if rs1 < rs2 (unsigned)
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_XOR,7'b0000000,`ALU_CTRL_XOR,"ALUOP_RTYPE XOR test");          // XOR:  bitwise exclusive-or
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_SRL_SRA,`FUNCT7_NORMAL,`ALU_CTRL_SRL,"ALUOP_RTYPE SRL test");  // SRL:  shift right logical  (funct7=0000000)
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_SRL_SRA,`FUNCT7_ALT,`ALU_CTRL_SRA,"ALUOP_RTYPE SRA test");     // SRA:  shift right arithmetic (funct7=0100000, sign-extends)
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_OR,7'b0000000,`ALU_CTRL_OR,"ALUOP_RTYPE OR test");             // OR:   bitwise or
check_alu_out(`ALUOP_R_TYPE,`FUNCT3_AND,7'b0000000,`ALU_CTRL_AND,"ALUOP_RTYPE AND test");          // AND:  bitwise and
//I-TYPE
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_ADD_SUB,7'b1100011,`ALU_CTRL_ADD,"ALUOP_RTYPE ADDI test");     // ADDI: funct7 irrelevant for non-shift I-type
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_SLL,7'b0000000, `ALU_CTRL_SLL,"ALUOP_RTYPE SLLI test");        // SLLI: shift left logical by imm[4:0]
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_SLT,7'b0000000,`ALU_CTRL_SLT,"ALUOP_RTYPE SLTI test");         // SLTI: set rd=1 if rs1 < sign_ext(imm) (signed)
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_SLTU,7'b0000000,`ALU_CTRL_SLTU,"ALUOP_RTYPE SLTUI test");      // SLTIU: set rd=1 if rs1 < imm (unsigned)
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_XOR,7'b0000000,`ALU_CTRL_XOR,"ALUOP_RTYPE XORI test");         // XORI: bitwise xor with immediate
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_SRL_SRA,`FUNCT7_NORMAL,`ALU_CTRL_SRL,"ALUOP_RTYPE SRLI test"); // SRLI: shift right logical immediate  (funct7=0000000)
check_alu_out(`ALUOP_I_TYPE, `FUNCT3_SRL_SRA, `FUNCT7_ALT, `ALU_CTRL_SRA, "ALUOP_RTYPE SRAI test"); // SRAI: shift right arithmetic immediate (funct7=0100000)
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_OR,7'b0000000, `ALU_CTRL_OR,"ALUOP_RTYPE ORI test");           // ORI:  bitwise or with immediate
check_alu_out(`ALUOP_I_TYPE,`FUNCT3_AND,7'b0000000, `ALU_CTRL_AND,"ALUOP_RTYPE ANDI test");        // ANDI: bitwise and with immediate

$display("-Tests Finished- ,Number of Errors: %d",errors);  // Print total error count
$finish;                         // End simulation
    

end

    
endmodule