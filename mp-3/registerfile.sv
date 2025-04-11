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
    input logic read_address_1 [4:0],
    input logic read_address_2 [4:0],
    input logic write_address [4:0],
    input logic write_value [31:0],
    input logic write_enable,
    output logic read_data_1 [31:0],
    output logic read_data_2 [31:0]
);
logic [31:0] read_value_1;
logic [31:0] read_value_2;
//the registers are represented as a memory array
logic [31:0] registers [31:0];
//Load in Register File Memory as all 0s
int i;
initial begin
    for (i = 0; i < 4096; i++) begin
        memory[i] = 32'd0;
    end
end
//Register file latches on negative edge
//handeling reads
always_ff(@negedge clk) begin
    //assign read values
    read_value_1 <= register[read_address_1];
    read_value_2 <= register[read_address_2];
end
always_comb begin
    read_data_1 = read_value_1;
    read_data_2 = read_value_2
end
//Handeling Writes
always_ff(@negedge clk) begin
    //check for write flag
    if (write_enable) begin
        //check if the write address is to the 0 register, in which case it is ignored
        if (write_address == 5'd0) begin
            //Do nothing
        end
        else{
            register[write_address] <= write_value;
        }
    end
end
endmodule