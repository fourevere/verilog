`timescale 1ns / 1ps

module TOP_sr04_controller (
   
    input        clk,
    input        rst,
    input        btn_R,
    input        echo,
    output       trig,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire [8:0] w_distance;
    wire w_tick_us;
    wire w_sr04_start;


        
    ila_0 U_ILA0 (
        //무조건 시스템클럭
        .clk(clk),
        .probe0(w_sr04_start),
        .probe1(w_distance)
    );

    btn_debounce U_BD_SR04_START (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn_R),
        .o_btn(w_sr04_start)
    );


    tick_gen_us U_TICK_GEN_US (
        .clk    (clk),
        .rst    (rst),
        .tick_us(w_tick_us)
    );


    sr04_controller U_SR04_CNTL (
        .clk       (clk),
        .rst       (rst),
        .sr04_start(w_sr04_start),
        .tick_us   (w_tick_us),
        .echo      (echo),
        .trig      (trig),
        .distance  (w_distance)
    );


    fnd_cotroller U_FND_CNTL (
        .clk     (clk),
        .rst     (rst),
        .fnd_in  ({5'b00000, w_distance}),
        .fnd_com (fnd_com),
        .fnd_data(fnd_data)
    );


endmodule


module sr04_controller (
    input clk,
    input rst,
    input sr04_start,
    input tick_us,
    input echo,
    output trig,
    output reg [8:0] distance
);


    parameter IDLE = 0, START = 1, WAIT = 2, REPONSE = 3;
    parameter BIT = $clog2(400 * 58);


    reg [1:0] c_state, n_state;
    reg trig_reg, trig_next;
    reg [BIT:0] tick_cnt_reg, tick_cnt_next;

    assign trig = trig_reg;
    //assign distance = (!echo) ? tick_cnt_reg / 58 : 0;


    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= IDLE;
            trig_reg <= 1'b0;
            tick_cnt_reg <= 1'b0;
        end else begin
            c_state <= n_state;
            trig_reg <= trig_next;
            tick_cnt_reg <= tick_cnt_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        trig_next = trig_reg;
        tick_cnt_next = tick_cnt_reg;
        distance = tick_cnt_next / 58;

        case (c_state)
            IDLE: begin
                //tick_cnt_next = 1'b0; 트러블슈팅 : 초기화해서 안나오는오류
                trig_next = 1'b0;
                if (sr04_start) begin
                    n_state = START;
                end
            end
            START: begin
                trig_next = 1'b1;
                if (tick_us) begin
                    if (tick_cnt_reg > 10) begin
                        n_state = WAIT;
                    end
                end else begin
                    tick_cnt_next = tick_cnt_reg + 1;
                end
            end
            WAIT: begin
                trig_next = 1'b0;
                if (tick_us) begin
                    if (echo) begin
                        tick_cnt_next = 0;
                        n_state = REPONSE;
                    end
                end
            end
            REPONSE: begin
                if (tick_us) begin
                    if (!echo) begin
                        //tick_cnt_next = 0;
                        n_state = IDLE;

                    end
                end else begin
                    tick_cnt_next = tick_cnt_reg + 1;
                end
            end
        endcase
    end


    //노이즈가 껴서 메타스테이블 터질수있음. CDC(센서에서오는신호는 CDC라서)
    //그래서 tick 읽는게 좋음. 100MHz말고. 


endmodule


module tick_gen_us (
    input      clk,
    input      rst,
    output reg tick_us
);

    parameter F_COUNT = 100_000_000 / 1_000_000;

    reg [$clog2(F_COUNT) - 1 : 0] counter_reg;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            tick_us <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == F_COUNT - 1) begin
                counter_reg <= 0;
                tick_us <= 1'b1;
            end else begin
                tick_us <= 1'b0;
            end
        end
    end

endmodule
