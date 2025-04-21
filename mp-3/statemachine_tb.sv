`include "statemachine.sv"
`include "pc_reg.sv"
`timescale 10ns/10ns
module statemachine_tb;
    logic clk =0;
    logic pc_clk;
    logic instruct_clk;
    logic mem_clk;
    logic [31:0] pc_output;
    logic reset;
    statemachine u1(
        .clk (clk),
        .pc_clk (pc_clk),
        .instruct_clk (instruct_clk),
        .mem_clk (mem_clk)
    );
    pc_reg u2(
        .pc_clk (clk),
        .increment (32'd4),
        .pc (pc_output),
        .reset (reset)
    );
    initial begin
        $dumpfile("sm_tb.vcd");
        $dumpvars(0,statemachine_tb);
        reset = 1;
        #10
        reset = 0;
        #100
        $finish;
    end
    //pulse clock
    always begin
        #4
        clk = ~clk;
    end
endmodule