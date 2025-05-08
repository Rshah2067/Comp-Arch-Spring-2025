//8 by 4 FIFO to buffer reads/writes from UART
module FIFO(
    input logic clk,
    input logic wr_en,
    input logic rd_en,
    input logic [7:0]din,
    output logic [7:0]dout,
    output logic empty,
    output logic full,
    output logic valid,
    input  logic data_accepted
);
    logic [3:0] wptr;
    logic [3:0] rptr;
    //memory array being used as fifo
    logic [7:0] fifo [4:0];
    logic [4:0] count;
    logic valid_reg;
    //initialize fifo to all 0s
    int i;
    initial begin
        //set the pointers to 0
        wptr = 4'd0;
        rptr = 4'd0;
        for (i=0;i<16;i++)begin
            fifo[i] = 8'd0;
        end
        count = 0;
    end
    //input register
    always_ff@(posedge clk)begin
        if(wr_en & !full)begin
            fifo[wptr] <= din;
            wptr <= (wptr == 4'd15) ? 0 : wptr + 1;
            count <= count + 1;
        end
    end
    //output register
always_ff @(posedge clk ) begin
    if (valid_reg) begin
    if (data_accepted) begin
        // Consumer accepted data, move to next element
        if (count > 0) begin
        dout <= fifo[rptr];
        rptr <= (rptr == 4'd15) ? 0 : rptr + 1;
        count <= count - 1;
        valid_reg <= (count > 1); // stay valid if more data exists
        end else begin
        valid_reg <= 0;
        end
    end
    end else if (count > 0) begin
    // Initial load after reset or after previous data was accepted
    dout <= fifo[rptr];
    valid_reg <= 1;
    end
end
//check to see if the mem is full or empty
assign empty = (count == 0);
assign full  = (count == 16);
assign valid = valid_reg;
endmodule