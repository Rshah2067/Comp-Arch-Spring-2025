module controller(
    input logic [6:0] opcode,
    input logic [2:0] funct3_instruct,
    input logic [6:0] funct7_instruct,
    //controller mux outputs
    output logic [1:0] alusubselector,
    output logic rdvmux,
    output logic ramux,
    output logic [1:0] pc_icrement_mux,
    output logic [2:0] imm_gen_mux,
    output logic [1:0] op1_mux,
    output logic [1:0] op2_mux ,
    output logic [1:0] funct7mux ,
    output logic funct3_mux,
    output logic [1:0] funct3_comp_mux ,
    output logic rdmux,
    output logic wen_mem,
    output logic wen_reg,
    output logic funct3_mem_mux,
    output logic funct3_adder_mux,
    output logic pc_mux
);
    //takes in instruction and sets muxes accordingly
    always_comb begin 
        case (opcode)
            //Utype Instructions
            //LUI
            7'b0110111:begin
                funct3_mem_mux = 0;
                rdmux = 0;
                ramux = 0;
                //take input from alu
                rdvmux =0;
                //pc_increment is +4
                pc_icrement_mux = 2'b00;
                pc_mux =0;
                //set the output of alu to the adder
                alusubselector = 2'b00;
                //set the immediate generator to u
                imm_gen_mux = 3'b010;
                //set the funct fields to add
                funct7mux = 2'b10;
                funct3_mux = 1'b1;
                funct3_comp_mux = 2'b00;
                funct3_adder_mux =0;
                //set the op1 to 0
                op1_mux = 2'b10;
                //set op2 to imm
                op2_mux = 2'b10;
                //enable writes
                wen_mem = 0;
                wen_reg =1;
            end
            //AUIPC
            7'b0010111:begin
                funct3_mem_mux = 0;
                rdmux = 0;
                ramux = 0;
                //take input from alu
                rdvmux =0;
                //pc_increment is +4
                pc_icrement_mux = 2'b00;
                pc_mux =0;
                //set the output of alu to the adder
                alusubselector = 2'b00;
                //set the immediate generator to u
                imm_gen_mux = 3'b010;
                //set the funct fields to add
                funct7mux = 2'b10;
                funct3_mux = 1'b1;
                funct3_comp_mux = 2'b00;
                funct3_adder_mux =0;
                //set the op1 to pc
                op1_mux = 2'b01;
                //set op2 to imm
                op2_mux = 2'b10;
                //enable writes
                wen_mem = 0;
                wen_reg =1;
            end
            //JAL
            7'b1101111:begin
                funct3_mem_mux = 0;
                rdmux = 0;
                ramux = 0;
                //take input from alu
                rdvmux =0;
                //pc_increment is immediate
                pc_icrement_mux = 2'b11;
                pc_mux =0;
                //set the output of alu to the adder
                alusubselector = 2'b00;
                //set the immediate generator to j
                imm_gen_mux = 3'b001;
                //set the funct fields to add
                funct7mux = 2'b10;
                funct3_mux = 1'b1;
                funct3_comp_mux = 2'b00;
                funct3_adder_mux =0;
                //set the op1 to pc
                op1_mux = 2'b01;
                //set op2 to 4
                op2_mux = 2'b11;
                //enable writes
                wen_mem = 0;
                wen_reg =1;                
            end
            //JALR
            7'b1100111:begin
                funct3_mem_mux = 0;
                rdmux = 0;
                ramux = 0;
                //take input from alu
                rdvmux =0;
                //pc_increment is immediate
                pc_icrement_mux = 2'b11;
                pc_mux =1;
                //set the output of alu to the adder
                alusubselector = 2'b00;
                //set the immediate generator to j
                imm_gen_mux = 3'b000;
                //set the funct fields to add
                funct7mux = 2'b10;
                funct3_mux = 1'b1;
                funct3_comp_mux = 2'b00;
                funct3_adder_mux =0;
                //set the op1 to pc
                op1_mux = 2'b01;
                //set op2 to 4
                op2_mux = 2'b11;
                //enable writes
                wen_mem = 0;
                wen_reg =1;
            end
            //B instructs
            7'b1100011:begin
                funct3_mem_mux = 1'b0;
                rdmux = 1;
                rdvmux =1;
                //disable writeback
                wen_mem = 0;
                wen_reg =0;
                //pc increment is bcond
                pc_icrement_mux = 2'b01;
                pc_mux =0;
                ramux = 1'b0;
                //both operands should be rsv1 and rsv2
                op1_mux = 2'b00;
                op2_mux = 2'b00;
                funct3_mux = 1'b0;
                //im generator to b
                imm_gen_mux = 3'b100;
                //alu subselector doesn't matter
                alusubselector = 2'b00;
                case (funct3_instruct)
                    //beq
                    3'b000:begin
                        //set funct3 and funct 7 for the adder so that we have subtraction
                        funct3_adder_mux =  1;
                        funct7mux = 2'b01;
                        funct3_comp_mux = 2'b00;
                    end
                    //bne
                    3'b001:begin
                        funct3_adder_mux =  1;
                        funct7mux = 2'b01;
                        funct3_comp_mux = 2'b00;
                    end
                    //blt
                    3'b010:begin
                        funct3_adder_mux =  1;
                        funct7mux = 2'b01;
                        //set comperator to signed
                        funct3_comp_mux = 2'b01;
                    end
                    //bge
                    3'b101:begin
                        funct3_adder_mux =  1;
                        funct7mux = 2'b01;
                        //set comperator to signed
                        funct3_comp_mux = 2'b01;                        
                    end
                    //bltu
                    3'b110:begin
                        funct3_adder_mux=1;
                        funct7mux = 2'b01;
                        //set comperator to unsigned
                        funct3_comp_mux = 2'b10;
                    end
                    //bgeu
                    3'b111:begin
                        funct3_adder_mux =1;
                        funct7mux = 2'b01;
                        funct3_comp_mux = 2'b10;
                    end
                    default:begin
                        funct3_adder_mux =  1;
                        funct7mux = 2'b01;
                        funct3_comp_mux = 2'b00;                        
                    end
                endcase
            end
            //Load Instructions
            7'b0000011:begin
                //give the memory unit the correct funct 3 field
                funct3_mem_mux = 1;
                //enable writing to register file at given address
                rdmux = 0;
                wen_mem = 0;
                wen_reg =1;
                //use i type immediate
                imm_gen_mux = 3'b000;
                //pc by 4
                pc_icrement_mux = 2'b00;
                pc_mux = 0;
                //read from calculated address
                ramux = 1;
                rdvmux = 1;
                //add rs1v and imm
                op1_mux = 2'b00;
                op2_mux = 2'b10;
                alusubselector =2'b00;
                funct3_mux = 0;
                //set adder to add
                funct3_adder_mux = 1;
                funct7mux = 2'b10;
                funct3_comp_mux =2'b00;
            end
            //I type arithmatic instructions
            7'b0010011:begin
                funct3_mem_mux = 1'b0;
                //we don't want to writeback to the memory 
                //writing to the rd val
                rdmux = 1'b0;
                //writing alu result to the rdv
                rdvmux = 1'b0;
                //selecting pc counter increment
                pc_icrement_mux = 2'b00;
                pc_mux =0;
                //setting read address to pc
                ramux = 1'b0;
                //setting the operands to be from rsv1 and imm
                op1_mux = 2'b00;
                op2_mux = 2'b10;
                //setting funct fields to instruction
                funct7mux = 2'b00;
                funct3_mux = 1'b0;
                funct3_comp_mux = 2'b00;
                funct3_adder_mux =0;
                //looking at funct3 to determine alu op
                case(funct3_instruct)
                    //add and sub
                    3'b000:begin
                        alusubselector =2'b00;
                        imm_gen_mux = 3'b000;
                    end
                    //sll
                    3'b001:begin
                        alusubselector = 2'b10;
                        imm_gen_mux = 3'b011;
                    end
                    //slt
                    3'b010:begin
                        alusubselector = 2'b01;
                        imm_gen_mux = 3'b000;
                    end
                    //sltu
                    3'b011:begin
                        alusubselector = 2'b01;
                        imm_gen_mux =3'b000;
                    end
                    //xor
                    3'b100:begin
                        alusubselector = 2'b00;
                        imm_gen_mux =3'b000;
                    end                        
                    //srli srai
                    3'b101:begin
                        alusubselector = 2'b10;
                        imm_gen_mux = 3'b011;
                    end
                    // or
                    3'b110:begin
                        alusubselector = 2'b00;
                        imm_gen_mux =3'b000;
                    end 
                    //and
                    3'b111:begin
                        alusubselector = 2'b00;
                        imm_gen_mux =3'b000;
                    end 
                    default:begin
                        alusubselector = 2'b00;
                        imm_gen_mux =3'b000;
                    end 
                endcase
                wen_reg = 1'b1;
                wen_mem = 1'b0;
            end
            //R type instructions
            7'b0110011:begin
                wen_mem = 1'b0;
                wen_reg = 1'b1;
                funct3_mem_mux = 1'b0;
                //writing to the rd val
                rdmux = 1'b0;
                //writing alu result to the rdv
                rdvmux = 1'b0;
                //selecting pc counter increment
                pc_icrement_mux = 2'b00;
                pc_mux =0;
                //setting read address to pc
                ramux = 1'b0;
                //setting the operands to be from rsv1 and rsv2
                op1_mux = 2'b00;
                op2_mux = 2'b00;
                //setting funct fields to instruction
                funct7mux = 2'b00;
                funct3_mux = 1'b0;
                funct3_comp_mux = 2'b00;
                imm_gen_mux = 3'b000;
                funct3_adder_mux =0;
                //looking at funct3 to determine alu op
                case(funct3_instruct)
                    //add and sub
                    3'b000:
                        alusubselector =2'b00;
                    //sll
                    3'b001:
                        alusubselector = 2'b10;
                    //slt
                    3'b010:
                        alusubselector = 2'b01;
                    //sltu
                    3'b011:
                        alusubselector = 2'b01;
                    //xor
                    3'b100:
                        alusubselector = 2'b00;
                    //srl sra
                    3'b101:
                        alusubselector = 2'b10;
                    // or
                    3'b110:
                        alusubselector = 2'b00;
                    //and
                    3'b111:
                        alusubselector = 2'b00;
                    default:
                        alusubselector = 2'b00;
                endcase
                //
            end
            default:begin
                //defualt case acts like a reset case
                rdmux = 1'b0;
                //writing alu result to the rdv
                rdvmux = 1'b0;
                //selecting pc counter increment
                pc_icrement_mux = 2'b00;
                //setting read address to pc
                ramux = 1'b0;
                //setting the operands to be from rsv1 and rsv2
                op1_mux = 2'b00;
                op2_mux = 2'b00;
                //setting funct fields to instruction
                funct7mux = 2'b00;
                funct3_mux = 1'b0;
                funct3_comp_mux = 2'b00;
                alusubselector = 2'b00;
                funct3_mem_mux = 1'b0;
                wen_mem =0;
                wen_reg = 0;
                imm_gen_mux = 3'b000;
                funct3_adder_mux =0;
                pc_mux =0;
            end
        endcase
    end
