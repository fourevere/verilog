`timescale 1ns / 1ps

module instraction_mem (  //instruction
    input  logic [31:0] instr_addr,
    output logic [31:0] instr_code
);

    logic [31:0] instr_rom[0:15];

    initial begin
        instr_rom[0] = 32'h0041_82b3;  //x5 = x3 + x4 add   7
        instr_rom[1] = 32'h4061_87b3;  //x15 = x3 - x6 sub   -3
        instr_rom[2] = 32'h0021_92b3;  //x5 = x3 << x2 sll   12
        instr_rom[3] = 32'h0027_a2b3;  //x5 = x15 < x2 ? 1:0 slt   3 < 2
        instr_rom[4] = 32'h0027_b2b3;  //x5 = x15 < x2 ? 1:0 sltu  -3 < 2
        instr_rom[5] = 32'h0033_c2b3;  //x5 = x7 ^ x3 xor    4
        instr_rom[6] = 32'h0022_52b3;  //x5 = x4 >> x2 srl   1
        instr_rom[7] = 32'h4071_8233;  //x4 = x3 - x7  sub2  -4
        instr_rom[8] = 32'h4022_52b3;  //x5 = x4 >>> x2 sra  -1
        instr_rom[9] = 32'h0031_62b3;  //x5 = x2 | x3 or      3
        instr_rom[10] = 32'h0031_72b3; //x5 = x2 & x3 and     2
    end
    assign instr_code = instr_rom[instr_addr[31:2]];



endmodule