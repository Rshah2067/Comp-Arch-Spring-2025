`include "alu.sv"
module top(
    //Alu Operands and Results
    logic [31:0] adder_op1;
    logic [31:0] adder_op2;
    logic [31:0] adder_rsv;
    logic [31:0] shifter_op1;
    logic [31:0] shifter_op2;
    logic [31:0] shifter_rsv;
    logic [31:0] comperator_op1;
    logic [31:0] comperator_op2;
    logic [31:0] comperator_rsv;
    //Instruction Decode Fields
    logic [31:0] instruction;
    logic [6:0] opcode;
    logic [6:0] funct7;
    logic [2:0] funct3;
    //Immediate Generator Results
    logic [31:0] i_imm;
    logic [31:0] j_imm;
    logic [31:0] u_imm;
    logic [31:0] i_shift_imm;
    logic [31:0] b_imm;
    logic [31:0] s_imm;
    //Register File Inputs

    //Mux controls
    //mux controlling which output of alu is written back
    //00 is adder, 01 is comperator, 10 is shifter
    logic [1:0] alusubselector;
    //determines where alu result is sent. 
    logic [1:0] alursvmux;

)
    alu u1(
        .adder_op1 (adder_op1),
        .adder_op2 (adder_op2),
        .adder_rsv (adder_rsv),
        .shifter_op1 (shifter_op1),
        .shifter_op2 (shifter_op2),
        .shifter_rsv (shifter_rsv),
        .comperator_op1 (comperator_op1),
        .comperator_op2 (comperator_op2),
        .comparator_rsv (comperator_rsv),
        .funct7 (funct7),
        .funct3 (funct3)
    )
    imm_gen u2(
        instruction (instruction),
        .i_imm (i_imm),
        .s_imm (s_imm),
        .i_shift_imm (i_shift_imm),
        .u_imm (u_imm),
        .j_imm (j_imm),
        .b_imm (b_imm)
    )
    //Instruction Decoder
    always_comb begin
        //take in  opcode and slect muxes 
        
    end
    //ALU Result MUX
    //Mux that selects the ALU output to write back
    always_comb begin
        case (alursvmux)
        3'b00:
          
        endcase
    end
endmodule