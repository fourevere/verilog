`timescale 1ns / 1ps

class transction;
    rand bit [7:0] a;
    rand bit [7:0] b;
    rand bit       mode;
    bit      [7:0] s;
    bit            c;

    function debug_print(string name);
        $display("%t : [%s] a = %d, b = %d, mode = %d, s = %d c = %d", $time, name, a, b,
                 mode, s, c);
    endfunction

endclass

interface adder_interface ();  //고정된 물리적 선
    logic [7:0] a;
    logic [7:0] b;
    logic       mode;
    logic [7:0] s;
    logic       c;
endinterface


//to generate random stimulus
class generator;
    transction tr;
    mailbox #(transction) gen2drv_mbox;
    function new(mailbox#(transction) gen2drv_mbox);
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction

    task run();
        tr = new();
        tr.randomize();
        tr.debug_print("GEN");
        gen2drv_mbox.put(tr);
    endtask

endclass

//to drive by interface stimulus
class driver;
    transction tr;
    virtual adder_interface adder_vif;
    mailbox #(transction) gen2drv_mbox;
    function new(mailbox#(transction) gen2drv_mbox,
                 virtual adder_interface adder_vinterf);
        this.adder_vif = adder_vinterf;
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction

    task run();
        gen2drv_mbox.get(tr);
        tr.debug_print("DRV");
        adder_vif.a = tr.a;
        adder_vif.b = tr.b;
        adder_vif.mode = tr.mode;
        #10;
    endtask
endclass

class monitor;
    transction tr;
    virtual adder_interface adder_vif;
    mailbox #(transction) mon2scb_mbox;
    function new(mailbox#(transction) mon2scb_mbox,
                 virtual adder_interface adder_vinterf);
        this.mon2scb_mbox = mon2scb_mbox;
        this.adder_vif    = adder_vinterf;
    endfunction

    task run();
        tr = new;
        tr.a = adder_vif.a;
        tr.b = adder_vif.b;
        tr.mode = adder_vif.mode;
        tr.s = adder_vif.s;
        tr.c = adder_vif.c;
        mon2scb_mbox.put(tr);
        tr.debug_print("MON");
    endtask

endclass

class scoreboard;
    transction tr;
    mailbox #(transction) mon2scb_mbox;
    function new(mailbox#(transction) mon2scb_mbox);
        this.mon2scb_mbox = mon2scb_mbox;
    endfunction

    task run();
        mon2scb_mbox.get(tr);
        tr.debug_print("SCB");
    endtask
endclass


//manager
class environment;
    generator gen;
    driver    drv;
    monitor  mon;
    scoreboard scb;
    mailbox   #(transction) gen2drv_mbox;
    mailbox   #(transction) mon2scb_mbox;
    function new(virtual adder_interface adder_vif);
        gen2drv_mbox = new;
        mon2scb_mbox = new;
        gen = new(gen2drv_mbox);
        drv = new(gen2drv_mbox, adder_vif);
        mon = new(mon2scb_mbox, adder_vif);
        scb = new(mon2scb_mbox);
    endfunction

    task run(int count);  //이러면 1번 딱 돌거
        repeat (count) begin
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        end
    endtask
endclass

//tb_alu_sv
module tb_alu_sv ();
    adder_interface adder_if ();
    environment env;


    adder dut (
        .a(adder_if.a),
        .b(adder_if.b),
        .mode(adder_if.mode),
        .s(adder_if.s),
        .c(adder_if.c)
    );
    initial begin
        env = new(adder_if);
        env.run(10);
        $stop;
    end
endmodule

