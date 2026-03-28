`include "riscv_defs.vh"
module branch_comparator (
    input wire [31:0] rs_1,
    input wire [31:0] rs_2,
    input wire [31:0] instruction,
    output reg branch_decision
);
wire [2:0] funct_3_branch = instruction[14:12];
always @(*) begin
    branch_decision=0;
    case (funct_3_branch)
        `FUNCT3_BEQ: begin
            if(rs_1==rs_2)
                branch_decision=1;
        end
        `FUNCT3_BNE : begin
            if(rs_1!=rs_2)
                branch_decision=1;
        end
        `FUNCT3_BLT: begin
            if($signed(rs_1)<$signed(rs_2))
                branch_decision=1;
        end
        `FUNCT3_BGE :begin
            if($signed(rs_1)>=$signed(rs_2))
                branch_decision=1;
        end
        `FUNCT3_BLTU : begin
            if($unsigned(rs_1)<$unsigned(rs_2))
                branch_decision=1;
        end
        `FUNCT3_BGEU : begin
            if($unsigned(rs_1)>=$unsigned(rs_2))
                branch_decision=1;
        end
        default: branch_decision=0;
    endcase
    
end
    
endmodule