`timescale 10ns/10ns
`include "imm_gen.sv"
module imm_gen_tb;
//input instruction
logic [31:0] instruction;
logic [31:0] i_imm;
logic [31:0] s_imm;
logic [31:0] i_shift_imm;
logic [31:0] u_imm;
logic [31:0] j_imm;
logic [31:0] b_imm;
//testing tasks that create mock instructions that can be decoded
//I type non shift ops
task i_generator(input logic[11:0] val,output logic[31:0] inst);
    begin 
        //justpadding the rs1, opcode, and rd fields with 0s
        inst = {val,{20{1'b0}}};
    end
endtask
//I type shift imms
task i_shift_generator(input logic [4:0] val,output logic [31:0] instruction);
    begin 
        //padding funct 7, rs1, and rd with 0
        instruction = {{7{1'b0}},val,{5{1'b0}},3'b001,{5{1'b0}},7'b0010011};
    end
endtask
task s_generator(input logic [11:0] val,output logic [31:0] instruction);
    begin 
        //padding the funct 3 and registers with 0's
        instruction = {val[11:5],{5{1'b0}},3'b000,{5{1'b0}},val[4:0],7'b0010011};
    end
endtask
task u_generator(input logic [19:0] val,output logic [31:0] instruction);
    begin 
        //padding the funct 3 and registers with 0's
        instruction = {val,{5{1'b0}},7'b0110111};
    end
endtask
task j_generator(input logic [20:1] val,output logic [31:0] instruction);
    begin 
        //padding the funct 3 and registers with 0's
        instruction = {val[20],val[10:1],val[11],val[19:12],5'b0,7'b1101111};
    end
endtask
task b_generator(input logic [12:0] val,output logic [31:0] instruction);
    begin 
        //padding the funct 3 and registers with 0's
        instruction = {val[12],val[10:5],{10{1'b0}},3'b000,val[4:1],val[11],7'b1100011};
    end
endtask
imm_gen u1 (
    .instruction (instruction),
    .i_imm (i_imm),
    .s_imm (s_imm),
    .i_shift_imm (i_shift_imm),
    .u_imm (u_imm),
    .j_imm (j_imm),
    .b_imm (b_imm)
);
initial begin
    logic [11:0] imm11;
    logic [12:0] b;
    logic [4:0] shift;
    logic [19:0] uimm;
    $dumpfile("imm.vcd");
    $dumpvars(0,imm_gen_tb);
    imm11 = $signed(-3);
    shift = 10;
    uimm = $signed(-100);
    b = $signed(-40);
    i_generator(imm11,instruction);
    #100
    im11: assert($signed(imm11) == $signed(i_imm));
    else
        $error("Immediate Aritmethic failed, expected: %b",$signed(imm11),"recieved: %b",$signed(i_imm));
    i_shift_generator(shift,instruction);
    #100
    shift: assert($signed(shift) == $signed(i_shift_imm));
    else
        $error("Immediate Shift failed, expected: %b",$signed(shift),"recieved: %b",$signed(i_shift_imm));
    s_generator(imm11,instruction);
    #100
    stype: assert($signed(imm11) == $signed(s_imm));
    else
        $error("S type failed, expected: %b",$signed(imm11),"recieved: %b",$signed(s_imm));
    u_generator(uimm,instruction);
    #100
    utype: assert(uimm  == u_imm[31:12]);
    else
        $error("U type failed, expected: %b",uimm,"recieved: %b",u_imm[31:12]);
    j_generator(uimm,instruction);
    #100
    jtype: assert($signed(uimm<<1)  == $signed(j_imm));
    else
        $error("j type failed, expected: %b",uimm<<1,"recieved: %b",j_imm);  
    b_generator(b,instruction);
    #100
    btype: assert($signed(b)  == $signed(b_imm));
    else
        $error("b type failed, expected: %b",b,"recieved: %b",b_imm); 
end
endmodule