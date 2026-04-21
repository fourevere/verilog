`timescale 1ns / 1ps

module uart (
    input        clk,
    input        rst,
    input        btnR,
    input  [7:0] tx_data,
    output       tx
);

    wire w_start, w_b_tick;

    button_debounce U_BD_TX_START (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR),
        .o_btn(w_start)
    );

    uart_tx U_UART_TX (
        .clk     (clk),
        .rst     (rst),
        .tx_start(w_start),
        .tx_data (tx_data),
        .i_b_tick(w_b_tick),
        .tx      (tx)
    );

    baud_tick_gen U_BAUD_TICK_GEN (

        .clk(clk),
        .rst(rst),
        .o_b_tick(w_b_tick)
    );

endmodule


module uart_tx (
    input        clk,
    input        rst,
    input        tx_start,  //start trigger
    input  [7:0] tx_data,
    input        i_b_tick,
    output       tx
);

    parameter IDLE = 0, WAIT = 1, START = 2;
    parameter BIT0 = 3, BIT1 = 4, BIT2 = 5;
    parameter BIT3 = 6, BIT4 = 7, BIT5 = 8;
    parameter BIT6 = 9, BIT7 = 10, STOP = 11;

    reg [3:0] c_state, n_state;

    reg tx_reg, tx_next;  //순차
    // tx data register
    reg [7:0] data_reg, data_next;


    assign tx = tx_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state  <= IDLE;
            tx_reg   <= 1'b1;
            data_reg <= 8'h00;
        end else begin
            c_state  <= n_state;
            tx_reg   <= tx_next;
            data_reg <= data_next;
        end
    end

    //start 신호가 들어오는건데 어디에 넣어야할지 고민하고 있었음. 
    //애초에 들어오는 값이라 내가 정하는게 아닌데. 

    //next st CL, output
    always @(*) begin
        n_state   = c_state;  //n_state
        tx_next   = tx_reg;  // tx output
        data_next = data_reg;
        case (c_state)
            IDLE: begin
                tx_next = 1'b1;
                if (tx_start) begin
                    data_next = tx_data;
                    n_state <= WAIT;
                end
            end
            WAIT: begin
                if (i_b_tick) begin
                    n_state <= START;
                end
            end
            START: begin  //tick이 1올때까지 0을 내보냄
                tx_next = 1'b0;
                if (i_b_tick) begin
                    n_state <= BIT0;
                end
            end
            BIT0: begin
                tx_next = data_reg[0];
                if (i_b_tick) begin
                    n_state <= BIT1;
                end
            end
            BIT1: begin
                tx_next = data_reg[1];
                if (i_b_tick) begin
                    n_state <= BIT2;
                end
            end
            BIT2: begin
                tx_next = data_reg[2];
                if (i_b_tick) begin
                    n_state <= BIT3;
                end
            end
            BIT3: begin
                tx_next = data_reg[3];
                if (i_b_tick) begin
                    n_state <= BIT4;
                end
            end
            BIT4: begin
                tx_next = data_reg[4];
                if (i_b_tick) begin
                    n_state <= BIT5;
                end
            end
            BIT5: begin
                tx_next = data_reg[5];
                if (i_b_tick) begin
                    n_state <= BIT6;
                end
            end
            BIT6: begin
                tx_next = data_reg[6];
                if (i_b_tick) begin
                    n_state <= BIT7;
                end
            end
            BIT7: begin
                tx_next = data_reg[7];
                if (i_b_tick) begin
                    n_state <= STOP;
                end
            end
            STOP: begin
                tx_next = 1'b1;
                if (i_b_tick) begin
                    n_state <= IDLE;
                end
            end
        endcase
    end

endmodule



module baud_tick_gen (

    input      clk,
    input      rst,
    output reg o_b_tick
);
    //이정도는 눈감고도 해야함
    //baud tick 9600bps (hz) tick gen
    parameter F_COUNT = 100_000_000 / 9600;
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
