`timescale 1ns / 1ps

module uart (
    input        clk,
    input        rst,
    input        tx_start,
    input  [7:0] tx_data,
    input        rx,
    output [7:0] rx_data,
    output       rx_done,
    output       tx_busy,
    output       tx
);

    wire w_b_tick;


    uart_tx U_UART_TX (
        .clk     (clk),
        .rst     (rst),
        .tx_start(tx_start),
        .tx_data (tx_data),
        .i_b_tick(w_b_tick),
        .tx_busy (tx_busy),
        .tx      (tx)
    );

    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .b_tick(w_b_tick),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    baud_tick_gen U_BAUD_TICK_GEN (
        .clk(clk),
        .rst(rst),
        .o_b_tick(w_b_tick)
    );

endmodule

module uart_rx (
    input        clk,
    input        rst,
    input        rx,
    input        b_tick,
    output [7:0] rx_data,
    output       rx_done
);

    parameter IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [1:0] c_state, n_state;
    reg [4:0] b_tick_cnt_reg, b_tick_cnt_next;
    reg [2:0] bit_cnt_reg, bit_cnt_next;
    reg [7:0] data_reg, data_next;
    reg rx_done_reg, rx_done_next;

    assign rx_done = rx_done_reg;
    assign rx_data = data_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state        <= IDLE;
            b_tick_cnt_reg <= 0;
            bit_cnt_reg    <= 0;
            data_reg       <= 8'h00;
            rx_done_reg    <= 1'b0;

        end else begin
            c_state        <= n_state;
            b_tick_cnt_reg <= b_tick_cnt_next;
            bit_cnt_reg    <= bit_cnt_next;
            data_reg       <= data_next;
            rx_done_reg    <= rx_done_next;
        end

    end

    always @(*) begin
        n_state = c_state;
        b_tick_cnt_next = b_tick_cnt_reg;
        bit_cnt_next = bit_cnt_reg;
        data_next = data_reg;
        rx_done_next = rx_done_reg;

        case (c_state)
            IDLE: begin
                rx_done_next = 0;
                if (b_tick && (!rx)) begin
                    b_tick_cnt_next = 0;
                    //이건 문제였던건지 아닌지 모르겠음
                    //bit_cnt_next    = 0;
                    n_state         = START;
                end else n_state = IDLE;
            end
            START: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 7) begin
                        b_tick_cnt_next = 0;
                        bit_cnt_next    = 0;
                        n_state         = DATA;


                        //여기 else문이 밑 if문에 들어있어서 동작안함
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        // bit right shift
                        data_next = {rx, data_reg[7:1]};
                        b_tick_cnt_next = 0;
                        if (bit_cnt_reg == 7) begin
                            b_tick_cnt_next = 0;
                            n_state = STOP;
                        end else begin
                            bit_cnt_next = bit_cnt_reg + 1;
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                if (b_tick) begin
                    if ((b_tick_cnt_reg == 23) || ((b_tick_cnt_reg > 16) && !rx)) begin
                        rx_done_next = 1'b1;
                        n_state = IDLE;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule


module uart_tx (
    input        clk,
    input        rst,
    input        tx_start,  //start trigger
    input  [7:0] tx_data,
    input        i_b_tick,
    output       tx_busy,
    output       tx
);

    parameter IDLE = 0, START = 1;
    parameter DATA = 2, STOP = 3;

    reg [1:0] c_state, n_state;

    reg tx_reg, tx_next;  //순차
    // tx data register
    reg [7:0] data_reg, data_next;

    reg [2:0] bit_cnt_reg, bit_cnt_next;
    reg [3:0] b_tick_cnt_reg, b_tick_cnt_next;
    reg tx_busy_reg, tx_busy_next;

    assign tx = tx_reg;
    assign tx_busy = tx_busy_reg;
    //state register
    // current : output, next :input

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state        <= IDLE;
            tx_reg         <= 1'b1;
            data_reg       <= 8'h00;
            bit_cnt_reg    <= 3'b000;
            b_tick_cnt_reg <= 4'h0;
            tx_busy_reg    <= 1'b0;
        end else begin
            c_state        <= n_state;
            tx_reg         <= tx_next;
            data_reg       <= data_next;
            bit_cnt_reg    <= bit_cnt_next;
            b_tick_cnt_reg <= b_tick_cnt_next;
            tx_busy_reg    <= tx_busy_next;
        end
    end

    //start 신호가 들어오는건데 어디에 넣어야할지 고민하고 있었음. 
    //애초에 들어오는 값이라 내가 정하는게 아닌데. 

    //next st CL, output
    always @(*) begin
        n_state         = c_state;  //n_state
        tx_next         = tx_reg;  // tx output
        data_next       = data_reg;
        bit_cnt_next    = bit_cnt_reg;
        b_tick_cnt_next = b_tick_cnt_reg;
        tx_busy_next    = tx_busy_reg;

        case (c_state)
            IDLE: begin
                tx_next = 1'b1;
                tx_busy_next = 1'b0;
                if (tx_start) begin
                    tx_busy_next    = 1'b1;
                    data_next       = tx_data;
                    b_tick_cnt_next = 0;
                    n_state         = START;
                end
            end
            START: begin  //tick이 1올때까지 0을 내보냄
                tx_next = 1'b0;
                if (i_b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        b_tick_cnt_next = 0;
                        bit_cnt_next = 3'b000;
                        n_state = DATA;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end

            // DATA: begin
            //     tx_next = data_reg[bit_cnt_reg];
            //     if (i_b_tick) begin
            //         if (bit_cnt_reg == 7) begin
            //             n_state <= STOP;
            //         end
            //     end else begin
            //         bit_cnt_next = bit_cnt_reg + 1;
            //         n_state = DATA;
            //     end
            // end

            // DATA: begin

            //     //PIPO 패러렐아웃풋
            //     //tx_next = data_reg[bit_cnt_reg];

            //     //PISO 시리얼아웃풋
            //     //to output from bit 0 of data_reg 
            //     tx_next = data_reg[0];

            //     if (i_b_tick) begin
            //         //내가 여기를 넣어서 한클럭이 더 빨리 들어간거같은?느낌
            //         //관계잇나?싶긴한데 이건 물어봐야할듯
            //         //bit_cnt_next = bit_cnt_reg + 1;
            //         if (bit_cnt_reg == 7) begin
            //             n_state <= STOP;
            //         end
            //     end else begin
            //         //right shift 1bit data register
            //         data_next = {1'b0, data_reg[7:1]};
            //         bit_cnt_next = bit_cnt_reg + 1;
            //         n_state = DATA;
            //     end
            // end


            DATA: begin

                //PIPO 패러렐아웃풋
                //tx_next = data_reg[bit_cnt_reg];

                //PISO 시리얼아웃풋
                //to output from bit 0 of data_reg 
                tx_next = data_reg[0];

                if (i_b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        b_tick_cnt_next = 0;
                        if (bit_cnt_reg == 7) begin
                            n_state = STOP;
                        end else begin
                            //right shift 1bit data register
                            data_next = {1'b0, data_reg[7:1]};
                            bit_cnt_next = bit_cnt_reg + 1;
                            n_state = DATA;
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1;
                if (i_b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        tx_busy_next = 0;
                        n_state = IDLE;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule

//baud tick * 16
module baud_tick_gen (

    input      clk,
    input      rst,
    output reg o_b_tick
);
    //이정도는 눈감고도 해야함
    //baud tick 9600bps (hz) tick gen
    parameter F_COUNT = 100_000_000 / (9600 * 16);
    parameter WIDTH = $clog2(F_COUNT) - 1;
    reg [WIDTH:0] conuter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            conuter_reg <= 0;
            o_b_tick    <= 1'b0;
        end else begin
            //period 9600hz
            conuter_reg <= conuter_reg + 1;  //상승때마다 1증가
            if (conuter_reg == F_COUNT - 1) begin
                conuter_reg <= 0;
                o_b_tick <= 1;
            end else begin
                o_b_tick <= 1'b0;
            end
        end
    end

endmodule
