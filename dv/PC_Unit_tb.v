`timescale 1ps/1ps
module pc_unit_tb ();
reg clk=0;
reg rst_n;
reg [31:0] next_pc;
wire [31:0] current_pc;

pc_unit uut(
.clk (clk),
.rst_n (rst_n),
.next_pc (next_pc),
.current_pc (current_pc)
);
always #5 clk=~clk;
initial begin
    //Power on reset
    rst_n=0;
    #12 if (current_pc==32'b0)
            $display("Reset test pass");
        else
            $display("Reset test fail");
    //Reset recovery
        rst_n=1;
        next_pc=32'hAAAAAAAA;
    #12 if (current_pc==32'hAAAAAAAA)
            $display("Reset rocovery test pass");
        else 
            $display("Reset recovery test fail");
    //Basic Synchronous Load
        next_pc=32'hA0A0A0A0;
    #12 if (current_pc==32'hA0A0A0A0)
            $display("Basic Synchronous Load pass");
        else
             $display("Basic Synchronous Load fail");
    // Asynchronous Reset Behavior (Mid-Cycle)
    #4 rst_n=0;
    #8 if (current_pc==32'b0)
            $display("Asynchronous Reset test pass");
        else
            $display("Asynchronous Reset test fail");
    //Full-Range Bit Toggle (32-bit Integrity)
    rst_n=1;
    next_pc=32'hAAAAAAAA;
    #12 next_pc=32'h55555555;
    #12 if (current_pc==32'h55555555)
            $display("Full-Range Bit Toggle test pass");
        else
            $display("Full-Range Bit Toggle test fail");
    //Maximum Address Stability
    next_pc=32'hFFFFFFFF;
    #12 if (current_pc==32'hFFFFFFFF)
            $display("Maximum Address Stability test pass");
        else
            $display("Maximum Address Stability test fail");
    // Hold & Stability Test
    next_pc=32'hAAAAAAAA;
    #32 if (current_pc==32'hAAAAAAAA)
            $display("Hold & Stability test pass");
        else
            $display("Hold & Stability test fail");
    $finish;

end
    
endmodule