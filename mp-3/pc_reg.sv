//Small module for the Program counter that just adds the value in the PC register that is supplied by the controller,
//the controller is responsible for either 
module pc_reg (
    input pc_clk,
    input logic pc_mux,
    input logic reset,
    input logic [31:0] rs1,
    input [31:0] increment,
    output logic[31:0] pc,
    output logic [31:0] pc_latched
);

    //on each clock cycle we want to save the new value of pc counter
    always_ff @(posedge pc_clk or posedge reset) begin
        if (reset) begin
            pc <=0;
            pc_latched <=0;
        end else begin
            pc_latched <=pc;
            if (pc_mux)begin
                pc <= rs1 + increment;
            end
            else begin
                pc <= pc + increment;
            end
        end
            //clear the LSB of the PC counter
            pc[0] = 0;
    end
endmodule