//Small module for the Program counter that just adds the value in the PC register that is supplied by the controller,
//the controller is responsible for either 
module pc (
    input pc_clk,
    input [31:0] increment,
    output logic[31:0] pc
);
    logic[31:0] counter;
    //adder that does our add operation
    always_comb begin
        counter = pc + increment;
    end 
    //on each clock cycle we want to save the new value of pc counter
    always_ff @( pc_clk ) begin
        pc <= counter;
    end
endmodule