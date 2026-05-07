`timescale 1ns / 1ps

class transction;
    rand bit [7:0] a;
    rand bit [7:0] b;
    rand bit       mode;
    bit      [7:0] s;
    bit            c;
endclass

interface adder_interface();  //고정된 물리적 선
    logic [7:0] a;
    logic [7:0] b;
    logic mode;
    logic [7:0] s;
    logic c;
endinterface

class generator;  //동적으로 생성되는 소프트웨어
    transction tr;  //메모리할당안됨. handler만 생성된상태

    // 소프트웨어라 virtual 필요(소프트웨어에서 하드웨어 신호에 접근하기 위한 포인터 역할)
    virtual adder_interface adder_vif;
    //클래스 정의때 초기화하는 함수로 정해져있는듯
    function new(virtual adder_interface adder_vinterf);
        adder_vif = adder_vinterf;
        tr = new;
    endfunction

    task run(int repeat_count);  //drive 
        repeat(repeat_count) begin
            tr.randomize(); 
            adder_vif.a = tr.a; //데이터저장변수라 괄호쓰면 X
            adder_vif.b = tr.b;
            adder_vif.mode = tr.mode;
            #10;
        end
    endtask
endclass


module tb_alu();
    adder_interface adder_if();
    generator gen;  //정적할당. handler만생성된듯
    adder dut (
        .a(adder_if.a),
        .b(adder_if.b),
        .mode(adder_if.mode),  //0():sum,1:sub
        .s(adder_if.s),
        .c(adder_if.c)
    );
    initial begin
        gen = new(adder_if);  //동적할당 
        gen.run(10);
        $stop;
    end
endmodule
