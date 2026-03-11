`timescale 1ns/1ps

module instruction_memory_tb();
    reg clk = 0;
    reg [31:0] addr;
    wire [31:0] instruction;

    instruction_memory uut(
        .addr(addr),
        .instruction(instruction)
    );

    always #5 clk = ~clk;

    initial begin
        // Memory Initialization ($readmemh)
        addr = 32'h0;
        #12;
        if(instruction == 32'h002081B3)
            $display("Memory Initialization ($readmemh) test pass");
        else
            $display("Memory Initialization ($readmemh) test fail");

        // Word-Alignment Logic (Byte-to-Word)
        addr = 32'h00000001;
        #12;
        if(instruction == 32'h002081B3)
            $display("Word-Alignment Logic (Byte-to-Word) 1 test pass");
        else
            $display("Word-Alignment Logic (Byte-to-Word) 1 test fail");

        addr = 32'h00000002;
        #12;
        if(instruction == 32'h002081B3)
            $display("Word-Alignment Logic (Byte-to-Word) 2 test pass");
        else
            $display("Word-Alignment Logic (Byte-to-Word) 2 test fail");

        addr = 32'h00000003;
        #12;
        if(instruction == 32'h002081B3)
            $display("Word-Alignment Logic (Byte-to-Word) 3 test pass");
        else
            $display("Word-Alignment Logic (Byte-to-Word) 3 test fail");

        // Asynchronous Combinatorial Read
        addr = 32'h00000004;
        #1;
        if(instruction == 32'h00512023)
            $display("Asynchronous Combinatorial Read test pass");
        else
            $display("Asynchronous Combinatorial Read test fail");

        // Sequential Addressing (PC+4)
        addr = 32'h00000008;
        #12;
        if(instruction == 32'h00000013)
            $display("Sequential Addressing (PC+4) 1 test pass");
        else
            $display("Sequential Addressing (PC+4) 1 test fail");
        // Boundary Access (Max)
        addr = 32'h00000FFC;
        #12;
        if(instruction == 32'hDEADBEEF)
            $display("Boundary Access (Max) test pass");
        else
            $display("Boundary Access (Max) test fail");

        $finish;
    end

endmodule