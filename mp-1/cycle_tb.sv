`timescale 10ns/10ns
`include "top.sv"
module cycle_tb;
    parameter PWM_INTERVAL = 1200;
    logic clk = 0;
    logic RGB_B;
    logic RGB_G;
    logic RGB_R;

    top # (
        .PWM_INTERVAL (PWM_INTERVAL)
    )u0 (
        .clk (clk),
        .RGB_R  (RGB_R),
        .RGB_B  (RGB_B),
        .RGB_G  (RGB_G)
    );

    initial begin
        $dumpfile("cycle.vcd");
        $dumpvars(0,cycle_tb);
         #80000000
         $finish;
    end
    always begin
        #4
        clk = ~clk;
    end
endmodule