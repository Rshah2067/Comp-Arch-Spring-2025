`include "top.sv"
`timescale 10ns/10ns
module top_tb;
    logic clk = 0;
    logic RGB_B;
    logic RGB_G;
    logic RGB_R;
    logic LED;
    logic reset;
    logic [31:0] temp;
    //helper functions
    //I type instruction
    top u1(
        .clk (clk),
        .BOOT (reset),
        .RGB_R (RGB_R),
        .RGB_B (RGB_B),
        .RGB_G (RGB_G),
        .LED (LED)
    );
    initial begin
        int fd;
        int i;
        $dumpfile("top_tb.vcd");
        $dumpvars(0,top_tb);
        reset = 1;
        #1;
        reset = 0;
        //start sim
        #500;
        temp = (32'hf0123456<<32'd2);
        $display("test %h",temp);
        //dump contents of register file to text file
        // Open file to write to
        fd = $fopen("memory_dump.txt", "w");

       // Dump memory contents
       for (i = 0; i < 31; i++) begin
            $fdisplay(fd, "%0d: %h", i, u1.u3.register[i]);
       end
        $finish;

    end
    always begin
        //when the simulation should be running oscillate the clock
            #4
            clk = ~clk;
    end
endmodule