endmodule
// //Instruction Decoder
//     always_comb begin
//         //take in  opcode and slect muxes 
//         case (opcode)
//             //LUI
//             7'b0110111: begin
//                 //set correct immediate value out
//                 imm_gen_mux = 3'b010;
//                 //Set the operand to the immediate value and 0
//                 op1_mux = 1'b1;
//                 op2_mux = 2'b10;
//                 //set the alu to the adding operation
//                 alu_funct7_mux = 2'b01;
//                 //set the alu result to adder
//                 alusubselector = 2'b00;
//                 //set the writeback path to the rdv of registerfile
//                 ramux = 1'b0;
//                 //set the program counter advance to +4
//                 pc_icrement_mux = 2'b00;
//             end
//             //aupic
//             7'b0010111:begin
//                 //set correct immediate value generator
//                 imm_gen_mux  = 3'b010;
//                 //set operands to pc and immu
//                 op1_mux = 1'b1;
//                 op2_mux = 2'b10;
//                 //set the alu to the adding operation
//                 alu_funct7_mux = 2'b01;
//                 //set the writeback to rdv of register file
//                 rdvmux = 1'b0;
//                 pc_icrement_mux = 2'b00;
//             end
//             //Jtype instruction
//             7'b1101111:begin
//             end
//             //b type instruction
//             7'b1100011:begin
//             end
//             //I type load
//             7'b0000011: begin
//                 //set immeidate type
//                 imm_gen_mux = 3'b000;
//                 //set the operands of ALU
//                 op1_mux = 1'b0;
//                 op2_mux = 2'b10;
//                 //set the alu output path
//                 alusubselector = 2'b00;
//                 //select the alu output to the read instruction mux
//                 alursvmux = 2'b10;
//                 //set the ALU Read mux to address instead of PC
//                 ramux = 1'b1;
//                 //set the writeback path to be the instruction
//                 rdvmux = 1'b1;
//                 pc_icrement_mux = 2'b00;

