//ALU Contains 3 seperate modules, an adder, barrell shifter, and comperator. A seperate comperator and adder is used to allow for conditional branch instructions
//to execute in a standard cycle. A barrell shifter is used to prevent shifting from taking many individual operations
module alu (
    //adder inputs
    input logic [31:0] op1 ,
    input logic [31:0] op2,

    //generic inputs
    input logic [6:0] funct7,
    input logic [2:0] funct3_adder,
    input logic [2:0] funct3_comp,
    //outputs
    output logic [31:0] comparator_rsv,
    //true or false comperator val
    output logic [31:0] shifter_rsv,
    output logic [31:0] adder_rsv

);  
    //Comperator intermediate
    logic[31:0] comperator_inter = 32'd0;
    //Adder operations 
    //When Funct7's 6th bit is 0 we add, when it is 1 we subtract
    //XOR, OR, and AND are distinguised via funct 3
    always_comb begin
        case (funct3_adder)
            //add/sub
            3'b000: begin
                //check if we are adding or subtracting
                case (funct7)
                7'b0000000:
                    adder_rsv = op1 + op2; 
                7'b0100000:
                    adder_rsv = op1 - op2;
                default:
                    adder_rsv = op1 + op2; 
                endcase
            end
            //xor
            3'b100:
                adder_rsv = op1 ^ op2;
            //or
            3'b110:
                adder_rsv = op1 | op2;
            //And
            3'b111:
                adder_rsv = op1 & op2;
            //what is the most effecient thing to put as the default?
            default:
                adder_rsv = op1 + op2;
        endcase
    end 
    //Shifter Operations, amount of shifts are module of 32 (no point in doing any greater as it just wraps around)
    //funct 7 is only used to distingues between srl and sra
    //funct 3 distingueshishes sll,srl/sra
    always_comb begin
        case (funct3_adder)
            //sll
            3'b001: 
                shifter_rsv = (op1 << (op2%'d32));
            //srl or sra
            3'b101: begin
                //srl
                if (funct7 == 7'b0000000) begin
                    shifter_rsv = (op1 >> (op2 % 'd32));
                end
                //sra
                else begin
                    shifter_rsv = (op1 >>> (op2 % 'd32));
                end
            end
            // in the default case we just give zero
            default: 
                shifter_rsv= 32'd0;
        endcase
    end
    //Comperator Operations
    //only care about funct 3 for slt and sltu
    //don't need to distinguish between these thwo operations
    always_comb begin
        comperator_inter = 32'd0;
        //slt (signed numbers)
        if (funct3_comp == 3'b010) begin
            //subtract numbers and check MSB for sign (if the result is negative than op2 is grater)
            comperator_inter = (op1 - op2);
            if (comperator_inter == 32'd0) begin
                comparator_rsv = 32'd1;
            end
            else begin
            comparator_rsv = (comperator_inter[31] == 1) ? 32'd1 : 32'd0;
            end
        end
        //sltu unsigned
        else begin
            comparator_rsv = (op1 <op2) ? 32'd1:32'd0;
        end
    end
endmodule