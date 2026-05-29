`timescale 1ns / 1ps

module top_rv32i_soc (
    input clk,
    input rst
);
    logic [31:0] instr_code, instr_addr;
    logic [ 2:0] mem_mode;
    //logic       dwe;

    logic [31:0] Addr;
    logic [31:0] WDATA;
    logic        W_REQ;
    logic        R_REQ;
    logic [31:0] RDATA;
    logic        READY;
    logic        PREADY0;
    logic        PREADY1;
    logic        PREADY2;
    logic        PREADY3;
    logic        PREADY4;
    logic [31:0] PRDATA0;
    logic [31:0] PRDATA1;
    logic [31:0] PRDATA2;
    logic [31:0] PRDATA3;
    logic [31:0] PRDATA4;
    logic        PSEL0;
    logic        PSEL1;
    logic        PSEL2;
    logic        PSEL3;
    logic        PSEL4;
    logic        PENABLE;
    logic        PWRITE;
    logic [31:0] PADDR;
    logic [31:0] PWDATA;


    instraction_mem U_INSTR_ROM (.*);
    rv32i_cpu U_RV32I_CPU (.*);
    //data_mem U_DATA_RAM (.*);

    APB_master U_APB_MASTER (
        .PCLK  (clk),
        .PRESET(rst),
        .Addr  (Addr),
        .WDATA (WDATA),
        .W_REQ (W_REQ),
        .R_REQ (R_REQ),
        .RDATA (RDATA),
        .READY (READY),

        .PSEL0  (PSEL0),
        .PREADY0(PREADY0),
        .PRDATA0(PRDATA0),
        .*

    );

    APB_bram U_APB_BRAM (
        .PCLK  (clk),
        .*,
        .PSEL  (PSEL0),
        .PREADY(PREADY0),
        .PRDATA(PRDATA0)
    );



endmodule
