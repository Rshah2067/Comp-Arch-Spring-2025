module statemachine(
    input logic clk,
    input logic ra_mux_cont,
    output logic pc_clk,
    output logic instruct_clk,
    output logic mem_clk,
    output logic ra_mux
);

//three phases introduces an assmetry to our phase so we add on every
//clock phase to our state. 
localparam fetch = 2'b00;
localparam operation = 2'b01;
localparam writeback = 2'b11;
//The start phase is used on boot to load the first instruction
localparam start = 2'b10; 
//on a positive and negative edge advance state
logic [1:0] current_state = start;
logic [1:0] next_state;
always_ff@(posedge clk) begin
    current_state <= next_state;
end
always_ff@(negedge clk) begin
    current_state <= next_state;
end
//determine next state
always_comb begin
    case (current_state)
        2'b00:
            next_state = operation;
        2'b01:
            next_state = writeback;
        2'b11:
            next_state = fetch;
        2'b10:
            next_state = fetch;
        default
            next_state = fetch;
    endcase
end
// always_comb begin
//     case (current_state)
//         2'b00:
//             next_state = operation;
//         2'b01:
//             next_state = operation2;
//         2'b10:
//             next_state = writeback;
//         2'b11:
//             next_state = fetch;
//         default
//             next_state = fetch;
//     endcase
// end
//enable writing and pulse registers
always_comb begin
    case(current_state)
        fetch:begin
            //pulse instruction register
            instruct_clk = 1;
            //other regs should hold values
            pc_clk = 0;
            mem_clk = 0;
            //we should always set the ra mux to instruction address during fetch
            ra_mux = 0;
        end
        operation:begin
            //instruction reg should now hold
            instruct_clk =0;
            pc_clk = 0;
            mem_clk = 1;
            ra_mux = ra_mux_cont ? 1:0;
        end
        writeback:begin
            pc_clk =1;
            mem_clk = 0;
            instruct_clk = 0;
            ra_mux =0;  
        end
        start:begin
            mem_clk = 1;
            pc_clk = 0;
            instruct_clk = 0;
            ra_mux =0;
        end
        default begin
            pc_clk =0;
            mem_clk = 0;
            instruct_clk = 0; 
            //ra_mux should default to 0
            ra_mux =0;  
        end
    endcase
end
endmodule