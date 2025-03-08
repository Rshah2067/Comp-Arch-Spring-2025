//top level module
// A FSM is used to keep track of the quadrant of the sine wave currently being created to correctly negate/reverse the bits
`include "memory.sv"

module top(
    input logic clk,    
    output logic    _9b,   //D0
    output logic    _6a,   //D1
    output logic    _4a,   //D2
    output logic    _2a,   //D3
    output logic    _0a,   //D4
    output logic    _5a,   //D5
    output logic    _3b,   //D6
    output logic    _49a,  //D7
    output logic    _45a,  //D8
    output logic    _48b   //D9
);
    logic[6:0] address = 0;
    logic[9:0] raw_data;
    logic[9:0] data;
    //FSM states using one hot encoding where first bit is inversion over x axis and 0th bit is inversion over y axis ()
    parameter q1 = 2'b00;
    parameter q2 = 2'b01;
    parameter q3 = 2'b10;
    parameter q4 = 2'b11;

    logic[1:0] state = q1;
    logic[1:0] next_state;
    memory#(
        .INIT_FILE  ("wave.txt")
    ) u1(
        .clk    (clk),
        .invert_data (state[1]),
        .read_address (address),
        .data (raw_data)
    );
    //assign the next FSM State
    always_comb begin
        next_state = 2'bxx;
        case (state)
            q1:
                next_state = q2;
            q2:
                next_state = q3;
            q3:
                next_state = q4;
            q4:
                next_state = q1;
        endcase
    end
    //every clock cycle increment the address that we are reading form memory
    always_ff @(posedge clk) begin
        //Check to see if we have hit the end of a wave quarter (address 127 if we are in q1 or q3 )
        if (address == 127 && (state == q1 || state == q3)) begin
            state = next_state;
        end 
        else if (address == 0 && (state == q2  || state == q4)) begin
            state = next_state;
        end
        //if the wave should not be inverted in order
        if (state[0] == 0) begin 
            address <= address +1;
        end
        //reverse order that the sample is traversed
        else if (state[0] == 1) begin
            address <= address -1;
        end
        if (state[1] == 1) begin
            data <= ~raw_data;
        end
        else begin
            data <= raw_data;
        end
    end
 
    // assign output 
    //We know the MSB of our output/ D9 on our DAC is always high

    assign {_48b, _45a, _49a, _3b, _5a, _0a, _2a, _4a, _6a, _9b} =  data;



endmodule