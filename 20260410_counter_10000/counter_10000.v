`timescale 1ns / 1ps


module counter_10000 (
    input   clk,
    input   rst,
    //2026.04.10
    input   [2:0] sw,
    
    output  [3:0] fnd_com,
    output  [7:0] fnd_data
);

    wire    [13:0] w_tick_counter;
    //2026.04.10
    wire    w_run_stop, w_clear, w_mode;

    Control_Unit U_CNTL_UNIT(
        .sw(sw),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear),
        .o_mode(w_mode)
    );
    //////////////////////////////////////////////

    fnd_cotroller U_FND_CNTL(
        .fnd_in(w_tick_counter),
        .rst(rst),
        .clk(clk),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)

    );


    datapath U_DATAPATH(
        .clk(clk),
        .rst(rst),
        .i_run_stop(w_run_stop),
        .i_clear(w_clear),
        .i_mode(w_mode),
        .o_tick_counter(w_tick_counter)
    );


endmodule


module clk_tick_gen ( //10Hz짜리 tick을 만들어내는 코드. tick_counter라는 모듈로 보내고.
    input      clk,
    input      rst,
    output reg o_tick
);

    //counter = 100_000_000  / 10 : 100Mhz -> 10hz   
    //뺴기 1 은 0까지니까 한거
    reg [$clog2(100_000_000/10) - 1:0] counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 24'd0;
            o_tick      <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            o_tick      <= 1'b0;  //동시처리라서 1이 올라감과 동시에 0으로 초기화도 되는듯
            if (counter_reg == (10_000_000) - 1) begin
                //천만마다 출력을 발생시키고싶음.
                counter_reg <= 24'd0;
                o_tick <= 1'b1;
            end
        end
    end

endmodule


module datapath (
    input clk,
    input rst,
    //2026.04.10
    input i_run_stop,
    input i_clear,
    input i_mode,

    output [13:0] o_tick_counter
);

    wire w_tick_10hz;

    //2026.04.10
    wire o_runstop_clk, o_clear_rst;

    and (o_runstop_clk, i_run_stop, clk);
    or (o_clear_rst, i_clear, rst);

    clk_tick_gen U_CLK_TICK_GEN(
        .clk(o_runstop_clk),
        .rst(o_clear_rst),
        .o_tick(w_tick_10hz)
    );

    tick_counter U_TICK_COUNTER(
        .clk(o_runstop_clk),
        .rst(o_clear_rst),
        .i_tick(w_tick_10hz),
        .mode(i_mode),
        .o_tick_counter(o_tick_counter)
    );




endmodule

//예전 tick_counter
// module tick_counter (  //100Mhz를 받아 동작. 
//     input         clk,
//     input         rst,
//     input         i_tick,
//     output [13:0] o_tick_counter
// );

//     reg [$clog2(10_000) - 1:0] tick_counter_reg;  //[10000-1부터 0까지 ] 이름 

//     assign o_tick_counter = tick_counter_reg;

//     always @(posedge clk, posedge rst) begin
//         if (rst) begin
//             tick_counter_reg <= 14'd0;
//         end else begin  //rst == 0인 상태 매번 카운트를 증가시키는건 앞의코드고 이번엔 1일때만
//             //if(i_tick == 1'b1) begin //tick이 1일때만 카운터하는코드(이래서 i_tick이 빠졌었음)
//             if(i_tick) begin   //아마 0과1뿐이라 쓰는듯? 이건 개인적인 생각. 어쨋든 같음.
//                 tick_counter_reg <= tick_counter_reg + 1;
//                 if (tick_counter_reg == (10_000) - 1) begin
//                         tick_counter_reg <= 14'd0;
//                 end 
//             end
//         end
//     end

// endmodule







//2026.04.10
module Control_Unit (
    input   [2:0] sw,
    output  o_run_stop,
    output  o_clear,
    output  o_mode
);

    assign {o_mode, o_clear, o_run_stop} = sw[2:0];  //가장 오른쪽이 0이 매칭 되므로 이렇게 해야합니다.


endmodule






module tick_counter (  //100Mhz를 받아 동작. 
    input         clk,
    input         rst,
    input         i_tick,
    input         mode,                 //add 2026.04.10
    output [13:0] o_tick_counter
);


    reg [$clog2(10_000) - 1:0] tick_counter_reg;

    assign o_tick_counter = tick_counter_reg;

    //add updown conter mode
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            tick_counter_reg <= 14'd0;
        end else begin  // rst == 0인 상태
            if (i_tick) begin   // i_tick == 1'b1 대신 간결하게 표현
                if (!mode) begin 
                    // Up Counter Mode
                    tick_counter_reg <= tick_counter_reg + 1;
                    if (tick_counter_reg == (10_000) - 1) begin
                        tick_counter_reg <= 14'd0;
                    end
                end else begin 
                    // Down Counter Mode
                    tick_counter_reg <= tick_counter_reg - 1;
                    if (tick_counter_reg == 14'd0) begin
                        tick_counter_reg <= (10_000) - 1;
                    end
                end
            end
        end
    end






    // reg [$clog2(10_000) - 1:0] tick_counter_reg;  //[10000-1부터 0까지 ] 이름 

    // assign o_tick_counter = tick_counter_reg;

    // always @(posedge clk, posedge rst) begin
    //     if (rst) begin
    //         tick_counter_reg <= 14'd0;
    //     end else begin  //rst == 0인 상태 매번 카운트를 증가시키는건 앞의코드고 이번엔 1일때만
    //         //if(i_tick == 1'b1) begin //tick이 1일때만 카운터하는코드(이래서 i_tick이 빠졌었음)
    //         if(i_tick) begin   //아마 0과1뿐이라 쓰는듯? 이건 개인적인 생각. 어쨋든 같음.
    //             tick_counter_reg <= tick_counter_reg + 1;
    //             if (tick_counter_reg == (10_000) - 1) begin
    //                     tick_counter_reg <= 14'd0;
    //             end 
    //         end
    //     end
    // end









endmodule
