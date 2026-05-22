`timescale 1ns / 1ps
`include "define.vh"


module rv32i_datapath (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instr_code,
    input  logic        rf_we,
    input  logic [ 3:0] alu_control,
    output logic [31:0] instr_addr
);

    logic [31:0] rs1, rs2, alu_result;

    register_file U_REG_FILE (
        .clk   (clk),
        .raddr0(instr_code[19:15]),
        .raddr1(instr_code[24:20]),
        .rf_we (rf_we),
        .waddr (instr_code[11:7]),
        .wdata (alu_result),
        .rdata0(rs1),
        .rdata1(rs2)
    );

    alu U_ALU (
        .rs1          (rs1),          //rs 1
        .rs2          (rs2),          //rs 2
        .alu_control(alu_control),
        .alu_result (alu_result)    //rd
    );

    program_counter U_PC (
        .clk   (clk),
        .rst   (rst),
        .pc_in (instr_addr), //for next program count
        .pc_out(instr_addr)  //current program count
    );

endmodule

module program_counter (
    input         clk,
    input         rst,
    input  [31:0] pc_in,
    output [31:0] pc_out
);
    logic [31:0] pc_reg;

    assign pc_out = pc_reg;

    always_ff @(posedge rst, posedge clk) begin
        if (rst) begin
            pc_reg <= 0;
        end else begin
            pc_reg <= pc_in + 4;
        end
    end

endmodule


module alu (
    input  logic [31:0] rs1,
    input  logic [31:0] rs2,
    input  logic [ 3:0] alu_control,
    output logic [31:0] alu_result
);

    always_comb begin
        alu_result = 0;
        case (alu_control[3:0])
            `ADD: alu_result = rs1 + rs2;
            `SUB: alu_result = rs1 - rs2;
            `SLL: alu_result = rs1 << rs2;
            `SLT: alu_result =  ($signed(rs1) < $signed(rs2)) ? 1 : 0; 
            `SLTU: alu_result = (rs1 < rs2) ? 1 : 0; //zero-extends
            `XOR: alu_result = rs1 ^ rs2;
            `SRL: alu_result = rs1 >> rs2[4:0];
            `SRA: alu_result = $signed(rs1) >> rs2[4:0]; //msb-extends
            `OR:  alu_result = rs1 | rs2;
            `AND: alu_result = rs1 & rs2;
        endcase
    end



endmodule

module register_file (
    input logic        clk,
    input logic [ 4:0] raddr1,
    input logic [ 4:0] raddr0,
    input logic        rf_we,
    input logic [ 4:0] waddr,
    input logic [31:0] wdata,

    output logic [31:0] rdata0,
    output logic [31:0] rdata1
);
    logic [31:0] register_file[1:31];
    int i = 0;
    initial begin
        for(i = 1; i < 32; i++) begin
            register_file[i] = i;
        end
    end

    always_ff @(posedge clk) begin
        if (rf_we) begin
            register_file[waddr] <= wdata;
        end
    end


    assign rdata0 = (raddr0) ? register_file[raddr0] : 32'h0000_0000; //rst필요없음
    assign rdata1 = (raddr1) ? register_file[raddr1] : 32'h0000_0000; //rst필요없음
    //assign rdata0 = register_file[raddr0];
    //assign rdata1 = register_file[raddr1];


endmodule
