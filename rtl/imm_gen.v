`include "riscv_defs.vh"

module imm_gen (
    input wire [31:0] instruction,
    output reg [31:0] immediate
);

always @(*) begin
    immediate=32'b0;
    case (instruction[6:0])//OP-CODE
        // I-Type
        `OPCODE_I_TYPE,`OPCODE_LOAD,`OPCODE_JALR: immediate={{20{instruction[31]}},instruction[31:20]}; 
        //S-Type
        `OPCODE_STORE:immediate={{20{instruction[31]}},instruction[31:25],instruction[11:7]};
        //B Type
        `OPCODE_BRANCH: immediate={{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
        //U-Type
        `OPCODE_LUI,`OPCODE_AUIPC: immediate={instruction[31:12],12'b0};
        //J-Type
        `OPCODE_JAL:immediate={{11{instruction[31]}},instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};

    endcase  
end
    
endmodule
