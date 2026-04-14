`timescale 1ns / 1ps


module tb_fsm_led();


    reg     clk, rst;
    reg     [2:0] sw;
    wire    [2:0] led;

    fsm_led dut(
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .led(led)
    );

    //여기서만 negedge 바꾸기?

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1'b1;

        //reset
        #20;
        rst = 1'b0;

        // state a -> b
        sw = 3'b001;
        // wait : next positive clock
        @(posedge clk);
        @(posedge clk);

        // state b -> c
        sw = 3'b010;
        @(posedge clk);
        @(posedge clk);

        //state c-> d
        sw = 3'b100;
        @(posedge clk);
        @(posedge clk);

        //state d -> e
        sw = 3'b111;
        @(posedge clk);
        @(posedge clk);        

        //state e -> a
        sw = 3'b000;
        @(posedge clk);
        @(posedge clk);   


        //state a -> c
        sw = 3'b010;
        @(posedge clk);
        @(posedge clk);

        //state c -> d (이미 본거)
        sw = 3'b100;
        @(posedge clk);
        @(posedge clk);

        //state d -> b
        sw = 3'b001;
        @(posedge clk);
        @(posedge clk);

        //state b -> c (이미 본거)
        sw = 3'b010;
        @(posedge clk);
        @(posedge clk);

        //state c -> d (이미 본거)
        sw = 3'b100;
        @(posedge clk);
        @(posedge clk);

        //state d -> a
        sw = 3'b000;
        @(posedge clk);
        @(posedge clk);
        $stop;

    end


endmodule





// `timescale 1ns / 1ps


// module tb_fsm_led();


//     reg     clk, rst;
//     reg     [1:0] sw;
//     wire    [2:0] led;

//     fsm_led dut(
//         .clk(clk),
//         .rst(rst),
//         .sw(sw),
//         .led(led)
//     );



//     always #5 clk = ~clk;

//     initial begin
//         clk = 0;
//         rst = 1'b1;

//         //reset
//         #20;
//         rst = 1'b0;

//         // state a -> b
//         // sw = 2'b01;
//         sw = 2'b01;
//         // wait : next positive clock
//         @(posedge clk);
//         @(posedge clk);


//         // state b -> c
//         // sw = 2'b10;
//         sw = 2'b10;
//         @(posedge clk);
//         @(posedge clk);


//         //state c-> a
//         sw = 2'b11;

//         @(posedge clk);
//         @(posedge clk);
//         $stop;

//     end


// endmodule