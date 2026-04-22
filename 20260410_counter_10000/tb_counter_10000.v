`timescale 1ns / 1ps


module tb_counter_10000();

    reg clk, rst;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    counter_10000 dut(
        .clk(clk),
        .rst(rst),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );


    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        #20;
        rst = 0;

    end

endmodule