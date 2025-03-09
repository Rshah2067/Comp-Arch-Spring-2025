//module fetching from memory, based off sample code, only loading in 9 bits of the 10 bit sample
module memory #(
    parameter INIT_FILE = ""
) (
    input logic clk,
    //7 bit memory address (we have 128 samples)
    input logic[6:0] read_address,
    //flag from main to invert the input data
    input logic invert_data,
    //each peace of memory is 9 bits long as we know the MSB will always be one
    output logic[8:0] data
);
    logic[8:0] samplememory [0:127];
    //if init file exists, initialize memory array with it's contents
    initial if (INIT_FILE) begin
        $readmemh(INIT_FILE,samplememory);
    end

    always_ff @(posedge clk) begin
            data[8:0] <= samplememory[read_address];
    end
endmodule