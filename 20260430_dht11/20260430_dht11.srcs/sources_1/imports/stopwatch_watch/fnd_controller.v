// fnd_controller.v
`timescale 1ns / 1ps

module fnd_controller #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
)(
    input        clk,
    input        rst,
    input  [1:0] sw,         //use sw 1,2 
    input  [7:0] humidity,
    input  [7:0] temperature,
    input  [8:0] distance,
    input  [3:0] i_digit_led,
    input  [MSEC_WIDTH - 1:0] msec,
    input  [ SEC_WIDTH - 1:0] sec,
    input  [ MIN_WIDTH - 1:0] min,
    input  [HOUR_WIDTH - 1:0] hour,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire       w_1khz;
    //sensor wire
    wire [3:0] w_out_mux;
    wire [3:0] w_hum_digit_1, w_hum_digit_10, w_hum_digit_100, w_hum_digit_1000;
    wire [3:0] w_temp_digit_1, w_temp_digit_10, w_temp_digit_100, w_temp_digit_1000;
    wire [3:0] w_dist_digit_1, w_dist_digit_10, w_dist_digit_100, w_dist_digit_1000;
    wire [3:0] w_out_mux_humidity, w_out_mux_temperature, w_out_mux_distance;
    wire [1:0] w_digit_sel_sensor;

    //time wire
    wire [3:0] w_out_mux_msec_sec, w_out_mux_min_hour;  //w_out_mux,
    wire [3:0] w_msec_digit_1, w_msec_digit_10;
    wire [3:0] w_sec_digit_1, w_sec_digit_10;
    wire [3:0] w_min_digit_1, w_min_digit_10;
    wire [3:0] w_hour_digit_1, w_hour_digit_10;
    wire [3:0] w_new_min_digit_1, w_new_min_digit_10, w_new_hour_digit_1;
    wire [3:0] w_new_hour_digit_10, w_new_sec_digit_1, w_new_sec_digit_10;
    wire [2:0] w_digit_sel_time;
    wire       w_comp;


    digit_splitter #(
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_MSEC_DS (
        .digit_in(msec),
        .digit_1 (w_msec_digit_1),
        .digit_10(w_msec_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(SEC_WIDTH)
    ) U_SEC_DS (
        .digit_in(sec),
        .digit_1 (w_sec_digit_1),
        .digit_10(w_sec_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(MIN_WIDTH)
    ) U_MIN_DS (
        .digit_in(min),
        .digit_1 (w_min_digit_1),
        .digit_10(w_min_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_HOUR_DS (
        .digit_in(hour),
        .digit_1 (w_hour_digit_1),
        .digit_10(w_hour_digit_10)
    );

    comparator U_COMPARATOR (
        .i_comp(msec),
        .o_comp(w_comp)
    );

    digit_splitter #(
        .BIT_WIDTH(8)
    ) U_DIGIT_SPLIT_HUMIDITY (
        .digit_in  (humidity),
        .digit_1   (w_hum_digit_1),
        .digit_10  (w_hum_digit_10),
        .digit_100 (w_hum_digit_100),
        .digit_1000(w_hum_digit_1000)
    );

    digit_splitter #(
        .BIT_WIDTH(8)
    ) U_DIGIT_SPLIT_TEMP (
        .digit_in  (temperature),
        .digit_1   (w_temp_digit_1),  
        .digit_10  (w_temp_digit_10), 
        .digit_100 (w_temp_digit_100),
        .digit_1000(w_temp_digit_1000)
    );

    digit_splitter #(
        .BIT_WIDTH(9)
    ) U_DIGIT_SPLIT_DISTANCE (
        .digit_in  (distance),
        .digit_1   (w_dist_digit_1),  
        .digit_10  (w_dist_digit_10), 
        .digit_100 (w_dist_digit_100),
        .digit_1000(w_dist_digit_1000)
    );

    //center blink mux
    mux_8x1 U_MUX_MSEC_SEC (
        .in0    (w_msec_digit_1),      // digit 1
        .in1    (w_msec_digit_10),     // digit 10
        .in2    (w_new_sec_digit_1),   // 
        .in3    (w_new_sec_digit_10),  // 
        .in4    (4'hf),
        .in5    (4'hf),
        .in6    ({3'b111, w_comp}),    // dot display
        .in7    (4'hf),
        .sel    (w_digit_sel_time),         // to select input
        .out_mux(w_out_mux_msec_sec)
    );

    mux_8x1 U_MUX_MIN_HOUR (
        .in0    (w_new_min_digit_1),    // digit 1
        .in1    (w_new_min_digit_10),   // digit 10
        .in2    (w_new_hour_digit_1),  
        .in3    (w_new_hour_digit_10), 
        .in4    (4'hf),
        .in5    (4'hf),
        .in6    ({3'b111, w_comp}),
        .in7    (4'hf),
        .sel    (w_digit_sel_time),          // to select input
        .out_mux(w_out_mux_min_hour)
    );

    //sensor mux 4x1
    mux_4x1 U_MUX_HUMIDITY (
        .in0    (w_hum_digit_1),
        .in1    (w_hum_digit_10),
        .in2    (w_hum_digit_100),
        .in3    (w_hum_digit_1000),
        .sel    (w_digit_sel_sensor),
        .out_mux(w_out_mux_humidity)
    );

    mux_4x1 U_MUX_TEMP (
        .in0    (w_temp_digit_1),  
        .in1    (w_temp_digit_10), 
        .in2    (w_temp_digit_100),
        .in3    (w_temp_digit_1000),
        .sel    (w_digit_sel_sensor),
        .out_mux(w_out_mux_temperature)
    );

    mux_4x1 U_MUX_DISTANCE (
        .in0    (w_dist_digit_1),  
        .in1    (w_dist_digit_10), 
        .in2    (w_dist_digit_100),
        .in3    (w_dist_digit_1000),
        .sel    (w_digit_sel_sensor),
        .out_mux(w_out_mux_distance)
    );

    //sensor DHT 11 mux
    mux_2x_1 U_MUX_2x1 (
        .in0    (w_out_mux_temperature),
        .in1    (w_out_mux_humidity),
        .sel    (sw[2]),
        .out_mux(w_out_mux)
    );

    mux_4x1 U_MUX_TIME_SENSOR_SEL (
        .in0    (w_out_mux_min_hour),  
        .in1    (w_out_mux_temperature), 
        .in2    (w_out_mux_msec_sec),
        .in3    (w_out_mux_humidity),
        .sel    (sw[2:1]),
        .out_mux(w_out_mux)
    );


    //blink muxs
    mux_watch_2x1 U_SEC_1D_ON_OFF (
        .in0        (w_sec_digit_1),     // 
        .in1        (4'hf),              // ff , off
        .i_comp     (w_comp),
        .i_fnd      (~sw[1] && sw[2]),
        .i_digit_led(i_digit_led[2]),
        .new_in     (w_new_sec_digit_1)
    );

    mux_watch_2x1 U_SEC_10D_ON_OFF (
        .in0        (w_sec_digit_10),     // 
        .in1        (4'hf),               // ff , off
        .i_comp     (w_comp),
        .i_fnd      (~sw[1] && sw[2]),
        .i_digit_led(i_digit_led[3]),
        .new_in     (w_new_sec_digit_10)
    );
     mux_watch_2x1 U_MIN_1D_ON_OFF (
        .in0        (w_min_digit_1),     // 
        .in1        (4'hf),              // ff , off
        .i_comp     (w_comp),
        .i_fnd      (~sw[1] && ~sw[2]),
        .i_digit_led(i_digit_led[0]),
        .new_in     (w_new_min_digit_1)
    );

    mux_watch_2x1 U_MIN_10D_ON_OFF (
        .in0        (w_min_digit_10),     // 
        .in1        (4'hf),               // ff , off
        .i_comp     (w_comp),
        .i_fnd      (~sw[1] && ~sw[2]),
        .i_digit_led(i_digit_led[1]),
        .new_in     (w_new_min_digit_10)
    );

    mux_watch_2x1 U_HOUR_1D_ON_OFF (
        .in0        (w_hour_digit_1),     // 
        .in1        (4'hf),               // ff , off
        .i_comp     (w_comp),
        .i_fnd      (~sw[1] && ~sw[2]),
        .i_digit_led(i_digit_led[2]),
        .new_in     (w_new_hour_digit_1)
    );

    mux_watch_2x1 U_HOUR_10D_ON_OFF (
        .in0        (w_hour_digit_10),     // 
        .in1        (4'hf),                // ff , off
        .i_comp     (w_comp),
        .i_fnd      (~sw[1] && ~sw[2]),
        .i_digit_led(i_digit_led[3]),
        .new_in     (w_new_hour_digit_10)
    );


    //watch, stopwatch counter
    counter_n #(
        .WIDTH(3)
    )U_COUNTER_TIME(
        .clk      (w_1khz),
        .rst      (rst),
        .digit_sel(w_digit_sel_time)
    );
    //sensor counter
    counter_n #(
        .WIDTH(2)
    )U_COUNTER_SENSOR(
        .clk      (w_1khz),
        .rst      (rst),
        .digit_sel(w_digit_sel_sensor)
    );

    decoder_2x4 U_DECODER_2x4_TIME (
        .decoder_in(w_digit_sel_time[1:0]),
        .fnd_com   (fnd_com)
    );

    decoder_2x4 U_DECODER_2x4_SENSOR (
        .decoder_in(w_digit_sel_sensor),
        .fnd_com   (fnd_com)
    );

    bcd U_BCD (
        .bin     (w_out_mux),
        .bcd_data(fnd_data)
    );
    clk_div_1khz U_CLK_DIV_1KHZ (
        .clk   (clk),
        .rst   (rst),
        .o_1khz(w_1khz)
    );



endmodule

module clk_div_1khz (
    input  clk,
    input  rst,
    output o_1khz
);

    reg [15:0] counter_reg;  // 16bit FF
    reg        o_1khz_reg;  // FF

    assign o_1khz = o_1khz_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 16'd0;
            o_1khz_reg  <= 1'b1;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == 50_000 - 1) begin
                counter_reg <= 16'd0;
                o_1khz_reg  <= ~o_1khz_reg;
            end
        end
    end

endmodule

module counter_n #(
    parameter WIDTH = 2
)(
    input clk,
    input rst,
    output [WIDTH - 1:0] digit_sel
);

    reg [WIDTH - 1:0] counter_reg;
    assign digit_sel = counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_reg + 1;
        end
    end

endmodule

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
            default: fnd_com = 4'b1111;
        endcase
    end
endmodule

module comparator (
    input  [6:0] i_comp,
    output       o_comp
);
    //0~49 : false 0 / 50~99 : true 1
    assign o_comp = (i_comp > 49) ? 1 : 0;

endmodule

module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input  [BIT_WIDTH - 1:0] digit_in,
    output [            3:0] digit_1,
    output [            3:0] digit_10,
    output [            3:0] digit_100,
    output [            3:0] digit_1000
);

    assign digit_1    = digit_in % 10;
    assign digit_10   = (digit_in / 10) % 10;
    assign digit_100  = (digit_in / 100) % 10;
    assign digit_1000 = (digit_in / 1000) % 10;

endmodule

module mux_watch_2x1 (
    input  [3:0] in0,          // 
    input  [3:0] in1,          // ff , off
    input        i_comp,
    input        i_fnd,
    input        i_digit_led,
    output [3:0] new_in
);
    wire sel;
    assign sel = i_fnd & i_digit_led & i_comp;
    assign new_in = (sel) ? in1 : in0;

endmodule

// module mux_2x_1 (
//     input  [3:0] in0,
//     input  [3:0] in1,
//     input        sel,
//     output [3:0] out_mux
// );

//     assign out_mux = (sel) ? in1 : in0;  // in0: humi, in1: temp

// endmodule

module mux_4x1 (
    input  [3:0] in0,    // digit 1
    input  [3:0] in1,    // digit 10
    input  [3:0] in2,    // digit 100
    input  [3:0] in3,    // digit 1000
    input  [1:0] sel,     // to select input
    output [3:0] out_mux
);
    // 그냥 확실하게 하기 위해서! 선연결 확실히
    reg [3:0] out_reg;
    assign out_mux = out_reg;

    //mux
    always @(*) begin
        // 모든 input list 감시할 땐 always @(*)라 씀
        case (sel)
            2'b00:   out_reg = in0;
            2'b01:   out_reg = in1;
            2'b10:   out_reg = in2;
            2'b11:   out_reg = in3;
            default: out_reg = 4'b0000;
        endcase
    end

endmodule

module mux_8x1 (
    input  [3:0] in0,    // digit 1
    input  [3:0] in1,    // digit 10
    input  [3:0] in2,    // 
    input  [3:0] in3,
    input  [3:0] in4,
    input  [3:0] in5,
    input  [3:0] in6,
    input  [3:0] in7,
    input  [2:0] sel,     // to select input
    output [3:0] out_mux
);
    // 그냥 확실하게 하기 위해서! 선연결 확실히
    reg [3:0] out_reg;
    assign out_mux = out_reg;

    //mux
    always @(*) begin
        // 모든 input list 감시할 땐 always @(*)라 씀
        case (sel)
            3'b000:  out_reg = in0;
            3'b001:  out_reg = in1;
            3'b010:  out_reg = in2;
            3'b011:  out_reg = in3;
            3'b100:  out_reg = in4;
            3'b101:  out_reg = in5;
            3'b110:  out_reg = in6;
            3'b111:  out_reg = in7;
            default: out_reg = 4'b0000;
        endcase
    end

endmodule



module bcd (
    input      [3:0] bin,
    output reg [7:0] bcd_data
);

    always @(bin) begin  // 항상 bin을 감시하라
        case (bin)
            4'b0000: bcd_data = 8'hc0;
            4'b0001: bcd_data = 8'hf9;
            4'b0010: bcd_data = 8'ha4;
            4'b0011: bcd_data = 8'hb0;
            4'b0100: bcd_data = 8'h99;
            4'b0101: bcd_data = 8'h92;
            4'b0110: bcd_data = 8'h82;
            4'b0111: bcd_data = 8'hf8;
            4'b1000: bcd_data = 8'h80;
            4'b1001: bcd_data = 8'h90;
            4'b1010: bcd_data = 8'h88;
            4'b1011: bcd_data = 8'h83;
            4'b1100: bcd_data = 8'hc6;
            4'b1101: bcd_data = 8'ha1;
            4'b1110: bcd_data = 8'h86;
            4'b1111: bcd_data = 8'h8e;
            default: bcd_data = 8'hff;

        endcase

    end
endmodule