//             end
//             //S type
//             7'b0100011:begin
//                 imm_gen_mux = 3'b101;
//                 //set operands
//                 op1_mux = 1'b0;
//                 op2_mux = 2'b10;
//                 //set alu add opcode
//                 //set alu result
//                 alusubselector = 2'b00;
//                 //set the result of alu to go to write address
//                 alursvmux = 3'b01;
//                 //set rs2 to go to the read port of the memroy
//                 pc_icrement_mux = 2'b00;

//             end

//             //I type Arethmatic
//             7'b0010011:begin
//                 //set the operands
//                 op1_mux = 1'b0;
//                 op2_mux = 2'b10;
//                 //funct 3 should be from the instruction
//                 funct3_mux = 1'b0;
//                 //depending on funct 3 we will set different alu output
//                 case (funct3)
//                 3'b000:begin
//                     alusubselector = 2'b00;
//                     imm_gen_mux = 3'b000;
//                 end
//                 3'b010:begin
//                     alusubselector = 2'b01;
//                     imm_gen_mux = 3'b000;
//                 end
//                 3'b011:begin
//                     alusubselector= 2'b01;
//                     imm_gen_mux = 3'b000;
//                 end
//                 3'b100:begin
//                     imm_gen_mux = 3'b000;
//                     alusubselector = 2'b00;
//                 end
//                 3'b110:begin
//                     alusubselector = 2'b00;
//                     imm_gen_mux = 3'b000;
//                 end
//                 3'b001:begin
//                     alusubselector = 2'b10;
//                     imm_gen_mux = 3'b011;
//                 end
//                 3'b101:begin
//                     alusubselector = 2'b10;
//                     imm_gen_mux = 3'b011;
//                 end
//                 default:begin 
//                     alusubselector = 2'b00;
//                     imm_gen_mux = 3'b000;

//                 end
//                 endcase
//                 //set writeback
//                 alursvmux = 2'b00;
//                 rdvmux = 1'b0;
//                 //set pc counter
//                 pc_icrement_mux = 2'b00;
//             end
//             //R Type
//             7'b0110011:begin 
//                 //set the operands
//                 op1_mux = 1'b0;
//                 op2_mux = 2'b00;
//                 //funct 3 should be from the instruction

//                 //depending on funct 3 we will set different alu output
//                 case (funct3)
//                 3'b000:
//                     alusubselector = 2'b00;
//                 3'b001:
//                     alusubselector = 2'b01;
//                 3'b010:
//                     alusubselector = 2'b01;
//                 3'b011:
//                     alusubselector= 2'b01;
//                 3'b100:
//                     alusubselector = 2'b00;
//                 3'b101:
//                     alusubselector = 2'b10;
//                 3'b110:
//                     alusubselector = 2'b00;
//                 default:
//                     alusubselector = 2'b00;
//                 endcase
//                 //set writeback
//                 alursvmux = 2'b00;
//                 rdvmux = 1'b0;
//                 //set pc counter
//                 pc_icrement_mux = 2'b00;
//             end
//             default: begin
            
//             end
//         endcase
//     end