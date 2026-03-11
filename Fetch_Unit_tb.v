`timescale 1ns/1ps
module fetch_unit_tb ();
    reg clk;
    reg rst_n;
    reg  pc_sel;
    reg [31:0] jump_add;
    wire [31:0] pc_out;
    reg  [31:0] prev_pc;
fetch_unit uut(
    .clk (clk),
    .rst_n (rst_n),
    .pc_sel (pc_sel),
    .jump_add (jump_add),
    .pc_out (pc_out)
);
initial clk=0;
always #5 clk=~clk;
initial begin
    //System Reset (Global)
    rst_n=0;
    pc_sel=1;
    jump_add=32'h12345678;
    #12 if (pc_out==32'h00000000)
            $display("System Reset (Global) test pass");
        else
            $display("System Reset (Global) test fail");
    // Sequential Execution (PC + 4)
    prev_pc=pc_out;
    rst_n=1;
    pc_sel=0;
    #12 if (pc_out==(prev_pc+4))
            $display("Sequential Execution (PC + 4)-one cycle test pass");
        else
            $display("Sequential Execution (PC + 4)-one cycle test fail");
    prev_pc=pc_out;
    #12 if (pc_out==(prev_pc+4))
            $display("Sequential Execution (PC + 4)-two cycles test pass");
        else
            $display("Sequential Execution (PC + 4)-two cycle test fail");
    prev_pc=pc_out;
    #12 if (pc_out==(prev_pc+4))
            $display("Sequential Execution (PC + 4)-three cycles test pass");
        else
            $display("Sequential Execution (PC + 4)-three cycle test fail");
    //Jump/Branch Selection
    jump_add=32'hABCDEFAA;
    pc_sel=1;
    #12 if (pc_out==32'hABCDEFAA)
            $display("Jump/Branch Selection test pass");
        else
            $display("Jump/Branch Selection test fail");
    //Return to Sequential Flow
    prev_pc=pc_out;
    pc_sel=0;
    #12 if (pc_out==(prev_pc+4))
            $display("Return to Sequential Flow (PC + 4)-one cycle test pass");
        else
            $display("Return to Sequential Flow (PC + 4)-one cycle test fail");
    prev_pc=pc_out;
    #12 if (pc_out==(prev_pc+4))
            $display("Return to Sequential Flow (PC + 4)-two cycles test pass");
        else
            $display("Return to Sequential Flow (PC + 4)-two cycle test fail");
    //PC Overflow (Roll-over)
    jump_add=32'hFFFFFFFC;
    pc_sel=1;
    #12 pc_sel0;
    #12 if (pc_out==32'h00000000)
            $display("PC Overflow (Roll-over) test pass");
        else
            $display("PC Overflow (Roll-over) test fail");
    //Back-to-Back Jumps
    jump_add=32'hAAAAAAAA;
    pc_sel=1;
    #12 if (pc_out==32'hAAAAAAAA)
            $display("Back-to-Back Jumps 1 test pass");
        else
            $display("Back-to-Back Jumps 1 test fail");
    jump_add=32'hA0A0A0A0;
    #12 if (pc_out==32'hA0A0A0A0)
            $display("Back-to-Back Jumps 2 test pass");
        else
            $display("Back-to-Back Jumps 2 test fail");
    $finish;

end
    
endmodule
