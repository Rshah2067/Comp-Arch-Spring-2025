//Module that takes output of comperator and dermines wheter to branch or not
module bcond(
    input logic [31:0] imm,
    input logic [31:0] comperator,
    input logic [31:0] adder,
    input logic [2:0] funct3,
    output logic [31:0] branc_add
);
    always_comb begin
        //dending on funct 3 we are doing a different beq operation
        //the comperator will be set to the correct op code be the controller
        case (funct3)
            //equality (Beq)
            3'b000: begin
                //check to see output of subtraction to see if we have equality
                if (adder == 0) begin
                    //equality so we set output
                    branc_add = imm;
                end
                else begin
                    branc_add = 32'd4;
                end
            end
            //inequality (Bne)
            3'b001: begin
                if (adder != 0) begin
                    //inequality so we set output
                    branc_add = imm;
                end
                else begin
                    branc_add = 32'd4;
                end
            end
            //branch less than signed (blt)
            3'b100:
                if (comperator == 32'd1)begin
                    branc_add = imm;
                end
                else begin
                    branc_add = 32'd4;
                end
            //branch greater than or equal signed(bge)
            3'b101: begin
                if (comperator == 32'd0 || adder == 0) begin
                    branc_add = imm;
                end
                else begin
                    branc_add = 32'd4;
                end
            end
            //branch less than unsigned (bltu)
            3'b110: begin
                //the comperator operand is set correctly by the controller
                if (comperator == 32'd1)begin
                    branc_add = imm;
                end
                else begin
                    branc_add = 32'd4;
                end
            end
            //branch greater than equal to unsigned(bgeu)
            3'b111:
            begin 
                if (comperator == 32'd0 || adder == 0) begin
                    branc_add = imm;
                end
                else begin
                    branc_add = 32'd4;
                end
            end
            default:
                branc_add = 32'd4;
        endcase
    end
endmodule