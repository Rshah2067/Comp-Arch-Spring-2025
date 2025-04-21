`timescale 10ns/10ns
`include "registerfile.sv"

module reg_tb;
    logic clk = 0;
    logic[4:0] read_address_1,read_address_2,write_address;
    logic [31:0] write_value,read_data_1,read_data_2;
    logic write_enable;
    task write(input logic [4:0] write_add,input logic [31:0]write_val);
        write_address = write_add;
        write_value = write_val;
        write_enable = 1'b1;
        //wait for clock
        #12;
        write_enable = 1'b0;
    endtask
    task read_reg(input logic[4:0] read_add,output logic [31:0] read_val);
        read_address_1 = read_add;
        #2
        read_val = read_data_1;
    endtask
    registerfile u1 (
        .clk (clk),
        .read_address_1 (read_address_1),
        .read_address_2 (read_address_2),
        .write_address (write_address),
        .write_value (write_value),
        .write_enable (write_enable),
        .read_data_1 (read_data_1),
        .read_data_2 (read_data_2)
    );
    initial begin
        logic [4:0] w1 = 4'd2;
        logic [4:0] w2 = 4'd0;
        logic [31:0] d1 = 31'd100;
        logic [31:0] read,read2;
        $dumpfile("reg_tb.vcd");
        $dumpvars(0,reg_tb);
        //try writing to first reg
        write(w1,d1);
        read_reg(w1,read);
        write(w2,d1);
        read_reg(w2,read2);
        r1: assert (read == d1)
        else
            $error("read/write failed");
        r2: assert (read2 == 32'd0)
        else
            $error("read to 0 reg produced non zero result");
        $finish;
    end
    //pulse clock
    always begin
        #4
        clk = ~clk;
    end
endmodule