`ifndef RISCV_DEFS_VH
`define RISCV_DEFS_VH

// Major Opcodes (inst[6:0])

`define OPCODE_R_TYPE       7'b0110011 // add, sub, sll, xor, srl, sra, or, and
`define OPCODE_I_TYPE       7'b0010011 // addi, xori, ori, andi, slli, srli, srai, slti
`define OPCODE_LOAD         7'b0000011 // lb, lh, lw, lbu, lhu
`define OPCODE_STORE        7'b0100011 // sb, sh, sw
`define OPCODE_BRANCH       7'b1100011 // beq, bne, blt, bge, bltu, bgeu
`define OPCODE_JAL          7'b1101111 // jal
`define OPCODE_JALR         7'b1100111 // jalr
`define OPCODE_LUI          7'b0110111 // lui
`define OPCODE_AUIPC        7'b0010111 // auipc

// Arithmetic & Logic (R-Type & I-Type)
`define FUNCT3_ADD_SUB      3'b000 // ADD / SUB / ADDI
`define FUNCT3_SLL          3'b001 // SLL / SLLI
`define FUNCT3_SLT          3'b010 // SLT / SLTI (Signed)
`define FUNCT3_SLTU         3'b011 // SLTU / SLTIU (Unsigned)
`define FUNCT3_XOR          3'b100 // XOR / XORI
`define FUNCT3_SRL_SRA      3'b101 // SRL / SRA / SRLI / SRAI
`define FUNCT3_OR           3'b110 // OR / ORI
`define FUNCT3_AND          3'b111 // AND / ANDI

// Branch Instructions
`define FUNCT3_BEQ          3'b000
`define FUNCT3_BNE          3'b001
`define FUNCT3_BLT          3'b100
`define FUNCT3_BGE          3'b101
`define FUNCT3_BLTU         3'b110
`define FUNCT3_BGEU         3'b111

// Load / Store Instructions (Width)
`define FUNCT3_BYTE         3'b000 // lb, sb
`define FUNCT3_HALF         3'b001 // lh, sh
`define FUNCT3_WORD         3'b010 // lw, sw
`define FUNCT3_BYTE_U       3'b100 // lbu
`define FUNCT3_HALF_U       3'b101 // lhu

// 3. Funct7 Codes (Bits 31:25) 
`define FUNCT7_NORMAL       7'b0000000 // ADD, SRL, etc.
`define FUNCT7_ALT          7'b0100000 // SUB, SRA (Alternative)

// 4. ALU Control Output (Signals to ALU Module)
`define ALU_CTRL_ADD        4'b0010
`define ALU_CTRL_SUB        4'b0110
`define ALU_CTRL_AND        4'b0000
`define ALU_CTRL_OR         4'b0001
`define ALU_CTRL_XOR        4'b0011 // 
`define ALU_CTRL_SLL        4'b0100 // Shift Left Logical
`define ALU_CTRL_SRL        4'b0101 // Shift Right Logical
`define ALU_CTRL_SRA        4'b0111 // Shift Right Arithmetic
`define ALU_CTRL_SLT        4'b1000 // Set Less Than (Signed)
`define ALU_CTRL_SLTU       4'b1001 // Set Less Than Unsigned
`define ALU_CTRL_LUI        4'b1111 // Pass Immediate (LUI) 

// -----------------------------------------------------------------
// 5. ALUOp Codes (Input from Main Control)
// -----------------------------------------------------------------
`define ALUOP_MEM           2'b00 // Load/Store (Add)
`define ALUOP_BRANCH        2'b01 // Branch (Sub)
`define ALUOP_R_TYPE        2'b10 // Determined by funct3/7
`define ALUOP_I_TYPE        2'b11 // (Optional) Often merged with R-type handling or defaults


`endif