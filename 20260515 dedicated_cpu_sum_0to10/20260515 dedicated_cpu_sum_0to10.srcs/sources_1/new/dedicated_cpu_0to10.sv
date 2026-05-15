`timescale 1ns / 1ps

module dedicated_cpu_0to10 (
    input  logic       clk,
    input  logic       rst,
    output logic [7:0] out
);

    logic ag10;
    logic asrc_sel;
    logic sumsrc_sel;
    logic areg_load;
    logic sumreg_load;
    logic outreg_load;
    logic alusrc_sel;


    data_path u_data_path (.*);

    control_unit u_control_unit (.*);

endmodule

module data_path (
    input        clk,
    input        rst,
    input        asrc_sel,
    input        sumsrc_sel,
    input        areg_load,
    input        sumreg_load,
    input        outreg_load,
    input        alusrc_sel,
    output       ag10,
    output [7:0] out
);

    logic [7:0] areg_mux_out, sumreg_mux_out, alusrc_mux_out;
    logic [7:0] areg_out, sumreg_out;
    logic [7:0] alu_result;

    mux_2x1 ASRC_MUX (
        .in0    (8'd00),
        .in1    (alu_result),
        .sel    (asrc_sel),
        .mux_out(areg_mux_out)
    );

    mux_2x1 SUMSRC_MUX (
        .in0    (8'd00),
        .in1    (alu_result),
        .sel    (sumsrc_sel),
        .mux_out(sumreg_mux_out)
    );

    register U_A_REG (
        .clk     (clk),
        .rst     (rst),
        .load    (areg_load),
        .data_in (areg_mux_out),
        .data_out(areg_out)
    );


    register U_SUM_REG (
        .clk     (clk),
        .rst     (rst),
        .load    (sumreg_load),
        .data_in (sumreg_mux_out),
        .data_out(sumreg_out)
    );

    mux_2x1 ALUSRC_MUX (
        .in0    (8'd01),
        .in1    (sumreg_out),
        .sel    (alusrc_sel),
        .mux_out(alusrc_mux_out)
    );

    alu U_ALU (
        .A         (areg_out),
        .B         (alusrc_mux_out),
        .alu_result(alu_result)
    );

    comparator U_COMP_AG10 (
        .in      (areg_out),
        .compare (8'd9),
        .comp_out(ag10)
    );

    register U_OUT_REG (
        .clk     (clk),
        .rst     (rst),
        .load    (outreg_load),
        .data_in (sumreg_out),
        .data_out(out)
    );

endmodule

module mux_2x1 (
    input  logic [7:0] in0,
    input  logic [7:0] in1,
    input  logic       sel,
    output logic [7:0] mux_out
);
    assign mux_out = sel ? in1 : in0;

    // always_comb begin
    //     if (sel == 0) mux_out = in0;
    //     else mux_out = in1;
    // end
endmodule

module register (
    input  logic       clk,
    input  logic       rst,
    input  logic       load,
    input  logic [7:0] data_in,
    output logic [7:0] data_out
);

    logic [7:0] a_register;

    assign data_out = a_register;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) a_register <= 0;
        else if (load) a_register <= data_in;
    end
endmodule

module alu (
    input  logic [7:0] A,
    input  logic [7:0] B,
    output logic [7:0] alu_result
);
    assign alu_result = A + B;
endmodule

module comparator (
    input  [7:0] in,
    input  [7:0] compare,
    output       comp_out
);
    assign comp_out = (in > compare);
endmodule

module control_unit (
    input  logic clk,
    input  logic rst,
    input  logic ag10,
    output logic asrc_sel,
    output logic sumsrc_sel,
    output logic areg_load,
    output logic sumreg_load,
    output logic outreg_load,
    output logic alusrc_sel
);

    typedef enum logic [2:0] {
        S0_IDLE,
        S1_COUNTING,
        S2_DONE,
        S3,
        S4,
        S5
    } state_t;
    state_t c_state, n_state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) c_state <= S0_IDLE;
        else c_state <= n_state;
    end

    always_comb begin
        n_state = c_state;
        asrc_sel = 0;
        sumsrc_sel = 0;
        areg_load = 0;
        sumreg_load = 0;
        outreg_load = 0;
        alusrc_sel = 0;

        case (c_state)
            S0_IDLE: begin
                // a = 0, sum = 0;
                asrc_sel = 0;
                sumsrc_sel = 0;
                areg_load = 1;
                sumreg_load = 1;
                outreg_load = 0;
                alusrc_sel = 0;
                n_state = S1_COUNTING;
            end
            S1_COUNTING: begin
                //a < 10
                asrc_sel    = 0;
                sumsrc_sel  = 0;
                areg_load   = 0;
                sumreg_load = 0;
                outreg_load = 0;
                alusrc_sel  = 0;
                if (!ag10) begin
                    n_state = S2_DONE;
                end else begin
                    n_state = S5;
                end
            end
            S2_DONE: begin
                //out = sum
                asrc_sel    = 0;
                sumsrc_sel  = 0;
                areg_load   = 0;
                sumreg_load = 0;
                outreg_load = 1;
                alusrc_sel  = 0;
                n_state     = S3;
            end
            S3: begin
                //a = a + 1
                asrc_sel    = 1;
                sumsrc_sel  = 0;
                areg_load   = 1;
                sumreg_load = 0;
                outreg_load = 0;
                alusrc_sel  = 0;
                n_state     = S4;
            end
            S4: begin
                //sum = sum + a
                asrc_sel    = 0;
                sumsrc_sel  = 1;
                areg_load   = 0;
                sumreg_load = 1;
                outreg_load = 0;
                alusrc_sel  = 1;
                n_state     = S1_COUNTING;
            end
            S5: begin
                //halt
                asrc_sel    = 0;
                sumsrc_sel  = 0;
                areg_load   = 0;
                sumreg_load = 0;
                outreg_load = 1;
                alusrc_sel  = 0;
            end
        endcase
    end

endmodule

