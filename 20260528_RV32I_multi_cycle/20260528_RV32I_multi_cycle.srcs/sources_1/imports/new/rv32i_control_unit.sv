`timescale 1ns / 1ps
`include "define.vh"

module rv32i_control_unit (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instr_code,
    output logic        pc_en,
    output logic        rf_we,
    output logic        branch,
    output logic        jal,
    output logic        jalr,
    output logic        alusrc_sel,
    output logic [ 3:0] alu_control,
    output logic [ 2:0] rfsrc_sel,
    output logic [ 2:0] mem_mode,
    output logic        dwe
);

    logic [6:0] funct7;
    logic [2:0] funct3;
    logic [6:0] opcode;

    assign opcode = instr_code[6:0];
    assign funct3 = instr_code[14:12];
    assign funct7 = instr_code[31:25];

    // [DEBUG]
    typedef enum logic [6:0] {
        DBG_R_TYPE  = `R_TYPE,
        DBG_S_TYPE  = `S_TYPE,
        DBG_IL_TYPE = `IL_TYPE,
        DBG_I_TYPE  = `I_TYPE,
        DBG_B_TYPE  = `B_TYPE,
        DBG_UL_TYPE = `UL_TYPE,
        DBG_UA_TYPE = `UA_TYPE,
        DBG_J_TYPE  = `J_TYPE,
        DBG_JL_TYPE = `JL_TYPE
    } opcode_dbg_e;

    opcode_dbg_e opcode_dbg;
    assign opcode_dbg = opcode_dbg_e'(opcode);
    

    typedef enum logic [2:0] {
        FETCH,
        DECODE,
        EXCUTE,
        MEM,
        WB
    } state_t;
    state_t c_state, n_state;



    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= FETCH;
        end else begin
            c_state <= n_state;
        end
    end

    //state next
    always_comb begin
        n_state = c_state;
        case (c_state)
            FETCH: begin
                n_state = DECODE;
            end
            DECODE: begin
                n_state = EXCUTE;
            end
            EXCUTE: begin
                case (opcode)
                    `R_TYPE, `I_TYPE, `B_TYPE, `UA_TYPE, `UL_TYPE, `J_TYPE, `JL_TYPE :  begin
                        n_state = FETCH;
                    end
                    `S_TYPE, `IL_TYPE: begin
                        n_state = MEM;
                    end
                endcase
            end
            MEM: begin
                if (opcode == `S_TYPE) n_state = FETCH;
                else n_state = WB;
            end
            WB: begin
                n_state = FETCH;
            end
        endcase
    end

    //output
    always_comb begin
        pc_en = 0;  //추가
        rf_we = 0;
        branch = 0;
        jal = 0;
        jalr = 0;
        alusrc_sel = 0;
        alu_control = 0;
        rfsrc_sel = 3'b0;
        mem_mode = 3'b0;
        dwe = 0;
        case (c_state)
            FETCH: pc_en = 1;
            EXCUTE: begin
                case (opcode)
                    `R_TYPE: begin
                        rf_we = 1;
                        alusrc_sel = 0;
                        rfsrc_sel = 0;
                        alu_control = {funct7[5], funct3};
                    end
                    `I_TYPE: begin
                        rf_we = 1;
                        alusrc_sel = 1;
                        rfsrc_sel = 0;
                        if (funct3 == 3'b101) alu_control = {funct7[5], funct3};
                        else alu_control = {1'b0, funct3};
                    end
                    `B_TYPE: begin
                        branch = 1;
                        alusrc_sel = 0;
                        alu_control = {1'b0, funct3};
                    end
                    `J_TYPE, `JL_TYPE: begin
                        rf_we = 1;
                        jal   = 1;
                        if (opcode == `J_TYPE) begin
                            jalr = 0;
                        end else begin
                            jalr = 1;
                        end
                        rfsrc_sel = 3'b100;
                    end
                    `UA_TYPE, `UL_TYPE: begin
                        rf_we = 1;
                        if (opcode == `UL_TYPE) rfsrc_sel = 3'b010;
                        else rfsrc_sel = 3'b011;
                    end
                    `S_TYPE, `IL_TYPE: begin
                        alusrc_sel  = 1'b1;
                        alu_control = `ADD;
                    end
                endcase
            end
            MEM: begin
                mem_mode = funct3;
                if (opcode == `S_TYPE) begin
                    dwe = 1'b1;
                end else begin
                    dwe = 1'b0;
                end
            end
            WB: begin
                rf_we = 1'b1;
                rfsrc_sel = 1;
            end
        endcase
    end
endmodule
