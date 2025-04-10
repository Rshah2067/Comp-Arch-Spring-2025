`timescale 10ns/10ns
`include "alu.sv"
module alu_tb;
    //operands
    logic[31:0] adder_op1,adder_op2,comperator_op1,comperator_op2,shifter_op1,shifter_op2;
    //results
    logic[31:0] adder_rsv,comperator_rsv,shifter_rsv;
    //funct
    logic funct7;
    logic[2:0] funct3;
    task add(input logic [31:0] op1,input logic [31:0] op2, output logic[31:0] rsv);
        begin
            adder_op1 = op1;
            adder_op2 = op2;
            funct3 = 3'b000;
            funct7 = 1'b0;
            #10
            rsv = adder_rsv;
        end
    endtask
    task sub(input logic [31:0] op1,input logic [31:0] op2, output logic[31:0] rsv);
    begin
        adder_op1 = op1;
        adder_op2 = op2;
        funct3 = 3'b000;
        funct7 = 1'b1;
        #10
        rsv = adder_rsv;
    end
    endtask
    task sll(input logic [31:0] op1,input logic [31:0] op2, output logic[31:0] rsv);
    begin
        shifter_op1 = op1;
        shifter_op2 = op2;
        funct3 = 3'b001;
        funct7 = 1'b0;
        #10
        rsv = shifter_rsv;
    end
    endtask
    task slt(input logic [31:0] op1,input logic [31:0] op2, output logic[31:0] rsv);
    begin
        comperator_op1 = op1;
        comperator_op2 = op2;
        funct3 = 3'b011;
        funct7 = 1'b0;
        #10
        rsv = comperator_rsv;
    end
    endtask
    task sltu(input logic [31:0] op1,input logic [31:0] op2, output logic[31:0] rsv);
    begin
        comperator_op1 = op1;
        comperator_op2 = op2;
        funct3 = 3'b011;
        funct7 = 1'b0;
        #10
        rsv = comperator_rsv;
    end
    endtask

    task exclusiveor(input logic [31:0] op1,input logic [31:0] op2, output logic[31:0] rsv);
    begin
        adder_op1 = op1;
        adder_op2 = op2;
        funct3 = 3'b100;
        funct7 = 1'b0;
        #10
        rsv = adder_rsv;
    end
    endtask
    task srl(input logic [31:0] op1,input logic [31:0] op2, output logic[31:0] rsv);
    begin
        shifter_op1 = op1;
        shifter_op2 = op2;
        funct3 = 3'b101;
        funct7 = 1'b0;
        #10
        rsv = shifter_rsv;
    end
    endtask
    task sra(input logic [31:0] op1,input logic [31:0] op2, output logic[31:0] rsv);
    begin
        shifter_op1 = op1;
        shifter_op2 = op2;
        funct3 = 3'b101;
        funct7 = 1'b1;
        #10
        rsv = shifter_rsv;
    end
    endtask
    task orop(input logic [31:0] op1,input logic [31:0] op2, output logic[31:0] rsv);
    begin
        adder_op1 = op1;
        adder_op2 = op2;
        funct3 = 3'b110;
        funct7 = 1'b0;
        #10
        rsv = adder_rsv;
    end
    endtask
    task and_op(input logic [31:0] op1,input logic [31:0] op2, output logic[31:0] rsv);
    begin
        adder_op1 = op1;
        adder_op2 = op2;
        funct3 = 3'b111;
        funct7 = 1'b0;
        #10
        rsv = adder_rsv;
    end
    endtask
    alu u1 (
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
    );
    initial begin
        logic[31:0] op1,op2,result_sub,result_add,result_xor,result_or,result_sll,result_slt,result_sltu,result_srl,result_sra,result_and,results_sub;   
        op1 = 32'd100;
        op2 = 32'd100;
        add(op1,op2,result_add);
        sub(op1,op2,result_sub);
        exclusiveor(op1,op2,result_xor);
        orop(op1,op2,result_or);
        sll(op1,op2,result_sll);
        slt($signed(op1),$signed(op2),result_slt);
        sltu(op1,op2,result_sltu);
        srl(op1,op2,result_srl);
        sra($signed(op1),op2,result_sra);
        and_op(op1,op2,result_and);
        //Tests
        add: assert (result_add == op1 + op2)
        else
            $error("add failed");
        sub: assert (result_sub == op1 - op2);
        else
            $error("subtraction failed");
        exclusiveor: assert(result_xor == (op1 ^ op2));
        else
            $error("xor failed");
        orop: assert(result_or == (op1 | op2));
        else
            $error("or failed");
        sll: assert(result_sll == (op1 <<(op2%32)));
        else
            $error("Shift Logic Left failed");
        slt: assert(result_slt == ($signed(op1) < $signed(op2)) ? 1:0 );
        else
            $error("set less than failed");
        sltu: assert(result_slt == ((op1) < (op2)) ? 1:0 );
        srl: assert(result_srl == ((op1) >> (op2%32)));
        sra: assert(result_sra == ($signed(op1) >>> (op2%32)));
        and_op:assert(result_and == (op1 & op2));
    end 
endmodule