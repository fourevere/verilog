`timescale 1ns / 1ps

interface ram_interface;
    logic       clk;
    logic [7:0] addr;
    logic [7:0] wdata;
    logic       we;
    logic [7:0] rdata;

endinterface  //ram_interface

class transaction;

    rand bit [7:0] addr;
    rand bit [7:0] wdata;
    rand bit       we;
    bit      [7:0] rdata;

    constraint addr_range {addr < 10;}

    function debug_print(string name);
        $display("%t : [%s] addr = %d, wdata = %d, we = %d, rdata = %d", $time,
                 name, addr, wdata, we, rdata);
    endfunction

endclass  //transaction

class generator;

    transaction tr;
    mailbox #(transaction) gen2drv_mailbox;
    event event_gen_next;

    function new(mailbox#(transaction) gen2drv_mailbox, event event_gen_next);
        this.gen2drv_mailbox = gen2drv_mailbox;
        this.event_gen_next  = event_gen_next;
    endfunction  //new()

    task run(int count);
        repeat (count) begin
            tr = new();
            assert(tr.randomize())
            else $error("[GEN] tr.randomize() error!");
            gen2drv_mailbox.put(tr);
            tr.debug_print("GEN");
            @event_gen_next;
        end
    endtask

endclass  //generator

class driver;

    transaction tr;
    mailbox #(transaction) gen2drv_mailbox;
    virtual ram_interface ram_vif;
    function new(mailbox#(transaction) gen2drv_mailbox,
                 virtual ram_interface ram_vif);
        this.gen2drv_mailbox = gen2drv_mailbox;
        this.ram_vif = ram_vif;
    endfunction  //new()

    task preset();
        ram_vif.addr  = 0;
        ram_vif.wdata = 0;
        ram_vif.we    = 0;
        @(posedge ram_vif.clk);
    endtask

    task run();
        forever begin
            gen2drv_mailbox.get(tr);
            tr.debug_print("DRV");
            @(posedge ram_vif.clk);
            #1;
            ram_vif.addr = tr.addr;
            ram_vif.wdata = tr.wdata;
            ram_vif.we = tr.we;
        end
    endtask


endclass  //driver

class monitor;

    transaction tr;
    mailbox #(transaction) mon2scb_mailbox;
    virtual ram_interface ram_vif;
    function new(mailbox#(transaction) mon2scb_mailbox,
                 virtual ram_interface ram_vif);
        this.mon2scb_mailbox = mon2scb_mailbox;
        this.ram_vif = ram_vif;
    endfunction  //new()

    task run();
        forever begin
            @(posedge ram_vif.clk);
            //            #1;
            tr = new();
            tr.addr = ram_vif.addr;
            tr.wdata = ram_vif.wdata;
            tr.rdata = ram_vif.rdata;
            tr.we = ram_vif.we;
            mon2scb_mailbox.put(tr);
            tr.debug_print("MON");
        end
    endtask

endclass

class scoreboard;
    transaction tr;
    mailbox #(transaction) mon2scb_mailbox;
    event event_gen_next;
    int total_cnt = 0, pass_cnt = 0, fail_cnt = 0;

    byte mem[256];

    function new(mailbox#(transaction) mon2scb_mailbox, event event_gen_next);
        this.mon2scb_mailbox = mon2scb_mailbox;
        this.event_gen_next  = event_gen_next;
    endfunction  //new()

    task run();
        forever begin
            mon2scb_mailbox.get(tr);
            tr.debug_print("SCB");
            total_cnt++;
            //pass fail
            if (tr.we) begin  //write senario
                mem[tr.addr] = tr.wdata;
            end else begin  //read senario
                if (tr.rdata == mem[tr.addr]) begin
                    pass_cnt++;
                    $display("%t : PASS", $time);
                end else begin
                    fail_cnt++;
                    $display(
                        "%t : FAIL addr = %d, rdata = %d, compare data = %d",
                        $time, tr.addr, tr.rdata, mem[tr.addr]);
                end
            end
            ->event_gen_next;
        end
    endtask

endclass  //scoreboard


class environment;

    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    mailbox #(transaction) gen2drv_mailbox;
    mailbox #(transaction) mon2scb_mailbox;
    event event_gen_next;
    function new(virtual ram_interface ram_vif);
        gen2drv_mailbox = new();
        mon2scb_mailbox = new();
        gen = new(gen2drv_mailbox, event_gen_next);
        drv = new(gen2drv_mailbox, ram_vif);
        mon = new(mon2scb_mailbox, ram_vif);
        scb = new(mon2scb_mailbox, event_gen_next);
    endfunction  //new()

    task run();
        //ram interface initial
        drv.preset();

        fork
            gen.run(20);
            drv.run();
            mon.run();
            scb.run();
        join_any
        #10;
        $display("env run task end");

        $display("________________________");
        $display("**SRAM IP Verification**");
        $display("** total test num =%3d**", scb.total_cnt);
        $display("** Pass test num = %2d**", scb.pass_cnt);
        $display("** Fail test num = %2d**", scb.fail_cnt);
        $display("________________________");

        $stop;
    endtask
endclass  //environment



module tb_ram_sv ();

    ram_interface ram_if ();

    environment env;

    ram_ip dut (
        .clk(ram_if.clk),
        .addr(ram_if.addr),
        .wdata(ram_if.wdata),
        .we(ram_if.we),
        .rdata(ram_if.rdata)
    );

    always #5 ram_if.clk = ~ram_if.clk;

    initial begin
        ram_if.clk = 0;
        env = new(ram_if);
        env.run();
    end

endmodule
