`timescale 1ns / 1ps

module fnd_cotroller (
    input  [13:0] fnd_in,
    input        rst,
    input        clk,
    output [3:0] fnd_com,
    output [7:0] fnd_data

);

    //assign fnd_com = 4'b1110;  //1개만 사용할거니까 이렇게 넣음

    wire [3:0]  w_o_mux, w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [1:0]  w_digit_sel;
    wire        w_1khz;


    //인스턴스라고 하시네
    digit_splitter U_DIGIT_SPLIT (
        .digit_in(fnd_in),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );


    mux_4x1 U_MUX_4x1 (
        .i_in0(w_digit_1),  //digit 1
        .i_in1(w_digit_10),  //digit 10
        .i_in2(w_digit_100),  //digit 100
        .i_in3(w_digit_1000),  //digit 1000
        .i_sel(w_digit_sel),  //to select input
        .o_mux(w_o_mux)
    );

    bcd U_BCD (
        .bin(w_o_mux),
        .bcd_data(fnd_data)
    );


    counter_4 U_COUNTER_4(
        .clk(w_1khz),
        .rst(rst),
        .digit_sel(w_digit_sel)
    );

    clk_div_1khz U_CLK_DIV_1KHZ(
    .clk(clk),
    .rst(rst),
    .o_1khz(w_1khz)
    );


    decoder_2x4 U_DECODER_2x4 (
        .decoder_in(w_digit_sel),
        .fnd_com(fnd_com)
    );




//포트만 바꿔주고 2개만 바꾸래.  14비트. fnd_in

endmodule


module clk_div_1khz (
    input   clk,
    input   rst,
    output  o_1khz
);

    reg [15:0] counter_reg; //모듈이 다르므로 중복 허용

    reg o_1khz_reg;  //output reg 안하는 이유: 초기화해야되서, 하는방법도 있지만 이해를위해 했다심
    assign o_1khz = o_1khz_reg;   
    

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 16'd0;
            o_1khz_reg <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == (50_000 - 1)) begin //보기편할려고 숫자_ 붙임
                counter_reg <= 16'd0;
                o_1khz_reg <= ~o_1khz_reg;
            end
        end
    end
    
endmodule


module bcd (
    input [3:0] bin,
    output reg [7:0] bcd_data
);


    always @(bin) begin
        case (bin)
            4'b0000: bcd_data = 8'hC0;
            4'b0001: bcd_data = 8'hF9;
            4'b0010: bcd_data = 8'hA4;
            4'b0011: bcd_data = 8'hB0;
            4'b0100: bcd_data = 8'h99;
            4'b0101: bcd_data = 8'h92;
            4'b0110: bcd_data = 8'h82;
            4'b0111: bcd_data = 8'hF8;
            4'b1000: bcd_data = 8'h80;
            4'b1001: bcd_data = 8'h90;
            4'b1010: bcd_data = 8'h88;
            4'b1011: bcd_data = 8'h83;
            4'b1100: bcd_data = 8'hC6;
            4'b1101: bcd_data = 8'hA1;
            4'b1110: bcd_data = 8'h86;
            4'b1111: bcd_data = 8'h8E;
            default: bcd_data = 8'hFF;
        endcase
    end


endmodule

//2026.04.08

module mux_4x1 (
    input  [3:0] i_in0,  //digit 1
    input  [3:0] i_in1,  //digit 10
    input  [3:0] i_in2,  //digit 100
    input  [3:0] i_in3,  //digit 1000
    input  [1:0] i_sel,  //to select input
    output [3:0] o_mux
);
    reg [3:0] o_reg;
    assign o_mux = o_reg;//위에 output을 output reg로 바꾸거나 이렇게 하면 된다고함. 
                         //이렇게하면 밑도 o_mux에서 o_reg로 바꿔야 함.

    //mux, (*) all input: sensitivity list
    always @(*) begin  /*i_in0, i_in1, i_in2, i_in3, i_sel*/
        case (i_sel)
            2'b00: o_reg = i_in0;  //출력 = 입력임 참고로 기억할것.
            2'b01: o_reg = i_in1;
            2'b10: o_reg = i_in2;
            2'b11: o_reg = i_in3;
            default:
            o_reg = 4'b0000;   //bxxxx로 처리하는 이유: 실수가 있으면 보기 쉽게할려고 하는듯.회사마다다름.
        endcase
    end

endmodule


//2026.04.08
module digit_splitter (
    input  [13:0] digit_in,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);
    assign digit_1 = digit_in % 10;
    assign digit_10 = (digit_in / 10) % 10;
    assign digit_100 = (digit_in / 100) % 10;
    assign digit_1000 = (digit_in / 1000) % 10;

endmodule

//2026.04.08
module decoder_2x4 (
    input [1:0] decoder_in,
    output reg [3:0] fnd_com
);

    always @(*) begin
        case (decoder_in)
            2'b00:   fnd_com = 4'b1110;
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;  //모두 끄겠다는뜻
        endcase

    end



endmodule


module counter_4 (
    input       clk,
    input       rst,
    output [1:0] digit_sel
);

    reg [1:0] counter_reg;

    assign digit_sel = counter_reg;


    always @(posedge clk, posedge rst) begin  //clk의 신호에 상승엣지가 발생할때마다 begin end 발동 or rst에 상승엣지~~
        if (rst) begin
            counter_reg <= 0;  //? 0으로 초기화라는데
        end else begin
            counter_reg <= counter_reg + 1;   //발생할때마다 1증가하셈.
        end
    end


endmodule