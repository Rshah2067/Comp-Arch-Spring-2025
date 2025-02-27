//Heavily Based off of Example PWM Code provided in fade example (didn't make any changes as it works, explored some other ways to create PWM Signals
//but this is the simplest way )
module pwm #(
    parameter PWM_INTERVAL =1200
)(
    input logic clk,
    input logic [$clog2(PWM_INTERVAL)-1:0] pwm_value,
    output logic pwm_out
);
    //PWM Counter
    logic [$clog2(PWM_INTERVAL)-1:0] pwm_count = 0;
    
    always_ff @(posedge clk) begin
        if (pwm_count == PWM_INTERVAL -1) begin
            pwm_count <= 0;
        end
        else begin
            pwm_count <= pwm_count +1;
        end
    end
    //Assigning output as high when we are below the pwm value and low when we are above the pwm value 
    assign pwm_out = (pwm_count > pwm_value) ? 1'b0: 1'b1;
endmodule