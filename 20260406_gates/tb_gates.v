`timescale 1ns / 1ps

//탑이면서 외부 인바이어먼트 모듈
module tb_gates ();

    reg a_reg, b;
    wire y0_wire, y1, y2, y3, y4, y5, y6;

    gates dut (  //top module
        .a(a_reg),
        .b(b),
        .y0(y0_wire),  //and gate
        .y1(y1),  //nand 
        .y2(y2),  //or
        .y3(y3),  //nor
        .y4(y4),  //xor
        .y5(y5),  //xnor
        .y6(y6)  //not
    );
    initial begin
        a_reg = 0;
        b = 0;
        #10;
        a_reg = 0;
        b = 1;
        #10;
        a_reg = 1;
        b = 0;
        #10;
        a_reg = 1;
        b = 1;
        #10;
        $finish;
    end

endmodule
