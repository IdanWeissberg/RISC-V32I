`timescale 1ns/1ps
module data_mem_tb ();
reg clk=0;
reg [31:0] add_in;
reg [31:0] write_data;
reg mem_write;
reg mem_read;
wire [31:0 ] read_data;
data_mem uut (
    .clk (clk),
    .add_in (add_in),
    .write_data (write_data),
    .mem_write (mem_write),
    .mem_read (mem_read),
    .read_data (read_data)
);
always #5 clk=~clk;
initial begin
   // Initialization & Combinatorial Read
   mem_write=0;
   mem_read=1;
   add_in=32'h00000000;
   #1;
    if (read_data==32'h00000000) 
        $display("Initialization & Combinatorial Read test for d_mem %h pass",add_in);
    else
        $display("Initialization & Combinatorial Read test for d_mem %h fail",add_in);
    add_in=32'h00000004;
    #1;
    if (read_data==32'h000D0001) 
        $display("Initialization & Combinatorial Read test for d_mem %h pass",add_in);
    else
        $display("Initialization & Combinatorial Read test for d_mem %h fail",add_in);
    add_in=32'h00000008;
    #1;
    if (read_data==32'hA0000002) 
        $display("Initialization & Combinatorial Read test for d_mem %h pass",add_in);
    else
        $display("Initialization & Combinatorial Read test for d_mem %h fail",add_in);
    add_in=32'h0000000C;
    #1;
    if (read_data==32'h00B00003) 
        $display("Initialization & Combinatorial Read test for d_mem %h pass",add_in);
    else
        $display("Initialization & Combinatorial Read test for d_mem %h fail",add_in);
    //Disabled Read Behavior
    mem_read=0;
    add_in=32'h00000008;
    #1;
    if (read_data==32'h00000000)
        $display("Disabled Read Behavior test pass");
    else
        $display("Disabled Read Behavior test fail , read_data= %h *check if it is not make match with the 3 test of the tb",read_data);
    //Synchronous Write Operation
    mem_write=1;
    add_in=32'h00000004;
    write_data=32'hABC00000;
    @(posedge clk);
    #1 mem_write=0;
    mem_read=1;
    #1;
    if (read_data==32'hABC00000)
        $display("Synchronous Write Operation test pass");
    else
        $display("Synchronous Write Operation test fail,read_deta=  %h  *check if it is not make match with the 2 test of the tb", read_data );
    //Write Enable Isolation (Disabled Write)
    mem_write=0;
    add_in=32'h00000000;
    write_data=32'hABCDEF55;
    mem_read=1;
    @(posedge clk);
    if (read_data==32'h00000000)
        $display("Write Enable Isolation (Disabled Write) test pass");
    else   
        $display("Write Enable Isolation (Disabled Write) test fail");
    $finish;    
end

    
endmodule