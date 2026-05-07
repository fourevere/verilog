`timescale 1ns / 1ps

class transction;
    rand bit [7:0] a;
    rand bit [7:0] b;
    rand bit       mode;
    bit      [7:0] s;
    bit            c;
endclass

class generator;  //동적으로 생성되는 소프트웨어
    transction tr;  //메모리할당

    // 소프트웨어라 virtual 필요(소프트웨어에서 하드웨어 신호에 접근하기 위한 포인터 역할)
    virtual adder_interface adder_vif;
    function new(virtual adder_interface adder_vinterf);
        adder_vif = adder_vinterf;
    endfunction

    task run();
        tr.randomize();
    endtask
endclass

interface adder_interface ();  //고정된 물리적 선
    logic [7:0] a;
    logic [7:0] b;
    logic mode;
    logic [7:0] s;
    logic c;
endinterface

module tb_alu ();
    adder_interface adder_if ();
    generator gen;
    adder dut (
        .a(adder_if.a),
        .b(adder_if.b),
        .mode(adder_if.mode),  //0():sum,1:sub
        .s(adder_if.s),
        .c(adder_if.c)
    );
    initial begin
        gen = new(adder_if);
    end
endmodule
