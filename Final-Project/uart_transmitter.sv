//The transmitter is very similar to the reciever but instead of oversampling it holds the output for 16 ticks. It's state machine
//follows the same states as the reciever, except it is driving bus
module uart_transmitter(
    input logic clk,
    input logic tick,
    input logic [7:0] din,
    input logic tx_start,
    output logic tx_done,
    output logic tx
);
    //Same FSM logic as reciever
    logic [3:0] state;
    logic [3:0] next_state;
    localparam idle = 4'b0001;
    localparam start =4'b0010;
    localparam data = 4'b0100;
    localparam stop = 4'b1000;
    //same bit number, tick trackers, and data register
    logic [4:0] s_reg,s_next;
    logic [3:0] n_reg,n_next;
    logic [7:0] b_reg,b_next;
    //contains value currently be transmitted on bus
    logic tx_reg, tx_next;
    initial begin 
        state = idle;
        s_reg =4'd0;
        n_reg =3'd0;
        b_reg = 8'd0;
        tx_reg = 0;
    end
    //advance FSM and latch new values
    always_ff@(posedge clk) begin   
        state <=next_state;
        b_reg <=b_next;
        n_reg <= n_next;
        s_reg <= s_next;
        tx_reg <= tx_next;
    end
    //always ouput the tx signal
    assign tx = tx_reg;
    always_comb begin
        next_state = state;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        tx_next = tx_reg;
        tx_done = 0;
        case (state)
            idle: begin
                //transmit high to keep bus idle
                tx_next = 1;
                //if asked to start transmission shift state to start and set the bytes to be transmitted to din
                if(tx_start)begin
                    next_state = start;
                    s_next = 0;
                    b_next = din;
                end
            end
            start:begin
                //transmit start bit
                tx_next = 1'b0;
                if (tick)begin
                //wait for 16 pulses
                if (s_reg ==4'd15)begin
                    next_state = data;
                    s_next = 0;
                    n_next =0;
                end
                else
                    s_next = s_reg +1;
                end
            end
            data:begin
                //transmit current data bit
                tx_next = b_reg[0];
                //every tick we are going to check if we are done with this bit
                if (tick)begin
                    if (s_reg ==4'd15)begin
                        ///reset tick counter and shift the data register for next bit
                        s_next = 0;
                        b_next = b_reg >>1;
                        //check if the last data bit has been sent
                        if (n_reg == 3'd7)
                            next_state = stop;
                        else
                            n_next = n_reg +1;
                    end
                    else
                        s_next = s_reg +1;
                end
            end
            stop:begin
                //set transmission line to stop
                tx_next = 1;
                if(tick) begin
                    //transmit 1 stop bit
                    if (s_reg ==15)begin
                        //finish transmission
                        next_state = idle;
                        tx_done = 1;
                    end
                    else
                        s_next = s_reg +1;
                end
            end
            default:
                next_state = idle;
        endcase
    end
endmodule