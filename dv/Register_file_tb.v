`timescale 1ns/1ps
module register_file_tb ();
reg clk=0;
reg reg_write;
reg [4:0] read_reg_1;
reg [4:0] read_reg_2;
reg [4:0] write_reg;
reg [31:0] write_data;
wire [31:0] read_data_1;
wire [31:0] read_data_2;
reg [31:0] temp_reg_1;
reg [31:0] temp_reg_2;

register_file uut(
    .clk (clk),
    .reg_write (reg_write),
    .read_reg_1 (read_reg_1),
    .read_reg_2 (read_reg_2),
    .write_reg (write_reg),
    .write_data (write_data),
    .read_data_1 (read_data_1),
    .read_data_2 (read_data_2)
);
always #5 clk = ~clk;
integer i;
initial begin
    uut.reg_file[0]=32'b0;
    for (i =1 ;i<32 ;i=i+1 ) begin
        uut.reg_file[i]=$urandom();
    end
    
    //Synchronous Write & Read
    reg_write=1;
    write_data=32'h00000001;
    write_reg=1;
    read_reg_1=1;
    #12 if (uut.reg_file[1]==32'h00000001)
            $display("Synchronous Write test pass");
        else $display("Synchronous Write test fail");
        if(read_data_1==32'h00000001)
            $display("Synchronous Read test pass");
        else $display("Synchronous Read test fail"); 

    // Dual-Port Independent Reads
    reg_write=0;
    temp_reg_1=uut.reg_file[5];
    temp_reg_2=uut.reg_file[13];
    read_reg_1=5;
    read_reg_2=13;
    #12 if (read_data_1==temp_reg_1)
            $display("Read from read_data_1 test pass");
        else $display("Read from read_data_1 test fail");
    if(read_data_2==temp_reg_2)
            $display("Read from read_data_2 test pass");
    else $display("Read from read_data_2 test fail");

    //Asynchronous Combinatorial Read Timing
    temp_reg_1=uut.reg_file[12];
    temp_reg_2=uut.reg_file[15];
    read_reg_1=12;
    read_reg_2=15;
    #1;
    if (read_data_1==temp_reg_1)
            $display("Asynchronous Combinatorial Read Timing_1 test pass");
        else $display("Asynchronous Combinatorial Read Timing_1 test fail");
    if(read_data_2==temp_reg_2)
            $display("Asynchronous Combinatorial Read Timing_2 test pass");
    else $display("Asynchronous Combinatorial Read Timing_2 test fail");

    //Write Enable (`reg_write`) Validation
    write_reg=7;
    reg_write=0;
    temp_reg_1=uut.reg_file[write_reg];
    if(temp_reg_1!=32'h0000000C)
        write_data=32'h0000000C;
    else
        write_data=32'h00000004;
    #12 if (uut.reg_file[write_reg]==temp_reg_1)
            $display("Write Enable (`reg_write`) Validation test pass");
        else $display("Write Enable (`reg_write`) Validation test fail");
    
    //Register x0 Hardwired Zero (Write Prevention)
    reg_write=1;
    write_data=32'h00000009;
    write_reg=0;
    #12 if (uut.reg_file[0]==32'b0)
            $display("Register x0 Hardwired Zero (Write Prevention) test pass");
        else $display("Register x0 Hardwired Zero (Write Prevention) test fail");
    //Register x0 Hardwired Zero (Read Forcing)
    reg_write=0;
    read_reg_1=0;
    read_reg_2=0;
    #12 if (read_data_1==32'b0 && read_data_2==32'b0)
            $display("Register x0 Hardwired Zero (Read Forcing) test pass");
        else $display("Register x0 Hardwired Zero (Read Forcing) test fail");
    //Read-After-Write (RAW) in Single-Cycle
    reg_write = 1;
    write_reg = 10;
    write_data = 32'hDEADC0DE;
    read_reg_1 = 10; 
    #1; 
    $display("RAW Before edge: read_data_1 = %h (Expected old value)", read_data_1);
    #12
    if (read_data_1 == 32'hDEADC0DE)
        $display("TC_07 (RAW) Pass: Data updated to %h after edge", read_data_1);
    else
        $display("TC_07 (RAW) Fail: Expected DEADC0DE, got %h", read_data_1);
    //Asynchronous Data Integrity
    reg_write = 1;
    write_reg = 15;
    write_data = 32'hCAFEBABE;
    if (uut.reg_file[15] != 32'hCAFEBABE)
        $display("TC_08 (Async Integrity) Pass");
    else
        $display("TC_08 (Async Integrity) Fail");

    #12;
    if (uut.reg_file[15] == 32'hCAFEBABE)
        $display("TC_08 (Sync Verification) Pass");

    $finish;

end
endmodule