`include "cycle.sv"
`include "pwm.sv"

module top #(
    parameter PWM_INTERVAL =1200
)(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_B,
    output logic    RGB_G
);
  logic [$clog2(PWM_INTERVAL)-1:0] r_pwm;
  logic [$clog2(PWM_INTERVAL)-1:0] g_pwm;
  logic [$clog2(PWM_INTERVAL)-1:0] b_pwm;

  logic red_led;
  logic green_led;
  logic blue_led;
  cycle #(
        .PWM_INTERVAL (PWM_INTERVAL)
  )u1
  (
        .clk (clk),
        .r_pwm (r_pwm),
        .g_pwm (g_pwm),
        .b_pwm (b_pwm)
  );
  //Could use a procedural for loop here but not worth it IMO
  //PWM Module for R
  pwm #(
    .PWM_INTERVAL (PWM_INTERVAL)
  )u2(
    .clk (clk),
    .pwm_value (r_pwm),
    .pwm_out (red_led)
  );

pwm #(
    .PWM_INTERVAL (PWM_INTERVAL)
  )u3(
    .clk (clk),
    .pwm_value (g_pwm),
    .pwm_out (green_led)
);
pwm #(
    .PWM_INTERVAL (PWM_INTERVAL)
  )u4(
    .clk (clk),
    .pwm_value (b_pwm),
    .pwm_out (blue_led)
);
assign RGB_B = ~blue_led;
assign RGB_G = ~green_led;
assign RGB_R = ~red_led;
endmodule