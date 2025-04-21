//Register File following RISCIV-32 Standard
//Register Mapping
//zero x0 zero (write protected)
//ra x1 return address
//sp x2 stack pointer
//gp x3 global pointer
//tp x4 thread pointer
//t0-2 x5-7 temp registers
//s0/fp x8 save register/Frame Pointer
//s1 x9 saved register
//a0-1 x10-11 Function Arguements/Return Values
//a2-7 x12-17 Function Arguements
//s2-11 x18-27 saved registers
//t3-6 x28-31 temp registers
module registerfile (
    input logic clk,
    input logic [4:0] read_address_1 ,
    input logic [4:0] read_address_2 ,
    input logic [4:0] write_address ,
    input logic [31:0] write_value ,
    input logic write_enable,
    output logic [31:0]read_data_1 ,
    output logic [31:0]read_data_2
);
//the registers are represented as a memory array
logic [31:0] register [31:0];
//Load in Register File Memory as all 0s
int i;
initial begin
    for (i = 0; i < 31; i++) begin
        register[i] = 32'd0;
    end
end
//Register file latches on negative edge
//handeling reads async
always_comb begin
    //assign read values
    read_data_1 = register[read_address_1];
    read_data_2= register[read_address_2];
end

//Handeling Writes
always_ff@(negedge clk) begin
    //check for write flag
    if (write_enable) begin
        //check if the write address is to the 0 register, in which case it is ignored
        if (write_address == 5'd0) begin
            //Do nothing
        end
        else
            register[write_address] <= write_value;
    end
end
endmodule