`timescale 1ns / 1ps



module tb_counter_10000_rscm();

    reg clk, rst;
    reg [2:0] sw;

    wire [3:0] fnd_com;
    wire [7:0] fnd_data;


    counter_10000 dut(
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );


    always #5 clk = ~clk;

    initial begin
        //초기 상태
        clk = 0;
        rst = 1;
    
        #20;
        rst = 0;


        //mode
        sw[0] = 1;
        sw[1] = 0;
        sw[2] = 0;
        #1_000_000_000;

        sw[0] = 1;
        sw[1] = 0;
        sw[2] = 1;
        #1_000_000_000;


        //stop run
        sw[0] = 0;
        sw[1] = 0;
        sw[2] = 1;
        #1_000_000_000;

        sw[0] = 1;
        sw[1] = 0;
        sw[2] = 1;
        #1_000_000_000;

        //clear
        sw[0] = 1;
        sw[1] = 1;
        sw[2] = 1;
        #1_000_000_000;

        sw[0] = 1;
        sw[1] = 0;
        sw[2] = 1;
        #1_000_000_000;

        $stop;

    end

endmodule


