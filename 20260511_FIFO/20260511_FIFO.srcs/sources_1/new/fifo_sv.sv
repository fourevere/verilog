`timescale 1ns / 1ps



module fifo_sv (
    input  logic       clk,
    input  logic       rst,
    input  logic [7:0] push_data,
    input  logic       push,
    input  logic       pop,
    output logic [7:0] pop_data,
    output logic       full,
    output logic       empty

);

    logic [3:0] wptr, rptr;


    reg_file REG_FILE (
        .*,
        .wdata(push_data),
        .waddr(wptr),
        .raddr(rptr),
        .we(~full & push),
        .rdata(pop_data)

    );

    control_unit CONTROL_UNIT (
        .*,
        .wptr (wptr),
        .rptr (rptr)
    );


endmodule

module reg_file (
    input  logic       clk,
    input  logic [7:0] wdata,
    input  logic [3:0] waddr,
    input  logic [3:0] raddr,
    input  logic       we,
    output logic [7:0] rdata

);

    logic [7:0] reg_file[0:15];

    always_ff @(posedge clk) begin
        if (we) begin
            reg_file[waddr] <= wdata;
        end
    end

    assign rdata = reg_file[raddr];

endmodule



module control_unit (
    input logic clk,
    input logic rst,
    input logic push,
    input logic pop,
    output logic empty,
    output logic full,
    output logic [3:0] wptr,
    output logic [3:0] rptr
);

    //하나로 짤수도 있다고함. reg,next 없이 

    logic full_next, full_reg;
    logic empty_next, empty_reg;
    logic [3:0] wptr_next, wptr_reg;
    logic [3:0] rptr_next, rptr_reg;

    assign wptr = wptr_reg;
    assign rptr = rptr_reg;
    assign full = full_reg;
    assign empty = empty_reg;


    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            wptr_reg  <= 0;
            full_reg  <= 0;
            empty_reg <= 1;
            rptr_reg  <= 0;
        end else begin
            wptr_reg  <= wptr_next;
            rptr_reg  <= rptr_next;
            empty_reg <= empty_next;
            full_reg  <= full_next;
        end
    end

    always @(*) begin
        wptr_next  = wptr_reg;
        rptr_next  = rptr_reg;
        empty_next = empty_reg;
        full_next  = full_reg;

        case ({
            push, pop
        })
            2'b10: begin
                if (!full_reg) begin
                    wptr_next  = wptr_reg + 1;
                    empty_next = 0;
                    if (wptr_next == rptr_reg) begin
                        full_next = 1;
                    end
                end
            end
            2'b01: begin
                if (!empty_reg) begin
                    rptr_next = rptr_reg + 1;
                    full_next = 0;
                    if (rptr_next == wptr_reg) begin
                        empty_next = 1;
                    end
                end
            end
            2'b11: begin
                if (full_reg) begin
                    rptr_next = rptr_reg + 1;
                    full_next = 0;
                end else if (empty_reg) begin
                    wptr_next  = wptr_reg + 1;
                    empty_next = 0;
                end else begin
                    rptr_next = rptr_reg + 1;
                    wptr_next = wptr_reg + 1;
                end
            end
        endcase
    end



endmodule


    // always @(*) begin
    //     wptr_next <= wptr_reg;
    //     rptr_next <= rptr_reg;
    //     empty_next <= empty_reg;
    //     full_next <= full_reg;
    //     if(push) begin
    //         if(!full) begin
    //             wptr_next = wptr_reg + 1;
    //             if(wptr_next == rptr_reg) begin
    //                 full_next = 1;
    //             end
    //         end
    //     end
    //     else if(pop) begin
    //         if(!empty) begin
    //             rptr_next = rptr_reg + 1;
    //             if(rptr_next == wptr_reg) begin
    //                 empty_next = 1;
    //             end
    //         end
    //     end
    //     else if (push & pop) begin
    //         if(full) begin
    //             rptr_next = rptr_reg + 1;
    //             full_next = 0;
    //         end
    //         else if(empty) begin
    //             wptr_next = wptr_reg + 1;
    //             empty_next = 0;
    //         end else begin
    //             rptr_next = rptr_reg + 1;
    //             wptr_next = wptr_reg + 1;
    //         end
    //     end
    // end

//     always @(posedge clk, posedge rst) begin
//         if (rst) begin
//             wptr  <= 0;
//             full  <= 0;
//             empty <= 1;
//             rptr  <= 0;

//         end else begin
//             if (push & !full) begin
//                 wptr++;
//                 empty = 1'b0;
//                 if (wptr == rptr) begin
//                     full = 1'b1;
//                 end
//             end else if (pop & !empty) begin
//                 rptr++;
//                 full = 1'b0;
//                 if (wptr == rptr) begin
//                     empty = 1'b1;
//                 end
//             end else if (!full & !empty) begin
//                 if (push) begin
//                     wptr++;
//                 end else if (pop) begin
//                     rptr++;
//                 end 
//             end
//         end
//     end

// endmodule
