//The reciever works by oversampling the input bits to center each bit. Each transmission starts with a start bit pulling the bus from idle high.
//Each transmission is 8 bits long and has a single end bit (no parity check). Once the transmisssion is recieved the line is idled
module uart_reciever(
    input logic clk,
    input logic tick,
    input logic rx,
    output logic [7:0] dout,
    output logic rx_done
);
    
    //state machine for reciever tracks wheter the reciever is idle, starting, or recieving data, or stopped
    //using a one hot encoding
    logic [3:0] state;
    logic [3:0] next_state;
    localparam idle = 4'b0001;
    localparam start =4'b0010;
    localparam data = 4'b0100;
    localparam stop = 4'b1000;
    //counter for the number of ticks.
    logic [3:0] s_reg,s_next;
    //counter for number of data bits
    logic [2:0] n_reg,n_next;
    //shift register containing data bits.Values are shifted in one at a time
    logic [7:0] b_reg,b_next;
    initial begin 
        state = idle;
        s_reg =4'd0;
        n_reg =3'd0;
        b_reg = 8'd0;
    end
    always_ff@(posedge clk) begin   
        state <=next_state;
        b_reg <=b_next;
        n_reg <= n_next;
        s_reg <= s_next;
    end
    //constantly assign dout to the contents of shift register
    assign dout = b_reg;
    //I don't fully like the way this combinitorial logic works, but I can'think of another way to get sensitivity from both required signals in the way needed
    //maybe an always ff with two inputs could work here better?
    always_comb begin
        next_state = state;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        rx_done = 0;
        case (state)
            idle: begin
                //if the line goes low, we know communication has been initiated
                if (!rx)
                    next_state = start;
                    //reset s counter
                    s_next= 4'd0;
            end
            start: begin
                //monitor for s tick
                if (tick)
                    //if this is the 7th tick we advance to data
                    if (s_reg == 4'd7) begin
                        next_state = data;
                        s_next = 0;
                        n_next = 0;
                    end
                    else
                        s_next = s_reg +1;
            end
            data: begin
                if(tick)begin
                    //over sample
                    if (s_reg ==4'd15) begin
                        //reset s counter
                        s_next = 0;
                        //shift in new data bit
                        b_next = {rx,b_reg[7:1]};
                        //check to see if we have recieved all data bits
                        if (n_reg == 3'd7)
                            next_state = stop;
                        else
                            n_next= n_reg+1;
                    end
                    else
                        s_next = s_reg+1;
                end
            end
            stop: begin
                if (tick) begin
                    //wait for 1 end bit
                    if (s_reg == 4'd15) begin
                        //set bus to idle and raise the rx done flag
                        next_state = idle;
                        rx_done = 1;
                    end else 
                        s_next = s_reg+1;
                end
            end
            default:
                next_state = idle;
        endcase
    end
    
endmodule