`timescale 10ns/10ns
`include "UARTcontroller.sv"
module uart_tb;
    logic clk = 0;
    logic [7:0] recieved_data,write_data;
    logic read_en,write_en;
    logic rx,tx;
    UARTcontroller u1 (
        .clk(clk),
        .rx(rx),
        .tx(tx),
        .mem_wr_data(write_data),
        .mem_wr_en(write_en),
        .mem_rd_en(read_en),
        .mem_rd_data(recieved_data)
    );
    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0,uart_tb);
        //write to transmitter
        write_data = 7'b1010101;
        //enable writes
        @(posedge clk);
        write_en = 1;
        @(posedge clk);
        write_en = 0;
        //start sim
    #105000
        $finish;
    end
    always begin
        //when the simulation should be running oscillate the clock
        #4
        clk = ~clk;
    end
endmodule