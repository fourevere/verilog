`timescale 1ns / 1ps


module tb_uart ();

    reg clk,rst,btnR;
    wire tx;


    uart dut (
        .clk (clk),
        .rst (rst),
        .btnR(btnR),
        .tx  (tx)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        
    end





endmodule
