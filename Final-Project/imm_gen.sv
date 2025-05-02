//The immediate generator takes the whole instruction and produces an immediate value
//for each instructino type. The controller is responsible for selecting the correct immediate
//The RISC standard suggests this method as the immeidate encoding is done such that the instruction does
//not need to be decoded before immediates are generated. This allows for the immediate to be generated in parallel with the instruction decoding
//This also reduces redundant hardware needed to decode the instruction to decide how to decode the immediate.
module imm_gen(
    //input instruction
    input logic [31:0] instruction,
    output logic [31:0] i_imm,
    output logic [31:0] s_imm,
    output logic [31:0] i_shift_imm,
    output logic [31:0] u_imm,
    output logic [31:0] j_imm,
    output logic [31:0] b_imm
);
    //There are 5 different ways that immediates are created (I, S, B, u, and J) with subcases for load instructions
    //and shift operation 
    //intermediate wires to get around not being able to select bits in always conditional statements (this naming convention is bad, but I couldn't think of a better one)
    logic[10:0] imm_11;
    logic imm_11_sign;
    logic [4:0] shamt;
    logic [19:0] imm_31_12;
    logic b_11;
    logic [3:0] b_4;
    logic [5:0] b_5;
    logic [7:0] j_7;
    logic [9:0] j_10;

    assign imm_11 = instruction[30:20];
    assign imm_11_sign = instruction[31];
    assign shamt = instruction[24:20];
    assign imm_31_12 = instruction[31:12];
    assign b_11 = instruction[7];
    assign b_4 = instruction[11:8];
    assign b_5 = instruction[30:25];
    assign j_7 = instruction[19:12];
    assign j_10 = instruction[30:21];
    assign j_11 = instruction[20];

    //always comb for intermediate bits
    always_comb begin
        i_imm = {{21{imm_11_sign}},imm_11};
        
    end
    //I type (shift)
    always_comb begin
        i_shift_imm = {{27{1'b0}},shamt};
    end
    //U type
    always_comb begin
        u_imm = {imm_31_12,{12{1'b0}}};
    end
    //B type
    always_comb begin
        b_imm = {{20{imm_11_sign}},b_11,b_5,b_4,1'b0};
    end
    //S Type
    always_comb begin
        s_imm = {{22{imm_11_sign}},b_5,b_4,b_11};
    end
    //J Type
    always_comb begin
        j_imm = {{12{imm_11_sign}},j_7,j_11,j_10,1'b0};
    end
endmodule