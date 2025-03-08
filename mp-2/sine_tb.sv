`timescale 10ns/10ns
`include "top.sv"

module sine_tb;
    logic clk =0;
    logic _48b, _45a, _49a, _3b, _5a, _0a, _2a, _4a, _6a, _9b;
    
    top u1 (
        .clk (clk),
        ._9b (_9b),
        ._6a (_6a),
        ._4a (_4a),
        ._2a (_2a),
        ._0a (_0a),
        ._5a (_5a),
        ._3b (_3b),
        ._49a (_49a),
        ._45a (_45a),
        ._48b (_48b)
    );
    initial begin
        $dumpfile("sine.vcd");
        $dumpvars(0,sine_tb);
        #10000
        $finish;
    end
    always begin
        #4
        clk = ~clk;
    end
endmodule