`timescale 1ns / 1ps

module fsm_led(
    input       clk,
    input       rst,
    input       [2:0] sw,
    output      [2:0] led
);

    parameter [2:0] STATE_A = 3'b000, STATE_B = 3'b001, STATE_C = 3'b010, 
                    STATE_D = 3'b100, STATE_E = 3'b111;


    //state register 
    //state를 저장해야하므로 reg
    reg [2:0] current_state, next_state;


    //output SL
    reg [2:0] led_reg, led_next;

    assign led = led_reg;



    always @(posedge clk, posedge rst) begin
        if(rst) begin
            current_state <= STATE_A;
            led_reg       <= 3'b000;
        end else begin
            current_state <= next_state;
            led_reg       <= led_next;
        end
    end

    //next state Combinational Logic
    always @(*) begin  //입력과 state 감시
        next_state = current_state;
        led_next   = led_reg;

        case (current_state)
            STATE_A : begin
                //add. always 2개대신 1개로 만들기
                led_next = 3'b000; //moore output

                if (sw == 3'b001) begin
                    next_state = STATE_B;
                end else if (sw == 3'b010) begin
                    next_state = STATE_C;
                end else begin
                    next_state = current_state;  //STATE_A도 가능
                end
            end
            STATE_B : begin
                led_next = 3'b001; //moore output
                if(sw == 3'b010) begin
                    next_state = STATE_C;
                end else begin
                    next_state = current_state;
                end
            end
            STATE_C : begin
                led_next = 3'b010; //moore output
                if(sw == 3'b100) begin 
                    next_state = STATE_D;
                end else begin
                    next_state = current_state;
                end
            end
            STATE_D : begin
                led_next = 3'b100; //moore output
                if(sw == 3'b111) begin
                    next_state = STATE_E;
                end else if (sw == 3'b001) begin
                    next_state = STATE_B;
                end else if (sw == 3'b000) begin
                    next_state = STATE_A;
                end
                    else begin
                    next_state = current_state;
                end
            end
            STATE_E : begin
                led_next = 3'b111; //moore output
                if(sw == 3'b000) begin
                    next_state = STATE_A;
                end else begin
                    next_state = current_state;
                end
            end
        endcase
    end

endmodule