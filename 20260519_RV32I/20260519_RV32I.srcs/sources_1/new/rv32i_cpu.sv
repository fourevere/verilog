`timescale 1ns / 1ps
`include "define.vh"

module rv32i_cpu (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instr_code,
    output logic [31:0] instr_addr
);

    logic rf_we;
    logic [3:0] alu_control;

    rv32i_control_unit U_CONTROL_UNIT (
        .instr_code(instr_code),
        .*
    );

    rv32i_datapath U_DATA_PATH (.*);

endmodule
