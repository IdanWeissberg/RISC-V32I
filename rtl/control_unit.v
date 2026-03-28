
`include "riscv_defs.vh"

module control_unit (
    input wire [6:0] op_code,
    output reg jal_branch_mux,
    output reg jalr,
    output reg mem_read,
    output reg branch,
    output reg [1:0] mem_to_reg,
    output reg mem_write,
    output reg alu_src,
    output reg reg_write,
    output reg [1:0] alu_op 
);
always @(*) begin
    case (op_code)
     `OPCODE_R_TYPE : begin
        jal_branch_mux=1'b0;
        jalr=1'b0;
        mem_read=1'b0;
        branch=1'b0;
        mem_to_reg=2'b00;
        mem_write=1'b0;
        alu_op=2'b10;
        alu_src=1'b0;
        reg_write=1'b1;
     end
     `OPCODE_I_TYPE : begin
        jal_branch_mux=1'b0;
        jalr=1'b0;
        mem_read=1'b0;
        branch=1'b0;
        mem_to_reg=2'b00;
        mem_write=1'b0;
        alu_op=2'b11;// Same as R type 
        alu_src=1'b1;
        reg_write=1'b1;
     end
     `OPCODE_LOAD : begin
        jal_branch_mux=1'b0;
        jalr=1'b0;
        mem_read=1'b1;
        branch=1'b0;
        mem_to_reg=2'b01;
        mem_write=1'b0;
        alu_op=2'b00;
        alu_src=1'b1;
        reg_write=1'b1;
     end
     `OPCODE_BRANCH : begin
        jal_branch_mux=1'b1;
        jalr=1'b0;
        mem_read=1'b0;
        branch=1'b1;
        mem_to_reg=2'b00;
        mem_write=1'b0;
        alu_op=2'b01;
        alu_src=1'b0;
        reg_write=1'b0;
     end
     `OPCODE_STORE : begin
        jal_branch_mux=1'b0;
        jalr=1'b0;
        mem_read=1'b0;
        branch=1'b0;
        mem_to_reg=2'b00;
        mem_write=1'b1;
        alu_op=2'b00;
        alu_src=1'b1;
        reg_write=1'b0;
     end
     `OPCODE_JAL : begin
        jal_branch_mux=1'b0;
        jalr=1'b0;
        mem_read=1'b0;
        branch=1'b1;
        mem_to_reg=2'b10;
        mem_write=1'b0;
        alu_op=2'b01;
        alu_src=1'b0;
        reg_write=1'b1;
     end
     `OPCODE_JALR : begin
        jal_branch_mux=1'b0;
        jalr=1'b1;
        mem_read=1'b0;
        branch=1'b0;
        mem_to_reg=2'b00;
        mem_write=1'b0;
        alu_op=2'b00;
        alu_src=1'b1;
        reg_write=1'b0; 
     end
        default: begin
        jal_branch_mux=1'b0;
        jalr=1'b0;
        mem_read=1'b0;
        branch=1'b0;
        mem_to_reg=2'b10;
        mem_write=1'b0;
        alu_op=2'b00;
        alu_src=1'b0;
        reg_write=1'b1; 
        end
    endcase    
end

    
endmodule