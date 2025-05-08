//UART requires 16 ticks per data bit. This core is hardcoded to support a baud rate of 9600. This means that every second 153600ticks need to be generated
//That means that every 78 clock cycles we should produce one tick
module baudrate_generator (
    input logic clk,
    output logic tick
);
    logic [7:0] tick_counter;
    logic [7:0] next_tick;
    initial begin
        tick_counter =18'd0;
    end 

    always_ff@(posedge clk)begin
        //assign tick counter to its next value
        tick_counter <= next_tick;
    end
    //determine what the next value of the tick counter should be 
    assign next_tick = (tick_counter == 7'd78) ? 0:(tick_counter+7'd1);
    //when the tick counter is zero send a tick
    assign tick = (tick_counter != 7'd0) ? 0:1;
endmodule