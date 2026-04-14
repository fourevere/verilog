`timescale 1ns / 1ps


module tb_4bit_full_adder ();

    reg [3:0] a, b;
    wire [3:0] s;
    wire c;

    integer i, j;

    full_adder_4bit dut (
        .a  (a),
        .b  (b),
        .cin(1'b0),
        .s  (s),
        .c  (c)
    );  //앞에서 이미 배열로 했으므로 굳이 여기서는 길게쓸필요가 없어서 줄이기 가능

    initial begin
        i = 0;
        j = 0;
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i;
                b = j;
                #10;
            end
        end
        $stop;
    end
    
endmodule




