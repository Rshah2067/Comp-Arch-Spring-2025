`include "alu.sv"
`include "imm_gen.sv"
`include "registerfile.sv"
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
    //Register File IO
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic [31:0] rs1v;
    logic [31:0] rs2v;
    logic [31:0] rdv;
    //Memmory IO
    logic [31:0] wa;
    logic [31:0] wd;
    logic [31:0] rd;
    logic [31:0] ra;
    //Program Counter
    logic [31:0] pc_increment;
    logic [31:0] pc;
    //Intermediate nets
    logic [31:0] alu_result;
    logic [31:0] alu_rdv;
    logic [31:0] alu_rda;
    //Mux controls
    //mux controlling which output of alu is written back
    //00 is adder, 01 is comperator, 10 is shifter
    logic [1:0] alusubselector;
    //determines where alu result is sent.
    //00 is rdv mux, 01 is write address, 10 is the read address mux
    logic [1:0] alursvmux;
    //determines wheter the alu result or memory read is loaded into register file
    logic rdvmux;
    //determines wheter program counter or calculated address
    logic rdamux;
    //Program Counter mux selects what to increment the program counter by
    logic [1:0] pc_icrement_mux;
    //Immediate Generator Mux selects what type of immediate coding to select
    logic [2:0] imm_gen_mux;
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
    );
    imm_gen u2(
        instruction (instruction),
        .i_imm (i_imm),
        .s_imm (s_imm),
        .i_shift_imm (i_shift_imm),
        .u_imm (u_imm),
        .j_imm (j_imm),
        .b_imm (b_imm)
    );
    registerfile u3(
        .clk    (clk),
        .read_address_1 (rs1),
        .read_address_2 (rs2),
        .write_address (rd),
        .write_value (rdv).
        .read_value_1 (rs1v),
        .read_value_2 (rs2v),
        .write_enable (wen)
    );
    pc u4(
        .pc_clk (clk),
        .increment (pc_increment),
        .pc (pc)
    );
    // Add memory mapped peripherals
    memory #(
        .INIT_FILE ("")
    )u5(
        .clk (clk),
        .write_mem (wen),
        .write_address (wa),
        .write_data (wd),
        .read_address (ra),
        .read_data (rd),
    );

    //Instruction Decoder
    always_comb begin
        //take in  opcode and slect muxes 
        
    end
    //Mux controllers
    //MUX that selects the correct alu sub module to assign to the result
    always_comb begin
        case alusubselector
            //adder
            3'b00:
                alu_result = adder_rsv;
            //01 comperator
            3'b01:
                alu_result = comperator_rsv;
            //10 shifter
            3'b10:
                alu_result = shifter_rsv;
            default:
                alu_result = adder_rsv;
        endcase
    end
    //ALU Result MUX
    //Mux that selects the where the ALU output is writen back
    always_comb begin
        case (alursvmux)
            //Written to RDV (goes to an intermediate net into another mux)
            3'b00:
                alu_rdv = alu_result;
            //goes to write address
            3'b01:

            //goes to read address (mux)
            3'b10:
                alu_rda = alu_result;
            default: alu_rdv = alu_result;
        endcase
    end
    //Register write value Mux
    //if rdvmux is 0 put ALU result through, if it is 1 put memory read through
    assign rdv = (rdvmux) ? (rd:alu_rdv);
    // Memory Read Address Mux
    //if rdamux is 0 put the pc counter in, if 1 put the alu address in
    assign wa = (rdamux) ? (alu_rda:pc);
    //PC increment mux
    always_comb begin
        case(pc_icrement_mux)

        endcase
    end
    //Imm gen mux
    always_comb begin
    case(imm_gen_mux)
        //I non shift type
        3'b000:
        //I shift type
        3'b001
        //Jtype
        3'b010
        3'b010

    endcase
    end
endmodule