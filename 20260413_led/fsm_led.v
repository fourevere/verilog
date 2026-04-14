`timescale 1ns / 1ps

module fsm_led(
    input       clk,
    input       rst,
    input       [2:0] sw,
    output      [2:0] led
);

    //파라미터 값은 내맘대로 설정가능
    //[2:0] 은 넣어도 차이없는듯. 하지만 지금은 3'b이라 써서 컴퓨터가 3비트로 알아먹지만 
    //그냥 숫자넣으면 컴퓨터가 알아서 생각해 처리하므로 넣어야하는게 권장인듯.
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
            //default: next_state = current_state;
        endcase
    end

    /*
    //Output Combinational Logic
    always @(*) begin
        case (current_state)
            STATE_A : led = 3'b000;
            STATE_B : led = 3'b001;
            STATE_C : led = 3'b010;
            STATE_D : led = 3'b100;
            STATE_E : led = 3'b111; 
            default : led = 3'b000;
        endcase
    end
    */
endmodule







/*
module fsm_led(
    input       clk,
    input       rst,
    input       [2:0] sw,
    output reg  [2:0] led
);


    parameter STATE_A = 2'b00, STATE_B = 2'b01, STATE_C = 2'b10;



    //state register 
    //state를 저장해야하므로 reg
    reg [1:0] current_state, next_state;
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            current_state <= STATE_A;
        end else begin
            current_state <= next_state;
        end
    end

    //next state Combinational Logic
    always @(*) begin  //입력과 state 감시
        case (current_state)
            STATE_A : begin
                if (sw == 2'b01) begin
                    next_state = STATE_B;
                end else begin
                    next_state = current_state;  //STATE_A도 가능
                end
            end
            STATE_B : begin
                if(sw == 2'b10) begin
                    next_state = STATE_C;
                end else begin
                    next_state = current_state;
                end
            end
            STATE_C : begin
                if(sw == 2'b11) begin  //왜 11이었지 그냥 그런 설계하신듯
                    next_state = STATE_A;
                end else begin
                    next_state = current_state;
                end
            end
            default: next_state = current_state;
        endcase
    end

    //Output Combinational Logic
    always @(*) begin
        case (current_state)
            STATE_A : led = 3'b001;
            STATE_B : led = 3'b010;
            STATE_C : led = 3'b100; 
            default : led = 3'b000;
        endcase
        
    end



endmodule

*/


//state 2개일때
// `timescale 1ns / 1ps


// module fsm_led(
//     input   clk,
//     input   rst,
//     input   sw,
//     output  [1:0] led
// );


//     parameter STATE_A = 1'b0, STATE_B = 1'b1;

    

//     //state register 
//     //state를 저장해야하므로 reg
//     reg current_state, next_state;
//     always @(posedge clk, posedge rst) begin
//         if(rst) begin
//             current_state <= STATE_A;
//         end else begin
//             current_state <= next_state;
//         end
//     end

//     //next state Combinational Logic
//     always @(*) begin  //입력과 state 감시
//         case (current_state)
//             STATE_A : begin
//                 if (sw == 1'b1) begin
//                     next_state = STATE_B;
//                 end else begin
//                     next_state = current_state;  //STATE_A도 가능
//                 end
//             end
//             STATE_B : begin
//                 if(sw == 1'b0) begin
//                     next_state = STATE_A;
//                 end else begin
//                     next_state = current_state;
//                 end
//             end
//             default: next_state = current_state;
//         endcase
//     end

//     //Output Combinational Logic
//     assign led = (current_state == STATE_B) ? 2'b01 : 2'b10;



// endmodule



// `timescale 1ns / 1ps

// module fsm_led(
//     input       clk,
//     input       rst,
//     input       [2:0] sw,
//     output reg  [2:0] led
// );

//     //파라미터 값은 내맘대로 설정가능
//     //[2:0] 은 넣어도 차이없는듯. 하지만 지금은 3'b이라 써서 컴퓨터가 3비트로 알아먹지만 
//     //그냥 숫자넣으면 컴퓨터가 알아서 생각해 처리하므로 넣어야하는게 권장인듯.
//     parameter [2:0] STATE_A = 3'b000, STATE_B = 3'b001, STATE_C = 3'b010, 
//                     STATE_D = 3'b100, STATE_E = 3'b111;


//     //state register 
//     //state를 저장해야하므로 reg
//     reg [2:0] current_state, next_state;




//     always @(posedge clk, posedge rst) begin
//         if(rst) begin
//             current_state <= STATE_A;
//         end else begin
//             current_state <= next_state;
//         end
//     end

//     //next state Combinational Logic
//     always @(*) begin  //입력과 state 감시

//         //always 1개로 만들때 초기화를 해야하므로 추가
//         led = 3'b000;

//         case (current_state)
//             STATE_A : begin
//                 //add. always 2개대신 1개로 만들기
//                 led = 3'b000; //moore output

//                 if (sw == 3'b001) begin
//                     next_state = STATE_B;
//                 end else if (sw == 3'b010) begin
//                     next_state = STATE_C;
//                 end else begin
//                     next_state = current_state;  //STATE_A도 가능
//                 end
//             end
//             STATE_B : begin
//                 led = 3'b001; //moore output
//                 if(sw == 3'b010) begin
//                     next_state = STATE_C;
//                 end else begin
//                     next_state = current_state;
//                 end
//             end
//             STATE_C : begin
//                 led = 3'b010; //moore output
//                 if(sw == 3'b100) begin 
//                     next_state = STATE_D;
//                 end else begin
//                     next_state = current_state;
//                 end
//             end
//             STATE_D : begin
//                 led = 3'b100; //moore output
//                 if(sw == 3'b111) begin
//                     next_state = STATE_E;
//                 end else if (sw == 3'b001) begin
//                     next_state = STATE_B;
//                 end else if (sw == 3'b000) begin
//                     next_state = STATE_A;
//                 end
//                     else begin
//                     next_state = current_state;
//                 end
//             end
//             STATE_E : begin
//                 led = 3'b111; //moore output
//                 if(sw == 3'b000) begin
//                     next_state = STATE_A;
//                 end else begin
//                     next_state = current_state;
//                 end
//             end
//             default: next_state = current_state;
//         endcase
//     end

//     /*
//     //Output Combinational Logic
//     always @(*) begin
//         case (current_state)
//             STATE_A : led = 3'b000;
//             STATE_B : led = 3'b001;
//             STATE_C : led = 3'b010;
//             STATE_D : led = 3'b100;
//             STATE_E : led = 3'b111; 
//             default : led = 3'b000;
//         endcase
//     end
//     */
// endmodule