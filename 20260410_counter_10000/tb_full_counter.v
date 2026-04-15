`timescale 1ns / 1ps


module tb_full_counter();


    reg clk;
    reg rst;
    reg btnL;
    reg btnR;
    reg btnD;

    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    

    counter_10000 dut(
        .clk(clk),
        .rst(rst),
        .btnL(btnL),
        .btnR(btnR),
        .btnD(btnD),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );


    always #5 clk = ~clk;


    initial begin
        clk = 0;
        rst = 1;
        btnL = 0;
        btnR = 0;
        btnD = 0;

        #100_000_000;

        rst = 0;

        #100;
        repeat(10000) @(negedge clk);


        btnR = 1;      

        repeat(30000) @(negedge clk);

        btnR = 0;

        repeat(40000) @(negedge clk);


        btnR = 1;

        repeat(20000) @(negedge clk);

        btnR = 0;

        repeat(30000) @(negedge clk);

        btnL = 1;

        repeat(40000) @(negedge clk);

        btnD = 1;

        repeat(20000) @(negedge clk);


        btnL = 0;

        repeat(20000) @(negedge clk);


        btnR = 1;

        repeat(30000) @(negedge clk);

        btnR = 0;

        repeat(40000) @(negedge clk);

        btnR = 1;

        repeat(20000) @(negedge clk);

        btnR = 0;

        repeat(20000) @(negedge clk);


        btnD = 0;

        #20;
        $stop;
    end



endmodule
