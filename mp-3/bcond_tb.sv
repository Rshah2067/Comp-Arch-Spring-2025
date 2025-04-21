`include "bcond.sv"
`include "alu.sv"
module bcond_tb;
    logic [31:0] op1,op2,comparator_rsv,adder_rsv,imm,branc_add,shifter_rsv;
    logic [2:0] funct3,funct3_adder,funct3_comp;
    logic [6:0] funct7;
    task beq(input logic [31:0] rs1, input logic [31:0] rs2, input logic [31:0] val, output logic [31:0] b_offset);
        imm = val;
        op2 = rs2;
        op1 = rs1;
        //set adder to subraction
        funct3_adder = 3'b000;
        funct7 = 7'b0100000;
        funct3 = 3'b000;
        #10
        b_offset = branc_add;
        assert (b_offset == ((rs1 == rs2)?val:0))
        else
            $error("Equality failed");
    endtask
    task bne(input logic [31:0] rs1, input logic [31:0] rs2, input logic [31:0] val, output logic [31:0] b_offset);
        imm = val;
        op2 = rs2;
        op1 = rs1;
        //set adder to subraction
        funct3_adder = 3'b000;
        funct7 = 7'b0100000;
        funct3 = 3'b001;
        #10
        b_offset = branc_add;
        assert (b_offset == ((rs1 != rs2)?val:0))
        else
            $error("inequality failed");
    endtask
    task blt(input logic [31:0] rs1, input logic [31:0] rs2, input logic [31:0] val, output logic [31:0] b_offset);
        imm = val;
        op2 = rs2;
        op1 = rs1;
        //set adder to subraction
        funct3_adder = 3'b000;
        funct7 = 7'b0100000;
        funct3 = 3'b100;
        //set comp to slt
        funct3_comp = 3'b010; 
        #10
        b_offset = branc_add;
        assert (b_offset == (($signed(rs1) < $signed(rs2))?val:0))
        else
            $error("less than failed");
    endtask
    task bltu(input logic [31:0] rs1, input logic [31:0] rs2, input logic [31:0] val, output logic [31:0] b_offset);
        imm = val;
        op2 = rs2;
        op1 = rs1;
        //set adder to subraction
        funct3_adder = 3'b000;
        funct7 = 7'b0100000;
        funct3 = 3'b100;
        //set comp to sltu
        funct3_comp = 3'b011; 
        #10
        b_offset = branc_add;
        assert (b_offset == ((rs1 < rs2)?val:0))
        else
            $error("less than failed");
    endtask
    task bgeu(input logic [31:0] rs1, input logic [31:0] rs2, input logic [31:0] val, output logic [31:0] b_offset);
        imm = val;
        op2 = rs2;
        op1 = rs1;
        //set adder to subraction
        funct3_adder = 3'b000;
        funct7 = 7'b0100000;
        funct3 = 3'b111;
        //set comp to sltu
        funct3_comp = 3'b011; 
        #10
        b_offset = branc_add;
        assert (b_offset == ((rs1 >= rs2)?val:0))
        else
            $error("greater than equal unsigned failed");
    endtask
    task bge(input logic [31:0] rs1, input logic [31:0] rs2, input logic [31:0] val, output logic [31:0] b_offset);
        imm = val;
        op2 = rs2;
        op1 = rs1;
        //set adder to subraction
        funct3_adder = 3'b000;
        funct7 = 7'b0100000;
        funct3 = 3'b111;
        //set comp to slt
        funct3_comp = 3'b010; 
        #10
        b_offset = branc_add;
        assert (b_offset == (($signed(rs1) >= $signed(rs2))?val:0))
        else
            $error("greater than equal failed");
    endtask
    
    bcond u1 (
        .imm (imm),
        .comperator (comparator_rsv),
        .adder (adder_rsv),
        .funct3 (funct3),
        .branc_add (branc_add)
    );
    alu u2(
        .adder_rsv (adder_rsv),
        .shifter_rsv (shifter_rsv),
        .comparator_rsv (comparator_rsv),
        .op1 (op1),
        .op2 (op2),
        .funct7 (funct7),
        .funct3_adder (funct3_adder),
        .funct3_comp (funct3_comp)
    );
    initial begin
        logic[31:0] b_offset;
        beq(10,12,30,b_offset);
        bne(10,10,30,b_offset);
        blt(20,-10,30,b_offset);
        bltu(20,30,30,b_offset);
        bge(20,30,30,b_offset);
        bgeu(20,30,30,b_offset);
    end

endmodule