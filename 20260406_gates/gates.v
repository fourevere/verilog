`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/06 10:56:49
// Design Name: 
// Module Name: gates
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gates(   //top module
    input a, 
    input b, 
    output y0,  //and gate
    output y1,  //nand 
    output y2,  //or
    output y3,  //nor
    output y4,  //xor
    output y5,  //xnor
    output y6   //not
); 
    //assign 뜻: 항상 연결해라
    //순서는 없음. 배치나 다른것에 따라 먼저 연결될것. 동시배치
    assign y0 = a & b;   // &: and operator
    assign y1 = ~(a & b);
    assign y2 = a | b; // | : or operator
    assign y3 = ~(a | b);
    assign y4 = a ^ b; //^ : hat, exor operator
    assign y5 = ~(a ^ b); //ex nor
    assign y6 = ~a;

endmodule

