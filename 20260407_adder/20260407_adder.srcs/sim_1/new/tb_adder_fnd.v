`timescale 1ns / 1ps


module tb_adder_fnd();


    reg [7:0] a,b;
    reg clk, rst;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire led;

    integer i,j;

    adder_fnd dut(
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .led(led)
    );

    always #5 clk = ~clk; //5us 마다


    initial begin
        clk = 0;
        rst = 1;
        a = 8'd0;
        b = 8'd0;

        #20;
        //reset
        rst = 0;

        
        #4_000_000;
        a = 255;
        b = 1;

        #4_000_000;
        a = 1;
        b = 255;



        
        #4_000_000;
        a = 255;
        b = 255;


        //expected S = 255, c= 0;
        #4_000_000;
        a = 0;
        b = 255;
        #1000;

        $stop;

    end



/* 내가한것
    initial begin
        i = 0;
        j = 0;
        a = 0;
        b = 0;
        clk = 0;
        rst = 1;
        #20;
        rst = 0;
        
        for (i = 0; i < 256; i = i + 1) begin
            for (j = 0; j < 256; j = j + 1) begin
                a = i;
                b = j;
                #10;
            end
        end
        $stop;
    end

*/


endmodule
