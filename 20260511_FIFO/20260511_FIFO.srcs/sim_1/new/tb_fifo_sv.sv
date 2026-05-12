`timescale 1ns / 1ps

interface fifo_interface;
    logic       clk;
    logic       rst;
    logic [7:0] push_data;
    logic       push;
    logic       pop;
    logic [7:0] pop_data;
    logic       full;
    logic       empty;
endinterface  //fifo_interface

class transaction;

    rand bit [7:0] push_data;
    rand bit       push;
    rand bit       pop;
    //bit            rst;
    bit      [7:0] pop_data;
    bit            full;
    bit            empty;

    //int            test_mode;

    function debug_print(string name);
        $display(
            "%t : [%s] push = %d, pop = %d, push_data = %d, pop_data = %d, full =%d, empty = %d",
            $time, name, push, pop, push_data, pop_data, full, empty);
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
            //assert (tr.randomize())
            //else $error("[GEN] tr.randomize() error!");
            tr.randomize();
            gen2drv_mailbox.put(tr);
            // tr.debug_print("GEN");
            @event_gen_next;
        end
    endtask
endclass  //generator

class driver;
    transaction tr;
    mailbox #(transaction) gen2drv_mailbox;
    event event_gen_next;
    virtual fifo_interface fifo_vif;
    function new(mailbox#(transaction) gen2drv_mailbox,
                 virtual fifo_interface fifo_vif, event event_gen_next);
        this.gen2drv_mailbox = gen2drv_mailbox;
        this.fifo_vif = fifo_vif;
        this.event_gen_next = event_gen_next;
    endfunction  //new()

    task preset();
        fifo_vif.rst = 1;
        @(posedge fifo_vif.clk);
        @(posedge fifo_vif.clk);
        fifo_vif.rst = 0;

        @(negedge fifo_vif.clk);
        //assertion check full, empty
        assert (fifo_vif.empty) $display("[DRV Assert] reset pass : empty!");
        else $display("[DRV Assert] reset fail : empty = %d", fifo_vif.empty);

        assert (!fifo_vif.full) $display("[DRV Assert] reset pass : full!");
        else $display("[DRV Assert] reset fail : full = %d", fifo_vif.full);
    endtask

    task push_only(int count);
        $display("fifo push only test");
        repeat (count) begin
            gen2drv_mailbox.get(tr);
            @(posedge fifo_vif.clk);
            #1;
            fifo_vif.push = 1;
            fifo_vif.push_data = tr.push_data;
            fifo_vif.pop = 0;  //굳이 드라이브하는 시점은 아님.
            ->event_gen_next;
        end
    endtask

    // task run();
    //     forever begin
    //         gen2drv_mailbox.get(tr);
    //         tr.debug_print("DRV");
    //         @(posedge fifo_vif.clk);
    //         #1;
    //         fifo_vif.push_data = tr.push_data;
    //         fifo_vif.push = tr.push;
    //         fifo_vif.pop = tr.pop;
    //     end
    // endtask
endclass  //driver

class monitor;
    transaction tr;
    mailbox #(transaction) mon2scb_mailbox;
    virtual fifo_interface fifo_vif;
    function new(mailbox#(transaction) mon2scb_mailbox,
                 virtual fifo_interface fifo_vif);
        this.mon2scb_mailbox = mon2scb_mailbox;
        this.fifo_vif = fifo_vif;
    endfunction  //new()

    // task run();
    //     forever begin
    //         @(negedge fifo_vif.clk);
    //         //            #1;
    //         tr = new();
    //         tr.push_data = fifo_vif.push_data;
    //         tr.push = fifo_vif.push;
    //         tr.pop = fifo_vif.pop;
    //         tr.pop_data = fifo_vif.pop_data;
    //         tr.full = fifo_vif.full;
    //         tr.empty = fifo_vif.empty;
    //         mon2scb_mailbox.put(tr);
    //         tr.debug_print("MON");
    //     end
    // endtask
endclass

class scoreboard;
    transaction tr;
    mailbox #(transaction) mon2scb_mailbox;
    event event_gen_next;
    int total_cnt = 0, pass_cnt = 0, fail_cnt = 0;
    //byte mem[256];
    // logic [7:0] fifo_que[$:15];
    // logic [7:0] pop_que;

    function new(mailbox#(transaction) mon2scb_mailbox, event event_gen_next);
        this.mon2scb_mailbox = mon2scb_mailbox;
        this.event_gen_next  = event_gen_next;
    endfunction  //new()

    // task run();
    //     forever begin
    //         mon2scb_mailbox.get(tr);
    //         tr.debug_print("SCB");
    //         case ({
    //             tr.push, tr.pop
    //         })
    //             2'b10: begin
    //                 if (!tr.full) begin
    //                     fifo_que.push_front(tr.push_data);
    //                 end
    //             end
    //             2'b01: begin
    //                 if (!tr.empty) begin
    //                     pop_que = fifo_que.pop_back();
    //                     if (pop_que == tr.pop_data) begin
    //                         total_cnt++;
    //                         pass_cnt++;
    //                         $display("%t : PASS", $time);
    //                     end else begin
    //                         total_cnt++;
    //                         fail_cnt++;
    //                         $display("%t : FAIL", $time);
    //                     end
    //                 end
    //             end
    //             2'b11: begin
    //                 if (tr.full) begin
    //                     pop_que = fifo_que.pop_back();
    //                     if (pop_que == tr.pop_data) begin
    //                         total_cnt++;
    //                         pass_cnt++;
    //                         $display("%t : PASS", $time);
    //                     end else begin
    //                         total_cnt++;
    //                         fail_cnt++;
    //                         $display("%t : FAIL", $time);
    //                     end
    //                 end else if (tr.empty) begin
    //                     fifo_que.push_front(tr.push_data);
    //                 end else begin
    //                     fifo_que.push_front(tr.push_data);
    //                     pop_que = fifo_que.pop_back();
    //                     if (pop_que == tr.pop_data) begin
    //                         total_cnt++;
    //                         pass_cnt++;
    //                         $display("%t : PASS", $time);
    //                     end else begin
    //                         total_cnt++;
    //                         fail_cnt++;
    //                         $display("%t : FAIL", $time);
    //                     end
    //                 end
    //             end
    //         endcase
    //         ->event_gen_next;
    //     end
    // endtask  //run
endclass  //scoreboard


class environment;

    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    mailbox #(transaction) gen2drv_mailbox;
    mailbox #(transaction) mon2scb_mailbox;
    event event_gen_next;
    virtual fifo_interface fifo_vif;
    int run_count;


    function new(virtual fifo_interface fifo_vif);
        gen2drv_mailbox = new();
        mon2scb_mailbox = new();
        gen = new(gen2drv_mailbox, event_gen_next);
        drv = new(gen2drv_mailbox, fifo_vif, event_gen_next);
        mon = new(mon2scb_mailbox, fifo_vif);
        scb = new(mon2scb_mailbox, event_gen_next);

        this.fifo_vif = fifo_vif;
    endfunction  //new()

    task run();
        //reset test by assertion
        drv.preset();
        //push only test for full signal "1"
        run_count = 16;
        fork
            gen.run(run_count);
            drv.push_only(run_count);
        join
        $display("[ENV] push only test end");
        #10;    //full인식못해서 주는 딜레이
        if (fifo_vif.full) $display("PASS : push only test");
        else $display("FAIL: push only test");
        #20;
        $stop;
        // fork
        //     gen.run(10);
        //     drv.run();
        //     mon.run();
        //     scb.run();
        // join_any
        // #10;
        // $display("env run task end");

        // $display("________________________");
        // $display("**SRAM IP Verification**");
        // $display("** total test num =%3d**", scb.total_cnt);
        // $display("** Pass test num = %2d**", scb.pass_cnt);
        // $display("** Fail test num = %2d**", scb.fail_cnt);
        // $display("________________________");
        // $stop;
    endtask
endclass  //environment


module tb_fifo_sv ();

    fifo_interface fifo_if ();
    environment env;

    fifo_sv dut (
        .clk(fifo_if.clk),
        .rst(fifo_if.rst),
        .push_data(fifo_if.push_data),
        .push(fifo_if.push),
        .pop(fifo_if.pop),
        .pop_data(fifo_if.pop_data),
        .full(fifo_if.full),
        .empty(fifo_if.empty)

    );

    always #5 fifo_if.clk = ~fifo_if.clk;
    initial begin
        fifo_if.clk = 0;
        env = new(fifo_if);
        env.run();
    end

endmodule

