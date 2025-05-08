module statemachine(
    input logic clk,
    input logic ra_mux_cont,
    output logic pc_en,
    output logic instruct_en,
    output logic mem_en,
    output logic reg_en,
    output logic ra_mux
);

//three phases introduces an assmetry to our phase so we add on every
//clock phase to our state. 
localparam fetch = 5'b00001;
localparam operation = 5'b00010;
localparam operation2 = 5'b00100;
localparam writeback = 5'b01000;
localparam start = 5'b10000;
//The start phase is used on boot to load the first instruction
logic [4:0] current_state;
//on a positive and negative edge advance state
initial begin
    current_state = start;
end
logic [4:0] next_state;

always_ff@(posedge clk) begin
        current_state <= next_state;
end
//determine next state
always_comb begin
    case (current_state)
        start:
            next_state = fetch;
        fetch:
            next_state = operation;
        operation:
            next_state = operation2;
        operation2:
            next_state = writeback;
        writeback:
            next_state = fetch;
        default
            next_state = fetch;
    endcase
end

always_comb begin
    case(current_state)
        fetch:begin
            //pulse instruction register to latch fetched instruction
            instruct_en =1;
            mem_en =0;
            pc_en = 0;
            //we should always set the ra mux to instruction address during fetch
            ra_mux = 0;
            reg_en= 0;
        end
        operation:begin
            //instruction reg should now hold value
            instruct_en = 0;
            mem_en = 0;
            pc_en = 0;
            ra_mux = 0;
            reg_en= 0;
        end
        operation2:begin
            instruct_en = 0;
            pc_en =0;
            mem_en = 1;
            ra_mux = ra_mux_cont ? 1:0;
            reg_en= 0;
        end
        writeback:begin
            pc_en =1;
            mem_en = 1;
            instruct_en = 0;
            ra_mux = ra_mux_cont ? 1:0;
            reg_en= 1;
        end
        start:begin
            pc_en =0;
            mem_en = 0;
            instruct_en = 0;
            ra_mux = 0;
            reg_en= 0;
        end
        default begin
            pc_en =0;
            mem_en = 0;
            instruct_en = 0;
            //ra_mux should default to 0
            ra_mux =0;  
            reg_en= 0;
        end
    endcase
end
endmodule