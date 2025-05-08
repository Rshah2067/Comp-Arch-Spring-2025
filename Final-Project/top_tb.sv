`include "top.sv"
`timescale 10ns/10ns
module top_tb;
    logic clk = 0;
    logic RGB_B;
    logic RGB_G;
    logic RGB_R;
    logic LED;
    logic reset;
    top u1(
        .clk (clk),
        .RGB_R (RGB_R),
        .RGB_B (RGB_B),
        .RGB_G (RGB_G),
        .LED (LED)
    );
    initial begin
        int fd;
        int fm;
        int i;
        logic [31:0] word;
        $dumpfile("top_tb.vcd");
        $dumpvars(0,top_tb);
        //start sim
        #1000;
        //dump contents of register file to text file
        // Open file to write to
        fd = $fopen("register_dump.txt", "w");
       // Dump memory contents
       for (i = 0; i < 31; i++) begin
            $fdisplay(fd, "%0d: %h", i, u1.u3.register[i]);
       end
       fm = $fopen("mem_dump.txt","w");
       for (i=0; i<2047; i++) begin
            word = {u1.u5.mem3.memory[i], u1.u5.mem2.memory[i], u1.u5.mem1.memory[i],u1.u5.mem0.memory[i]};
            $fdisplay(fm, "%0d: %h", i, word); 
       end
        $finish;

    end
    always begin
        //when the simulation should be running oscillate the clock
            #4
            clk = ~clk;
    end
endmodule
