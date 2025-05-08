//controller that manages the FIFOS for each TX and RX module as well as well as routing data from memory to handle reads/writes
`include "uart_reciever.sv"
`include "uart_transmitter.sv"
`include "baudrate_generator.sv"
`include "FIFO.sv"
module UARTcontroller(
    input logic clk,
    input logic rx,
    output logic tx,
    //memmory wrapped controls
    input logic mem_wr_en,
    input logic[7:0] mem_wr_data,
    output logic tx_fifo_full,
    input logic mem_rd_en,
    output logic [7:0] mem_rd_data,
    output logic rx_fifo_empty
);
    //transmitter internal wires
    logic tx_start,tx_done;
    logic [7:0] tx_data;
    logic [7:0] tx_fifo_dout;
    logic tx_fifo_empty;
    logic tx_fifo_rd_en;
    logic tick;
    //RX internal wires
    logic [7:0] rx_data;
    logic rx_done;
    logic rx_fifo_wr_en;
    logic rx_fifo_full;
    logic tx_fifo_valid;
    logic data_accepted;
    //TX FIFO
    FIFO u1(
        .clk(clk),
        .wr_en(mem_wr_en),
        .rd_en(tx_fifo_rd_en),
        .din(mem_wr_data),
        .dout(tx_fifo_dout),
        .empty(),
        .full(tx_fifo_full),
        .valid(tx_fifo_valid),
        .data_accepted(data_accepted)
    );
    //RX FIFO
    FIFO u2(
        .clk(clk),
        .wr_en(rx_fifo_wr_en),
        .rd_en(mem_rd_en),
        .din(rx_data),
        .dout(mem_rd_data),
        .empty(rx_fifo_empty),
        .full(rx_fifo_full)
    );
    uart_reciever u3(
        .clk(clk),
        .tick(tick),
        .rx(rx),
        .dout(rx_data),
        .rx_done(rx_done)
    );
    uart_transmitter u4(
        .clk(clk),
        .tick(tick),
        .din(tx_data),
        .tx_start(tx_start),
        .tx_done(tx_done),
        .tx(tx)
    );
    baudrate_generator u5(
        .clk(clk),
        .tick(tick)
    );
    //transmitter controller
    logic [1:0] tx_state,tx_state_n;
    localparam TX_IDLE = 2'b00;
    localparam TX_START = 2'b10;
    initial begin
        tx_state = TX_IDLE;
    end
    always_comb begin
        //move to idle if the transmission is done, start new transmission is transmission is idle and there is stuff in buffer, or hold
        if (tx_state == TX_START &&tx_done)
            tx_state_n = TX_IDLE;
        else if (tx_state == TX_IDLE && tx_fifo_valid)
            tx_state_n =TX_START;
        else
            tx_state_n = tx_state;
    end
    always_ff@(posedge clk)begin
        tx_state <= tx_state_n;
    end
    //start the transmitter when idled and the buffer is not emptey
    assign tx_start = tx_fifo_valid;
    assign tx_fifo_rd_en = tx_start;
    assign tx_data = tx_fifo_dout;
    //allow writing to the fifo when reciever is done and the reciever is not full
    assign rx_fifo_wr_en = rx_done &&!rx_fifo_full;
    assign data_accepted = tx_start;

endmodule