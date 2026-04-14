`timescale 1ns / 1ps


module tb_adder ();

    reg a, b, cin;  //input
    wire s, c;  //output

    //instaciation
    //dut : design under test
    //uut : unit under test
    //cct : ?
    full_adder dut (
        .a  (a),
        .b  (b),
        .cin(cin),
        .s  (s),
        .c  (c)
    );

    initial begin
        //init, time control
        a   = 0;
        b   = 0;
        cin = 0;
        #10;  //10ns
        a   = 0;
        b   = 1;
        cin = 0;
        #10;
        a   = 1;
        b   = 0;
        cin = 0;
        #10;
        a   = 1;
        b   = 1;
        cin = 0;
        #10;
        a   = 0;
        b   = 0;
        cin = 1;
        #10;  //10ns
        a   = 0;
        b   = 1;
        cin = 1;
        #10;
        a   = 1;
        b   = 0;
        cin = 1;
        #10;
        a   = 1;
        b   = 1;
        cin = 1;
        #10;
        $stop;
    end


endmodule
