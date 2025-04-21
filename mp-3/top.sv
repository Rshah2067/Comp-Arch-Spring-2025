`include "alu.sv"
`include "imm_gen.sv"
`include "registerfile.sv"
`include "memory.sv"
`include "pc_reg.sv"
`include "bcond.sv"
`include "controller.sv"
`include "statemachine.sv"
module top (
    input logic     clk,
    input logic     BOOT, 
    output logic    RGB_R,
    output logic    RGB_B,
    output logic    RGB_G,
    output logic    LED
);
    //Alu Operands and Results
    logic [31:0] op1;
    logic [31:0] op2;
    logic [31:0] adder_rsv;
    logic [31:0] shifter_rsv;
    logic [31:0] comperator_rsv;
    logic [2:0] funct3_comp;
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
    logic [31:0] rsv1;
    logic [31:0] rsv2;
    logic [31:0] rdv;
    //Memmory IO
    logic [31:0] wa;
    logic [31:0] wd;
    logic [31:0] rdvm;
    logic [31:0] ra;
    logic [2:0] funct3_mem;
    //Program Counter
    logic [31:0] pc_increment;
    logic [31:0] pc;
    //Controller
    logic wen_mem;
    logic wen_reg;
    //Conditional Branch
    logic [31:0] branc_add;
    //Intermediate nets
    logic [31:0] alu_result;
    logic [6:0] alu_funct7;
    logic [2:0] funct3_instruct;
    logic [2:0] funct3_adder;
    logic [6:0] funct7_instruct;
    logic[31:0] imm;
    logic [4:0] rd_instruct;
    //branch conditional
    logic [31:0] b_offset;
    //Mux controls
    //mux controlling which output of alu is written back
    //00 is adder, 01 is comperator, 10 is shifter
    logic [1:0] alusubselector;
    //determines wheter the alu result or memory read is loaded into register file
    logic rdvmux;
    //determines wheter program counter or calculated address is used for the mem read
    logic ramux;
    logic ra_mux_cont;
    //Program Counter mux selects what to increment the program counter by
    logic [1:0] pc_icrement_mux;
    //Immediate Generator Mux selects what type of immediate coding to select
    logic [2:0] imm_gen_mux;
    //operand mux selects operand between an immediate and rsv1
    logic [1:0] op1_mux;
    //operand 2 mux selects operand between rsv2(00) and pc(01) and 0 (10)
    logic [1:0] op2_mux;
    //sets the funt 7 and funct 3 fields appropriately depending on operation
    //00 is regular funct 7 assignment. 01 is 6th bit 1 10 is all bits are 0
    logic [1:0] funct_7mux;
    //when given 0 funct3 is taken from the instruction, when 1 funct3 is taken from a 
    logic funct3_mux;
    logic funct3_mem_mux;
    logic [1:0] funct7mux;
    logic[1:0] funct3_comp_mux;
    logic funct3_adder_mux;
    logic pc_mux;
    //sets the rd register file to the rd instruction field or 0 when 0
    logic rdmux;
    alu u1(
        .op1 (op1),
        .op2 (op2),
        .adder_rsv (adder_rsv),
        .shifter_rsv (shifter_rsv),
        .comparator_rsv (comperator_rsv),
        .funct7 (funct7),
        .funct3_adder (funct3_adder),
        .funct3_comp (funct3_comp)
    );
    imm_gen u2(
        .instruction (instruction),
        .i_imm (i_imm),
        .s_imm (s_imm),
        .i_shift_imm (i_shift_imm),
        .u_imm (u_imm),
        .j_imm (j_imm),
        .b_imm (b_imm)
    );
    registerfile u3(
        .clk    (mem_clk),
        .read_address_1 (rs1),
        .read_address_2 (rs2),
        .write_address (rd),
        .write_value (rdv),
        .read_data_1 (rsv1),
        .read_data_2 (rsv2),
        .write_enable (wen_reg)
    );
    pc_reg u4(
        .pc_clk (pc_clk),
        .increment (pc_increment),
        .pc (pc),
        .reset (BOOT),
        .rs1 (rsv1),
        .pc_mux (pc_mux)
    );
    // Add memory mapped peripherals
    memory #(
        .INIT_FILE ("mem.txt")
    )u5(
        .clk (mem_clk),
        .funct3 (funct3_mem),
        .write_mem (wen_mem),
        .write_address (wa),
        .write_data (wd),
        .read_address (ra),
        .read_data (rdvm),
        .led (LED),
        .blue (RGB_B),
        .green (RGB_G),
        .red (RGB_R)
    );
    bcond u6(
        .imm (imm),
        .funct3 (funct3),
        .comperator (comperator_rsv),
        .adder (adder_rsv),
        .branc_add (b_offset)
    );
    controller u7 (
        .opcode (opcode),
        .funct3_instruct (funct3_instruct),
        .funct7_instruct (funct7_instruct),
        .alusubselector (alusubselector),
        .rdvmux (rdvmux),
        .ramux (ra_mux_cont),
        .pc_icrement_mux (pc_icrement_mux),
        .imm_gen_mux (imm_gen_mux),
        .op1_mux (op1_mux),
        .op2_mux (op2_mux),
        .funct7mux (funct7mux),
        .funct3_mux(funct3_mux),
        .funct3_comp_mux (funct3_comp_mux),
        .funct3_mem_mux (funct3_mem_mux),
        .rdmux (rdmux),
        .wen_mem(wen_mem),
        .wen_reg(wen_reg),
        .funct3_adder_mux(funct3_adder_mux),
        .pc_mux (pc_mux)
    );
    statemachine u8(
        .ra_mux_cont (ra_mux_cont),
        .clk (clk),
        .pc_clk (pc_clk),
        .instruct_clk (instruct_clk),
        .mem_clk (mem_clk),
        .ra_mux (ra_mux)
    );
    //instruction splitter
    assign opcode = instruction[6:0];
    assign funct3_instruct = instruction[14:12];
    assign funct7_instruct = instruction[31:25];
    assign rd_instruct = instruction[11:7];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];

    //instruction register
    always_ff @(posedge instruct_clk)begin
        instruction <= rdvm;
    end
    //write address of memory is always the alu result
    assign wa = alu_result;
    
    //Mux controllers
    //MUX that selects the correct alu sub module to assign to the result
    always_comb begin
        case (alusubselector)
            //adder
            2'b00:
                alu_result = adder_rsv;
            //01 comperator
            2'b01:
                alu_result = comperator_rsv;
            //10 shifter
            2'b10:
                alu_result = shifter_rsv;
            default:
                alu_result = adder_rsv;
        endcase
    end
    //ALU Result MUX
    //Register write value Mux
    //if rdvmux is 0 put ALU result through, if it is 1 put memory read through
    assign rdv = (rdvmux) ? rdvm:alu_result;
    // Memory Read Address Mux
    //if ramux is 0 put the pc counter in, if 1 put the alu address in
    assign ra = (ra_mux) ? alu_result:pc;
    //assigns rd to be either 0 in the case of B or S type instructions
    assign rd= (rdmux) ? 5'b0:rd_instruct;
    //op1 mux
    always_comb begin
        case(op1_mux)
            2'b00:
                op1 = rsv1;
            2'b01:
                op1 = pc;
            2'b10:
                op1 = 32'd0;
            default:
                op1 = rsv1;
        endcase
    end
    //operand 2 mux selects operand between 01 immediate val, 01 rsv2 and  00 
    always_comb begin
        case (op2_mux)
            //rd1
            2'b00:
                op2 = rsv2;
            //0
            2'b01:
                op2 = 32'd0;
            2'b10:
                op2 = imm;
            2'b11:
                op2 = 32'd4;
            default:
                op2 = rsv2;
        endcase
    end
    //PC increment mux
    always_comb begin
        case(pc_icrement_mux)
            //default is to advance the pc counter by 4
                2'b00:
                    pc_increment = 32'd4;
            //can advance by a beq
                2'b01:begin
                    pc_increment = b_offset;
                end
            //can advance by immediate
                2'b11:
                    pc_increment = imm;
            default:
                pc_increment = 32'd4;
        endcase
    end
    //Imm gen mux
    always_comb begin
        case(imm_gen_mux)
            //I imm
            3'b000:
                imm = i_imm;
            //j imm
            3'b001:
                imm = j_imm;
            //u imm
            3'b010:
                imm = u_imm;
            //i shift
            3'b011:
                imm = i_shift_imm;
            //b imm
            3'b100:
                imm = b_imm;
            //s imm
            3'b101:
                imm = s_imm;
            default:
                imm = i_imm;
        endcase
    end
    //ALU funct field muxes
    //funct 7 mux either gives the instruction funct 7 or one indicating addition/subtraction
    always_comb begin
        case(funct7mux)
            2'b00:
                funct7 = funct7_instruct;
            2'b01:
                funct7 = 7'b0100000;
            2'b10:
                funct7 = 7'b0000000;
            default:
                funct7 = funct7_instruct;
        endcase
    end
    always_comb begin
        case(funct3_comp_mux)
            2'b00:
                funct3_comp = funct3;
            //slt
            2'b01:
                funct3_comp = 3'b010;
            2'b10:
                funct3_comp = 3'b011;
            default:
                funct3_comp = funct3;
        endcase
    end
    //funct 3 needs to be able to be switched from the value created by the instruction to a preset val
    assign funct3 = (funct3_mux) ? 3'b000:funct3_instruct;
    assign funct3_mem = (funct3_mem_mux) ? funct3:3'b010;
    assign funct3_adder = (funct3_adder_mux) ? 3'b000:funct3;
endmodule