//CODE INCLUDES EXAMPLE CODE FROM FSM MACHINE AND LED BLINK EXAMPLE
//CHAT GPT was used to help debug code and was used in conjuction with Textbook to understand syntax
module top(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_B,
    output logic    RGB_G
);
    //State Values that correspond to Color states
    localparam RED = 3'b000;
    localparam YELLOW = 3'b001;
    localparam GREEN = 3'b010;
    localparam CYAN = 3'b011;
    localparam BLUE = 3'b100;
    localparam MAGENTA = 3'b101;
    
    //State Variables
    logic[2:0] currentstate = RED;
    logic[2:0] next_state;
    //Output Variables
    logic next_red,next_green,next_blue;
    // Clock is 12MHZ and we have 6 colors we want to cycle through every 1s
    parameter COLOR_INTERVAL = 2000000;
    //Clock Counter
    logic [$clog2(COLOR_INTERVAL) - 1:0] count = 0;
    //Updates our Clock Counter every clock cycle, if 2 million clock cycles have passed we switch color
    always_ff @(posedge clk) begin
        //Triggers if we are at the 
        if (count == COLOR_INTERVAL - 1) begin
            count <= 0;
            //Advance FSM to next state
            currentstate <=next_state;
            //Set RGB LED based on current state
            RGB_B <= next_blue;
            RGB_G <= next_green;
            RGB_R <= next_red;
        end
        else begin
            //iterate counter
            count <= count + 1;
        end
    end
    //Compute RGB combination based on state
    always_comb begin
        next_red = 1'b0;
        next_green = 1'b0;
        next_blue = 1'b0;
        case(currentstate)
            RED:begin
                next_red = 1'b1;
                next_green = 1'b0;
                next_blue = 1'b0;
            end
            YELLOW:begin
                next_red = 1'b1;
                next_green = 1'b1;
                next_blue = 1'b0;
            end
            GREEN:begin
                next_red = 1'b0;
                next_green = 1'b1;
                next_blue = 1'b0;
            end
            CYAN:begin
                next_red = 1'b0;
                next_green = 1'b1;
                next_blue = 1'b1;
            end
            BLUE:begin
                next_red = 1'b0;
                next_green = 1'b0;
                next_blue = 1'b1;
            end
            MAGENTA:begin
                next_red = 1'b1;
                next_green = 1'b0;
                next_blue = 1'b1;
            end
        endcase
    end
    //Finite State Machine
    always_comb begin
        next_state = RED;
        case (currentstate)
            RED:  
                next_state = YELLOW;
            YELLOW:
                next_state = GREEN;
            GREEN:
                next_state = CYAN;
            CYAN:
                next_state = BLUE;
            BLUE:
                next_state = MAGENTA;
            MAGENTA:
                next_state = RED;
        endcase
    end

endmodule