//Code is based off of/inspired by Brad's FSM implementation and the various resources provided on good FSM HDL coding practices
module cycle #(
    //Amount of clock cycles that should pass corresponding to traveling 60 degrees on the color wheel.
    //Clock Frequency is 12MHZ and we want to rotate 360 degrees in 1 second and therefore want to use 1/6 of the clock frequency per 60 degrees
    parameter SIXTY_DEGREES_INTERVAL = 2000000,
    //PWM signal goes from 0 to 1200 and we want to go from 0 to max in 2 Million clock cycles. We want to change the PWM signal once every 10000 cycles
    //This means that we will make 200 changes to the PWM value to go from 0 to 1200 and each change should be a step of 6.
    //Amount of cyles before we step the PWM
    parameter RAMP_COUNTER = 10000,
    //Steps of PWM in a full ramp cylce
    parameter PWM_STEPS = 200,
    //Maximum PWM Value
    parameter PWM_INTERVAL = 1200, 
    //Amount PWM should change per step
    parameter PWM_DELTA = PWM_INTERVAL/PWM_STEPS
) (
    input logic clk,
    //Output signals indicating desired PWM value for each light
    output logic [$clog2(PWM_INTERVAL)-1:0] r_pwm,
    output logic [$clog2(PWM_INTERVAL)-1:0] g_pwm,
    output logic [$clog2(PWM_INTERVAL)-1:0] b_pwm
);

    localparam highholding = 3'b000;
    localparam highholdingtwo = 3'b001;
    localparam lowholding = 3'b010;
    localparam lowholdingtwo = 3'b011;
    localparam lowramping = 3'b100;
    localparam highramping = 3'b101;
    //first state of the 
    logic [2:0] current_state = highholdingtwo;
    logic [2:0] next_state;
    //FSM variables
    logic time_to_transition = 1'b0;
    //Amount of clock cycles passed since last state transition
    logic [$clog2(SIXTY_DEGREES_INTERVAL)-1:0] count = 0;
    //Amount of clock cycles since last PWM Step
    logic [$clog2(RAMP_COUNTER)-1:0] pwm_count = 0;
    logic time_to_step = 1'b0;
    //Initial Conditions
    initial begin
        r_pwm = PWM_INTERVAL;
        g_pwm = 0;
        b_pwm = 0;
    end
 
    //advances next state
    always_ff @(posedge time_to_transition)begin
        current_state <= next_state;
    end
    //logic dictating what should be the next state and what the PWM increment should be should be 
    always_comb begin
        next_state = 3'bxxx;
        case (current_state)
            highholdingtwo:
                next_state = lowramping;
            lowramping:
                next_state = lowholding;
            lowholding:
                next_state = lowholdingtwo;
            lowholdingtwo:
                next_state = highramping;
            highramping:
                next_state =highholding;
            highholding:
                next_state = highholdingtwo;
        endcase
    end
    //Advances FSM Counter every clock cycle and step counter
    always_ff @( posedge clk ) begin
        //If we are at the amount  of clock cycles corresponding with 60 degrees than we switch states
        if (count == SIXTY_DEGREES_INTERVAL -1) begin
            //reset count 
            count <=0;
            //transition state flag
            time_to_transition = 1'b1;
            end
        else begin
            //increment the clock signal and PWM counter
            count <= count +1;
            time_to_transition <= 1'b0;
        end
        if (pwm_count == RAMP_COUNTER-1) begin
            //trigger PWM transition
            time_to_step <= 1'b1;
            pwm_count <= 0;
        end
        else begin
            pwm_count <= pwm_count +1;
            time_to_step <= 1'b0;
        end
    end
    always_ff @(posedge time_to_step) begin
        //Update the PWM Value for each signal based on signal shift
        //either 
        if (current_state == highholding) begin
            //green is in high fade blue is in low hold
            r_pwm <= PWM_INTERVAL;
            g_pwm <= 0;
            b_pwm <= b_pwm - PWM_DELTA;
        end
        else if (current_state == lowramping) begin
            //green is in high hold blue is in low hold
            r_pwm <=r_pwm - PWM_DELTA;
            g_pwm <= PWM_INTERVAL;
            b_pwm <= 0;
        end
        else if (current_state == lowholding) begin
            //green is in high hold blue is in high fade
            r_pwm <=0;
            g_pwm <=PWM_INTERVAL;
            b_pwm <= b_pwm + PWM_DELTA;
        end
        else if (current_state == lowholdingtwo) begin
            //green is low fading and blue is high holding
            r_pwm <=0;
            g_pwm <= g_pwm + PWM_DELTA;
            b_pwm <= PWM_INTERVAL;
        end
        else if (current_state == highramping) begin
            //green is low holding blue is high holding
            r_pwm <= r_pwm +PWM_INTERVAL;
            g_pwm <= 0;
            b_pwm <= PWM_INTERVAL;
        end
        else if (current_state == highholdingtwo) begin
            //green is holding low, blue is fading low
            r_pwm <= PWM_INTERVAL;
            g_pwm <= 0;
            b_pwm <= b_pwm - PWM_DELTA;
        end
    end
endmodule
