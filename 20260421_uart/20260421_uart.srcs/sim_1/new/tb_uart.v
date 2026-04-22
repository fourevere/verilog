`timescale 1ns / 1ps

module tb_uart ();


    //(system clock * 1clock time) / BAUD
    parameter UART_BAUD_PERIOD = (100_000_000 * 10 / 9600);

    // Inputs
    reg clk;
    reg rst;
    reg btnR;
    reg [7:0] tx_data;

    // Outputs
    wire tx;

    // Instantiate the Unit Under Test (UUT)
    uart uut (
        .clk(clk),
        .rst(rst),
        .btnR(btnR),
        .tx_data(tx_data),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin

        clk     = 0;
        rst     = 1;
        btnR    = 0;
        tx_data = 8'h30;

        @(negedge clk);
        @(negedge clk);
        rst = 0;

        //button push btnR
        //for tx start trigger
        btnR = 1;
        #(110000);
        btnR = 0;

        //1bit
        repeat(10) #(UART_BAUD_PERIOD);
        #100;


        btnR = 1;
        tx_data = 8'h31;
        #(110000);
        btnR = 0;

        //1bit
        repeat(10) #(UART_BAUD_PERIOD);
        #1000;

        $stop;
    end

endmodule
