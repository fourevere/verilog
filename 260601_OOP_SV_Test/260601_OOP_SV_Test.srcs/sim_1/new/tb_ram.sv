`timescale 1ns / 1ps

interface ram_intf (
    input logic clk
);
    logic we;
    logic [7:0] addr;
    logic [7:0] wdata;
    logic [7:0] rdata;
endinterface

class transaction;
    rand logic [7:0] addr;
    rand logic [7:0] wdata;
    logic [7:0] rdata;
endclass  //transaction



class test_ram;
    transaction tr;

    virtual ram_intf ram_if;
    function new(virtual ram_intf ram_if);
        this.ram_if = ram_if;
        tr = new();
    endfunction

    //task write(logic [7:0] addr, logic [7:0] data);
    task write();
        ram_if.we = 1;
        ram_if.addr = tr.addr;
        ram_if.wdata = tr.wdata;
        @(posedge ram_if.clk);
        $display("we:%0h, addr:%0h, wadata:%0h", ram_if.we, ram_if.addr,
                 ram_if.wdata);
    endtask

    //task read(logic [7:0] addr);
    task read();
        ram_if.we   = 0;
        ram_if.addr = tr.addr;
        @(posedge ram_if.clk);
        tr.rdata = ram_if.rdata;
        $display("we:%0h, addr:%0h, radata:%0h", ram_if.we, ram_if.addr,
                 ram_if.rdata);
    endtask

    virtual function result();     //virtual : 자식 class에서 재정의 할 수 있음
        if (tr.wdata != tr.rdata) begin
            $display("FAIL! wdata:%0h != rdata:%0h", tr.wdata, tr.rdata);
        end else begin
            $display("PASS! wdata:%0h == rdata:%0h", tr.wdata, tr.rdata);
        end

    endfunction

    virtual task test_run(int loop);
        repeat (loop) begin
            tr.randomize();
            write();
            read();
            result();
        end
    endtask
endclass

class test_ram_child extends test_ram;  //why? 부모클래스를 수정하면 안될때
    int pass, fail;
    function new(virtual ram_intf ram_if);
        super.new(ram_if);    //부모class를 인스턴스화
        pass = 0;
        fail = 0;
    endfunction

    virtual function result();
        if (tr.wdata != tr.rdata) begin
            $display("FAIL! wdata:%0h != rdata:%0h", tr.wdata, tr.rdata);
            fail++;
        end else begin
            $display("PASS! wdata:%0h == rdata:%0h", tr.wdata, tr.rdata);
            pass++;
        end
    endfunction

    function report();
        $display("fail count       : %0d", fail);
        $display("pass count       : %0d", pass);
        $display("total test count : %0d", pass + fail);

    endfunction

    virtual task test_run(int loop);
        repeat (loop) begin
            tr.randomize();
            write();
            read();
            result();
        end
        report();
    endtask
endclass

module tb_ram ();
    logic clk;

    ram_intf ram_if (clk);
    test_ram_child RAM;

    always #5 clk = ~clk;

    ram dut (
        .clk(ram_if.clk),
        .we(ram_if.we),
        .addr(ram_if.addr),
        .wdata(ram_if.wdata),
        .rdata(ram_if.rdata)
    );

    initial begin
        RAM = new(ram_if);
        clk = 0;
        repeat (5) @(posedge clk);
        // RAM.write(8'h00, 8'h01);
        // RAM.read(8'h00);
        // RAM.write(8'h01, 8'h02);
        // RAM.read(8'h01);
        // RAM.write(8'h02, 8'h03);
        // RAM.read(8'h02);
        // RAM.write(8'h03, 8'h04);
        // RAM.read(8'h03);

        // repeat (100) begin
        //     RAM.randomize();
        //     RAM.write();
        //     RAM.read();

        // end


        RAM.test_run(100);


        repeat (5) @(posedge clk);
        $finish;
    end
endmodule
