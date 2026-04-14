`timescale 1ns / 1ps

//Top: design, hw in/out
module adder_fnd (
    input clk,
    input rst,
    input  [7:0] a,
    input  [7:0] b,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output       led
);

    wire [7:0] w_sum;

    fnd_cotroller U_FND_CNTL (
        //.bin(w_sum),
        .clk        (clk),
        .rst        (rst),
        .fnd_in     (w_sum),
        .fnd_com    (fnd_com),
        .fnd_data   (fnd_data)

    );


    /*    full_adder_4bit U_FA_4 (
        .a  (a),
        .b  (b),
        .cin(1'b0),
        .s  (w_sum),
        .c  (led)
    );*/



    adder_8bit U_ADDER_8BIT (
        .a(a),
        .b(b),
        .s(w_sum),
        .c(led)
    );

endmodule




module full_adder (
    input  a,
    input  b,
    input  cin,
    output s,
    output c
);

    wire w_s1, w_c1, w_c2;//값을 바꾸는게 목적이 아니기 때문.연결할 변수라 wire로 지정
    assign c = w_c1 | w_c2;  //이게 최종결과 c

    half_adder U_HA0 (
        .a(a),  //from full_adder input a
        .b(b),  //from full_adder input b        //결국 여기 괄호는 입력오는 변수가 뭐냐를 뜻하고
        .s(w_s1),                                //여기는 어디에 출력할 건지 변수를 넣는거인듯
        .c(w_c1)
    );

    half_adder U_HA1 (
        .a(w_s1),  //from full_adder input a  
        .b(cin),   //from full_adder input cin  
        .s(s),     //to full adder output s
        .c(w_c2)
    );


endmodule


module half_adder (
    input  a,
    input  b,
    output s,
    output c
);

    //assign s = a ^ b;
    //assign c = a & b;
    xor(s,a,b);
    //xor U_XOR0 (s,a,b);
    and(c,a,b);


endmodule

//////////////////////////////////////////////////////////////////////////////////////////////
module full_adder_4bit (
    input [3:0] a,
    b,
    input cin,
    output [3:0] s,
    output c
);
    wire w_c0, w_c1, w_c2;

    full_adder U_FA0 (
        .a  (a[0]),
        .b  (b[0]),
        .cin(cin),
        .s  (s[0]),
        .c  (w_c0)   //to FA1 cin 
    );
    full_adder U_FA1 (
        .a  (a[1]),
        .b  (b[1]),
        .cin(w_c0),
        .s  (s[1]),
        .c  (w_c1)   //to FA2 cin 
    );
    full_adder U_FA2 (
        .a  (a[2]),
        .b  (b[2]),
        .cin(w_c1),
        .s  (s[2]),
        .c  (w_c2)   ////to FA3 cin 
    );
    full_adder U_FA3 (
        .a  (a[3]),
        .b  (b[3]),
        .cin(w_c2),
        .s  (s[3]),
        .c  (c)
    );


endmodule
///////////////////////////////////////////////////////////////////////////////////////////
module adder_8bit (
    input [7:0] a,
    b,
    output [7:0] s,
    output c
);
    wire w_c0;

    //lower bit 3:0
    full_adder_4bit U_FA_4BIT0 (
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(1'b0),
        .s(s[3:0]),
        .c(w_c0)  //to U_FA_4BIT1 of cin
    );

    //upper bit 7:4
    full_adder_4bit U_FA_4BIT1 (
        .a  (a[7:4]),
        .b  (b[7:4]),
        .cin(w_c0),
        .s  (s[7:4]),
        .c  (c)
    );


endmodule
