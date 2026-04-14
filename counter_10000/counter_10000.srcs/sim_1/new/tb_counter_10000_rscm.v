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
        

        //sw[0], sw[1], sw[2] 변화에 따른 상태 시뮬 시나리오

        //sw[0]가 1일때 sw[2]가 0이면 0~9999까지 가는걸 보여주고 sw[2]가 1이라면 9999~0까지 가는걸 보여주고
        
        //sw[1]이 1이 된다면 fnd_data가 어떤 값이든 0으로 바뀌는걸 보여주고

        //sw[0]가 0에서 1에서 다시 0이되고 다시 1이 되도 sw[2]가 안바껴서 그대로 다시 잘 작동하는걸 보여주고


    end

endmodule


